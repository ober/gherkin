(defcompile-method (apply-optimize-call) (::optimize-call ::basic-xform) ()
  'final: (%\x23;call optimize-call%) (%\x23;if optimize-if%))

(defcompile-method (apply-check-return-type) (::check-return-type ::void) ()
  'final: (%\x23;begin apply-begin%)
  (%\x23;begin-syntax apply-begin-syntax%)
  (%\x23;begin-annotation
    apply-check-return-type-begin-annotation%)
  (%\x23;module apply-module%)
  (%\x23;define-values apply-define-values%)
  (%\x23;define-syntax apply-define-syntax%)
  (%\x23;lambda apply-body-lambda%)
  (%\x23;case-lambda apply-body-case-lambda%)
  (%\x23;let-values apply-body-let-values%)
  (%\x23;letrec-values apply-body-let-values%)
  (%\x23;letrec*-values apply-body-let-values%)
  (%\x23;call apply-operands) (%\x23;if apply-path-type-if%)
  (%\x23;set! apply-body-setq%))

(define (optimize-call% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5707} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5708} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5709} (lambda ()
                                                                                                    (__raise-syntax-error
                                                                                                      #f
                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-5707}))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5707})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5710} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5707})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5711} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5710})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5712} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5710})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5712})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5713} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5712})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5714} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5713})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5715} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5713})])
                                                                  (let ([rator #{ehd dpuuv4a3mobea70icwo8nvdax-5714}])
                                                                    (if (__AST-pair?
                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5715})
                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5716} (__AST-e
                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5715})]
                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5717} (\x23;\x23;car
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5716})]
                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5718} (\x23;\x23;cdr
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5716})])
                                                                          (let ([rand #{ehd dpuuv4a3mobea70icwo8nvdax-5717}])
                                                                            (if (__AST-pair?
                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5718})
                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5719} (__AST-e
                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5718})]
                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5720} (\x23;\x23;car
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5719})]
                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5721} (\x23;\x23;cdr
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5719})])
                                                                                  (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-5720}])
                                                                                    (if (null?
                                                                                          (__AST-e
                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5721}))
                                                                                        (let ([rator-type (apply-basic-expression-type
                                                                                                            #'rator)])
                                                                                          (cond
                                                                                            [(and rator-type
                                                                                                  (eq? (!type-id
                                                                                                         rator-type)
                                                                                                       'procedure)
                                                                                                  (not (!primitive?
                                                                                                         rator-type))
                                                                                                  (not (and (!procedure?
                                                                                                              rator-type)
                                                                                                            (eq? (!procedure-origin
                                                                                                                   rator-type)
                                                                                                                 (expander-context-id
                                                                                                                   (current-expander-context))))))
                                                                                             (xform-wrap-source
                                                                                               (cons*
                                                                                                 '%\x23;call-unchecked
                                                                                                 (compile-e
                                                                                                   self
                                                                                                   #'rator)
                                                                                                 (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5722})
                                                                                                        (compile-e
                                                                                                          self
                                                                                                          #{cut-arg dpuuv4a3mobea70icwo8nvdax-5722}))
                                                                                                      #'(rand
                                                                                                          ...)))
                                                                                               stx)]
                                                                                            [(or (not rator-type)
                                                                                                 (memq
                                                                                                   (!type-id
                                                                                                     rator-type)
                                                                                                   '(t procedure)))
                                                                                             (xform-call%
                                                                                               self
                                                                                               stx)]
                                                                                            [else
                                                                                             (raise-compile-error
                                                                                               "illegal application; not a procedure"
                                                                                               stx
                                                                                               rator-type)]))
                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5709}))))
                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5709}))))
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5709}))))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5709})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5709}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5707})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5723} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5707})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5724} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5723})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-5725} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5723})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-5725})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5726} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5725})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5727} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5726})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-5728} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5726})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-5727})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5729} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5727})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5730} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5729})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-5731} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5729})])
                        (if (and (__AST-id?
                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5730})
                                 (eq? (__AST-e
                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5730})
                                      '%\x23;ref))
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-5731})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5732} (__AST-e
                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5731})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5733} (\x23;\x23;car
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5732})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5734} (\x23;\x23;cdr
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5732})])
                                  (let ([rator #{ehd dpuuv4a3mobea70icwo8nvdax-5733}])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-5734}))
                                        (if (__AST-pair?
                                              #{etl dpuuv4a3mobea70icwo8nvdax-5728})
                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5735} (__AST-e
                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5728})]
                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5736} (\x23;\x23;car
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5735})]
                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5737} (\x23;\x23;cdr
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5735})])
                                              (let ([rand #{ehd dpuuv4a3mobea70icwo8nvdax-5736}])
                                                (if (__AST-pair?
                                                      #{etl dpuuv4a3mobea70icwo8nvdax-5737})
                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5738} (__AST-e
                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5737})]
                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5739} (\x23;\x23;car
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5738})]
                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-5740} (\x23;\x23;cdr
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5738})])
                                                      (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-5739}])
                                                        (if (null?
                                                              (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-5740}))
                                                            (let* ([rator-id (identifier-symbol
                                                                               #'rator)])
                                                              (let* ([rator-type (optimizer-resolve-type
                                                                                   rator-id)])
                                                                (cond
                                                                  [(or (not rator-type)
                                                                       (eq? (!type-id
                                                                              rator-type)
                                                                            't))
                                                                   (xform-call%
                                                                     self
                                                                     stx)]
                                                                  [(!procedure?
                                                                     rator-type)
                                                                   (verbose
                                                                     "optimize-call "
                                                                     rator-id
                                                                     " => "
                                                                     rator-type
                                                                     " "
                                                                     (!type-id
                                                                       rator-type))
                                                                   (let ([optimized (call-method
                                                                                      self
                                                                                      'rator-type.optimize-call
                                                                                      stx
                                                                                      #'(rand
                                                                                          ...))])
                                                                     (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5741} optimized])
                                                                       (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5742} (lambda ()
                                                                                                                       (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5743} (lambda ()
                                                                                                                                                                       (__raise-syntax-error
                                                                                                                                                                         #f
                                                                                                                                                                         "Bad syntax; malformed ast clause"
                                                                                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-5741}))])
                                                                                                                         optimized))])
                                                                         (if (__AST-pair?
                                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-5741})
                                                                             (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5744} (__AST-e
                                                                                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-5741})]
                                                                                    [#{ehd dpuuv4a3mobea70icwo8nvdax-5745} (\x23;\x23;car
                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-5744})]
                                                                                    [#{etl dpuuv4a3mobea70icwo8nvdax-5746} (\x23;\x23;cdr
                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-5744})])
                                                                               (if (and (__AST-id?
                                                                                          #{ehd dpuuv4a3mobea70icwo8nvdax-5745})
                                                                                        (eq? (__AST-e
                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-5745})
                                                                                             '%\x23;call))
                                                                                   (if (__AST-pair?
                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5746})
                                                                                       (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5747} (__AST-e
                                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-5746})]
                                                                                              [#{ehd dpuuv4a3mobea70icwo8nvdax-5748} (\x23;\x23;car
                                                                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-5747})]
                                                                                              [#{etl dpuuv4a3mobea70icwo8nvdax-5749} (\x23;\x23;cdr
                                                                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-5747})])
                                                                                         (if (__AST-pair?
                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-5748})
                                                                                             (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5750} (__AST-e
                                                                                                                                              #{ehd dpuuv4a3mobea70icwo8nvdax-5748})]
                                                                                                    [#{ehd dpuuv4a3mobea70icwo8nvdax-5751} (\x23;\x23;car
                                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-5750})]
                                                                                                    [#{etl dpuuv4a3mobea70icwo8nvdax-5752} (\x23;\x23;cdr
                                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-5750})])
                                                                                               (if (and (__AST-id?
                                                                                                          #{ehd dpuuv4a3mobea70icwo8nvdax-5751})
                                                                                                        (eq? (__AST-e
                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-5751})
                                                                                                             '%\x23;ref))
                                                                                                   (if (__AST-pair?
                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5752})
                                                                                                       (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5753} (__AST-e
                                                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-5752})]
                                                                                                              [#{ehd dpuuv4a3mobea70icwo8nvdax-5754} (\x23;\x23;car
                                                                                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-5753})]
                                                                                                              [#{etl dpuuv4a3mobea70icwo8nvdax-5755} (\x23;\x23;cdr
                                                                                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-5753})])
                                                                                                         (let ([optimized-rator #{ehd dpuuv4a3mobea70icwo8nvdax-5754}])
                                                                                                           (if (null?
                                                                                                                 (__AST-e
                                                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-5755}))
                                                                                                               (if (__AST-pair?
                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5749})
                                                                                                                   (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5756} (__AST-e
                                                                                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-5749})]
                                                                                                                          [#{ehd dpuuv4a3mobea70icwo8nvdax-5757} (\x23;\x23;car
                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-5756})]
                                                                                                                          [#{etl dpuuv4a3mobea70icwo8nvdax-5758} (\x23;\x23;cdr
                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-5756})])
                                                                                                                     (let ([arg #{ehd dpuuv4a3mobea70icwo8nvdax-5757}])
                                                                                                                       (if (__AST-pair?
                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5758})
                                                                                                                           (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5759} (__AST-e
                                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5758})]
                                                                                                                                  [#{ehd dpuuv4a3mobea70icwo8nvdax-5760} (\x23;\x23;car
                                                                                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-5759})]
                                                                                                                                  [#{etl dpuuv4a3mobea70icwo8nvdax-5761} (\x23;\x23;cdr
                                                                                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-5759})])
                                                                                                                             (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-5760}])
                                                                                                                               (if (null?
                                                                                                                                     (__AST-e
                                                                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-5761}))
                                                                                                                                   (let* ([optimized-rator-id (identifier-symbol
                                                                                                                                                                #'optimized-rator)])
                                                                                                                                     (let* ([rator-type (or (optimizer-lookup-type
                                                                                                                                                              optimized-rator-id)
                                                                                                                                                            rator-type)])
                                                                                                                                       (if (or (!primitive?
                                                                                                                                                 rator-type)
                                                                                                                                               (memq
                                                                                                                                                 optimized-rator-id
                                                                                                                                                 checked-primitives)
                                                                                                                                               (and (!procedure?
                                                                                                                                                      rator-type)
                                                                                                                                                    (eq? (!procedure-origin
                                                                                                                                                           rator-type)
                                                                                                                                                         (expander-context-id
                                                                                                                                                           (current-expander-context)))))
                                                                                                                                           optimized
                                                                                                                                           (xform-wrap-source
                                                                                                                                             (cons*
                                                                                                                                               '%\x23;call-unchecked
                                                                                                                                               #'(%\x23;ref
                                                                                                                                                   optimized-rator)
                                                                                                                                               #'(arg ...))
                                                                                                                                             stx))))
                                                                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))))
                                                                                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))))
                                                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))
                                                                                                               (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))))
                                                                                                       (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))
                                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-5742})))
                                                                                             (#{fail dpuuv4a3mobea70icwo8nvdax-5742})))
                                                                                       (#{fail dpuuv4a3mobea70icwo8nvdax-5742}))
                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-5742})))
                                                                             (#{fail dpuuv4a3mobea70icwo8nvdax-5742})))))]
                                                                  [(and (!class?
                                                                          rator-type)
                                                                        (eq? (&!type-id
                                                                               rator-type)
                                                                             'procedure))
                                                                   (xform-wrap-source
                                                                     (cons*
                                                                       '%\x23;call-unchecked
                                                                       #'(%\x23;ref
                                                                           rator)
                                                                       (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5762})
                                                                              (compile-e
                                                                                self
                                                                                #{cut-arg dpuuv4a3mobea70icwo8nvdax-5762}))
                                                                            #'(rand
                                                                                ...)))
                                                                     stx)]
                                                                  [else
                                                                   (raise-compile-error
                                                                     "illegal application; not a procedure"
                                                                     stx
                                                                     rator-type)])))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5708}))))
                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5708}))))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5708}))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5708}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-5708}))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-5708})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-5708})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5708})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-5708})))))

(begin
  (define !procedure::optimize-call
    (lambda (self ctx stx args)
      (if (call-method ctx 'self.check-arguments stx args)
          (let ([signature !signature])
            (cond
              [(and signature (slot-ref signature 'unchecked)) =>
               (lambda (unchecked)
                 (if (symbol-in-local-scope? unchecked)
                     (xform-wrap-apply
                       (cons*
                         '%\x23;call
                         (list '%\x23;ref unchecked)
                         (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5763})
                                (compile-e
                                  ctx
                                  #{cut-arg dpuuv4a3mobea70icwo8nvdax-5763}))
                              args))
                       stx
                       ctx)
                     (xform-call% ctx stx)))]
              [else (xform-call% ctx stx)]))
          (xform-call% ctx stx))))
  (bind-method!
    !procedure::t
    'optimize-call
    !procedure::optimize-call))

(begin
  (define !procedure::check-arguments
    (lambda (self ctx stx args)
      (let ([((signature self.signature)) (let ([((argument-types
                                                    (!signature-arguments
                                                      signature))) (begin
                                                                     (let ([argument-types (map*
                                                                                             (lambda (t)
                                                                                               (and t
                                                                                                    (optimizer-resolve-class
                                                                                                      stx
                                                                                                      t)))
                                                                                             argument-types)])
                                                                       (let loop ([rest-args args]
                                                                                  [rest-types argument-types]
                                                                                  [result #t])
                                                                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-5764} rest-args])
                                                                           (if (pair?
                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-5764})
                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5765} (car #{match-val dpuuv4a3mobea70icwo8nvdax-5764})]
                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-5766} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-5764})])
                                                                                 (let ([arg #{hd dpuuv4a3mobea70icwo8nvdax-5765}])
                                                                                   (let ([rest-args #{tl dpuuv4a3mobea70icwo8nvdax-5766}])
                                                                                     (begin
                                                                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-5767} rest-types])
                                                                                         (if (pair?
                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-5767})
                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5768} (car #{match-val dpuuv4a3mobea70icwo8nvdax-5767})]
                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-5769} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-5767})])
                                                                                               (let ([type #{hd dpuuv4a3mobea70icwo8nvdax-5768}])
                                                                                                 (let ([rest-types #{tl dpuuv4a3mobea70icwo8nvdax-5769}])
                                                                                                   (begin
                                                                                                     (loop
                                                                                                       rest-args
                                                                                                       rest-types
                                                                                                       (and (check-expression-type!
                                                                                                              stx
                                                                                                              arg
                                                                                                              type)
                                                                                                            result))))))
                                                                                             (if (null?
                                                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-5767})
                                                                                                 (begin
                                                                                                   (raise-compile-error
                                                                                                     "signature arity mismatch"
                                                                                                     stx
                                                                                                     argument-types))
                                                                                                 (let ([tail-type #{match-val dpuuv4a3mobea70icwo8nvdax-5767}])
                                                                                                   (and (andmap
                                                                                                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5770})
                                                                                                            (check-expression-type!
                                                                                                              stx
                                                                                                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-5770}
                                                                                                              tail-type))
                                                                                                          rest-args)
                                                                                                        result)))))))))
                                                                               (begin
                                                                                 result))))))])
                                            (and ((argument-types
                                                    (!signature-arguments
                                                      signature)))
                                                 (begin)))])
        (and ((signature self.signature)) (begin)))))
  (bind-method!
    !procedure::t
    'check-arguments
    !procedure::check-arguments))

(begin
  (define !primitive-predicate::optimize-call
    (lambda (self ctx stx args)
      (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5771} args])
        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5772} (lambda ()
                                                        (__raise-syntax-error
                                                          #f
                                                          "Bad syntax; malformed ast clause"
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-5771}))])
          (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5771})
              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5773} (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-5771})]
                     [#{ehd dpuuv4a3mobea70icwo8nvdax-5774} (\x23;\x23;car
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-5773})]
                     [#{etl dpuuv4a3mobea70icwo8nvdax-5775} (\x23;\x23;cdr
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-5773})])
                (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-5774}])
                  (if (null?
                        (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-5775}))
                      (let* ([klass (optimizer-resolve-class
                                      stx
                                      (slot-ref self 'id))])
                        (let* ([object (compile-e ctx #'expr)])
                          (let* ([instance? (or (expression-type?
                                                  object
                                                  klass)
                                                (expression-type?
                                                  #'expr
                                                  klass))])
                            (if instance?
                                (xform-wrap-source
                                  (if (or (expression-no-side-effects?
                                            object)
                                          (expression-no-side-effects?
                                            #'expr))
                                      (list '%\x23;quote #t)
                                      (list '%\x23;begin object #t))
                                  stx)
                                (xform-call% ctx stx)))))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-5772}))))
              (#{fail dpuuv4a3mobea70icwo8nvdax-5772}))))))
  (bind-method!
    !primitive-predicate::t
    'optimize-call
    !primitive-predicate::optimize-call))

(begin
  (define !predicate::optimize-call
    (lambda (self ctx stx args)
      (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5776} args])
        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5777} (lambda ()
                                                        (__raise-syntax-error
                                                          #f
                                                          "Bad syntax; malformed ast clause"
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-5776}))])
          (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5776})
              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5778} (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-5776})]
                     [#{ehd dpuuv4a3mobea70icwo8nvdax-5779} (\x23;\x23;car
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-5778})]
                     [#{etl dpuuv4a3mobea70icwo8nvdax-5780} (\x23;\x23;cdr
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-5778})])
                (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-5779}])
                  (if (null?
                        (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-5780}))
                      (let* ([klass (optimizer-resolve-class
                                      stx
                                      (slot-ref self 'id))])
                        (let* ([object (compile-e ctx #'expr)])
                          (let* ([instance? (or (expression-type?
                                                  object
                                                  klass)
                                                (expression-type?
                                                  #'expr
                                                  klass))])
                            (let ([klass klass])
                              (cond
                                [instance?
                                 (xform-wrap-source
                                   (if (or (expression-no-side-effects?
                                             object)
                                           (expression-no-side-effects?
                                             #'expr))
                                       (list '%\x23;quote #t)
                                       (list '%\x23;begin object #t))
                                   stx)]
                                [(slot-ref klass 'final?)
                                 (xform-wrap-source
                                   (list
                                     '%\x23;struct-direct-instance?
                                     (list
                                       '%\x23;quote
                                       (slot-ref klass 'id))
                                     object)
                                   stx)]
                                [(slot-ref klass 'struct?)
                                 (xform-wrap-source
                                   (list
                                     '%\x23;struct-instance?
                                     (list
                                       '%\x23;quote
                                       (slot-ref klass 'id))
                                     object)
                                   stx)]
                                [else
                                 (xform-wrap-source
                                   (list
                                     '%\x23;call
                                     (list '%\x23;ref 'class-instance?)
                                     (list '%\x23;ref (slot-ref self 'id))
                                     object)
                                   stx)])))))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-5777}))))
              (#{fail dpuuv4a3mobea70icwo8nvdax-5777}))))))
  (bind-method!
    !predicate::t
    'optimize-call
    !predicate::optimize-call))

(define (expression-no-side-effects? stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5781} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5782} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5783} (lambda ()
                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5784} (lambda ()
                                                                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5785} (lambda ()
                                                                                                                                                                                                    (__raise-syntax-error
                                                                                                                                                                                                      #f
                                                                                                                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-5781}))])
                                                                                                                                                      #f))])
                                                                                                      (if (__AST-pair?
                                                                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})
                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5786} (__AST-e
                                                                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})]
                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5787} (\x23;\x23;car
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5786})]
                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5788} (\x23;\x23;cdr
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5786})])
                                                                                                            (if (and (__AST-id?
                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5787})
                                                                                                                     (eq? (__AST-e
                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-5787})
                                                                                                                          '%\x23;call))
                                                                                                                (if (__AST-pair?
                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-5788})
                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5789} (__AST-e
                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5788})]
                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5790} (\x23;\x23;car
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5789})]
                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-5791} (\x23;\x23;cdr
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5789})])
                                                                                                                      (if (__AST-pair?
                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-5790})
                                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5792} (__AST-e
                                                                                                                                                                           #{ehd dpuuv4a3mobea70icwo8nvdax-5790})]
                                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5793} (\x23;\x23;car
                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5792})]
                                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5794} (\x23;\x23;cdr
                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5792})])
                                                                                                                            (if (and (__AST-id?
                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5793})
                                                                                                                                     (eq? (__AST-e
                                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-5793})
                                                                                                                                          '%\x23;ref))
                                                                                                                                (if (__AST-pair?
                                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-5794})
                                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5795} (__AST-e
                                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5794})]
                                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5796} (\x23;\x23;car
                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5795})]
                                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-5797} (\x23;\x23;cdr
                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5795})])
                                                                                                                                      (let ([rator #{ehd dpuuv4a3mobea70icwo8nvdax-5796}])
                                                                                                                                        (if (null?
                                                                                                                                              (__AST-e
                                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-5797}))
                                                                                                                                            (if (__AST-pair?
                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5791})
                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5798} (__AST-e
                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5791})]
                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5799} (\x23;\x23;car
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5798})]
                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5800} (\x23;\x23;cdr
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5798})])
                                                                                                                                                  (let ([rand #{ehd dpuuv4a3mobea70icwo8nvdax-5799}])
                                                                                                                                                    (if (__AST-pair?
                                                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5800})
                                                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5801} (__AST-e
                                                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5800})]
                                                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5802} (\x23;\x23;car
                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5801})]
                                                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5803} (\x23;\x23;cdr
                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5801})])
                                                                                                                                                          (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-5802}])
                                                                                                                                                            (if (null?
                                                                                                                                                                  (__AST-e
                                                                                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-5803}))
                                                                                                                                                                (let ([((rator-type
                                                                                                                                                                          (optimizer-resolve-type
                                                                                                                                                                            (identifier-symbol
                                                                                                                                                                              #'rator)))) (let ([((rator-signature
                                                                                                                                                                                                    (and (!procedure?
                                                                                                                                                                                                           rator-type)
                                                                                                                                                                                                         (&!procedure-signature
                                                                                                                                                                                                           rator-type)))) (let ([((rator-effect
                                                                                                                                                                                                                                    (and rator-signature
                                                                                                                                                                                                                                         (!signature-effect
                                                                                                                                                                                                                                           rator-signature)))) (begin
                                                                                                                                                                                                                                                                 (and (or (equal?
                                                                                                                                                                                                                                                                            '(pure)
                                                                                                                                                                                                                                                                            rator-effect)
                                                                                                                                                                                                                                                                          (equal?
                                                                                                                                                                                                                                                                            '(alloc)
                                                                                                                                                                                                                                                                            rator-effect))
                                                                                                                                                                                                                                                                      (andmap
                                                                                                                                                                                                                                                                        expression-no-side-effects?
                                                                                                                                                                                                                                                                        #'(rand
                                                                                                                                                                                                                                                                            ...))))])
                                                                                                                                                                                                                            (and ((rator-effect
                                                                                                                                                                                                                                    (and rator-signature
                                                                                                                                                                                                                                         (!signature-effect
                                                                                                                                                                                                                                           rator-signature))))
                                                                                                                                                                                                                                 (begin)))])
                                                                                                                                                                                            (and ((rator-signature
                                                                                                                                                                                                    (and (!procedure?
                                                                                                                                                                                                           rator-type)
                                                                                                                                                                                                         (&!procedure-signature
                                                                                                                                                                                                           rator-type))))
                                                                                                                                                                                                 (begin)))])
                                                                                                                                                                  (and ((rator-type
                                                                                                                                                                          (optimizer-resolve-type
                                                                                                                                                                            (identifier-symbol
                                                                                                                                                                              #'rator))))
                                                                                                                                                                       (begin)))
                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))))
                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))))
                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))
                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))))
                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))
                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5784})))
                                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5784})))
                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))
                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5784})))
                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5784}))))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5804} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5805} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5804})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5806} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5804})])
                                                            (if (and (__AST-id?
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5805})
                                                                     (eq? (__AST-e
                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-5805})
                                                                          '%\x23;ref))
                                                                (if (__AST-pair?
                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-5806})
                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5807} (__AST-e
                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5806})]
                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5808} (\x23;\x23;car
                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5807})]
                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-5809} (\x23;\x23;cdr
                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5807})])
                                                                      (if (null?
                                                                            (__AST-e
                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5809}))
                                                                          #t
                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5783})))
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5783}))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5783})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5783}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5810} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5781})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5811} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5810})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-5812} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5810})])
            (if (and (__AST-id? #{ehd dpuuv4a3mobea70icwo8nvdax-5811})
                     (eq? (__AST-e #{ehd dpuuv4a3mobea70icwo8nvdax-5811})
                          '%\x23;quote))
                (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-5812})
                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5813} (__AST-e
                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5812})]
                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5814} (\x23;\x23;car
                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5813})]
                           [#{etl dpuuv4a3mobea70icwo8nvdax-5815} (\x23;\x23;cdr
                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5813})])
                      (if (null?
                            (__AST-e
                              #{etl dpuuv4a3mobea70icwo8nvdax-5815}))
                          #t
                          (#{fail dpuuv4a3mobea70icwo8nvdax-5782})))
                    (#{fail dpuuv4a3mobea70icwo8nvdax-5782}))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5782})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-5782})))))

(define (expression-type? stx klass)
  (let ([expr-type (apply-basic-expression-type stx)])
    (and expr-type (!type-subtype? expr-type klass))))

(define (check-expression-type! stx expr type)
  (cond
    [(not type) #f]
    [(eq? (!type-id type) 't)]
    [else
     (let ([expr-type (apply-basic-expression-type expr)])
       (cond
         [(not expr-type) #f]
         [(eq? 't (!type-id expr-type)) #f]
         [(!abort? expr-type)]
         [(!type-subtype? expr-type type)]
         [(!interface-instance? type) #f]
         [(!type-subtype? type expr-type) #f]
         [else
          (raise-compile-error "signature type mismatch" stx expr
            expr-type type)]))]))

(begin
  (define !constructor::optimize-call
    (lambda (self ctx stx args)
      (let* ([klass (optimizer-resolve-class
                      stx
                      (slot-ref self 'id))])
        (let* ([fields (length (!class-fields klass))])
          (let* ([args (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5816})
                              (compile-e
                                ctx
                                #{cut-arg dpuuv4a3mobea70icwo8nvdax-5816}))
                            args)])
            (let* ([inline-make-object (list
                                         '%\x23;begin-annotation
                                         (list
                                           '\x40;type
                                           (slot-ref self 'id))
                                         (cons*
                                           '%\x23;call
                                           (list
                                             '%\x23;ref
                                             '\x23;\x23;structure)
                                           (list
                                             '%\x23;ref
                                             (slot-ref self 'id))
                                           (make-list
                                             fields
                                             '(%\x23;quote #f))))])
              (let ([klass klass])
                (cond
                  [(slot-ref klass 'constructor) =>
                   (lambda (ctor)
                     (let ([$obj (make-symbol (gensym "__obj"))]
                           [ctor-impl (!class-lookup-method klass ctor)])
                       (xform-wrap-source
                         (list
                           '%\x23;let-values
                           (list (list (list $obj) inline-make-object))
                           (list
                             '%\x23;begin
                             (if ctor-impl
                                 (xform-wrap-apply
                                   (cons*
                                     '%\x23;call
                                     (list '%\x23;ref ctor-impl)
                                     (list '%\x23;ref $obj)
                                     args)
                                   stx
                                   ctx)
                                 (let ([$ctor (make-symbol
                                                (gensym "__constructor"))])
                                   (list
                                     '%\x23;let-values
                                     (list
                                       (list
                                         (list $ctor)
                                         (list '%\x23;call
                                           (list
                                             '%\x23;ref
                                             'direct-method-ref)
                                           (list
                                             '%\x23;ref
                                             (slot-ref self 'id))
                                           (list '%\x23;ref $obj)
                                           (list '%\x23;quote ctor))))
                                     (list
                                       '%\x23;if
                                       (list '%\x23;ref $ctor)
                                       (cons*
                                         '%\x23;call
                                         (list '%\x23;ref $ctor)
                                         (list '%\x23;ref $obj)
                                         args)
                                       (list '%\x23;call
                                         (list '%\x23;ref 'error)
                                         (list
                                           '%\x23;quote
                                           "missing constructor method implementation")
                                         (list '%\x23;quote 'class:)
                                         (list
                                           '%\x23;ref
                                           (slot-ref self 'id))
                                         (list '%\x23;quote 'method:)
                                         (list '%\x23;quote ctor))))))
                             (list '%\x23;ref $obj)))
                         stx)))]
                  [(slot-ref klass 'metaclass) =>
                   (lambda (metaclass)
                     (let* ([$obj (make-symbol (gensym "__obj"))])
                       (let* ([metakons (!class-lookup-method
                                          (optimizer-resolve-class
                                            stx
                                            metaclass)
                                          'instance-init!)])
                         (xform-wrap-source
                           (list
                             '%\x23;let-values
                             (list (list (list $obj) inline-make-object))
                             (list
                               '%\x23;begin
                               (if metakons
                                   (xform-wrap-apply
                                     (cons* '%\x23;call
                                       (list '%\x23;ref metakons)
                                       (list
                                         '%\x23;ref
                                         (slot-ref self 'id))
                                       (list '%\x23;ref $obj) args)
                                     stx
                                     ctx)
                                   (cons* '%\x23;call
                                     (list '%\x23;ref 'call-method)
                                     (list '%\x23;ref (slot-ref self 'id))
                                     (list '%\x23;quote 'instance-init!)
                                     (list '%\x23;ref $obj) args))
                               (list '%\x23;ref $obj)))
                           stx))))]
                  [(slot-ref klass 'struct?)
                   (if (fx= (length args) fields)
                       (xform-wrap-source
                         (list
                           '%\x23;begin-annotation
                           (list '\x40;type (slot-ref self 'id))
                           (cons*
                             '%\x23;call
                             (list '%\x23;ref '\x23;\x23;structure)
                             (list '%\x23;ref (slot-ref self 'id))
                             args))
                         stx)
                       (raise-compile-error
                         "illegal struct constructor application; arity mismatch"
                         stx
                         (slot-ref self 'id)
                         (slot-ref klass 'fields)))]
                  [else
                   (let ([$obj (make-symbol (gensym "__obj"))])
                     (let lp ([rest args] [initializers (list)])
                       (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5817} rest])
                         (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5818} (lambda ()
                                                                         (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5819} (lambda ()
                                                                                                                         (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5820} (lambda ()
                                                                                                                                                                         (__raise-syntax-error
                                                                                                                                                                           #f
                                                                                                                                                                           "Bad syntax; malformed ast clause"
                                                                                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5817}))])
                                                                                                                           (xform-wrap-source
                                                                                                                             (list
                                                                                                                               '%\x23;let-values
                                                                                                                               (list
                                                                                                                                 (list
                                                                                                                                   (list
                                                                                                                                     $obj)
                                                                                                                                   inline-make-object))
                                                                                                                               (list
                                                                                                                                 '%\x23;begin
                                                                                                                                 (cons*
                                                                                                                                   '%\x23;call
                                                                                                                                   (list
                                                                                                                                     '%\x23;ref
                                                                                                                                     'class-instance-init!)
                                                                                                                                   (list
                                                                                                                                     '%\x23;ref
                                                                                                                                     $obj)
                                                                                                                                   args)
                                                                                                                                 (list
                                                                                                                                   '%\x23;ref
                                                                                                                                   $obj)))
                                                                                                                             stx)))])
                                                                           (if (null?
                                                                                 (__AST-e
                                                                                   #{ast-val dpuuv4a3mobea70icwo8nvdax-5817}))
                                                                               (xform-wrap-source
                                                                                 (list
                                                                                   '%\x23;let-values
                                                                                   (list
                                                                                     (list
                                                                                       (list
                                                                                         $obj)
                                                                                       inline-make-object))
                                                                                   (list
                                                                                     '%\x23;begin
                                                                                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-5821} (lambda (i
                                                                                                                                         r)
                                                                                                                                  (cons
                                                                                                                                    (list
                                                                                                                                      '%\x23;struct-unchecked-set!
                                                                                                                                      (list
                                                                                                                                        '%\x23;ref
                                                                                                                                        (slot-ref
                                                                                                                                          self
                                                                                                                                          'id))
                                                                                                                                      (list
                                                                                                                                        '%\x23;quote
                                                                                                                                        (car i))
                                                                                                                                      (list
                                                                                                                                        '%\x23;ref
                                                                                                                                        $obj)
                                                                                                                                      (cdr i))
                                                                                                                                    r))])
                                                                                       (fold-left
                                                                                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-5822}
                                                                                                  #{e dpuuv4a3mobea70icwo8nvdax-5823})
                                                                                           (#{f dpuuv4a3mobea70icwo8nvdax-5821}
                                                                                             #{e dpuuv4a3mobea70icwo8nvdax-5823}
                                                                                             #{a dpuuv4a3mobea70icwo8nvdax-5822}))
                                                                                         (list)
                                                                                         initializers))
                                                                                     ...
                                                                                     (list
                                                                                       '%\x23;ref
                                                                                       $obj)))
                                                                                 stx)
                                                                               (#{fail dpuuv4a3mobea70icwo8nvdax-5819}))))])
                           (if (__AST-pair?
                                 #{ast-val dpuuv4a3mobea70icwo8nvdax-5817})
                               (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5824} (__AST-e
                                                                                #{ast-val dpuuv4a3mobea70icwo8nvdax-5817})]
                                      [#{ehd dpuuv4a3mobea70icwo8nvdax-5825} (\x23;\x23;car
                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-5824})]
                                      [#{etl dpuuv4a3mobea70icwo8nvdax-5826} (\x23;\x23;cdr
                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-5824})])
                                 (if (__AST-pair?
                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5825})
                                     (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5827} (__AST-e
                                                                                      #{ehd dpuuv4a3mobea70icwo8nvdax-5825})]
                                            [#{ehd dpuuv4a3mobea70icwo8nvdax-5828} (\x23;\x23;car
                                                                                     #{etgt dpuuv4a3mobea70icwo8nvdax-5827})]
                                            [#{etl dpuuv4a3mobea70icwo8nvdax-5829} (\x23;\x23;cdr
                                                                                     #{etgt dpuuv4a3mobea70icwo8nvdax-5827})])
                                       (if (and (__AST-id?
                                                  #{ehd dpuuv4a3mobea70icwo8nvdax-5828})
                                                (eq? (__AST-e
                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5828})
                                                     '%\x23;quote))
                                           (if (__AST-pair?
                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5829})
                                               (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5830} (__AST-e
                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-5829})]
                                                      [#{ehd dpuuv4a3mobea70icwo8nvdax-5831} (\x23;\x23;car
                                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-5830})]
                                                      [#{etl dpuuv4a3mobea70icwo8nvdax-5832} (\x23;\x23;cdr
                                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-5830})])
                                                 (let ([kw #{ehd dpuuv4a3mobea70icwo8nvdax-5831}])
                                                   (if (null?
                                                         (__AST-e
                                                           #{etl dpuuv4a3mobea70icwo8nvdax-5832}))
                                                       (if (__AST-pair?
                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5826})
                                                           (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5833} (__AST-e
                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5826})]
                                                                  [#{ehd dpuuv4a3mobea70icwo8nvdax-5834} (\x23;\x23;car
                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-5833})]
                                                                  [#{etl dpuuv4a3mobea70icwo8nvdax-5835} (\x23;\x23;cdr
                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-5833})])
                                                             (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-5834}])
                                                               (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-5835}])
                                                                 (if (stx-keyword?
                                                                       #'kw)
                                                                     (let* ([slot (keyword->symbol
                                                                                    (stx-e
                                                                                      #'kw))])
                                                                       (let* ([off (!class-slot->field-offset
                                                                                     klass
                                                                                     slot)])
                                                                         (if off
                                                                             (lp #'rest
                                                                                 (cons
                                                                                   (cons
                                                                                     off
                                                                                     #'expr)
                                                                                   initializers))
                                                                             (raise-compile-error
                                                                               "unknown slot"
                                                                               stx
                                                                               (slot-ref
                                                                                 self
                                                                                 'id)
                                                                               slot))))
                                                                     (#{fail dpuuv4a3mobea70icwo8nvdax-5818})))))
                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-5818}))
                                                       (#{fail dpuuv4a3mobea70icwo8nvdax-5818}))))
                                               (#{fail dpuuv4a3mobea70icwo8nvdax-5818}))
                                           (#{fail dpuuv4a3mobea70icwo8nvdax-5818})))
                                     (#{fail dpuuv4a3mobea70icwo8nvdax-5818})))
                               (#{fail dpuuv4a3mobea70icwo8nvdax-5818}))))))]))))))))
  (bind-method!
    !constructor::t
    'optimize-call
    !constructor::optimize-call))

(begin
  (define !accessor::optimize-call
    (lambda (self ctx stx args)
      (let ([arguments-ok? (call-method
                             ctx
                             'self.check-arguments
                             stx
                             args)])
        (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5836} args])
          (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5837} (lambda ()
                                                          (__raise-syntax-error
                                                            #f
                                                            "Bad syntax; malformed ast clause"
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5836}))])
            (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5836})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5838} (__AST-e
                                                                 #{ast-val dpuuv4a3mobea70icwo8nvdax-5836})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5839} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5838})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-5840} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5838})])
                  (let ([object #{ehd dpuuv4a3mobea70icwo8nvdax-5839}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-5840}))
                        (let* ([klass (optimizer-resolve-class
                                        stx
                                        (slot-ref self 'id))])
                          (let* ([field (!class-slot->field-offset
                                          klass
                                          (slot-ref self 'slot))])
                            (let* ([object (compile-e ctx #'object)])
                              (let ([klass klass])
                                (cond
                                  [(slot-ref klass 'final?)
                                   (xform-wrap-source
                                     (list
                                       (if (or arguments-ok?
                                               (not (slot-ref
                                                      self
                                                      'checked?)))
                                           '%\x23;struct-unchecked-ref
                                           '%\x23;struct-direct-ref)
                                       (list
                                         '%\x23;ref
                                         (slot-ref self 'id))
                                       (list '%\x23;quote field)
                                       object)
                                     stx)]
                                  [(slot-ref klass 'struct?)
                                   (xform-wrap-source
                                     (list
                                       (if (or arguments-ok?
                                               (not (slot-ref
                                                      self
                                                      'checked?)))
                                           '%\x23;struct-unchecked-ref
                                           '%\x23;struct-ref)
                                       (list
                                         '%\x23;ref
                                         (slot-ref self 'id))
                                       (list '%\x23;quote field)
                                       object)
                                     stx)]
                                  [(!class-slot-find-struct
                                     klass
                                     (slot-ref self 'slot)) =>
                                   (lambda (klass)
                                     (xform-wrap-source
                                       (list
                                         (if (or arguments-ok?
                                                 (not (slot-ref
                                                        self
                                                        'checked?)))
                                             '%\x23;struct-unchecked-ref
                                             '%\x23;struct-ref)
                                         (list
                                           '%\x23;ref
                                           (slot-ref self 'id))
                                         (list '%\x23;quote field)
                                         object)
                                       stx))]
                                  [(slot-ref self 'checked?)
                                   (xform-wrap-source
                                     (let ([$obj (make-symbol
                                                   (gensym "__obj"))])
                                       (list
                                         '%\x23;let-values
                                         (list (list (list $obj) object))
                                         (list
                                           '%\x23;if
                                           (list
                                             '%\x23;struct-direct-instance?
                                             (list
                                               '%\x23;quote
                                               (slot-ref klass 'id))
                                             (list '%\x23;ref $obj))
                                           (list
                                             '%\x23;struct-unchecked-ref
                                             (list
                                               '%\x23;ref
                                               (slot-ref self 'id))
                                             (list '%\x23;quote field)
                                             (list '%\x23;ref $obj))
                                           (if arguments-ok?
                                               (list
                                                 '%\x23;call
                                                 (list
                                                   '%\x23;ref
                                                   'unchecked-slot-ref)
                                                 (list '%\x23;ref $obj)
                                                 (list
                                                   '%\x23;quote
                                                   (!accessor-slot self)))
                                               (list '%\x23;call
                                                 (list
                                                   '%\x23;ref
                                                   'class-slot-ref)
                                                 (list
                                                   '%\x23;ref
                                                   (slot-ref self 'id))
                                                 (list '%\x23;ref $obj)
                                                 (list
                                                   '%\x23;quote
                                                   (slot-ref
                                                     self
                                                     'slot)))))))
                                     stx)]
                                  [else
                                   (xform-wrap-source
                                     (list
                                       '%\x23;call
                                       (list
                                         '%\x23;ref
                                         'unchecked-slot-ref)
                                       object
                                       (list
                                         '%\x23;quote
                                         (slot-ref self 'slot)))
                                     stx)])))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-5837}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5837})))))))
  (bind-method!
    !accessor::t
    'optimize-call
    !accessor::optimize-call))

(begin
  (define !mutator::optimize-call
    (lambda (self ctx stx args)
      (let ([arguments-ok? (call-method
                             ctx
                             'self.check-arguments
                             stx
                             args)])
        (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5841} args])
          (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5842} (lambda ()
                                                          (__raise-syntax-error
                                                            #f
                                                            "Bad syntax; malformed ast clause"
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5841}))])
            (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5841})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5843} (__AST-e
                                                                 #{ast-val dpuuv4a3mobea70icwo8nvdax-5841})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5844} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5843})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-5845} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5843})])
                  (let ([object #{ehd dpuuv4a3mobea70icwo8nvdax-5844}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-5845})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5846} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5845})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5847} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5846})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-5848} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5846})])
                          (let ([value #{ehd dpuuv4a3mobea70icwo8nvdax-5847}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-5848}))
                                (let* ([klass (optimizer-resolve-class
                                                stx
                                                (slot-ref self 'id))])
                                  (let* ([field (!class-slot->field-offset
                                                  klass
                                                  (slot-ref self 'slot))])
                                    (let* ([object (compile-e
                                                     ctx
                                                     #'object)])
                                      (let* ([value (compile-e
                                                      ctx
                                                      #'value)])
                                        (let ([klass klass])
                                          (cond
                                            [(slot-ref klass 'final?)
                                             (xform-wrap-source
                                               (list
                                                 (if (or arguments-ok?
                                                         (not (slot-ref
                                                                self
                                                                'checked?)))
                                                     '%\x23;struct-unchecked-set!
                                                     '%\x23;struct-direct-set!)
                                                 (list
                                                   '%\x23;ref
                                                   (slot-ref self 'id))
                                                 (list '%\x23;quote field)
                                                 object value)
                                               stx)]
                                            [(slot-ref klass 'struct?)
                                             (xform-wrap-source
                                               (list
                                                 (if (or arguments-ok?
                                                         (not (slot-ref
                                                                self
                                                                'checked?)))
                                                     '%\x23;struct-unchecked-set!
                                                     '%\x23;struct-set!)
                                                 (list
                                                   '%\x23;ref
                                                   (slot-ref self 'id))
                                                 (list '%\x23;quote field)
                                                 object value)
                                               stx)]
                                            [(!class-slot-find-struct
                                               klass
                                               (slot-ref self 'slot)) =>
                                             (lambda (klass)
                                               (xform-wrap-source
                                                 (list
                                                   (if (or arguments-ok?
                                                           (not (slot-ref
                                                                  self
                                                                  'slot)))
                                                       '%\x23;struct-unchecked-set!
                                                       '%\x23;struct-set!)
                                                   (list
                                                     '%\x23;ref
                                                     (slot-ref self 'id))
                                                   (list
                                                     '%\x23;quote
                                                     field)
                                                   object value)
                                                 stx))]
                                            [(slot-ref self 'checked?)
                                             (xform-wrap-source
                                               (let ([$obj (make-symbol
                                                             (gensym
                                                               "__obj"))])
                                                 (list
                                                   '%\x23;let-values
                                                   (list
                                                     (list
                                                       (list $obj)
                                                       object))
                                                   (list
                                                     '%\x23;if
                                                     (list
                                                       '%\x23;struct-direct-instance?
                                                       (list
                                                         '%\x23;quote
                                                         (slot-ref
                                                           klass
                                                           'id))
                                                       (list
                                                         '%\x23;ref
                                                         $obj))
                                                     (list
                                                       '%\x23;struct-unchecked-set!
                                                       (list
                                                         '%\x23;ref
                                                         (slot-ref
                                                           self
                                                           'id))
                                                       (list
                                                         '%\x23;quote
                                                         field)
                                                       (list
                                                         '%\x23;ref
                                                         $obj)
                                                       value)
                                                     (if arguments-ok?
                                                         (list '%\x23;call
                                                           (list
                                                             '%\x23;ref
                                                             'unchecked-slot-set!)
                                                           (list
                                                             '%\x23;ref
                                                             $obj)
                                                           (list
                                                             '%\x23;quote
                                                             (slot-ref
                                                               self
                                                               'slot))
                                                           value)
                                                         (list '%\x23;call
                                                           (list
                                                             '%\x23;ref
                                                             'class-slot-set!)
                                                           (list
                                                             '%\x23;ref
                                                             (slot-ref
                                                               self
                                                               'id))
                                                           (list
                                                             '%\x23;ref
                                                             $obj)
                                                           (list
                                                             '%\x23;quote
                                                             (slot-ref
                                                               self
                                                               'slot))
                                                           value)))))
                                               stx)]
                                            [else
                                             (xform-wrap-source
                                               (list '%\x23;call
                                                 (list
                                                   '%\x23;ref
                                                   'unchecked-slot-set!)
                                                 object
                                                 (list
                                                   '%\x23;quote
                                                   (slot-ref self 'slot))
                                                 value)
                                               stx)]))))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-5842}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-5842}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5842})))))))
  (bind-method!
    !mutator::t
    'optimize-call
    !mutator::optimize-call))

(begin
  (define !lambda::optimize-call
    (lambda (self ctx stx args)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-5849} self])
        (let ([arity (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-5849}
                       3)]
              [dispatch (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-5849}
                          4)]
              [inline (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-5849}
                        5)])
          (unless (!lambda-arity-match? self args)
            (raise-compile-error
              "Illegal lambda application; arity mismatch"
              stx
              arity))
          (cond
            [inline
             (verbose "inline lambda")
             (xform-wrap-apply (inline stx) stx ctx)]
            [(and dispatch (symbol-in-local-scope? dispatch))
             (verbose "dispatch lambda => " dispatch)
             (xform-wrap-apply
               (cons* '%\x23;call (list '%\x23;ref dispatch) args)
               stx
               ctx)]
            [else (!procedure::optimize-call self ctx stx args)])))))
  (bind-method!
    !lambda::t
    'optimize-call
    !lambda::optimize-call))

(begin
  (define !case-lambda::optimize-call
    (lambda (self ctx stx args)
      (cond
        [(find
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-5850})
             (!lambda-arity-match?
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-5850}
               args))
           (slot-ref self 'clauses)) =>
         (lambda (clause)
           (call-method ctx 'clause.optimize-call stx args))]
        [else
         (raise-compile-error
           "Illegal case-lambda application; arity mismatch"
           stx
           (map !lambda-arity (slot-ref self 'clauses)))])))
  (bind-method!
    !case-lambda::t
    'optimize-call
    !case-lambda::optimize-call))

(begin
  (define !kw-lambda::optimize-call
    (lambda (self ctx stx args)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-5851} self])
        (let ([table (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-5851}
                       3)]
              [dispatch (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-5851}
                          4)])
          (if (symbol-in-local-scope? dispatch)
              (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-5852} (optimizer-lookup-type
                                                                   dispatch)])
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-5852})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5853} (car #{match-val dpuuv4a3mobea70icwo8nvdax-5852})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-5854} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-5852})])
                      (let ([!kw-lambda-primary #{hd dpuuv4a3mobea70icwo8nvdax-5853}])
                        (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-5854})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5855} (car #{tl dpuuv4a3mobea70icwo8nvdax-5854})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-5856} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-5854})])
                              (if (pair?
                                    #{tl dpuuv4a3mobea70icwo8nvdax-5856})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5857} (car #{tl dpuuv4a3mobea70icwo8nvdax-5856})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-5858} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-5856})])
                                    (if (pair?
                                          #{tl dpuuv4a3mobea70icwo8nvdax-5858})
                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5859} (car #{tl dpuuv4a3mobea70icwo8nvdax-5858})]
                                              [#{tl dpuuv4a3mobea70icwo8nvdax-5860} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-5858})])
                                          (let ([keys #{hd dpuuv4a3mobea70icwo8nvdax-5859}])
                                            (if (pair?
                                                  #{tl dpuuv4a3mobea70icwo8nvdax-5860})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-5861} (car #{tl dpuuv4a3mobea70icwo8nvdax-5860})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-5862} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-5860})])
                                                  (let ([main #{hd dpuuv4a3mobea70icwo8nvdax-5861}])
                                                    (if (null?
                                                          #{tl dpuuv4a3mobea70icwo8nvdax-5862})
                                                        (begin
                                                          (let ([values pargs]
                                                                [!kw-lambda-split-args stx])
                                                            (verbose
                                                              "dispatch kw-lambda => "
                                                              main)
                                                            (if table
                                                                (let ([xargs (map (lambda (key)
                                                                                    (cond
                                                                                      [(agetq
                                                                                         key
                                                                                         kwargs)]
                                                                                      [else
                                                                                       '(%\x23;ref
                                                                                          absent-value)]))
                                                                                  keys)])
                                                                  (for-each
                                                                    (lambda (kw)
                                                                      (unless (memq
                                                                                (car kw)
                                                                                keys)
                                                                        (raise-compile-error
                                                                          "Illegal keyword lambda application; unexpected keyword"
                                                                          stx
                                                                          keys
                                                                          kw)))
                                                                    kwargs)
                                                                  (xform-wrap-apply
                                                                    (cons*
                                                                      '%\x23;call
                                                                      (list
                                                                        '%\x23;ref
                                                                        main)
                                                                      (list
                                                                        '%\x23;quote
                                                                        #f)
                                                                      xargs
                                                                      ...
                                                                      pargs)
                                                                    stx
                                                                    ctx))
                                                                (let* ([kwt (make-symbol
                                                                              (gensym
                                                                                "__kwt"))])
                                                                  (let* ([kwvars (map (lambda (_)
                                                                                        (make-symbol
                                                                                          (gensym
                                                                                            "__kw")))
                                                                                      kwargs)])
                                                                    (let* ([kwbind (map (lambda (kw
                                                                                                 kwvar)
                                                                                          (list
                                                                                            (list
                                                                                              kwvar)
                                                                                            (cdr kw)))
                                                                                        kwargs
                                                                                        kwvars)])
                                                                      (let* ([kwset (map (lambda (kw
                                                                                                  kwvar)
                                                                                           (list
                                                                                             '%\x23;call
                                                                                             '(%\x23;ref
                                                                                                symbolic-table-set!)
                                                                                             (list
                                                                                               '%\x23;ref
                                                                                               kwt)
                                                                                             (list
                                                                                               '%\x23;quote
                                                                                               (car kw))
                                                                                             (list
                                                                                               '%\x23;ref
                                                                                               kwvar)))
                                                                                         kwargs
                                                                                         kwvars)])
                                                                        (let* ([xkwargs (map (lambda (kw
                                                                                                      kwvar)
                                                                                               (cons
                                                                                                 (car kw)
                                                                                                 (list
                                                                                                   '%\x23;ref
                                                                                                   kwvar)))
                                                                                             kwargs
                                                                                             kwvars)])
                                                                          (let* ([xargs (map (lambda (key)
                                                                                               (cond
                                                                                                 [(agetq
                                                                                                    key
                                                                                                    xkwargs)]
                                                                                                 [else
                                                                                                  '(%\x23;ref
                                                                                                     absent-value)]))
                                                                                             keys)])
                                                                            (xform-wrap-apply
                                                                              (list
                                                                                '%\x23;let-values
                                                                                kwbind
                                                                                (list
                                                                                  '%\x23;let-values
                                                                                  (list
                                                                                    (list
                                                                                      (list
                                                                                        kwt)
                                                                                      (xform-wrap-source
                                                                                        (list
                                                                                          '%\x23;call
                                                                                          '(%\x23;ref
                                                                                             make-symbolic-table)
                                                                                          (list
                                                                                            '%\x23;quote
                                                                                            (length
                                                                                              kwargs))
                                                                                          '(%\x23;quote
                                                                                             (length
                                                                                               kwvars)))
                                                                                        stx)))
                                                                                  (list
                                                                                    '%\x23;begin
                                                                                    kwset
                                                                                    ...
                                                                                    (xform-wrap-source
                                                                                      (cons*
                                                                                        '%\x23;call
                                                                                        (list
                                                                                          '%\x23;ref
                                                                                          main)
                                                                                        (list
                                                                                          '%\x23;ref
                                                                                          kwt)
                                                                                        xargs
                                                                                        ...
                                                                                        pargs)
                                                                                      stx))))
                                                                              stx
                                                                              ctx))))))))))
                                                        (begin
                                                          (verbose
                                                            "unknown keyword dispatch lambda "
                                                            dispatch)
                                                          (xform-call%
                                                            ctx
                                                            stx)))))
                                                (begin
                                                  (verbose
                                                    "unknown keyword dispatch lambda "
                                                    dispatch)
                                                  (xform-call% ctx stx)))))
                                        (begin
                                          (verbose
                                            "unknown keyword dispatch lambda "
                                            dispatch)
                                          (xform-call% ctx stx))))
                                  (begin
                                    (verbose
                                      "unknown keyword dispatch lambda "
                                      dispatch)
                                    (xform-call% ctx stx))))
                            (begin
                              (verbose
                                "unknown keyword dispatch lambda "
                                dispatch)
                              (xform-call% ctx stx)))))
                    (begin
                      (verbose "unknown keyword dispatch lambda " dispatch)
                      (xform-call% ctx stx))))
              (xform-call% ctx stx))))))
  (bind-method!
    !kw-lambda::t
    'optimize-call
    !kw-lambda::optimize-call))

(define (!kw-lambda-split-args stx args)
  (let lp ([rest args] [pargs (list)] [kwargs (list)])
    (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5863} rest])
      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5864} (lambda ()
                                                      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5865} (lambda ()
                                                                                                      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5866} (lambda ()
                                                                                                                                                      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5867} (lambda ()
                                                                                                                                                                                                      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5868} (lambda ()
                                                                                                                                                                                                                                                      (__raise-syntax-error
                                                                                                                                                                                                                                                        #f
                                                                                                                                                                                                                                                        "Bad syntax; malformed ast clause"
                                                                                                                                                                                                                                                        #{ast-val dpuuv4a3mobea70icwo8nvdax-5863}))])
                                                                                                                                                                                                        (values
                                                                                                                                                                                                          (reverse
                                                                                                                                                                                                            pargs)
                                                                                                                                                                                                          (reverse
                                                                                                                                                                                                            kwargs))))])
                                                                                                                                                        (if (__AST-pair?
                                                                                                                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})
                                                                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5869} (__AST-e
                                                                                                                                                                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})]
                                                                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5870} (\x23;\x23;car
                                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5869})]
                                                                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5871} (\x23;\x23;cdr
                                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5869})])
                                                                                                                                                              (let ([val #{ehd dpuuv4a3mobea70icwo8nvdax-5870}])
                                                                                                                                                                (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-5871}])
                                                                                                                                                                  (lp #'rest
                                                                                                                                                                      (cons
                                                                                                                                                                        #'val
                                                                                                                                                                        pargs)
                                                                                                                                                                      kwargs))))
                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5867}))))])
                                                                                                        (if (__AST-pair?
                                                                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})
                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5872} (__AST-e
                                                                                                                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})]
                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5873} (\x23;\x23;car
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5872})]
                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5874} (\x23;\x23;cdr
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5872})])
                                                                                                              (if (__AST-pair?
                                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-5873})
                                                                                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5875} (__AST-e
                                                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5873})]
                                                                                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-5876} (\x23;\x23;car
                                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5875})]
                                                                                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-5877} (\x23;\x23;cdr
                                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5875})])
                                                                                                                    (if (and (__AST-id?
                                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-5876})
                                                                                                                             (eq? (__AST-e
                                                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-5876})
                                                                                                                                  '%\x23;quote))
                                                                                                                        (if (__AST-pair?
                                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5877})
                                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5878} (__AST-e
                                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5877})]
                                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5879} (\x23;\x23;car
                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5878})]
                                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5880} (\x23;\x23;cdr
                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5878})])
                                                                                                                              (let ([kw #{ehd dpuuv4a3mobea70icwo8nvdax-5879}])
                                                                                                                                (if (null?
                                                                                                                                      (__AST-e
                                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-5880}))
                                                                                                                                    (if (__AST-pair?
                                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5874})
                                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5881} (__AST-e
                                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5874})]
                                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5882} (\x23;\x23;car
                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5881})]
                                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5883} (\x23;\x23;cdr
                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5881})])
                                                                                                                                          (let ([val #{ehd dpuuv4a3mobea70icwo8nvdax-5882}])
                                                                                                                                            (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-5883}])
                                                                                                                                              (if (stx-keyword?
                                                                                                                                                    #'kw)
                                                                                                                                                  (let ([kw (stx-e
                                                                                                                                                              #'kw)])
                                                                                                                                                    (if (assq
                                                                                                                                                          kw
                                                                                                                                                          kwargs)
                                                                                                                                                        (raise-compile-error
                                                                                                                                                          "Illegal keyword lambda application; duplicate keyword"
                                                                                                                                                          stx
                                                                                                                                                          kw)
                                                                                                                                                        (lp #'rest
                                                                                                                                                            pargs
                                                                                                                                                            (cons
                                                                                                                                                              (cons
                                                                                                                                                                kw
                                                                                                                                                                #'val)
                                                                                                                                                              kwargs))))
                                                                                                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5866})))))
                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5866}))
                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5866}))))
                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5866}))
                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5866})))
                                                                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5866})))
                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5866}))))])
                                                        (if (__AST-pair?
                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})
                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5884} (__AST-e
                                                                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})]
                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5885} (\x23;\x23;car
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5884})]
                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5886} (\x23;\x23;cdr
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5884})])
                                                              (if (__AST-pair?
                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-5885})
                                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5887} (__AST-e
                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5885})]
                                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-5888} (\x23;\x23;car
                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5887})]
                                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-5889} (\x23;\x23;cdr
                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5887})])
                                                                    (if (and (__AST-id?
                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-5888})
                                                                             (eq? (__AST-e
                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-5888})
                                                                                  '%\x23;quote))
                                                                        (if (__AST-pair?
                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5889})
                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5890} (__AST-e
                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5889})]
                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5891} (\x23;\x23;car
                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5890})]
                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5892} (\x23;\x23;cdr
                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5890})])
                                                                              (if (equal?
                                                                                    (__AST-e
                                                                                      #{ehd dpuuv4a3mobea70icwo8nvdax-5891})
                                                                                    'rest:)
                                                                                  (if (null?
                                                                                        (__AST-e
                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5892}))
                                                                                      (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-5886}])
                                                                                        (values
                                                                                          (let ([#{f dpuuv4a3mobea70icwo8nvdax-5893} cons])
                                                                                            (fold-left
                                                                                              (lambda (#{a dpuuv4a3mobea70icwo8nvdax-5894}
                                                                                                       #{e dpuuv4a3mobea70icwo8nvdax-5895})
                                                                                                (#{f dpuuv4a3mobea70icwo8nvdax-5893}
                                                                                                  #{e dpuuv4a3mobea70icwo8nvdax-5895}
                                                                                                  #{a dpuuv4a3mobea70icwo8nvdax-5894}))
                                                                                              #'rest
                                                                                              pargs))
                                                                                          (reverse
                                                                                            kwargs)))
                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5865}))
                                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5865})))
                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5865}))
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5865})))
                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5865})))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5865}))))])
        (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})
            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5896} (__AST-e
                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-5863})]
                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5897} (\x23;\x23;car
                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5896})]
                   [#{etl dpuuv4a3mobea70icwo8nvdax-5898} (\x23;\x23;cdr
                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5896})])
              (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-5897})
                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5899} (__AST-e
                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5897})]
                         [#{ehd dpuuv4a3mobea70icwo8nvdax-5900} (\x23;\x23;car
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5899})]
                         [#{etl dpuuv4a3mobea70icwo8nvdax-5901} (\x23;\x23;cdr
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-5899})])
                    (if (and (__AST-id?
                               #{ehd dpuuv4a3mobea70icwo8nvdax-5900})
                             (eq? (__AST-e
                                    #{ehd dpuuv4a3mobea70icwo8nvdax-5900})
                                  '%\x23;quote))
                        (if (__AST-pair?
                              #{etl dpuuv4a3mobea70icwo8nvdax-5901})
                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5902} (__AST-e
                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5901})]
                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5903} (\x23;\x23;car
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5902})]
                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5904} (\x23;\x23;cdr
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5902})])
                              (if (equal?
                                    (__AST-e
                                      #{ehd dpuuv4a3mobea70icwo8nvdax-5903})
                                    'key:)
                                  (if (null?
                                        (__AST-e
                                          #{etl dpuuv4a3mobea70icwo8nvdax-5904}))
                                      (if (__AST-pair?
                                            #{etl dpuuv4a3mobea70icwo8nvdax-5898})
                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5905} (__AST-e
                                                                                           #{etl dpuuv4a3mobea70icwo8nvdax-5898})]
                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5906} (\x23;\x23;car
                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5905})]
                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5907} (\x23;\x23;cdr
                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5905})])
                                            (let ([key #{ehd dpuuv4a3mobea70icwo8nvdax-5906}])
                                              (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-5907}])
                                                (lp #'rest
                                                    (cons #'key pargs)
                                                    kwargs))))
                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5864}))
                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5864}))
                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5864})))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-5864}))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-5864})))
                  (#{fail dpuuv4a3mobea70icwo8nvdax-5864})))
            (#{fail dpuuv4a3mobea70icwo8nvdax-5864}))))))

(begin
  (define !kw-lambda-primary::optimize-call
    (lambda (self ctx stx args) (xform-call% ctx stx)))
  (bind-method!
    !kw-lambda-primary::t
    'optimize-call
    !kw-lambda-primary::optimize-call))

(define (apply-check-return-type-begin-annotation% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5908} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5909} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5910} (lambda ()
                                                                                                    (__raise-syntax-error
                                                                                                      #f
                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-5908}))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5908})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5911} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5908})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5912} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5911})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5913} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5911})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5913})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5914} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5913})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5915} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5914})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5916} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5914})])
                                                                  (let ([ann #{ehd dpuuv4a3mobea70icwo8nvdax-5915}])
                                                                    (if (__AST-pair?
                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5916})
                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5917} (__AST-e
                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5916})]
                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5918} (\x23;\x23;car
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5917})]
                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5919} (\x23;\x23;cdr
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5917})])
                                                                          (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-5918}])
                                                                            (if (null?
                                                                                  (__AST-e
                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-5919}))
                                                                                (compile-e
                                                                                  self
                                                                                  #'body)
                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5910}))))
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5910}))))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5910})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5910}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5908})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5920} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5908})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5921} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5920})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-5922} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5920})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-5922})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5923} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5922})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5924} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5923})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-5925} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5923})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-5924})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5926} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5924})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5927} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5926})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-5928} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5926})])
                        (if (and (__AST-id?
                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5927})
                                 (eq? (__AST-e
                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5927})
                                      '\x40;type.signature))
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-5928})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5929} (__AST-e
                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5928})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5930} (\x23;\x23;car
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5929})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5931} (\x23;\x23;cdr
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5929})])
                                  (let ([signature #{ehd dpuuv4a3mobea70icwo8nvdax-5930}])
                                    (if (__AST-pair?
                                          #{etl dpuuv4a3mobea70icwo8nvdax-5931})
                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5932} (__AST-e
                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5931})]
                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5933} (\x23;\x23;car
                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5932})]
                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5934} (\x23;\x23;cdr
                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5932})])
                                          (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-5933}])
                                            (if (null?
                                                  (__AST-e
                                                    #{etl dpuuv4a3mobea70icwo8nvdax-5934}))
                                                (if (__AST-pair?
                                                      #{etl dpuuv4a3mobea70icwo8nvdax-5925})
                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5935} (__AST-e
                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-5925})]
                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-5936} (\x23;\x23;car
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5935})]
                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-5937} (\x23;\x23;cdr
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-5935})])
                                                      (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-5936}])
                                                        (if (null?
                                                              (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-5937}))
                                                            (cond
                                                              [(memp
                                                                 (lambda (#{e dpuuv4a3mobea70icwo8nvdax-5938})
                                                                   (stx-eq?
                                                                     'return:
                                                                     #{e dpuuv4a3mobea70icwo8nvdax-5938}))
                                                                 #'(signature
                                                                     ...)) =>
                                                               (lambda (tail)
                                                                 (let ([type (optimizer-resolve-class
                                                                               stx
                                                                               (identifier-symbol
                                                                                 (cadr
                                                                                   tail)))])
                                                                   (check-return-type!
                                                                     stx
                                                                     #'body
                                                                     type)
                                                                   (compile-e
                                                                     self
                                                                     #'body)))]
                                                              [else
                                                               (compile-e
                                                                 self
                                                                 #'body)])
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5909}))))
                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5909}))
                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5909}))))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5909}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-5909}))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-5909})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-5909})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5909})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-5909})))))

(define (check-return-type! stx expr type)
  (cond
    [(not type)]
    [(eq? (!type-id type) 't)]
    [(eq? (!type-id type) 'void)]
    [else
     (let ([expr-type (apply-basic-expression-type expr)])
       (cond
         [(not expr-type)
          (raise-compile-error
            "cannot verify procedure return type; no type information"
            stx
            type)]
         [(eq? 't (!type-id expr-type))
          (raise-compile-error
            "cannot verify procedure return type; unspecific type"
            stx
            type
            expr-type)]
         [(!abort? expr-type)]
         [(!type-subtype? expr-type type)]
         [else
          (raise-compile-error
            "procedure return type does not match signature"
            stx
            type
            expr-type)]))]))

(define (optimize-if% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-5939} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5940} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5941} (lambda ()
                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5942} (lambda ()
                                                                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-5943} (lambda ()
                                                                                                                                                                                                    (__raise-syntax-error
                                                                                                                                                                                                      #f
                                                                                                                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-5939}))])
                                                                                                                                                      (if (__AST-pair?
                                                                                                                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})
                                                                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5944} (__AST-e
                                                                                                                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})]
                                                                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5945} (\x23;\x23;car
                                                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5944})]
                                                                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5946} (\x23;\x23;cdr
                                                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5944})])
                                                                                                                                                            (if (__AST-pair?
                                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5946})
                                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5947} (__AST-e
                                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5946})]
                                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5948} (\x23;\x23;car
                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5947})]
                                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5949} (\x23;\x23;cdr
                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5947})])
                                                                                                                                                                  (let ([test #{ehd dpuuv4a3mobea70icwo8nvdax-5948}])
                                                                                                                                                                    (if (__AST-pair?
                                                                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5949})
                                                                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5950} (__AST-e
                                                                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5949})]
                                                                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5951} (\x23;\x23;car
                                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5950})]
                                                                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5952} (\x23;\x23;cdr
                                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5950})])
                                                                                                                                                                          (let ([K #{ehd dpuuv4a3mobea70icwo8nvdax-5951}])
                                                                                                                                                                            (if (__AST-pair?
                                                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5952})
                                                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5953} (__AST-e
                                                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5952})]
                                                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5954} (\x23;\x23;car
                                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5953})]
                                                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5955} (\x23;\x23;cdr
                                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5953})])
                                                                                                                                                                                  (let ([E #{ehd dpuuv4a3mobea70icwo8nvdax-5954}])
                                                                                                                                                                                    (if (null?
                                                                                                                                                                                          (__AST-e
                                                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5955}))
                                                                                                                                                                                        (xform-operands
                                                                                                                                                                                          self
                                                                                                                                                                                          stx)
                                                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5943}))))
                                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5943}))))
                                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5943}))))
                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5943})))
                                                                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5943}))))])
                                                                                                      (if (__AST-pair?
                                                                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})
                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5956} (__AST-e
                                                                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})]
                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5957} (\x23;\x23;car
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5956})]
                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5958} (\x23;\x23;cdr
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5956})])
                                                                                                            (if (__AST-pair?
                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5958})
                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5959} (__AST-e
                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5958})]
                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5960} (\x23;\x23;car
                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5959})]
                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5961} (\x23;\x23;cdr
                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5959})])
                                                                                                                  (if (__AST-pair?
                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5960})
                                                                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5962} (__AST-e
                                                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5960})]
                                                                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5963} (\x23;\x23;car
                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5962})]
                                                                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-5964} (\x23;\x23;cdr
                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5962})])
                                                                                                                        (if (and (__AST-id?
                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5963})
                                                                                                                                 (eq? (__AST-e
                                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5963})
                                                                                                                                      '%\x23;call))
                                                                                                                            (if (__AST-pair?
                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5964})
                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5965} (__AST-e
                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5964})]
                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5966} (\x23;\x23;car
                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5965})]
                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5967} (\x23;\x23;cdr
                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5965})])
                                                                                                                                  (if (__AST-pair?
                                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5966})
                                                                                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5968} (__AST-e
                                                                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5966})]
                                                                                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5969} (\x23;\x23;car
                                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5968})]
                                                                                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-5970} (\x23;\x23;cdr
                                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5968})])
                                                                                                                                        (if (and (__AST-id?
                                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5969})
                                                                                                                                                 (eq? (__AST-e
                                                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5969})
                                                                                                                                                      '%\x23;ref))
                                                                                                                                            (if (__AST-pair?
                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5970})
                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5971} (__AST-e
                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5970})]
                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5972} (\x23;\x23;car
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5971})]
                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5973} (\x23;\x23;cdr
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5971})])
                                                                                                                                                  (let ([\x2D;not #{ehd dpuuv4a3mobea70icwo8nvdax-5972}])
                                                                                                                                                    (if (null?
                                                                                                                                                          (__AST-e
                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5973}))
                                                                                                                                                        (if (__AST-pair?
                                                                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5967})
                                                                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5974} (__AST-e
                                                                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5967})]
                                                                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-5975} (\x23;\x23;car
                                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5974})]
                                                                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-5976} (\x23;\x23;cdr
                                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-5974})])
                                                                                                                                                              (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-5975}])
                                                                                                                                                                (if (null?
                                                                                                                                                                      (__AST-e
                                                                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-5976}))
                                                                                                                                                                    (if (__AST-pair?
                                                                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-5961})
                                                                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5977} (__AST-e
                                                                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-5961})]
                                                                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-5978} (\x23;\x23;car
                                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5977})]
                                                                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-5979} (\x23;\x23;cdr
                                                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-5977})])
                                                                                                                                                                          (let ([K #{ehd dpuuv4a3mobea70icwo8nvdax-5978}])
                                                                                                                                                                            (if (__AST-pair?
                                                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5979})
                                                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5980} (__AST-e
                                                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5979})]
                                                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5981} (\x23;\x23;car
                                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5980})]
                                                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5982} (\x23;\x23;cdr
                                                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5980})])
                                                                                                                                                                                  (let ([E #{ehd dpuuv4a3mobea70icwo8nvdax-5981}])
                                                                                                                                                                                    (if (null?
                                                                                                                                                                                          (__AST-e
                                                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-5982}))
                                                                                                                                                                                        (if (runtime-identifier=?
                                                                                                                                                                                              #'\x2D;not
                                                                                                                                                                                              'not)
                                                                                                                                                                                            (optimize-if%
                                                                                                                                                                                              self
                                                                                                                                                                                              (xform-wrap-source
                                                                                                                                                                                                #'(%\x23;if
                                                                                                                                                                                                    expr
                                                                                                                                                                                                    E
                                                                                                                                                                                                    K)
                                                                                                                                                                                                stx))
                                                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))
                                                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))))
                                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))))
                                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))
                                                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))))
                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))
                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))))
                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))
                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5942})))
                                                                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5942})))
                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))
                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5942})))
                                                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5942})))
                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5942})))
                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5942}))))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5983} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-5984} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5983})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-5985} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-5983})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5985})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5986} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5985})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5987} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5986})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5988} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5986})])
                                                                  (if (__AST-pair?
                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5987})
                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5989} (__AST-e
                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5987})]
                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5990} (\x23;\x23;car
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5989})]
                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-5991} (\x23;\x23;cdr
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5989})])
                                                                        (if (and (__AST-id?
                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5990})
                                                                                 (eq? (__AST-e
                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5990})
                                                                                      '%\x23;call))
                                                                            (if (__AST-pair?
                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5991})
                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5992} (__AST-e
                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5991})]
                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5993} (\x23;\x23;car
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5992})]
                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-5994} (\x23;\x23;cdr
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5992})])
                                                                                  (if (__AST-pair?
                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5993})
                                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5995} (__AST-e
                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-5993})]
                                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-5996} (\x23;\x23;car
                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5995})]
                                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-5997} (\x23;\x23;cdr
                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-5995})])
                                                                                        (if (and (__AST-id?
                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-5996})
                                                                                                 (eq? (__AST-e
                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-5996})
                                                                                                      '%\x23;ref))
                                                                                            (if (__AST-pair?
                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-5997})
                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-5998} (__AST-e
                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-5997})]
                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-5999} (\x23;\x23;car
                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5998})]
                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-6000} (\x23;\x23;cdr
                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-5998})])
                                                                                                  (let ([pred #{ehd dpuuv4a3mobea70icwo8nvdax-5999}])
                                                                                                    (if (null?
                                                                                                          (__AST-e
                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-6000}))
                                                                                                        (if (__AST-pair?
                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5994})
                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6001} (__AST-e
                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5994})]
                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-6002} (\x23;\x23;car
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6001})]
                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-6003} (\x23;\x23;cdr
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6001})])
                                                                                                              (if (__AST-pair?
                                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-6002})
                                                                                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6004} (__AST-e
                                                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-6002})]
                                                                                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-6005} (\x23;\x23;car
                                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-6004})]
                                                                                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-6006} (\x23;\x23;cdr
                                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-6004})])
                                                                                                                    (if (and (__AST-id?
                                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-6005})
                                                                                                                             (eq? (__AST-e
                                                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-6005})
                                                                                                                                  '%\x23;ref))
                                                                                                                        (if (__AST-pair?
                                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-6006})
                                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6007} (__AST-e
                                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-6006})]
                                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-6008} (\x23;\x23;car
                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6007})]
                                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-6009} (\x23;\x23;cdr
                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6007})])
                                                                                                                              (let ([obj #{ehd dpuuv4a3mobea70icwo8nvdax-6008}])
                                                                                                                                (if (null?
                                                                                                                                      (__AST-e
                                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-6009}))
                                                                                                                                    (if (null?
                                                                                                                                          (__AST-e
                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-6003}))
                                                                                                                                        (if (__AST-pair?
                                                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-5988})
                                                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6010} (__AST-e
                                                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-5988})]
                                                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-6011} (\x23;\x23;car
                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6010})]
                                                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-6012} (\x23;\x23;cdr
                                                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6010})])
                                                                                                                                              (let ([K #{ehd dpuuv4a3mobea70icwo8nvdax-6011}])
                                                                                                                                                (if (__AST-pair?
                                                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-6012})
                                                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6013} (__AST-e
                                                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-6012})]
                                                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-6014} (\x23;\x23;car
                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-6013})]
                                                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-6015} (\x23;\x23;cdr
                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-6013})])
                                                                                                                                                      (let ([E #{ehd dpuuv4a3mobea70icwo8nvdax-6014}])
                                                                                                                                                        (if (null?
                                                                                                                                                              (__AST-e
                                                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-6015}))
                                                                                                                                                            (cond
                                                                                                                                                              [(optimizer-lookup-type
                                                                                                                                                                 (identifier-symbol
                                                                                                                                                                   #'pred)) =>
                                                                                                                                                               (lambda (pred-type)
                                                                                                                                                                 (if (or (!predicate?
                                                                                                                                                                           pred-type)
                                                                                                                                                                         (!primitive-predicate?
                                                                                                                                                                           pred-type))
                                                                                                                                                                     (let* ([test (xform-wrap-apply
                                                                                                                                                                                    #'(%\x23;call
                                                                                                                                                                                        (%\x23;ref
                                                                                                                                                                                          pred)
                                                                                                                                                                                        (%\x23;ref
                                                                                                                                                                                          obj))
                                                                                                                                                                                    stx
                                                                                                                                                                                    self)])
                                                                                                                                                                       (let* ([K (delay (parameterize ([current-compile-path-type
                                                                                                                                                                                                        (cons
                                                                                                                                                                                                          (cons
                                                                                                                                                                                                            (identifier-symbol
                                                                                                                                                                                                              #'obj)
                                                                                                                                                                                                            (optimizer-resolve-class
                                                                                                                                                                                                              stx
                                                                                                                                                                                                              (!type-id
                                                                                                                                                                                                                pred-type)))
                                                                                                                                                                                                          (current-compile-path-type))])
                                                                                                                                                                                          (compile-e
                                                                                                                                                                                            self
                                                                                                                                                                                            #'K)))])
                                                                                                                                                                         (let* ([E (delay (compile-e
                                                                                                                                                                                            self
                                                                                                                                                                                            #'E))])
                                                                                                                                                                           (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-6016} test])
                                                                                                                                                                             (let ([#{fail dpuuv4a3mobea70icwo8nvdax-6017} (lambda ()
                                                                                                                                                                                                                             (let ([#{fail dpuuv4a3mobea70icwo8nvdax-6018} (lambda ()
                                                                                                                                                                                                                                                                             (__raise-syntax-error
                                                                                                                                                                                                                                                                               #f
                                                                                                                                                                                                                                                                               "Bad syntax; malformed ast clause"
                                                                                                                                                                                                                                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-6016}))])
                                                                                                                                                                                                                               (xform-wrap-source
                                                                                                                                                                                                                                 (list
                                                                                                                                                                                                                                   '%\x23;if
                                                                                                                                                                                                                                   test
                                                                                                                                                                                                                                   (force
                                                                                                                                                                                                                                     K)
                                                                                                                                                                                                                                   (force
                                                                                                                                                                                                                                     E))
                                                                                                                                                                                                                                 stx)))])
                                                                                                                                                                               (if (__AST-pair?
                                                                                                                                                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-6016})
                                                                                                                                                                                   (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6019} (__AST-e
                                                                                                                                                                                                                                    #{ast-val dpuuv4a3mobea70icwo8nvdax-6016})]
                                                                                                                                                                                          [#{ehd dpuuv4a3mobea70icwo8nvdax-6020} (\x23;\x23;car
                                                                                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-6019})]
                                                                                                                                                                                          [#{etl dpuuv4a3mobea70icwo8nvdax-6021} (\x23;\x23;cdr
                                                                                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-6019})])
                                                                                                                                                                                     (let ([%\x23;quote #{ehd dpuuv4a3mobea70icwo8nvdax-6020}])
                                                                                                                                                                                       (if (__AST-pair?
                                                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-6021})
                                                                                                                                                                                           (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6022} (__AST-e
                                                                                                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-6021})]
                                                                                                                                                                                                  [#{ehd dpuuv4a3mobea70icwo8nvdax-6023} (\x23;\x23;car
                                                                                                                                                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-6022})]
                                                                                                                                                                                                  [#{etl dpuuv4a3mobea70icwo8nvdax-6024} (\x23;\x23;cdr
                                                                                                                                                                                                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-6022})])
                                                                                                                                                                                             (let ([val #{ehd dpuuv4a3mobea70icwo8nvdax-6023}])
                                                                                                                                                                                               (if (null?
                                                                                                                                                                                                     (__AST-e
                                                                                                                                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-6024}))
                                                                                                                                                                                                   (if (stx-e
                                                                                                                                                                                                         #'val)
                                                                                                                                                                                                       (force
                                                                                                                                                                                                         K)
                                                                                                                                                                                                       (force
                                                                                                                                                                                                         E))
                                                                                                                                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-6017}))))
                                                                                                                                                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-6017}))))
                                                                                                                                                                                   (#{fail dpuuv4a3mobea70icwo8nvdax-6017})))))))
                                                                                                                                                                     (xform-operands
                                                                                                                                                                       self
                                                                                                                                                                       stx)))]
                                                                                                                                                              [else
                                                                                                                                                               (xform-operands
                                                                                                                                                                 self
                                                                                                                                                                 stx)])
                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))))
                                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))))
                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))))
                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))))
                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))
                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-5941})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-5941}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6025} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-5939})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-6026} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-6025})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-6027} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-6025})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-6027})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6028} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-6027})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-6029} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-6028})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-6030} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-6028})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-6029})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6031} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-6029})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-6032} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-6031})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-6033} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-6031})])
                        (if (and (__AST-id?
                                   #{ehd dpuuv4a3mobea70icwo8nvdax-6032})
                                 (eq? (__AST-e
                                        #{ehd dpuuv4a3mobea70icwo8nvdax-6032})
                                      '%\x23;quote))
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-6033})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6034} (__AST-e
                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-6033})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-6035} (\x23;\x23;car
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-6034})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-6036} (\x23;\x23;cdr
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-6034})])
                                  (let ([val #{ehd dpuuv4a3mobea70icwo8nvdax-6035}])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-6036}))
                                        (if (__AST-pair?
                                              #{etl dpuuv4a3mobea70icwo8nvdax-6030})
                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6037} (__AST-e
                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-6030})]
                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-6038} (\x23;\x23;car
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6037})]
                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-6039} (\x23;\x23;cdr
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-6037})])
                                              (let ([K #{ehd dpuuv4a3mobea70icwo8nvdax-6038}])
                                                (if (__AST-pair?
                                                      #{etl dpuuv4a3mobea70icwo8nvdax-6039})
                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-6040} (__AST-e
                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-6039})]
                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-6041} (\x23;\x23;car
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-6040})]
                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-6042} (\x23;\x23;cdr
                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-6040})])
                                                      (let ([E #{ehd dpuuv4a3mobea70icwo8nvdax-6041}])
                                                        (if (null?
                                                              (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-6042}))
                                                            (if (stx-e
                                                                  #'val)
                                                                (compile-e
                                                                  self
                                                                  #'K)
                                                                (compile-e
                                                                  self
                                                                  #'E))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5940}))))
                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-5940}))))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-5940}))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-5940}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-5940}))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-5940})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-5940})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-5940})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-5940})))))

