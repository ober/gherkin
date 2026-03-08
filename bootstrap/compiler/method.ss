(define current-compile-method (make-parameter #f))

(define-syntax with-context
  (syntax-rules ()
    [(with-context stx expr)
     (cond
       [(stx-source stx) =>
        (lambda (source)
          (parameterize ([current-compile-context
                          (cons
                            `(\x40; ,source)
                            (or (current-compile-context) (\x40;list)))])
            expr))]
       [else expr])]))

(define compile-e
  (case-lambda
    [(stx)
     (let ([self (current-compile-method)])
       (cond
         [(method-ref self (stx-car-e stx)) =>
          (lambda (method)
            (void)
            (cond
              [(stx-source stx) =>
               (lambda (source)
                 (parameterize ([current-compile-context
                                 (cons
                                   `(\x40; ,source)
                                   (or (current-compile-context) (list)))])
                   (method self stx)))]
              [else (method self stx)]))]
         [else
          (error 'gerbil
            "missing method"
            self
            (stx-car-e stx)
            (syntax->datum stx))]))]
    [(self stx)
     (cond
       [(method-ref self (stx-car-e stx)) =>
        (lambda (method)
          (void)
          (cond
            [(stx-source stx) =>
             (lambda (source)
               (parameterize ([current-compile-context
                               (cons
                                 `(\x40; ,source)
                                 (or (current-compile-context) (list)))])
                 (method self stx)))]
            [else (method self stx)]))]
       [else
        (error 'gerbil
          "missing method"
          self
          (stx-car-e stx)
          (syntax->datum stx))])]))

(define (stx-car-e stx) (stx-e (car (stx-e stx))))

(define-syntax defcompile-method
  (lambda (stx)
    (syntax-case stx ()
      [(_ compile-method klass slots . methods)
       (identifier? #'klass)
       #'(defcompile-method compile-method (klass) slots .
           methods)]
      [(_ #f (klass super ...) slots (method implementation) ...)
       (with-syntax ([klass-bind-methods! (stx-identifier
                                            #'klass
                                            #'klass
                                            "-bind-methods!")]
                     [(super-bind-methods! ...) (map (lambda (super)
                                                       (stx-identifier
                                                         super
                                                         super
                                                         "-bind-methods!"))
                                                     #'(super ...))]
                     [klass::t (stx-identifier #'klass #'klass "::t")])
         #'(begin
             (defclass (klass super ...) slots)
             (def klass-bind-methods!
                  (delay-atomic
                    (begin
                      (force super-bind-methods!)
                      ...
                      (bind-method! klass::t 'method implementation)
                      ...)))))]
      [(_ (compile-method arg ...) (klass super ...) slots
          (method implementation) ...)
       (with-syntax ([klass-bind-methods! (stx-identifier
                                            #'klass
                                            #'klass
                                            "-bind-methods!")]
                     [(super-bind-methods! ...) (map (lambda (super)
                                                       (stx-identifier
                                                         super
                                                         super
                                                         "-bind-methods!"))
                                                     #'(super ...))]
                     [klass::t (stx-identifier #'klass #'klass "::t")])
         #'(begin
             (defclass (klass super ...) slots)
             (def klass-bind-methods!
                  (delay-atomic
                    (begin
                      (force super-bind-methods!)
                      ...
                      (bind-method! klass::t 'method implementation)
                      ...)))
             (def (compile-method stx arg ...)
                  (force klass-bind-methods!)
                  (let (self [klass arg ...])
                    (parameterize ([current-compile-method self])
                      (compile-e self stx))))))]
      [(_ (compile-method arg ...) (klass super ...) slots final:
          (method implementation) ...)
       (with-syntax ([klass-bind-methods! (stx-identifier
                                            #'klass
                                            #'klass
                                            "-bind-methods!")]
                     [(super-bind-methods! ...) (map (lambda (super)
                                                       (stx-identifier
                                                         super
                                                         super
                                                         "-bind-methods!"))
                                                     #'(super ...))]
                     [klass::t (stx-identifier #'klass #'klass "::t")])
         #'(begin
             (defclass (klass super ...) slots final: #t)
             (def klass-bind-methods!
                  (delay-atomic
                    (begin
                      (force super-bind-methods!)
                      ...
                      (bind-method! klass::t 'method implementation)
                      ...
                      (seal-class! klass::t))))
             (def (compile-method stx arg ...)
                  (force klass-bind-methods!)
                  (let (self [klass arg ...])
                    (parameterize ([current-compile-method self])
                      (compile-e self stx))))))])))

(define (void-method self stx) (%%void))

(define (false-method self stx) #f)

(define (true-method self stx) #t)

(define (identity-method self stx) stx)

(defcompile-method #f ::void-expression ()
 (%\x23;begin-annotation void-method)
 (%\x23;lambda void-method) (%\x23;case-lambda void-method)
 (%\x23;let-values void-method)
 (%\x23;letrec-values void-method)
 (%\x23;letrec*-values void-method) (%\x23;quote void-method)
 (%\x23;quote-syntax void-method) (%\x23;call void-method)
 (%\x23;call-unchecked void-method) (%\x23;if void-method)
 (%\x23;ref void-method) (%\x23;set! void-method)
 (%\x23;struct-instance? void-method)
 (%\x23;struct-direct-instance? void-method)
 (%\x23;struct-ref void-method)
 (%\x23;struct-set! void-method)
 (%\x23;struct-direct-ref void-method)
 (%\x23;struct-direct-set! void-method)
 (%\x23;struct-unchecked-ref void-method)
 (%\x23;struct-unchecked-set! void-method))

(defcompile-method #f ::void-special-form () (%\x23;begin void-method)
  (%\x23;begin-syntax void-method)
  (%\x23;begin-foreign void-method) (%\x23;module void-method)
  (%\x23;import void-method) (%\x23;export void-method)
  (%\x23;provide void-method) (%\x23;extern void-method)
  (%\x23;define-values void-method)
  (%\x23;define-syntax void-method)
  (%\x23;define-alias void-method)
  (%\x23;declare void-method))

(defcompile-method
  #f
  (::void ::void-special-form ::void-expression)
  ())

(defcompile-method #f ::false-expression ()
 (%\x23;begin-annotation false-method)
 (%\x23;lambda false-method) (%\x23;case-lambda false-method)
 (%\x23;let-values false-method)
 (%\x23;letrec-values false-method)
 (%\x23;letrec*-values false-method)
 (%\x23;quote false-method) (%\x23;quote-syntax false-method)
 (%\x23;call false-method)
 (%\x23;call-unchecked false-method) (%\x23;if false-method)
 (%\x23;ref false-method) (%\x23;set! false-method)
 (%\x23;struct-instance? false-method)
 (%\x23;struct-direct-instance? false-method)
 (%\x23;struct-ref false-method)
 (%\x23;struct-set! false-method)
 (%\x23;struct-direct-ref false-method)
 (%\x23;struct-direct-set! false-method)
 (%\x23;struct-unchecked-ref false-method)
 (%\x23;struct-unchecked-set! false-method))

(defcompile-method #f ::false-special-form () (%\x23;begin false-method)
  (%\x23;begin-syntax false-method)
  (%\x23;begin-foreign false-method)
  (%\x23;module false-method) (%\x23;import false-method)
  (%\x23;export false-method) (%\x23;provide false-method)
  (%\x23;extern false-method)
  (%\x23;define-values false-method)
  (%\x23;define-syntax false-method)
  (%\x23;define-alias false-method)
  (%\x23;declare false-method))

(defcompile-method
  #f
  (::false ::false-special-form ::false-expression)
  ())

(defcompile-method #f ::identity-expression ()
 (%\x23;begin-annotation identity-method)
 (%\x23;lambda identity-method)
 (%\x23;case-lambda identity-method)
 (%\x23;let-values identity-method)
 (%\x23;letrec-values identity-method)
 (%\x23;letrec*-values identity-method)
 (%\x23;quote identity-method)
 (%\x23;quote-syntax identity-method)
 (%\x23;call identity-method)
 (%\x23;call-unchecked identity-method)
 (%\x23;if identity-method) (%\x23;ref identity-method)
 (%\x23;set! identity-method)
 (%\x23;struct-instance? identity-method)
 (%\x23;struct-direct-instance? identity-method)
 (%\x23;struct-ref identity-method)
 (%\x23;struct-set! identity-method)
 (%\x23;struct-direct-ref identity-method)
 (%\x23;struct-direct-set! identity-method)
 (%\x23;struct-unchecked-ref identity-method)
 (%\x23;struct-unchecked-set! identity-method))

(defcompile-method #f ::identity-special-form () (%\x23;begin identity-method)
  (%\x23;begin-syntax identity-method)
  (%\x23;begin-foreign identity-method)
  (%\x23;module identity-method)
  (%\x23;import identity-method)
  (%\x23;export identity-method)
  (%\x23;provide identity-method)
  (%\x23;extern identity-method)
  (%\x23;define-values identity-method)
  (%\x23;define-syntax identity-method)
  (%\x23;define-alias identity-method)
  (%\x23;declare identity-method))

(defcompile-method
  #f
  (::identity ::identity-special-form ::identity-expression)
  ())

(defcompile-method #f ::basic-xform-expression ()
 (%\x23;begin-annotation xform-begin-annotation%)
 (%\x23;lambda xform-lambda%)
 (%\x23;case-lambda xform-case-lambda%)
 (%\x23;let-values xform-let-values%)
 (%\x23;letrec-values xform-letrec-values%)
 (%\x23;letrec*-values xform-letrec-values%)
 (%\x23;quote identity-method)
 (%\x23;quote-syntax identity-method)
 (%\x23;call xform-operands)
 (%\x23;call-unchecked xform-operands)
 (%\x23;if xform-operands) (%\x23;ref identity-method)
 (%\x23;set! xform-setq%)
 (%\x23;struct-instance? xform-operands)
 (%\x23;struct-direct-instance? xform-operands)
 (%\x23;struct-ref xform-operands)
 (%\x23;struct-set! xform-operands)
 (%\x23;struct-direct-ref xform-operands)
 (%\x23;struct-direct-set! xform-operands)
 (%\x23;struct-unchecked-ref xform-operands)
 (%\x23;struct-unchecked-set! xform-operands))

(defcompile-method #f (::basic-xform ::basic-xform-expression ::identity) ()
  (%\x23;begin xform-begin%)
  (%\x23;begin-syntax xform-begin-syntax%)
  (%\x23;module xform-module%)
  (%\x23;define-values xform-define-values%)
  (%\x23;define-syntax xform-define-syntax%))

(define (apply-begin% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3264} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3265} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3264}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3264})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3266} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3264})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3267} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3266})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3268} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3266})])
            (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3268}])
              (for-each
                (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3269})
                  (compile-e
                    self
                    #{cut-arg dpuuv4a3mobea70icwo8nvdax-3269}))
                (stx-e #'body))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3265})))))

(define (apply-last-begin% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3270} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3271} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3270}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3270})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3272} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3270})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3273} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3272})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3274} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3272})])
            (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3274}])
              (compile-e self (last #'body))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3271})))))

(define (apply-begin-syntax% self stx)
  (parameterize ([current-expander-phi
                  (fx1+ (current-expander-phi))])
    (apply-begin% self stx)))

(define (apply-module% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3275} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3276} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3275}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3275})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3277} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3275})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3278} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3277})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3279} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3277})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3279})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3280} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3279})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3281} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3280})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3282} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3280})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3281}])
                    (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3282}])
                      (let* ([ctx (syntax-local-e #'id)])
                        (let* ([ctx-stx (module-context-code ctx)])
                          (parameterize ([current-expander-context ctx])
                            (compile-e self ctx-stx)))))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3276})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3276})))))

(define (apply-begin-annotation% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3283} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3284} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3283}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3283})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3285} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3283})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3286} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3285})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3287} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3285})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3287})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3288} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3287})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3289} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3288})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3290} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3288})])
                  (let ([ann #{ehd dpuuv4a3mobea70icwo8nvdax-3289}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3290})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3291} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3290})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3292} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3291})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3293} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3291})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3292}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3293}))
                                (compile-e self #'expr)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3284}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3284}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3284})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3284})))))

(define (apply-define-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3294} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3295} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3294}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3294})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3296} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3294})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3297} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3296})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3298} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3296})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3298})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3299} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3298})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3300} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3299})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3301} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3299})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3300}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3301})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3302} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3301})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3303} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3302})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3304} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3302})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3303}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3304}))
                                (compile-e self #'expr)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3295}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3295}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3295})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3295})))))

(define (apply-define-syntax% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3305} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3306} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3305}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3305})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3307} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3305})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3308} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3307})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3309} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3307})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3309})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3310} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3309})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3311} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3310})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3312} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3310})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3311}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3312})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3313} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3312})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3314} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3313})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3315} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3313})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3314}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3315}))
                                (parameterize ([current-expander-phi
                                                (fx1+
                                                  (current-expander-phi))])
                                  (compile-e self #'expr))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3306}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3306}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3306})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3306})))))

(define (apply-body-lambda% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3316} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3317} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3316}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3316})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3318} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3316})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3319} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3318})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3320} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3318})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3320})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3321} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3320})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3322} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3321})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3323} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3321})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3322}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3323})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3324} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3323})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3325} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3324})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3326} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3324})])
                          (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-3325}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3326}))
                                (compile-e self #'body)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3317}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3317}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3317})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3317})))))

(define (apply-body-case-lambda% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3327} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3328} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3327}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3327})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3329} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3327})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3330} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3329})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3331} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3329})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3331})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3332} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3331})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3333} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3332})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3334} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3332})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-3333})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3335} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-3333})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-3336} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3335})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-3337} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3335})])
                        (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3336}])
                          (if (__AST-pair?
                                #{etl dpuuv4a3mobea70icwo8nvdax-3337})
                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3338} (__AST-e
                                                                               #{etl dpuuv4a3mobea70icwo8nvdax-3337})]
                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-3339} (\x23;\x23;car
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3338})]
                                     [#{etl dpuuv4a3mobea70icwo8nvdax-3340} (\x23;\x23;cdr
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3338})])
                                (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-3339}])
                                  (if (null?
                                        (__AST-e
                                          #{etl dpuuv4a3mobea70icwo8nvdax-3340}))
                                      (if (__AST-pair?
                                            #{etl dpuuv4a3mobea70icwo8nvdax-3334})
                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3341} (__AST-e
                                                                                           #{etl dpuuv4a3mobea70icwo8nvdax-3334})]
                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3342} (\x23;\x23;car
                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3341})]
                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-3343} (\x23;\x23;cdr
                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3341})])
                                            (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3342}])
                                              (if (null?
                                                    (__AST-e
                                                      #{etl dpuuv4a3mobea70icwo8nvdax-3343}))
                                                  (for-each
                                                    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3344})
                                                      (compile-e
                                                        self
                                                        #{cut-arg dpuuv4a3mobea70icwo8nvdax-3344}))
                                                    #'(body ...))
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-3328}))))
                                          (#{fail dpuuv4a3mobea70icwo8nvdax-3328}))
                                      (#{fail dpuuv4a3mobea70icwo8nvdax-3328}))))
                              (#{fail dpuuv4a3mobea70icwo8nvdax-3328}))))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-3328})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3328})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3328})))))

(define (apply-body-let-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3345} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3346} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3345}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3345})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3347} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3345})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3348} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3347})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3349} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3347})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3349})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3350} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3349})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3351} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3350})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3352} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3350})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-3351})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3353} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-3351})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-3354} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3353})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-3355} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3353})])
                        (if (__AST-pair?
                              #{ehd dpuuv4a3mobea70icwo8nvdax-3354})
                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3356} (__AST-e
                                                                             #{ehd dpuuv4a3mobea70icwo8nvdax-3354})]
                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-3357} (\x23;\x23;car
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3356})]
                                   [#{etl dpuuv4a3mobea70icwo8nvdax-3358} (\x23;\x23;cdr
                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3356})])
                              (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3357}])
                                (if (__AST-pair?
                                      #{etl dpuuv4a3mobea70icwo8nvdax-3358})
                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3359} (__AST-e
                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-3358})]
                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-3360} (\x23;\x23;car
                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-3359})]
                                           [#{etl dpuuv4a3mobea70icwo8nvdax-3361} (\x23;\x23;cdr
                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-3359})])
                                      (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3360}])
                                        (if (null?
                                              (__AST-e
                                                #{etl dpuuv4a3mobea70icwo8nvdax-3361}))
                                            (if (__AST-pair?
                                                  #{etl dpuuv4a3mobea70icwo8nvdax-3355})
                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3362} (__AST-e
                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3355})]
                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3363} (\x23;\x23;car
                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3362})]
                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-3364} (\x23;\x23;cdr
                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3362})])
                                                  (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3363}])
                                                    (if (null?
                                                          (__AST-e
                                                            #{etl dpuuv4a3mobea70icwo8nvdax-3364}))
                                                        (if (__AST-pair?
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-3352})
                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3365} (__AST-e
                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-3352})]
                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-3366} (\x23;\x23;car
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3365})]
                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-3367} (\x23;\x23;cdr
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3365})])
                                                              (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-3366}])
                                                                (if (null?
                                                                      (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-3367}))
                                                                    (for-each
                                                                      (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3368})
                                                                        (compile-e
                                                                          self
                                                                          #{cut-arg dpuuv4a3mobea70icwo8nvdax-3368}))
                                                                      #'(expr
                                                                          ...
                                                                          body))
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))
                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))))
                                                (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))))
                                    (#{fail dpuuv4a3mobea70icwo8nvdax-3346}))))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-3346})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-3346})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3346})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3346})))))

(define (apply-body-last-let-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3369} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3370} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3369}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3369})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3371} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3369})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3372} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3371})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3373} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3371})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3373})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3374} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3373})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3375} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3374})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3376} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3374})])
                  (let ([bind #{ehd dpuuv4a3mobea70icwo8nvdax-3375}])
                    (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3376}])
                      (compile-e self (last #'body)))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3370})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3370})))))

(define (apply-body-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3377} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3378} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3377}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3377})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3379} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3377})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3380} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3379})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3381} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3379})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3381})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3382} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3381})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3383} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3382})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3384} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3382})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3383}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3384})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3385} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3384})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3386} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3385})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3387} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3385})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3386}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3387}))
                                (compile-e self #'expr)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3378}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3378}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3378})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3378})))))

(define (apply-operands self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3388} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3389} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3388}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3388})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3390} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3388})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3391} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3390})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3392} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3390})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3392})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3393} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3392})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3394} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3393})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3395} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3393})])
                  (let ([rands #{ehd dpuuv4a3mobea70icwo8nvdax-3394}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3395})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3396} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3395})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3397} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3396})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3398} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3396})])
                          (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3397}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3398}))
                                (for-each
                                  (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3399})
                                    (compile-e
                                      self
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-3399}))
                                  #'(rands ...))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3389}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3389}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3389})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3389})))))

(define (xform-wrap-source stx src-stx)
  (stx-wrap-source stx (stx-source src-stx)))

(define (xform-wrap-apply stx src-stx ctx)
  (compile-e ctx (xform-wrap-source stx src-stx)))

(define (xform-begin% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3400} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3401} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3400}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3400})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3402} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3400})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3403} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3402})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3404} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3402})])
            (let ([forms #{etl dpuuv4a3mobea70icwo8nvdax-3404}])
              (let ([forms (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3405})
                                  (compile-e
                                    self
                                    #{cut-arg dpuuv4a3mobea70icwo8nvdax-3405}))
                                #'forms)])
                (xform-wrap-source (cons* '%\x23;begin forms) stx))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3401})))))

(define (xform-begin-syntax% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3406} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3407} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3406}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3406})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3408} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3406})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3409} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3408})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3410} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3408})])
            (let ([forms #{etl dpuuv4a3mobea70icwo8nvdax-3410}])
              (parameterize ([current-expander-phi
                              (fx1+ (current-expander-phi))])
                (let ([forms (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3411})
                                    (compile-e
                                      self
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-3411}))
                                  #'forms)])
                  (xform-wrap-source
                    (cons* '%\x23;begin-syntax forms)
                    stx)))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3407})))))

(define (xform-module% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3412} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3413} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3412}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3412})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3414} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3412})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3415} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3414})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3416} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3414})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3416})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3417} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3416})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3418} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3417})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3419} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3417})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3418}])
                    (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3419}])
                      (let* ([ctx (syntax-local-e #'id)])
                        (let* ([code (module-context-code ctx)])
                          (let* ([code (parameterize ([current-expander-context
                                                       ctx])
                                         (compile-e self code))])
                            (module-context-code-set! ctx code)
                            (xform-wrap-source
                              (list '%\x23;module #'id code)
                              stx)))))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3413})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3413})))))

(define (xform-define-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3420} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3421} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3420}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3420})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3422} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3420})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3423} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3422})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3424} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3422})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3424})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3425} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3424})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3426} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3425})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3427} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3425})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3426}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3427})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3428} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3427})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3429} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3428})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3430} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3428})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3429}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3430}))
                                (let ([expr (compile-e self #'expr)])
                                  (xform-wrap-source
                                    (list '%\x23;define-values #'hd expr)
                                    stx))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3421}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3421}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3421})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3421})))))

(define (xform-define-syntax% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3431} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3432} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3431}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3431})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3433} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3431})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3434} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3433})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3435} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3433})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3435})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3436} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3435})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3437} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3436})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3438} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3436})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3437}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3438})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3439} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3438})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3440} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3439})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3441} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3439})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3440}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3441}))
                                (parameterize ([current-expander-phi
                                                (fx1+
                                                  (current-expander-phi))])
                                  (let ([expr (compile-e self #'expr)])
                                    (xform-wrap-source
                                      (list '%\x23;define-syntax #'id expr)
                                      stx)))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3432}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3432}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3432})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3432})))))

(define (xform-begin-annotation% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3442} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3443} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3442}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3442})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3444} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3442})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3445} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3444})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3446} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3444})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3446})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3447} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3446})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3448} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3447})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3449} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3447})])
                  (let ([ann #{ehd dpuuv4a3mobea70icwo8nvdax-3448}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3449})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3450} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3449})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3451} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3450})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3452} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3450})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3451}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3452}))
                                (let ([expr (compile-e self #'expr)])
                                  (xform-wrap-source
                                    (list
                                      '%\x23;begin-annotation
                                      #'ann
                                      expr)
                                    stx))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3443}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3443}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3443})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3443})))))

(define (xform-lambda% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3453} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3454} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3453}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3453})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3455} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3453})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3456} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3455})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3457} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3455})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3457})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3458} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3457})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3459} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3458})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3460} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3458})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3459}])
                    (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3460}])
                      (parameterize ([current-compile-local-env
                                      (xform-let-locals #'hd)])
                        (let ([body (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3461})
                                           (compile-e
                                             self
                                             #{cut-arg dpuuv4a3mobea70icwo8nvdax-3461}))
                                         #'body)])
                          (xform-wrap-source
                            (cons* '%\x23;lambda #'hd body)
                            stx))))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3454})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3454})))))

(define (xform-case-lambda% self stx)
  (define (clause-e clause)
    (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3462} clause])
      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3463} (lambda ()
                                                      (__raise-syntax-error
                                                        #f
                                                        "Bad syntax; malformed ast clause"
                                                        #{ast-val dpuuv4a3mobea70icwo8nvdax-3462}))])
        (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3462})
            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3464} (__AST-e
                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-3462})]
                   [#{ehd dpuuv4a3mobea70icwo8nvdax-3465} (\x23;\x23;car
                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3464})]
                   [#{etl dpuuv4a3mobea70icwo8nvdax-3466} (\x23;\x23;cdr
                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-3464})])
              (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3465}])
                (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3466}])
                  (parameterize ([current-compile-local-env
                                  (xform-let-locals #'hd)])
                    (let ([body (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3467})
                                       (compile-e
                                         self
                                         #{cut-arg dpuuv4a3mobea70icwo8nvdax-3467}))
                                     #'body)])
                      (cons* #'hd body))))))
            (#{fail dpuuv4a3mobea70icwo8nvdax-3463})))))
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3468} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3469} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3468}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3468})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3470} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3468})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3471} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3470})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3472} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3470})])
            (let ([clauses #{etl dpuuv4a3mobea70icwo8nvdax-3472}])
              (let ([clauses (map clause-e #'clauses)])
                (xform-wrap-source
                  (cons* '%\x23;case-lambda clauses)
                  stx))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3469})))))

(define (xform-let-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3473} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3474} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3473}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3473})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3475} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3473})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3476} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3475})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3477} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3475})])
            (let ([form #{ehd dpuuv4a3mobea70icwo8nvdax-3476}])
              (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3477})
                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3478} (__AST-e
                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-3477})]
                         [#{ehd dpuuv4a3mobea70icwo8nvdax-3479} (\x23;\x23;car
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3478})]
                         [#{etl dpuuv4a3mobea70icwo8nvdax-3480} (\x23;\x23;cdr
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3478})])
                    (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-3479})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3481} (__AST-e
                                                                         #{ehd dpuuv4a3mobea70icwo8nvdax-3479})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3482} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3481})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3483} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3481})])
                          (if (__AST-pair?
                                #{ehd dpuuv4a3mobea70icwo8nvdax-3482})
                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3484} (__AST-e
                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-3482})]
                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-3485} (\x23;\x23;car
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3484})]
                                     [#{etl dpuuv4a3mobea70icwo8nvdax-3486} (\x23;\x23;cdr
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3484})])
                                (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3485}])
                                  (if (__AST-pair?
                                        #{etl dpuuv4a3mobea70icwo8nvdax-3486})
                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3487} (__AST-e
                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-3486})]
                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-3488} (\x23;\x23;car
                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3487})]
                                             [#{etl dpuuv4a3mobea70icwo8nvdax-3489} (\x23;\x23;cdr
                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3487})])
                                        (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3488}])
                                          (if (null?
                                                (__AST-e
                                                  #{etl dpuuv4a3mobea70icwo8nvdax-3489}))
                                              (if (__AST-pair?
                                                    #{etl dpuuv4a3mobea70icwo8nvdax-3483})
                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3490} (__AST-e
                                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-3483})]
                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-3491} (\x23;\x23;car
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3490})]
                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-3492} (\x23;\x23;cdr
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3490})])
                                                    (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3491}])
                                                      (if (null?
                                                            (__AST-e
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-3492}))
                                                          (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3480}])
                                                            (with-syntax ([(expr
                                                                             ...) (map (cut compile-e
                                                                                            self
                                                                                            <>)
                                                                                       #'(expr
                                                                                           ...))])
                                                              (parameterize ([current-compile-local-env
                                                                              (xform-let-locals
                                                                                #'(hd ...))])
                                                                (with-syntax ([body (map (cut compile-e
                                                                                              self
                                                                                              <>)
                                                                                         #'body)])
                                                                  (xform-wrap-source
                                                                    #'(form
                                                                        ((hd expr)
                                                                          ...)
                                                                        .
                                                                        body)
                                                                    stx)))))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-3474}))))
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-3474}))
                                              (#{fail dpuuv4a3mobea70icwo8nvdax-3474}))))
                                      (#{fail dpuuv4a3mobea70icwo8nvdax-3474}))))
                              (#{fail dpuuv4a3mobea70icwo8nvdax-3474})))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3474})))
                  (#{fail dpuuv4a3mobea70icwo8nvdax-3474}))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3474})))))

(define (xform-letrec-values% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3493} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3494} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3493}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3493})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3495} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3493})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3496} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3495})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3497} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3495})])
            (let ([form #{ehd dpuuv4a3mobea70icwo8nvdax-3496}])
              (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3497})
                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3498} (__AST-e
                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-3497})]
                         [#{ehd dpuuv4a3mobea70icwo8nvdax-3499} (\x23;\x23;car
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3498})]
                         [#{etl dpuuv4a3mobea70icwo8nvdax-3500} (\x23;\x23;cdr
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3498})])
                    (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-3499})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3501} (__AST-e
                                                                         #{ehd dpuuv4a3mobea70icwo8nvdax-3499})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3502} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3501})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3503} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3501})])
                          (if (__AST-pair?
                                #{ehd dpuuv4a3mobea70icwo8nvdax-3502})
                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3504} (__AST-e
                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-3502})]
                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-3505} (\x23;\x23;car
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3504})]
                                     [#{etl dpuuv4a3mobea70icwo8nvdax-3506} (\x23;\x23;cdr
                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-3504})])
                                (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3505}])
                                  (if (__AST-pair?
                                        #{etl dpuuv4a3mobea70icwo8nvdax-3506})
                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3507} (__AST-e
                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-3506})]
                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-3508} (\x23;\x23;car
                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3507})]
                                             [#{etl dpuuv4a3mobea70icwo8nvdax-3509} (\x23;\x23;cdr
                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-3507})])
                                        (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3508}])
                                          (if (null?
                                                (__AST-e
                                                  #{etl dpuuv4a3mobea70icwo8nvdax-3509}))
                                              (if (__AST-pair?
                                                    #{etl dpuuv4a3mobea70icwo8nvdax-3503})
                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3510} (__AST-e
                                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-3503})]
                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-3511} (\x23;\x23;car
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3510})]
                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-3512} (\x23;\x23;cdr
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3510})])
                                                    (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-3511}])
                                                      (if (null?
                                                            (__AST-e
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-3512}))
                                                          (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-3500}])
                                                            (parameterize ([current-compile-local-env
                                                                            (xform-let-locals
                                                                              #'(hd ...))])
                                                              (with-syntax ([(expr
                                                                               ...) (map (cut compile-e
                                                                                              self
                                                                                              <>)
                                                                                         #'(expr
                                                                                             ...))])
                                                                (with-syntax ([body (map (cut compile-e
                                                                                              self
                                                                                              <>)
                                                                                         #'body)])
                                                                  (xform-wrap-source
                                                                    #'(form
                                                                        ((hd expr)
                                                                          ...)
                                                                        .
                                                                        body)
                                                                    stx)))))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-3494}))))
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-3494}))
                                              (#{fail dpuuv4a3mobea70icwo8nvdax-3494}))))
                                      (#{fail dpuuv4a3mobea70icwo8nvdax-3494}))))
                              (#{fail dpuuv4a3mobea70icwo8nvdax-3494})))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3494})))
                  (#{fail dpuuv4a3mobea70icwo8nvdax-3494}))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3494})))))

(define (xform-let-locals bindings)
  (define (flatten maybe-lst)
    (if (identifier? maybe-lst)
        (list maybe-lst)
        (let loop ([rest maybe-lst] [result (list)])
          (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3513} rest])
            (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3514} (lambda ()
                                                            (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3515} (lambda ()
                                                                                                            (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3516} (lambda ()
                                                                                                                                                            (__raise-syntax-error
                                                                                                                                                              #f
                                                                                                                                                              "Bad syntax; malformed ast clause"
                                                                                                                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-3513}))])
                                                                                                              result))])
                                                              (let ([id #{ast-val dpuuv4a3mobea70icwo8nvdax-3513}])
                                                                (if (identifier?
                                                                      #'id)
                                                                    (cons
                                                                      #'id
                                                                      result)
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-3515})))))])
              (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3513})
                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3517} (__AST-e
                                                                   #{ast-val dpuuv4a3mobea70icwo8nvdax-3513})]
                         [#{ehd dpuuv4a3mobea70icwo8nvdax-3518} (\x23;\x23;car
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3517})]
                         [#{etl dpuuv4a3mobea70icwo8nvdax-3519} (\x23;\x23;cdr
                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-3517})])
                    (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-3518}])
                      (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-3519}])
                        (loop
                          #'rest
                          (let ([#{f dpuuv4a3mobea70icwo8nvdax-3520} cons])
                            (fold-left
                              (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3521}
                                       #{e dpuuv4a3mobea70icwo8nvdax-3522})
                                (#{f dpuuv4a3mobea70icwo8nvdax-3520}
                                  #{e dpuuv4a3mobea70icwo8nvdax-3522}
                                  #{a dpuuv4a3mobea70icwo8nvdax-3521}))
                              result
                              (flatten #'hd)))))))
                  (#{fail dpuuv4a3mobea70icwo8nvdax-3514})))))))
  (let loop ([rest (flatten bindings)]
             [locals (current-compile-local-env)])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3523} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3523})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3524} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3523})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-3525} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3523})])
            (if (identifier? #{hd dpuuv4a3mobea70icwo8nvdax-3524})
                (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-3524}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3525}])
                    (begin
                      (loop rest (cons (identifier-symbol id) locals)))))
                (if (identifier?
                      #{match-val dpuuv4a3mobea70icwo8nvdax-3523})
                    (let ([id #{match-val dpuuv4a3mobea70icwo8nvdax-3523}])
                      (begin (cons (identifier-symbol id) locals)))
                    (begin locals))))
          (if (identifier?
                #{match-val dpuuv4a3mobea70icwo8nvdax-3523})
              (let ([id #{match-val dpuuv4a3mobea70icwo8nvdax-3523}])
                (begin (cons (identifier-symbol id) locals)))
              (begin locals))))))

(define (xform-operands self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3526} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3527} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3526}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3526})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3528} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3526})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3529} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3528})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3530} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3528})])
            (let ([form #{ehd dpuuv4a3mobea70icwo8nvdax-3529}])
              (let ([rands #{etl dpuuv4a3mobea70icwo8nvdax-3530}])
                (let ([rands (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3531})
                                    (compile-e
                                      self
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-3531}))
                                  #'rands)])
                  (xform-wrap-source (cons* #'form rands) stx)))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3527})))))

(define xform-call% xform-operands)

(define (xform-setq% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-3532} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-3533} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-3532}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-3532})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3534} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-3532})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-3535} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3534})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-3536} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-3534})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3536})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3537} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-3536})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-3538} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3537})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-3539} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-3537})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-3538}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-3539})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-3540} (__AST-e
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-3539})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-3541} (\x23;\x23;car
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3540})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-3542} (\x23;\x23;cdr
                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-3540})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-3541}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-3542}))
                                (let ([expr (compile-e self #'expr)])
                                  (xform-wrap-source
                                    (list '%\x23;set! #'id expr)
                                    stx))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-3533}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-3533}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-3533})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-3533})))))

