(defcompile-method (apply-collect-mutators)
 (::collect-mutators ::void) () 'final:
 (%\x23;begin apply-begin%)
 (%\x23;begin-syntax apply-begin-syntax%)
 (%\x23;begin-annotation apply-begin-annotation%)
 (%\x23;module apply-module%)
 (%\x23;define-values apply-define-values%)
 (%\x23;define-syntax apply-define-syntax%)
 (%\x23;lambda apply-body-lambda%)
 (%\x23;case-lambda apply-body-case-lambda%)
 (%\x23;let-values apply-body-let-values%)
 (%\x23;letrec-values apply-body-let-values%)
 (%\x23;letrec*-values apply-body-let-values%)
 (%\x23;call apply-operands)
 (%\x23;call-unchecked apply-operands)
 (%\x23;if apply-operands)
 (%\x23;set! collect-mutators-setq%)
 (%\x23;struct-instance? apply-operands)
 (%\x23;struct-direct-instance? apply-operands)
 (%\x23;struct-ref apply-operands)
 (%\x23;struct-set! apply-operands)
 (%\x23;struct-direct-ref apply-operands)
 (%\x23;struct-direct-set! apply-operands)
 (%\x23;struct-unchecked-ref apply-operands)
 (%\x23;struct-unchecked-set! apply-operands))

(defcompile-method (apply-expression-subst 'id: id 'new-id: new-id)
  (::expression-subst ::basic-xform-expression) (id new-id)
  'final: (%\x23;begin xform-begin%)
  (%\x23;ref expression-subst-ref%)
  (%\x23;set! expression-subst-setq%))

(defcompile-method (apply-expression-subst* 'subst: subst)
  (::expression-subst* ::basic-xform-expression) (subst)
  'final: (%\x23;begin xform-begin%)
  (%\x23;ref expression-subst*-ref%)
  (%\x23;set! expression-subst*-setq%))

(defcompile-method #f (::find-expression ::false-expression)
 () (%\x23;begin find-body%)
 (%\x23;begin-annotation apply-begin-annotation%)
 (%\x23;lambda apply-body-lambda%)
 (%\x23;case-lambda apply-body-case-lambda%)
 (%\x23;let-values find-let-values%)
 (%\x23;letrec-values find-let-values%)
 (%\x23;letrec*-values find-let-values%)
 (%\x23;call find-body%) (%\x23;call-unchecked find-body%)
 (%\x23;if find-body%) (%\x23;set! apply-body-setq%)
 (%\x23;struct-instance? find-body%)
 (%\x23;struct-direct-instance? find-body%)
 (%\x23;struct-ref find-body%) (%\x23;struct-set! find-body%)
 (%\x23;struct-direct-ref find-body%)
 (%\x23;struct-direct-set! find-body%)
 (%\x23;struct-unchecked-ref find-body%)
 (%\x23;struct-unchecked-set! find-body%))

(defcompile-method (apply-find-var-refs 'ids: ids)
  (::find-var-refs ::find-expression) (ids) 'final:
  (%\x23;ref find-var-refs-ref%)
  (%\x23;set! find-var-refs-setq%))

(defcompile-method (apply-collect-runtime-refs 'table: table)
  (::collect-runtime-refs ::collect-expression-refs) ()
  'final: (%\x23;ref collect-runtime-refs-ref%)
  (%\x23;set! collect-runtime-refs-setq%))

(define (collect-mutators-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3572} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3573} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3572}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3572})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3574} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3572})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3575} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3574})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3576} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3574})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3576})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3577} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3576})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3578} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3577})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3579} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3577})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3578}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3579})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3580} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3579})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3581} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3580})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3582} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3580})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3581}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3582}))
                                (let ([sym (identifier-symbol #'id)])
                                  (verbose "collect mutator " sym)
                                  (hash-put!
                                    (current-compile-mutators)
                                    sym
                                    #t)
                                  (compile-e self #'expr))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3573}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3573}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3573})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3573})))))

(define (expression-subst-ref% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3583} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3584} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3583}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3583})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3585} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3583})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3586} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3585})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3587} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3585})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3587})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3588} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3587})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3589} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3588})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3590} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3588})])
                  (let ([xid #{ehd dpuuv4a3mobea70icwo8nvdax-3589}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-3590}))
                        (if (free-identifier=? #'xid (slot-ref self 'id))
                            (xform-wrap-source
                              (list '%\x23;ref (slot-ref self 'new-id))
                              stx)
                            stx)
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3584}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3584})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3584})))))

(define (expression-subst*-ref% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3591} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3592} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3591}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3591})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3593} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3591})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3594} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3593})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3595} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3593})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3595})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3596} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3595})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3597} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3596})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3598} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3596})])
                  (let ([xid #{ehd dpuuv4a3mobea70icwo8nvdax-3597}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-3598}))
                        (cond
                          [(find
                             (lambda (sub)
                               (free-identifier=? #'xid (car sub)))
                             (slot-ref self 'subst)) =>
                           (lambda (sub)
                             (xform-wrap-source
                               (list '%\x23;ref (cdr sub))
                               stx))]
                          [else stx])
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3592}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3592})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3592})))))

(define (expression-subst-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3599} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3600} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3599}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3599})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3601} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3599})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3602} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3601})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3603} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3601})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3603})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3604} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3603})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3605} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3604})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3606} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3604})])
                  (let ([xid #{ehd dpuuv4a3mobea70icwo8nvdax-3605}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3606})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3607} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3606})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3608} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3607})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3609} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3607})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3608}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3609}))
                                (let ([new-expr (compile-e self #'expr)]
                                      [new-xid (if (free-identifier=?
                                                     #'xid
                                                     (slot-ref self 'id))
                                                   (slot-ref self 'new-id)
                                                   #'xid)])
                                  (xform-wrap-source
                                    (list '%\x23;set! new-xid new-expr)
                                    stx))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3600}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3600}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3600})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3600})))))

(define (expression-subst*-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3610} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3611} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3610}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3610})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3612} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3610})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3613} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3612})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3614} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3612})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3614})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3615} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3614})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3616} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3615})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3617} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3615})])
                  (let ([xid #{ehd dpuuv4a3mobea70icwo8nvdax-3616}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3617})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3618} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3617})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3619} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3618})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3620} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3618})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3619}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3620}))
                                (let ([new-expr (compile-e self #'expr)]
                                      [new-xid (cond
                                                 [(find
                                                    (lambda (sub)
                                                      (free-identifier=?
                                                        #'xid
                                                        (car sub)))
                                                    (slot-ref self 'subst)) =>
                                                  cdr]
                                                 [else #'xid])])
                                  (xform-wrap-source
                                    (list '%\x23;set! new-xid new-expr)
                                    stx))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3611}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3611}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3611})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3611})))))

(define (collect-runtime-refs-ref% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3621} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3622} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3621}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3621})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3623} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3621})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3624} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3623})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3625} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3623})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3625})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3626} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3625})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3627} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3626})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3628} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3626})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3627}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-3628}))
                        (let ([eid (identifier-symbol #'id)])
                          (hash-update!
                            (slot-ref self 'table)
                            eid
                            \x31;+
                            0))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3622}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3622})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3622})))))

(define (collect-runtime-refs-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3629} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3630} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3629}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3629})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3631} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3629})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3632} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3631})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3633} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3631})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3633})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3634} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3633})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3635} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3634})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3636} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3634})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3635}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3636})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3637} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3636})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3638} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3637})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3639} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3637})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3638}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3639}))
                                (let ([eid (identifier-symbol #'id)])
                                  (hash-update!
                                    (slot-ref self 'table)
                                    eid
                                    \x31;+
                                    0)
                                  (compile-e self #'expr))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3630}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3630}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3630})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3630})))))

(define (find-body% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3640} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3641} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3640}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3640})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3642} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3640})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3643} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3642})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3644} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3642})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3644})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3645} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3644})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3646} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3645})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3647} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3645})])
                  (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3646}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3647})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3648} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3647})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3649} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3648})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3650} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3648})])
                          (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3649}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3650}))
                                (ormap
                                  (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3651})
                                    (compile-e
                                      self
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-3651}))
                                  #'(expr ...))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3641}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3641}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3641})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3641})))))

(define (find-let-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3652} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3653} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3652}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3652})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3654} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3652})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3655} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3654})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3656} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3654})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3656})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3657} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3656})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3658} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3657})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3659} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3657})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-3658})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3660} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-3658})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-3661} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3660})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-3662} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3660})])
                        (if (__AST-pair?
                              #{ehd dpuuv4a3mobea70icwo8nvdax-3661})
                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3663} (__AST-e
                                                                             #{ehd dpuuv4a3mobea70icwo8nvdax-3661})]
                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-3664} (\x23;\x23;car
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3663})]
                                   [#{etl dpuuv4a3mobea70icwo8nvdax-3665} (\x23;\x23;cdr
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3663})])
                              (let ([bind #{ehd dpuuv4a3mobea70icwo8nvdax-3664}])
                                (if (__AST-pair?
                                      #{etl dpuuv4a3mobea70icwo8nvdax-3665})
                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3666} (__AST-e
                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-3665})]
                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-3667} (\x23;\x23;car
                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-3666})]
                                           [#{etl dpuuv4a3mobea70icwo8nvdax-3668} (\x23;\x23;cdr
                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-3666})])
                                      (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3667}])
                                        (if (null?
                                              (__AST-e
                                                #{etl dpuuv4a3mobea70icwo8nvdax-3668}))
                                            (if (__AST-pair?
                                                  #{etl dpuuv4a3mobea70icwo8nvdax-3662})
                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3669} (__AST-e
                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3662})]
                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3670} (\x23;\x23;car
                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3669})]
                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-3671} (\x23;\x23;cdr
                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3669})])
                                                  (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3670}])
                                                    (if (null?
                                                          (__AST-e
                                                            #{etl dpuuv4a3mobea70icwo8nvdax-3671}))
                                                        (if (__AST-pair?
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-3659})
                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3672} (__AST-e
                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-3659})]
                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-3673} (\x23;\x23;car
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3672})]
                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-3674} (\x23;\x23;cdr
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3672})])
                                                              (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-3673}])
                                                                (if (null?
                                                                      (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-3674}))
                                                                    (or (ormap
                                                                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3675})
                                                                            (compile-e
                                                                              self
                                                                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-3675}))
                                                                          #'(expr
                                                                              ...))
                                                                        (compile-e
                                                                          self
                                                                          #'body))
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))
                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))))
                                                (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))))
                                    (#{fail dpuuv4a3mobea70icwo8nvdax-3653}))))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-3653})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-3653})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3653})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3653})))))

(define (find-var-refs-ref% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3676} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3677} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3676}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3676})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3678} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3676})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3679} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3678})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3680} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3678})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3680})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3681} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3680})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3682} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3681})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3683} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3681})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3682}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-3683}))
                        (find
                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3684})
                            (free-identifier=?
                              #'id
                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-3684}))
                          (slot-ref self 'ids))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3677}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3677})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3677})))))

(define (find-var-refs-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3685} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3686} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3685}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3685})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3687} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3685})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3688} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3687})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3689} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3687})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3689})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3690} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3689})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3691} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3690})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3692} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3690})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3691}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3692})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3693} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3692})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3694} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3693})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3695} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3693})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3694}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3695}))
                                (or (find
                                      (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3696})
                                        (free-identifier=?
                                          #'id
                                          #{cut-arg dpuuv4a3mobea70icwo8nvdax-3696}))
                                      (slot-ref self 'ids))
                                    (compile-e self #'expr))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3686}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3686}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3686})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3686})))))

