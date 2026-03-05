#!chezscheme
;;; test-sugar.ss -- Test Tier 1 sugar macros
;;; if-let, when-let, ignore-errors, with-destroy, do-while, values-set!,
;;; delay/force/lazy, cond-expand
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (compat types)
  (compat threading)
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

(test-begin "Sugar Macros")

;;; ============================================================
;;; if-let
;;; ============================================================

(test-equal "if-let compiles with else"
  '(let ((x 42)) (if x (+ x 1) 0))
  (gerbil-compile-expression '(if-let (x 42) (+ x 1) 0)))

(test-equal "if-let compiles without else"
  '(let ((x 42)) (if x (+ x 1) (void)))
  (gerbil-compile-expression '(if-let (x 42) (+ x 1))))

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (test-equal "if-let eval truthy"
    43
    (eval (gerbil-compile-expression '(if-let (x 42) (+ x 1) 0)) env))
  (test-equal "if-let eval falsy"
    0
    (eval (gerbil-compile-expression '(if-let (x #f) (+ x 1) 0)) env)))

;;; ============================================================
;;; when-let
;;; ============================================================

(test-equal "when-let compiles"
  '(let ((x 42)) (when x (+ x 1)))
  (gerbil-compile-expression '(when-let (x 42) (+ x 1))))

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (test-equal "when-let eval truthy"
    43
    (eval (gerbil-compile-expression '(when-let (x 42) (+ x 1))) env))
  (test-assert "when-let eval falsy returns void"
    (eq? (eval (gerbil-compile-expression '(when-let (x #f) (+ x 1))) env)
         (eval '(void) env))))

;;; ============================================================
;;; ignore-errors
;;; ============================================================

(test-assert "ignore-errors compiles"
  (pair? (gerbil-compile-expression '(ignore-errors (error "boom")))))

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (test-equal "ignore-errors catches"
    #f
    (eval (gerbil-compile-expression '(ignore-errors (error "boom" "test"))) env))
  (test-equal "ignore-errors passes through"
    42
    (eval (gerbil-compile-expression '(ignore-errors 42)) env)))

;;; ============================================================
;;; with-destroy
;;; ============================================================

(test-assert "with-destroy compiles"
  (let ((compiled (gerbil-compile-expression '(with-destroy obj (do-stuff obj)))))
    (and (pair? compiled) (eq? (car compiled) 'let))))

;;; ============================================================
;;; do-while
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (test-equal "do-while runs body at least once"
    1
    (eval (gerbil-compile-expression
            '(let ((count 0))
               (do-while #f (set! count (+ count 1)))
               count))
          env))
  (test-equal "do-while loops while true"
    3
    (eval (gerbil-compile-expression
            '(let ((count 0))
               (do-while (< count 3) (set! count (+ count 1)))
               count))
          env)))

;;; ============================================================
;;; values-set!
;;; ============================================================

(test-assert "values-set! compiles"
  (let ((compiled (gerbil-compile-expression '(values-set! (a b) (values 1 2)))))
    (and (pair? compiled) (eq? (car compiled) 'let-values))))

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (eval '(define a 0) env)
  (eval '(define b 0) env)
  (eval (gerbil-compile-expression '(values-set! (a b) (values 10 20))) env)
  (test-equal "values-set! sets first" 10 (eval 'a env))
  (test-equal "values-set! sets second" 20 (eval 'b env)))

;;; ============================================================
;;; delay / force / lazy
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (test-equal "delay/force pass through"
    42
    (eval (gerbil-compile-expression '(force (delay 42))) env)))

;;; ============================================================
;;; cond-expand
;;; ============================================================

(test-equal "cond-expand chez-scheme"
  '(begin 42)
  (gerbil-compile-expression '(cond-expand (chez-scheme 42))))

(test-equal "cond-expand gherkin"
  '(begin 42)
  (gerbil-compile-expression '(cond-expand (gherkin 42))))

(test-equal "cond-expand gambit falls through to else"
  '(begin 99)
  (gerbil-compile-expression '(cond-expand (gambit 42) (else 99))))

(test-equal "cond-expand unsupported no else"
  '(void)
  (gerbil-compile-expression '(cond-expand (gambit 42))))

(test-equal "cond-expand not"
  '(begin 42)
  (gerbil-compile-expression '(cond-expand ((not gambit) 42))))

(test-equal "cond-expand and"
  '(begin 42)
  (gerbil-compile-expression '(cond-expand ((and chez-scheme r6rs) 42))))

(test-equal "cond-expand or"
  '(begin 42)
  (gerbil-compile-expression '(cond-expand ((or gambit chez-scheme) 42))))

(test-end)
