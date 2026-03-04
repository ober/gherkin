#!chezscheme
;;; std-disasm.sls -- Disassembly support for Chez Scheme procedures
;;; Uses objdump as the backend disassembler

(library (compat std-disasm)
  (export
    disassemble
    disassemble-to-string
    disassemble-bytevector)

  (import (chezscheme))

  ;; Map Chez machine-type symbols to objdump -m architecture flags
  (define (machine-type->objdump-arch mt)
    (let ((s (symbol->string mt)))
      (cond
        ((or (string-contains s "a6") (string-contains s "x86_64"))
         "i386:x86-64")
        ((or (string-contains s "i3") (string-contains s "x86"))
         "i386")
        ((string-contains s "arm64")
         "aarch64")
        ((string-contains s "arm32")
         "arm")
        ((string-contains s "rv64")
         "riscv")
        ((string-contains s "ppc32")
         "powerpc")
        ((string-contains s "la64")
         "loongarch64")
        (else
         (error 'disassemble
                "unsupported architecture for disassembly"
                mt)))))

  ;; Simple string-contains helper
  (define (string-contains haystack needle)
    (let ((hlen (string-length haystack))
          (nlen (string-length needle)))
      (let lp ((i 0))
        (cond
          ((> (+ i nlen) hlen) #f)
          ((string=? (substring haystack i (+ i nlen)) needle) #t)
          (else (lp (+ i 1)))))))

  ;; Extract raw machine code bytes from a code object
  (define (extract-code-bytes code data-disp len)
    (let ((bv (make-bytevector len)))
      (do ((i 0 (+ i 1)))
          ((= i len) bv)
        (bytevector-u8-set! bv i
          (#%$object-ref 'unsigned-8 code (+ data-disp i))))))

  ;; Write bytevector to a temporary file, return the path
  (define (write-temp-file bv)
    (let ((path (format "/tmp/gherkin-disasm-~a.bin" (random 1000000))))
      (let ((port (open-file-output-port path
                    (file-options no-fail)
                    (buffer-mode block))))
        (put-bytevector port bv)
        (close-port port))
      path))

  ;; Run objdump and return output as a string
  (define (run-objdump-to-string bv arch)
    (let ((tmp (write-temp-file bv)))
      (dynamic-wind
        (lambda () #f)
        (lambda ()
          (let-values (((to-stdin from-stdout from-stderr pid)
                        (open-process-ports
                          (format "objdump -D -b binary -m ~a ~a" arch tmp)
                          (buffer-mode block)
                          (native-transcoder))))
            (close-port to-stdin)
            (let ((output (get-string-all from-stdout)))
              (close-port from-stdout)
              (close-port from-stderr)
              (parse-objdump-output output))))
        (lambda ()
          (when (file-exists? tmp)
            (delete-file tmp))))))

  ;; Strip objdump boilerplate, return clean assembly lines
  (define (parse-objdump-output raw)
    (let ((lines (string-split raw #\newline)))
      ;; Skip header lines (file format, section headers, etc.)
      ;; Assembly lines start with whitespace followed by hex address
      (let lp ((lines lines) (result '()) (past-header? #f))
        (cond
          ((null? lines)
           (apply string-append
             (map (lambda (l) (string-append l "\n"))
                  (reverse result))))
          ((and (not past-header?)
                (> (string-length (car lines)) 0)
                (or (string-contains (car lines) "Disassembly of")
                    (string-contains (car lines) "file format")
                    (string-contains (car lines) "<.data>")))
           (lp (cdr lines) result #t))
          ((and past-header?
                (> (string-length (car lines)) 0)
                (char-whitespace? (string-ref (car lines) 0)))
           (lp (cdr lines)
               (cons (string-trim (car lines)) result)
               #t))
          (else
           (lp (cdr lines) result past-header?))))))

  ;; Split a string by a character
  (define (string-split str ch)
    (let ((len (string-length str)))
      (let lp ((i 0) (start 0) (result '()))
        (cond
          ((= i len)
           (reverse (cons (substring str start len) result)))
          ((char=? (string-ref str i) ch)
           (lp (+ i 1) (+ i 1)
               (cons (substring str start i) result)))
          (else
           (lp (+ i 1) start result))))))

  ;; Trim leading whitespace
  (define (string-trim str)
    (let ((len (string-length str)))
      (let lp ((i 0))
        (cond
          ((= i len) "")
          ((char-whitespace? (string-ref str i))
           (lp (+ i 1)))
          (else (substring str i len))))))

  ;; Disassemble a raw bytevector with a given architecture string
  (define (disassemble-bytevector bv arch)
    (unless (bytevector? bv)
      (error 'disassemble-bytevector "not a bytevector" bv))
    (unless (string? arch)
      (error 'disassemble-bytevector "arch must be a string" arch))
    (display (run-objdump-to-string bv arch)))

  ;; Get disassembly as a string for a procedure
  (define (disassemble-to-string proc)
    (unless (procedure? proc)
      (error 'disassemble-to-string "not a procedure" proc))
    (let* ((code (#%$closure-code proc))
           (name (#%$code-name code))
           (data-disp (- (foreign-callable-entry-point code)
                         (#%$object-address code 0)))
           (len (#%$object-ref 'iptr code 8))
           (bv (extract-code-bytes code data-disp len))
           (arch (machine-type->objdump-arch (machine-type)))
           (asm (run-objdump-to-string bv arch)))
      (if name
        (string-append (format "disassembly of ~a:\n" name) asm)
        asm)))

  ;; Pretty-print disassembly of a procedure to stdout
  (define (disassemble proc)
    (unless (procedure? proc)
      (error 'disassemble "not a procedure" proc))
    (display (disassemble-to-string proc)))

  ) ;; end library
