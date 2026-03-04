#!chezscheme
;;; test-match-defmethod.ss -- Test enhanced match patterns and defmethod full form
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

(test-begin "Match Patterns & Defmethod")

;;; ============================================================
;;; Quoted symbol patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ('foo "found foo")
                       ('bar "found bar")
                       (_ "other")))))
    ;; Test with 'foo
    (eval `(define x 'foo) env)
    (test-equal "match quoted symbol foo"
      "found foo" (eval compiled env))
    ;; Test with 'bar
    (eval '(set! x 'bar) env)
    (test-equal "match quoted symbol bar"
      "found bar" (eval compiled env))
    ;; Test with something else
    (eval '(set! x 'baz) env)
    (test-equal "match quoted symbol other"
      "other" (eval compiled env))))

;;; ============================================================
;;; Predicate with binding: (? pred var)
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ((? string? s) (string-append "str:" s))
                       ((? number? n) (+ n 1))
                       (_ "unknown")))))
    (eval '(define x "hello") env)
    (test-equal "match ? pred var string" "str:hello" (eval compiled env))
    (eval '(set! x 42) env)
    (test-equal "match ? pred var number" 43 (eval compiled env))
    (eval '(set! x #t) env)
    (test-equal "match ? pred var other" "unknown" (eval compiled env))))

;;; ============================================================
;;; And patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ((and (? number?) (? positive?)) "pos-num")
                       ((? number?) "non-pos-num")
                       (_ "not-num")))))
    (eval '(define x 5) env)
    (test-equal "match and pattern positive" "pos-num" (eval compiled env))
    (eval '(set! x -3) env)
    (test-equal "match and pattern non-pos" "non-pos-num" (eval compiled env))
    (eval '(set! x "hi") env)
    (test-equal "match and pattern not num" "not-num" (eval compiled env))))

;;; ============================================================
;;; Or patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ((or 1 2 3) "small")
                       (_ "other")))))
    (eval '(define x 2) env)
    (test-equal "match or pattern 2" "small" (eval compiled env))
    (eval '(set! x 5) env)
    (test-equal "match or pattern 5" "other" (eval compiled env))))

;;; ============================================================
;;; Not patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ((not #f) "truthy")
                       (_ "falsy")))))
    (eval '(define x 42) env)
    (test-equal "match not pattern truthy" "truthy" (eval compiled env))
    (eval '(set! x #f) env)
    (test-equal "match not pattern falsy" "falsy" (eval compiled env))))

;;; ============================================================
;;; Vector patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match v
                       (#(a b c) (+ a b c))
                       (_ 0)))))
    (eval '(define v (vector 10 20 30)) env)
    (test-equal "match vector pattern" 60 (eval compiled env))
    ;; Wrong length vector
    (eval '(set! v (vector 1 2)) env)
    (test-equal "match vector wrong length" 0 (eval compiled env))
    ;; Not a vector
    (eval '(set! v '(1 2 3)) env)
    (test-equal "match vector not vector" 0 (eval compiled env))))

;;; ============================================================
;;; Struct patterns
;;; ============================================================

;; First define a struct using the compiler
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (eval '(import (compat types)) env)
  (eval '(import (runtime mop)) env)
  (eval '(import (runtime hash)) env)
  (eval '(import (except (runtime table) string-hash)) env)
  (eval '(import (runtime util)) env)
  (eval '(import (compat gambit-compat)) env)

  ;; Define a struct
  (let ((struct-def (gherkin-compile-form '(defstruct Point (x y)))))
    (eval struct-def env))

  ;; Create an instance
  (eval '(define p (make-Point 3 4)) env)
  (test-assert "struct created" (eval '(Point? p) env))
  (test-equal "struct field x" 3 (eval '(Point-x p) env))
  (test-equal "struct field y" 4 (eval '(Point-y p) env))

  ;; Match against the struct
  (let ((compiled (gerbil-compile-expression
                    '(match p
                       ((Point x y) (+ x y))
                       (_ 0)))))
    (test-equal "match struct pattern" 7 (eval compiled env)))

  ;; Match with wildcard fields
  (let ((compiled (gerbil-compile-expression
                    '(match p
                       ((Point _ y) y)
                       (_ 0)))))
    (test-equal "match struct wildcard" 4 (eval compiled env)))

  ;; Match struct with nested pattern
  (let ((compiled (gerbil-compile-expression
                    '(match p
                       ((Point (? positive? x) y) (list x y))
                       (_ #f)))))
    (test-equal "match struct nested pred" '(3 4) (eval compiled env))))

;;; ============================================================
;;; Apply patterns
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(match x
                       ((apply car 1) "starts with 1")
                       (_ "other")))))
    (eval '(define x '(1 2 3)) env)
    (test-equal "match apply pattern" "starts with 1" (eval compiled env))))

;;; ============================================================
;;; defmethod full form
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (eval '(import (compat types)) env)
  (eval '(import (runtime mop)) env)
  (eval '(import (runtime hash)) env)
  (eval '(import (except (runtime table) string-hash)) env)
  (eval '(import (runtime util)) env)
  (eval '(import (compat gambit-compat)) env)

  ;; Define a class
  (let ((class-def (gherkin-compile-form '(defclass Widget (name)))))
    (eval class-def env))

  ;; Define a method using the full form
  (let ((method-def (gherkin-compile-form
                      '(defmethod (render (self Widget) buf)
                         (string-append "rendering:" (Widget-name self) ">" buf)))))
    (eval method-def env))

  ;; Create instance and set field directly
  (eval '(define w (make-Widget)) env)
  (eval '(Widget-name-set! w "btn") env)
  (test-equal "defmethod full form"
    "rendering:btn>screen"
    (eval '(call-method w 'render "screen") env)))

;; Test defmethod with @method form still works
(let ((compiled (gherkin-compile-form
                  '(defmethod (@method render Widget)
                     (lambda (self buf) (display buf))))))
  (test-assert "defmethod @method form"
    (and (pair? compiled) (eq? (car compiled) 'method-set!))))

;; Test defmethod with => return type annotation
(let ((compiled (gherkin-compile-form
                  '(defmethod (greet (self Widget) name) => :string
                     (string-append "Hello, " name)))))
  (test-assert "defmethod with => annotation"
    (and (pair? compiled) (eq? (car compiled) 'method-set!))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
