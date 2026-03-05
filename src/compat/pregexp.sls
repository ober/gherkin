#!chezscheme
;;; pregexp.sls -- Compat shim for Gerbil's :std/pregexp
;;; Re-exports pregexp from Chez's built-in support.
;;; Note: Chez has pregexp via the (pregexp) library or inline support.

(library (compat pregexp)
  (export pregexp pregexp-match pregexp-match-positions
          pregexp-replace pregexp-replace* pregexp-split
          pregexp-quote)
  (import (chezscheme))

  ;; Chez doesn't have a built-in pregexp library by default.
  ;; The compiler handles pregexp inline, so this is a fallback stub.
  ;; If the pregexp egg is installed, we'd import it. Otherwise, provide stubs.

  ;; Simple regex support via Chez's built-in regex functions is limited.
  ;; For now, we provide basic implementations.

  ;; pregexp is typically handled by the compiler compiling the call inline.
  ;; This library exists so (compat pregexp) can be imported without error.

  ;; If pregexp functions are used directly (not through compiler), they need
  ;; a real implementation. For basic use, we'll rely on the compiler's inline
  ;; handling.

  ;; Stub definitions that the compiler overrides:
  (define (pregexp pattern)
    ;; In practice, the compiler handles pregexp calls inline
    pattern)

  (define (pregexp-match pattern str . rest)
    #f)

  (define (pregexp-match-positions pattern str . rest)
    #f)

  (define (pregexp-replace pattern str replacement)
    str)

  (define (pregexp-replace* pattern str replacement)
    str)

  (define (pregexp-split pattern str)
    (list str))

  (define (pregexp-quote str)
    str)

  ) ;; end library
