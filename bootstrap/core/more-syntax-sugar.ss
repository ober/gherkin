(define-syntax identifier-rules
  (syntax-rules ()
    [(_ . body)
     (make-setq-macro macro: (syntax-rules . body))]))

(define-syntax quasisyntax (syntax-rules ()))

