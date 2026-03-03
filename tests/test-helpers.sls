#!chezscheme
;;; test-helpers.sls -- Minimal test framework
(library (tests test-helpers)
  (export
    test-begin test-end
    test-assert test-equal test-error
    test-stats)

  (import (chezscheme))

  (define pass-count 0)
  (define fail-count 0)
  (define current-suite "")

  (define (test-begin name)
    (set! current-suite name)
    (set! pass-count 0)
    (set! fail-count 0)
    (printf "~n=== ~a ===~n" name))

  (define (test-end)
    (printf "~n--- ~a: ~a passed, ~a failed ---~n"
            current-suite pass-count fail-count)
    (when (> fail-count 0)
      (printf "*** FAILURES ***~n")))

  (define (test-pass name)
    (set! pass-count (+ pass-count 1))
    (printf "  PASS: ~a~n" name))

  (define (test-fail name msg)
    (set! fail-count (+ fail-count 1))
    (printf "  FAIL: ~a -- ~a~n" name msg))

  (define-syntax test-assert
    (syntax-rules ()
      [(_ name expr)
       (guard (exn [#t (test-fail name (format "exception: ~a" exn))])
         (if expr
             (test-pass name)
             (test-fail name "assertion failed")))]))

  (define-syntax test-equal
    (syntax-rules ()
      [(_ name expected actual)
       (guard (exn [#t (test-fail name (format "exception: ~a" exn))])
         (let ([e expected] [a actual])
           (if (equal? e a)
               (test-pass name)
               (test-fail name (format "expected ~s, got ~s" e a)))))]))

  (define-syntax test-error
    (syntax-rules ()
      [(_ name expr)
       (guard (exn [#t (test-pass name)])
         expr
         (test-fail name "expected error, got none"))]))

  (define (test-stats)
    (values pass-count fail-count))

  ) ;; end library
