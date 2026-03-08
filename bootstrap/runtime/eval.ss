(begin
  (define __syntax::t
    (make-class-type 'gerbil\x23;__syntax::t '__syntax
      (list object::t) '(e id) '((struct: . #t)) '#f))
  (define (make-__syntax . args)
    (let* ([type __syntax::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (__syntax? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;__syntax::t))
  (define (__syntax-e obj) (unchecked-slot-ref obj 'e))
  (define (__syntax-id obj) (unchecked-slot-ref obj 'id))
  (define (__syntax-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (__syntax-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&__syntax-e obj) (unchecked-slot-ref obj 'e))
  (define (&__syntax-id obj) (unchecked-slot-ref obj 'id))
  (define (&__syntax-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&__syntax-id-set! obj val)
    (unchecked-slot-set! obj 'id val)))

(begin
  (define __core-form::t
    (make-class-type 'gerbil\x23;__core-form::t '__core-form
      (list __syntax::t) '() '((struct: . #t)) '#f))
  (define (make-__core-form . args)
    (let* ([type __core-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (__core-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;__core-form::t)))

(begin
  (define __core-expression::t
    (make-class-type 'gerbil\x23;__core-expression::t '__core-expression
      (list __core-form::t) '() '((struct: . #t)) '#f))
  (define (make-__core-expression . args)
    (let* ([type __core-expression::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (__core-expression? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;__core-expression::t)))

(begin
  (define __core-special-form::t
    (make-class-type 'gerbil\x23;__core-special-form::t '__core-special-form
      (list __core-form::t) '() '((struct: . #t)) '#f))
  (define (make-__core-special-form . args)
    (let* ([type __core-special-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (__core-special-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;__core-special-form::t)))

(define __core (make-hash-table-eq))

(define __current-expander (make-parameter #f))

(define __current-compiler (make-parameter #f))

(define __current-path (make-parameter '()))

(define (__core-resolve id) (hash-get __core (__AST-e id)))

(define __core-bound-id?
  (case-lambda
    [(id)
     (let* ([is? true])
       (cond [(__core-resolve id) => is?] [else #f]))]
    [(id is?) (cond [(__core-resolve id) => is?] [else #f])]))

(define __core-bind-syntax!
  (case-lambda
    [(id e)
     (let* ([make make-__syntax])
       (hash-put! __core id (if (__syntax? e) e (make e id))))]
    [(id e make)
     (hash-put! __core id (if (__syntax? e) e (make e id)))]))

(define __SRC
  (case-lambda
    [(e)
     (let* ([src-stx #f])
       (cond
         [(or (pair? e) (symbol? e))
          (\x23;\x23;make-source
            e
            (and (AST? src-stx) (__locat (__AST-source src-stx))))]
         [(AST? e)
          (\x23;\x23;make-source
            (&AST-e e)
            (__locat (__AST-source e)))]
         [else (error 'gerbil "BUG! Cannot sourcify object" e)]))]
    [(e src-stx)
     (cond
       [(or (pair? e) (symbol? e))
        (\x23;\x23;make-source
          e
          (and (AST? src-stx) (__locat (__AST-source src-stx))))]
       [(AST? e)
        (\x23;\x23;make-source
          (&AST-e e)
          (__locat (__AST-source e)))]
       [else (error 'gerbil "BUG! Cannot sourcify object" e)])]))

(define (__locat loc) (and (\x23;\x23;locat? loc) loc))

(define (__check-values obj k)
  (let ([count (values-count obj)])
    (unless (fx= count k)
      (error 'gerbil
        (if (fx< count k)
            "Too few values for context"
            "Too many values for context")
        (if (\x23;\x23;values? obj)
            (\x23;\x23;values->list obj)
            obj)
        k))))

(define (__compile stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-146} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-147} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-146}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-146})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-148} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-146})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-149} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-148})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-150} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-148})])
            (let ([form #{ehd dpuuv4a3mobea70icwo8nvdax-149}])
              (cond
                [(__core-resolve form) =>
                 (lambda (bind) ((__syntax-e bind) stx))]
                [else
                 (__raise-syntax-error
                   #f
                   "Bad syntax; cannot resolve form"
                   stx
                   form)])))
          (#{fail dpuuv4a3mobea70icwo8nvdax-147})))))

(define __compile-error
  (case-lambda
    [(stx)
     (let* ([detail #f])
       (__raise-syntax-error
         'compile
         "Bad syntax; cannot compile"
         stx
         detail))]
    [(stx detail)
     (__raise-syntax-error
       'compile
       "Bad syntax; cannot compile"
       stx
       detail)]))

(define (__compile-ignore% stx)
  (__SRC (cons 'quote (cons (%%void) '())) stx))

(define (__compile-begin% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-151} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-152} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-151}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-151})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-153} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-151})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-154} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-153})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-155} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-153})])
            (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-155}])
              (__SRC (cons 'begin (map __compile body)) stx)))
          (#{fail dpuuv4a3mobea70icwo8nvdax-152})))))

(define (__compile-begin-foreign% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-156} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-157} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-156}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-156})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-158} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-156})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-159} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-158})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-160} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-158})])
            (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-160}])
              (__SRC (cons 'begin (__AST->datum body)) stx)))
          (#{fail dpuuv4a3mobea70icwo8nvdax-157})))))

(define (__compile-import% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-161} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-162} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-161}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-161})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-163} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-161})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-164} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-163})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-165} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-163})])
            (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-165}])
              (__SRC `(__eval-import ',body) stx)))
          (#{fail dpuuv4a3mobea70icwo8nvdax-162})))))

(define (__compile-begin-annotation% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-166} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-167} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-166}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-166})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-168} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-166})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-169} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-168})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-170} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-168})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-170})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-171} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-170})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-172} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-171})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-173} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-171})])
                  (let ([ann #{ehd dpuuv4a3mobea70icwo8nvdax-172}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-173})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-174} (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-173})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-175} (\x23;\x23;car
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-174})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-176} (\x23;\x23;cdr
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-174})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-175}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-176}))
                                (__compile expr)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-167}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-167}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-167})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-167})))))

(define (__compile-define-values% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-177} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-178} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-177}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-177})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-179} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-177})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-180} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-179})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-181} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-179})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-181})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-182} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-181})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-183} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-182})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-184} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-182})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-183}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-184})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-185} (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-184})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-186} (\x23;\x23;car
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-185})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-187} (\x23;\x23;cdr
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-185})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-186}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-187}))
                                (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-188} hd])
                                  (let ([#{fail dpuuv4a3mobea70icwo8nvdax-189} (lambda ()
                                                                                 (let ([#{fail dpuuv4a3mobea70icwo8nvdax-190} (lambda ()
                                                                                                                                (begin
                                                                                                                                  (let* ([ids hd])
                                                                                                                                    (let* ([len (length
                                                                                                                                                  ids)])
                                                                                                                                      (let* ([tmp (__SRC
                                                                                                                                                    (gensym))])
                                                                                                                                        (__SRC
                                                                                                                                          `(begin
                                                                                                                                             ,(__SRC
                                                                                                                                                `(define (unquote
                                                                                                                                                          tmp)
                                                                                                                                                   ,(__compile
                                                                                                                                                      expr))
                                                                                                                                                stx)
                                                                                                                                             ,(__SRC
                                                                                                                                                `(__check-values
                                                                                                                                                   ,tmp
                                                                                                                                                   ,len)
                                                                                                                                                stx)
                                                                                                                                             ,@(filter-map
                                                                                                                                                 (lambda (id
                                                                                                                                                          k)
                                                                                                                                                   (and (__AST-e
                                                                                                                                                          id)
                                                                                                                                                        (__SRC
                                                                                                                                                          `(define (unquote
                                                                                                                                                                    (__SRC
                                                                                                                                                                      id))
                                                                                                                                                             (\x23;\x23;values-ref
                                                                                                                                                               ,tmp
                                                                                                                                                               ,k))
                                                                                                                                                          stx)))
                                                                                                                                                 ids
                                                                                                                                                 (iota
                                                                                                                                                   len)))
                                                                                                                                          stx))))))])
                                                                                   (if (__AST-pair?
                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-188})
                                                                                       (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-191} (__AST-e
                                                                                                                                       #{ast-val dpuuv4a3mobea70icwo8nvdax-188})]
                                                                                              [#{ehd dpuuv4a3mobea70icwo8nvdax-192} (\x23;\x23;car
                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-191})]
                                                                                              [#{etl dpuuv4a3mobea70icwo8nvdax-193} (\x23;\x23;cdr
                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-191})])
                                                                                         (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-192}])
                                                                                           (if (null?
                                                                                                 (__AST-e
                                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-193}))
                                                                                               (__SRC
                                                                                                 `(define (unquote
                                                                                                           (__SRC
                                                                                                             id))
                                                                                                    ,(__compile
                                                                                                       expr))
                                                                                                 stx)
                                                                                               (#{fail dpuuv4a3mobea70icwo8nvdax-190}))))
                                                                                       (#{fail dpuuv4a3mobea70icwo8nvdax-190}))))])
                                    (if (__AST-pair?
                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-188})
                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-194} (__AST-e
                                                                                        #{ast-val dpuuv4a3mobea70icwo8nvdax-188})]
                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-195} (\x23;\x23;car
                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-194})]
                                               [#{etl dpuuv4a3mobea70icwo8nvdax-196} (\x23;\x23;cdr
                                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-194})])
                                          (if (equal?
                                                (__AST-e
                                                  #{ehd dpuuv4a3mobea70icwo8nvdax-195})
                                                '#f)
                                              (if (null?
                                                    (__AST-e
                                                      #{etl dpuuv4a3mobea70icwo8nvdax-196}))
                                                  (__compile expr)
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-189}))
                                              (#{fail dpuuv4a3mobea70icwo8nvdax-189})))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-189}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-178}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-178}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-178})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-178})))))

(define (__compile-head-id e)
  (__SRC (if (__AST-e e) e (gensym))))

(define (__compile-lambda-head hd)
  (let recur ([rest hd])
    (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-197} rest])
      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-198} (lambda ()
                                                     (let ([#{fail dpuuv4a3mobea70icwo8nvdax-199} (lambda ()
                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-200} (lambda ()
                                                                                                                                                   (__raise-syntax-error
                                                                                                                                                     #f
                                                                                                                                                     "Bad syntax; malformed ast clause"
                                                                                                                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-197}))])
                                                                                                      (let ([tail #{ast-val dpuuv4a3mobea70icwo8nvdax-197}])
                                                                                                        (__compile-head-id
                                                                                                          tail))))])
                                                       (if (null?
                                                             (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-197}))
                                                           '()
                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-199}))))])
        (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-197})
            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-201} (__AST-e
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-197})]
                   [#{ehd dpuuv4a3mobea70icwo8nvdax-202} (\x23;\x23;car
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-201})]
                   [#{etl dpuuv4a3mobea70icwo8nvdax-203} (\x23;\x23;cdr
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-201})])
              (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-202}])
                (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-203}])
                  (cons (__compile-head-id hd) (recur rest)))))
            (#{fail dpuuv4a3mobea70icwo8nvdax-198}))))))

(define (__compile-lambda% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-204} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-205} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-204}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-204})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-206} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-204})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-207} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-206})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-208} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-206})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-208})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-209} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-208})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-210} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-209})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-211} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-209})])
                  (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-210}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-211})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-212} (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-211})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-213} (\x23;\x23;car
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-212})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-214} (\x23;\x23;cdr
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-212})])
                          (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-213}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-214}))
                                (__SRC
                                  `(lambda (unquote
                                            (__compile-lambda-head hd))
                                     ,(__compile body))
                                  stx)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-205}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-205}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-205})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-205})))))

(define (__compile-case-lambda% stx)
  (define (variadic? hd)
    (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-215} hd])
      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-216} (lambda ()
                                                     (let ([#{fail dpuuv4a3mobea70icwo8nvdax-217} (lambda ()
                                                                                                    (begin
                                                                                                      #t))])
                                                       (if (null?
                                                             (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-215}))
                                                           #f
                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-217}))))])
        (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-215})
            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-218} (__AST-e
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-215})]
                   [#{ehd dpuuv4a3mobea70icwo8nvdax-219} (\x23;\x23;car
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-218})]
                   [#{etl dpuuv4a3mobea70icwo8nvdax-220} (\x23;\x23;cdr
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-218})])
              (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-220}])
                (variadic? rest)))
            (#{fail dpuuv4a3mobea70icwo8nvdax-216})))))
  (define (arity hd)
    (let lp ([rest hd] [k 0])
      (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-221} rest])
        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-222} (lambda ()
                                                       (begin k))])
          (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-221})
              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-223} (__AST-e
                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-221})]
                     [#{ehd dpuuv4a3mobea70icwo8nvdax-224} (\x23;\x23;car
                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-223})]
                     [#{etl dpuuv4a3mobea70icwo8nvdax-225} (\x23;\x23;cdr
                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-223})])
                (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-225}])
                  (lp rest (fx1+ k))))
              (#{fail dpuuv4a3mobea70icwo8nvdax-222}))))))
  (define (generate rest args len)
    (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-226} rest])
      (let ([#{fail dpuuv4a3mobea70icwo8nvdax-227} (lambda ()
                                                     (begin
                                                       (__SRC
                                                         `(error "No clause matching arguments"
                                                            ,args)
                                                         stx)))])
        (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-226})
            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-228} (__AST-e
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-226})]
                   [#{ehd dpuuv4a3mobea70icwo8nvdax-229} (\x23;\x23;car
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-228})]
                   [#{etl dpuuv4a3mobea70icwo8nvdax-230} (\x23;\x23;cdr
                                                           #{etgt dpuuv4a3mobea70icwo8nvdax-228})])
              (let ([clause #{ehd dpuuv4a3mobea70icwo8nvdax-229}])
                (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-230}])
                  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-231} clause])
                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-232} (lambda ()
                                                                   (__raise-syntax-error
                                                                     #f
                                                                     "Bad syntax; malformed ast clause"
                                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-231}))])
                      (if (__AST-pair?
                            #{ast-val dpuuv4a3mobea70icwo8nvdax-231})
                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-233} (__AST-e
                                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-231})]
                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-234} (\x23;\x23;car
                                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-233})]
                                 [#{etl dpuuv4a3mobea70icwo8nvdax-235} (\x23;\x23;cdr
                                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-233})])
                            (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-234}])
                              (if (__AST-pair?
                                    #{etl dpuuv4a3mobea70icwo8nvdax-235})
                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-236} (__AST-e
                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-235})]
                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-237} (\x23;\x23;car
                                                                                 #{etgt dpuuv4a3mobea70icwo8nvdax-236})]
                                         [#{etl dpuuv4a3mobea70icwo8nvdax-238} (\x23;\x23;cdr
                                                                                 #{etgt dpuuv4a3mobea70icwo8nvdax-236})])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-238}))
                                        (let ([clen (arity hd)]
                                              [cmp (if (variadic? hd)
                                                       'fx>=
                                                       'fx=)])
                                          (__SRC
                                            `(if (,cmp ,len ,clen)
                                                 ,(__SRC
                                                    `(\x23;\x23;apply
                                                       ,(__compile-lambda%
                                                          (cons
                                                            '%\x23;lambda
                                                            clause))
                                                       ,args)
                                                    stx)
                                                 ,(generate rest args len))
                                            stx))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-232})))
                                  (#{fail dpuuv4a3mobea70icwo8nvdax-232}))))
                          (#{fail dpuuv4a3mobea70icwo8nvdax-232})))))))
            (#{fail dpuuv4a3mobea70icwo8nvdax-227})))))
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-239} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-240} (lambda ()
                                                   (let ([#{fail dpuuv4a3mobea70icwo8nvdax-241} (lambda ()
                                                                                                  (__raise-syntax-error
                                                                                                    #f
                                                                                                    "Bad syntax; malformed ast clause"
                                                                                                    #{ast-val dpuuv4a3mobea70icwo8nvdax-239}))])
                                                     (if (__AST-pair?
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-239})
                                                         (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-242} (__AST-e
                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-239})]
                                                                [#{ehd dpuuv4a3mobea70icwo8nvdax-243} (\x23;\x23;car
                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-242})]
                                                                [#{etl dpuuv4a3mobea70icwo8nvdax-244} (\x23;\x23;cdr
                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-242})])
                                                           (let ([clauses #{etl dpuuv4a3mobea70icwo8nvdax-244}])
                                                             (let ([args (__SRC
                                                                           (gensym)
                                                                           stx)]
                                                                   [len (__SRC
                                                                          (gensym)
                                                                          stx)])
                                                               (__SRC
                                                                 `(lambda (unquote
                                                                           args)
                                                                    ,(__SRC
                                                                       `(let ([,len ,(__SRC
                                                                                       `(\x23;\x23;length
                                                                                          ,args)
                                                                                       stx)])
                                                                          ,(generate
                                                                             clauses
                                                                             args
                                                                             len))
                                                                       stx))
                                                                 stx))))
                                                         (#{fail dpuuv4a3mobea70icwo8nvdax-241}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-239})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-245} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-239})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-246} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-245})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-247} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-245})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-247})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-248} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-247})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-249} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-248})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-250} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-248})])
                  (let ([clause #{ehd dpuuv4a3mobea70icwo8nvdax-249}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-250}))
                        (__compile-lambda% (cons '%\x23;lambda clause))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-240}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-240})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-240})))))

(define (__compile-let-form stx compile-simple
         compile-values)
  (define (simple-bind? hd)
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-251} hd])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-251})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-252} (car #{match-val dpuuv4a3mobea70icwo8nvdax-251})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-253} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-251})])
            (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-252}])
              (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-253})
                  (begin #t)
                  (if (equal?
                        #{match-val dpuuv4a3mobea70icwo8nvdax-251}
                        '#f)
                      (begin #t)
                      (begin #f)))))
          (if (equal? #{match-val dpuuv4a3mobea70icwo8nvdax-251} '#f)
              (begin #t)
              (begin #f)))))
  (define (car-e hd) (if (pair? hd) (car hd) hd))
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-254} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-255} (lambda ()
                                                   (let ([#{fail dpuuv4a3mobea70icwo8nvdax-256} (lambda ()
                                                                                                  (__raise-syntax-error
                                                                                                    #f
                                                                                                    "Bad syntax; malformed ast clause"
                                                                                                    #{ast-val dpuuv4a3mobea70icwo8nvdax-254}))])
                                                     (if (__AST-pair?
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-254})
                                                         (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-257} (__AST-e
                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-254})]
                                                                [#{ehd dpuuv4a3mobea70icwo8nvdax-258} (\x23;\x23;car
                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-257})]
                                                                [#{etl dpuuv4a3mobea70icwo8nvdax-259} (\x23;\x23;cdr
                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-257})])
                                                           (if (__AST-pair?
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-259})
                                                               (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-260} (__AST-e
                                                                                                               #{etl dpuuv4a3mobea70icwo8nvdax-259})]
                                                                      [#{ehd dpuuv4a3mobea70icwo8nvdax-261} (\x23;\x23;car
                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-260})]
                                                                      [#{etl dpuuv4a3mobea70icwo8nvdax-262} (\x23;\x23;cdr
                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-260})])
                                                                 (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-261}])
                                                                   (if (__AST-pair?
                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-262})
                                                                       (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-263} (__AST-e
                                                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-262})]
                                                                              [#{ehd dpuuv4a3mobea70icwo8nvdax-264} (\x23;\x23;car
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-263})]
                                                                              [#{etl dpuuv4a3mobea70icwo8nvdax-265} (\x23;\x23;cdr
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-263})])
                                                                         (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-264}])
                                                                           (if (null?
                                                                                 (__AST-e
                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-265}))
                                                                               (let* ([hd-ids (map (lambda (bind)
                                                                                                     (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-266} bind])
                                                                                                       (let ([#{fail dpuuv4a3mobea70icwo8nvdax-267} (lambda ()
                                                                                                                                                      (__raise-syntax-error
                                                                                                                                                        #f
                                                                                                                                                        "Bad syntax; malformed ast clause"
                                                                                                                                                        #{ast-val dpuuv4a3mobea70icwo8nvdax-266}))])
                                                                                                         (if (__AST-pair?
                                                                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-266})
                                                                                                             (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-268} (__AST-e
                                                                                                                                                             #{ast-val dpuuv4a3mobea70icwo8nvdax-266})]
                                                                                                                    [#{ehd dpuuv4a3mobea70icwo8nvdax-269} (\x23;\x23;car
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-268})]
                                                                                                                    [#{etl dpuuv4a3mobea70icwo8nvdax-270} (\x23;\x23;cdr
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-268})])
                                                                                                               (let ([ids #{ehd dpuuv4a3mobea70icwo8nvdax-269}])
                                                                                                                 (if (__AST-pair?
                                                                                                                       #{etl dpuuv4a3mobea70icwo8nvdax-270})
                                                                                                                     (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-271} (__AST-e
                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-270})]
                                                                                                                            [#{ehd dpuuv4a3mobea70icwo8nvdax-272} (\x23;\x23;car
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-271})]
                                                                                                                            [#{etl dpuuv4a3mobea70icwo8nvdax-273} (\x23;\x23;cdr
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-271})])
                                                                                                                       (if (null?
                                                                                                                             (__AST-e
                                                                                                                               #{etl dpuuv4a3mobea70icwo8nvdax-273}))
                                                                                                                           ids
                                                                                                                           (#{fail dpuuv4a3mobea70icwo8nvdax-267})))
                                                                                                                     (#{fail dpuuv4a3mobea70icwo8nvdax-267}))))
                                                                                                             (#{fail dpuuv4a3mobea70icwo8nvdax-267})))))
                                                                                                   hd)])
                                                                                 (let* ([exprs (map (lambda (bind)
                                                                                                      (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-274} bind])
                                                                                                        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-275} (lambda ()
                                                                                                                                                       (__raise-syntax-error
                                                                                                                                                         #f
                                                                                                                                                         "Bad syntax; malformed ast clause"
                                                                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-274}))])
                                                                                                          (if (__AST-pair?
                                                                                                                #{ast-val dpuuv4a3mobea70icwo8nvdax-274})
                                                                                                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-276} (__AST-e
                                                                                                                                                              #{ast-val dpuuv4a3mobea70icwo8nvdax-274})]
                                                                                                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-277} (\x23;\x23;car
                                                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-276})]
                                                                                                                     [#{etl dpuuv4a3mobea70icwo8nvdax-278} (\x23;\x23;cdr
                                                                                                                                                             #{etgt dpuuv4a3mobea70icwo8nvdax-276})])
                                                                                                                (if (__AST-pair?
                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-278})
                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-279} (__AST-e
                                                                                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-278})]
                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-280} (\x23;\x23;car
                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-279})]
                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-281} (\x23;\x23;cdr
                                                                                                                                                                   #{etgt dpuuv4a3mobea70icwo8nvdax-279})])
                                                                                                                      (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-280}])
                                                                                                                        (if (null?
                                                                                                                              (__AST-e
                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-281}))
                                                                                                                            (__compile
                                                                                                                              expr)
                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-275}))))
                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-275})))
                                                                                                              (#{fail dpuuv4a3mobea70icwo8nvdax-275})))))
                                                                                                    hd)])
                                                                                   (let* ([body (__compile
                                                                                                  body)])
                                                                                     (if (andmap
                                                                                           simple-bind?
                                                                                           hd-ids)
                                                                                         (compile-simple
                                                                                           (map car-e
                                                                                                hd-ids)
                                                                                           exprs
                                                                                           body)
                                                                                         (compile-values
                                                                                           hd-ids
                                                                                           exprs
                                                                                           body)))))
                                                                               (#{fail dpuuv4a3mobea70icwo8nvdax-256}))))
                                                                       (#{fail dpuuv4a3mobea70icwo8nvdax-256}))))
                                                               (#{fail dpuuv4a3mobea70icwo8nvdax-256})))
                                                         (#{fail dpuuv4a3mobea70icwo8nvdax-256}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-254})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-282} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-254})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-283} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-282})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-284} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-282})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-284})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-285} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-284})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-286} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-285})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-287} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-285})])
                  (if (null?
                        (__AST-e #{ehd dpuuv4a3mobea70icwo8nvdax-286}))
                      (if (__AST-pair?
                            #{etl dpuuv4a3mobea70icwo8nvdax-287})
                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-288} (__AST-e
                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-287})]
                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-289} (\x23;\x23;car
                                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-288})]
                                 [#{etl dpuuv4a3mobea70icwo8nvdax-290} (\x23;\x23;cdr
                                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-288})])
                            (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-289}])
                              (if (null?
                                    (__AST-e
                                      #{etl dpuuv4a3mobea70icwo8nvdax-290}))
                                  (__compile body)
                                  (#{fail dpuuv4a3mobea70icwo8nvdax-255}))))
                          (#{fail dpuuv4a3mobea70icwo8nvdax-255}))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-255})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-255})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-255})))))

(define (__compile-let-values% stx)
  (define (compile-simple hd-ids exprs body)
    (__SRC
      `(let (unquote
             [map list (map __compile-head-id hd-ids) exprs])
         ,body)
      stx))
  (define (compile-values hd-ids exprs body)
    (let lp ([rest hd-ids] [exprs exprs] [bind '()] [post '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-291} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-291})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-292} (car #{match-val dpuuv4a3mobea70icwo8nvdax-291})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-293} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-291})])
              (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-292})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-294} (car #{hd dpuuv4a3mobea70icwo8nvdax-292})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-295} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-292})])
                    (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-294}])
                      (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-295})
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-293}])
                            (begin
                              (lp rest
                                  (cdr exprs)
                                  (cons
                                    `(,(__compile-head-id id) ,(car exprs))
                                    bind)
                                  post)))
                          (if (pair?
                                #{match-val dpuuv4a3mobea70icwo8nvdax-291})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-296} (car #{match-val dpuuv4a3mobea70icwo8nvdax-291})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-297} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-291})])
                                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-296}])
                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-297}])
                                    (begin
                                      (cond
                                        [(__AST-id? hd)
                                         (lp rest
                                             (cdr exprs)
                                             (cons
                                               `(,(__compile-head-id hd)
                                                  (values->list
                                                    ,(car exprs)))
                                               bind)
                                             post)]
                                        [(list? hd)
                                         (let* ([len (length hd)])
                                           (let* ([tmp (__SRC (gensym))])
                                             (lp rest
                                                 (cdr exprs)
                                                 (cons
                                                   `(,tmp ,(car exprs))
                                                   bind)
                                                 (cons
                                                   (cons*
                                                     tmp
                                                     len
                                                     (filter-map
                                                       (lambda (id k)
                                                         (and (__AST-e id)
                                                              (cons
                                                                (__SRC id)
                                                                k)))
                                                       hd
                                                       (iota len)))
                                                   post))))]
                                        [else
                                         (__compile-error stx hd)])))))
                              (begin
                                (__SRC
                                  `(let (unquote [reverse bind])
                                     ,(compile-post post body))
                                  stx))))))
                  (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-291})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-296} (car #{match-val dpuuv4a3mobea70icwo8nvdax-291})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-297} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-291})])
                        (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-296}])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-297}])
                            (begin
                              (cond
                                [(__AST-id? hd)
                                 (lp rest
                                     (cdr exprs)
                                     (cons
                                       `(,(__compile-head-id hd)
                                          (values->list ,(car exprs)))
                                       bind)
                                     post)]
                                [(list? hd)
                                 (let* ([len (length hd)])
                                   (let* ([tmp (__SRC (gensym))])
                                     (lp rest
                                         (cdr exprs)
                                         (cons `(,tmp ,(car exprs)) bind)
                                         (cons
                                           (cons*
                                             tmp
                                             len
                                             (filter-map
                                               (lambda (id k)
                                                 (and (__AST-e id)
                                                      (cons (__SRC id) k)))
                                               hd
                                               (iota len)))
                                           post))))]
                                [else (__compile-error stx hd)])))))
                      (begin
                        (__SRC
                          `(let (unquote [reverse bind])
                             ,(compile-post post body))
                          stx)))))
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-291})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-296} (car #{match-val dpuuv4a3mobea70icwo8nvdax-291})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-297} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-291})])
                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-296}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-297}])
                      (begin
                        (cond
                          [(__AST-id? hd)
                           (lp rest
                               (cdr exprs)
                               (cons
                                 `(,(__compile-head-id hd)
                                    (values->list ,(car exprs)))
                                 bind)
                               post)]
                          [(list? hd)
                           (let* ([len (length hd)])
                             (let* ([tmp (__SRC (gensym))])
                               (lp rest
                                   (cdr exprs)
                                   (cons `(,tmp ,(car exprs)) bind)
                                   (cons
                                     (cons*
                                       tmp
                                       len
                                       (filter-map
                                         (lambda (id k)
                                           (and (__AST-e id)
                                                (cons (__SRC id) k)))
                                         hd
                                         (iota len)))
                                     post))))]
                          [else (__compile-error stx hd)])))))
                (begin
                  (__SRC
                    `(let (unquote [reverse bind])
                       ,(compile-post post body))
                    stx)))))))
  (define (compile-post post body)
    (let lp ([rest post] [check '()] [bind '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-298} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-298})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-299} (car #{match-val dpuuv4a3mobea70icwo8nvdax-298})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-300} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-298})])
              (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-299})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-301} (car #{hd dpuuv4a3mobea70icwo8nvdax-299})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-302} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-299})])
                    (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-301}])
                      (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-302})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-303} (car #{tl dpuuv4a3mobea70icwo8nvdax-302})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-304} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-302})])
                            (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-303}])
                              (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-304}])
                                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-300}])
                                  (begin
                                    (lp rest
                                        (cons
                                          (__SRC
                                            `(__check-values ,tmp ,len)
                                            stx)
                                          check)
                                        (fold-right
                                          (lambda (hd r)
                                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-305} hd])
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-305})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-306} (car #{match-val dpuuv4a3mobea70icwo8nvdax-305})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-307} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-305})])
                                                    (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-306}])
                                                      (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-307}])
                                                        (begin
                                                          (cons
                                                            `(,id (\x23;\x23;values-ref
                                                                    ,tmp
                                                                    ,k))
                                                            r)))))
                                                  (error 'match
                                                    "no matching clause"
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-305}))))
                                          bind
                                          init)))))))
                          (begin
                            (__SRC
                              `(begin
                                 ,@check
                                 ,(__SRC `(let (unquote bind) ,body) stx))
                              stx)))))
                  (begin
                    (__SRC
                      `(begin
                         ,@check
                         ,(__SRC `(let (unquote bind) ,body) stx))
                      stx))))
            (begin
              (__SRC
                `(begin ,@check ,(__SRC `(let (unquote bind) ,body) stx))
                stx))))))
  (__compile-let-form stx compile-simple compile-values))

(define (__compile-letrec-values% stx)
  (define (compile-simple hd-ids exprs body)
    (__SRC
      `(letrec (unquote
                [map list (map __compile-head-id hd-ids) exprs])
         ,body)
      stx))
  (define (compile-values hd-ids exprs body)
    (let lp ([rest hd-ids]
             [exprs exprs]
             [pre '()]
             [bind '()]
             [post '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-308} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-308})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-309} (car #{match-val dpuuv4a3mobea70icwo8nvdax-308})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-310} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-308})])
              (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-309})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-311} (car #{hd dpuuv4a3mobea70icwo8nvdax-309})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-312} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-309})])
                    (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-311}])
                      (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-312})
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-310}])
                            (begin
                              (lp rest (cdr exprs) pre
                                  (cons
                                    `(,(__compile-head-id id) ,(car exprs))
                                    bind)
                                  post)))
                          (if (pair?
                                #{match-val dpuuv4a3mobea70icwo8nvdax-308})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-313} (car #{match-val dpuuv4a3mobea70icwo8nvdax-308})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-314} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-308})])
                                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-313}])
                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-314}])
                                    (begin
                                      (cond
                                        [(__AST-id? hd)
                                         (lp rest (cdr exprs) pre
                                             (cons
                                               `(,(__compile-head-id hd)
                                                  (values->list
                                                    ,(car exprs)))
                                               bind)
                                             post)]
                                        [(list? hd)
                                         (let* ([len (length hd)])
                                           (let* ([tmp (__SRC (gensym))])
                                             (lp rest (cdr exprs)
                                                 (let ([#{f dpuuv4a3mobea70icwo8nvdax-315} (lambda (id
                                                                                                    r)
                                                                                             (if (__AST-e
                                                                                                   id)
                                                                                                 (cons
                                                                                                   `(,(__SRC
                                                                                                        id)
                                                                                                      ',(%%void))
                                                                                                   r)
                                                                                                 r))])
                                                   (fold-left
                                                     (lambda (#{a dpuuv4a3mobea70icwo8nvdax-316}
                                                              #{e dpuuv4a3mobea70icwo8nvdax-317})
                                                       (#{f dpuuv4a3mobea70icwo8nvdax-315}
                                                         #{e dpuuv4a3mobea70icwo8nvdax-317}
                                                         #{a dpuuv4a3mobea70icwo8nvdax-316}))
                                                     pre
                                                     hd))
                                                 (cons
                                                   `(,tmp ,(car exprs))
                                                   bind)
                                                 (cons
                                                   (cons*
                                                     tmp
                                                     len
                                                     (filter-map
                                                       (lambda (id k)
                                                         (and (__AST-e id)
                                                              (cons
                                                                (__SRC id)
                                                                k)))
                                                       hd
                                                       (iota len)))
                                                   post))))]
                                        [else
                                         (__compile-error stx hd)])))))
                              (begin
                                (compile-inner pre bind post body))))))
                  (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-308})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-313} (car #{match-val dpuuv4a3mobea70icwo8nvdax-308})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-314} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-308})])
                        (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-313}])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-314}])
                            (begin
                              (cond
                                [(__AST-id? hd)
                                 (lp rest (cdr exprs) pre
                                     (cons
                                       `(,(__compile-head-id hd)
                                          (values->list ,(car exprs)))
                                       bind)
                                     post)]
                                [(list? hd)
                                 (let* ([len (length hd)])
                                   (let* ([tmp (__SRC (gensym))])
                                     (lp rest (cdr exprs)
                                         (let ([#{f dpuuv4a3mobea70icwo8nvdax-315} (lambda (id
                                                                                            r)
                                                                                     (if (__AST-e
                                                                                           id)
                                                                                         (cons
                                                                                           `(,(__SRC
                                                                                                id)
                                                                                              ',(%%void))
                                                                                           r)
                                                                                         r))])
                                           (fold-left
                                             (lambda (#{a dpuuv4a3mobea70icwo8nvdax-316}
                                                      #{e dpuuv4a3mobea70icwo8nvdax-317})
                                               (#{f dpuuv4a3mobea70icwo8nvdax-315}
                                                 #{e dpuuv4a3mobea70icwo8nvdax-317}
                                                 #{a dpuuv4a3mobea70icwo8nvdax-316}))
                                             pre
                                             hd))
                                         (cons `(,tmp ,(car exprs)) bind)
                                         (cons
                                           (cons*
                                             tmp
                                             len
                                             (filter-map
                                               (lambda (id k)
                                                 (and (__AST-e id)
                                                      (cons (__SRC id) k)))
                                               hd
                                               (iota len)))
                                           post))))]
                                [else (__compile-error stx hd)])))))
                      (begin (compile-inner pre bind post body)))))
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-308})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-313} (car #{match-val dpuuv4a3mobea70icwo8nvdax-308})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-314} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-308})])
                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-313}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-314}])
                      (begin
                        (cond
                          [(__AST-id? hd)
                           (lp rest (cdr exprs) pre
                               (cons
                                 `(,(__compile-head-id hd)
                                    (values->list ,(car exprs)))
                                 bind)
                               post)]
                          [(list? hd)
                           (let* ([len (length hd)])
                             (let* ([tmp (__SRC (gensym))])
                               (lp rest (cdr exprs)
                                   (let ([#{f dpuuv4a3mobea70icwo8nvdax-315} (lambda (id
                                                                                      r)
                                                                               (if (__AST-e
                                                                                     id)
                                                                                   (cons
                                                                                     `(,(__SRC
                                                                                          id)
                                                                                        ',(%%void))
                                                                                     r)
                                                                                   r))])
                                     (fold-left
                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-316}
                                                #{e dpuuv4a3mobea70icwo8nvdax-317})
                                         (#{f dpuuv4a3mobea70icwo8nvdax-315}
                                           #{e dpuuv4a3mobea70icwo8nvdax-317}
                                           #{a dpuuv4a3mobea70icwo8nvdax-316}))
                                       pre
                                       hd))
                                   (cons `(,tmp ,(car exprs)) bind)
                                   (cons
                                     (cons*
                                       tmp
                                       len
                                       (filter-map
                                         (lambda (id k)
                                           (and (__AST-e id)
                                                (cons (__SRC id) k)))
                                         hd
                                         (iota len)))
                                     post))))]
                          [else (__compile-error stx hd)])))))
                (begin (compile-inner pre bind post body)))))))
  (define (compile-inner pre bind post body)
    (if (null? pre)
        (compile-bind bind post body)
        (__SRC
          `(let (unquote [reverse pre])
             ,(compile-bind bind post body))
          stx)))
  (define (compile-bind bind post body)
    (__SRC
      `(letrec (unquote [reverse bind]) ,(compile-post post body))
      stx))
  (define (compile-post post body)
    (let lp ([rest post] [check '()] [bind '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-318} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-318})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-319} (car #{match-val dpuuv4a3mobea70icwo8nvdax-318})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-320} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-318})])
              (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-319})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-321} (car #{hd dpuuv4a3mobea70icwo8nvdax-319})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-322} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-319})])
                    (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-321}])
                      (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-322})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-323} (car #{tl dpuuv4a3mobea70icwo8nvdax-322})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-324} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-322})])
                            (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-323}])
                              (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-324}])
                                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-320}])
                                  (begin
                                    (lp rest
                                        (cons
                                          (__SRC
                                            `(__check-values ,tmp ,len)
                                            stx)
                                          check)
                                        (fold-right
                                          (lambda (hd r)
                                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-325} hd])
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-325})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-326} (car #{match-val dpuuv4a3mobea70icwo8nvdax-325})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-327} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-325})])
                                                    (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-326}])
                                                      (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-327}])
                                                        (begin
                                                          (cons
                                                            `(set! ,id
                                                               (\x23;\x23;values-ref
                                                                 ,tmp
                                                                 ,k))
                                                            r)))))
                                                  (error 'match
                                                    "no matching clause"
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-325}))))
                                          bind
                                          init)))))))
                          (begin
                            (__SRC `(begin ,@check ,@bind ,body) stx)))))
                  (begin (__SRC `(begin ,@check ,@bind ,body) stx))))
            (begin (__SRC `(begin ,@check ,@bind ,body) stx))))))
  (__compile-let-form stx compile-simple compile-values))

(define (__compile-letrec*-values% stx)
  (define (compile-simple hd-ids exprs body)
    (__SRC
      `(letrec* (unquote
                 [map list (map __compile-head-id hd-ids) exprs])
         ,body)
      stx))
  (define (compile-values hd-ids exprs body)
    (let lp ([rest hd-ids] [exprs exprs] [bind '()] [post '()])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-328} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-328})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-329} (car #{match-val dpuuv4a3mobea70icwo8nvdax-328})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-330} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-328})])
              (if (pair? #{hd dpuuv4a3mobea70icwo8nvdax-329})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-331} (car #{hd dpuuv4a3mobea70icwo8nvdax-329})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-332} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-329})])
                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-331}])
                      (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-332})
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-330}])
                            (begin
                              (if (__AST-id? hd)
                                  (let ([id (__SRC hd)])
                                    (lp rest
                                        (cdr exprs)
                                        (cons `(,id ',(%%void)) bind)
                                        (cons `(,id ,(car exprs)) post)))
                                  (lp rest
                                      (cdr exprs)
                                      bind
                                      (cons `(#f ,(car exprs)) post)))))
                          (if (pair?
                                #{match-val dpuuv4a3mobea70icwo8nvdax-328})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-333} (car #{match-val dpuuv4a3mobea70icwo8nvdax-328})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-334} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-328})])
                                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-333}])
                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-334}])
                                    (begin
                                      (cond
                                        [(__AST-id? hd)
                                         (let ([id (__SRC hd)])
                                           (lp rest
                                               (cdr exprs)
                                               (cons
                                                 `(,id ',(%%void))
                                                 bind)
                                               (cons
                                                 `(,id (values->list
                                                         ,(car exprs)))
                                                 post)))]
                                        [(not (__AST-e hd))
                                         (lp rest
                                             (cdr exprs)
                                             bind
                                             (cons
                                               `(#f ,(car exprs))
                                               post))]
                                        [(list? hd)
                                         (let* ([len (length hd)])
                                           (let* ([tmp (__SRC (gensym))])
                                             (lp rest
                                                 (cdr exprs)
                                                 (let ([#{f dpuuv4a3mobea70icwo8nvdax-335} (lambda (id
                                                                                                    r)
                                                                                             (if (__AST-e
                                                                                                   id)
                                                                                                 (cons
                                                                                                   `(,(__SRC
                                                                                                        id)
                                                                                                      ',(%%void))
                                                                                                   r)
                                                                                                 r))])
                                                   (fold-left
                                                     (lambda (#{a dpuuv4a3mobea70icwo8nvdax-336}
                                                              #{e dpuuv4a3mobea70icwo8nvdax-337})
                                                       (#{f dpuuv4a3mobea70icwo8nvdax-335}
                                                         #{e dpuuv4a3mobea70icwo8nvdax-337}
                                                         #{a dpuuv4a3mobea70icwo8nvdax-336}))
                                                     bind
                                                     hd))
                                                 (cons
                                                   (cons*
                                                     tmp
                                                     (car exprs)
                                                     len
                                                     (filter-map
                                                       (lambda (id k)
                                                         (and (__AST-e id)
                                                              (cons
                                                                (__SRC id)
                                                                k)))
                                                       hd
                                                       (iota len)))
                                                   post))))]
                                        [else
                                         (__compile-error stx hd)])))))
                              (begin (compile-bind bind post body))))))
                  (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-328})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-333} (car #{match-val dpuuv4a3mobea70icwo8nvdax-328})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-334} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-328})])
                        (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-333}])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-334}])
                            (begin
                              (cond
                                [(__AST-id? hd)
                                 (let ([id (__SRC hd)])
                                   (lp rest
                                       (cdr exprs)
                                       (cons `(,id ',(%%void)) bind)
                                       (cons
                                         `(,id (values->list ,(car exprs)))
                                         post)))]
                                [(not (__AST-e hd))
                                 (lp rest
                                     (cdr exprs)
                                     bind
                                     (cons `(#f ,(car exprs)) post))]
                                [(list? hd)
                                 (let* ([len (length hd)])
                                   (let* ([tmp (__SRC (gensym))])
                                     (lp rest
                                         (cdr exprs)
                                         (let ([#{f dpuuv4a3mobea70icwo8nvdax-335} (lambda (id
                                                                                            r)
                                                                                     (if (__AST-e
                                                                                           id)
                                                                                         (cons
                                                                                           `(,(__SRC
                                                                                                id)
                                                                                              ',(%%void))
                                                                                           r)
                                                                                         r))])
                                           (fold-left
                                             (lambda (#{a dpuuv4a3mobea70icwo8nvdax-336}
                                                      #{e dpuuv4a3mobea70icwo8nvdax-337})
                                               (#{f dpuuv4a3mobea70icwo8nvdax-335}
                                                 #{e dpuuv4a3mobea70icwo8nvdax-337}
                                                 #{a dpuuv4a3mobea70icwo8nvdax-336}))
                                             bind
                                             hd))
                                         (cons
                                           (cons*
                                             tmp
                                             (car exprs)
                                             len
                                             (filter-map
                                               (lambda (id k)
                                                 (and (__AST-e id)
                                                      (cons (__SRC id) k)))
                                               hd
                                               (iota len)))
                                           post))))]
                                [else (__compile-error stx hd)])))))
                      (begin (compile-bind bind post body)))))
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-328})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-333} (car #{match-val dpuuv4a3mobea70icwo8nvdax-328})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-334} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-328})])
                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-333}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-334}])
                      (begin
                        (cond
                          [(__AST-id? hd)
                           (let ([id (__SRC hd)])
                             (lp rest
                                 (cdr exprs)
                                 (cons `(,id ',(%%void)) bind)
                                 (cons
                                   `(,id (values->list ,(car exprs)))
                                   post)))]
                          [(not (__AST-e hd))
                           (lp rest
                               (cdr exprs)
                               bind
                               (cons `(#f ,(car exprs)) post))]
                          [(list? hd)
                           (let* ([len (length hd)])
                             (let* ([tmp (__SRC (gensym))])
                               (lp rest
                                   (cdr exprs)
                                   (let ([#{f dpuuv4a3mobea70icwo8nvdax-335} (lambda (id
                                                                                      r)
                                                                               (if (__AST-e
                                                                                     id)
                                                                                   (cons
                                                                                     `(,(__SRC
                                                                                          id)
                                                                                        ',(%%void))
                                                                                     r)
                                                                                   r))])
                                     (fold-left
                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-336}
                                                #{e dpuuv4a3mobea70icwo8nvdax-337})
                                         (#{f dpuuv4a3mobea70icwo8nvdax-335}
                                           #{e dpuuv4a3mobea70icwo8nvdax-337}
                                           #{a dpuuv4a3mobea70icwo8nvdax-336}))
                                       bind
                                       hd))
                                   (cons
                                     (cons*
                                       tmp
                                       (car exprs)
                                       len
                                       (filter-map
                                         (lambda (id k)
                                           (and (__AST-e id)
                                                (cons (__SRC id) k)))
                                         hd
                                         (iota len)))
                                     post))))]
                          [else (__compile-error stx hd)])))))
                (begin (compile-bind bind post body)))))))
  (define (compile-bind bind post body)
    (__SRC
      `(let (unquote [reverse bind]) ,(compile-post post body))
      stx))
  (define (compile-post post body)
    (__SRC
      `(begin
         ,@(let ([#{f dpuuv4a3mobea70icwo8nvdax-338} (lambda (hd r)
                                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-339} hd])
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-340} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-341} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                               (if (equal?
                                                                     #{hd dpuuv4a3mobea70icwo8nvdax-340}
                                                                     '#f)
                                                                   (if (pair?
                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-341})
                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-342} (car #{tl dpuuv4a3mobea70icwo8nvdax-341})]
                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-343} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-341})])
                                                                         (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-342}])
                                                                           (if (null?
                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-343})
                                                                               (begin
                                                                                 (cons
                                                                                   expr
                                                                                   r))
                                                                               (if (pair?
                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-344} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-345} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                     (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-344}])
                                                                                       (if (pair?
                                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-345})
                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-346} (car #{tl dpuuv4a3mobea70icwo8nvdax-345})]
                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-347} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-345})])
                                                                                             (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-346}])
                                                                                               (if (null?
                                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-347})
                                                                                                   (begin
                                                                                                     (cons
                                                                                                       (__SRC
                                                                                                         `(set! ,id
                                                                                                            ,expr)
                                                                                                         stx)
                                                                                                       r))
                                                                                                   (if (pair?
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                                         (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                                           (if (pair?
                                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                                 (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                                   (if (pair?
                                                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                                         (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                                           (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                                             (begin
                                                                                                                               (cons
                                                                                                                                 (__SRC
                                                                                                                                   `(let ([,tmp ,expr])
                                                                                                                                      ,(__SRC
                                                                                                                                         `(__check-values
                                                                                                                                            ,tmp
                                                                                                                                            ,len)
                                                                                                                                         stx)
                                                                                                                                      ,@(map (lambda (hd)
                                                                                                                                               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                                 (if (pair?
                                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                                       (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                                         (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                                           (begin
                                                                                                                                                             (__SRC
                                                                                                                                                               `(set! ,id
                                                                                                                                                                  (\x23;\x23;values-ref
                                                                                                                                                                    ,tmp
                                                                                                                                                                    ,k))
                                                                                                                                                               stx)))))
                                                                                                                                                     (error 'match
                                                                                                                                                       "no matching clause"
                                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                                             init))
                                                                                                                                   stx)
                                                                                                                                 r)))))
                                                                                                                       (error 'match
                                                                                                                         "no matching clause"
                                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                                               (error 'match
                                                                                                                 "no matching clause"
                                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                                       (error 'match
                                                                                                         "no matching clause"
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                                           (if (pair?
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                                 (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                                   (if (pair?
                                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                         (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                           (if (pair?
                                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                                 (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                                   (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                                     (begin
                                                                                                                       (cons
                                                                                                                         (__SRC
                                                                                                                           `(let ([,tmp ,expr])
                                                                                                                              ,(__SRC
                                                                                                                                 `(__check-values
                                                                                                                                    ,tmp
                                                                                                                                    ,len)
                                                                                                                                 stx)
                                                                                                                              ,@(map (lambda (hd)
                                                                                                                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                         (if (pair?
                                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                               (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                                 (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                                   (begin
                                                                                                                                                     (__SRC
                                                                                                                                                       `(set! ,id
                                                                                                                                                          (\x23;\x23;values-ref
                                                                                                                                                            ,tmp
                                                                                                                                                            ,k))
                                                                                                                                                       stx)))))
                                                                                                                                             (error 'match
                                                                                                                                               "no matching clause"
                                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                                     init))
                                                                                                                           stx)
                                                                                                                         r)))))
                                                                                                               (error 'match
                                                                                                                 "no matching clause"
                                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                                       (error 'match
                                                                                                         "no matching clause"
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                               (error 'match
                                                                                                 "no matching clause"
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                                   (if (pair?
                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                         (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                           (if (pair?
                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                 (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                   (if (pair?
                                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                         (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                           (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                             (begin
                                                                                                               (cons
                                                                                                                 (__SRC
                                                                                                                   `(let ([,tmp ,expr])
                                                                                                                      ,(__SRC
                                                                                                                         `(__check-values
                                                                                                                            ,tmp
                                                                                                                            ,len)
                                                                                                                         stx)
                                                                                                                      ,@(map (lambda (hd)
                                                                                                                               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                 (if (pair?
                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                       (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                         (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                           (begin
                                                                                                                                             (__SRC
                                                                                                                                               `(set! ,id
                                                                                                                                                  (\x23;\x23;values-ref
                                                                                                                                                    ,tmp
                                                                                                                                                    ,k))
                                                                                                                                               stx)))))
                                                                                                                                     (error 'match
                                                                                                                                       "no matching clause"
                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                             init))
                                                                                                                   stx)
                                                                                                                 r)))))
                                                                                                       (error 'match
                                                                                                         "no matching clause"
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                               (error 'match
                                                                                                 "no matching clause"
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                       (error 'match
                                                                                         "no matching clause"
                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))))
                                                                       (if (pair?
                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-344} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-345} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                             (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-344}])
                                                                               (if (pair?
                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-345})
                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-346} (car #{tl dpuuv4a3mobea70icwo8nvdax-345})]
                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-347} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-345})])
                                                                                     (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-346}])
                                                                                       (if (null?
                                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-347})
                                                                                           (begin
                                                                                             (cons
                                                                                               (__SRC
                                                                                                 `(set! ,id
                                                                                                    ,expr)
                                                                                                 stx)
                                                                                               r))
                                                                                           (if (pair?
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                                 (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                                   (if (pair?
                                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                         (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                           (if (pair?
                                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                                 (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                                   (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                                     (begin
                                                                                                                       (cons
                                                                                                                         (__SRC
                                                                                                                           `(let ([,tmp ,expr])
                                                                                                                              ,(__SRC
                                                                                                                                 `(__check-values
                                                                                                                                    ,tmp
                                                                                                                                    ,len)
                                                                                                                                 stx)
                                                                                                                              ,@(map (lambda (hd)
                                                                                                                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                         (if (pair?
                                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                               (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                                 (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                                   (begin
                                                                                                                                                     (__SRC
                                                                                                                                                       `(set! ,id
                                                                                                                                                          (\x23;\x23;values-ref
                                                                                                                                                            ,tmp
                                                                                                                                                            ,k))
                                                                                                                                                       stx)))))
                                                                                                                                             (error 'match
                                                                                                                                               "no matching clause"
                                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                                     init))
                                                                                                                           stx)
                                                                                                                         r)))))
                                                                                                               (error 'match
                                                                                                                 "no matching clause"
                                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                                       (error 'match
                                                                                                         "no matching clause"
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                               (error 'match
                                                                                                 "no matching clause"
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                                   (if (pair?
                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                         (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                           (if (pair?
                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                 (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                   (if (pair?
                                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                         (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                           (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                             (begin
                                                                                                               (cons
                                                                                                                 (__SRC
                                                                                                                   `(let ([,tmp ,expr])
                                                                                                                      ,(__SRC
                                                                                                                         `(__check-values
                                                                                                                            ,tmp
                                                                                                                            ,len)
                                                                                                                         stx)
                                                                                                                      ,@(map (lambda (hd)
                                                                                                                               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                 (if (pair?
                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                       (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                         (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                           (begin
                                                                                                                                             (__SRC
                                                                                                                                               `(set! ,id
                                                                                                                                                  (\x23;\x23;values-ref
                                                                                                                                                    ,tmp
                                                                                                                                                    ,k))
                                                                                                                                               stx)))))
                                                                                                                                     (error 'match
                                                                                                                                       "no matching clause"
                                                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                             init))
                                                                                                                   stx)
                                                                                                                 r)))))
                                                                                                       (error 'match
                                                                                                         "no matching clause"
                                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                               (error 'match
                                                                                                 "no matching clause"
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                       (error 'match
                                                                                         "no matching clause"
                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                           (if (pair?
                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                 (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                   (if (pair?
                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                         (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                           (if (pair?
                                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                 (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                   (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                     (begin
                                                                                                       (cons
                                                                                                         (__SRC
                                                                                                           `(let ([,tmp ,expr])
                                                                                                              ,(__SRC
                                                                                                                 `(__check-values
                                                                                                                    ,tmp
                                                                                                                    ,len)
                                                                                                                 stx)
                                                                                                              ,@(map (lambda (hd)
                                                                                                                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                         (if (pair?
                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                               (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                 (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                   (begin
                                                                                                                                     (__SRC
                                                                                                                                       `(set! ,id
                                                                                                                                          (\x23;\x23;values-ref
                                                                                                                                            ,tmp
                                                                                                                                            ,k))
                                                                                                                                       stx)))))
                                                                                                                             (error 'match
                                                                                                                               "no matching clause"
                                                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                     init))
                                                                                                           stx)
                                                                                                         r)))))
                                                                                               (error 'match
                                                                                                 "no matching clause"
                                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                       (error 'match
                                                                                         "no matching clause"
                                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                               (error 'match
                                                                                 "no matching clause"
                                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                   (if (pair?
                                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-344} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-345} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                         (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-344}])
                                                                           (if (pair?
                                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-345})
                                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-346} (car #{tl dpuuv4a3mobea70icwo8nvdax-345})]
                                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-347} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-345})])
                                                                                 (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-346}])
                                                                                   (if (null?
                                                                                         #{tl dpuuv4a3mobea70icwo8nvdax-347})
                                                                                       (begin
                                                                                         (cons
                                                                                           (__SRC
                                                                                             `(set! ,id
                                                                                                ,expr)
                                                                                             stx)
                                                                                           r))
                                                                                       (if (pair?
                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                             (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                               (if (pair?
                                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                                     (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                       (if (pair?
                                                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                             (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                               (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                                 (begin
                                                                                                                   (cons
                                                                                                                     (__SRC
                                                                                                                       `(let ([,tmp ,expr])
                                                                                                                          ,(__SRC
                                                                                                                             `(__check-values
                                                                                                                                ,tmp
                                                                                                                                ,len)
                                                                                                                             stx)
                                                                                                                          ,@(map (lambda (hd)
                                                                                                                                   (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                                     (if (pair?
                                                                                                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                           (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                             (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                               (begin
                                                                                                                                                 (__SRC
                                                                                                                                                   `(set! ,id
                                                                                                                                                      (\x23;\x23;values-ref
                                                                                                                                                        ,tmp
                                                                                                                                                        ,k))
                                                                                                                                                   stx)))))
                                                                                                                                         (error 'match
                                                                                                                                           "no matching clause"
                                                                                                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                                 init))
                                                                                                                       stx)
                                                                                                                     r)))))
                                                                                                           (error 'match
                                                                                                             "no matching clause"
                                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                                   (error 'match
                                                                                                     "no matching clause"
                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                           (error 'match
                                                                                             "no matching clause"
                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                               (if (pair?
                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                     (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                       (if (pair?
                                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                             (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                               (if (pair?
                                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                     (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                       (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                         (begin
                                                                                                           (cons
                                                                                                             (__SRC
                                                                                                               `(let ([,tmp ,expr])
                                                                                                                  ,(__SRC
                                                                                                                     `(__check-values
                                                                                                                        ,tmp
                                                                                                                        ,len)
                                                                                                                     stx)
                                                                                                                  ,@(map (lambda (hd)
                                                                                                                           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                             (if (pair?
                                                                                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                   (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                     (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                       (begin
                                                                                                                                         (__SRC
                                                                                                                                           `(set! ,id
                                                                                                                                              (\x23;\x23;values-ref
                                                                                                                                                ,tmp
                                                                                                                                                ,k))
                                                                                                                                           stx)))))
                                                                                                                                 (error 'match
                                                                                                                                   "no matching clause"
                                                                                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                         init))
                                                                                                               stx)
                                                                                                             r)))))
                                                                                                   (error 'match
                                                                                                     "no matching clause"
                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                           (error 'match
                                                                                             "no matching clause"
                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                   (error 'match
                                                                                     "no matching clause"
                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                       (if (pair?
                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                             (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                               (if (pair?
                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                     (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                       (if (pair?
                                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                             (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                               (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                 (begin
                                                                                                   (cons
                                                                                                     (__SRC
                                                                                                       `(let ([,tmp ,expr])
                                                                                                          ,(__SRC
                                                                                                             `(__check-values
                                                                                                                ,tmp
                                                                                                                ,len)
                                                                                                             stx)
                                                                                                          ,@(map (lambda (hd)
                                                                                                                   (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                     (if (pair?
                                                                                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                           (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                             (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                               (begin
                                                                                                                                 (__SRC
                                                                                                                                   `(set! ,id
                                                                                                                                      (\x23;\x23;values-ref
                                                                                                                                        ,tmp
                                                                                                                                        ,k))
                                                                                                                                   stx)))))
                                                                                                                         (error 'match
                                                                                                                           "no matching clause"
                                                                                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                 init))
                                                                                                       stx)
                                                                                                     r)))))
                                                                                           (error 'match
                                                                                             "no matching clause"
                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                   (error 'match
                                                                                     "no matching clause"
                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                           (error 'match
                                                                             "no matching clause"
                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-344} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-345} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                   (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-344}])
                                                                     (if (pair?
                                                                           #{tl dpuuv4a3mobea70icwo8nvdax-345})
                                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-346} (car #{tl dpuuv4a3mobea70icwo8nvdax-345})]
                                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-347} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-345})])
                                                                           (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-346}])
                                                                             (if (null?
                                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-347})
                                                                                 (begin
                                                                                   (cons
                                                                                     (__SRC
                                                                                       `(set! ,id
                                                                                          ,expr)
                                                                                       stx)
                                                                                     r))
                                                                                 (if (pair?
                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                                       (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                         (if (pair?
                                                                                               #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                               (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                                 (if (pair?
                                                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                                       (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                         (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                           (begin
                                                                                                             (cons
                                                                                                               (__SRC
                                                                                                                 `(let ([,tmp ,expr])
                                                                                                                    ,(__SRC
                                                                                                                       `(__check-values
                                                                                                                          ,tmp
                                                                                                                          ,len)
                                                                                                                       stx)
                                                                                                                    ,@(map (lambda (hd)
                                                                                                                             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                               (if (pair?
                                                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                                     (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                                       (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                         (begin
                                                                                                                                           (__SRC
                                                                                                                                             `(set! ,id
                                                                                                                                                (\x23;\x23;values-ref
                                                                                                                                                  ,tmp
                                                                                                                                                  ,k))
                                                                                                                                             stx)))))
                                                                                                                                   (error 'match
                                                                                                                                     "no matching clause"
                                                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                           init))
                                                                                                                 stx)
                                                                                                               r)))))
                                                                                                     (error 'match
                                                                                                       "no matching clause"
                                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                             (error 'match
                                                                                               "no matching clause"
                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                     (error 'match
                                                                                       "no matching clause"
                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                         (if (pair?
                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                               (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                                 (if (pair?
                                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                                       (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                         (if (pair?
                                                                                               #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                               (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                                 (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                                   (begin
                                                                                                     (cons
                                                                                                       (__SRC
                                                                                                         `(let ([,tmp ,expr])
                                                                                                            ,(__SRC
                                                                                                               `(__check-values
                                                                                                                  ,tmp
                                                                                                                  ,len)
                                                                                                               stx)
                                                                                                            ,@(map (lambda (hd)
                                                                                                                     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                                       (if (pair?
                                                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                             (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                               (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                                 (begin
                                                                                                                                   (__SRC
                                                                                                                                     `(set! ,id
                                                                                                                                        (\x23;\x23;values-ref
                                                                                                                                          ,tmp
                                                                                                                                          ,k))
                                                                                                                                     stx)))))
                                                                                                                           (error 'match
                                                                                                                             "no matching clause"
                                                                                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                                   init))
                                                                                                         stx)
                                                                                                       r)))))
                                                                                             (error 'match
                                                                                               "no matching clause"
                                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                                     (error 'match
                                                                                       "no matching clause"
                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                             (error 'match
                                                                               "no matching clause"
                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339})))))
                                                                 (if (pair?
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-348} (car #{match-val dpuuv4a3mobea70icwo8nvdax-339})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-349} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-339})])
                                                                       (let ([tmp #{hd dpuuv4a3mobea70icwo8nvdax-348}])
                                                                         (if (pair?
                                                                               #{tl dpuuv4a3mobea70icwo8nvdax-349})
                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-350} (car #{tl dpuuv4a3mobea70icwo8nvdax-349})]
                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-351} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-349})])
                                                                               (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-350}])
                                                                                 (if (pair?
                                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-351})
                                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-352} (car #{tl dpuuv4a3mobea70icwo8nvdax-351})]
                                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-353} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-351})])
                                                                                       (let ([len #{hd dpuuv4a3mobea70icwo8nvdax-352}])
                                                                                         (let ([init #{tl dpuuv4a3mobea70icwo8nvdax-353}])
                                                                                           (begin
                                                                                             (cons
                                                                                               (__SRC
                                                                                                 `(let ([,tmp ,expr])
                                                                                                    ,(__SRC
                                                                                                       `(__check-values
                                                                                                          ,tmp
                                                                                                          ,len)
                                                                                                       stx)
                                                                                                    ,@(map (lambda (hd)
                                                                                                             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-354} hd])
                                                                                                               (if (pair?
                                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-354})
                                                                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-355} (car #{match-val dpuuv4a3mobea70icwo8nvdax-354})]
                                                                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-356} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-354})])
                                                                                                                     (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-355}])
                                                                                                                       (let ([k #{tl dpuuv4a3mobea70icwo8nvdax-356}])
                                                                                                                         (begin
                                                                                                                           (__SRC
                                                                                                                             `(set! ,id
                                                                                                                                (\x23;\x23;values-ref
                                                                                                                                  ,tmp
                                                                                                                                  ,k))
                                                                                                                             stx)))))
                                                                                                                   (error 'match
                                                                                                                     "no matching clause"
                                                                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-354}))))
                                                                                                           init))
                                                                                                 stx)
                                                                                               r)))))
                                                                                     (error 'match
                                                                                       "no matching clause"
                                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                             (error 'match
                                                                               "no matching clause"
                                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))
                                                                     (error 'match
                                                                       "no matching clause"
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-339}))))))])
             (fold-left
               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-357}
                        #{e dpuuv4a3mobea70icwo8nvdax-358})
                 (#{f dpuuv4a3mobea70icwo8nvdax-338}
                   #{e dpuuv4a3mobea70icwo8nvdax-358}
                   #{a dpuuv4a3mobea70icwo8nvdax-357}))
               (list body)
               post)))
      stx))
  (__compile-let-form stx compile-simple compile-values))

(define (__compile-call% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-359} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-360} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-359}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-359})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-361} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-359})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-362} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-361})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-363} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-361})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-363})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-364} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-363})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-365} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-364})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-366} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-364})])
                  (let ([rator #{ehd dpuuv4a3mobea70icwo8nvdax-365}])
                    (let ([rands #{etl dpuuv4a3mobea70icwo8nvdax-366}])
                      (__SRC
                        (cons (__compile rator) (map __compile rands))
                        stx))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-360})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-360})))))

(define (__compile-ref% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-367} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-368} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-367}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-367})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-369} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-367})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-370} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-369})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-371} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-369})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-371})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-372} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-371})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-373} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-372})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-374} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-372})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-373}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-374}))
                        (__SRC id stx)
                        (#{fail dpuuv4a3mobea70icwo8nvdax-368}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-368})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-368})))))

(define (__compile-setq% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-375} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-376} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-375}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-375})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-377} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-375})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-378} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-377})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-379} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-377})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-379})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-380} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-379})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-381} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-380})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-382} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-380})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-381}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-382})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-383} (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-382})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-384} (\x23;\x23;car
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-383})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-385} (\x23;\x23;cdr
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-383})])
                          (let ([expr #{ehd dpuuv4a3mobea70icwo8nvdax-384}])
                            (if (null?
                                  (__AST-e
                                    #{etl dpuuv4a3mobea70icwo8nvdax-385}))
                                (__SRC
                                  `(set! ,(__SRC id stx) ,(__compile expr))
                                  stx)
                                (#{fail dpuuv4a3mobea70icwo8nvdax-376}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-376}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-376})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-376})))))

(define (__compile-if% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-386} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-387} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-386}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-386})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-388} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-386})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-389} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-388})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-390} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-388})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-390})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-391} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-390})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-392} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-391})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-393} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-391})])
                  (let ([p #{ehd dpuuv4a3mobea70icwo8nvdax-392}])
                    (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-393})
                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-394} (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-393})]
                               [#{ehd dpuuv4a3mobea70icwo8nvdax-395} (\x23;\x23;car
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-394})]
                               [#{etl dpuuv4a3mobea70icwo8nvdax-396} (\x23;\x23;cdr
                                                                       #{etgt dpuuv4a3mobea70icwo8nvdax-394})])
                          (let ([t #{ehd dpuuv4a3mobea70icwo8nvdax-395}])
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-396})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-397} (__AST-e
                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-396})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-398} (\x23;\x23;car
                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-397})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-399} (\x23;\x23;cdr
                                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-397})])
                                  (let ([f #{ehd dpuuv4a3mobea70icwo8nvdax-398}])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-399}))
                                        (__SRC
                                          `(if ,(__compile p)
                                               ,(__compile t)
                                               ,(__compile f))
                                          stx)
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-387}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-387}))))
                        (#{fail dpuuv4a3mobea70icwo8nvdax-387}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-387})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-387})))))

(define (__compile-quote% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-400} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-401} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-400}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-400})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-402} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-400})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-403} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-402})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-404} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-402})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-404})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-405} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-404})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-406} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-405})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-407} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-405})])
                  (let ([e #{ehd dpuuv4a3mobea70icwo8nvdax-406}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-407}))
                        (__SRC `',(__AST->datum e) stx)
                        (#{fail dpuuv4a3mobea70icwo8nvdax-401}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-401})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-401})))))

(define (__compile-quote-syntax% stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-408} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-409} (lambda ()
                                                   (__raise-syntax-error
                                                     #f
                                                     "Bad syntax; malformed ast clause"
                                                     #{ast-val dpuuv4a3mobea70icwo8nvdax-408}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-408})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-410} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-408})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-411} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-410})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-412} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-410})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-412})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-413} (__AST-e
                                                                #{etl dpuuv4a3mobea70icwo8nvdax-412})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-414} (\x23;\x23;car
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-413})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-415} (\x23;\x23;cdr
                                                               #{etgt dpuuv4a3mobea70icwo8nvdax-413})])
                  (let ([e #{ehd dpuuv4a3mobea70icwo8nvdax-414}])
                    (if (null?
                          (__AST-e #{etl dpuuv4a3mobea70icwo8nvdax-415}))
                        (__SRC `',e stx)
                        (#{fail dpuuv4a3mobea70icwo8nvdax-409}))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-409})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-409})))))

(define-syntax defcore-forms
  (lambda (stx)
    (define (generate id compile make)
      (with-syntax ([id id]
                    [eid (stx-identifier id "__" compile)]
                    [make make])
        #'(__core-bind-syntax! 'id eid make)))
    (syntax-case stx ()
      [(_ form ...)
       (let lp ([rest #'(form ...)] [body (\x40;list)])
         (syntax-case rest ()
           [((id expr: compile) . rest)
            (lp #'rest
                (cons
                  (generate #'id #'compile #'make-__core-expression)
                  body))]
           [((id special: compile) . rest)
            (lp #'rest
                (cons
                  (generate #'id #'compile #'make-__core-special-form)
                  body))]
           [((id) . rest)
            (lp #'rest
                (cons
                  (generate #'id #'compile-error #'make-__core-form)
                  body))]
           [() (cons 'begin (reverse body))]))])))

(begin
  (__core-bind-syntax!
    '%\x23;begin
    __compile-begin%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;begin-syntax
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;begin-foreign
    __compile-begin-foreign%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;module
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;import
    __compile-import%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;export
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;provide
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;define-values
    __compile-define-values%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;define-syntax
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;define-alias
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;define-runtime
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;extern
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;declare
    __compile-ignore%
    make-__core-special-form)
  (__core-bind-syntax!
    '%\x23;begin-annotation
    __compile-begin-annotation%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;quote
    __compile-quote%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;quote-syntax
    __compile-quote-syntax%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;lambda
    __compile-lambda%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;case-lambda
    __compile-case-lambda%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;let-values
    __compile-let-values%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;letrec-values
    __compile-letrec-values%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;letrec*-values
    __compile-letrec*-values%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;call
    __compile-call%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;if
    __compile-if%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;ref
    __compile-ref%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;set!
    __compile-setq%
    make-__core-expression)
  (__core-bind-syntax!
    '%\x23;cond-expand
    __compile-error
    make-__core-form)
  (__core-bind-syntax!
    '%\x23;include
    __compile-error
    make-__core-form)
  (__core-bind-syntax!
    '%\x23;let-syntax
    __compile-error
    make-__core-form)
  (__core-bind-syntax!
    '%\x23;letrec-syntax
    __compile-error
    make-__core-form))

