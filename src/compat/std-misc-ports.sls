#!chezscheme
;;; std-misc-ports.sls -- Compat shim for Gerbil's :std/misc/ports module
;;; Provides read-all-as-string, read-all-as-u8vector, copy-port, etc.

(library (compat std-misc-ports)
  (export
    read-all-as-string
    read-all-as-u8vector
    read-all-as-lines
    copy-port
    read-file-string
    read-file-lines
    write-file-string)

  (import (chezscheme))

  ;; --- read-all-as-string ---
  ;; In Gerbil, read-line with #f as separator reads until EOF.
  ;; In Chez, we read chunks until EOF.
  (define (read-all-as-string port)
    (let lp ((chunks '()))
      (let ((buf (get-string-n port 4096)))
        (if (eof-object? buf)
          (if (null? chunks)
            ""
            (apply string-append (reverse chunks)))
          (lp (cons buf chunks))))))

  ;; --- read-all-as-u8vector ---
  ;; Read all bytes from a binary input port.
  (define (read-all-as-u8vector port . rest)
    (let ((bufsize (if (pair? rest) (car rest) 8192)))
      (let lp ((chunks '()))
        (let ((buf (make-bytevector bufsize)))
          (let ((n (get-bytevector-n! port buf 0 bufsize)))
            (cond
              ((eof-object? n)
               (if (null? chunks)
                 (make-bytevector 0)
                 (bytevector-concat (reverse chunks))))
              ((< n bufsize)
               (let ((trimmed (make-bytevector n)))
                 (bytevector-copy! buf 0 trimmed 0 n)
                 (bytevector-concat (reverse (cons trimmed chunks)))))
              (else
               (lp (cons buf chunks)))))))))

  ;; Helper: concatenate a list of bytevectors
  (define (bytevector-concat bvs)
    (if (null? bvs)
      (make-bytevector 0)
      (if (null? (cdr bvs))
        (car bvs)
        (let* ((total (fold-left (lambda (acc bv) (+ acc (bytevector-length bv))) 0 bvs))
               (result (make-bytevector total)))
          (let lp ((bvs bvs) (offset 0))
            (unless (null? bvs)
              (let ((bv (car bvs)))
                (bytevector-copy! bv 0 result offset (bytevector-length bv))
                (lp (cdr bvs) (+ offset (bytevector-length bv))))))
          result))))

  ;; --- read-all-as-lines ---
  ;; Read all lines from a textual input port, returning a list of strings.
  (define (read-all-as-lines port)
    (let lp ((lines '()))
      (let ((line (get-line port)))
        (if (eof-object? line)
          (reverse lines)
          (lp (cons line lines))))))

  ;; --- copy-port ---
  ;; Copy all data from input port to output port.
  (define (copy-port in out)
    (cond
      ((and (binary-port? in) (binary-port? out))
       ;; Binary copy
       (let ((buf (make-bytevector 8192)))
         (let lp ()
           (let ((n (get-bytevector-n! in buf 0 8192)))
             (unless (eof-object? n)
               (put-bytevector out buf 0 n)
               (lp))))))
      (else
       ;; Textual copy
       (let ((buf (make-string 4096)))
         (let lp ()
           (let ((n (get-string-n! in buf 0 4096)))
             (unless (eof-object? n)
               (put-string out buf 0 n)
               (lp))))))))

  ;; --- read-file-string ---
  ;; Read entire file as a string.
  (define (read-file-string path)
    (call-with-input-file path
      (lambda (port)
        (read-all-as-string port))))

  ;; --- read-file-lines ---
  ;; Read all lines from a file.
  (define (read-file-lines path)
    (call-with-input-file path
      (lambda (port)
        (read-all-as-lines port))))

  ;; --- write-file-string ---
  ;; Write a string to a file.
  (define (write-file-string path str)
    (call-with-output-file path
      (lambda (port)
        (put-string port str))
      'replace))

  ) ;; end library
