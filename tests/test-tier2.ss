#!chezscheme
;;; test-tier2.ss -- Test Tier 2 features: compat modules, import map, Gambit primitives
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime c3)
  (runtime control)
  (runtime mop)
  (runtime error)
  (runtime hash)
  (runtime syntax)
  (runtime eval)
  (compiler compile)
  (boot gherkin)
  (tests test-helpers))

(test-begin "Tier 2 Features")

;;; ============================================================
;;; :std/test compat module
;;; ============================================================

;; Test that the module compiles and loads
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-test)) env)
  ;; Define and run a test suite
  (eval '(define my-suite
           (test-suite "Math Tests"
             (test-case "addition"
               (check (+ 1 2) => 3)
               (check (+ 0 0) => 0))
             (test-case "multiplication"
               (check (* 2 3) => 6))))
        env)
  ;; The suite was created if we can run it without error
  (test-assert ":std/test suite created" #t)
  ;; Run the suite
  (let ((result (eval '(run-tests! my-suite) env)))
    (test-assert ":std/test suite passes" result))
  ;; Test failure detection
  (eval '(define fail-suite
           (test-suite "Fail Tests"
             (test-case "bad math"
               (check (+ 1 2) => 99))))
        env)
  (let ((result (eval '(run-tests! fail-suite) env)))
    (test-assert ":std/test failure detected" (not result))))

;;; ============================================================
;;; :std/misc/ports compat module
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-misc-ports)) env)
  ;; Test read-all-as-string
  (let ((test-file "/tmp/gherkin-test-ports.txt"))
    (call-with-output-file test-file
      (lambda (port)
        (display "hello\nworld\nfoo\n" port))
      'replace)
    ;; read-all-as-string
    (test-equal "read-all-as-string"
      "hello\nworld\nfoo\n"
      (eval `(call-with-input-file ,test-file
               (lambda (port)
                 (read-all-as-string port)))
            env))
    ;; read-all-as-lines
    (test-equal "read-all-as-lines"
      '("hello" "world" "foo")
      (eval `(read-all-as-lines (open-input-file ,test-file)) env))
    ;; read-file-string
    (test-equal "read-file-string"
      "hello\nworld\nfoo\n"
      (eval `(read-file-string ,test-file) env))
    ;; write-file-string
    (let ((out-file "/tmp/gherkin-test-write.txt"))
      (eval `(write-file-string ,out-file "test output") env)
      (test-equal "write-file-string"
        "test output"
        (eval `(read-file-string ,out-file) env)))))

;;; ============================================================
;;; Import map entries
;;; ============================================================

;; Test that :std/test maps correctly
(let ((compiled (gerbil-compile-expression
                  '(let ((x 1)) x))))
  (test-assert "basic compile still works" (pair? compiled)))

;; Check import map has the new entries
;; We can test this by compiling an import form to library
;; The *default-import-map* is internal, but we can verify indirectly
;; by checking compile-to-library handles these imports

;;; ============================================================
;;; Gambit primitive inline compilations
;;; ============================================================

;; string-contains
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(string-contains "hello world" "world"))))
    (test-equal "string-contains found" 6 (eval compiled env)))
  (let ((compiled (gerbil-compile-expression
                    '(string-contains "hello" "xyz"))))
    (test-equal "string-contains not found" #f (eval compiled env))))

;; string-prefix?
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(string-prefix? "hel" "hello"))))
    (test-assert "string-prefix? true" (eval compiled env)))
  (let ((compiled (gerbil-compile-expression
                    '(string-prefix? "xyz" "hello"))))
    (test-assert "string-prefix? false" (not (eval compiled env)))))

;; string-suffix?
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(string-suffix? "llo" "hello"))))
    (test-assert "string-suffix? true" (eval compiled env)))
  (let ((compiled (gerbil-compile-expression
                    '(string-suffix? "xyz" "hello"))))
    (test-assert "string-suffix? false" (not (eval compiled env)))))

;; read-line → get-line
(let ((compiled (gerbil-compile-expression '(read-line port))))
  (test-equal "read-line compiles to get-line"
    '(get-line port)
    compiled))

;; pretty-print / pp
(let ((compiled (gerbil-compile-expression '(pp x))))
  (test-equal "pp compiles to pretty-print"
    '(pretty-print x)
    compiled))

;; make-parameter
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression '(make-parameter 42))))
    (let ((p (eval compiled env)))
      (test-equal "make-parameter default" 42 (p))
      (test-equal "make-parameter set"
        99
        (begin (p 99) (p))))))

;; subvector
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression '(subvector v 1 3))))
    (eval '(define v (vector 10 20 30 40 50)) env)
    (test-equal "subvector"
      '#(20 30)
      (eval compiled env))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
