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

(test-assert "disassemble-to-string returns string"
  (let ((result (disassemble-to-string '(lambda (x) (+ x 1)))))
    (and (string? result)
         (> (string-length result) 0))))

(test-assert "disassemble-to-string contains asm labels"
  (let ((result (disassemble-to-string '(lambda (x) (+ x 1)))))
    (or (string-contains-ci result "entry")
        (string-contains-ci result "mov")
        (string-contains-ci result "jmp"))))

(test-assert "disassemble prints output"
  (let ((output (with-output-to-string
                  (lambda ()
                    (disassemble '(lambda (x) x))))))
    (> (string-length output) 0)))

(test-assert "disassemble-to-string handles if"
  (let ((result (disassemble-to-string
                  '(lambda (x y) (if (< x y) x y)))))
    (and (string? result)
         (or (string-contains-ci result "bne")
             (string-contains-ci result "beq")
             (string-contains-ci result "bge")))))

(test-end)
