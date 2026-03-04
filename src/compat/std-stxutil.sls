#!chezscheme
;;; std-stxutil.sls -- Compat shim for Gerbil's :std/stxutil module
;;; Re-exports syntax utilities for use at macro expansion time (phase 1).

(library (compat std-stxutil)
  (export
    stx-identifier genident gentemps
    format-id
    ;; Re-export core syntax ops commonly needed in macros
    stx-e stx-car stx-cdr stx->list stx->datum
    stx-pair? stx-null? stx-list?
    stx-map stx-for-each stx-foldl stx-foldr
    stx-wrap-source stx-source
    identifier? datum->syntax syntax->datum
    raise-syntax-error)

  (import
    (chezscheme)
    (runtime syntax))

  ;; format-id: convenience wrapper around stx-identifier for formatted identifier creation
  ;; (format-id ctx "make-~a" name) creates an identifier like make-foo
  (define (format-id ctx fmt . args)
    (let ((str (apply format fmt args)))
      (stx-identifier ctx str)))

  ;; Re-export datum->syntax and syntax->datum from Chez
  ;; These are already provided by (chezscheme), just re-exported here
  ;; for Gerbil compatibility.

  ) ;; end library
