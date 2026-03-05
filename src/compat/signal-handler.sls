#!chezscheme
;;; signal-handler.sls -- Compat shim for Gerbil's :std/os/signal-handler
;;; Signal handler registration.

(library (compat signal-handler)
  (export
    add-signal-handler!
    remove-signal-handler!)

  (import (except (chezscheme) filter))

  ;; Chez Scheme doesn't have native signal handler registration.
  ;; Provide stub implementations that register handlers but note
  ;; that actual signal delivery depends on the OS-level mechanism.

  (define *signal-handlers* '())

  (define (add-signal-handler! signum handler)
    ;; Register a signal handler. On Chez, we use register-signal-handler
    ;; if available, otherwise this is a best-effort stub.
    (set! *signal-handlers*
      (cons (cons signum handler) *signal-handlers*))
    ;; Try to use Chez's signal handler if available
    (when (top-level-bound? 'register-signal-handler)
      ((top-level-value 'register-signal-handler) signum handler)))

  (define (remove-signal-handler! signum)
    (set! *signal-handlers*
      (filter (lambda (p) (not (= (car p) signum))) *signal-handlers*)))

  (define (filter pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
      (else (filter pred (cdr lst)))))

  ) ;; end library
