#!chezscheme
;;; std-net-ssl.sls -- Compat shim for Gerbil's :std/net/ssl
;;; Delegates to chez-ssl for native TLS support.
;;;
;;; Gerbil's :std/net/ssl provides SSL context creation and management.
;;; This shim maps those calls to chez-ssl equivalents.

(library (compat std-net-ssl)
  (export
    make-ssl-context ssl-context?
    ssl-connect ssl-close ssl-read ssl-write
    ssl-init! ssl-cleanup!)

  (import (chezscheme))

  ;; Try to load chez-ssl
  (define *use-chez-ssl* #f)
  (define chez-ssl-init! #f)
  (define chez-ssl-connect #f)
  (define chez-ssl-close #f)
  (define chez-ssl-read #f)
  (define chez-ssl-write #f)

  (define dummy-init
    (guard (e [#t #f])
      (eval '(import (chez-ssl)))
      (set! *use-chez-ssl* #t)
      (set! chez-ssl-init! (eval 'ssl-init!))
      (set! chez-ssl-connect (eval 'ssl-connect))
      (set! chez-ssl-close (eval 'ssl-close))
      (set! chez-ssl-read (eval 'ssl-read))
      (set! chez-ssl-write (eval 'ssl-write))
      #t))

  ;; SSL context (opaque wrapper)
  (define-record-type ssl-context
    (fields (mutable purpose))
    (protocol
      (lambda (new)
        (lambda args
          (when *use-chez-ssl*
            (chez-ssl-init!))
          (new (if (pair? args) (car args) 'connect))))))

  (define (ssl-init!)
    (when *use-chez-ssl*
      (chez-ssl-init!)))

  (define (ssl-cleanup!)
    (void))

  (define (ssl-connect host port . args)
    (if *use-chez-ssl*
      (chez-ssl-connect host port)
      (error 'ssl-connect "chez-ssl not available; install from https://github.com/ober/chez-ssl")))

  (define (ssl-close conn)
    (if *use-chez-ssl*
      (chez-ssl-close conn)
      (void)))

  (define (ssl-read conn buf len)
    (if *use-chez-ssl*
      (chez-ssl-read conn buf len)
      (error 'ssl-read "chez-ssl not available")))

  (define (ssl-write conn bv)
    (if *use-chez-ssl*
      (chez-ssl-write conn bv)
      (error 'ssl-write "chez-ssl not available")))

  ) ;; end library
