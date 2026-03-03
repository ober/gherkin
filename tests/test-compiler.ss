#!chezscheme
;;; test-compiler.ss -- Test the Gerbil to Chez compiler
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

(test-begin "Compiler")

;;; Test basic form compilation

(test-equal "compile def"
  '(define (foo x) (+ x 1))
  (gherkin-compile-form '(def (foo x) (+ x 1))))

(test-equal "compile def variable"
  '(define x 42)
  (gherkin-compile-form '(def x 42)))

(test-equal "compile when"
  '(when (> x 0) (display x))
  (gerbil-compile-expression '(when (> x 0) (display x))))

(test-equal "compile if"
  '(if (> x 0) x 0)
  (gerbil-compile-expression '(if (> x 0) x 0)))

(test-equal "compile let single binding"
  '(let ((x 42)) (+ x 1))
  (gerbil-compile-expression '(let (x 42) (+ x 1))))

(test-equal "compile lambda"
  '(lambda (x y) (+ x y))
  (gerbil-compile-expression '(lambda (x y) (+ x y))))

;;; Test match compilation

(let ((result (gerbil-compile-expression
                '(match lst
                   ([hd . rest] hd)
                   ([] #f)))))
  (test-assert "match compiles to let+if" (pair? result)))

;;; Test defstruct compilation

(let ((result (gherkin-compile-form
                '(defstruct point (x y)))))
  (test-assert "defstruct compiles to begin" (and (pair? result) (eq? (car result) 'begin)))
  ;; Should contain: define point::t, make-point, point?, point-x, point-y, etc.
  (test-assert "defstruct has type def"
    (let ((defines (filter (lambda (f) (and (pair? f) (eq? (car f) 'define))) (cdr result))))
      (>= (length defines) 5))))  ;; type + constructor + predicate + 2 accessors + 2 mutators

;;; Test string compilation and evaluation

(let ((compiled (gherkin-compile-string "(def (add1 x) (+ x 1))")))
  (test-assert "string compilation" (pair? compiled))
  (test-equal "compiled def form"
    '(define (add1 x) (+ x 1))
    (car compiled)))

;;; Test compile and eval

;; Create a temp file with Gerbil code
(let ((test-file "/tmp/gherkin-test.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (square x) (* x x))\n" port)
      (display "(def result (square 7))\n" port))
    'replace)
  ;; Compile to Chez
  (let ((compiled (gerbil-compile-file test-file)))
    (test-assert "file compilation" (pair? compiled))
    (test-equal "compiled square def"
      '(define (square x) (* x x))
      (car compiled))
    (test-equal "compiled result def"
      '(define result (square 7))
      (cadr compiled))))

;;; Test eval of compiled code

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(define (gherkin-test-add x y) (+ x y)) env)
  (test-equal "eval compiled code" 7 (eval '(gherkin-test-add 3 4) env)))

;;; Test compile to native binary

(let ((test-file "/tmp/gherkin-hello.ss")
      (output-path "/tmp/gherkin-hello"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(display \"Hello from Gherkin!\\n\")\n" port))
    'replace)
  (let ((chez-path (gherkin-make-binary test-file output-path)))
    (test-assert "binary compilation produced .ss file"
      (file-exists? chez-path))
    (test-assert "binary compilation produced .so file"
      (file-exists? (string-append output-path ".so")))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
