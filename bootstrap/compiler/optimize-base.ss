(define current-compile-optimizer-info (make-parameter #f))

(define current-compile-mutators (make-parameter #f))

(define current-compile-local-type (make-parameter #f))

(define current-compile-path-type (make-parameter (list)))

(begin
  (define optimizer-info::t
    (make-class-type 'gerbil\x23;optimizer-info::t 'optimizer-info
      (list object::t) '(type classes ssxi methods)
      '((struct: . #t) (constructor: . :init!)) '#f))
  (define (make-optimizer-info . args)
    (let* ([type optimizer-info::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (optimizer-info? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;optimizer-info::t))
  (define (optimizer-info-type obj)
    (unchecked-slot-ref obj 'type))
  (define (optimizer-info-classes obj)
    (unchecked-slot-ref obj 'classes))
  (define (optimizer-info-ssxi obj)
    (unchecked-slot-ref obj 'ssxi))
  (define (optimizer-info-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (optimizer-info-type-set! obj val)
    (unchecked-slot-set! obj 'type val))
  (define (optimizer-info-classes-set! obj val)
    (unchecked-slot-set! obj 'classes val))
  (define (optimizer-info-ssxi-set! obj val)
    (unchecked-slot-set! obj 'ssxi val))
  (define (optimizer-info-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val))
  (define (&optimizer-info-type obj)
    (unchecked-slot-ref obj 'type))
  (define (&optimizer-info-classes obj)
    (unchecked-slot-ref obj 'classes))
  (define (&optimizer-info-ssxi obj)
    (unchecked-slot-ref obj 'ssxi))
  (define (&optimizer-info-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (&optimizer-info-type-set! obj val)
    (unchecked-slot-set! obj 'type val))
  (define (&optimizer-info-classes-set! obj val)
    (unchecked-slot-set! obj 'classes val))
  (define (&optimizer-info-ssxi-set! obj val)
    (unchecked-slot-set! obj 'ssxi val))
  (define (&optimizer-info-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val)))

(begin
  (define optimizer-info:::init!
    (lambda (self)
      (struct-instance-init! self (make-hash-table-eq) (make-hash-table-eq)
        (make-hash-table-eq) (make-hash-table-eq))))
  (bind-method!
    optimizer-info::t
    ':init!
    optimizer-info:::init!))

(begin
  (define !type::t
    (make-class-type 'gerbil\x23;!type::t '!type (list object::t) '(id)
      '((struct: . #t) (equal: . #t) (print: . #t)) '#f))
  (define (make-!type . args)
    (let* ([type !type::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!type? obj)
    (\x23;\x23;structure-instance-of? obj 'gerbil\x23;!type::t))
  (define (!type-id obj) (unchecked-slot-ref obj 'id))
  (define (!type-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&!type-id obj) (unchecked-slot-ref obj 'id))
  (define (&!type-id-set! obj val)
    (unchecked-slot-set! obj 'id val)))

(begin
  (define !abort::t
    (make-class-type 'gerbil\x23;!abort::t '!abort (list !type::t) '()
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!abort . args)
    (let* ([type !abort::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!abort? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!abort::t)))

(begin
  (define !alias::t
    (make-class-type 'gerbil\x23;!alias::t '!alias
      (list !type::t) '() '((struct: . #t) (equal: . #t)) '#f))
  (define (make-!alias . args)
    (let* ([type !alias::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!alias? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!alias::t)))

(begin
  (define !signature::t
    (make-class-type 'gerbil\x23;!signature::t '!signature (list object::t)
      '(return effect arguments unchecked origin)
      '((final: . #t) (equal: . #t) (print: . #t)) '#f))
  (define (!signature . args) (apply make-!signature args))
  (define (!signature? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!signature::t))
  (define (make-!signature . args)
    (apply make-instance !signature::t args))
  (define (&!signature-return-set! obj val)
    (unchecked-slot-set! obj 'return val))
  (define (&!signature-return obj)
    (unchecked-slot-ref obj 'return))
  (define (!signature-return-set! obj val)
    (unchecked-slot-set! obj 'return val))
  (define (!signature-return obj)
    (unchecked-slot-ref obj 'return))
  (define (&!signature-effect-set! obj val)
    (unchecked-slot-set! obj 'effect val))
  (define (&!signature-effect obj)
    (unchecked-slot-ref obj 'effect))
  (define (!signature-effect-set! obj val)
    (unchecked-slot-set! obj 'effect val))
  (define (!signature-effect obj)
    (unchecked-slot-ref obj 'effect))
  (define (&!signature-arguments-set! obj val)
    (unchecked-slot-set! obj 'arguments val))
  (define (&!signature-arguments obj)
    (unchecked-slot-ref obj 'arguments))
  (define (!signature-arguments-set! obj val)
    (unchecked-slot-set! obj 'arguments val))
  (define (!signature-arguments obj)
    (unchecked-slot-ref obj 'arguments))
  (define (&!signature-unchecked-set! obj val)
    (unchecked-slot-set! obj 'unchecked val))
  (define (&!signature-unchecked obj)
    (unchecked-slot-ref obj 'unchecked))
  (define (!signature-unchecked-set! obj val)
    (unchecked-slot-set! obj 'unchecked val))
  (define (!signature-unchecked obj)
    (unchecked-slot-ref obj 'unchecked))
  (define (&!signature-origin-set! obj val)
    (unchecked-slot-set! obj 'origin val))
  (define (&!signature-origin obj)
    (unchecked-slot-ref obj 'origin))
  (define (!signature-origin-set! obj val)
    (unchecked-slot-set! obj 'origin val))
  (define (!signature-origin obj)
    (unchecked-slot-ref obj 'origin)))

(begin
  (define !procedure::t
    (make-class-type 'gerbil\x23;!procedure::t '!procedure (list !type::t)
      '(signature) '((struct: . #t) (equal: . #t) (print: . #t))
      '#f))
  (define (make-!procedure . args)
    (let* ([type !procedure::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!procedure? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!procedure::t))
  (define (!procedure-signature obj)
    (unchecked-slot-ref obj 'signature))
  (define (!procedure-signature-set! obj val)
    (unchecked-slot-set! obj 'signature val))
  (define (&!procedure-signature obj)
    (unchecked-slot-ref obj 'signature))
  (define (&!procedure-signature-set! obj val)
    (unchecked-slot-set! obj 'signature val)))

(begin
  (define !class-meta::t
    (make-class-type 'gerbil\x23;!class-meta::t '!class-meta (list !type::t)
      '(class) '((struct: . #t) (constructor: . :init!)) '#f))
  (define (make-!class-meta . args)
    (let* ([type !class-meta::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!class-meta? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!class-meta::t))
  (define (!class-meta-class obj)
    (unchecked-slot-ref obj 'class))
  (define (!class-meta-class-set! obj val)
    (unchecked-slot-set! obj 'class val))
  (define (&!class-meta-class obj)
    (unchecked-slot-ref obj 'class))
  (define (&!class-meta-class-set! obj val)
    (unchecked-slot-set! obj 'class val)))

(begin
  (define !class::t
    (make-class-type 'gerbil\x23;!class::t '!class (list !type::t)
      '(super precedence-list slots fields constructor struct?
         final? system? metaclass methods)
      '((struct: . #t)
         (constructor: . :init!)
         (equal: . #t)
         (print: super precedence-list))
      '#f))
  (define (make-!class . args)
    (let* ([type !class::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!class? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!class::t))
  (define (!class-super obj) (unchecked-slot-ref obj 'super))
  (define (!class-precedence-list obj)
    (unchecked-slot-ref obj 'precedence-list))
  (define (!class-slots obj) (unchecked-slot-ref obj 'slots))
  (define (!class-fields obj)
    (unchecked-slot-ref obj 'fields))
  (define (!class-constructor obj)
    (unchecked-slot-ref obj 'constructor))
  (define (!class-struct? obj)
    (unchecked-slot-ref obj 'struct?))
  (define (!class-final? obj)
    (unchecked-slot-ref obj 'final?))
  (define (!class-system? obj)
    (unchecked-slot-ref obj 'system?))
  (define (!class-metaclass obj)
    (unchecked-slot-ref obj 'metaclass))
  (define (!class-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (!class-super-set! obj val)
    (unchecked-slot-set! obj 'super val))
  (define (!class-precedence-list-set! obj val)
    (unchecked-slot-set! obj 'precedence-list val))
  (define (!class-slots-set! obj val)
    (unchecked-slot-set! obj 'slots val))
  (define (!class-fields-set! obj val)
    (unchecked-slot-set! obj 'fields val))
  (define (!class-constructor-set! obj val)
    (unchecked-slot-set! obj 'constructor val))
  (define (!class-struct?-set! obj val)
    (unchecked-slot-set! obj 'struct? val))
  (define (!class-final?-set! obj val)
    (unchecked-slot-set! obj 'final? val))
  (define (!class-system?-set! obj val)
    (unchecked-slot-set! obj 'system? val))
  (define (!class-metaclass-set! obj val)
    (unchecked-slot-set! obj 'metaclass val))
  (define (!class-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val))
  (define (&!class-super obj) (unchecked-slot-ref obj 'super))
  (define (&!class-precedence-list obj)
    (unchecked-slot-ref obj 'precedence-list))
  (define (&!class-slots obj) (unchecked-slot-ref obj 'slots))
  (define (&!class-fields obj)
    (unchecked-slot-ref obj 'fields))
  (define (&!class-constructor obj)
    (unchecked-slot-ref obj 'constructor))
  (define (&!class-struct? obj)
    (unchecked-slot-ref obj 'struct?))
  (define (&!class-final? obj)
    (unchecked-slot-ref obj 'final?))
  (define (&!class-system? obj)
    (unchecked-slot-ref obj 'system?))
  (define (&!class-metaclass obj)
    (unchecked-slot-ref obj 'metaclass))
  (define (&!class-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (&!class-super-set! obj val)
    (unchecked-slot-set! obj 'super val))
  (define (&!class-precedence-list-set! obj val)
    (unchecked-slot-set! obj 'precedence-list val))
  (define (&!class-slots-set! obj val)
    (unchecked-slot-set! obj 'slots val))
  (define (&!class-fields-set! obj val)
    (unchecked-slot-set! obj 'fields val))
  (define (&!class-constructor-set! obj val)
    (unchecked-slot-set! obj 'constructor val))
  (define (&!class-struct?-set! obj val)
    (unchecked-slot-set! obj 'struct? val))
  (define (&!class-final?-set! obj val)
    (unchecked-slot-set! obj 'final? val))
  (define (&!class-system?-set! obj val)
    (unchecked-slot-set! obj 'system? val))
  (define (&!class-metaclass-set! obj val)
    (unchecked-slot-set! obj 'metaclass val))
  (define (&!class-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val)))

(begin
  (define !predicate::t
    (make-class-type 'gerbil\x23;!predicate::t '!predicate (list !procedure::t)
      '() '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!predicate . args)
    (let* ([type !predicate::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!predicate? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!predicate::t)))

(begin
  (define !constructor::t
    (make-class-type 'gerbil\x23;!constructor::t '!constructor
      (list !procedure::t) '()
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!constructor . args)
    (let* ([type !constructor::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!constructor? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!constructor::t)))

(begin
  (define !accessor::t
    (make-class-type 'gerbil\x23;!accessor::t '!accessor (list !procedure::t)
      '(slot checked?)
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!accessor . args)
    (let* ([type !accessor::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!accessor? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!accessor::t))
  (define (!accessor-slot obj) (unchecked-slot-ref obj 'slot))
  (define (!accessor-checked? obj)
    (unchecked-slot-ref obj 'checked?))
  (define (!accessor-slot-set! obj val)
    (unchecked-slot-set! obj 'slot val))
  (define (!accessor-checked?-set! obj val)
    (unchecked-slot-set! obj 'checked? val))
  (define (&!accessor-slot obj)
    (unchecked-slot-ref obj 'slot))
  (define (&!accessor-checked? obj)
    (unchecked-slot-ref obj 'checked?))
  (define (&!accessor-slot-set! obj val)
    (unchecked-slot-set! obj 'slot val))
  (define (&!accessor-checked?-set! obj val)
    (unchecked-slot-set! obj 'checked? val)))

(begin
  (define !mutator::t
    (make-class-type 'gerbil\x23;!mutator::t '!mutator (list !procedure::t)
      '(slot checked?)
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!mutator . args)
    (let* ([type !mutator::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!mutator? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!mutator::t))
  (define (!mutator-slot obj) (unchecked-slot-ref obj 'slot))
  (define (!mutator-checked? obj)
    (unchecked-slot-ref obj 'checked?))
  (define (!mutator-slot-set! obj val)
    (unchecked-slot-set! obj 'slot val))
  (define (!mutator-checked?-set! obj val)
    (unchecked-slot-set! obj 'checked? val))
  (define (&!mutator-slot obj) (unchecked-slot-ref obj 'slot))
  (define (&!mutator-checked? obj)
    (unchecked-slot-ref obj 'checked?))
  (define (&!mutator-slot-set! obj val)
    (unchecked-slot-set! obj 'slot val))
  (define (&!mutator-checked?-set! obj val)
    (unchecked-slot-set! obj 'checked? val)))

(begin
  (define !interface::t
    (make-class-type 'gerbil\x23;!interface::t '!interface (list !type::t)
      '(methods) '((struct: . #t) (equal: . #t)) '#f))
  (define (make-!interface . args)
    (let* ([type !interface::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!interface? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!interface::t))
  (define (!interface-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (!interface-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val))
  (define (&!interface-methods obj)
    (unchecked-slot-ref obj 'methods))
  (define (&!interface-methods-set! obj val)
    (unchecked-slot-set! obj 'methods val)))

(begin
  (define !lambda::t
    (make-class-type 'gerbil\x23;!lambda::t '!lambda (list !procedure::t)
      '(arity dispatch inline inline-typedecl)
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!lambda . args)
    (let* ([type !lambda::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!lambda? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!lambda::t))
  (define (!lambda-arity obj) (unchecked-slot-ref obj 'arity))
  (define (!lambda-dispatch obj)
    (unchecked-slot-ref obj 'dispatch))
  (define (!lambda-inline obj)
    (unchecked-slot-ref obj 'inline))
  (define (!lambda-inline-typedecl obj)
    (unchecked-slot-ref obj 'inline-typedecl))
  (define (!lambda-arity-set! obj val)
    (unchecked-slot-set! obj 'arity val))
  (define (!lambda-dispatch-set! obj val)
    (unchecked-slot-set! obj 'dispatch val))
  (define (!lambda-inline-set! obj val)
    (unchecked-slot-set! obj 'inline val))
  (define (!lambda-inline-typedecl-set! obj val)
    (unchecked-slot-set! obj 'inline-typedecl val))
  (define (&!lambda-arity obj)
    (unchecked-slot-ref obj 'arity))
  (define (&!lambda-dispatch obj)
    (unchecked-slot-ref obj 'dispatch))
  (define (&!lambda-inline obj)
    (unchecked-slot-ref obj 'inline))
  (define (&!lambda-inline-typedecl obj)
    (unchecked-slot-ref obj 'inline-typedecl))
  (define (&!lambda-arity-set! obj val)
    (unchecked-slot-set! obj 'arity val))
  (define (&!lambda-dispatch-set! obj val)
    (unchecked-slot-set! obj 'dispatch val))
  (define (&!lambda-inline-set! obj val)
    (unchecked-slot-set! obj 'inline val))
  (define (&!lambda-inline-typedecl-set! obj val)
    (unchecked-slot-set! obj 'inline-typedecl val)))

(begin
  (define !case-lambda::t
    (make-class-type 'gerbil\x23;!case-lambda::t '!case-lambda
      (list !procedure::t) '(clauses)
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!case-lambda . args)
    (let* ([type !case-lambda::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!case-lambda? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!case-lambda::t))
  (define (!case-lambda-clauses obj)
    (unchecked-slot-ref obj 'clauses))
  (define (!case-lambda-clauses-set! obj val)
    (unchecked-slot-set! obj 'clauses val))
  (define (&!case-lambda-clauses obj)
    (unchecked-slot-ref obj 'clauses))
  (define (&!case-lambda-clauses-set! obj val)
    (unchecked-slot-set! obj 'clauses val)))

(begin
  (define !kw-lambda::t
    (make-class-type 'gerbil\x23;!kw-lambda::t '!kw-lambda (list !procedure::t)
      '(table dispatch)
      '((struct: . #t) (equal: . #t) (constructor: . :init!))
      '#f))
  (define (make-!kw-lambda . args)
    (let* ([type !kw-lambda::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!kw-lambda? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!kw-lambda::t))
  (define (!kw-lambda-table obj)
    (unchecked-slot-ref obj 'table))
  (define (!kw-lambda-dispatch obj)
    (unchecked-slot-ref obj 'dispatch))
  (define (!kw-lambda-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (!kw-lambda-dispatch-set! obj val)
    (unchecked-slot-set! obj 'dispatch val))
  (define (&!kw-lambda-table obj)
    (unchecked-slot-ref obj 'table))
  (define (&!kw-lambda-dispatch obj)
    (unchecked-slot-ref obj 'dispatch))
  (define (&!kw-lambda-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (&!kw-lambda-dispatch-set! obj val)
    (unchecked-slot-set! obj 'dispatch val)))

(begin
  (define !kw-lambda-primary::t
    (make-class-type 'gerbil\x23;!kw-lambda-primary::t '!kw-lambda-primary
      (list !procedure::t) '(keys main)
      '((struct: . #t) (equal: . #t) (constructor: . :init!))
      '#f))
  (define (make-!kw-lambda-primary . args)
    (let* ([type !kw-lambda-primary::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!kw-lambda-primary? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!kw-lambda-primary::t))
  (define (!kw-lambda-primary-keys obj)
    (unchecked-slot-ref obj 'keys))
  (define (!kw-lambda-primary-main obj)
    (unchecked-slot-ref obj 'main))
  (define (!kw-lambda-primary-keys-set! obj val)
    (unchecked-slot-set! obj 'keys val))
  (define (!kw-lambda-primary-main-set! obj val)
    (unchecked-slot-set! obj 'main val))
  (define (&!kw-lambda-primary-keys obj)
    (unchecked-slot-ref obj 'keys))
  (define (&!kw-lambda-primary-main obj)
    (unchecked-slot-ref obj 'main))
  (define (&!kw-lambda-primary-keys-set! obj val)
    (unchecked-slot-set! obj 'keys val))
  (define (&!kw-lambda-primary-main-set! obj val)
    (unchecked-slot-set! obj 'main val)))

(begin
  (define !primitive::t
    (make-class-type 'gerbil\x23;!primitive::t '!primitive
      (list object::t) '() '((equal: . #t)) '#f))
  (define (!primitive . args) (apply make-!primitive args))
  (define (!primitive? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!primitive::t))
  (define (make-!primitive . args)
    (apply make-instance !primitive::t args)))

(begin
  (define !primitive-predicate::t
    (make-class-type 'gerbil\x23;!primitive-predicate::t '!primitive-predicate
      (list !primitive::t) '()
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!primitive-predicate . args)
    (let* ([type !primitive-predicate::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!primitive-predicate? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!primitive-predicate::t)))

(begin
  (define !primitive-lambda::t
    (make-class-type 'gerbil\x23;!primitive-lambda::t '!primitive-lambda
      (list !primitive::t) '()
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!primitive-lambda . args)
    (let* ([type !primitive-lambda::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!primitive-lambda? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!primitive-lambda::t)))

(begin
  (define !primitive-case-lambda::t
    (make-class-type 'gerbil\x23;!primitive-case-lambda::t
      '!primitive-case-lambda (list !primitive::t) '()
      '((struct: . #t) (constructor: . :init!) (equal: . #t))
      '#f))
  (define (make-!primitive-case-lambda . args)
    (let* ([type !primitive-case-lambda::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (!primitive-case-lambda? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;!primitive-case-lambda::t)))

(begin
  (define !abort:::init!
    (lambda (self) (slot-set! self 'id 'abort)))
  (bind-method! !abort::t ':init! !abort:::init!))

(begin
  (define !class-meta:::init!
    (lambda (self klass)
      (slot-set! self 'id 'class)
      (slot-set! self 'class klass)))
  (bind-method! !class-meta::t ':init! !class-meta:::init!))

(begin
  (define !class:::init!
    (case-lambda
      [(self id super slots ctor-method struct? final? system?
        metaclass)
       (let lp ([rest super])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3543} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3543})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3544} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3543})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-3545} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3543})])
                 (let ([super-id #{hd dpuuv4a3mobea70icwo8nvdax-3544}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3545}])
                     (begin
                       (when (!class-final?
                               (optimizer-resolve-class
                                 `(!class ,id)
                                 super-id))
                         (raise-compile-error
                           "cannot extend final class"
                           `(!class ,id)
                           super-id))
                       (lp rest)))))
               (begin (void)))))
       (let* ([ctor-method (or ctor-method
                               (let lp ([rest super] [method #f])
                                 (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3546} rest])
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3546})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3547} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3546})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3548} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3546})])
                                         (let ([super-id #{hd dpuuv4a3mobea70icwo8nvdax-3547}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3548}])
                                             (begin
                                               (let ([klass (optimizer-resolve-class
                                                              `(!class ,id)
                                                              super-id)])
                                                 (cond
                                                   [(!class-constructor
                                                      klass) =>
                                                    (lambda (ctor-method)
                                                      (if method
                                                          (if (eq? ctor-method
                                                                   method)
                                                              (lp rest
                                                                  ctor-method)
                                                              (raise-compile-error
                                                                "conflicting implicit constructor methods"
                                                                `(!class
                                                                   ,id)
                                                                method
                                                                ctor-method))
                                                          (lp rest
                                                              ctor-method)))]
                                                   [else
                                                    (lp rest method)]))))))
                                       (begin method)))))])
         (call-with-values
           (lambda ()
             (c4-linearize (list) super
               (lambda (klass-id)
                 (cons
                   klass-id
                   (!class-precedence-list
                     (optimizer-resolve-class `(!class ,id) klass-id))))
               (lambda (klass-id)
                 (!class-struct?
                   (optimizer-resolve-class `(!class ,id) klass-id)))
               eq? identity))
           (lambda (precedence-list base-struct)
             (let* ([precedence-list (cond
                                       [(memq id '(t object class))
                                        precedence-list]
                                       [(memq 'object::t precedence-list)
                                        precedence-list]
                                       [system?
                                        (if (memq 't::t precedence-list)
                                            precedence-list
                                            (append
                                              precedence-list
                                              '(t::t)))]
                                       [else
                                        (let loop ([tail precedence-list]
                                                   [head (list)])
                                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3549} tail])
                                            (if (pair?
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-3549})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3550} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3549})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-3551} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3549})])
                                                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-3550}])
                                                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3551}])
                                                      (begin
                                                        (if (eq? hd 't::t)
                                                            (let ([#{f dpuuv4a3mobea70icwo8nvdax-3552} cons])
                                                              (fold-left
                                                                (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3553}
                                                                         #{e dpuuv4a3mobea70icwo8nvdax-3554})
                                                                  (#{f dpuuv4a3mobea70icwo8nvdax-3552}
                                                                    #{e dpuuv4a3mobea70icwo8nvdax-3554}
                                                                    #{a dpuuv4a3mobea70icwo8nvdax-3553}))
                                                                (cons
                                                                  'object::t
                                                                  tail)
                                                                head))
                                                            (loop
                                                              rest
                                                              (cons
                                                                hd
                                                                head)))))))
                                                (begin
                                                  (let ([#{f dpuuv4a3mobea70icwo8nvdax-3555} cons])
                                                    (fold-left
                                                      (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3556}
                                                               #{e dpuuv4a3mobea70icwo8nvdax-3557})
                                                        (#{f dpuuv4a3mobea70icwo8nvdax-3555}
                                                          #{e dpuuv4a3mobea70icwo8nvdax-3557}
                                                          #{a dpuuv4a3mobea70icwo8nvdax-3556}))
                                                      '(object::t t::t)
                                                      head))))))])])
               (let* ([fields (compute-class-fields
                                `(!class ,id)
                                base-struct
                                precedence-list
                                slots)])
                 (slot-set! self 'id id)
                 (slot-set! self 'super super)
                 (slot-set! self 'precedence-list precedence-list)
                 (slot-set! self 'slots slots)
                 (slot-set! self 'fields fields)
                 (slot-set! self 'constructor ctor-method)
                 (slot-set! self 'struct? struct?)
                 (slot-set! self 'final? final?)
                 (slot-set! self 'metaclass metaclass))))))]
      [(self id super precedence-list slots fields constructor
        struct? final? system? metaclass methods)
       (slot-set! self 'id id)
       (slot-set! self 'super super)
       (slot-set! self 'precedence-list precedence-list)
       (slot-set! self 'slots slots)
       (slot-set! self 'fields fields)
       (slot-set! self 'constructor constructor)
       (slot-set! self 'struct? struct?)
       (slot-set! self 'final? final?)
       (slot-set! self 'metaclass metaclass)
       (when methods
         (slot-set! self 'methods (list->hash-table-eq methods)))]))
  (bind-method! !class::t ':init! !class:::init!))

(define (compute-class-fields where base-struct
         precedence-list direct-slots)
  (let* ([base-fields (if base-struct
                          (!class-fields
                            (optimizer-resolve-class where base-struct))
                          (list))])
    (let* ([r-fields (reverse base-fields)])
      (let* ([seen-slots (let ([tab (make-hash-table-eq)])
                           (for-each
                             (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3558})
                               (hash-put!
                                 tab
                                 #{cut-arg dpuuv4a3mobea70icwo8nvdax-3558}
                                 #t))
                             base-fields)
                           tab)])
        (let* ([process-slot (lambda (slot)
                               (unless (hash-get seen-slots slot)
                                 (hash-put! seen-slots slot #t)
                                 (set! r-fields (cons slot r-fields))))])
          (for-each
            (lambda (mixin)
              (let ([klass (optimizer-resolve-class where mixin)])
                (unless (!class-struct? klass)
                  (for-each process-slot (!class-fields klass)))))
            precedence-list)
          (for-each process-slot direct-slots)
          (reverse r-fields))))))

(define (!class-slot->field-offset klass slot)
  (let lp ([rest (!class-fields klass)] [offset 1])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3559} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3559})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3560} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3559})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-3561} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3559})])
            (let ([s #{hd dpuuv4a3mobea70icwo8nvdax-3560}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3561}])
                (begin (if (eq? s slot) offset (lp rest (fx1+ offset)))))))
          (begin
            (raise-compile-error
              "unknown class slot"
              (!type-id klass)
              (!class-fields klass)
              slot))))))

(define (!class-slot-find-struct klass slot)
  (if (!class-struct-slot? klass slot)
      klass
      (let lp ([rest (!class-precedence-list klass)])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3562} rest])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3562})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3563} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3562})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-3564} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3562})])
                (let ([super #{hd dpuuv4a3mobea70icwo8nvdax-3563}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3564}])
                    (begin
                      (let ([super-class (optimizer-resolve-class
                                           `(!class-slot-find-struct
                                              ,(!type-id klass)
                                              ,slot)
                                           super)])
                        (if (!class-struct-slot? super-class slot)
                            super-class
                            (lp rest)))))))
              (begin #f))))))

(define (!class-struct-slot? klass slot)
  (and (!class-struct? klass)
       (memq slot (!class-fields klass))))

(begin
  (define !predicate:::init!
    (lambda (self id)
      (slot-set! self 'id id)
      (slot-set!
        self
        'signature
        (!signature 'return: 'boolean::t 'effect: '(pure predicate)
          'arguments: '(t::t)))))
  (bind-method! !predicate::t ':init! !predicate:::init!))

(begin
  (define !constructor:::init!
    (lambda (self id)
      (slot-set! self 'id id)
      (slot-set!
        self
        'signature
        (!signature 'return: id 'effect: '(alloc)))))
  (bind-method! !constructor::t ':init! !constructor:::init!))

(begin
  (define !accessor:::init!
    (lambda (self id slot checked?)
      (slot-set! self 'id id)
      (slot-set! self 'slot slot)
      (slot-set! self 'checked? checked?)
      (slot-set!
        self
        'signature
        (!signature 'return: 't::t 'effect: '(pure) 'arguments:
          (list id)))))
  (bind-method! !accessor::t ':init! !accessor:::init!))

(begin
  (define !mutator:::init!
    (lambda (self id slot checked?)
      (slot-set! self 'id id)
      (slot-set! self 'slot slot)
      (slot-set! self 'checked? checked?)
      (slot-set!
        self
        'signature
        (!signature 'return: 'void::t 'effect: '(mut) 'arguments:
          (list id 't::t)))))
  (bind-method! !mutator::t ':init! !mutator:::init!))

(begin
  (define !lambda:::init!
    (case-lambda
      [(self arity dispatch)
       (let* ([signature #f])
         (slot-set! self 'id 'procedure)
         (slot-set! self 'arity arity)
         (slot-set! self 'dispatch dispatch)
         (slot-set! self 'signature signature))]
      [(self arity dispatch signature)
       (slot-set! self 'id 'procedure)
       (slot-set! self 'arity arity)
       (slot-set! self 'dispatch dispatch)
       (slot-set! self 'signature signature)]))
  (bind-method! !lambda::t ':init! !lambda:::init!))

(begin
  (define !case-lambda:::init!
    (case-lambda
      [(self clauses)
       (let* ([signature #f])
         (slot-set! self 'id 'procedure)
         (slot-set! self 'signature signature)
         (slot-set! self 'clauses clauses))]
      [(self clauses signature)
       (slot-set! self 'id 'procedure)
       (slot-set! self 'signature signature)
       (slot-set! self 'clauses clauses)]))
  (bind-method! !case-lambda::t ':init! !case-lambda:::init!))

(begin
  (define !kw-lambda:::init!
    (lambda (self tab dispatch)
      (slot-set! self 'id 'procedure)
      (slot-set! self 'table tab)
      (slot-set! self 'dispatch dispatch)))
  (bind-method! !kw-lambda::t ':init! !kw-lambda:::init!))

(begin
  (define !kw-lambda-primary:::init!
    (lambda (self keys main)
      (slot-set! self 'id 'procedure)
      (slot-set! self 'keys keys)
      (slot-set! self 'main main)))
  (bind-method!
    !kw-lambda-primary::t
    ':init!
    !kw-lambda-primary:::init!))

(begin
  (define !primitive-lambda:::init! !lambda:::init!)
  (bind-method!
    !primitive-lambda::t
    ':init!
    !primitive-lambda:::init!))

(begin
  (define !primitive-case-lambda:::init! !case-lambda:::init!)
  (bind-method!
    !primitive-case-lambda::t
    ':init!
    !primitive-case-lambda:::init!))

(begin
  (define !primitive-predicate:::init!
    (lambda (self id)
      (slot-set! self 'id id)
      (slot-set!
        self
        'signature
        (!signature 'return: 'boolean::t 'effect: '(pure)
          'arguments: '(t::t)))))
  (bind-method!
    !primitive-predicate::t
    ':init!
    !primitive-predicate:::init!))

(define (!class-method-table klass)
  (cond
    [(!class-methods klass)]
    [else
     (let ([tab (make-hash-table-eq)])
       (!class-methods-set! klass tab)
       tab)]))

(define (!class-lookup-method klass method)
  (let ([tab (!class-methods klass)])
    (and tab (begin (hash-get tab method)))))

(define (!type-subtype? type-a type-b)
  (and type-a
       type-b
       (or (eq? type-a type-b)
           (eq? (!type-id type-b) 't)
           (and (!procedure? type-a)
                (eq? (!type-id type-b) 'procedure))
           (and (!class? type-a)
                (!class? type-b)
                (!class-subclass? type-a type-b)))))

(define (!class-subclass? klass-a klass-b)
  (or (eq? (!type-id klass-a) (!type-id klass-b))
      (let ([klass-id-b (!type-id klass-b)]
            [precedence-list (!class-precedence-list klass-a)])
        (let loop ([rest precedence-list])
          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3565} rest])
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3565})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3566} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3565})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-3567} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3565})])
                  (let ([klass-name #{hd dpuuv4a3mobea70icwo8nvdax-3566}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3567}])
                      (begin
                        (or (eq? (!type-id
                                   (optimizer-resolve-class
                                     `(subclass? ,klass-a ,klass-b)
                                     klass-name))
                                 klass-id-b)
                            (loop rest))))))
                (begin #f)))))))

(define (!interface-instance? type)
  (and (!class? type)
       (memq
         'interface-instance::t
         (!class-precedence-list type))))

(define (!procedure-origin proc)
  (let ([proc proc])
    (and (slot-ref proc 'signature)
         (slot-ref proc 'signature.origin))))

(define optimizer-declare-type!
  (case-lambda
    [(sym type)
     (let* ([local? #f])
       (unless (!type? type)
         (error 'gerbil "bad declaration: expected !type" sym type))
       (verbose "declare-type " sym " " type)
       (let ([table (if local?
                        (current-compile-local-type)
                        (optimizer-info-type
                          (current-compile-optimizer-info)))])
         (hash-put! table sym type)))]
    [(sym type local?)
     (unless (!type? type)
       (error 'gerbil "bad declaration: expected !type" sym type))
     (verbose "declare-type " sym " " type)
     (let ([table (if local?
                      (current-compile-local-type)
                      (optimizer-info-type
                        (current-compile-optimizer-info)))])
       (hash-put! table sym type))]))

(define (optimizer-declare-class! sym type)
  (unless (!class? type)
    (error 'gerbil "bad declaration: expected !class" sym type))
  (let ([table (optimizer-info-classes
                 (current-compile-optimizer-info))])
    (verbose "declare-class " sym " " (struct->list type))
    (hash-put! table sym type)
    (hash-put! table type sym)))

(define (optimizer-declare-builtin-class! sym type)
  (unless (!class? type)
    (error 'gerbil "bad declaration: expected !class" sym type))
  (let ([table (optimizer-info-classes
                 (current-compile-optimizer-info))])
    (unless (hash-get table sym)
      (verbose
        "declare-builtin-class "
        sym
        " "
        (struct->list type))
      (hash-put! table sym type)
      (hash-put! table type sym))))

(define (optimizer-clear-type! sym)
  (verbose "clear-type " sym)
  (hash-remove! (current-compile-local-type) sym)
  (hash-remove!
    (optimizer-info-type (current-compile-optimizer-info))
    sym))

(define optimizer-declare-method!
  (case-lambda
    [(type-t method sym)
     (let* ([rebind? #f])
       (hash-put!
         (optimizer-info-methods (current-compile-optimizer-info))
         sym
         #t)
       (let ([klass (optimizer-lookup-class type-t)])
         (if klass
             (let ([vtab (!class-method-table klass)])
               (cond
                 [(hash-get vtab method) =>
                  (lambda (existing)
                    (cond
                      [rebind?
                       (verbose
                         "declare-method: rebind existing method"
                         type-t
                         " "
                         method)
                       (hash-put! vtab method sym)]
                      [(eq? existing sym) (void)]
                      [else
                       (raise-compile-error
                         "declare-method: duplicate method declaration"
                         `(bind-method! ,type-t ,method ,sym)
                         method)]))]
                 [else
                  (verbose "declare-method " type-t " " method " => " sym)
                  (hash-put! vtab method sym)]))
             (verbose "declare-method: unknown class" type-t))))]
    [(type-t method sym rebind?)
     (hash-put!
       (optimizer-info-methods (current-compile-optimizer-info))
       sym
       #t)
     (let ([klass (optimizer-lookup-class type-t)])
       (if klass
           (let ([vtab (!class-method-table klass)])
             (cond
               [(hash-get vtab method) =>
                (lambda (existing)
                  (cond
                    [rebind?
                     (verbose
                       "declare-method: rebind existing method"
                       type-t
                       " "
                       method)
                     (hash-put! vtab method sym)]
                    [(eq? existing sym) (void)]
                    [else
                     (raise-compile-error
                       "declare-method: duplicate method declaration"
                       `(bind-method! ,type-t ,method ,sym)
                       method)]))]
               [else
                (verbose "declare-method " type-t " " method " => " sym)
                (hash-put! vtab method sym)]))
           (verbose "declare-method: unknown class" type-t)))]))

(define (optimizer-lookup-type sym)
  (or (agetq sym (current-compile-path-type))
      (let ([ht (current-compile-local-type)])
        (and ht (begin (hash-get ht sym))))
      (hash-get
        (optimizer-info-type (current-compile-optimizer-info))
        sym)))

(define (optimizer-resolve-type sym)
  (let ([type (optimizer-lookup-type sym)])
    (and type
         (begin
           (if (!alias? type)
               (optimizer-resolve-type (!type-id type))
               type)))))

(define (optimizer-lookup-class sym)
  (let ([table (optimizer-info-classes
                 (current-compile-optimizer-info))])
    (hash-get table sym)))

(define (optimizer-resolve-class where sym)
  (cond
    [(optimizer-lookup-class sym) =>
     (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3568})
       #{cut-arg dpuuv4a3mobea70icwo8nvdax-3568})]
    [else
     (begin
       (raise-compile-error "unknown class" where sym)
       (void))]))

(define (optimizer-lookup-class-name klass)
  (hash-get
    (optimizer-info-classes (current-compile-optimizer-info))
    klass))

(define (optimizer-lookup-method type-t method)
  (!class-lookup-method
    (optimizer-resolve-class 'lookup-method type-t)
    method))

(define (optimizer-top-level-method? sym)
  (hash-get
    (optimizer-info-methods (current-compile-optimizer-info))
    sym))

(define (optimizer-current-types)
  (define (type-e t)
    (cond
      [(symbol? t) (type-e (optimizer-lookup-type t))]
      [(!lambda? t) (lambda-type t)]
      [(!kw-lambda? t) (kw-lambda-type t)]
      [(!kw-lambda-primary? t) (kw-lambda-primary-type t)]
      [(!procedure? t)
       (cons
         'procedure
         (let ([t t])
           (and (slot-ref t 'signature)
                (slot-ref t 'signature.return))))]
      [(!type? t) (!type-id t)]
      [else #f]))
  (begin
    (define (lambda-type t)
      (if (slot-ref t 'dispatch)
          (type-e (slot-ref t 'dispatch))
          (cons
            'procedure
            (and (slot-ref t 'signature)
                 (slot-ref t 'signature.return)))))
    (define __lambda-type lambda-type))
  (begin
    (define (kw-lambda-type t) (type-e (slot-ref t 'dispatch)))
    (define __kw-lambda-type kw-lambda-type))
  (begin
    (define (kw-lambda-primary-type t)
      (type-e (slot-ref t 'main)))
    (define __kw-lambda-primary-type kw-lambda-primary-type))
  (let* ([ht1 (optimizer-info-type
                (current-compile-optimizer-info))])
    (let* ([ht2 (current-compile-local-type)])
      (let* ([result (if ht1 (hash->list ht1) (list))])
        (let* ([result (if ht2
                           (let ([#{f dpuuv4a3mobea70icwo8nvdax-3569} cons])
                             (fold-left
                               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3570}
                                        #{e dpuuv4a3mobea70icwo8nvdax-3571})
                                 (#{f dpuuv4a3mobea70icwo8nvdax-3569}
                                   #{e dpuuv4a3mobea70icwo8nvdax-3571}
                                   #{a dpuuv4a3mobea70icwo8nvdax-3570}))
                               result
                               (hash->list ht2)))
                           result)])
          (for-each
            (lambda (p)
              (let* ([t (cdr p)])
                (let* ([tr (type-e t)]) (set-cdr! p tr))))
            result)
          (list-sort
            (lambda (a b)
              (string<?
                (symbol->string (car a))
                (symbol->string (car b))))
            result))))))

