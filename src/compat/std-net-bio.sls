#!chezscheme
;;; std-net-bio.sls -- Compat shim for Gerbil's :std/net/bio
;;; Binary I/O over network connections.
;;; Delegates to chez-ssl's conn-read/conn-write when available.

(library (compat std-net-bio)
  (export
    bio-read bio-write bio-close
    bio-read-u8 bio-write-u8)

  (import (chezscheme))

  ;; Bio operations map to basic port or connection I/O
  (define (bio-read port buf len)
    (get-bytevector-n! port buf 0 len))

  (define (bio-write port bv)
    (put-bytevector port bv)
    (flush-output-port port))

  (define (bio-close port)
    (close-port port))

  (define (bio-read-u8 port)
    (get-u8 port))

  (define (bio-write-u8 port byte)
    (put-u8 port byte))

  ) ;; end library
