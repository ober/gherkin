#!chezscheme
;;; test-e2e.ss -- End-to-end Gerbil compilation tests
;;; Verifies that Gerbil source code compiles to Chez and runs correctly.

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

(test-begin "End-to-End")

;; --- Test 1: Simple function definition and call ---
(let ((test-file "/tmp/gherkin-e2e-1.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (factorial n)\n" port)
      (display "  (if (<= n 1) 1\n" port)
      (display "    (* n (factorial (- n 1)))))\n" port)
      (display "(def result (factorial 10))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    ;; Evaluate in a fresh environment
    (let ((env (copy-environment (scheme-environment) #t)))
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "factorial(10)" 3628800 (eval 'result env)))))

;; --- Test 2: Defstruct with constructor and accessors ---
(let ((test-file "/tmp/gherkin-e2e-2.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(defstruct point (x y))\n" port)
      (display "(def p (make-point 3 4))\n" port)
      (display "(def px (point-x p))\n" port)
      (display "(def py (point-y p))\n" port)
      (display "(def is-point (point? p))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    ;; Need runtime imports for the eval environment
    (let ((env (copy-environment (scheme-environment) #t)))
      ;; Import runtime into the eval environment
      (eval '(import (compat types) (runtime util) (except (runtime table) string-hash)
                     (runtime mop) (runtime error) (runtime hash)) env)
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "point-x" 3 (eval 'px env))
      (test-equal "point-y" 4 (eval 'py env))
      (test-assert "point?" (eval 'is-point env)))))

;; --- Test 3: Match expression ---
(let ((test-file "/tmp/gherkin-e2e-3.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (list-length lst)\n" port)
      (display "  (match lst\n" port)
      (display "    ([] 0)\n" port)
      (display "    ([_ . rest] (+ 1 (list-length rest)))))\n" port)
      (display "(def result (list-length '(a b c d e)))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    (let ((env (copy-environment (scheme-environment) #t)))
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "match list-length" 5 (eval 'result env)))))

;; --- Test 4: let, when, unless, cond ---
(let ((test-file "/tmp/gherkin-e2e-4.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (classify n)\n" port)
      (display "  (cond\n" port)
      (display "    ((< n 0) 'negative)\n" port)
      (display "    ((= n 0) 'zero)\n" port)
      (display "    (else 'positive)))\n" port)
      (display "(def r1 (classify -5))\n" port)
      (display "(def r2 (classify 0))\n" port)
      (display "(def r3 (classify 42))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    (let ((env (copy-environment (scheme-environment) #t)))
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "classify -5" 'negative (eval 'r1 env))
      (test-equal "classify 0" 'zero (eval 'r2 env))
      (test-equal "classify 42" 'positive (eval 'r3 env)))))

;; --- Test 5: Higher-order functions ---
(let ((test-file "/tmp/gherkin-e2e-5.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (my-map f lst)\n" port)
      (display "  (match lst\n" port)
      (display "    ([] '())\n" port)
      (display "    ([hd . rest] (cons (f hd) (my-map f rest)))))\n" port)
      (display "(def result (my-map (lambda (x) (* x x)) '(1 2 3 4 5)))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    (let ((env (copy-environment (scheme-environment) #t)))
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "my-map squares" '(1 4 9 16 25) (eval 'result env)))))

;; --- Test 6: Compile to native .so and run ---
(let ((test-file "/tmp/gherkin-e2e-native.ss")
      (output-base "/tmp/gherkin-e2e-native-out"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(def (fib n)\n" port)
      (display "  (if (<= n 1) n\n" port)
      (display "    (+ (fib (- n 1)) (fib (- n 2)))))\n" port)
      (display "(display (fib 20))\n" port)
      (display "(newline)\n" port))
    'replace)
  (let ((chez-path (gherkin-make-binary test-file output-base)))
    (test-assert "native compilation produced file" (file-exists? chez-path))
    ;; Run the compiled program and capture output
    (let-values (((port get) (open-string-output-port)))
      ;; We can load the .ss file with --program to test
      ;; For now just verify it compiled
      (test-assert "native .so exists"
        (file-exists? (string-append output-base ".so"))))))

;; --- Test 7: def* (case-lambda) ---
(let ((compiled (gherkin-compile-string
                  "(def* my-add ((x) x) ((x y) (+ x y)) ((x y z) (+ x y z)))")))
  (test-assert "def* compiles" (pair? compiled))
  (let ((env (copy-environment (scheme-environment) #t)))
    (for-each (lambda (form) (eval form env)) compiled)
    (test-equal "def* 1 arg" 5 (eval '(my-add 5) env))
    (test-equal "def* 2 args" 7 (eval '(my-add 3 4) env))
    (test-equal "def* 3 args" 12 (eval '(my-add 3 4 5) env))))

;; --- Test 8: Defstruct with inheritance ---
(let ((test-file "/tmp/gherkin-e2e-8.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(defstruct animal (name))\n" port)
      (display "(defstruct (dog animal) (breed))\n" port)
      (display "(def d (make-dog \"Rex\" \"Labrador\"))\n" port)
      (display "(def dname (animal-name d))\n" port)
      (display "(def dbreed (dog-breed d))\n" port)
      (display "(def is-dog (dog? d))\n" port)
      (display "(def is-animal (animal? d))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    (let ((env (copy-environment (scheme-environment) #t)))
      (eval '(import (compat types) (runtime util) (except (runtime table) string-hash)
                     (runtime mop) (runtime error) (runtime hash)) env)
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "inherited field" "Rex" (eval 'dname env))
      (test-equal "own field" "Labrador" (eval 'dbreed env))
      (test-assert "dog?" (eval 'is-dog env))
      (test-assert "animal?" (eval 'is-animal env)))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
