#!chezscheme
;;; std-disasm.sls -- Disassembly support for Chez Scheme
;;; Uses Chez's $assembly-output to capture symbolic assembly during compilation.

(library (compat std-disasm)
  (export
    disassemble
    disassemble-to-string)

  (import (chezscheme))

  ;; Get symbolic assembly for an expression as a string
  (define (disassemble-to-string expr)
    (let ((port (open-output-string)))
      (parameterize ([#%$assembly-output port])
        (compile expr))
      (get-output-string port)))

  ;; Display symbolic assembly for an expression
  (define (disassemble expr)
    (parameterize ([#%$assembly-output (current-output-port)])
      (compile expr))
    (void))

  ) ;; end library
