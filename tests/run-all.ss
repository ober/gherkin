#!chezscheme
;;; run-all.ss -- Run all test suites
(import (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name) (tests test-helpers))

(define test-files
  '("tests/test-compat.ss"
    "tests/test-types.ss"
    "tests/test-threading.ss"
    "tests/test-reader.ss"
    "tests/test-runtime.ss"
    "tests/test-compiler.ss"
    "tests/test-e2e.ss"
    "tests/test-extended.ss"
    "tests/test-gxi.ss"))

(define total-pass 0)
(define total-fail 0)

(for-each
  (lambda (file)
    (printf "~n========================================~n")
    (printf "Running ~a~n" file)
    (printf "========================================~n")
    (guard (exn
            [#t (printf "ERROR in ~a: ~a~n" file exn)
                (set! total-fail (+ total-fail 1))])
      (load file)))
  test-files)

(printf "~n========================================~n")
(printf "TOTAL: ~a passed, ~a failed~n" total-pass total-fail)
(printf "========================================~n")
(exit (if (> total-fail 0) 1 0))
