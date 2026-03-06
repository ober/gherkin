#!chezscheme
;;; std-compress-zlib.sls -- Compat shim for Gerbil's :std/text/zlib
;;; and :std/compress/zlib
;;; Delegates to chez-zlib for native compression support.
;;;
;;; Gerbil provides compress/uncompress and gzip/gunzip operations.
;;; This shim maps to chez-zlib equivalents.

(library (compat std-compress-zlib)
  (export
    compress uncompress
    gzip gunzip
    gzip-data?
    deflate-bytevector inflate-bytevector
    gzip-bytevector gunzip-bytevector)

  (import (chezscheme))

  ;; Try to load chez-zlib
  (define *use-chez-zlib* #f)
  (define chez-gzip-bytevector #f)
  (define chez-gunzip-bytevector #f)
  (define chez-deflate-bytevector #f)
  (define chez-inflate-bytevector #f)
  (define chez-gzip-data? #f)

  (define dummy-init
    (guard (e [#t #f])
      (eval '(import (chez-zlib)))
      (set! *use-chez-zlib* #t)
      (set! chez-gzip-bytevector (eval 'gzip-bytevector))
      (set! chez-gunzip-bytevector (eval 'gunzip-bytevector))
      (set! chez-deflate-bytevector (eval 'deflate-bytevector))
      (set! chez-inflate-bytevector (eval 'inflate-bytevector))
      (set! chez-gzip-data? (eval 'gzip-data?))
      #t))

  ;; Gerbil's compress/uncompress are deflate/inflate
  (define (compress bv)
    (if *use-chez-zlib*
      (chez-deflate-bytevector (if (string? bv) (string->utf8 bv) bv))
      (error 'compress "chez-zlib not available; install from https://github.com/ober/chez-zlib")))

  (define (uncompress bv)
    (if *use-chez-zlib*
      (chez-inflate-bytevector bv)
      (error 'uncompress "chez-zlib not available")))

  ;; Gerbil's gzip/gunzip
  (define (gzip bv)
    (if *use-chez-zlib*
      (chez-gzip-bytevector (if (string? bv) (string->utf8 bv) bv))
      (error 'gzip "chez-zlib not available")))

  (define (gunzip bv)
    (if *use-chez-zlib*
      (chez-gunzip-bytevector bv)
      (error 'gunzip "chez-zlib not available")))

  (define (gzip-data? bv)
    (if *use-chez-zlib*
      (chez-gzip-data? bv)
      ;; Inline fallback check
      (and (bytevector? bv)
           (>= (bytevector-length bv) 2)
           (= (bytevector-u8-ref bv 0) #x1f)
           (= (bytevector-u8-ref bv 1) #x8b))))

  ;; Direct re-exports for code that uses the chez-zlib names
  (define (deflate-bytevector bv) (compress bv))
  (define (inflate-bytevector bv) (uncompress bv))
  (define (gzip-bytevector bv) (gzip bv))
  (define (gunzip-bytevector bv) (gunzip bv))

  ) ;; end library
