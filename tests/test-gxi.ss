#!chezscheme
;;; test-gxi.ss -- Subprocess-based tests for bin/gxi
;;; Runs fixture scripts via bin/gxi and verifies output.

(import (chezscheme) (tests test-helpers))

(test-begin "gxi")

;; Helper: run bin/gxi on a fixture file, return stdout as a string.
;; Assumes tests are run from the project root directory.
(define (run-gxi fixture)
  (let* ((root (current-directory))
         (gxi  (string-append root "/bin/gxi"))
         (path (string-append root "/" fixture)))
    (let-values (((to-stdin from-stdout from-stderr pid)
                  (open-process-ports
                    (string-append gxi " " path)
                    (buffer-mode block)
                    (native-transcoder))))
      (close-port to-stdin)
      (let ((out (get-string-all from-stdout)))
        (close-port from-stdout)
        (close-port from-stderr)
        out))))

;; Helper: check that stdout contains a given substring
(define (output-contains? output substr)
  (let ((olen (string-length output))
        (slen (string-length substr)))
    (let lp ((i 0))
      (cond
        ((> (+ i slen) olen) #f)
        ((string=? (substring output i (+ i slen)) substr) #t)
        (else (lp (+ i 1)))))))

;; --- Test 1: Basic script ---
(let ((out (run-gxi "tests/fixtures/gxi-hello.ss")))
  (test-assert "hello: greeting" (output-contains? out "Hello from gxi!"))
  (test-assert "hello: arithmetic" (output-contains? out "5")))

;; --- Test 2: Export skipped ---
(let ((out (run-gxi "tests/fixtures/gxi-export.ss")))
  (test-assert "export: not crashed" (output-contains? out "42")))

;; --- Test 3: Import resolution ---
(let ((out (run-gxi "tests/fixtures/gxi-import.ss")))
  (test-assert "import: format works" (output-contains? out "1 + 2 = 3")))

;; --- Test 4: Gambit stubs ---
(let ((out (run-gxi "tests/fixtures/gxi-gambit-stubs.ss")))
  (test-assert "stubs: process-statistics" (output-contains? out "stats-ok"))
  (test-assert "stubs: f64vector" (output-contains? out "1.5"))
  (test-assert "stubs: force-output" (output-contains? out "stubs-done")))

;; --- Test 5: Error resilience ---
(let ((out (run-gxi "tests/fixtures/gxi-error-resilience.ss")))
  (test-assert "error: continues after failure" (output-contains? out "after-error")))

;; --- Test 6: Defstruct ---
(let ((out (run-gxi "tests/fixtures/gxi-defstruct.ss")))
  (test-assert "defstruct: field x" (output-contains? out "10"))
  (test-assert "defstruct: field y" (output-contains? out "20"))
  (test-assert "defstruct: predicate" (output-contains? out "#t")))

;; --- Test 7: Stripped import (iter) ---
(let ((out (run-gxi "tests/fixtures/gxi-iter.ss")))
  (test-assert "iter: for loop item 1" (output-contains? out "1"))
  (test-assert "iter: for loop item 3" (output-contains? out "3")))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
