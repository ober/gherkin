(begin
  (define (make-promise thunk)
    (\x23;\x23;make-delay-promise thunk))
  (define __make-promise make-promise))

(begin
  (define (make-atomic-promise thunk)
    (let ([mx (make-mutex 'promise)]
          [inner (make-promise thunk)])
      (make-promise
        (lambda ()
          (let ([once (vector 0)])
            (dynamic-wind
              (lambda ()
                (unless (\x23;\x23;fx=
                          (\x23;\x23;vector-cas! once 0 1 0)
                          0)
                  (error 'gerbil "Cannot reenter atomic block"))
                (mutex-lock! mx))
              (lambda () (\x23;\x23;force-out-of-line inner))
              (lambda () (mutex-unlock! mx))))))))
  (define __make-atomic-promise make-atomic-promise))

(define call-with-parameters
  (case-lambda
    [(thunk) (thunk)]
    [(thunk param val)
     (\x23;\x23;parameterize1 param val thunk)]
    [(thunk param val . rest)
     (call-with-parameters
       (lambda () (apply call-with-parameters thunk rest))
       param
       val)]))

(begin
  (define (with-unwind-protect K fini)
    (let ([once (vector 0)])
      (dynamic-wind
        (lambda ()
          (unless (\x23;\x23;fx= (\x23;\x23;vector-cas! once 0 1 0) 0)
            (error 'gerbil "Cannot re-enter unwind protected block")))
        K
        fini)))
  (define __with-unwind-protect with-unwind-protect))

(define (keyword-dispatch kwt K . all-args)
  (when kwt
    (unless (vector? kwt)
      (error 'gerbil "keyword-dispatch: expected vector" kwt)))
  (unless (procedure? K)
    (error 'gerbil "keyword-dispatch: expected procedure" K))
  (let ([keys (make-symbolic-table #f 0)])
    (let lp ([rest all-args] [args #f] [tail #f])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-96} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-96})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-97} (car #{match-val dpuuv4a3mobea70icwo8nvdax-96})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-98} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-96})])
              (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-97}])
                (let ([hd-rest #{tl dpuuv4a3mobea70icwo8nvdax-98}])
                  (begin
                    (cond
                      [(keyword? hd)
                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-99} hd-rest])
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-99})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-100} (car #{match-val dpuuv4a3mobea70icwo8nvdax-99})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-101} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-99})])
                               (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-100}])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-101}])
                                   (begin
                                     (when kwt
                                       (let ([pos (\x23;\x23;fxmodulo
                                                    (\x23;\x23;keyword-hash
                                                      hd)
                                                    (\x23;\x23;vector-length
                                                      kwt))])
                                         (unless (eq? hd
                                                      (\x23;\x23;vector-ref
                                                        kwt
                                                        pos))
                                           (error 'gerbil
                                             "Unexpected keyword argument"
                                             K
                                             hd))))
                                     (unless (eq? (symbolic-table-ref
                                                    keys
                                                    hd
                                                    absent-value)
                                                  absent-value)
                                       (error 'gerbil
                                         "Duplicate keyword argument"
                                         K
                                         hd))
                                     (symbolic-table-set! keys hd val)
                                     (lp rest args tail)))))
                             (error 'match
                               "no matching clause"
                               #{match-val dpuuv4a3mobea70icwo8nvdax-99})))]
                      [(eq? hd 'key:)
                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-102} hd-rest])
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-102})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-103} (car #{match-val dpuuv4a3mobea70icwo8nvdax-102})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-104} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-102})])
                               (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-103}])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-104}])
                                   (begin
                                     (if args
                                         (begin
                                           (\x23;\x23;set-cdr!
                                             tail
                                             hd-rest)
                                           (lp rest args hd-rest))
                                         (lp rest hd-rest hd-rest))))))
                             (error 'match
                               "no matching clause"
                               #{match-val dpuuv4a3mobea70icwo8nvdax-102})))]
                      [(eq? hd 'rest:)
                       (if args
                           (begin
                             (\x23;\x23;set-cdr! tail hd-rest)
                             (\x23;\x23;apply K (cons keys args)))
                           (\x23;\x23;apply K (cons keys hd-rest)))]
                      [else
                       (if args
                           (begin
                             (\x23;\x23;set-cdr! tail rest)
                             (lp hd-rest args rest))
                           (lp hd-rest rest rest))])))))
            (begin
              (if args
                  (begin
                    (\x23;\x23;set-cdr! tail (list))
                    (\x23;\x23;apply K (cons keys args)))
                  (K keys))))))))

(define (keyword-rest kwt . drop)
  (let ([rest (list)])
    (raw-table-for-each
      kwt
      (lambda (k v)
        (unless (memq k drop) (set! rest (cons* k v rest)))))
    rest))

