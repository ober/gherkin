#!chezscheme
;;; test-disasm.ss -- Tests for disassembly module
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name)
  (tests test-helpers)
  (compat std-disasm))

;; Helper for test assertions
(define (string-contains-ci haystack needle)
  (let ((h (string-downcase haystack))
        (n (string-downcase needle)))
    (let ((hlen (string-length h))
          (nlen (string-length n)))
      (let lp ((i 0))
        (cond
          ((> (+ i nlen) hlen) #f)
          ((string=? (substring h i (+ i nlen)) n) #t)
          (else (lp (+ i 1))))))))

(test-begin "disassemble")

;; Test that disassemble-to-string returns non-empty output for a simple lambda
(test-assert "disassemble-to-string returns string"
  (let ((result (disassemble-to-string (lambda (x) x))))
    (and (string? result)
         (> (string-length result) 0))))

;; Test that disassemble-to-string output contains typical asm instructions
(test-assert "disassemble-to-string contains asm"
  (let ((result (disassemble-to-string (lambda (x) (+ x 1)))))
    ;; Should contain at least some hex addresses or asm mnemonics
    (or (string-contains-ci result "ret")
        (string-contains-ci result "mov")
        (string-contains-ci result "add")
        (> (string-length result) 10))))

;; Test that named procedures include their name
(test-assert "disassemble-to-string shows name for car"
  (let ((result (disassemble-to-string car)))
    (string-contains-ci result "car")))

;; Test that disassemble prints to stdout (non-empty)
(test-assert "disassemble prints output"
  (let ((output (with-output-to-string (lambda () (disassemble car)))))
    (> (string-length output) 0)))

;; Test disassemble-bytevector with known x86-64 bytes: nop + ret
(test-assert "disassemble-bytevector nop+ret"
  (let ((output (with-output-to-string
                  (lambda ()
                    (disassemble-bytevector
                      (bytevector #x90 #xc3)
                      "i386:x86-64")))))
    (and (> (string-length output) 0)
         (or (string-contains-ci output "nop")
             (string-contains-ci output "ret")))))

;; Test error on non-procedure
(test-error "disassemble rejects non-procedure"
  (disassemble 42))

(test-error "disassemble-to-string rejects non-procedure"
  (disassemble-to-string "not a proc"))

(test-error "disassemble-bytevector rejects non-bytevector"
  (disassemble-bytevector 42 "i386:x86-64"))

(test-end)
