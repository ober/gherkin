#!chezscheme
;;; test-tier1.ss -- Test Tier 1 compiler features
;;; let-hash, let/cc, defvalues, spawn/spawn-name, awhen, and-let*, with-lock
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

(test-begin "Tier 1 Features")

;;; ============================================================
;;; let/cc
;;; ============================================================

(test-equal "let/cc compiles"
  '(call/cc (lambda (k) (+ 1 2)))
  (gerbil-compile-expression '(let/cc k (+ 1 2))))

(test-equal "let/cc with early return"
  42
  (call/cc (lambda (return) (return 42) 99)))

;; Test compiled let/cc evaluates correctly
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (let ((compiled (gerbil-compile-expression
                    '(let/cc return
                       (when #t (return 42))
                       99))))
    (test-equal "let/cc eval" 42 (eval compiled env))))

;;; ============================================================
;;; defvalues
;;; ============================================================

(test-equal "defvalues compiles"
  '(define-values (a b c) (values 1 2 3))
  (gherkin-compile-form '(defvalues (a b c) (values 1 2 3))))

;; Test defvalues evaluates correctly
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (eval (gherkin-compile-form '(defvalues (x y) (values 10 20))) env)
  (test-equal "defvalues x" 10 (eval 'x env))
  (test-equal "defvalues y" 20 (eval 'y env)))

;;; ============================================================
;;; awhen
;;; ============================================================

(let ((compiled (gerbil-compile-expression '(awhen (x (find-it)) (use x)))))
  (test-assert "awhen compiles to let+when"
    (and (pair? compiled) (eq? (car compiled) 'let))))

;; Test awhen evaluates correctly
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  ;; awhen with truthy value
  (let ((compiled (gerbil-compile-expression
                    '(awhen (x 42) (+ x 1)))))
    (test-equal "awhen truthy" 43 (eval compiled env)))
  ;; awhen with #f — should not execute body (returns void)
  (let ((compiled (gerbil-compile-expression
                    '(awhen (x #f) (+ x 1)))))
    ;; Chez (when #f ...) returns (void), which is not equal? to any useful value
    (test-assert "awhen falsy does not return body"
      (not (equal? 1 (eval compiled env))))))

;;; ============================================================
;;; and-let*
;;; ============================================================

(let ((compiled (gerbil-compile-expression
                  '(and-let* ((x 1) (y 2)) (+ x y)))))
  (test-assert "and-let* compiles" (pair? compiled)))

;; Test and-let* evaluates correctly
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  ;; All bindings truthy
  (let ((compiled (gerbil-compile-expression
                    '(and-let* ((x 10) (y 20)) (+ x y)))))
    (test-equal "and-let* all truthy" 30 (eval compiled env)))
  ;; Short circuit on #f
  (let ((compiled (gerbil-compile-expression
                    '(and-let* ((x 10) (y #f)) (+ x y)))))
    (test-equal "and-let* short circuit" #f (eval compiled env)))
  ;; First binding is #f
  (let ((compiled (gerbil-compile-expression
                    '(and-let* ((x #f) (y 20)) (+ x y)))))
    (test-equal "and-let* first #f" #f (eval compiled env))))

;;; ============================================================
;;; let-hash
;;; ============================================================

;; Test compilation structure
(let ((compiled (gerbil-compile-expression
                  '(let-hash config .host))))
  (test-assert "let-hash compiles" (pair? compiled)))

;; Test let-hash with hash-ref (strong accessor)
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  ;; Import our hash module
  (eval '(import (runtime hash)) env)
  (eval '(import (except (runtime table) string-hash)) env)
  (eval '(import (runtime util)) env)
  ;; Create a hash table
  (eval '(define test-ht (make-hash-table)) env)
  (eval '(hash-put! test-ht 'host "localhost") env)
  (eval '(hash-put! test-ht 'port 8080) env)

  ;; Compile and eval let-hash with .field (strong accessor)
  (let ((compiled (gerbil-compile-expression
                    '(let-hash test-ht .host))))
    (test-equal "let-hash .field" "localhost" (eval compiled env)))

  ;; Compile and eval let-hash with .?field (weak accessor)
  (let ((compiled (gerbil-compile-expression
                    '(let-hash test-ht .?missing))))
    (test-equal "let-hash .?field missing" #f (eval compiled env)))

  ;; Compile and eval let-hash with body
  (let ((compiled (gerbil-compile-expression
                    '(let-hash test-ht
                       (list .host .port)))))
    (test-equal "let-hash body" '("localhost" 8080) (eval compiled env))))

;; Test let-hash with string accessor .$field
(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (chezscheme)) env)
  (eval '(import (runtime hash)) env)
  (eval '(import (except (runtime table) string-hash)) env)
  (eval '(import (runtime util)) env)
  (eval '(define test-ht (make-hash-table)) env)
  (eval '(hash-put! test-ht "name" "alice") env)
  (let ((compiled (gerbil-compile-expression
                    '(let-hash test-ht .$name))))
    (test-equal "let-hash .$field" "alice" (eval compiled env))))

;;; ============================================================
;;; spawn / spawn/name
;;; ============================================================

(let ((compiled (gerbil-compile-expression
                  '(spawn (lambda () (+ 1 2))))))
  (test-assert "spawn compiles"
    (and (pair? compiled)
         (eq? (car compiled) 'thread-start!))))

(let ((compiled (gerbil-compile-expression
                  '(spawn/name "worker" (lambda () (+ 1 2))))))
  (test-assert "spawn/name compiles"
    (and (pair? compiled)
         (eq? (car compiled) 'thread-start!))))

;; spawn with non-lambda expression
(let ((compiled (gerbil-compile-expression
                  '(spawn (do-work)))))
  (test-assert "spawn wraps non-lambda in thunk"
    (and (pair? compiled)
         (eq? (car compiled) 'thread-start!))))

;;; ============================================================
;;; with-lock
;;; ============================================================

(let ((compiled (gerbil-compile-expression
                  '(with-lock my-mutex (lambda () (do-stuff))))))
  (test-assert "with-lock compiles to dynamic-wind"
    (pair? compiled)))

(let ((compiled (gerbil-compile-expression
                  '(with-lock my-mutex (do-stuff)))))
  (test-assert "with-lock body form compiles"
    (pair? compiled)))

;;; ============================================================
;;; defmethod full form
;;; ============================================================

;; Test that defmethod with typed parameter compiles
(let ((compiled (gherkin-compile-form
                  '(defmethod (render (self MyWidget) buf area)
                     (display "rendering")))))
  (test-assert "defmethod full form compiles" (pair? compiled)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
