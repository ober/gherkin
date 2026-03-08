#!chezscheme
;;; sugar.sls -- Gerbil :std/sugar compatibility for Chez Scheme
;;;
;;; Provides syntax sugar forms that survive gherkin compilation:
;;; unwind-protect, try/catch/finally, with-catch, while, until, chain

(library (compat sugar)
  (export
    unwind-protect
    try catch finally
    with-catch
    while until
    chain)

  (import (chezscheme))

  ;; unwind-protect — like Java's try/finally
  (define-syntax unwind-protect
    (syntax-rules ()
      ((_ body cleanup ...)
       (dynamic-wind
         void
         (lambda () body)
         (lambda () cleanup ...)))))

  ;; Auxiliary keywords for try
  (define-syntax catch
    (lambda (x)
      (syntax-violation 'catch "misplaced auxiliary keyword" x)))

  (define-syntax finally
    (lambda (x)
      (syntax-violation 'finally "misplaced auxiliary keyword" x)))

  ;; try/catch/finally
  (define-syntax try
    (syntax-rules (catch finally)
      ((_ body ... (catch (var) handler ...))
       (guard (var [#t handler ...]) body ...))
      ((_ body ... (finally cleanup ...))
       (dynamic-wind
         void
         (lambda () body ...)
         (lambda () cleanup ...)))
      ((_ body ... (catch (var) handler ...) (finally cleanup ...))
       (dynamic-wind
         void
         (lambda () (guard (var [#t handler ...]) body ...))
         (lambda () cleanup ...)))))

  ;; with-catch — (with-catch handler thunk)
  (define (with-catch handler thunk)
    (guard (exn (#t (handler exn)))
      (thunk)))

  ;; while — (while test body ...)
  (define-syntax while
    (syntax-rules ()
      ((_ test body ...)
       (let loop ()
         (when test body ... (loop))))))

  ;; until — (until test body ...)
  (define-syntax until
    (syntax-rules ()
      ((_ test body ...)
       (let loop ()
         (unless test body ... (loop))))))

  ;; chain — threading macro: (chain expr (fn args ...) ...)
  ;; Threads expr through fn calls as first argument
  (define-syntax chain
    (syntax-rules ()
      ((_ expr) expr)
      ((_ expr (fn args ...) rest ...)
       (chain (fn expr args ...) rest ...))))

  ) ;; end library
