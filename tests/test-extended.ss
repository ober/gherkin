#!chezscheme
;;; test-extended.ss -- Tests for extended compiler features
;;; Hash tables, for loops, while/until, try/catch/finally, etc.

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

(test-begin "Extended Compiler")

;; --- Helper to compile and eval Gerbil code ---
(define (gerbil-eval-string code)
  (let ((compiled (gherkin-compile-string code))
        (env (copy-environment (scheme-environment) #t)))
    (eval '(import (compat types) (runtime util) (except (runtime table) string-hash)
                   (runtime mop) (runtime error) (runtime hash)) env)
    (for-each (lambda (form) (eval form env)) compiled)
    env))

;; ========================================
;; Hash table operations
;; ========================================

;; Test 1: make-hash-table and hash-put!/hash-get
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'x 10)
              (hash-put! ht 'y 20)
              (def rx (hash-get ht 'x))
              (def ry (hash-get ht 'y))
              (def rz (hash-get ht 'z))")))
  (test-equal "hash-put!/get x" 10 (eval 'rx env))
  (test-equal "hash-put!/get y" 20 (eval 'ry env))
  (test-equal "hash-get missing" #f (eval 'rz env)))

;; Test 2: hash-ref with default
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'a 1)
              (def ra (hash-ref ht 'a))
              (def rb (hash-ref ht 'b 42))")))
  (test-equal "hash-ref found" 1 (eval 'ra env))
  (test-equal "hash-ref default" 42 (eval 'rb env)))

;; Test 3: hash-remove! / hash-key?
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'x 10)
              (def before-remove (hash-key? ht 'x))
              (hash-remove! ht 'x)
              (def after-remove (hash-key? ht 'x))")))
  (test-assert "hash-key? before remove" (eval 'before-remove env))
  (test-assert "hash-key? after remove" (not (eval 'after-remove env))))

;; Test 4: hash-keys / hash-values / hash->list
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'a 1)
              (hash-put! ht 'b 2)
              (def keys (hash-keys ht))
              (def vals (hash-values ht))
              (def pairs (hash->list ht))")))
  (test-equal "hash-keys length" 2 (length (eval 'keys env)))
  (test-equal "hash-values length" 2 (length (eval 'vals env)))
  (test-equal "hash->list length" 2 (length (eval 'pairs env))))

;; Test 5: hash-for-each
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'a 1)
              (hash-put! ht 'b 2)
              (hash-put! ht 'c 3)
              (def total 0)
              (hash-for-each (lambda (k v) (set! total (+ total v))) ht)
              (def result total)")))
  (test-equal "hash-for-each sum" 6 (eval 'result env)))

;; Test 6: hash-update!
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'count 0)
              (hash-update! ht 'count (lambda (v) (+ v 1)) 0)
              (hash-update! ht 'count (lambda (v) (+ v 1)) 0)
              (hash-update! ht 'count (lambda (v) (+ v 1)) 0)
              (def result (hash-get ht 'count))")))
  (test-equal "hash-update!" 3 (eval 'result env)))

;; Test 7: list->hash-table
(let ((env (gerbil-eval-string
             "(def ht (list->hash-table '((a . 1) (b . 2) (c . 3))))
              (def ra (hash-get ht 'a))
              (def rb (hash-get ht 'b))
              (def rc (hash-get ht 'c))")))
  (test-equal "list->hash-table a" 1 (eval 'ra env))
  (test-equal "list->hash-table b" 2 (eval 'rb env))
  (test-equal "list->hash-table c" 3 (eval 'rc env)))

;; Test 8: hash-copy
(let ((env (gerbil-eval-string
             "(def h1 (make-hash-table))
              (hash-put! h1 'x 10)
              (def h2 (hash-copy h1))
              (hash-put! h2 'x 20)
              (def r1 (hash-get h1 'x))
              (def r2 (hash-get h2 'x))")))
  (test-equal "hash-copy original" 10 (eval 'r1 env))
  (test-equal "hash-copy is independent" 20 (eval 'r2 env)))

;; Test 9: hash-merge
(let ((env (gerbil-eval-string
             "(def h1 (make-hash-table))
              (hash-put! h1 'a 1)
              (def h2 (make-hash-table))
              (hash-put! h2 'b 2)
              (def merged (hash-merge h1 h2))
              (def ra (hash-get merged 'a))
              (def rb (hash-get merged 'b))")))
  (test-equal "hash-merge a" 1 (eval 'ra env))
  (test-equal "hash-merge b" 2 (eval 'rb env)))

;; ========================================
;; while / until loops
;; ========================================

;; Test 10: while loop
(let ((env (gerbil-eval-string
             "(def i 0)
              (def sum 0)
              (while (< i 10)
                (set! sum (+ sum i))
                (set! i (+ i 1)))
              (def result sum)")))
  (test-equal "while loop sum 0..9" 45 (eval 'result env)))

;; Test 11: until loop
(let ((env (gerbil-eval-string
             "(def i 0)
              (until (= i 5)
                (set! i (+ i 1)))
              (def result i)")))
  (test-equal "until loop" 5 (eval 'result env)))

;; ========================================
;; try / catch / finally
;; ========================================

;; Test 12: basic try/catch
(let ((env (gerbil-eval-string
             "(def result
                (try
                  (error 'test \"boom\")
                  (catch (e) 'caught)))")))
  (test-equal "try/catch basic" 'caught (eval 'result env)))

;; Test 13: try/catch with no error
(let ((env (gerbil-eval-string
             "(def result
                (try
                  42
                  (catch (e) 'caught)))")))
  (test-equal "try/catch no error" 42 (eval 'result env)))

;; Test 14: try/finally
(let ((env (gerbil-eval-string
             "(def cleanup-ran #f)
              (def result
                (try
                  42
                  (finally (set! cleanup-ran #t))))
              (def clean cleanup-ran)")))
  (test-equal "try/finally value" 42 (eval 'result env))
  (test-assert "try/finally cleanup ran" (eval 'clean env)))

;; Test 15: try/catch/finally
(let ((env (gerbil-eval-string
             "(def cleanup-ran #f)
              (def result
                (try
                  (error 'test \"boom\")
                  (catch (e) 'caught)
                  (finally (set! cleanup-ran #t))))
              (def clean cleanup-ran)")))
  (test-equal "try/catch/finally value" 'caught (eval 'result env))
  (test-assert "try/catch/finally cleanup" (eval 'clean env)))

;; ========================================
;; for iteration
;; ========================================

;; Test 16: basic for (single binding)
(let ((env (gerbil-eval-string
             "(def result '())
              (for (x '(1 2 3))
                (set! result (cons (* x x) result)))
              (def answer (reverse result))")))
  (test-equal "for loop" '(1 4 9) (eval 'answer env)))

;; Test 17: for with in-range
(let ((env (gerbil-eval-string
             "(def result '())
              (for (i (in-range 5))
                (set! result (cons i result)))
              (def answer (reverse result))")))
  (test-equal "for in-range" '(0 1 2 3 4) (eval 'answer env)))

;; Test 18: for/collect
(let ((env (gerbil-eval-string
             "(def result (for/collect (x '(1 2 3 4 5))
                            (* x x)))")))
  (test-equal "for/collect" '(1 4 9 16 25) (eval 'result env)))

;; Test 19: for/fold
(let ((env (gerbil-eval-string
             "(def result (for/fold ((sum 0)) (x '(1 2 3 4 5))
                            (+ sum x)))")))
  (test-equal "for/fold sum" 15 (eval 'result env)))

;; Test 20: for/or
(let ((env (gerbil-eval-string
             "(def r1 (for/or (x '(1 2 3 4 5))
                        (and (= x 3) x)))
              (def r2 (for/or (x '(1 2 4 5))
                        (and (= x 3) x)))")))
  (test-equal "for/or found" 3 (eval 'r1 env))
  (test-assert "for/or not found" (not (eval 'r2 env))))

;; Test 21: for/and
(let ((env (gerbil-eval-string
             "(def r1 (for/and (x '(2 4 6 8))
                        (even? x)))
              (def r2 (for/and (x '(2 4 5 8))
                        (even? x)))")))
  (test-assert "for/and all true" (eval 'r1 env))
  (test-assert "for/and not all true" (not (eval 'r2 env))))

;; ========================================
;; displayln
;; ========================================

;; Test 22: displayln
(let ((compiled (gherkin-compile-string "(displayln \"hello\")")))
  (test-assert "displayln compiles" (pair? compiled)))

;; ========================================
;; receive (multiple values)
;; ========================================

;; Test 23: receive
(let ((env (gerbil-eval-string
             "(def result
                (receive (a b)
                  (values 10 20)
                  (+ a b)))")))
  (test-equal "receive values" 30 (eval 'result env)))

;; ========================================
;; => type annotation stripping
;; ========================================

;; Test 24: def with => type annotation
(let ((env (gerbil-eval-string
             "(def (add x y) => :fixnum (+ x y))
              (def result (add 3 4))")))
  (test-equal "def with => annotation" 7 (eval 'result env)))

;; ========================================
;; @list (bracket syntax)
;; ========================================

;; Test 25: @list
(let ((compiled (gherkin-compile-string "(@list 1 2 3)")))
  (test-assert "@list compiles" (pair? compiled))
  (let ((env (copy-environment (scheme-environment) #t)))
    (test-equal "@list result" '(1 2 3) (eval (car compiled) env))))

;; ========================================
;; void
;; ========================================

;; Test 26: void
(let ((compiled (gherkin-compile-string "(void)")))
  (test-assert "void compiles" (pair? compiled)))

;; ========================================
;; string-join
;; ========================================

;; Test 27: string-join
(let ((env (gerbil-eval-string
             "(def result (string-join '(\"a\" \"b\" \"c\") \"-\"))")))
  (test-equal "string-join" "a-b-c" (eval 'result env)))

;; Test 28: string-join no sep
(let ((env (gerbil-eval-string
             "(def result (string-join '(\"hello\" \" \" \"world\")))")))
  (test-equal "string-join no sep" "hello world" (eval 'result env)))

;; ========================================
;; string-split
;; ========================================

;; Test 29: string-split
(let ((env (gerbil-eval-string
             "(def result (string-split \"a-b-c\" #\\-))")))
  (test-equal "string-split" '("a" "b" "c") (eval 'result env)))

;; ========================================
;; defmethod
;; ========================================

;; Test 30: defmethod + call-method (using direct method-set! since @method requires custom reader)
(let ((test-file "/tmp/gherkin-e2e-method.ss"))
  (call-with-output-file test-file
    (lambda (port)
      (display "(defstruct animal (name sound))\n" port)
      (display "(method-set! animal::t 'speak\n" port)
      (display "  (lambda (self)\n" port)
      (display "    (string-append (animal-name self) \" says \" (animal-sound self))))\n" port)
      (display "(def a (make-animal \"Dog\" \"Woof\"))\n" port)
      (display "(def result (call-method a 'speak))\n" port))
    'replace)
  (let ((compiled (gerbil-compile-file test-file)))
    (let ((env (copy-environment (scheme-environment) #t)))
      (eval '(import (compat types) (runtime util) (except (runtime table) string-hash)
                     (runtime mop) (runtime error) (runtime hash)) env)
      (for-each (lambda (form) (eval form env)) compiled)
      (test-equal "defmethod call-method" "Dog says Woof" (eval 'result env)))))

;; ========================================
;; Complex combined test
;; ========================================

;; Test 31: Hash + for/collect
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (hash-put! ht 'a 1)
              (hash-put! ht 'b 2)
              (hash-put! ht 'c 3)
              (def result (for/collect (k (hash-keys ht))
                            (cons k (hash-get ht k))))")))
  (test-equal "hash + for/collect len" 3 (length (eval 'result env))))

;; Test 32: Nested try/catch
(let ((env (gerbil-eval-string
             "(def result
                (try
                  (try
                    (error 'inner \"inner error\")
                    (catch (e) 'inner-caught))
                  (catch (e) 'outer-caught)))")))
  (test-equal "nested try/catch" 'inner-caught (eval 'result env)))

;; Test 33: while + hash
(let ((env (gerbil-eval-string
             "(def ht (make-hash-table))
              (def i 0)
              (while (< i 5)
                (hash-put! ht i (* i i))
                (set! i (+ i 1)))
              (def r0 (hash-get ht 0))
              (def r3 (hash-get ht 3))
              (def r4 (hash-get ht 4))")))
  (test-equal "while+hash 0" 0 (eval 'r0 env))
  (test-equal "while+hash 3" 9 (eval 'r3 env))
  (test-equal "while+hash 4" 16 (eval 'r4 env)))

;; Test 34: for with in-range start/end
(let ((env (gerbil-eval-string
             "(def result (for/collect (i (in-range 5 10))
                            i))")))
  (test-equal "for in-range 5 10" '(5 6 7 8 9) (eval 'result env)))

;; Test 35: foldl/foldr compilation
(let ((env (gerbil-eval-string
             "(def result (foldl cons '() '(1 2 3)))")))
  (test-equal "foldl" '(3 2 1) (eval 'result env)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
