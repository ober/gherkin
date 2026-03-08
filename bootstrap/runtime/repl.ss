(define (replx)
  (define (write-reason exn)
    (lambda (cont port)
      (\x23;\x23;display-exception-in-context exn cont port)
      #f))
  (with-exception-handler
    (lambda (exn)
      (\x23;\x23;continuation-capture
        (lambda (cont)
          (\x23;\x23;repl-within cont (write-reason exn) exn))))
    \x23;\x23;repl))

