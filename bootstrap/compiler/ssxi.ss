(define-syntax declare-type
  (syntax-rules ()
    [(_ symbol type-expr)
     (optimizer-declare-type! 'symbol type-expr)]))

(define-syntax declare-class
  (syntax-rules ()
    [(_ symbol type-expr)
     (optimizer-declare-class! 'symbol type-expr)]))

(define-syntax declare-type*
  (syntax-rules ()
    [(_ (symbol type) ...)
     (begin (declare-type symbol type) ...)]))

(define-syntax declare-method
  (syntax-rules ()
    [(_ type-t method symbol rebind?)
     (optimizer-declare-method! 'type-t 'method 'symbol rebind?)]
    [(recur type-t method symbol)
     (recur type-t method symbol rebind?)]))

(define-syntax declare-method*
  (syntax-rules ()
    [(_ (type-t method symbol) ...)
     (begin (declare-method type-t method symbol) ...)]))

(define-syntax declare-methods
  (syntax-rules ()
    [(_ type-t (method symbol) ...)
     (begin (declare-method type-t method symbol) ...)]))

(define-syntax \x40;alias
  (syntax-rules () [(_ alias-id) (make-!alias 'alias-id)]))

(define-syntax \x40;class
  (syntax-rules ()
    [(_ type-id super-ids precedence-list slots fields
        constructor struct? final? system? metaclass methods)
     (make-!class 'type-id 'super-ids 'precedence-list 'slots 'fields
       'constructor struct? final? system? 'metaclass 'methods)]))

(define-syntax \x40;predicate
  (syntax-rules () [(_ type-id) (make-!predicate 'type-id)]))

(define-syntax \x40;constructor
  (syntax-rules ()
    [(_ type-id) (make-!constructor 'type-id)]))

(define-syntax \x40;accessor
  (syntax-rules ()
    [(_ type-id slot checked?)
     (make-!accessor 'type-id 'slot checked?)]))

(define-syntax \x40;mutator
  (syntax-rules ()
    [(_ type-id slot checked?)
     (make-!mutator 'type-id 'slot checked?)]))

(define-syntax \x40;primitive-predicate
  (syntax-rules ()
    [(_ type-id) (make-!primitive-predicate 'type-id)]))

(define-syntax \x40;interface
  (syntax-rules ()
    [(_ type-id methods) (make-!interface 'type-id 'methods)]))

(define-syntax \x40;lambda
  (syntax-rules ()
    [(_ arity dispatch) (make-!lambda 'arity 'dispatch)]
    [(_ arity dispatch signature: signature)
     (make-!lambda
       'arity
       'dispatch
       signature:
       (apply make-!signature 'signature))]
    [(recur arity) (recur arity #f)]
    [(recur arity signature: signature)
     (recur arity #f signature: signature)]))

(define-syntax \x40;case-lambda
  (syntax-rules ()
    [(_ (clause ...) ...)
     (make-!case-lambda
       (\x40;list (\x40;lambda clause ...) ...))]))

(define-syntax \x40;kw-lambda
  (syntax-rules ()
    [(_ tab dispatch) (make-!kw-lambda 'tab 'dispatch)]))

(define-syntax \x40;kw-lambda-dispatch
  (syntax-rules ()
    [(_ keys main) (make-!kw-lambda-primary 'keys 'main)]))

(define-syntax declare-inline-rules!
  (syntax-rules ()
    [(_ (proc rule) ...)
     (begin (declare-inline-rule! proc rule) ...)]))

(define-syntax declare-inline-rule!
  (syntax-rules ()
    [(_ proc rules)
     (let (type [optimizer-lookup-type 'proc])
       (if (!lambda? type)
           (set! (!lambda-inline type) rules)
           (displayln
             "*** WARNING unknown procedure "
             'proc
             "; ignoring inline rule")))]))

(define-syntax declare-primitive-predicates
  (syntax-rules ()
    [(_) (begin)]
    [(_ (proc klass) . rest)
     (begin
       (declare-primitive-predicate proc klass)
       (declare-primitive-predicates . rest))]))

(define-syntax declare-primitive-procedures
  (syntax-rules ()
    [(_) (begin)]
    [(_ (id sig ...) . rest)
     (begin
       (declare-primitive-procedure id sig ...)
       (declare-primitive-procedures . rest))]))

(define-syntax declare-primitive-procedure
  (syntax-rules (\x40;list)
    [(_ id (\x40;list sig ...))
     (declare-primitive-case-lambda id sig ...)]
    [(_ id sig ...) (declare-primitive-lambda id sig ...)]))

(begin
  (define (verify-procedure! ctx id)
    (let ([proc (guard (__exn [#t (false __exn)])
                  ((lambda () (eval-syntax id))))])
      (unless (procedure? proc)
        (raise-syntax-error #f "unknown procedure" ctx id))))
  (define (verify-class! ctx id)
    (let ([klass (guard (__exn [#t (false __exn)])
                   ((lambda () (eval-syntax id))))])
      (unless (class-type? klass)
        (raise-syntax-error #f "unknown class" ctx id))))
  (define (parse-signature ctx proc sig)
    (define (signature-arity args)
      (let loop ([rest args] [count 0])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-8714} rest])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-8714})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-8715} (car #{match-val dpuuv4a3mobea70icwo8nvdax-8714})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-8716} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-8714})])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-8716}])
                  (begin (loop rest (fx1+ count)))))
              (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-8714})
                  (begin count)
                  (begin (list count)))))))
    (define (make-signature args return effect unchecked)
      (stx-for-each
        (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-8717})
          (verify-class!
            ctx
            #{cut-arg dpuuv4a3mobea70icwo8nvdax-8717}))
        args)
      (verify-class! ctx return)
      (when unchecked (verify-procedure! ctx unchecked))
      (let ([arity (signature-arity (stx-map stx-e args))])
        (when effect
          (let ([effect (syntax->datum effect)])
            (unless (and (list? effect) (andmap symbol? effect))
              (raise-syntax-error #f "bad effect" ctx proc effect))))
        (list
          arity
          (with-syntax ([args args]
                        [return return]
                        [effect effect]
                        [unchecked unchecked])
            #'(make-!signature arguments: 'args return: 'return effect:
                'effect unchecked: 'unchecked origin: 'builtin)))))
    (verify-procedure! ctx proc)
    (syntax-case sig ()
      [(args return) (make-signature #'args #'return #f #f)]
      [(args return effect: effect)
       (make-signature #'args #'return #'effect #f)]
      [(args return effect: effect unchecked:)
       (make-signature
         #'args
         #'return
         #'effect
         (make-symbol "##" (stx-e proc)))]
      [(args return effect: effect unchecked: unchecked-proc)
       (make-signature
         #'args
         #'return
         #f
         (stx-e #'unchecked-proc))]
      [(args return unchecked:)
       (make-signature
         #'args
         #'return
         #f
         (make-symbol "##" (stx-e proc)))]
      [(args return unchecked: unchecked-proc)
       (make-signature
         #'args
         #'return
         #f
         (stx-e #'unchecked-proc))]))
  (define (signature->unchecked-signature sig)
    (syntax-case sig (quote)
      [(_ arguments: 'args return: 'return effect: 'effect
          unchecked: 'unchecked origin: 'origin)
       (and (stx-e #'unchecked)
            #'(unchecked
                (make-!signature return: 'return origin: 'origin)))])))

(define-syntax declare-primitive-predicate
  (lambda (stx)
    (syntax-case stx ()
      [(_ proc klass)
       (and (identifier? #'proc) (identifier? #'klass))
       (begin
         (verify-procedure! stx #'proc)
         (verify-class! stx #'klass)
         #'(declare-type
             proc
             (make-!primitive-predicate 'klass)))])))

(define-syntax declare-primitive-lambda
  (lambda (stx)
    (syntax-case stx ()
      [(_ proc signature ...)
       (identifier? #'proc)
       (with-syntax*
         (((arity sig)
            (parse-signature stx #'proc #'(signature ...)))
           (decl
             #'(declare-type
                 proc
                 (make-!primitive-lambda 'arity #f signature: sig)))
           ((values unchecked) (signature->unchecked-signature #'sig))
           (decl-unchecked
             (if unchecked
                 (with-syntax ([(proc sig) unchecked])
                   #'(declare-type
                       proc
                       (make-!primitive-lambda 'arity #f signature: sig)))
                 '(begin))))
         #'(begin decl decl-unchecked))])))

(define-syntax declare-primitive-case-lambda
  (lambda (stx)
    (syntax-case stx ()
      [(_ proc case-signature ...)
       (identifier? #'proc)
       (let (signatures
             [map (cut parse-signature stx #'proc <>)
               #'(case-signature ...)])
         (with-syntax*
           ((((arity sig) ...) signatures)
             (decl
               #'(declare-type
                   proc
                   (make-!primitive-case-lambda
                     (\x40;list
                       (make-!primitive-lambda 'arity #f signature: sig)
                       ...))))
             (decl-unchecked
               (let ([values unchecked-proc unchecked-clauses]
                     [let loop
                       ((rest signatures)
                         (unchecked-proc #f)
                         (unchecked-clauses (\x40;list)))
                       (match rest
                         [(\x40;list hd . rest)
                          (syntax-case hd (quote)
                            [(arity
                               (_ arguments: 'args return: 'return effect:
                                  'effect unchecked: 'unchecked origin:
                                  'origin))
                             (let ([clause #'(make-!primitive-lambda
                                               'arity
                                               #f
                                               signature:
                                               (make-!signature
                                                 return:
                                                 'return
                                                 origin:
                                                 'origin))]
                                   [unchecked (stx-e #'unchecked)])
                               (loop
                                 rest
                                 (or unchecked unchecked-proc)
                                 (cons clause unchecked-clauses)))])]
                         [else
                          (values
                            unchecked-proc
                            (reverse! unchecked-clauses))])])
                 (if unchecked-proc
                     (with-syntax ([proc unchecked-proc]
                                   [(clause ...) unchecked-clauses])
                       #'(declare-type
                           proc
                           (make-!primitive-case-lambda
                             (\x40;list clause ...))))
                     '(begin)))))
           #'(begin decl decl-unchecked)))])))

(define-syntax declare-builtin-class
  (syntax-rules ()
    [(_ system: id super)
     (optimizer-declare-builtin-class!
       'id
       (make-!class (class-type-id id) 'super (\x40;list) #f #f #f
         #t #f))]
    [(_ struct: id super slots)
     (optimizer-declare-builtin-class!
       'id
       (make-!class (class-type-id id) 'super 'slots #f #f #f #f
         #f))]
    [(_ class: id super slots)
     (optimizer-declare-builtin-class!
       'id
       (make-!class (class-type-id id) 'super 'slots #f #t #f #f
         #f))]))

(define-syntax declare-builtin-classes
  (syntax-rules ()
    [(_ decl ...) (begin (declare-builtin-class . decl) ...)]))

