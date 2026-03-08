(define (core-expand-begin% stx)
  (define (expand-special hd K rest r)
    (K rest (cons (core-expand-top hd) r)))
  (core-expand-block stx expand-special))

(define (core-expand-begin-syntax% stx)
  (define (expand-special hd K rest r)
    (let ([K (lambda (e) (K rest (cons e r)))])
      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-739} hd])
        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-740} (lambda ()
                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-741} (lambda ()
                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-742} (lambda ()
                                                                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-743} (lambda ()
                                                                                                                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-744} (lambda ()
                                                                                                                                                                                                                                                        (raise-syntax-error
                                                                                                                                                                                                                                                          #f
                                                                                                                                                                                                                                                          "Bad syntax; invalid syntax-case clause"
                                                                                                                                                                                                                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-739}))])
                                                                                                                                                                                                          (if (stx-pair?
                                                                                                                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-739})
                                                                                                                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-745} (syntax-e
                                                                                                                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-739})])
                                                                                                                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-746} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-745})]
                                                                                                                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-747} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-745})])
                                                                                                                                                                                                                  (if (and (identifier?
                                                                                                                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-746})
                                                                                                                                                                                                                           (core-identifier=?
                                                                                                                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-746}
                                                                                                                                                                                                                             '%\x23;define-runtime))
                                                                                                                                                                                                                      (K (core-expand-define-runtime%
                                                                                                                                                                                                                           hd))
                                                                                                                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-744}))))
                                                                                                                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-744}))))])
                                                                                                                                                          (if (stx-pair?
                                                                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-739})
                                                                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-748} (syntax-e
                                                                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-739})])
                                                                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-749} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-748})]
                                                                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-750} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-748})])
                                                                                                                                                                  (if (and (identifier?
                                                                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-749})
                                                                                                                                                                           (core-identifier=?
                                                                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-749}
                                                                                                                                                                             '%\x23;define-alias))
                                                                                                                                                                      (K (core-expand-define-alias%
                                                                                                                                                                           hd))
                                                                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-743}))))
                                                                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-743}))))])
                                                                                                          (if (stx-pair?
                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-739})
                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-751} (syntax-e
                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-739})])
                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-752} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-751})]
                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-753} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-751})])
                                                                                                                  (if (and (identifier?
                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-752})
                                                                                                                           (core-identifier=?
                                                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-752}
                                                                                                                             '%\x23;define-syntax))
                                                                                                                      (K (core-expand-define-syntax%
                                                                                                                           hd))
                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-742}))))
                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-742}))))])
                                                          (if (stx-pair?
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-739})
                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-754} (syntax-e
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-739})])
                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-755} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-754})]
                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-756} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-754})])
                                                                  (if (and (identifier?
                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-755})
                                                                           (core-identifier=?
                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-755}
                                                                             '%\x23;define-values))
                                                                      (if (stx-pair?
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-756})
                                                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-757} (syntax-e
                                                                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-756})])
                                                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-758} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-757})]
                                                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-759} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-757})])
                                                                              (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-758}])
                                                                                (if (stx-pair?
                                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-759})
                                                                                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-760} (syntax-e
                                                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-759})])
                                                                                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-761} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-760})]
                                                                                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-762} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-760})])
                                                                                        (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-761}])
                                                                                          (if (stx-null?
                                                                                                #{csc-t dpuuv4a3mobea70icwo8nvdax-762})
                                                                                              (if (core-bind-values?
                                                                                                    hd-bind)
                                                                                                  (begin
                                                                                                    (core-bind-values!
                                                                                                      hd-bind)
                                                                                                    (K hd))
                                                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-741}))
                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-741})))))
                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-741})))))
                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-741}))
                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-741}))))
                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-741}))))])
          (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-739})
              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-763} (syntax-e
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-739})])
                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-764} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-763})]
                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-765} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-763})])
                  (if (and (identifier?
                             #{csc-h dpuuv4a3mobea70icwo8nvdax-764})
                           (core-identifier=?
                             #{csc-h dpuuv4a3mobea70icwo8nvdax-764}
                             '%\x23;begin-syntax))
                      (K (core-expand-begin-syntax% hd))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-740}))))
              (#{csc-E dpuuv4a3mobea70icwo8nvdax-740}))))))
  (define (eval-body rbody)
    (let lp ([rest rbody] [body '()] [ebody '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-766} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-766})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-767} (car #{match-val dpuuv4a3mobea70icwo8nvdax-766})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-768} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-766})])
              (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-767}])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-768}])
                  (begin
                    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-769} hd])
                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-770} (lambda ()
                                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-771} (lambda ()
                                                                                                                      (lp rest
                                                                                                                          (cons
                                                                                                                            hd
                                                                                                                            body)
                                                                                                                          (cons
                                                                                                                            hd
                                                                                                                            ebody)))])
                                                                        (if (stx-pair?
                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-769})
                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-772} (syntax-e
                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-769})])
                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-773} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-772})]
                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-774} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-772})])
                                                                                (if (and (identifier?
                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-773})
                                                                                         (core-identifier=?
                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-773}
                                                                                           '%\x23;begin-syntax))
                                                                                    (lp rest
                                                                                        (cons
                                                                                          hd
                                                                                          body)
                                                                                        ebody)
                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-771}))))
                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-771}))))])
                        (if (stx-pair?
                              #{csc-e dpuuv4a3mobea70icwo8nvdax-769})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-775} (syntax-e
                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-769})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-776} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-775})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-777} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-775})])
                                (if (and (identifier?
                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-776})
                                         (core-identifier=?
                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-776}
                                           '%\x23;define-values))
                                    (if (stx-pair?
                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-777})
                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-778} (syntax-e
                                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-777})])
                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-779} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-778})]
                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-780} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-778})])
                                            (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-779}])
                                              (if (stx-pair?
                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-780})
                                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-781} (syntax-e
                                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-780})])
                                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-782} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-781})]
                                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-783} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-781})])
                                                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-782}])
                                                        (if (stx-null?
                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-783})
                                                            (let ([ehd (core-quote-syntax
                                                                         (list
                                                                           (core-quote-syntax
                                                                             '%\x23;define-values)
                                                                           (core-quote-bind-values
                                                                             hd-bind)
                                                                           (core-expand-expression
                                                                             expr))
                                                                         (stx-source
                                                                           hd))])
                                                              (lp rest
                                                                  (cons
                                                                    ehd
                                                                    body)
                                                                  (cons
                                                                    ehd
                                                                    ebody)))
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-770})))))
                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-770})))))
                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-770}))
                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-770}))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-770}))))))))
            (begin
              (values
                body
                (eval-syntax*
                  (core-quote-syntax
                    (core-cons '%\x23;begin ebody)
                    (stx-source stx)))))))))
  (parameterize ([current-expander-phi
                  (fx1+ (current-expander-phi))])
    (let ([rbody (core-expand-block stx expand-special #f)])
      (let-values ([(expanded-body value) (eval-body rbody)])
        (core-quote-syntax
          (if (module-context? (current-expander-context))
              (core-cons '%\x23;begin-syntax expanded-body)
              (list (core-quote-syntax '%\x23;quote) value))
          (stx-source stx))))))

(define (core-expand-begin-foreign% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-784} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-785} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-784}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-784})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-786} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-784})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-787} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-786})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-788} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-786})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-788}])
                (if (stx-list? body)
                    (core-quote-syntax
                      (core-cons '%\x23;begin-foreign body)
                      (stx-source stx))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-785})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-785})))))

(define (core-expand-begin-module% stx)
  (raise-syntax-error #f "Illegal expansion" stx))

(define (core-expand-begin-annotation% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-789} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-790} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-789}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-789})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-791} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-789})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-792} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-791})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-793} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-791})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-793})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-794} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-793})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-795} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-794})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-796} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-794})])
                      (let ([ann #{csc-h dpuuv4a3mobea70icwo8nvdax-795}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-796})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-797} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-796})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-798} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-797})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-799} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-797})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-798}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-799})
                                      (core-quote-syntax
                                        (list
                                          (core-quote-syntax
                                            '%\x23;begin-annotation)
                                          ann
                                          (core-expand-expression expr))
                                        (stx-source stx))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-790})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-790})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-790}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-790})))))

(define (core-expand-local-block stx body)
  (define (expand-special hd K rest r)
    (K (list) (cons (expand-internal hd rest) r)))
  (define (expand-internal hd rest)
    (parameterize ([current-expander-context
                    (make-local-context)])
      (wrap-internal
        (core-expand-block
          (stx-wrap-source
            (cons* '%\x23;begin hd rest)
            (stx-source stx))
          expand-internal-special
          #f))))
  (define (expand-internal-special hd K rest r)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-800} hd])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-801} (lambda ()
                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-802} (lambda ()
                                                                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-803} (lambda ()
                                                                                                                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-804} (lambda ()
                                                                                                                                                                                                      (raise-syntax-error
                                                                                                                                                                                                        #f
                                                                                                                                                                                                        "Bad syntax; invalid syntax-case clause"
                                                                                                                                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-800}))])
                                                                                                                                                        (if (stx-pair?
                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-800})
                                                                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-805} (syntax-e
                                                                                                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-800})])
                                                                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-806} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-805})]
                                                                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-807} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-805})])
                                                                                                                                                                (if (and (identifier?
                                                                                                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-806})
                                                                                                                                                                         (core-identifier=?
                                                                                                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-806}
                                                                                                                                                                           '%\x23;declare))
                                                                                                                                                                    (K rest
                                                                                                                                                                       (cons
                                                                                                                                                                         (core-expand-declare%
                                                                                                                                                                           hd)
                                                                                                                                                                         r))
                                                                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-804}))))
                                                                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-804}))))])
                                                                                                        (if (stx-pair?
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-800})
                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-808} (syntax-e
                                                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-800})])
                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-809} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-808})]
                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-810} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-808})])
                                                                                                                (if (and (identifier?
                                                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-809})
                                                                                                                         (core-identifier=?
                                                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-809}
                                                                                                                           '%\x23;define-alias))
                                                                                                                    (begin
                                                                                                                      (core-expand-define-alias%
                                                                                                                        hd)
                                                                                                                      (K rest
                                                                                                                         r))
                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-803}))))
                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-803}))))])
                                                        (if (stx-pair?
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-800})
                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-811} (syntax-e
                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-800})])
                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-812} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-811})]
                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-813} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-811})])
                                                                (if (and (identifier?
                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-812})
                                                                         (core-identifier=?
                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-812}
                                                                           '%\x23;define-syntax))
                                                                    (begin
                                                                      (core-expand-define-syntax%
                                                                        hd)
                                                                      (K rest
                                                                         r))
                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-802}))))
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-802}))))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-800})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-814} (syntax-e
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-800})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-815} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-814})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-816} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-814})])
                (if (and (identifier?
                           #{csc-h dpuuv4a3mobea70icwo8nvdax-815})
                         (core-identifier=?
                           #{csc-h dpuuv4a3mobea70icwo8nvdax-815}
                           '%\x23;define-values))
                    (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-816})
                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-817} (syntax-e
                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-816})])
                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-818} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-817})]
                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-819} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-817})])
                            (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-818}])
                              (if (stx-pair?
                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-819})
                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-820} (syntax-e
                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-819})])
                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-821} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-820})]
                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-822} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-820})])
                                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-821}])
                                        (if (stx-null?
                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-822})
                                            (if (core-bind-values? hd-bind)
                                                (begin
                                                  (core-bind-values!
                                                    hd-bind)
                                                  (K rest (cons hd r)))
                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-801}))
                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-801})))))
                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-801})))))
                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-801}))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-801}))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-801})))))
  (define (wrap-internal rbody)
    (let lp ([rest rbody]
             [decls (list)]
             [bind (list)]
             [body (list)])
      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-823} rest])
        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-824} (lambda ()
                                                        (let* ([body (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-825} body])
                                                                       (if (null?
                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-825})
                                                                           (begin
                                                                             (raise-syntax-error
                                                                               #f
                                                                               "Bad syntax; empty body"
                                                                               stx))
                                                                           (if (pair?
                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-825})
                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-826} (car #{match-val dpuuv4a3mobea70icwo8nvdax-825})]
                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-827} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-825})])
                                                                                 (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-826}])
                                                                                   (if (null?
                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-827})
                                                                                       (begin
                                                                                         expr)
                                                                                       (begin
                                                                                         (core-quote-syntax
                                                                                           (core-cons
                                                                                             '%\x23;begin
                                                                                             body)
                                                                                           (stx-source
                                                                                             stx))))))
                                                                               (begin
                                                                                 (core-quote-syntax
                                                                                   (core-cons
                                                                                     '%\x23;begin
                                                                                     body)
                                                                                   (stx-source
                                                                                     stx))))))])
                                                          (let* ([body (if (null?
                                                                             bind)
                                                                           body
                                                                           (core-quote-syntax
                                                                             (list
                                                                               (core-quote-syntax
                                                                                 '%\x23;letrec*-values)
                                                                               bind
                                                                               body)
                                                                             (stx-source
                                                                               stx)))])
                                                            (if (null?
                                                                  decls)
                                                                body
                                                                (core-quote-syntax
                                                                  (list
                                                                    (core-quote-syntax
                                                                      '%\x23;begin-annotation)
                                                                    decls
                                                                    body)
                                                                  (stx-source
                                                                    stx))))))])
          (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-823})
              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-828} (syntax-e
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-823})])
                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-829} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-828})]
                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-830} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-828})])
                  (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-829}])
                    (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-830}])
                      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-831} hd])
                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-832} (lambda ()
                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-833} (lambda ()
                                                                                                                        (if (null?
                                                                                                                              bind)
                                                                                                                            (lp rest
                                                                                                                                decls
                                                                                                                                bind
                                                                                                                                (cons
                                                                                                                                  hd
                                                                                                                                  body))
                                                                                                                            (lp rest
                                                                                                                                decls
                                                                                                                                (cons
                                                                                                                                  (list
                                                                                                                                    #f
                                                                                                                                    hd)
                                                                                                                                  bind)
                                                                                                                                body)))])
                                                                          (if (stx-pair?
                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-831})
                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-834} (syntax-e
                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-831})])
                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-835} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-834})]
                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-836} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-834})])
                                                                                  (if (and (identifier?
                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-835})
                                                                                           (core-identifier=?
                                                                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-835}
                                                                                             '%\x23;declare))
                                                                                      (let ([xdecls #{csc-t dpuuv4a3mobea70icwo8nvdax-836}])
                                                                                        (lp rest
                                                                                            (stx-foldr
                                                                                              cons
                                                                                              decls
                                                                                              xdecls)
                                                                                            bind
                                                                                            body))
                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-833}))))
                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-833}))))])
                          (if (stx-pair?
                                #{csc-e dpuuv4a3mobea70icwo8nvdax-831})
                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-837} (syntax-e
                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-831})])
                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-838} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-837})]
                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-839} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-837})])
                                  (if (and (identifier?
                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-838})
                                           (core-identifier=?
                                             #{csc-h dpuuv4a3mobea70icwo8nvdax-838}
                                             '%\x23;define-values))
                                      (if (stx-pair?
                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-839})
                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-840} (syntax-e
                                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-839})])
                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-841} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-840})]
                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-842} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-840})])
                                              (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-841}])
                                                (if (stx-pair?
                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-842})
                                                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-843} (syntax-e
                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-842})])
                                                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-844} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-843})]
                                                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-845} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-843})])
                                                        (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-844}])
                                                          (if (stx-null?
                                                                #{csc-t dpuuv4a3mobea70icwo8nvdax-845})
                                                              (lp rest
                                                                  decls
                                                                  (cons
                                                                    (list
                                                                      (core-quote-bind-values
                                                                        hd-bind)
                                                                      (core-expand-expression
                                                                        expr))
                                                                    bind)
                                                                  body)
                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-832})))))
                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-832})))))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-832}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-832}))))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-832}))))))))
              (#{csc-E dpuuv4a3mobea70icwo8nvdax-824}))))))
  (core-expand-block*
    (stx-wrap-source (cons '%\x23;begin body) (stx-source stx))
    expand-special))

(define (core-expand-declare% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-846} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-847} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-846}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-846})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-848} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-846})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-849} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-848})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-850} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-848})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-850}])
                (if (stx-list? body)
                    (core-quote-syntax
                      (core-cons
                        '%\x23;declare
                        (stx-map
                          (lambda (decl)
                            (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-851} decl])
                              (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-852} (lambda ()
                                                                              (raise-syntax-error
                                                                                #f
                                                                                "Bad syntax; invalid syntax-case clause"
                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-851}))])
                                (if (stx-pair?
                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-851})
                                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-853} (syntax-e
                                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-851})])
                                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-854} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-853})]
                                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-855} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-853})])
                                        (let ([head #{csc-h dpuuv4a3mobea70icwo8nvdax-854}])
                                          (let ([args #{csc-t dpuuv4a3mobea70icwo8nvdax-855}])
                                            (if (stx-list? args)
                                                (stx-map
                                                  core-quote-syntax
                                                  decl)
                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-852}))))))
                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-852})))))
                          body))
                      (stx-source stx))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-847})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-847})))))

(define (core-expand-extern% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-856} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-857} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-856}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-856})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-858} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-856})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-859} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-858})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-860} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-858})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-860}])
                (let lp ([rest body] [r (list)])
                  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-861} rest])
                    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-862} (lambda ()
                                                                    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-863} (lambda ()
                                                                                                                    (raise-syntax-error
                                                                                                                      #f
                                                                                                                      "Bad syntax; %#extern expects list of (internal external) identifier lists"
                                                                                                                      stx))])
                                                                      (if (stx-null?
                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-861})
                                                                          (core-quote-syntax
                                                                            (core-cons
                                                                              '%\x23;extern
                                                                              (reverse
                                                                                r))
                                                                            (stx-source
                                                                              stx))
                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-863}))))])
                      (if (stx-pair?
                            #{csc-e dpuuv4a3mobea70icwo8nvdax-861})
                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-864} (syntax-e
                                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-861})])
                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-865} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-864})]
                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-866} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-864})])
                              (if (stx-pair?
                                    #{csc-h dpuuv4a3mobea70icwo8nvdax-865})
                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-867} (syntax-e
                                                                                  #{csc-h dpuuv4a3mobea70icwo8nvdax-865})])
                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-868} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-867})]
                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-869} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-867})])
                                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-868}])
                                        (if (stx-pair?
                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-869})
                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-870} (syntax-e
                                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-869})])
                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-871} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-870})]
                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-872} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-870})])
                                                (let ([eid #{csc-h dpuuv4a3mobea70icwo8nvdax-871}])
                                                  (if (stx-null?
                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-872})
                                                      (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-866}])
                                                        (if (and (identifier?
                                                                   id)
                                                                 (identifier?
                                                                   eid))
                                                            (let ([eid (stx-e
                                                                         eid)])
                                                              (core-bind-extern!
                                                                id
                                                                eid)
                                                              (lp rest
                                                                  (cons
                                                                    (list
                                                                      (core-quote-syntax
                                                                        id)
                                                                      eid)
                                                                    r)))
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-862})))
                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-862})))))
                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-862})))))
                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-862}))))
                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-862}))))))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-857})))))

(define (core-expand-define-values% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-873} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-874} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-873}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-873})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-875} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-873})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-876} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-875})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-877} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-875})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-877})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-878} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-877})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-879} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-878})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-880} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-878})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-879}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-880})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-881} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-880})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-882} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-881})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-883} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-881})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-882}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-883})
                                      (if (core-bind-values? hd)
                                          (begin
                                            (core-bind-values! hd)
                                            (core-quote-syntax
                                              (list
                                                (core-quote-syntax
                                                  '%\x23;define-values)
                                                (core-quote-bind-values hd)
                                                (core-expand-expression
                                                  expr))
                                              (stx-source stx)))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-874}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-874})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-874})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-874}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-874})))))

(define (core-expand-define-runtime% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-884} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-885} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-884}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-884})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-886} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-884})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-887} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-886})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-888} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-886})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-888})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-889} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-888})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-890} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-889})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-891} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-889})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-890}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-891})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-892} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-891})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-893} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-892})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-894} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-892})])
                                (let ([binding-id #{csc-h dpuuv4a3mobea70icwo8nvdax-893}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-894})
                                      (if (and (identifier? id)
                                               (identifier? binding-id))
                                          (let ([eid (stx-e binding-id)])
                                            (core-bind-runtime-reference!
                                              id
                                              eid)
                                            (core-quote-syntax
                                              (list
                                                (core-quote-syntax
                                                  '%\x23;define-runtime)
                                                (core-quote-syntax id)
                                                eid)))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-885}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-885})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-885})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-885}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-885})))))

(define (core-expand-define-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-895} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-896} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-895}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-895})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-897} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-895})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-898} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-897})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-899} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-897})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-899})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-900} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-899})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-901} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-900})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-902} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-900})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-901}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-902})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-903} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-902})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-904} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-903})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-905} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-903})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-904}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-905})
                                      (if (identifier? id)
                                          (let-values ([(e-stx e)
                                                        (core-expand-expression+1
                                                          expr)])
                                            (core-bind-syntax! id e)
                                            (core-quote-syntax
                                              (list
                                                (core-quote-syntax
                                                  '%\x23;define-syntax)
                                                (core-quote-syntax id)
                                                e-stx)
                                              (stx-source stx)))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-896}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-896})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-896})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-896}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-896})))))

(define (core-expand-define-alias% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-906} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-907} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-906}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-906})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-908} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-906})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-909} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-908})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-910} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-908})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-910})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-911} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-910})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-912} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-911})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-913} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-911})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-912}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-913})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-914} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-913})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-915} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-914})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-916} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-914})])
                                (let ([alias-id #{csc-h dpuuv4a3mobea70icwo8nvdax-915}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-916})
                                      (if (and (identifier? id)
                                               (identifier? alias-id))
                                          (let ([alias-id (core-quote-syntax
                                                            alias-id)])
                                            (core-bind-alias! id alias-id)
                                            (core-quote-syntax
                                              (list
                                                (core-quote-syntax
                                                  '%\x23;define-alias)
                                                (core-quote-syntax id)
                                                alias-id)))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-907}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-907})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-907})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-907}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-907})))))

(define core-expand-lambda%
  (case-lambda
    [(stx)
     (let* ([wrap? #t])
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-917} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-918} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-917}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-917})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-919} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-917})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-920} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-919})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-921} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-919})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-921})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-922} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-921})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-923} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-922})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-924} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-922})])
                           (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-923}])
                             (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-924}])
                               (if (core-bind-values? hd)
                                   (parameterize ([current-expander-context
                                                   (make-local-context)])
                                     (core-bind-values! hd)
                                     (let ([body (list
                                                   (core-quote-bind-values
                                                     hd)
                                                   (core-expand-local-block
                                                     stx
                                                     body))])
                                       (if wrap?
                                           (core-quote-syntax
                                             (core-cons '%\x23;lambda body)
                                             (stx-source stx))
                                           body)))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-918}))))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-918}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-918})))))]
    [(stx wrap?)
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-917} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-918} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; invalid syntax-case clause"
                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-917}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-917})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-919} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-917})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-920} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-919})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-921} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-919})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-921})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-922} (syntax-e
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-921})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-923} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-922})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-924} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-922})])
                         (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-923}])
                           (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-924}])
                             (if (core-bind-values? hd)
                                 (parameterize ([current-expander-context
                                                 (make-local-context)])
                                   (core-bind-values! hd)
                                   (let ([body (list
                                                 (core-quote-bind-values
                                                   hd)
                                                 (core-expand-local-block
                                                   stx
                                                   body))])
                                     (if wrap?
                                         (core-quote-syntax
                                           (core-cons '%\x23;lambda body)
                                           (stx-source stx))
                                         body)))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-918}))))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-918}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-918}))))]))

(define (core-expand-case-lambda% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-925} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-926} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-925}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-925})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-927} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-925})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-928} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-927})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-929} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-927})])
              (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-929}])
                (if (stx-list? clauses)
                    (core-quote-syntax
                      (core-cons
                        '%\x23;case-lambda
                        (stx-map
                          (lambda (clause)
                            (core-expand-lambda%
                              (stx-wrap-source
                                (cons '%\x23;case-lambda-clause clause)
                                (or (stx-source clause) (stx-source stx)))
                              #f))
                          clauses))
                      (stx-source stx))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-926})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-926})))))

(define (core-expand-let-values% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-930} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-931} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-930}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-930})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-932} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-930})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-933} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-932})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-934} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-932})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-934})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-935} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-934})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-936} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-935})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-937} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-935})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-936}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-937}])
                          (if (core-expand-let-bind? hd)
                              (let ([expressions (stx-map
                                                   core-expand-let-bind-expression
                                                   hd)])
                                (parameterize ([current-expander-context
                                                (make-local-context)])
                                  (stx-for-each
                                    core-expand-let-bind-values!
                                    hd)
                                  (core-quote-syntax
                                    (list
                                      (core-quote-syntax '%\x23;let-values)
                                      (stx-map
                                        core-expand-let-bind-quote
                                        hd
                                        expressions)
                                      (core-expand-local-block stx body))
                                    (stx-source stx))))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-931}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-931}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-931})))))

(define core-expand-letrec-values%
  (case-lambda
    [(stx)
     (let* ([form '%\x23;letrec-values])
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-938} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-939} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-938}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-938})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-940} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-938})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-941} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-940})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-942} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-940})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-942})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-943} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-942})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-944} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-943})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-945} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-943})])
                           (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-944}])
                             (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-945}])
                               (if (core-expand-let-bind? hd)
                                   (parameterize ([current-expander-context
                                                   (make-local-context)])
                                     (stx-for-each
                                       core-expand-let-bind-values!
                                       hd)
                                     (core-quote-syntax
                                       (list
                                         (core-quote-syntax form)
                                         (stx-map
                                           core-expand-let-bind-quote
                                           hd
                                           (stx-map
                                             core-expand-let-bind-expression
                                             hd))
                                         (core-expand-local-block
                                           stx
                                           body))
                                       (stx-source stx)))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-939}))))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-939}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-939})))))]
    [(stx form)
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-938} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-939} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; invalid syntax-case clause"
                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-938}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-938})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-940} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-938})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-941} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-940})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-942} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-940})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-942})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-943} (syntax-e
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-942})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-944} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-943})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-945} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-943})])
                         (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-944}])
                           (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-945}])
                             (if (core-expand-let-bind? hd)
                                 (parameterize ([current-expander-context
                                                 (make-local-context)])
                                   (stx-for-each
                                     core-expand-let-bind-values!
                                     hd)
                                   (core-quote-syntax
                                     (list
                                       (core-quote-syntax form)
                                       (stx-map
                                         core-expand-let-bind-quote
                                         hd
                                         (stx-map
                                           core-expand-let-bind-expression
                                           hd))
                                       (core-expand-local-block stx body))
                                     (stx-source stx)))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-939}))))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-939}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-939}))))]))

(define (core-expand-letrec*-values% stx)
  (core-expand-letrec-values% stx '%\x23;letrec*-values))

(define (core-expand-let-bind? stx)
  (and (stx-list? stx)
       (stx-andmap
         (lambda (bind)
           (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-946} bind])
             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-947} (lambda ()
                                                             #f)])
               (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-946})
                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-948} (syntax-e
                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-946})])
                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-949} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-948})]
                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-950} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-948})])
                       (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-949}])
                         (if (stx-pair?
                               #{csc-t dpuuv4a3mobea70icwo8nvdax-950})
                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-951} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-950})])
                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-952} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-951})]
                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-953} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-951})])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-953})
                                     (core-bind-values? hd)
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-947}))))
                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-947})))))
                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-947})))))
         stx)))

(define (core-expand-let-bind-expression bind)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-954} bind])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-955} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-954}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-954})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-956} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-954})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-957} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-956})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-958} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-956})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-958})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-959} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-958})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-960} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-959})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-961} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-959})])
                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-960}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-961})
                            (core-expand-expression expr)
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-955})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-955}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-955})))))

(define (core-expand-let-bind-values! bind)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-962} bind])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-963} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-962}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-962})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-964} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-962})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-965} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-964})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-966} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-964})])
              (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-965}])
                (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-966})
                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-967} (syntax-e
                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-966})])
                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-968} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-967})]
                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-969} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-967})])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-969})
                            (core-bind-values! hd)
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-963}))))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-963})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-963})))))

(define (core-expand-let-bind-quote bind expr)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-970} bind])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-971} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-970}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-970})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-972} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-970})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-973} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-972})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-974} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-972})])
              (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-973}])
                (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-974})
                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-975} (syntax-e
                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-974})])
                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-976} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-975})]
                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-977} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-975})])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-977})
                            (list (core-quote-bind-values hd) expr)
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-971}))))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-971})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-971})))))

(define (core-expand-let-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-978} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-979} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-978}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-978})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-980} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-978})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-981} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-980})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-982} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-980})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-982})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-983} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-982})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-984} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-983})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-985} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-983})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-984}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-985}])
                          (if (core-expand-let-bind-syntax? hd)
                              (let ([expanders (stx-map
                                                 core-expand-let-bind-syntax-expression
                                                 hd)])
                                (parameterize ([current-expander-context
                                                (make-local-context)])
                                  (stx-for-each
                                    core-expand-let-bind-syntax!
                                    hd
                                    expanders)
                                  (core-expand-local-block stx body)))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-979}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-979}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-979})))))

(define (core-expand-letrec-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-986} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-987} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-986}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-986})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-988} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-986})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-989} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-988})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-990} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-988})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-990})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-991} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-990})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-992} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-991})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-993} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-991})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-992}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-993}])
                          (if (core-expand-let-bind-syntax? hd)
                              (parameterize ([current-expander-context
                                              (make-local-context)])
                                (stx-for-each
                                  core-expand-let-bind-syntax!
                                  hd
                                  (make-list (stx-length hd) (%%void)))
                                (stx-for-each
                                  (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-994}
                                           #{cut-arg dpuuv4a3mobea70icwo8nvdax-995})
                                    (core-expand-let-bind-syntax!
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-994}
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-995}
                                      #t))
                                  hd
                                  (stx-map
                                    core-expand-let-bind-syntax-expression
                                    hd))
                                (core-expand-local-block stx body))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-987}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-987}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-987})))))

(define (core-expand-let-bind-syntax? stx)
  (and (stx-list? stx)
       (stx-andmap
         (lambda (bind)
           (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-996} bind])
             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-997} (lambda ()
                                                             #f)])
               (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-996})
                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-998} (syntax-e
                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-996})])
                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-999} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-998})]
                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1000} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-998})])
                       (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-999}])
                         (if (stx-pair?
                               #{csc-t dpuuv4a3mobea70icwo8nvdax-1000})
                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1001} (syntax-e
                                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1000})])
                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1002} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1001})]
                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1003} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1001})])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1003})
                                     (identifier? hd)
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-997}))))
                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-997})))))
                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-997})))))
         stx)))

(define (core-expand-let-bind-syntax-expression bind)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1004} bind])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1005} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1004}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1004})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1006} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1004})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1007} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1006})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1008} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1006})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1008})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1009} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1008})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1010} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1009})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1011} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1009})])
                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1010}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1011})
                            (let-values ([(_ e)
                                          (core-expand-expression+1 expr)])
                              e)
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1005})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1005}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1005})))))

(define core-expand-let-bind-syntax!
  (case-lambda
    [(bind e)
     (let* ([rebind? #f])
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1012} bind])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1013} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; invalid syntax-case clause"
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1012}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1012})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1014} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1012})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1015} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1014})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1016} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1014})])
                   (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1015}])
                     (if (stx-pair?
                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1016})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1017} (syntax-e
                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1016})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1018} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1017})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-1019} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1017})])
                             (if (stx-null?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1019})
                                 (core-bind-syntax! id e rebind?)
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013}))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013})))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013})))))]
    [(bind e rebind?)
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1012} bind])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1013} (lambda ()
                                                        (raise-syntax-error
                                                          #f
                                                          "Bad syntax; invalid syntax-case clause"
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-1012}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1012})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1014} (syntax-e
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1012})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1015} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1014})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1016} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1014})])
                 (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1015}])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1016})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1017} (syntax-e
                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1016})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1018} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1017})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-1019} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1017})])
                           (if (stx-null?
                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1019})
                               (core-bind-syntax! id e rebind?)
                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013}))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013})))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1013}))))]))

(define (core-expand-expression% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1020} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1021} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1020}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1020})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1022} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1020})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1023} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1022})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1024} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1022})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1024})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1025} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1024})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1026} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1025})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1027} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1025})])
                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1026}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1027})
                            (core-expand-expression expr)
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1021})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1021}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1021})))))

(define (core-expand-quote% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1028} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1029} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1028}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1028})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1030} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1028})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1031} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1030})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1032} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1030})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1032})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1033} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1032})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1034} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1033})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1035} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1033})])
                      (let ([e #{csc-h dpuuv4a3mobea70icwo8nvdax-1034}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1035})
                            (core-quote-syntax
                              (list
                                (core-quote-syntax '%\x23;quote)
                                (syntax->datum e))
                              (stx-source stx))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1029})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1029}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1029})))))

(define (core-expand-quote-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1036} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1037} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1036}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1036})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1038} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1036})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1039} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1038})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1040} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1038})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1040})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1041} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1040})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1042} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1041})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1043} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1041})])
                      (let ([e #{csc-h dpuuv4a3mobea70icwo8nvdax-1042}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1043})
                            (core-quote-syntax
                              (list
                                (core-quote-syntax '%\x23;quote-syntax)
                                (core-quote-syntax e))
                              (stx-source stx))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1037})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1037}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1037})))))

(define (core-expand-call% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1044} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1045} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1044}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1044})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1046} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1044})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1047} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1046})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1048} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1046})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1048})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1049} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1048})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1050} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1049})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1051} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1049})])
                      (let ([rator #{csc-h dpuuv4a3mobea70icwo8nvdax-1050}])
                        (let ([args #{csc-t dpuuv4a3mobea70icwo8nvdax-1051}])
                          (if (stx-list? args)
                              (core-quote-syntax
                                (core-cons*
                                  '%\x23;call
                                  (core-expand-expression rator)
                                  (stx-map core-expand-expression args))
                                (stx-source stx))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1045}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1045}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1045})))))

(define (core-expand-if% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1052} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1053} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1052}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1052})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1054} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1052})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1055} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1054})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1056} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1054})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1056})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1057} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1056})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1058} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1057})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1059} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1057})])
                      (let ([test #{csc-h dpuuv4a3mobea70icwo8nvdax-1058}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1059})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1060} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1059})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1061} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1060})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1062} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1060})])
                                (let ([K #{csc-h dpuuv4a3mobea70icwo8nvdax-1061}])
                                  (if (stx-pair?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1062})
                                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1063} (syntax-e
                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1062})])
                                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1064} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1063})]
                                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-1065} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1063})])
                                          (let ([E #{csc-h dpuuv4a3mobea70icwo8nvdax-1064}])
                                            (if (stx-null?
                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1065})
                                                (core-quote-syntax
                                                  (list
                                                    (core-quote-syntax
                                                      '%\x23;if)
                                                    (core-expand-expression
                                                      test)
                                                    (core-expand-expression
                                                      K)
                                                    (core-expand-expression
                                                      E))
                                                  (stx-source stx))
                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1053})))))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1053})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1053})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1053}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1053})))))

(define (core-expand-ref% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1066} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1067} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1066}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1066})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1068} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1066})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1069} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1068})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1070} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1068})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1070})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1071} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1070})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1072} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1071})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1073} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1071})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1072}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1073})
                            (if (identifier? id)
                                (core-quote-syntax
                                  (list
                                    (core-quote-syntax '%\x23;ref)
                                    (core-quote-runtime-ref id stx))
                                  (stx-source stx))
                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1067}))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1067})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1067}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1067})))))

(define (core-expand-setq% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1074} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1075} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1074}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1074})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1076} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1074})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1077} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1076})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1078} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1076})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1078})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1079} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1078})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1080} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1079})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1081} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1079})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1080}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1081})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1082} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1081})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1083} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1082})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1084} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1082})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1083}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1084})
                                      (if (identifier? id)
                                          (core-quote-syntax
                                            (list
                                              (core-quote-syntax
                                                '%\x23;set!)
                                              (core-quote-runtime-ref
                                                id
                                                stx)
                                              (core-expand-expression
                                                expr))
                                            (stx-source stx))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1075}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1075})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1075})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1075}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1075})))))

(define (macro-expand-extern stx)
  (define (generate body)
    (let lp ([rest body] [ns (core-context-namespace)] [r '()])
      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1085} rest])
        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1086} (lambda ()
                                                         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1087} (lambda ()
                                                                                                          (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1088} (lambda ()
                                                                                                                                                           (raise-syntax-error
                                                                                                                                                             #f
                                                                                                                                                             "Bad syntax; invalid syntax-case clause"
                                                                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1085}))])
                                                                                                            (if (stx-null?
                                                                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1085})
                                                                                                                (reverse
                                                                                                                  r)
                                                                                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1088}))))])
                                                           (if (stx-pair?
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-1085})
                                                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1089} (syntax-e
                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1085})])
                                                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1090} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1089})]
                                                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1091} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1089})])
                                                                   (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1090}])
                                                                     (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1091}])
                                                                       (if (identifier?
                                                                             hd)
                                                                           (lp rest
                                                                               ns
                                                                               (cons
                                                                                 (list
                                                                                   hd
                                                                                   (if ns
                                                                                       (stx-identifier
                                                                                         hd
                                                                                         ns
                                                                                         "#"
                                                                                         hd)
                                                                                       hd))
                                                                                 r))
                                                                           (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1092} hd])
                                                                             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1093} (lambda ()
                                                                                                                              (raise-syntax-error
                                                                                                                                #f
                                                                                                                                "Bad syntax; invalid syntax-case clause"
                                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1092}))])
                                                                               (if (stx-pair?
                                                                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-1092})
                                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1094} (syntax-e
                                                                                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-1092})])
                                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1095} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1094})]
                                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1096} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1094})])
                                                                                       (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1095}])
                                                                                         (if (stx-pair?
                                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-1096})
                                                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1097} (syntax-e
                                                                                                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1096})])
                                                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1098} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1097})]
                                                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1099} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1097})])
                                                                                                 (let ([eid #{csc-h dpuuv4a3mobea70icwo8nvdax-1098}])
                                                                                                   (if (stx-null?
                                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1099})
                                                                                                       (if (and (identifier?
                                                                                                                  id)
                                                                                                                (identifier?
                                                                                                                  eid))
                                                                                                           (lp rest
                                                                                                               ns
                                                                                                               (cons
                                                                                                                 (list
                                                                                                                   id
                                                                                                                   eid)
                                                                                                                 r))
                                                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1093}))
                                                                                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1093})))))
                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1093})))))
                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1093})))))))))
                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1087}))))])
          (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1085})
              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1100} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1085})])
                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1101} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1100})]
                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1102} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1100})])
                  (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1103} (stx-e
                                                                    #{csc-h dpuuv4a3mobea70icwo8nvdax-1101})])
                    (if (and (keyword?
                               #{csc-kv dpuuv4a3mobea70icwo8nvdax-1103})
                             (string=?
                               (keyword->string
                                 #{csc-kv dpuuv4a3mobea70icwo8nvdax-1103})
                               "namespace"))
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1102})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1104} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1102})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1105} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1104})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1106} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1104})])
                                (let ([ns #{csc-h dpuuv4a3mobea70icwo8nvdax-1105}])
                                  (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1106}])
                                    (let ([ns (cond
                                                [(identifier? ns)
                                                 (symbol->string
                                                   (stx-e ns))]
                                                [(or (stx-string? ns)
                                                     (stx-false? ns))
                                                 (stx-e ns)]
                                                [else
                                                 (raise-syntax-error
                                                   #f
                                                   "Bad syntax; extern expects namespace identifier"
                                                   stx
                                                   ns)])])
                                      (lp rest ns r))))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1086}))
                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1086})))))
              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1086}))))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1107} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1108} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1107}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1107})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1109} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1107})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1110} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1109})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1111} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1109})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1111}])
                (if (stx-list? body)
                    (core-cons '%\x23;extern (generate body))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1108})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1108})))))

(define (macro-expand-define-values stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1112} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1113} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1112}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1112})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1114} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1112})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1115} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1114})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1116} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1114})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1116})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1117} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1116})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1118} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1117})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1119} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1117})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1118}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1119})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1120} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1119})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1121} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1120})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1122} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1120})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1121}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1122})
                                      (if (stx-andmap identifier? hd)
                                          (list
                                            (core-quote-syntax
                                              '%\x23;define-values)
                                            (stx-map identity hd)
                                            expr)
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1113}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1113})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1113})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1113}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1113})))))

(define (macro-expand-define-syntax stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1123} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1124} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1123}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1123})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1125} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1123})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1126} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1125})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1127} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1125})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1127})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1128} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1127})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1129} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1128})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1130} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1128})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1129}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1130})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1131} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1130})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1132} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1131})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1133} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1131})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1132}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1133})
                                      (if (identifier? hd)
                                          (list
                                            (core-quote-syntax
                                              '%\x23;define-syntax)
                                            hd
                                            expr)
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1124}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1124})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1124})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1124}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1124})))))

(define (macro-expand-define-alias stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1134} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1135} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1134}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1134})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1136} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1134})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1137} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1136})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1138} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1136})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1138})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1139} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1138})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1140} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1139})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1141} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1139})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1140}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1141})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1142} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1141})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1143} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1142})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1144} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1142})])
                                (let ([alias-id #{csc-h dpuuv4a3mobea70icwo8nvdax-1143}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1144})
                                      (if (and (identifier? id)
                                               (identifier? alias-id))
                                          (list
                                            (core-quote-syntax
                                              '%\x23;define-alias)
                                            id
                                            alias-id)
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1135}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1135})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1135})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1135}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1135})))))

(define (macro-expand-lambda% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1145} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1146} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1145}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1145})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1147} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1145})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1148} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1147})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1149} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1147})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1149})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1150} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1149})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1151} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1150})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1152} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1150})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1151}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1152}])
                          (if (and (stx-andmap identifier? hd)
                                   (stx-list? body)
                                   (not (stx-null? body)))
                              (core-cons*
                                '%\x23;lambda
                                (stx-map identity hd)
                                body)
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1146}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1146}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1146})))))

(define (macro-expand-case-lambda stx)
  (define (generate clause)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1153} clause])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1154} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; malformed clause"
                                                         stx
                                                         clause))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1153})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1155} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1153})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1156} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1155})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1157} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1155})])
                (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1156}])
                  (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1157}])
                    (if (and (stx-andmap identifier? hd)
                             (stx-list? body)
                             (not (stx-null? body)))
                        (stx-wrap-source
                          (cons (stx-map identity hd) body)
                          (stx-source clause))
                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1154}))))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1154})))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1158} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1159} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1158}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1158})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1160} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1158})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1161} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1160})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1162} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1160})])
              (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-1162}])
                (if (stx-list? clauses)
                    (core-cons
                      '%\x23;case-lambda
                      (stx-map generate clauses))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1159})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1159})))))

(define macro-expand-let-values
  (case-lambda
    [(stx)
     (let* ([form '%\x23;let-values])
       (define (generate bind)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1163} bind])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1164} (lambda ()
                                                            (raise-syntax-error
                                                              #f
                                                              "Bad syntax; malformed binding"
                                                              stx
                                                              bind))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1163})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1165} (syntax-e
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1163})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1166} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1165})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1167} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1165})])
                     (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-1166}])
                       (if (stx-pair?
                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1167})
                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1168} (syntax-e
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1167})])
                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1169} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1168})]
                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-1170} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1168})])
                               (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1169}])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1170})
                                     (if (stx-andmap identifier? ids)
                                         (list (stx-map identity ids) expr)
                                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164}))
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1171} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1172} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; invalid syntax-case clause"
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1171}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1171})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1173} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1171})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1174} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1173})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1175} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1173})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1175})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1176} (syntax-e
                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1175})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1177} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1176})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-1178} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1176})])
                           (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1177}])
                             (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1178}])
                               (if (and (stx-list? hd)
                                        (stx-list? body)
                                        (not (stx-null? body)))
                                   (core-cons*
                                     form
                                     (stx-map generate hd)
                                     body)
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172}))))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172})))))]
    [(stx form)
     (define (generate bind)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1163} bind])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1164} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; malformed binding"
                                                            stx
                                                            bind))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1163})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1165} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1163})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1166} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1165})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1167} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1165})])
                   (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-1166}])
                     (if (stx-pair?
                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1167})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1168} (syntax-e
                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1167})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1169} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1168})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-1170} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1168})])
                             (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1169}])
                               (if (stx-null?
                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1170})
                                   (if (stx-andmap identifier? ids)
                                       (list (stx-map identity ids) expr)
                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164}))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1164})))))
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1171} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1172} (lambda ()
                                                        (raise-syntax-error
                                                          #f
                                                          "Bad syntax; invalid syntax-case clause"
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-1171}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1171})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1173} (syntax-e
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1171})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1174} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1173})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1175} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1173})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1175})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1176} (syntax-e
                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1175})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1177} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1176})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-1178} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1176})])
                         (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1177}])
                           (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1178}])
                             (if (and (stx-list? hd)
                                      (stx-list? body)
                                      (not (stx-null? body)))
                                 (core-cons*
                                   form
                                   (stx-map generate hd)
                                   body)
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172}))))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1172}))))]))

(define (macro-expand-letrec-values stx)
  (macro-expand-let-values stx '%\x23;letrec-values))

(define (macro-expand-letrec*-values stx)
  (macro-expand-let-values stx '%\x23;letrec*-values))

(define (macro-expand-if stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1179} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1180} (lambda ()
                                                     (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1181} (lambda ()
                                                                                                      (raise-syntax-error
                                                                                                        #f
                                                                                                        "Bad syntax; invalid syntax-case clause"
                                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-1179}))])
                                                       (if (stx-pair?
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1179})
                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1182} (syntax-e
                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1179})])
                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1183} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1182})]
                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-1184} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1182})])
                                                               (if (stx-pair?
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1184})
                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1185} (syntax-e
                                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1184})])
                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1186} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1185})]
                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1187} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1185})])
                                                                       (let ([test #{csc-h dpuuv4a3mobea70icwo8nvdax-1186}])
                                                                         (if (stx-pair?
                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-1187})
                                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1188} (syntax-e
                                                                                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1187})])
                                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1189} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1188})]
                                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1190} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1188})])
                                                                                 (let ([K #{csc-h dpuuv4a3mobea70icwo8nvdax-1189}])
                                                                                   (if (stx-pair?
                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1190})
                                                                                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1191} (syntax-e
                                                                                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1190})])
                                                                                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1192} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1191})]
                                                                                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-1193} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1191})])
                                                                                           (let ([E #{csc-h dpuuv4a3mobea70icwo8nvdax-1192}])
                                                                                             (if (stx-null?
                                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1193})
                                                                                                 (core-list
                                                                                                   '%\x23;if
                                                                                                   test
                                                                                                   K
                                                                                                   E)
                                                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1181})))))
                                                                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1181})))))
                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1181})))))
                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1181}))))
                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1181}))))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1179})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1194} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1179})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1195} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1194})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1196} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1194})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1196})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1197} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1196})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1198} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1197})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1199} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1197})])
                      (let ([test #{csc-h dpuuv4a3mobea70icwo8nvdax-1198}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1199})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1200} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1199})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1201} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1200})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1202} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1200})])
                                (let ([K #{csc-h dpuuv4a3mobea70icwo8nvdax-1201}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1202})
                                      (core-list '%\x23;if test K (%%void))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1180})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1180})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1180}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1180})))))

(define (free-identifier=? xid yid)
  (let ([xe (resolve-identifier xid)]
        [ye (resolve-identifier yid)])
    (cond
      [(and xe ye)
       (or (eq? xe ye)
           (and (binding? xe)
                (binding? ye)
                (eq? (&binding-id xe) (&binding-id ye))))]
      [(or xe ye) #f]
      [else (stx-eq? xid yid)])))

(define (bound-identifier=? xid yid)
  (define (context e)
    (if (syntax-quote? e)
        (&syntax-quote-context e)
        (current-expander-context)))
  (define (marks e)
    (cond
      [(symbol? e) (list)]
      [(identifier-wrap? e) (&identifier-wrap-marks e)]
      [else (&syntax-quote-marks e)]))
  (define (unwrap e)
    (if (symbol? e) e (syntax-local-unwrap e)))
  (let ([x (unwrap xid)] [y (unwrap yid)])
    (and (stx-eq? x y)
         (eq? (context x) (context y))
         (equal? (marks x) (marks y)))))

(define (underscore? stx)
  (and (identifier? stx) (core-identifier=? stx '_)))

(define (ellipsis? stx)
  (and (identifier? stx) (core-identifier=? stx '...)))

(define check-duplicate-identifiers
  (case-lambda
    [(stx)
     (let* ([where stx])
       (let lp ([rest (syntax->list stx)])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1203} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1203})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1204} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1203})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-1205} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1203})])
                 (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1204}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1205}])
                     (begin
                       (cond
                         [(not (identifier? hd))
                          (raise-syntax-error
                            #f
                            "Bad identifier"
                            where
                            hd)]
                         [(find
                            (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1206})
                              (bound-identifier=?
                                #{cut-arg dpuuv4a3mobea70icwo8nvdax-1206}
                                hd))
                            rest)
                          (raise-syntax-error
                            #f
                            "Duplicate identifier"
                            where
                            hd)]
                         [else (lp rest)])))))
               (begin #t)))))]
    [(stx where)
     (let lp ([rest (syntax->list stx)])
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1203} rest])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1203})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1204} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1203})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-1205} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1203})])
               (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1204}])
                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1205}])
                   (begin
                     (cond
                       [(not (identifier? hd))
                        (raise-syntax-error #f "Bad identifier" where hd)]
                       [(find
                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1206})
                            (bound-identifier=?
                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-1206}
                              hd))
                          rest)
                        (raise-syntax-error
                          #f
                          "Duplicate identifier"
                          where
                          hd)]
                       [else (lp rest)])))))
             (begin #t))))]))

(define (core-bind-values? stx)
  (stx-andmap
    (lambda (x) (or (identifier? x) (stx-false? x)))
    stx))

(define core-bind-values!
  (case-lambda
    [(stx)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (stx-for-each
         (lambda (id)
           (when (identifier? id)
             (core-bind-runtime! id rebind? phi ctx)))
         stx))]
    [(stx rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (stx-for-each
         (lambda (id)
           (when (identifier? id)
             (core-bind-runtime! id rebind? phi ctx)))
         stx))]
    [(stx rebind? phi)
     (let* ([ctx (current-expander-context)])
       (stx-for-each
         (lambda (id)
           (when (identifier? id)
             (core-bind-runtime! id rebind? phi ctx)))
         stx))]
    [(stx rebind? phi ctx)
     (stx-for-each
       (lambda (id)
         (when (identifier? id)
           (core-bind-runtime! id rebind? phi ctx)))
       stx)]))

(define (core-quote-bind-values stx)
  (stx-map
    (lambda (x) (and (identifier? x) (core-quote-syntax x)))
    stx))

(define (core-runtime-ref? stx)
  (and (identifier? stx)
       (let ([bind (resolve-identifier stx)])
         (or (not bind) (runtime-binding? bind)))))

(define (core-quote-runtime-ref id form)
  (let ([bind (resolve-identifier id)])
    (cond
      [(runtime-binding? bind) (core-quote-syntax id)]
      [(not bind)
       (if (or (core-context-rebind? (core-context-top))
               (core-extern-symbol? (stx-e id)))
           (core-quote-syntax id)
           (raise-syntax-error
             #f
             "Reference to unbound identifier"
             form
             id))]
      [else
       (raise-syntax-error
         #f
         "Bad syntax; not a runtime binding"
         form
         id)])))

(define core-bind-runtime!
  (case-lambda
    [(id)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([eid (make-binding-id key #f phi ctx)])
           (let* ([bind (cond
                          [(module-context? ctx)
                           (make-module-binding eid key phi ctx)]
                          [(top-context? ctx)
                           (make-top-binding eid key phi)]
                          [(local-context? ctx)
                           (make-local-binding eid key phi)]
                          [else (make-runtime-binding eid key phi)])])
             (bind-identifier! id bind rebind? phi ctx)))))]
    [(id rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([eid (make-binding-id key #f phi ctx)])
           (let* ([bind (cond
                          [(module-context? ctx)
                           (make-module-binding eid key phi ctx)]
                          [(top-context? ctx)
                           (make-top-binding eid key phi)]
                          [(local-context? ctx)
                           (make-local-binding eid key phi)]
                          [else (make-runtime-binding eid key phi)])])
             (bind-identifier! id bind rebind? phi ctx)))))]
    [(id rebind? phi)
     (let* ([ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([eid (make-binding-id key #f phi ctx)])
           (let* ([bind (cond
                          [(module-context? ctx)
                           (make-module-binding eid key phi ctx)]
                          [(top-context? ctx)
                           (make-top-binding eid key phi)]
                          [(local-context? ctx)
                           (make-local-binding eid key phi)]
                          [else (make-runtime-binding eid key phi)])])
             (bind-identifier! id bind rebind? phi ctx)))))]
    [(id rebind? phi ctx)
     (let* ([key (core-identifier-key id)])
       (let* ([eid (make-binding-id key #f phi ctx)])
         (let* ([bind (cond
                        [(module-context? ctx)
                         (make-module-binding eid key phi ctx)]
                        [(top-context? ctx) (make-top-binding eid key phi)]
                        [(local-context? ctx)
                         (make-local-binding eid key phi)]
                        [else (make-runtime-binding eid key phi)])])
           (bind-identifier! id bind rebind? phi ctx))))]))

(define core-bind-runtime-reference!
  (case-lambda
    [(id eid)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([bind (cond
                        [(module-context? ctx)
                         (make-module-binding eid key phi ctx)]
                        [(top-context? ctx) (make-top-binding eid key phi)]
                        [else (make-runtime-binding eid key phi)])])
           (bind-identifier! id bind rebind? phi ctx))))]
    [(id eid rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([bind (cond
                        [(module-context? ctx)
                         (make-module-binding eid key phi ctx)]
                        [(top-context? ctx) (make-top-binding eid key phi)]
                        [else (make-runtime-binding eid key phi)])])
           (bind-identifier! id bind rebind? phi ctx))))]
    [(id eid rebind? phi)
     (let* ([ctx (current-expander-context)])
       (let* ([key (core-identifier-key id)])
         (let* ([bind (cond
                        [(module-context? ctx)
                         (make-module-binding eid key phi ctx)]
                        [(top-context? ctx) (make-top-binding eid key phi)]
                        [else (make-runtime-binding eid key phi)])])
           (bind-identifier! id bind rebind? phi ctx))))]
    [(id eid rebind? phi ctx)
     (let* ([key (core-identifier-key id)])
       (let* ([bind (cond
                      [(module-context? ctx)
                       (make-module-binding eid key phi ctx)]
                      [(top-context? ctx) (make-top-binding eid key phi)]
                      [else (make-runtime-binding eid key phi)])])
         (bind-identifier! id bind rebind? phi ctx)))]))

(define core-bind-extern!
  (case-lambda
    [(id eid)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (make-extern-binding eid (core-identifier-key id) phi)
         rebind? phi ctx))]
    [(id eid rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (make-extern-binding eid (core-identifier-key id) phi)
         rebind? phi ctx))]
    [(id eid rebind? phi)
     (let* ([ctx (current-expander-context)])
       (bind-identifier! id
         (make-extern-binding eid (core-identifier-key id) phi)
         rebind? phi ctx))]
    [(id eid rebind? phi ctx)
     (bind-identifier! id
       (make-extern-binding eid (core-identifier-key id) phi)
       rebind? phi ctx)]))

(define core-bind-syntax!
  (case-lambda
    [(id e)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)]
               [e (if (or (expander? e) (expander-context? e))
                      e
                      (make-user-expander e ctx phi))])
           (make-syntax-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             e))
         rebind? phi ctx))]
    [(id e rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)]
               [e (if (or (expander? e) (expander-context? e))
                      e
                      (make-user-expander e ctx phi))])
           (make-syntax-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             e))
         rebind? phi ctx))]
    [(id e rebind? phi)
     (let* ([ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)]
               [e (if (or (expander? e) (expander-context? e))
                      e
                      (make-user-expander e ctx phi))])
           (make-syntax-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             e))
         rebind? phi ctx))]
    [(id e rebind? phi ctx)
     (bind-identifier! id
       (let ([key (core-identifier-key id)]
             [e (if (or (expander? e) (expander-context? e))
                    e
                    (make-user-expander e ctx phi))])
         (make-syntax-binding
           (make-binding-id key #t phi ctx)
           key
           phi
           e))
       rebind? phi ctx)]))

(define core-bind-root-syntax!
  (case-lambda
    [(id e)
     (let* ([rebind? #f])
       (core-bind-syntax! id e rebind? 0 (core-context-root)))]
    [(id e rebind?)
     (core-bind-syntax! id e rebind? 0 (core-context-root))]))

(define core-bind-alias!
  (case-lambda
    [(id alias-id)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)])
           (make-alias-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             alias-id))
         rebind? phi ctx))]
    [(id alias-id rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)])
           (make-alias-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             alias-id))
         rebind? phi ctx))]
    [(id alias-id rebind? phi)
     (let* ([ctx (current-expander-context)])
       (bind-identifier! id
         (let ([key (core-identifier-key id)])
           (make-alias-binding
             (make-binding-id key #t phi ctx)
             key
             phi
             alias-id))
         rebind? phi ctx))]
    [(id alias-id rebind? phi ctx)
     (bind-identifier! id
       (let ([key (core-identifier-key id)])
         (make-alias-binding
           (make-binding-id key #t phi ctx)
           key
           phi
           alias-id))
       rebind? phi ctx)]))

(define make-binding-id
  (case-lambda
    [(key)
     (let* ([syntax? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (cond
         [(uninterned-symbol? key) (gensym "L")]
         [(pair? key)
          (gensym
            (let ([x (car key)])
              (if (symbol? x) (symbol->string x) x)))]
         [(top-context? ctx)
          (let ([ns (core-context-namespace ctx)])
            (cond
              [(and (fxzero? phi) (not syntax?))
               (if ns (make-symbol ns "#" key) key)]
              [syntax?
               (make-symbol (or ns "") "[:" (number->string phi) ":]#"
                 key)]
              [else
               (make-symbol (or ns "") "[" (number->string phi) "]#"
                 key)]))]
         [else
          (gensym
            (let ([x key]) (if (symbol? x) (symbol->string x) x)))]))]
    [(key syntax?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (cond
         [(uninterned-symbol? key) (gensym "L")]
         [(pair? key)
          (gensym
            (let ([x (car key)])
              (if (symbol? x) (symbol->string x) x)))]
         [(top-context? ctx)
          (let ([ns (core-context-namespace ctx)])
            (cond
              [(and (fxzero? phi) (not syntax?))
               (if ns (make-symbol ns "#" key) key)]
              [syntax?
               (make-symbol (or ns "") "[:" (number->string phi) ":]#"
                 key)]
              [else
               (make-symbol (or ns "") "[" (number->string phi) "]#"
                 key)]))]
         [else
          (gensym
            (let ([x key]) (if (symbol? x) (symbol->string x) x)))]))]
    [(key syntax? phi)
     (let* ([ctx (current-expander-context)])
       (cond
         [(uninterned-symbol? key) (gensym "L")]
         [(pair? key)
          (gensym
            (let ([x (car key)])
              (if (symbol? x) (symbol->string x) x)))]
         [(top-context? ctx)
          (let ([ns (core-context-namespace ctx)])
            (cond
              [(and (fxzero? phi) (not syntax?))
               (if ns (make-symbol ns "#" key) key)]
              [syntax?
               (make-symbol (or ns "") "[:" (number->string phi) ":]#"
                 key)]
              [else
               (make-symbol (or ns "") "[" (number->string phi) "]#"
                 key)]))]
         [else
          (gensym
            (let ([x key]) (if (symbol? x) (symbol->string x) x)))]))]
    [(key syntax? phi ctx)
     (cond
       [(uninterned-symbol? key) (gensym "L")]
       [(pair? key)
        (gensym
          (let ([x (car key)])
            (if (symbol? x) (symbol->string x) x)))]
       [(top-context? ctx)
        (let ([ns (core-context-namespace ctx)])
          (cond
            [(and (fxzero? phi) (not syntax?))
             (if ns (make-symbol ns "#" key) key)]
            [syntax?
             (make-symbol (or ns "") "[:" (number->string phi) ":]#"
               key)]
            [else
             (make-symbol (or ns "") "[" (number->string phi) "]#"
               key)]))]
       [else
        (gensym
          (let ([x key]) (if (symbol? x) (symbol->string x) x)))])]))

