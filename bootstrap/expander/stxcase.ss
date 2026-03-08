(begin
  (define syntax-pattern::t
    (make-class-type 'gerbil\x23;syntax-pattern::t 'syntax-pattern
      (list expander::t) '(id depth) '((struct: . #t)) '#f))
  (define (make-syntax-pattern . args)
    (let* ([type syntax-pattern::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (syntax-pattern? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;syntax-pattern::t))
  (define (syntax-pattern-id obj)
    (unchecked-slot-ref obj 'id))
  (define (syntax-pattern-depth obj)
    (unchecked-slot-ref obj 'depth))
  (define (syntax-pattern-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (syntax-pattern-depth-set! obj val)
    (unchecked-slot-set! obj 'depth val))
  (define (&syntax-pattern-id obj)
    (unchecked-slot-ref obj 'id))
  (define (&syntax-pattern-depth obj)
    (unchecked-slot-ref obj 'depth))
  (define (&syntax-pattern-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&syntax-pattern-depth-set! obj val)
    (unchecked-slot-set! obj 'depth val)))

(begin
  (define syntax-pattern::apply-macro-expander
    (lambda (self stx)
      (raise-syntax-error
        #f
        "Identifier used out of context"
        stx)))
  (bind-method!
    syntax-pattern::t
    'apply-macro-expander
    syntax-pattern::apply-macro-expander))

(define (macro-expand-syntax stx)
  (define (generate e)
    (define (BUG q)
      (error 'gerbil "BUG: syntax; generate" stx e q))
    (define (local-pattern-e pat)
      (syntax-local-rewrap (syntax-pattern-id pat)))
    (define (getvar q vars) (agetq q vars BUG))
    (define (getarg arg vars)
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-496} arg])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-496})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-497} (car #{match-val dpuuv4a3mobea70icwo8nvdax-496})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-498} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-496})])
              (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-497}])
                (let ([e #{tl dpuuv4a3mobea70icwo8nvdax-498}])
                  (begin
                    (case tag
                      [(ref) (getvar e vars)]
                      [(pattern) (local-pattern-e e)]
                      [else (BUG arg)])))))
            (error 'match
              "no matching clause"
              #{match-val dpuuv4a3mobea70icwo8nvdax-496}))))
    (let recur ([e e] [vars (list)])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-499} e])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-499})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-500} (car #{match-val dpuuv4a3mobea70icwo8nvdax-499})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-501} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-499})])
              (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-500}])
                (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-501}])
                  (begin
                    (case tag
                      [(datum) (core-list 'quote body)]
                      [(term)
                       (let ([id (syntax-local-unwrap body)])
                         (cond
                           [(identifier-wrap? id)
                            (let ([marks (&identifier-wrap-marks id)])
                              (if (null? marks)
                                  (core-list
                                    'datum->syntax
                                    #f
                                    (core-list 'quote body))
                                  (core-list 'datum->syntax
                                    (core-list 'quote-syntax body)
                                    (core-list 'quote body) #f #f)))]
                           [(syntax-quote? id)
                            (core-list 'quote-syntax body)]
                           [else (BUG e)]))]
                      [(pattern) (local-pattern-e body)]
                      [(ref) (getvar body vars)]
                      [(cons)
                       (core-list
                         'cons
                         (recur (car body) vars)
                         (recur (cdr body) vars))]
                      [(vector)
                       (core-list 'list->vector (recur body vars))]
                      [(box) (core-list 'box (recur body vars))]
                      [(splice)
                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-502} body])
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-502})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-503} (car #{match-val dpuuv4a3mobea70icwo8nvdax-502})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-504} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-502})])
                               (let ([depth #{hd dpuuv4a3mobea70icwo8nvdax-503}])
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-504})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-505} (car #{tl dpuuv4a3mobea70icwo8nvdax-504})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-506} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-504})])
                                       (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-505}])
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-506})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-507} (car #{tl dpuuv4a3mobea70icwo8nvdax-506})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-508} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-506})])
                                               (let ([iv #{hd dpuuv4a3mobea70icwo8nvdax-507}])
                                                 (let ([args #{tl dpuuv4a3mobea70icwo8nvdax-508}])
                                                   (begin
                                                     (let* ([targets (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-509})
                                                                            (getarg
                                                                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-509}
                                                                              vars))
                                                                          args)])
                                                       (let* ([fold-in (gentemps
                                                                         args)])
                                                         (let* ([fold-out (genident)])
                                                           (let* ([lambda-args (fold-right
                                                                                 cons
                                                                                 (list
                                                                                   fold-out)
                                                                                 fold-in)])
                                                             (let* ([lambda-body (if (fx> depth
                                                                                          1)
                                                                                     (let ([r-args (map (lambda (arg)
                                                                                                          (cons
                                                                                                            'ref
                                                                                                            (cdr arg)))
                                                                                                        args)]
                                                                                           [r-vars (fold-right
                                                                                                     (lambda (arg
                                                                                                              var
                                                                                                              r)
                                                                                                       (cons
                                                                                                         (cons
                                                                                                           (cdr arg)
                                                                                                           var)
                                                                                                         r))
                                                                                                     vars
                                                                                                     args
                                                                                                     fold-in)])
                                                                                       (recur
                                                                                         (cons*
                                                                                           'splice
                                                                                           (fx1-
                                                                                             depth)
                                                                                           hd
                                                                                           (cons
                                                                                             'var
                                                                                             fold-out)
                                                                                           r-args)
                                                                                         r-vars))
                                                                                     (let ([hd-vars (fold-right
                                                                                                      (lambda (arg
                                                                                                               var
                                                                                                               r)
                                                                                                        (cons
                                                                                                          (cons
                                                                                                            (cdr arg)
                                                                                                            var)
                                                                                                          r))
                                                                                                      vars
                                                                                                      args
                                                                                                      fold-in)])
                                                                                       (core-list
                                                                                         'cons
                                                                                         (recur
                                                                                           hd
                                                                                           hd-vars)
                                                                                         fold-out)))])
                                                               (core-list
                                                                 'begin
                                                                 (if (fx> (length
                                                                            targets)
                                                                          1)
                                                                     (core-cons*
                                                                       'syntax-check-splice-targets
                                                                       targets)
                                                                     (%%void))
                                                                 (core-cons*
                                                                   'foldr
                                                                   (core-list
                                                                     'lambda%
                                                                     lambda-args
                                                                     lambda-body)
                                                                   (recur
                                                                     iv
                                                                     vars)
                                                                   targets)))))))))))
                                             (error 'match
                                               "no matching clause"
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-502}))))
                                     (error 'match
                                       "no matching clause"
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-502}))))
                             (error 'match
                               "no matching clause"
                               #{match-val dpuuv4a3mobea70icwo8nvdax-502})))]
                      [(var) body]
                      [else (BUG e)])))))
            (error 'match
              "no matching clause"
              #{match-val dpuuv4a3mobea70icwo8nvdax-499})))))
  (define (parse e)
    (define (make-cons hd tl)
      (let-values ([(hd-e hd-vars) hd] [(tl-e tl-vars) tl])
        (values (cons* 'cons hd-e tl-e) (append hd-vars tl-vars))))
    (define (make-splice where depth hd tl)
      (let-values ([(hd-e hd-vars) hd] [(tl-e tl-vars) tl])
        (let lp ([rest hd-vars] [targets (list)] [vars tl-vars])
          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-510} rest])
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-510})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-511} (car #{match-val dpuuv4a3mobea70icwo8nvdax-510})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-512} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-510})])
                  (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-511})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-513} (car #{hd dpuuv4a3mobea70icwo8nvdax-511})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-514} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-511})])
                        (let ([hd-depth* #{hd dpuuv4a3mobea70icwo8nvdax-513}])
                          (let ([hd-pat #{tl dpuuv4a3mobea70icwo8nvdax-514}])
                            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-512}])
                              (begin
                                (let ([hd-depth (fx- hd-depth* depth)])
                                  (cond
                                    [(fxpositive? hd-depth)
                                     (lp rest
                                         (cons (cons 'ref hd-pat) targets)
                                         (cons
                                           (cons hd-depth hd-pat)
                                           vars))]
                                    [(fxzero? hd-depth)
                                     (lp rest
                                         (cons
                                           (cons 'pattern hd-pat)
                                           targets)
                                         vars)]
                                    [else
                                     (raise-syntax-error
                                       #f
                                       "Too many ellipses"
                                       stx
                                       where)])))))))
                      (begin
                        (if (null? targets)
                            (raise-syntax-error
                              #f
                              "Misplaced ellipsis"
                              stx
                              where)
                            (values
                              (cons* 'splice depth hd-e tl-e targets)
                              vars)))))
                (begin
                  (if (null? targets)
                      (raise-syntax-error
                        #f
                        "Misplaced ellipsis"
                        stx
                        where)
                      (values
                        (cons* 'splice depth hd-e tl-e targets)
                        vars))))))))
    (define (recur e is-e?)
      (cond
        [(is-e? e) (raise-syntax-error #f "Mislpaced ellipsis" stx)]
        [(syntax-local-pattern? e)
         (let* ([pat (syntax-local-e e)])
           (let* ([depth (syntax-pattern-depth pat)])
             (if (fxpositive? depth)
                 (values (cons 'ref pat) (list (cons depth pat)))
                 (values (cons 'pattern pat) (list)))))]
        [(identifier? e) (values (cons 'term e) (list))]
        [(stx-pair? e)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-515} e])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-516} (lambda ()
                                                           (raise-syntax-error
                                                             #f
                                                             "Bad syntax; invalid syntax-case clause"
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-515}))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-515})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-517} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-515})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-518} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-517})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-519} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-517})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-518}])
                       (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-519}])
                         (if (is-e? hd)
                             (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-520} rest])
                               (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-521} (lambda ()
                                                                               (raise-syntax-error
                                                                                 #f
                                                                                 "Bad ellipsis syntax"
                                                                                 stx
                                                                                 e))])
                                 (if (stx-pair?
                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-520})
                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-522} (syntax-e
                                                                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-520})])
                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-523} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-522})]
                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-524} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-522})])
                                         (let ([rest #{csc-h dpuuv4a3mobea70icwo8nvdax-523}])
                                           (if (stx-null?
                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-524})
                                               (recur rest false)
                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-521})))))
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-521}))))
                             (let lp ([rest rest] [depth 0])
                               (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-525} rest])
                                 (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-526} (lambda ()
                                                                                 (if (fxpositive?
                                                                                       depth)
                                                                                     (make-splice
                                                                                       e
                                                                                       depth
                                                                                       (recur
                                                                                         hd
                                                                                         is-e?)
                                                                                       (recur
                                                                                         rest
                                                                                         is-e?))
                                                                                     (make-cons
                                                                                       (recur
                                                                                         hd
                                                                                         is-e?)
                                                                                       (recur
                                                                                         rest
                                                                                         is-e?))))])
                                   (if (stx-pair?
                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-525})
                                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-527} (syntax-e
                                                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-525})])
                                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-528} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-527})]
                                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-529} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-527})])
                                           (let ([rest-hd #{csc-h dpuuv4a3mobea70icwo8nvdax-528}])
                                             (let ([rest-tl #{csc-t dpuuv4a3mobea70icwo8nvdax-529}])
                                               (cond
                                                 [(is-e? rest-hd)
                                                  (lp rest-tl
                                                      (fx1+ depth))]
                                                 [(fxpositive? depth)
                                                  (make-splice
                                                    e
                                                    depth
                                                    (recur hd is-e?)
                                                    (recur rest is-e?))]
                                                 [else
                                                  (make-cons
                                                    (recur hd is-e?)
                                                    (recur
                                                      rest
                                                      is-e?))])))))
                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-526}))))))))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-516}))))]
        [(stx-vector? e)
         (let-values ([(e vars)
                       (recur (vector->list (stx-unwrap e)) is-e?)])
           (values (cons 'vector e) vars))]
        [(stx-box? e)
         (let-values ([(e vars)
                       (recur (unbox (stx-unwrap e)) is-e?)])
           (values (cons 'box e) vars))]
        [else (values (cons 'datum e) (list))]))
    (let-values ([(tree vars) (recur e ellipsis?)])
      (if (null? vars)
          tree
          (raise-syntax-error #f "Missing ellipsis" stx vars))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-530} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-531} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; expand-syntax expects a single argument"
                                                      stx))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-530})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-532} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-530})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-533} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-532})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-534} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-532})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-534})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-535} (syntax-e
                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-534})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-536} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-535})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-537} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-535})])
                      (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-536}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-537})
                            (stx-wrap-source
                              (generate (parse form))
                              (stx-source stx))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-531})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-531}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-531})))))

(define macro-expand-syntax-case
  (case-lambda
    [(stx)
     (let* ([identifier=? 'free-identifier=?]
            [unwrap-e 'syntax-e]
            [wrap-e 'quote-syntax])
       (define (generate-bindings target ids clauses clause-ids E)
         (define (generate1 clause clause-id E)
           (list
             (list clause-id)
             (core-list
               'lambda%
               (list target)
               (generate-clause target ids clause E))))
         (let lp ([rest clauses]
                  [rest-ids clause-ids]
                  [bindings (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-538} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-538})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-539} (car #{match-val dpuuv4a3mobea70icwo8nvdax-538})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-540} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-538})])
                   (let ([clause #{hd dpuuv4a3mobea70icwo8nvdax-539}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-540}])
                       (begin
                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-541} rest-ids])
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-542} (car #{match-val dpuuv4a3mobea70icwo8nvdax-541})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-543} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-541})])
                                 (let ([clause-id #{hd dpuuv4a3mobea70icwo8nvdax-542}])
                                   (let ([rest-ids #{tl dpuuv4a3mobea70icwo8nvdax-543}])
                                     (begin
                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-544} rest-ids])
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-544})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-545} (car #{match-val dpuuv4a3mobea70icwo8nvdax-544})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-546} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-544})])
                                               (let ([next-clause-id #{hd dpuuv4a3mobea70icwo8nvdax-545}])
                                                 (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-546}])
                                                   (begin
                                                     (lp rest
                                                         rest-ids
                                                         (cons
                                                           (generate1
                                                             clause
                                                             clause-id
                                                             next-clause-id)
                                                           bindings))))))
                                             (begin
                                               (cons
                                                 (generate1
                                                   clause
                                                   clause-id
                                                   E)
                                                 bindings))))))))
                               (error 'match
                                 "no matching clause"
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})))))))
                 (begin bindings)))))
       (define (generate-body bindings body)
         (let recur ([rest bindings])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-547} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-547})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-548} (car #{match-val dpuuv4a3mobea70icwo8nvdax-547})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-549} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-547})])
                   (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-548}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-549}])
                       (begin
                         (core-list 'let-values (list hd) (recur rest))))))
                 (begin body)))))
       (define (generate-clause target ids clause E)
         (define (generate1 hd fender body)
           (let-values ([(e mvars) (parse-clause hd ids)])
             (let* ([pvars (map syntax-local-rewrap (gentemps mvars))])
               (let* ([E (list E target)])
                 (let* ([K (core-list
                             'lambda%
                             pvars
                             (core-list
                               'let-syntax
                               (map (lambda (mvar pvar)
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-550} mvar])
                                        (if (pair?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-551} (car #{match-val dpuuv4a3mobea70icwo8nvdax-550})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-552} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-550})])
                                              (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-551}])
                                                (let ([depth #{tl dpuuv4a3mobea70icwo8nvdax-552}])
                                                  (begin
                                                    (list
                                                      id
                                                      (core-list
                                                        'make-syntax-pattern
                                                        (core-list
                                                          'quote
                                                          id)
                                                        (core-list
                                                          'quote
                                                          pvar)
                                                        depth))))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550}))))
                                    mvars
                                    pvars)
                               (if (true? fender)
                                   body
                                   (core-list 'if fender body E))))])
                   (generate-match hd target e mvars K E))))))
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-553} clause])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-554} (lambda ()
                                                           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-555} (lambda ()
                                                                                                           (raise-syntax-error
                                                                                                             #f
                                                                                                             "Bad syntax; invalid syntax-case clause"
                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-553}))])
                                                             (if (stx-pair?
                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                                                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-556} (syntax-e
                                                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                                                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-557} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-556})]
                                                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-558} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-556})])
                                                                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-557}])
                                                                       (if (stx-pair?
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-558})
                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-559} (syntax-e
                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-558})])
                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-560} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-559})]
                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-561} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-559})])
                                                                               (let ([fender #{csc-h dpuuv4a3mobea70icwo8nvdax-560}])
                                                                                 (if (stx-pair?
                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-561})
                                                                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-562} (syntax-e
                                                                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-561})])
                                                                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-563} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-562})]
                                                                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-564} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-562})])
                                                                                         (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-563}])
                                                                                           (if (stx-null?
                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-564})
                                                                                               (generate1
                                                                                                 hd
                                                                                                 fender
                                                                                                 body)
                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-555}))))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-565} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-566} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-565})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-567} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-565})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-566}])
                       (if (stx-pair?
                             #{csc-t dpuuv4a3mobea70icwo8nvdax-567})
                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-568} (syntax-e
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-567})])
                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-569} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-568})]
                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-570} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-568})])
                               (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-569}])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-570})
                                     (generate1 hd #t body)
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
       (define (generate-match where target hd mvars K E)
         (define (BUG q)
           (error 'gerbil "BUG: syntax-case; generate" stx hd q))
         (define (recur e vars target E k)
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-571} e])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-571})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-572} (car #{match-val dpuuv4a3mobea70icwo8nvdax-571})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-573} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-571})])
                   (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-572}])
                     (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-573}])
                       (begin
                         (case tag
                           [(any) (k vars)]
                           [(id)
                            (core-list
                              'if
                              (core-list 'identifier? target)
                              (core-list
                                'if
                                (core-list
                                  identifier=?
                                  (core-list wrap-e body)
                                  target)
                                (k vars)
                                E)
                              E)]
                           [(var) (k (cons (cons body target) vars))]
                           [(cons)
                            (let ([$e (genident 'e)]
                                  [$hd (genident 'hd)]
                                  [$tl (genident 'tl)])
                              (core-list
                                'if
                                (core-list 'stx-pair? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list unwrap-e target)))
                                  (core-list
                                    'let-values
                                    (list
                                      (list
                                        (list $hd)
                                        (core-list '\x23;\x23;car $e))
                                      (list
                                        (list $tl)
                                        (core-list '\x23;\x23;cdr $e)))
                                    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-574} body])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-575} (car #{match-val dpuuv4a3mobea70icwo8nvdax-574})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-576} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-574})])
                                            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-575}])
                                              (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-576}])
                                                (begin
                                                  (recur hd vars $hd E
                                                    (lambda (vars)
                                                      (recur tl vars $tl E
                                                        k)))))))
                                          (error 'match
                                            "no matching clause"
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})))))
                                E))]
                           [(splice)
                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-577} body])
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-578} (car #{match-val dpuuv4a3mobea70icwo8nvdax-577})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-579} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-577})])
                                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-578}])
                                      (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-579}])
                                        (begin
                                          (let* ([rlen (splice-rlen tl)])
                                            (let* ([$target (genident
                                                              'target)])
                                              (let* ([$hd (genident 'hd)])
                                                (let* ([$tl (genident
                                                              'tl)])
                                                  (let* ([$lp (genident
                                                                'loop)])
                                                    (let* ([$lp-e (genident
                                                                    'e)])
                                                      (let* ([$lp-hd (genident
                                                                       'lp-hd)])
                                                        (let* ([$lp-tl (genident
                                                                         'lp-tl)])
                                                          (let* ([svars (splice-vars
                                                                          hd)])
                                                            (let* ([lvars (gentemps
                                                                            svars)])
                                                              (let* ([tlvars (gentemps
                                                                               svars)])
                                                                (let* ([linit (map (lambda (var)
                                                                                     (core-list
                                                                                       'quote
                                                                                       (list)))
                                                                                   lvars)])
                                                                  (define (make-loop
                                                                           vars)
                                                                    (core-list
                                                                      'letrec-values
                                                                      (list
                                                                        (list
                                                                          (list
                                                                            $lp)
                                                                          (core-list
                                                                            'lambda%
                                                                            (cons
                                                                              $hd
                                                                              lvars)
                                                                            (core-list
                                                                              'if
                                                                              (core-list
                                                                                'stx-pair?
                                                                                $hd)
                                                                              (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $lp-e)
                                                                                    (core-list
                                                                                      unwrap-e
                                                                                      $hd)))
                                                                                (core-list
                                                                                  'let-values
                                                                                  (list
                                                                                    (list
                                                                                      (list
                                                                                        $lp-hd)
                                                                                      (core-list
                                                                                        '\x23;\x23;car
                                                                                        $lp-e))
                                                                                    (list
                                                                                      (list
                                                                                        $lp-tl)
                                                                                      (core-list
                                                                                        '\x23;\x23;cdr
                                                                                        $lp-e)))
                                                                                  (recur
                                                                                    hd
                                                                                    (list)
                                                                                    $lp-hd
                                                                                    E
                                                                                    (lambda (hdvars)
                                                                                      (cons*
                                                                                        $lp
                                                                                        $lp-tl
                                                                                        (map (lambda (svar
                                                                                                      lvar)
                                                                                               (core-list
                                                                                                 'cons
                                                                                                 (agetq
                                                                                                   svar
                                                                                                   hdvars
                                                                                                   BUG)
                                                                                                 lvar))
                                                                                             svars
                                                                                             lvars))))))
                                                                              (core-list
                                                                                'let-values
                                                                                (map (lambda (lvar
                                                                                              tlvar)
                                                                                       (list
                                                                                         (list
                                                                                           tlvar)
                                                                                         (core-list
                                                                                           'reverse
                                                                                           lvar)))
                                                                                     lvars
                                                                                     tlvars)
                                                                                (k (let ([#{f dpuuv4a3mobea70icwo8nvdax-580} (lambda (svar
                                                                                                                                      tlvar
                                                                                                                                      r)
                                                                                                                               (cons
                                                                                                                                 (cons
                                                                                                                                   svar
                                                                                                                                   tlvar)
                                                                                                                                 r))])
                                                                                     (fold-left
                                                                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-581}
                                                                                                #{e dpuuv4a3mobea70icwo8nvdax-582})
                                                                                         (#{f dpuuv4a3mobea70icwo8nvdax-580}
                                                                                           #{e dpuuv4a3mobea70icwo8nvdax-582}
                                                                                           #{a dpuuv4a3mobea70icwo8nvdax-581}))
                                                                                       vars
                                                                                       svars))))))))
                                                                      (cons*
                                                                        $lp
                                                                        $target
                                                                        linit)))
                                                                  (let ([body (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $target
                                                                                      $tl)
                                                                                    (core-list
                                                                                      'syntax-split-splice
                                                                                      target
                                                                                      rlen)))
                                                                                (recur
                                                                                  tl
                                                                                  vars
                                                                                  $tl
                                                                                  E
                                                                                  make-loop))])
                                                                    (core-list
                                                                      'if
                                                                      (core-list
                                                                        'stx-pair/null?
                                                                        target)
                                                                      (if (zero?
                                                                            rlen)
                                                                          body
                                                                          (core-list
                                                                            'if
                                                                            (core-list
                                                                              'fx>=
                                                                              (core-list
                                                                                'stx-length
                                                                                target)
                                                                              rlen)
                                                                            body
                                                                            E))
                                                                      E))))))))))))))))))
                                  (error 'match
                                    "no matching clause"
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})))]
                           [(null)
                            (core-list
                              'if
                              (core-list 'stx-null? target)
                              (k vars)
                              E)]
                           [(vector)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-vector? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'vector->list
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(box)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-box? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'unbox
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(datum)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-datum? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list 'stx-e target)))
                                  (core-list
                                    'if
                                    (core-list 'equal? $e body)
                                    (k vars)
                                    E))
                                E))]
                           [else (BUG e)])))))
                 (error 'match
                   "no matching clause"
                   #{match-val dpuuv4a3mobea70icwo8nvdax-571}))))
         (define (splice-rlen e)
           (let lp ([e e] [n 0])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-583} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-583})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-584} (car #{match-val dpuuv4a3mobea70icwo8nvdax-583})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-585} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-583})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-584}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-585}])
                         (begin
                           (case tag
                             [(splice)
                              (raise-syntax-error
                                #f
                                "Ambiguous pattern"
                                stx
                                where)]
                             [(cons) (lp (cdr body) (fx1+ n))]
                             [else n])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-583})))))
         (define (splice-vars e)
           (let recur ([e e] [vars (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-586} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-586})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-587} (car #{match-val dpuuv4a3mobea70icwo8nvdax-586})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-588} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-586})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-587}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-588}])
                         (begin
                           (case tag
                             [(var) (cons body vars)]
                             [(cons splice)
                              (recur (cdr body) (recur (car body) vars))]
                             [(vector box) (recur body vars)]
                             [else vars])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-586})))))
         (define (make-body vars)
           (cons
             K
             (map (lambda (mvar) (agetq (car mvar) vars BUG)) mvars)))
         (recur hd (list) target E make-body))
       (define (parse-clause hd ids)
         (let recur ([e hd] [vars (list)] [depth 0])
           (cond
             [(identifier? e)
              (cond
                [(underscore? e) (values '(any) vars)]
                [(ellipsis? e)
                 (raise-syntax-error #f "Misplaced ellipsis" stx hd)]
                [(find (lambda (id) (bound-identifier=? e id)) ids)
                 (values (cons 'id e) vars)]
                [(find
                   (lambda (var) (bound-identifier=? e (car var)))
                   vars)
                 (raise-syntax-error
                   #f
                   "Duplicate pattern variable"
                   stx
                   e)]
                [else (values (cons 'var e) (cons (cons e depth) vars))])]
             [(stx-pair? e)
              (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-589} e])
                (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-590} (lambda ()
                                                                (raise-syntax-error
                                                                  #f
                                                                  "Bad syntax; invalid syntax-case clause"
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-589}))])
                  (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-589})
                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-591} (syntax-e
                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-589})])
                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-592} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-591})]
                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-593} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-591})])
                          (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-592}])
                            (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-593}])
                              (let ([make-pair (lambda (tag hd tl)
                                                 (let*-values ([(hd-depth)
                                                                (if (eq? tag
                                                                         'splice)
                                                                    (fx1+
                                                                      depth)
                                                                    depth)]
                                                               [(hd vars)
                                                                (recur
                                                                  hd
                                                                  vars
                                                                  hd-depth)]
                                                               [(tl vars)
                                                                (recur
                                                                  tl
                                                                  vars
                                                                  depth)])
                                                   (values
                                                     (cons* tag hd tl)
                                                     vars)))])
                                (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-594} rest])
                                  (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-595} (lambda ()
                                                                                  (make-pair
                                                                                    'cons
                                                                                    hd
                                                                                    rest))])
                                    (if (stx-pair?
                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-594})
                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-596} (syntax-e
                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-594})])
                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-597} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-596})]
                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-598} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-596})])
                                            (let ([rest-hd #{csc-h dpuuv4a3mobea70icwo8nvdax-597}])
                                              (let ([rest-tl #{csc-t dpuuv4a3mobea70icwo8nvdax-598}])
                                                (if (ellipsis? rest-hd)
                                                    (make-pair
                                                      'splice
                                                      hd
                                                      rest-tl)
                                                    (make-pair
                                                      'cons
                                                      hd
                                                      rest))))))
                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-595})))))))))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-590}))))]
             [(stx-null? e) (values '(null) vars)]
             [(stx-vector? e)
              (let-values ([(e vars)
                            (recur
                              (vector->list (syntax-e e))
                              vars
                              depth)])
                (values (cons 'vector e) vars))]
             [(stx-box? e)
              (let-values ([(e vars)
                            (recur (unbox (syntax-e e)) vars depth)])
                (values (cons 'box e) vars))]
             [(stx-datum? e) (values (cons 'datum (stx-e e)) vars)]
             [else (raise-syntax-error #f "Bad pattern" stx e)])))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-599} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-600} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-599}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-599})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-601} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-599})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-602} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-601})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-603} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-601})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-603})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-604} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-603})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-605} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-604})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-606} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-604})])
                           (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-605}])
                             (if (stx-pair?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-606})
                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-607} (syntax-e
                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-606})])
                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-608} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-607})]
                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-609} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-607})])
                                     (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-608}])
                                       (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-609}])
                                         (cond
                                           [(not (identifier-list? ids))
                                            (raise-syntax-error
                                              #f
                                              "Bad template identifier list"
                                              stx
                                              ids)]
                                           [(not (stx-list? clauses))
                                            (raise-syntax-error
                                              #f
                                              "Bad syntax; clauses expected"
                                              stx)]
                                           [else
                                            (let* ([ids (syntax->list
                                                          ids)])
                                              (let* ([clauses (syntax->list
                                                                clauses)])
                                                (let* ([clause-ids (gentemps
                                                                     clauses)])
                                                  (let* ([E (genident)])
                                                    (let* ([target (genident)])
                                                      (let* ([first (if (null?
                                                                          clauses)
                                                                        E
                                                                        (car clause-ids))])
                                                        (stx-wrap-source
                                                          (core-list
                                                            'begin-annotation
                                                            '\x40;syntax-case
                                                            (stx-wrap-source
                                                              (core-list
                                                                'let-values
                                                                (list
                                                                  (list
                                                                    (list
                                                                      E)
                                                                    (core-list
                                                                      'lambda%
                                                                      (list
                                                                        target)
                                                                      (core-list
                                                                        'raise-syntax-error
                                                                        #f
                                                                        "Bad syntax; invalid match target"
                                                                        target))))
                                                                (generate-body
                                                                  (generate-bindings target
                                                                    ids
                                                                    clauses
                                                                    clause-ids
                                                                    E)
                                                                  (list
                                                                    first
                                                                    expr)))
                                                              (stx-source
                                                                stx)))
                                                          (stx-source
                                                            stx))))))))])))))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-600}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))]
    [(stx identifier=?)
     (let* ([unwrap-e 'syntax-e] [wrap-e 'quote-syntax])
       (define (generate-bindings target ids clauses clause-ids E)
         (define (generate1 clause clause-id E)
           (list
             (list clause-id)
             (core-list
               'lambda%
               (list target)
               (generate-clause target ids clause E))))
         (let lp ([rest clauses]
                  [rest-ids clause-ids]
                  [bindings (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-538} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-538})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-539} (car #{match-val dpuuv4a3mobea70icwo8nvdax-538})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-540} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-538})])
                   (let ([clause #{hd dpuuv4a3mobea70icwo8nvdax-539}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-540}])
                       (begin
                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-541} rest-ids])
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-542} (car #{match-val dpuuv4a3mobea70icwo8nvdax-541})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-543} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-541})])
                                 (let ([clause-id #{hd dpuuv4a3mobea70icwo8nvdax-542}])
                                   (let ([rest-ids #{tl dpuuv4a3mobea70icwo8nvdax-543}])
                                     (begin
                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-544} rest-ids])
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-544})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-545} (car #{match-val dpuuv4a3mobea70icwo8nvdax-544})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-546} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-544})])
                                               (let ([next-clause-id #{hd dpuuv4a3mobea70icwo8nvdax-545}])
                                                 (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-546}])
                                                   (begin
                                                     (lp rest
                                                         rest-ids
                                                         (cons
                                                           (generate1
                                                             clause
                                                             clause-id
                                                             next-clause-id)
                                                           bindings))))))
                                             (begin
                                               (cons
                                                 (generate1
                                                   clause
                                                   clause-id
                                                   E)
                                                 bindings))))))))
                               (error 'match
                                 "no matching clause"
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})))))))
                 (begin bindings)))))
       (define (generate-body bindings body)
         (let recur ([rest bindings])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-547} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-547})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-548} (car #{match-val dpuuv4a3mobea70icwo8nvdax-547})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-549} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-547})])
                   (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-548}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-549}])
                       (begin
                         (core-list 'let-values (list hd) (recur rest))))))
                 (begin body)))))
       (define (generate-clause target ids clause E)
         (define (generate1 hd fender body)
           (let-values ([(e mvars) (parse-clause hd ids)])
             (let* ([pvars (map syntax-local-rewrap (gentemps mvars))])
               (let* ([E (list E target)])
                 (let* ([K (core-list
                             'lambda%
                             pvars
                             (core-list
                               'let-syntax
                               (map (lambda (mvar pvar)
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-550} mvar])
                                        (if (pair?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-551} (car #{match-val dpuuv4a3mobea70icwo8nvdax-550})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-552} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-550})])
                                              (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-551}])
                                                (let ([depth #{tl dpuuv4a3mobea70icwo8nvdax-552}])
                                                  (begin
                                                    (list
                                                      id
                                                      (core-list
                                                        'make-syntax-pattern
                                                        (core-list
                                                          'quote
                                                          id)
                                                        (core-list
                                                          'quote
                                                          pvar)
                                                        depth))))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550}))))
                                    mvars
                                    pvars)
                               (if (true? fender)
                                   body
                                   (core-list 'if fender body E))))])
                   (generate-match hd target e mvars K E))))))
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-553} clause])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-554} (lambda ()
                                                           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-555} (lambda ()
                                                                                                           (raise-syntax-error
                                                                                                             #f
                                                                                                             "Bad syntax; invalid syntax-case clause"
                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-553}))])
                                                             (if (stx-pair?
                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                                                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-556} (syntax-e
                                                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                                                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-557} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-556})]
                                                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-558} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-556})])
                                                                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-557}])
                                                                       (if (stx-pair?
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-558})
                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-559} (syntax-e
                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-558})])
                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-560} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-559})]
                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-561} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-559})])
                                                                               (let ([fender #{csc-h dpuuv4a3mobea70icwo8nvdax-560}])
                                                                                 (if (stx-pair?
                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-561})
                                                                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-562} (syntax-e
                                                                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-561})])
                                                                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-563} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-562})]
                                                                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-564} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-562})])
                                                                                         (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-563}])
                                                                                           (if (stx-null?
                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-564})
                                                                                               (generate1
                                                                                                 hd
                                                                                                 fender
                                                                                                 body)
                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-555}))))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-565} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-566} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-565})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-567} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-565})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-566}])
                       (if (stx-pair?
                             #{csc-t dpuuv4a3mobea70icwo8nvdax-567})
                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-568} (syntax-e
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-567})])
                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-569} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-568})]
                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-570} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-568})])
                               (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-569}])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-570})
                                     (generate1 hd #t body)
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
       (define (generate-match where target hd mvars K E)
         (define (BUG q)
           (error 'gerbil "BUG: syntax-case; generate" stx hd q))
         (define (recur e vars target E k)
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-571} e])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-571})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-572} (car #{match-val dpuuv4a3mobea70icwo8nvdax-571})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-573} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-571})])
                   (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-572}])
                     (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-573}])
                       (begin
                         (case tag
                           [(any) (k vars)]
                           [(id)
                            (core-list
                              'if
                              (core-list 'identifier? target)
                              (core-list
                                'if
                                (core-list
                                  identifier=?
                                  (core-list wrap-e body)
                                  target)
                                (k vars)
                                E)
                              E)]
                           [(var) (k (cons (cons body target) vars))]
                           [(cons)
                            (let ([$e (genident 'e)]
                                  [$hd (genident 'hd)]
                                  [$tl (genident 'tl)])
                              (core-list
                                'if
                                (core-list 'stx-pair? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list unwrap-e target)))
                                  (core-list
                                    'let-values
                                    (list
                                      (list
                                        (list $hd)
                                        (core-list '\x23;\x23;car $e))
                                      (list
                                        (list $tl)
                                        (core-list '\x23;\x23;cdr $e)))
                                    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-574} body])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-575} (car #{match-val dpuuv4a3mobea70icwo8nvdax-574})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-576} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-574})])
                                            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-575}])
                                              (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-576}])
                                                (begin
                                                  (recur hd vars $hd E
                                                    (lambda (vars)
                                                      (recur tl vars $tl E
                                                        k)))))))
                                          (error 'match
                                            "no matching clause"
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})))))
                                E))]
                           [(splice)
                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-577} body])
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-578} (car #{match-val dpuuv4a3mobea70icwo8nvdax-577})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-579} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-577})])
                                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-578}])
                                      (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-579}])
                                        (begin
                                          (let* ([rlen (splice-rlen tl)])
                                            (let* ([$target (genident
                                                              'target)])
                                              (let* ([$hd (genident 'hd)])
                                                (let* ([$tl (genident
                                                              'tl)])
                                                  (let* ([$lp (genident
                                                                'loop)])
                                                    (let* ([$lp-e (genident
                                                                    'e)])
                                                      (let* ([$lp-hd (genident
                                                                       'lp-hd)])
                                                        (let* ([$lp-tl (genident
                                                                         'lp-tl)])
                                                          (let* ([svars (splice-vars
                                                                          hd)])
                                                            (let* ([lvars (gentemps
                                                                            svars)])
                                                              (let* ([tlvars (gentemps
                                                                               svars)])
                                                                (let* ([linit (map (lambda (var)
                                                                                     (core-list
                                                                                       'quote
                                                                                       (list)))
                                                                                   lvars)])
                                                                  (define (make-loop
                                                                           vars)
                                                                    (core-list
                                                                      'letrec-values
                                                                      (list
                                                                        (list
                                                                          (list
                                                                            $lp)
                                                                          (core-list
                                                                            'lambda%
                                                                            (cons
                                                                              $hd
                                                                              lvars)
                                                                            (core-list
                                                                              'if
                                                                              (core-list
                                                                                'stx-pair?
                                                                                $hd)
                                                                              (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $lp-e)
                                                                                    (core-list
                                                                                      unwrap-e
                                                                                      $hd)))
                                                                                (core-list
                                                                                  'let-values
                                                                                  (list
                                                                                    (list
                                                                                      (list
                                                                                        $lp-hd)
                                                                                      (core-list
                                                                                        '\x23;\x23;car
                                                                                        $lp-e))
                                                                                    (list
                                                                                      (list
                                                                                        $lp-tl)
                                                                                      (core-list
                                                                                        '\x23;\x23;cdr
                                                                                        $lp-e)))
                                                                                  (recur
                                                                                    hd
                                                                                    (list)
                                                                                    $lp-hd
                                                                                    E
                                                                                    (lambda (hdvars)
                                                                                      (cons*
                                                                                        $lp
                                                                                        $lp-tl
                                                                                        (map (lambda (svar
                                                                                                      lvar)
                                                                                               (core-list
                                                                                                 'cons
                                                                                                 (agetq
                                                                                                   svar
                                                                                                   hdvars
                                                                                                   BUG)
                                                                                                 lvar))
                                                                                             svars
                                                                                             lvars))))))
                                                                              (core-list
                                                                                'let-values
                                                                                (map (lambda (lvar
                                                                                              tlvar)
                                                                                       (list
                                                                                         (list
                                                                                           tlvar)
                                                                                         (core-list
                                                                                           'reverse
                                                                                           lvar)))
                                                                                     lvars
                                                                                     tlvars)
                                                                                (k (let ([#{f dpuuv4a3mobea70icwo8nvdax-580} (lambda (svar
                                                                                                                                      tlvar
                                                                                                                                      r)
                                                                                                                               (cons
                                                                                                                                 (cons
                                                                                                                                   svar
                                                                                                                                   tlvar)
                                                                                                                                 r))])
                                                                                     (fold-left
                                                                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-581}
                                                                                                #{e dpuuv4a3mobea70icwo8nvdax-582})
                                                                                         (#{f dpuuv4a3mobea70icwo8nvdax-580}
                                                                                           #{e dpuuv4a3mobea70icwo8nvdax-582}
                                                                                           #{a dpuuv4a3mobea70icwo8nvdax-581}))
                                                                                       vars
                                                                                       svars))))))))
                                                                      (cons*
                                                                        $lp
                                                                        $target
                                                                        linit)))
                                                                  (let ([body (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $target
                                                                                      $tl)
                                                                                    (core-list
                                                                                      'syntax-split-splice
                                                                                      target
                                                                                      rlen)))
                                                                                (recur
                                                                                  tl
                                                                                  vars
                                                                                  $tl
                                                                                  E
                                                                                  make-loop))])
                                                                    (core-list
                                                                      'if
                                                                      (core-list
                                                                        'stx-pair/null?
                                                                        target)
                                                                      (if (zero?
                                                                            rlen)
                                                                          body
                                                                          (core-list
                                                                            'if
                                                                            (core-list
                                                                              'fx>=
                                                                              (core-list
                                                                                'stx-length
                                                                                target)
                                                                              rlen)
                                                                            body
                                                                            E))
                                                                      E))))))))))))))))))
                                  (error 'match
                                    "no matching clause"
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})))]
                           [(null)
                            (core-list
                              'if
                              (core-list 'stx-null? target)
                              (k vars)
                              E)]
                           [(vector)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-vector? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'vector->list
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(box)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-box? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'unbox
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(datum)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-datum? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list 'stx-e target)))
                                  (core-list
                                    'if
                                    (core-list 'equal? $e body)
                                    (k vars)
                                    E))
                                E))]
                           [else (BUG e)])))))
                 (error 'match
                   "no matching clause"
                   #{match-val dpuuv4a3mobea70icwo8nvdax-571}))))
         (define (splice-rlen e)
           (let lp ([e e] [n 0])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-583} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-583})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-584} (car #{match-val dpuuv4a3mobea70icwo8nvdax-583})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-585} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-583})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-584}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-585}])
                         (begin
                           (case tag
                             [(splice)
                              (raise-syntax-error
                                #f
                                "Ambiguous pattern"
                                stx
                                where)]
                             [(cons) (lp (cdr body) (fx1+ n))]
                             [else n])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-583})))))
         (define (splice-vars e)
           (let recur ([e e] [vars (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-586} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-586})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-587} (car #{match-val dpuuv4a3mobea70icwo8nvdax-586})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-588} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-586})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-587}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-588}])
                         (begin
                           (case tag
                             [(var) (cons body vars)]
                             [(cons splice)
                              (recur (cdr body) (recur (car body) vars))]
                             [(vector box) (recur body vars)]
                             [else vars])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-586})))))
         (define (make-body vars)
           (cons
             K
             (map (lambda (mvar) (agetq (car mvar) vars BUG)) mvars)))
         (recur hd (list) target E make-body))
       (define (parse-clause hd ids)
         (let recur ([e hd] [vars (list)] [depth 0])
           (cond
             [(identifier? e)
              (cond
                [(underscore? e) (values '(any) vars)]
                [(ellipsis? e)
                 (raise-syntax-error #f "Misplaced ellipsis" stx hd)]
                [(find (lambda (id) (bound-identifier=? e id)) ids)
                 (values (cons 'id e) vars)]
                [(find
                   (lambda (var) (bound-identifier=? e (car var)))
                   vars)
                 (raise-syntax-error
                   #f
                   "Duplicate pattern variable"
                   stx
                   e)]
                [else (values (cons 'var e) (cons (cons e depth) vars))])]
             [(stx-pair? e)
              (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-589} e])
                (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-590} (lambda ()
                                                                (raise-syntax-error
                                                                  #f
                                                                  "Bad syntax; invalid syntax-case clause"
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-589}))])
                  (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-589})
                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-591} (syntax-e
                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-589})])
                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-592} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-591})]
                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-593} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-591})])
                          (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-592}])
                            (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-593}])
                              (let ([make-pair (lambda (tag hd tl)
                                                 (let*-values ([(hd-depth)
                                                                (if (eq? tag
                                                                         'splice)
                                                                    (fx1+
                                                                      depth)
                                                                    depth)]
                                                               [(hd vars)
                                                                (recur
                                                                  hd
                                                                  vars
                                                                  hd-depth)]
                                                               [(tl vars)
                                                                (recur
                                                                  tl
                                                                  vars
                                                                  depth)])
                                                   (values
                                                     (cons* tag hd tl)
                                                     vars)))])
                                (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-594} rest])
                                  (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-595} (lambda ()
                                                                                  (make-pair
                                                                                    'cons
                                                                                    hd
                                                                                    rest))])
                                    (if (stx-pair?
                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-594})
                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-596} (syntax-e
                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-594})])
                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-597} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-596})]
                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-598} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-596})])
                                            (let ([rest-hd #{csc-h dpuuv4a3mobea70icwo8nvdax-597}])
                                              (let ([rest-tl #{csc-t dpuuv4a3mobea70icwo8nvdax-598}])
                                                (if (ellipsis? rest-hd)
                                                    (make-pair
                                                      'splice
                                                      hd
                                                      rest-tl)
                                                    (make-pair
                                                      'cons
                                                      hd
                                                      rest))))))
                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-595})))))))))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-590}))))]
             [(stx-null? e) (values '(null) vars)]
             [(stx-vector? e)
              (let-values ([(e vars)
                            (recur
                              (vector->list (syntax-e e))
                              vars
                              depth)])
                (values (cons 'vector e) vars))]
             [(stx-box? e)
              (let-values ([(e vars)
                            (recur (unbox (syntax-e e)) vars depth)])
                (values (cons 'box e) vars))]
             [(stx-datum? e) (values (cons 'datum (stx-e e)) vars)]
             [else (raise-syntax-error #f "Bad pattern" stx e)])))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-599} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-600} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-599}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-599})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-601} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-599})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-602} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-601})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-603} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-601})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-603})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-604} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-603})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-605} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-604})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-606} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-604})])
                           (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-605}])
                             (if (stx-pair?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-606})
                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-607} (syntax-e
                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-606})])
                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-608} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-607})]
                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-609} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-607})])
                                     (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-608}])
                                       (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-609}])
                                         (cond
                                           [(not (identifier-list? ids))
                                            (raise-syntax-error
                                              #f
                                              "Bad template identifier list"
                                              stx
                                              ids)]
                                           [(not (stx-list? clauses))
                                            (raise-syntax-error
                                              #f
                                              "Bad syntax; clauses expected"
                                              stx)]
                                           [else
                                            (let* ([ids (syntax->list
                                                          ids)])
                                              (let* ([clauses (syntax->list
                                                                clauses)])
                                                (let* ([clause-ids (gentemps
                                                                     clauses)])
                                                  (let* ([E (genident)])
                                                    (let* ([target (genident)])
                                                      (let* ([first (if (null?
                                                                          clauses)
                                                                        E
                                                                        (car clause-ids))])
                                                        (stx-wrap-source
                                                          (core-list
                                                            'begin-annotation
                                                            '\x40;syntax-case
                                                            (stx-wrap-source
                                                              (core-list
                                                                'let-values
                                                                (list
                                                                  (list
                                                                    (list
                                                                      E)
                                                                    (core-list
                                                                      'lambda%
                                                                      (list
                                                                        target)
                                                                      (core-list
                                                                        'raise-syntax-error
                                                                        #f
                                                                        "Bad syntax; invalid match target"
                                                                        target))))
                                                                (generate-body
                                                                  (generate-bindings target
                                                                    ids
                                                                    clauses
                                                                    clause-ids
                                                                    E)
                                                                  (list
                                                                    first
                                                                    expr)))
                                                              (stx-source
                                                                stx)))
                                                          (stx-source
                                                            stx))))))))])))))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-600}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))]
    [(stx identifier=? unwrap-e)
     (let* ([wrap-e 'quote-syntax])
       (define (generate-bindings target ids clauses clause-ids E)
         (define (generate1 clause clause-id E)
           (list
             (list clause-id)
             (core-list
               'lambda%
               (list target)
               (generate-clause target ids clause E))))
         (let lp ([rest clauses]
                  [rest-ids clause-ids]
                  [bindings (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-538} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-538})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-539} (car #{match-val dpuuv4a3mobea70icwo8nvdax-538})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-540} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-538})])
                   (let ([clause #{hd dpuuv4a3mobea70icwo8nvdax-539}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-540}])
                       (begin
                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-541} rest-ids])
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-542} (car #{match-val dpuuv4a3mobea70icwo8nvdax-541})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-543} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-541})])
                                 (let ([clause-id #{hd dpuuv4a3mobea70icwo8nvdax-542}])
                                   (let ([rest-ids #{tl dpuuv4a3mobea70icwo8nvdax-543}])
                                     (begin
                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-544} rest-ids])
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-544})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-545} (car #{match-val dpuuv4a3mobea70icwo8nvdax-544})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-546} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-544})])
                                               (let ([next-clause-id #{hd dpuuv4a3mobea70icwo8nvdax-545}])
                                                 (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-546}])
                                                   (begin
                                                     (lp rest
                                                         rest-ids
                                                         (cons
                                                           (generate1
                                                             clause
                                                             clause-id
                                                             next-clause-id)
                                                           bindings))))))
                                             (begin
                                               (cons
                                                 (generate1
                                                   clause
                                                   clause-id
                                                   E)
                                                 bindings))))))))
                               (error 'match
                                 "no matching clause"
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-541})))))))
                 (begin bindings)))))
       (define (generate-body bindings body)
         (let recur ([rest bindings])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-547} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-547})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-548} (car #{match-val dpuuv4a3mobea70icwo8nvdax-547})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-549} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-547})])
                   (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-548}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-549}])
                       (begin
                         (core-list 'let-values (list hd) (recur rest))))))
                 (begin body)))))
       (define (generate-clause target ids clause E)
         (define (generate1 hd fender body)
           (let-values ([(e mvars) (parse-clause hd ids)])
             (let* ([pvars (map syntax-local-rewrap (gentemps mvars))])
               (let* ([E (list E target)])
                 (let* ([K (core-list
                             'lambda%
                             pvars
                             (core-list
                               'let-syntax
                               (map (lambda (mvar pvar)
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-550} mvar])
                                        (if (pair?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-551} (car #{match-val dpuuv4a3mobea70icwo8nvdax-550})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-552} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-550})])
                                              (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-551}])
                                                (let ([depth #{tl dpuuv4a3mobea70icwo8nvdax-552}])
                                                  (begin
                                                    (list
                                                      id
                                                      (core-list
                                                        'make-syntax-pattern
                                                        (core-list
                                                          'quote
                                                          id)
                                                        (core-list
                                                          'quote
                                                          pvar)
                                                        depth))))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-550}))))
                                    mvars
                                    pvars)
                               (if (true? fender)
                                   body
                                   (core-list 'if fender body E))))])
                   (generate-match hd target e mvars K E))))))
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-553} clause])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-554} (lambda ()
                                                           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-555} (lambda ()
                                                                                                           (raise-syntax-error
                                                                                                             #f
                                                                                                             "Bad syntax; invalid syntax-case clause"
                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-553}))])
                                                             (if (stx-pair?
                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                                                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-556} (syntax-e
                                                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                                                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-557} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-556})]
                                                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-558} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-556})])
                                                                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-557}])
                                                                       (if (stx-pair?
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-558})
                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-559} (syntax-e
                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-558})])
                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-560} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-559})]
                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-561} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-559})])
                                                                               (let ([fender #{csc-h dpuuv4a3mobea70icwo8nvdax-560}])
                                                                                 (if (stx-pair?
                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-561})
                                                                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-562} (syntax-e
                                                                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-561})])
                                                                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-563} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-562})]
                                                                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-564} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-562})])
                                                                                         (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-563}])
                                                                                           (if (stx-null?
                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-564})
                                                                                               (generate1
                                                                                                 hd
                                                                                                 fender
                                                                                                 body)
                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-555}))))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-565} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-566} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-565})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-567} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-565})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-566}])
                       (if (stx-pair?
                             #{csc-t dpuuv4a3mobea70icwo8nvdax-567})
                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-568} (syntax-e
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-567})])
                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-569} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-568})]
                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-570} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-568})])
                               (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-569}])
                                 (if (stx-null?
                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-570})
                                     (generate1 hd #t body)
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
       (define (generate-match where target hd mvars K E)
         (define (BUG q)
           (error 'gerbil "BUG: syntax-case; generate" stx hd q))
         (define (recur e vars target E k)
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-571} e])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-571})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-572} (car #{match-val dpuuv4a3mobea70icwo8nvdax-571})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-573} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-571})])
                   (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-572}])
                     (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-573}])
                       (begin
                         (case tag
                           [(any) (k vars)]
                           [(id)
                            (core-list
                              'if
                              (core-list 'identifier? target)
                              (core-list
                                'if
                                (core-list
                                  identifier=?
                                  (core-list wrap-e body)
                                  target)
                                (k vars)
                                E)
                              E)]
                           [(var) (k (cons (cons body target) vars))]
                           [(cons)
                            (let ([$e (genident 'e)]
                                  [$hd (genident 'hd)]
                                  [$tl (genident 'tl)])
                              (core-list
                                'if
                                (core-list 'stx-pair? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list unwrap-e target)))
                                  (core-list
                                    'let-values
                                    (list
                                      (list
                                        (list $hd)
                                        (core-list '\x23;\x23;car $e))
                                      (list
                                        (list $tl)
                                        (core-list '\x23;\x23;cdr $e)))
                                    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-574} body])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-575} (car #{match-val dpuuv4a3mobea70icwo8nvdax-574})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-576} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-574})])
                                            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-575}])
                                              (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-576}])
                                                (begin
                                                  (recur hd vars $hd E
                                                    (lambda (vars)
                                                      (recur tl vars $tl E
                                                        k)))))))
                                          (error 'match
                                            "no matching clause"
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-574})))))
                                E))]
                           [(splice)
                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-577} body])
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-578} (car #{match-val dpuuv4a3mobea70icwo8nvdax-577})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-579} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-577})])
                                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-578}])
                                      (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-579}])
                                        (begin
                                          (let* ([rlen (splice-rlen tl)])
                                            (let* ([$target (genident
                                                              'target)])
                                              (let* ([$hd (genident 'hd)])
                                                (let* ([$tl (genident
                                                              'tl)])
                                                  (let* ([$lp (genident
                                                                'loop)])
                                                    (let* ([$lp-e (genident
                                                                    'e)])
                                                      (let* ([$lp-hd (genident
                                                                       'lp-hd)])
                                                        (let* ([$lp-tl (genident
                                                                         'lp-tl)])
                                                          (let* ([svars (splice-vars
                                                                          hd)])
                                                            (let* ([lvars (gentemps
                                                                            svars)])
                                                              (let* ([tlvars (gentemps
                                                                               svars)])
                                                                (let* ([linit (map (lambda (var)
                                                                                     (core-list
                                                                                       'quote
                                                                                       (list)))
                                                                                   lvars)])
                                                                  (define (make-loop
                                                                           vars)
                                                                    (core-list
                                                                      'letrec-values
                                                                      (list
                                                                        (list
                                                                          (list
                                                                            $lp)
                                                                          (core-list
                                                                            'lambda%
                                                                            (cons
                                                                              $hd
                                                                              lvars)
                                                                            (core-list
                                                                              'if
                                                                              (core-list
                                                                                'stx-pair?
                                                                                $hd)
                                                                              (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $lp-e)
                                                                                    (core-list
                                                                                      unwrap-e
                                                                                      $hd)))
                                                                                (core-list
                                                                                  'let-values
                                                                                  (list
                                                                                    (list
                                                                                      (list
                                                                                        $lp-hd)
                                                                                      (core-list
                                                                                        '\x23;\x23;car
                                                                                        $lp-e))
                                                                                    (list
                                                                                      (list
                                                                                        $lp-tl)
                                                                                      (core-list
                                                                                        '\x23;\x23;cdr
                                                                                        $lp-e)))
                                                                                  (recur
                                                                                    hd
                                                                                    (list)
                                                                                    $lp-hd
                                                                                    E
                                                                                    (lambda (hdvars)
                                                                                      (cons*
                                                                                        $lp
                                                                                        $lp-tl
                                                                                        (map (lambda (svar
                                                                                                      lvar)
                                                                                               (core-list
                                                                                                 'cons
                                                                                                 (agetq
                                                                                                   svar
                                                                                                   hdvars
                                                                                                   BUG)
                                                                                                 lvar))
                                                                                             svars
                                                                                             lvars))))))
                                                                              (core-list
                                                                                'let-values
                                                                                (map (lambda (lvar
                                                                                              tlvar)
                                                                                       (list
                                                                                         (list
                                                                                           tlvar)
                                                                                         (core-list
                                                                                           'reverse
                                                                                           lvar)))
                                                                                     lvars
                                                                                     tlvars)
                                                                                (k (let ([#{f dpuuv4a3mobea70icwo8nvdax-580} (lambda (svar
                                                                                                                                      tlvar
                                                                                                                                      r)
                                                                                                                               (cons
                                                                                                                                 (cons
                                                                                                                                   svar
                                                                                                                                   tlvar)
                                                                                                                                 r))])
                                                                                     (fold-left
                                                                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-581}
                                                                                                #{e dpuuv4a3mobea70icwo8nvdax-582})
                                                                                         (#{f dpuuv4a3mobea70icwo8nvdax-580}
                                                                                           #{e dpuuv4a3mobea70icwo8nvdax-582}
                                                                                           #{a dpuuv4a3mobea70icwo8nvdax-581}))
                                                                                       vars
                                                                                       svars))))))))
                                                                      (cons*
                                                                        $lp
                                                                        $target
                                                                        linit)))
                                                                  (let ([body (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $target
                                                                                      $tl)
                                                                                    (core-list
                                                                                      'syntax-split-splice
                                                                                      target
                                                                                      rlen)))
                                                                                (recur
                                                                                  tl
                                                                                  vars
                                                                                  $tl
                                                                                  E
                                                                                  make-loop))])
                                                                    (core-list
                                                                      'if
                                                                      (core-list
                                                                        'stx-pair/null?
                                                                        target)
                                                                      (if (zero?
                                                                            rlen)
                                                                          body
                                                                          (core-list
                                                                            'if
                                                                            (core-list
                                                                              'fx>=
                                                                              (core-list
                                                                                'stx-length
                                                                                target)
                                                                              rlen)
                                                                            body
                                                                            E))
                                                                      E))))))))))))))))))
                                  (error 'match
                                    "no matching clause"
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-577})))]
                           [(null)
                            (core-list
                              'if
                              (core-list 'stx-null? target)
                              (k vars)
                              E)]
                           [(vector)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-vector? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'vector->list
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(box)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-box? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list
                                        'unbox
                                        (core-list unwrap-e target))))
                                  (recur body vars $e E k))
                                E))]
                           [(datum)
                            (let ([$e (genident 'e)])
                              (core-list
                                'if
                                (core-list 'stx-datum? target)
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $e)
                                      (core-list 'stx-e target)))
                                  (core-list
                                    'if
                                    (core-list 'equal? $e body)
                                    (k vars)
                                    E))
                                E))]
                           [else (BUG e)])))))
                 (error 'match
                   "no matching clause"
                   #{match-val dpuuv4a3mobea70icwo8nvdax-571}))))
         (define (splice-rlen e)
           (let lp ([e e] [n 0])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-583} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-583})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-584} (car #{match-val dpuuv4a3mobea70icwo8nvdax-583})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-585} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-583})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-584}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-585}])
                         (begin
                           (case tag
                             [(splice)
                              (raise-syntax-error
                                #f
                                "Ambiguous pattern"
                                stx
                                where)]
                             [(cons) (lp (cdr body) (fx1+ n))]
                             [else n])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-583})))))
         (define (splice-vars e)
           (let recur ([e e] [vars (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-586} e])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-586})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-587} (car #{match-val dpuuv4a3mobea70icwo8nvdax-586})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-588} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-586})])
                     (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-587}])
                       (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-588}])
                         (begin
                           (case tag
                             [(var) (cons body vars)]
                             [(cons splice)
                              (recur (cdr body) (recur (car body) vars))]
                             [(vector box) (recur body vars)]
                             [else vars])))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-586})))))
         (define (make-body vars)
           (cons
             K
             (map (lambda (mvar) (agetq (car mvar) vars BUG)) mvars)))
         (recur hd (list) target E make-body))
       (define (parse-clause hd ids)
         (let recur ([e hd] [vars (list)] [depth 0])
           (cond
             [(identifier? e)
              (cond
                [(underscore? e) (values '(any) vars)]
                [(ellipsis? e)
                 (raise-syntax-error #f "Misplaced ellipsis" stx hd)]
                [(find (lambda (id) (bound-identifier=? e id)) ids)
                 (values (cons 'id e) vars)]
                [(find
                   (lambda (var) (bound-identifier=? e (car var)))
                   vars)
                 (raise-syntax-error
                   #f
                   "Duplicate pattern variable"
                   stx
                   e)]
                [else (values (cons 'var e) (cons (cons e depth) vars))])]
             [(stx-pair? e)
              (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-589} e])
                (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-590} (lambda ()
                                                                (raise-syntax-error
                                                                  #f
                                                                  "Bad syntax; invalid syntax-case clause"
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-589}))])
                  (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-589})
                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-591} (syntax-e
                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-589})])
                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-592} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-591})]
                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-593} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-591})])
                          (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-592}])
                            (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-593}])
                              (let ([make-pair (lambda (tag hd tl)
                                                 (let*-values ([(hd-depth)
                                                                (if (eq? tag
                                                                         'splice)
                                                                    (fx1+
                                                                      depth)
                                                                    depth)]
                                                               [(hd vars)
                                                                (recur
                                                                  hd
                                                                  vars
                                                                  hd-depth)]
                                                               [(tl vars)
                                                                (recur
                                                                  tl
                                                                  vars
                                                                  depth)])
                                                   (values
                                                     (cons* tag hd tl)
                                                     vars)))])
                                (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-594} rest])
                                  (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-595} (lambda ()
                                                                                  (make-pair
                                                                                    'cons
                                                                                    hd
                                                                                    rest))])
                                    (if (stx-pair?
                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-594})
                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-596} (syntax-e
                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-594})])
                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-597} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-596})]
                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-598} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-596})])
                                            (let ([rest-hd #{csc-h dpuuv4a3mobea70icwo8nvdax-597}])
                                              (let ([rest-tl #{csc-t dpuuv4a3mobea70icwo8nvdax-598}])
                                                (if (ellipsis? rest-hd)
                                                    (make-pair
                                                      'splice
                                                      hd
                                                      rest-tl)
                                                    (make-pair
                                                      'cons
                                                      hd
                                                      rest))))))
                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-595})))))))))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-590}))))]
             [(stx-null? e) (values '(null) vars)]
             [(stx-vector? e)
              (let-values ([(e vars)
                            (recur
                              (vector->list (syntax-e e))
                              vars
                              depth)])
                (values (cons 'vector e) vars))]
             [(stx-box? e)
              (let-values ([(e vars)
                            (recur (unbox (syntax-e e)) vars depth)])
                (values (cons 'box e) vars))]
             [(stx-datum? e) (values (cons 'datum (stx-e e)) vars)]
             [else (raise-syntax-error #f "Bad pattern" stx e)])))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-599} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-600} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-599}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-599})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-601} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-599})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-602} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-601})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-603} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-601})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-603})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-604} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-603})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-605} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-604})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-606} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-604})])
                           (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-605}])
                             (if (stx-pair?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-606})
                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-607} (syntax-e
                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-606})])
                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-608} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-607})]
                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-609} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-607})])
                                     (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-608}])
                                       (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-609}])
                                         (cond
                                           [(not (identifier-list? ids))
                                            (raise-syntax-error
                                              #f
                                              "Bad template identifier list"
                                              stx
                                              ids)]
                                           [(not (stx-list? clauses))
                                            (raise-syntax-error
                                              #f
                                              "Bad syntax; clauses expected"
                                              stx)]
                                           [else
                                            (let* ([ids (syntax->list
                                                          ids)])
                                              (let* ([clauses (syntax->list
                                                                clauses)])
                                                (let* ([clause-ids (gentemps
                                                                     clauses)])
                                                  (let* ([E (genident)])
                                                    (let* ([target (genident)])
                                                      (let* ([first (if (null?
                                                                          clauses)
                                                                        E
                                                                        (car clause-ids))])
                                                        (stx-wrap-source
                                                          (core-list
                                                            'begin-annotation
                                                            '\x40;syntax-case
                                                            (stx-wrap-source
                                                              (core-list
                                                                'let-values
                                                                (list
                                                                  (list
                                                                    (list
                                                                      E)
                                                                    (core-list
                                                                      'lambda%
                                                                      (list
                                                                        target)
                                                                      (core-list
                                                                        'raise-syntax-error
                                                                        #f
                                                                        "Bad syntax; invalid match target"
                                                                        target))))
                                                                (generate-body
                                                                  (generate-bindings target
                                                                    ids
                                                                    clauses
                                                                    clause-ids
                                                                    E)
                                                                  (list
                                                                    first
                                                                    expr)))
                                                              (stx-source
                                                                stx)))
                                                          (stx-source
                                                            stx))))))))])))))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-600}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))]
    [(stx identifier=? unwrap-e wrap-e)
     (define (generate-bindings target ids clauses clause-ids E)
       (define (generate1 clause clause-id E)
         (list
           (list clause-id)
           (core-list
             'lambda%
             (list target)
             (generate-clause target ids clause E))))
       (let lp ([rest clauses]
                [rest-ids clause-ids]
                [bindings (list)])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-538} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-538})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-539} (car #{match-val dpuuv4a3mobea70icwo8nvdax-538})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-540} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-538})])
                 (let ([clause #{hd dpuuv4a3mobea70icwo8nvdax-539}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-540}])
                     (begin
                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-541} rest-ids])
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-541})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-542} (car #{match-val dpuuv4a3mobea70icwo8nvdax-541})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-543} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-541})])
                               (let ([clause-id #{hd dpuuv4a3mobea70icwo8nvdax-542}])
                                 (let ([rest-ids #{tl dpuuv4a3mobea70icwo8nvdax-543}])
                                   (begin
                                     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-544} rest-ids])
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-544})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-545} (car #{match-val dpuuv4a3mobea70icwo8nvdax-544})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-546} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-544})])
                                             (let ([next-clause-id #{hd dpuuv4a3mobea70icwo8nvdax-545}])
                                               (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-546}])
                                                 (begin
                                                   (lp rest
                                                       rest-ids
                                                       (cons
                                                         (generate1
                                                           clause
                                                           clause-id
                                                           next-clause-id)
                                                         bindings))))))
                                           (begin
                                             (cons
                                               (generate1
                                                 clause
                                                 clause-id
                                                 E)
                                               bindings))))))))
                             (error 'match
                               "no matching clause"
                               #{match-val dpuuv4a3mobea70icwo8nvdax-541})))))))
               (begin bindings)))))
     (define (generate-body bindings body)
       (let recur ([rest bindings])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-547} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-547})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-548} (car #{match-val dpuuv4a3mobea70icwo8nvdax-547})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-549} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-547})])
                 (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-548}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-549}])
                     (begin
                       (core-list 'let-values (list hd) (recur rest))))))
               (begin body)))))
     (define (generate-clause target ids clause E)
       (define (generate1 hd fender body)
         (let-values ([(e mvars) (parse-clause hd ids)])
           (let* ([pvars (map syntax-local-rewrap (gentemps mvars))])
             (let* ([E (list E target)])
               (let* ([K (core-list
                           'lambda%
                           pvars
                           (core-list
                             'let-syntax
                             (map (lambda (mvar pvar)
                                    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-550} mvar])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-550})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-551} (car #{match-val dpuuv4a3mobea70icwo8nvdax-550})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-552} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-550})])
                                            (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-551}])
                                              (let ([depth #{tl dpuuv4a3mobea70icwo8nvdax-552}])
                                                (begin
                                                  (list
                                                    id
                                                    (core-list
                                                      'make-syntax-pattern
                                                      (core-list 'quote id)
                                                      (core-list
                                                        'quote
                                                        pvar)
                                                      depth))))))
                                          (error 'match
                                            "no matching clause"
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-550}))))
                                  mvars
                                  pvars)
                             (if (true? fender)
                                 body
                                 (core-list 'if fender body E))))])
                 (generate-match hd target e mvars K E))))))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-553} clause])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-554} (lambda ()
                                                         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-555} (lambda ()
                                                                                                         (raise-syntax-error
                                                                                                           #f
                                                                                                           "Bad syntax; invalid syntax-case clause"
                                                                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-553}))])
                                                           (if (stx-pair?
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
                                                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-556} (syntax-e
                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                                                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-557} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-556})]
                                                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-558} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-556})])
                                                                   (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-557}])
                                                                     (if (stx-pair?
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-558})
                                                                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-559} (syntax-e
                                                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-558})])
                                                                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-560} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-559})]
                                                                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-561} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-559})])
                                                                             (let ([fender #{csc-h dpuuv4a3mobea70icwo8nvdax-560}])
                                                                               (if (stx-pair?
                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-561})
                                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-562} (syntax-e
                                                                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-561})])
                                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-563} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-562})]
                                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-564} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-562})])
                                                                                       (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-563}])
                                                                                         (if (stx-null?
                                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-564})
                                                                                             (generate1
                                                                                               hd
                                                                                               fender
                                                                                               body)
                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-555})))))
                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-555}))))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-553})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-565} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-553})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-566} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-565})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-567} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-565})])
                   (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-566}])
                     (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-567})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-568} (syntax-e
                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-567})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-569} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-568})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-570} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-568})])
                             (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-569}])
                               (if (stx-null?
                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-570})
                                   (generate1 hd #t body)
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-554})))))
     (define (generate-match where target hd mvars K E)
       (define (BUG q)
         (error 'gerbil "BUG: syntax-case; generate" stx hd q))
       (define (recur e vars target E k)
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-571} e])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-571})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-572} (car #{match-val dpuuv4a3mobea70icwo8nvdax-571})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-573} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-571})])
                 (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-572}])
                   (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-573}])
                     (begin
                       (case tag
                         [(any) (k vars)]
                         [(id)
                          (core-list
                            'if
                            (core-list 'identifier? target)
                            (core-list
                              'if
                              (core-list
                                identifier=?
                                (core-list wrap-e body)
                                target)
                              (k vars)
                              E)
                            E)]
                         [(var) (k (cons (cons body target) vars))]
                         [(cons)
                          (let ([$e (genident 'e)]
                                [$hd (genident 'hd)]
                                [$tl (genident 'tl)])
                            (core-list
                              'if
                              (core-list 'stx-pair? target)
                              (core-list
                                'let-values
                                (list
                                  (list
                                    (list $e)
                                    (core-list unwrap-e target)))
                                (core-list
                                  'let-values
                                  (list
                                    (list
                                      (list $hd)
                                      (core-list '\x23;\x23;car $e))
                                    (list
                                      (list $tl)
                                      (core-list '\x23;\x23;cdr $e)))
                                  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-574} body])
                                    (if (pair?
                                          #{match-val dpuuv4a3mobea70icwo8nvdax-574})
                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-575} (car #{match-val dpuuv4a3mobea70icwo8nvdax-574})]
                                              [#{tl dpuuv4a3mobea70icwo8nvdax-576} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-574})])
                                          (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-575}])
                                            (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-576}])
                                              (begin
                                                (recur hd vars $hd E
                                                  (lambda (vars)
                                                    (recur tl vars $tl E
                                                      k)))))))
                                        (error 'match
                                          "no matching clause"
                                          #{match-val dpuuv4a3mobea70icwo8nvdax-574})))))
                              E))]
                         [(splice)
                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-577} body])
                            (if (pair?
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-577})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-578} (car #{match-val dpuuv4a3mobea70icwo8nvdax-577})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-579} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-577})])
                                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-578}])
                                    (let ([tl #{tl dpuuv4a3mobea70icwo8nvdax-579}])
                                      (begin
                                        (let* ([rlen (splice-rlen tl)])
                                          (let* ([$target (genident
                                                            'target)])
                                            (let* ([$hd (genident 'hd)])
                                              (let* ([$tl (genident 'tl)])
                                                (let* ([$lp (genident
                                                              'loop)])
                                                  (let* ([$lp-e (genident
                                                                  'e)])
                                                    (let* ([$lp-hd (genident
                                                                     'lp-hd)])
                                                      (let* ([$lp-tl (genident
                                                                       'lp-tl)])
                                                        (let* ([svars (splice-vars
                                                                        hd)])
                                                          (let* ([lvars (gentemps
                                                                          svars)])
                                                            (let* ([tlvars (gentemps
                                                                             svars)])
                                                              (let* ([linit (map (lambda (var)
                                                                                   (core-list
                                                                                     'quote
                                                                                     (list)))
                                                                                 lvars)])
                                                                (define (make-loop
                                                                         vars)
                                                                  (core-list
                                                                    'letrec-values
                                                                    (list
                                                                      (list
                                                                        (list
                                                                          $lp)
                                                                        (core-list
                                                                          'lambda%
                                                                          (cons
                                                                            $hd
                                                                            lvars)
                                                                          (core-list
                                                                            'if
                                                                            (core-list
                                                                              'stx-pair?
                                                                              $hd)
                                                                            (core-list
                                                                              'let-values
                                                                              (list
                                                                                (list
                                                                                  (list
                                                                                    $lp-e)
                                                                                  (core-list
                                                                                    unwrap-e
                                                                                    $hd)))
                                                                              (core-list
                                                                                'let-values
                                                                                (list
                                                                                  (list
                                                                                    (list
                                                                                      $lp-hd)
                                                                                    (core-list
                                                                                      '\x23;\x23;car
                                                                                      $lp-e))
                                                                                  (list
                                                                                    (list
                                                                                      $lp-tl)
                                                                                    (core-list
                                                                                      '\x23;\x23;cdr
                                                                                      $lp-e)))
                                                                                (recur
                                                                                  hd
                                                                                  (list)
                                                                                  $lp-hd
                                                                                  E
                                                                                  (lambda (hdvars)
                                                                                    (cons*
                                                                                      $lp
                                                                                      $lp-tl
                                                                                      (map (lambda (svar
                                                                                                    lvar)
                                                                                             (core-list
                                                                                               'cons
                                                                                               (agetq
                                                                                                 svar
                                                                                                 hdvars
                                                                                                 BUG)
                                                                                               lvar))
                                                                                           svars
                                                                                           lvars))))))
                                                                            (core-list
                                                                              'let-values
                                                                              (map (lambda (lvar
                                                                                            tlvar)
                                                                                     (list
                                                                                       (list
                                                                                         tlvar)
                                                                                       (core-list
                                                                                         'reverse
                                                                                         lvar)))
                                                                                   lvars
                                                                                   tlvars)
                                                                              (k (let ([#{f dpuuv4a3mobea70icwo8nvdax-580} (lambda (svar
                                                                                                                                    tlvar
                                                                                                                                    r)
                                                                                                                             (cons
                                                                                                                               (cons
                                                                                                                                 svar
                                                                                                                                 tlvar)
                                                                                                                               r))])
                                                                                   (fold-left
                                                                                     (lambda (#{a dpuuv4a3mobea70icwo8nvdax-581}
                                                                                              #{e dpuuv4a3mobea70icwo8nvdax-582})
                                                                                       (#{f dpuuv4a3mobea70icwo8nvdax-580}
                                                                                         #{e dpuuv4a3mobea70icwo8nvdax-582}
                                                                                         #{a dpuuv4a3mobea70icwo8nvdax-581}))
                                                                                     vars
                                                                                     svars))))))))
                                                                    (cons*
                                                                      $lp
                                                                      $target
                                                                      linit)))
                                                                (let ([body (core-list
                                                                              'let-values
                                                                              (list
                                                                                (list
                                                                                  (list
                                                                                    $target
                                                                                    $tl)
                                                                                  (core-list
                                                                                    'syntax-split-splice
                                                                                    target
                                                                                    rlen)))
                                                                              (recur
                                                                                tl
                                                                                vars
                                                                                $tl
                                                                                E
                                                                                make-loop))])
                                                                  (core-list
                                                                    'if
                                                                    (core-list
                                                                      'stx-pair/null?
                                                                      target)
                                                                    (if (zero?
                                                                          rlen)
                                                                        body
                                                                        (core-list
                                                                          'if
                                                                          (core-list
                                                                            'fx>=
                                                                            (core-list
                                                                              'stx-length
                                                                              target)
                                                                            rlen)
                                                                          body
                                                                          E))
                                                                    E))))))))))))))))))
                                (error 'match
                                  "no matching clause"
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-577})))]
                         [(null)
                          (core-list
                            'if
                            (core-list 'stx-null? target)
                            (k vars)
                            E)]
                         [(vector)
                          (let ([$e (genident 'e)])
                            (core-list
                              'if
                              (core-list 'stx-vector? target)
                              (core-list
                                'let-values
                                (list
                                  (list
                                    (list $e)
                                    (core-list
                                      'vector->list
                                      (core-list unwrap-e target))))
                                (recur body vars $e E k))
                              E))]
                         [(box)
                          (let ([$e (genident 'e)])
                            (core-list
                              'if
                              (core-list 'stx-box? target)
                              (core-list
                                'let-values
                                (list
                                  (list
                                    (list $e)
                                    (core-list
                                      'unbox
                                      (core-list unwrap-e target))))
                                (recur body vars $e E k))
                              E))]
                         [(datum)
                          (let ([$e (genident 'e)])
                            (core-list
                              'if
                              (core-list 'stx-datum? target)
                              (core-list
                                'let-values
                                (list
                                  (list
                                    (list $e)
                                    (core-list 'stx-e target)))
                                (core-list
                                  'if
                                  (core-list 'equal? $e body)
                                  (k vars)
                                  E))
                              E))]
                         [else (BUG e)])))))
               (error 'match
                 "no matching clause"
                 #{match-val dpuuv4a3mobea70icwo8nvdax-571}))))
       (define (splice-rlen e)
         (let lp ([e e] [n 0])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-583} e])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-583})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-584} (car #{match-val dpuuv4a3mobea70icwo8nvdax-583})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-585} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-583})])
                   (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-584}])
                     (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-585}])
                       (begin
                         (case tag
                           [(splice)
                            (raise-syntax-error
                              #f
                              "Ambiguous pattern"
                              stx
                              where)]
                           [(cons) (lp (cdr body) (fx1+ n))]
                           [else n])))))
                 (error 'match
                   "no matching clause"
                   #{match-val dpuuv4a3mobea70icwo8nvdax-583})))))
       (define (splice-vars e)
         (let recur ([e e] [vars (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-586} e])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-586})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-587} (car #{match-val dpuuv4a3mobea70icwo8nvdax-586})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-588} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-586})])
                   (let ([tag #{hd dpuuv4a3mobea70icwo8nvdax-587}])
                     (let ([body #{tl dpuuv4a3mobea70icwo8nvdax-588}])
                       (begin
                         (case tag
                           [(var) (cons body vars)]
                           [(cons splice)
                            (recur (cdr body) (recur (car body) vars))]
                           [(vector box) (recur body vars)]
                           [else vars])))))
                 (error 'match
                   "no matching clause"
                   #{match-val dpuuv4a3mobea70icwo8nvdax-586})))))
       (define (make-body vars)
         (cons
           K
           (map (lambda (mvar) (agetq (car mvar) vars BUG)) mvars)))
       (recur hd (list) target E make-body))
     (define (parse-clause hd ids)
       (let recur ([e hd] [vars (list)] [depth 0])
         (cond
           [(identifier? e)
            (cond
              [(underscore? e) (values '(any) vars)]
              [(ellipsis? e)
               (raise-syntax-error #f "Misplaced ellipsis" stx hd)]
              [(find (lambda (id) (bound-identifier=? e id)) ids)
               (values (cons 'id e) vars)]
              [(find (lambda (var) (bound-identifier=? e (car var))) vars)
               (raise-syntax-error #f "Duplicate pattern variable" stx e)]
              [else (values (cons 'var e) (cons (cons e depth) vars))])]
           [(stx-pair? e)
            (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-589} e])
              (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-590} (lambda ()
                                                              (raise-syntax-error
                                                                #f
                                                                "Bad syntax; invalid syntax-case clause"
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-589}))])
                (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-589})
                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-591} (syntax-e
                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-589})])
                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-592} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-591})]
                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-593} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-591})])
                        (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-592}])
                          (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-593}])
                            (let ([make-pair (lambda (tag hd tl)
                                               (let*-values ([(hd-depth)
                                                              (if (eq? tag
                                                                       'splice)
                                                                  (fx1+
                                                                    depth)
                                                                  depth)]
                                                             [(hd vars)
                                                              (recur
                                                                hd
                                                                vars
                                                                hd-depth)]
                                                             [(tl vars)
                                                              (recur
                                                                tl
                                                                vars
                                                                depth)])
                                                 (values
                                                   (cons* tag hd tl)
                                                   vars)))])
                              (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-594} rest])
                                (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-595} (lambda ()
                                                                                (make-pair
                                                                                  'cons
                                                                                  hd
                                                                                  rest))])
                                  (if (stx-pair?
                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-594})
                                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-596} (syntax-e
                                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-594})])
                                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-597} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-596})]
                                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-598} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-596})])
                                          (let ([rest-hd #{csc-h dpuuv4a3mobea70icwo8nvdax-597}])
                                            (let ([rest-tl #{csc-t dpuuv4a3mobea70icwo8nvdax-598}])
                                              (if (ellipsis? rest-hd)
                                                  (make-pair
                                                    'splice
                                                    hd
                                                    rest-tl)
                                                  (make-pair
                                                    'cons
                                                    hd
                                                    rest))))))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-595})))))))))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-590}))))]
           [(stx-null? e) (values '(null) vars)]
           [(stx-vector? e)
            (let-values ([(e vars)
                          (recur (vector->list (syntax-e e)) vars depth)])
              (values (cons 'vector e) vars))]
           [(stx-box? e)
            (let-values ([(e vars)
                          (recur (unbox (syntax-e e)) vars depth)])
              (values (cons 'box e) vars))]
           [(stx-datum? e) (values (cons 'datum (stx-e e)) vars)]
           [else (raise-syntax-error #f "Bad pattern" stx e)])))
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-599} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-600} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; invalid syntax-case clause"
                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-599}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-599})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-601} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-599})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-602} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-601})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-603} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-601})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-603})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-604} (syntax-e
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-603})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-605} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-604})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-606} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-604})])
                         (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-605}])
                           (if (stx-pair?
                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-606})
                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-607} (syntax-e
                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-606})])
                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-608} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-607})]
                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-609} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-607})])
                                   (let ([ids #{csc-h dpuuv4a3mobea70icwo8nvdax-608}])
                                     (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-609}])
                                       (cond
                                         [(not (identifier-list? ids))
                                          (raise-syntax-error
                                            #f
                                            "Bad template identifier list"
                                            stx
                                            ids)]
                                         [(not (stx-list? clauses))
                                          (raise-syntax-error
                                            #f
                                            "Bad syntax; clauses expected"
                                            stx)]
                                         [else
                                          (let* ([ids (syntax->list ids)])
                                            (let* ([clauses (syntax->list
                                                              clauses)])
                                              (let* ([clause-ids (gentemps
                                                                   clauses)])
                                                (let* ([E (genident)])
                                                  (let* ([target (genident)])
                                                    (let* ([first (if (null?
                                                                        clauses)
                                                                      E
                                                                      (car clause-ids))])
                                                      (stx-wrap-source
                                                        (core-list
                                                          'begin-annotation
                                                          '\x40;syntax-case
                                                          (stx-wrap-source
                                                            (core-list
                                                              'let-values
                                                              (list
                                                                (list
                                                                  (list E)
                                                                  (core-list
                                                                    'lambda%
                                                                    (list
                                                                      target)
                                                                    (core-list
                                                                      'raise-syntax-error
                                                                      #f
                                                                      "Bad syntax; invalid match target"
                                                                      target))))
                                                              (generate-body
                                                                (generate-bindings target
                                                                  ids
                                                                  clauses
                                                                  clause-ids
                                                                  E)
                                                                (list
                                                                  first
                                                                  expr)))
                                                            (stx-source
                                                              stx)))
                                                        (stx-source
                                                          stx))))))))])))))
                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-600})))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-600}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-600}))))]))

(define (syntax-local-pattern? stx)
  (and (identifier? stx)
       (syntax-pattern? (syntax-local-e stx false))))

(define (syntax-check-splice-targets hd . rest)
  (let ([len (length hd)])
    (let lp ([rest rest])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-610} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-610})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-611} (car #{match-val dpuuv4a3mobea70icwo8nvdax-610})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-612} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-610})])
              (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-611}])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-612}])
                  (begin
                    (if (fx= len (length hd))
                        (lp rest)
                        (raise-syntax-error
                          #f
                          "Splice length mismatch"
                          hd))))))
            (begin (void)))))))

(define (syntax-split-splice stx n)
  (let lp ([rest stx] [r (list)])
    (if (stx-pair? rest)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-613} (syntax-e
                                                            rest)])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-613})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-614} (car #{match-val dpuuv4a3mobea70icwo8nvdax-613})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-615} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-613})])
                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-614}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-615}])
                    (begin (lp rest (cons hd r))))))
              (error 'match
                "no matching clause"
                #{match-val dpuuv4a3mobea70icwo8nvdax-613})))
        (let lp ([n n] [l r] [r rest])
          (cond
            [(null? l) (values l r)]
            [(fxpositive? n) (lp (fx1- n) (cdr l) (cons (car l) r))]
            [else (values (reverse! l) r)])))))

(define (syntax-split-splice->vector stx n)
  (let lp ([rest stx] [r (list)])
    (if (stx-pair? rest)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-616} (syntax-e
                                                            rest)])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-616})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-617} (car #{match-val dpuuv4a3mobea70icwo8nvdax-616})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-618} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-616})])
                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-617}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-618}])
                    (begin (lp rest (cons hd r))))))
              (error 'match
                "no matching clause"
                #{match-val dpuuv4a3mobea70icwo8nvdax-616})))
        (let lp ([n n] [l r] [r rest])
          (cond
            [(null? l) (vector l r)]
            [(fxpositive? n) (lp (fx1- n) (cdr l) (cons (car l) r))]
            [else (vector (reverse! l) r)])))))

(define-syntax syntax-split-splice*
  (syntax-rules ()
    [(syntax-split-splice* stx n return)
     (let lp ([rest stx] [r (\x40;list)])
       (if (stx-pair? rest)
           (match (syntax-e rest)
             [(\x40;list hd . rest) (lp rest (cons hd r))])
           (let lp ([n n] [l r] [r rest])
             (cond
               [(null? l) (return l r)]
               [(fxpositive? n) (lp (fx1- n) (cdr l) (cons (car l) r))]
               [else (return (reverse! l) r)]))))]))

