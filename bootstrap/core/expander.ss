(begin
  (define-syntax syntax macro-expand-syntax)
  (define-syntax syntax-case macro-expand-syntax-case))

(begin
  (define-syntax syntax-rules
    (lambda (stx)
      (syntax-case stx ()
        [(_ ids clauses ...)
         (identifier-list? #'ids)
         (let-values ([(body)
                       (stx-map
                         (lambda%
                           (clause)
                           (syntax-case clause ()
                             [(hd body) #'(hd #'body)]
                             [(hd fender body) #'(hd fender #'body)]))
                         #'(clauses ...))])
           (syntax-case body ()
             [(clause ...)
              #'(lambda% ($stx) (syntax-case $stx ids clause ...))]))])))
  (define-syntax with-syntax
    (lambda (stx)
      (syntax-case stx ()
        [(_ () body ...) #'(let-values () body ...)]
        [(_ ((pat e)) body ...)
         #'(syntax-case e () [pat (let-values () body ...)])]
        [(_ ((pat e) ...) body ...)
         #'(syntax-case (list e ...) ()
             [(pat ...) (let-values () body ...)])])))
  (define-syntax with-syntax*
    (lambda (stx)
      (syntax-case stx (values)
        [(_ () body ...) #'(let-values () body ...)]
        [(recur (((values . hd) e) . rest) body ...)
         #'(let-values ([hd e]) (recur rest body ...))]
        [(recur (hd . rest) body ...)
         #'(with-syntax (hd) (recur rest body ...))])))
  (define-syntax syntax/loc
    (lambda (stx)
      (syntax-case stx ()
        [(_ src-stx form)
         #'(stx-wrap-source #'form (stx-source src-stx))]))))

