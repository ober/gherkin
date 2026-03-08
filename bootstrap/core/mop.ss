(begin
  (begin
    (define (module-type-id type-t)
      (cond
        [(module-context-ns (current-expander-context)) =>
         (lambda (ns) (stx-identifier type-t ns "#" type-t "::t"))]
        [else
         (let ([mid (expander-context-id
                      (current-expander-context))])
           (stx-identifier type-t mid "#" type-t "::t"))]))
    (define (make-class-type-id type-t)
      (if (module-context? (current-expander-context))
          (module-type-id type-t)
          (make-symbol
            "__"
            (gensym
              (let ([x (stx-e type-t)])
                (if (symbol? x) (symbol->string x) x)))
            "::t")))
    (define (generate-typedef stx struct?)
      (define (wrap e-stx)
        (stx-wrap-source e-stx (stx-source stx)))
      (define (slot-name slot-spec)
        (syntax-case slot-spec () [(slot getf setf) #'slot]))
      (define (class-opt? key)
        (memq
          (stx-e key)
          (cons
            'struct:
            (cons
              'slots:
              (cons
                'id:
                (cons
                  'name:
                  (cons
                    'properties:
                    (cons
                      'constructor:
                      (cons
                        'final:
                        (cons 'mixin: (cons 'metaclass: '())))))))))))
      (syntax-case stx ()
        [(_ type-t super make instance? . rest)
         (and (identifier? #'type-t)
              (identifier-list? #'super)
              (or (identifier? #'make) (stx-false? #'make))
              (identifier? #'instance?)
              (stx-plist? #'rest class-opt?))
         (with-syntax*
           (((values struct?)
              (cond
                [struct?]
                [(stx-getq struct: #'rest) => stx-e]
                [else #f]))
            ((values slots) (or (stx-getq slots: #'rest) (\x40;list)))
            ((values mixin-slots)
              (or (stx-getq mixin: #'rest) (\x40;list)))
            ((values accessible-slots)
              (append (syntax->list slots) (syntax->list mixin-slots)))
            ((values metaclass) (stx-getq metaclass: #'rest))
            ((slot ...) (stx-map slot-name slots))
            (type-id
              (or (stx-getq id: #'rest) (make-class-type-id #'type-t)))
            (type-name (or (stx-getq name: #'rest) #'type-t))
            (type-constructor (stx-getq constructor: #'rest))
            (mop-type-t (core-quote-syntax #'type-t))
            (mop-super (stx-map core-quote-syntax #'super))
            (mop-struct? struct?) (mop-final? (stx-getq final: #'rest))
            (mop-metaclass
              (if (stx-e metaclass) (core-quote-syntax metaclass) #f))
            (type-properties
              (or (stx-getq properties: #'rest) #'(\x40;list)))
            (type-properties
              (if (stx-e #'mop-final?)
                  #'(\x40;list (\x40;list final: . #t) :: type-properties)
                  #'type-properties))
            (type-properties
              (if struct?
                  #'(\x40;list (\x40;list struct: . #t) :: type-properties)
                  #'type-properties))
            (type-properties
              (if (stx-e metaclass)
                  (with-syntax ([metaclass metaclass])
                    #'(\x40;list
                        (\x40;list metaclass: :: metaclass)
                        ::
                        type-properties))
                  #'type-properties))
            (type-super (cons #'list #'super))
            (make-type-rtd
              #'(make-class-type 'type-id 'type-name type-super
                  '(slot ...) type-properties 'type-constructor))
            (def-type
              (wrap
                #'(def type-t
                       (begin-annotation
                         (\x40;mop.class type-id mop-super (slot ...) type-constructor
                           mop-struct? mop-final? mop-metaclass)
                         make-type-rtd))))
            (def-make
              (if (stx-false? #'make)
                  #'(begin)
                  (wrap
                    #'(def make
                           (begin-annotation
                             (\x40;mop.constructor mop-type-t)
                             (lambda $args
                               (apply make-instance type-t $args)))))))
            (def-predicate
              (wrap
                #'(def instance?
                       (begin-annotation
                         (\x40;mop.predicate mop-type-t)
                         (make-class-predicate type-t)))))
            (((def-getf def-setf) ...)
              (stx-map
                (lambda (ref)
                  (syntax-case ref ()
                    [(slot getf setf)
                     (\x40;list
                       (wrap
                         #'(def getf
                                (begin-annotation
                                  (\x40;mop.accessor mop-type-t slot #t)
                                  (make-class-slot-accessor
                                    type-t
                                    'slot))))
                       (wrap
                         #'(def setf
                                (begin-annotation
                                  (\x40;mop.mutator mop-type-t slot #t)
                                  (make-class-slot-mutator
                                    type-t
                                    'slot)))))]))
                accessible-slots))
            (((def-ugetf def-usetf) ...)
              (stx-map
                (lambda (ref)
                  (syntax-case ref ()
                    [(slot getf setf)
                     (with-syntax ([ugetf (stx-identifier
                                            #'getf
                                            "&"
                                            #'getf)]
                                   [usetf (stx-identifier
                                            #'setf
                                            "&"
                                            #'setf)])
                       (\x40;list
                         (wrap
                           #'(def ugetf
                                  (begin-annotation
                                    (\x40;mop.accessor mop-type-t slot #f)
                                    (make-class-slot-unchecked-accessor
                                      type-t
                                      'slot))))
                         (wrap
                           #'(def usetf
                                  (begin-annotation
                                    (\x40;mop.mutator mop-type-t slot #f)
                                    (make-class-slot-unchecked-mutator
                                      type-t
                                      'slot))))))]))
                accessible-slots)))
           (wrap
             #'(begin
                 def-type
                 def-predicate
                 def-make
                 def-getf
                 ...
                 def-setf
                 ...
                 def-ugetf
                 ...
                 def-usetf
                 ...)))])))
  (define-syntax defstruct-type
    (lambda (stx) (generate-typedef stx #t)))
  (define-syntax defclass-type
    (lambda (stx) (generate-typedef stx #f))))

(begin
  (defclass-type class-type-info::t () make-class-type-info class-type-info?
    'id: (slot-ref gerbil 'core\x23;class-type-info::t) 'name:
    class-type-info 'properties:
    (cons (cons 'print: '(name)) '()) 'slots:
    ((id !class-type-id !class-type-id-set!)
     (name !class-type-name !class-type-name-set!)
     (super !class-type-super !class-type-super-set!)
     (slots !class-type-slots !class-type-slots-set!)
     (precedence-list
       !class-type-precedence-list
       !class-type-precedence-list-set!)
     (ordered-slots
       !class-type-ordered-slots
       !class-type-ordered-slots-set!)
     (struct? !class-type-struct? !class-type-struct?-set!)
     (final? !class-type-final? !class-type-final?-set!)
     (system? !class-type-system? !class-type-system?-set!)
     (metaclass !class-type-metaclass !class-type-metaclass-set!)
     (constructor-method
       !class-type-constructor-method
       !class-type-constructor-method-set!)
     (type-descriptor
       !class-type-descriptor
       !class-type-descriptor-set!)
     (constructor
       !class-type-constructor
       !class-type-constructor-set!)
     (predicate !class-type-predicate !class-type-predicate-set!)
     (accessors !class-type-accessors !class-type-accessors-set!)
     (mutators !class-type-mutators !class-type-mutators-set!)
     (unchecked-accessors
       !class-type-unchecked-accessors
       !class-type-unchecked-accessors-set!)
     (unchecked-mutators
       !class-type-unchecked-mutators
       !class-type-unchecked-mutators-set!)
     (slot-types
       !class-type-slot-types
       !class-type-slot-types-set!)
     (slot-defaults
       !class-type-slot-defaults
       !class-type-slot-defaults-set!)
     (slot-contracts
       !class-type-slot-contracts
       !class-type-slot-contracts-set!)))
  (define (class-type-info::apply-macro-expander self stx)
    (syntax-case stx ()
      [(_ arg ...)
       (cond
         [(!class-type-constructor self) =>
          (lambda (make) (cons make #'(arg ...)))]
         [else
          (raise-syntax-error
            #f
            "no constructor defined for class"
            stx
            self)])]))
  (bind-method!
    class-type-info::t
    'apply-macro-expander
    class-type-info::apply-macro-expander)
  (define syntax-local-class-type-info?
    (case-lambda
      [(stx)
       (let* ([is? true])
         (and (identifier? stx)
              (let ([e (syntax-local-value stx false)])
                (and e (begin (and (class-type-info? e) (is? e)))))))]
      [(stx is?)
       (and (identifier? stx)
            (let ([e (syntax-local-value stx false)])
              (and e (begin (and (class-type-info? e) (is? e))))))])))

(begin
  (define-syntax class-type-info
    (make-class-type-info 'id:
     'gerbil.core\x23;class-type-info::t 'name: 'class-type-info
     'super: (list) 'slots:
     '(id name super slots precedence-list ordered-slots struct?
       final? system? metaclass constructor-method type-descriptor
       constructor predicate accessors mutators unchecked-accessors
       unchecked-mutators slot-types slot-defaults slot-contracts)
     'struct?: #f 'final?: #f 'system?: #f 'constructor-method:
     #f 'type-descriptor: (quote-syntax class-type-info::t)
     'constructor: (quote-syntax make-class-type-info)
     'predicate: (quote-syntax class-type-info?) 'accessors:
     (list (cons* 'id (quote-syntax !class-type-id))
      (cons* 'name (quote-syntax !class-type-name))
      (cons* 'super (quote-syntax !class-type-super))
      (cons* 'slots (quote-syntax !class-type-slots))
      (cons*
        'precedence-list
        (quote-syntax !class-type-precedence-list))
      (cons*
        'ordered-slots
        (quote-syntax !class-type-ordered-slots))
      (cons* 'struct? (quote-syntax !class-type-struct?))
      (cons* 'final? (quote-syntax !class-type-final?))
      (cons* 'system? (quote-syntax !class-type-system?))
      (cons* 'metaclass (quote-syntax !class-type-metaclass))
      (cons*
        'constructor-method
        (quote-syntax !class-type-constructor-method))
      (cons*
        'type-descriptor
        (quote-syntax !class-type-descriptor))
      (cons* 'constructor (quote-syntax !class-type-constructor))
      (cons* 'predicate (quote-syntax !class-type-predicate))
      (cons* 'accessors (quote-syntax !class-type-accessors))
      (cons* 'mutators (quote-syntax !class-type-mutators))
      (cons*
        'unchecked-accessors
        (quote-syntax !class-type-unchecked-accessors))
      (cons*
        'unchecked-mutators
        (quote-syntax !class-type-unchecked-mutators))
      (cons* 'slot-types (quote-syntax !class-type-slot-types))
      (cons*
        'slot-defaults
        (quote-syntax !class-type-slot-defaults))
      (cons*
        'slot-contracts
        (quote-syntax !class-type-slot-contracts)))
     'mutators:
     (list (cons* 'id (quote-syntax !class-type-id-set!))
      (cons* 'name (quote-syntax !class-type-name-set!))
      (cons* 'super (quote-syntax !class-type-super-set!))
      (cons* 'slots (quote-syntax !class-type-slots-set!))
      (cons*
        'precedence-list
        (quote-syntax !class-type-precedence-list-set!))
      (cons*
        'ordered-slots
        (quote-syntax !class-type-ordered-slots-set!))
      (cons* 'struct? (quote-syntax !class-type-struct?-set!))
      (cons* 'final? (quote-syntax !class-type-final?-set!))
      (cons* 'system? (quote-syntax !class-type-system?-set!))
      (cons* 'metaclass (quote-syntax !class-type-metaclass-set!))
      (cons*
        'constructor-method
        (quote-syntax !class-type-constructor-method-set!))
      (cons*
        'type-descriptor
        (quote-syntax !class-type-descriptor-set!))
      (cons*
        'constructor
        (quote-syntax !class-type-constructor-set!))
      (cons* 'predicate (quote-syntax !class-type-predicate-set!))
      (cons* 'accessors (quote-syntax !class-type-accessors-set!))
      (cons* 'mutators (quote-syntax !class-type-mutators-set!))
      (cons*
        'unchecked-accessors
        (quote-syntax !class-type-unchecked-accessors-set!))
      (cons*
        'unchecked-mutators
        (quote-syntax !class-type-unchecked-mutators-set!))
      (cons*
        'slot-types
        (quote-syntax !class-type-slot-types-set!))
      (cons*
        'slot-defaults
        (quote-syntax !class-type-slot-defaults-set!))
      (cons*
        'slot-contracts
        (quote-syntax !class-type-slot-contracts-set!)))
     'unchecked-accessors:
     (list (cons* 'id (quote-syntax &!class-type-id))
      (cons* 'name (quote-syntax &!class-type-name))
      (cons* 'super (quote-syntax &!class-type-super))
      (cons* 'slots (quote-syntax &!class-type-slots))
      (cons*
        'precedence-list
        (quote-syntax &!class-type-precedence-list))
      (cons*
        'ordered-slots
        (quote-syntax &!class-type-ordered-slots))
      (cons* 'struct? (quote-syntax &!class-type-struct?))
      (cons* 'final? (quote-syntax &!class-type-final?))
      (cons* 'system? (quote-syntax &!class-type-system?))
      (cons* 'metaclass (quote-syntax !class-type-metaclass))
      (cons*
        'constructor-method
        (quote-syntax &!class-type-constructor-method))
      (cons*
        'type-descriptor
        (quote-syntax &!class-type-descriptor))
      (cons* 'constructor (quote-syntax &!class-type-constructor))
      (cons* 'predicate (quote-syntax &!class-type-predicate))
      (cons* 'accessors (quote-syntax &!class-type-accessors))
      (cons* 'mutators (quote-syntax &!class-type-mutators))
      (cons*
        'unchecked-accessors
        (quote-syntax &!class-type-unchecked-accessors))
      (cons*
        'unchecked-mutators
        (quote-syntax &!class-type-unchecked-mutators))
      (cons* 'slot-types (quote-syntax &!class-type-slot-types))
      (cons*
        'slot-defaults
        (quote-syntax &!class-type-slot-defaults))
      (cons*
        'slot-contracts
        (quote-syntax &!class-type-slot-contracts)))
     'unchecked-mutators:
     (list (cons* 'id (quote-syntax &!class-type-id-set!))
      (cons* 'name (quote-syntax &!class-type-name-set!))
      (cons* 'super (quote-syntax &!class-type-super-set!))
      (cons* 'slots (quote-syntax &!class-type-slots-set!))
      (cons*
        'precedence-list
        (quote-syntax &!class-type-precedence-list-set!))
      (cons*
        'ordered-slots
        (quote-syntax &!class-type-ordered-slots-set!))
      (cons* 'struct? (quote-syntax &!class-type-struct?-set!))
      (cons* 'final? (quote-syntax &!class-type-final?-set!))
      (cons* 'system? (quote-syntax &!class-type-system?-set!))
      (cons*
        'metaclass
        (quote-syntax &!class-type-metaclass-set!))
      (cons*
        'constructor-method
        (quote-syntax &!class-type-constructor-method-set!))
      (cons*
        'type-descriptor
        (quote-syntax &!class-type-descriptor-set!))
      (cons*
        'constructor
        (quote-syntax &!class-type-constructor-set!))
      (cons*
        'predicate
        (quote-syntax &!class-type-predicate-set!))
      (cons*
        'accessors
        (quote-syntax &!class-type-accessors-set!))
      (cons* 'mutators (quote-syntax &!class-type-mutators-set!))
      (cons*
        'unchecked-accessors
        (quote-syntax &!class-type-unchecked-accessors-set!))
      (cons*
        'unchecked-mutators
        (quote-syntax &!class-type-unchecked-mutators-set!))
      (cons*
        'slot-types
        (quote-syntax &!class-type-slot-types-set!))
      (cons*
        'slot-defaults
        (quote-syntax &!class-type-slot-defaults-set!))
      (cons*
        'slot-contracts
        (quote-syntax &!class-type-slot-contracts-set!))))))

(begin
  (begin
    (define (typedef-body? stx)
      (define (body-opt? key)
        (memq
          (stx-e key)
          (cons
            'id:
            (cons
              'struct:
              (cons
                'name:
                (cons
                  'constructor:
                  (cons
                    'transparent:
                    (cons
                      'final:
                      (cons
                        'print:
                        (cons 'equal: (cons 'metaclass: '())))))))))))
      (stx-plist? stx body-opt?))
    (define (generate-defclass stx id super-ref slots body)
      (define (wrap e-stx)
        (stx-wrap-source e-stx (stx-source stx)))
      (define (make-id . args) (apply stx-identifier id args))
      (define (get-mixin-slots super slots)
        (define tab (make-hash-table-eq))
        (define (dedup mixins)
          (let lp ([rest mixins] [r (list)])
            (if (pair? rest)
                (let ([slot (car rest)])
                  (if (hash-get tab slot)
                      (lp (cdr rest) r)
                      (begin
                        (hash-put! tab slot #t)
                        (lp (cdr rest) (cons slot r)))))
                (reverse r))))
        (stx-for-each
          (lambda (slot) (hash-put! tab (stx-e slot) #t))
          slots)
        (cond
          [(not super) (list)]
          [(identifier? super) (dedup (get-mixin-slots-r super))]
          [else (dedup (concatenate (map get-mixin-slots-r super)))]))
      (define (get-mixin-slots-r type-id)
        (let ([info (syntax-local-value type-id)])
          (append
            (!class-type-slots info)
            (concatenate
              (map get-mixin-slots-r (!class-type-super info))))))
      (check-duplicate-identifiers slots stx)
      (with-syntax*
        (((values name) (symbol->string (stx-e id)))
         ((values super) (map syntax-local-value super-ref))
         ((values struct?) (stx-getq struct: body)) (type id)
         (type::t (make-id name "::t"))
         (make-type (make-id "make-" name))
         (type? (make-id name "?"))
         (type-super (map !class-type-descriptor super))
         ((slot ...) slots)
         ((getf ...) (stx-map (cut make-id name "-" <>) slots))
         ((setf ...)
           (stx-map (cut make-id name "-" <> "-set!") slots))
         ((values mixin-slots) (get-mixin-slots super-ref slots))
         ((mixin-slot ...) mixin-slots)
         ((mixin-getf ...)
           (stx-map (cut make-id name "-" <>) mixin-slots))
         ((mixin-setf ...)
           (stx-map (cut make-id name "-" <> "-set!") mixin-slots))
         ((ugetf ...) (stx-map (cut make-id "&" <>) #'(getf ...)))
         ((usetf ...) (stx-map (cut make-id "&" <>) #'(setf ...)))
         ((mixin-ugetf ...)
           (stx-map (cut make-id "&" <>) #'(mixin-getf ...)))
         ((mixin-usetf ...)
           (stx-map (cut make-id "&" <>) #'(mixin-setf ...)))
         ((values type-slots)
           (cond
             [(stx-null? slots) (\x40;list)]
             [else (\x40;list slots: #'((slot getf setf) ...))]))
         ((values type-mixin-slots)
           (cond
             [(stx-null? mixin-slots) (\x40;list)]
             [else
              (\x40;list
                mixin:
                #'((mixin-slot mixin-getf mixin-setf) ...))]))
         ((values type-name)
           (\x40;list name: (or (stx-getq name: body) id)))
         ((values type-id)
           (\x40;list
             id:
             (or (stx-getq id: body) (make-class-type-id #'type))))
         ((values type-constructor)
           (or (alet
                 (e (stx-getq constructor: body))
                 (\x40;list constructor: e))
               (\x40;list)))
         ((values properties)
           (let* ([properties (if (stx-e (stx-getq transparent: body))
                                  (\x40;list (\x40;list transparent: . #t))
                                  (\x40;list))]
                  [properties (cond
                                [(stx-e (stx-getq print: body)) =>
                                 (lambda (print)
                                   (let (print
                                         [if (eq? print #t) slots print])
                                     (cons
                                       (\x40;list print: . print)
                                       properties)))]
                                [else properties])]
                  [properties (cond
                                [(stx-e (stx-getq equal: body)) =>
                                 (lambda (equal)
                                   (let (equal
                                         [if (eq? equal #t) slots equal])
                                     (cons
                                       (\x40;list equal: . equal)
                                       properties)))]
                                [else properties])])
             properties))
         ((values type-properties)
           (if (null? properties)
               (\x40;list)
               (with-syntax ([properties properties])
                 (\x40;list properties: #''properties))))
         ((values metaclass)
           (cond
             [(stx-getq metaclass: body) =>
              (lambda (metaclass)
                (and (identifier? metaclass) metaclass))]
             [else #f]))
         ((values type-metaclass)
           (if metaclass (\x40;list metaclass: metaclass) (\x40;list)))
         ((values final?) (stx-e (stx-getq final: body)))
         ((values type-struct) (\x40;list struct: struct?))
         ((values type-final) (\x40;list final: final?))
         ((type-body ...)
           (\x40;list type-id ... type-name ... type-constructor ... type-struct
             ... type-final ... type-metaclass ... type-properties ...
             type-slots ... type-mixin-slots ...))
         (typedef
           (wrap
             #'(defclass-type type::t type-super make-type type?
                 type-body ...)))
         (meta-type-id (with-syntax ([(id: id) type-id]) #''id))
         (meta-type-name
           (with-syntax ([type-name (cadr type-name)]) #''type-name))
         (meta-type-super
           (with-syntax ([(super-id ...) super-ref])
             #'(\x40;list (quote-syntax super-id) ...)))
         (meta-type-slots #''(slot ...)) (meta-type-struct? struct?)
         (meta-type-final? final?)
         (meta-type-metaclass
           (if metaclass
               (with-syntax ([metaclass metaclass])
                 #'(quote-syntax metaclass))
               #f))
         (meta-type-constructor-method
           (if (null? type-constructor)
               #f
               (with-syntax ([(constructor: kons) type-constructor])
                 #''kons)))
         (meta-type-descriptor #'(quote-syntax type::t))
         (meta-type-constructor #'(quote-syntax make-type))
         (meta-type-predicate #'(quote-syntax type?))
         (meta-type-accessors
           #'(\x40;list
               (\x40;list 'slot :: (quote-syntax getf))
               ...
               (\x40;list 'mixin-slot :: (quote-syntax mixin-getf))
               ...))
         (meta-type-mutators
           #'(\x40;list
               (\x40;list 'slot :: (quote-syntax setf))
               ...
               (\x40;list 'mixin-slot :: (quote-syntax mixin-setf))
               ...))
         (meta-type-unchecked-accessors
           #'(\x40;list
               (\x40;list 'slot :: (quote-syntax ugetf))
               ...
               (\x40;list 'mixin-slot :: (quote-syntax mixin-ugetf))
               ...))
         (meta-type-unchecked-mutators
           #'(\x40;list
               (\x40;list 'slot :: (quote-syntax usetf))
               ...
               (\x40;list 'mixin-slot :: (quote-syntax mixin-usetf))
               ...))
         (metadef
           (wrap
             #'(defsyntax
                 type
                 (make-class-type-info id: meta-type-id name:
                  meta-type-name slots: meta-type-slots super:
                  meta-type-super struct?: meta-type-struct? final?:
                  meta-type-final? metaclass: meta-type-metaclass
                  constructor-method: meta-type-constructor-method
                  type-descriptor: meta-type-descriptor constructor:
                  meta-type-constructor predicate: meta-type-predicate
                  accessors: meta-type-accessors mutators:
                  meta-type-mutators unchecked-accessors:
                  meta-type-unchecked-accessors unchecked-mutators:
                  meta-type-unchecked-mutators)))))
        (wrap #'(begin typedef metadef)))))
  (define-syntax defstruct
    (syntax-rules ()
      [(_ hd slots . rest)
       (defclass hd slots struct: #t . rest)]))
  (define define-struct defstruct)
  (define-syntax defclass
    (lambda (stx)
      (define (generate hd slots body)
        (syntax-case hd ()
          [(id . super)
           (and (stx-list? #'super)
                (stx-andmap syntax-local-class-type-info? #'super))
           (generate-defclass stx #'id (syntax->list #'super) slots
             body)]
          [_
           (if (identifier? hd)
               (generate-defclass stx hd (\x40;list) slots body)
               (raise-syntax-error
                 #f
                 "bad syntax; class name should be an identifier"
                 stx
                 hd))]))
      (syntax-case stx ()
        [(_ hd slots . rest)
         (and (identifier-list? #'slots) (typedef-body? #'rest))
         (generate #'hd #'slots #'rest)])))
  (define define-class defclass)
  (define-syntax defmethod
    (lambda (stx)
      (define (wrap e-stx)
        (stx-wrap-source e-stx (stx-source stx)))
      (define (method-opt? x)
        (memq (stx-e x) (cons 'rebind: '())))
      (syntax-case stx (\x40;method)
        [(_ (\x40;method id type) impl . rest)
         (cond
           [(and (identifier? #'id)
                 (syntax-local-class-type-info? #'type)
                 (stx-plist? #'rest method-opt?))
            (with-syntax*
              (((values klass) (syntax-local-value #'type)) ((values rebind?) (stx-e (stx-getq rebind: #'rest)))
                (type::t (!class-type-descriptor klass))
                (name (stx-identifier #'type #'type "::" #'id))
                (\x40;next-method
                  (stx-identifier #'type '\x40;next-method))
                (defimpl
                  (wrap
                    #'(def name
                           (let-syntax ([\x40;next-method (syntax-rules ()
                                                            [(_ obj
                                                                arg
                                                                (... ...))
                                                             (call-next-method type::t obj
                                                               'id arg
                                                               (... ...))])])
                             impl))))
                (rebind? rebind?)
                (bind (wrap #'(bind-method! type::t 'id name rebind?))))
              (wrap #'(begin defimpl bind)))]
           [(not (identifier? #'id))
            (raise-syntax-error
              #f
              "bad syntax; expected method identifier"
              stx
              #'id)]
           [(not (syntax-local-class-type-info? #'type))
            (raise-syntax-error
              #f
              "bad syntax; expected type identifier"
              stx
              #'type)]
           [else
            (raise-syntax-error
              #f
              "bad syntax; illegal method options"
              stx)])])))
  (define-syntax \x40;method
    (lambda (stx)
      (define (dotted-identifier? id)
        (and (identifier? id)
             (let ([id-str (symbol->string (stx-e id))])
               (and (string-index id-str #\.)
                    (let ([split (let ([#{str dpuuv4a3mobea70icwo8nvdax-1756} id-str]
                                       [#{sep dpuuv4a3mobea70icwo8nvdax-1757} (if (char?
                                                                                    #\.)
                                                                                  #\.
                                                                                  (string-ref
                                                                                    #\.
                                                                                    0))])
                                   (let split-lp ([i 0]
                                                  [start 0]
                                                  [acc '()])
                                     (cond
                                       [(= i
                                           (string-length
                                             #{str dpuuv4a3mobea70icwo8nvdax-1756}))
                                        (reverse
                                          (cons
                                            (substring
                                              #{str dpuuv4a3mobea70icwo8nvdax-1756}
                                              start
                                              i)
                                            acc))]
                                       [(char=?
                                          (string-ref
                                            #{str dpuuv4a3mobea70icwo8nvdax-1756}
                                            i)
                                          #{sep dpuuv4a3mobea70icwo8nvdax-1757})
                                        (split-lp
                                          (+ i 1)
                                          (+ i 1)
                                          (cons
                                            (substring
                                              #{str dpuuv4a3mobea70icwo8nvdax-1756}
                                              start
                                              i)
                                            acc))]
                                       [else
                                        (split-lp (+ i 1) start acc)])))])
                      (fx= (length split) 2))))))
      (define (split-dotted id)
        (let* ([id-str (symbol->string (stx-e id))])
          (let* ([split (let ([#{str dpuuv4a3mobea70icwo8nvdax-1758} id-str]
                              [#{sep dpuuv4a3mobea70icwo8nvdax-1759} (if (char?
                                                                           #\.)
                                                                         #\.
                                                                         (string-ref
                                                                           #\.
                                                                           0))])
                          (let split-lp ([i 0] [start 0] [acc '()])
                            (cond
                              [(= i
                                  (string-length
                                    #{str dpuuv4a3mobea70icwo8nvdax-1758}))
                               (reverse
                                 (cons
                                   (substring
                                     #{str dpuuv4a3mobea70icwo8nvdax-1758}
                                     start
                                     i)
                                   acc))]
                              [(char=?
                                 (string-ref
                                   #{str dpuuv4a3mobea70icwo8nvdax-1758}
                                   i)
                                 #{sep dpuuv4a3mobea70icwo8nvdax-1759})
                               (split-lp
                                 (+ i 1)
                                 (+ i 1)
                                 (cons
                                   (substring
                                     #{str dpuuv4a3mobea70icwo8nvdax-1758}
                                     start
                                     i)
                                   acc))]
                              [else (split-lp (+ i 1) start acc)])))])
            (list
              (stx-identifier id (car split))
              (stx-identifier id (cadr split))))))
      (syntax-case stx ()
        [(_ id arg ... last)
         (and (dotted-identifier? #'id)
              (stx-ormap ellipsis? #'(arg ...)))
         (with-syntax ([(object method) (split-dotted #'id)])
           #'(apply call-method object 'method (\x40;list arg ...)))]
        [(_ id arg ...)
         (dotted-identifier? #'id)
         (with-syntax ([(object method) (split-dotted #'id)])
           #'(call-method object 'method arg ...))]
        [(_ id obj arg ...)
         (and (identifier? #'id) (stx-ormap ellipsis? #'(arg ...)))
         #'(apply call-method obj 'id (\x40;list arg ...))]
        [(_ id obj arg ...)
         (identifier? #'id)
         #'(call-method obj 'id arg ...)])))
  (define-syntax \x40;
    (syntax-rules ()
      [(_ obj id) (slot-ref obj 'id)]
      [(recur obj id rest ...) (recur (recur obj id) rest ...)]))
  (define-syntax \x40;-set!
    (syntax-rules ()
      [(_ obj id val) (slot-set! obj 'id val)]
      [(recur obj id path ... last val)
       (recur (\x40; obj id path ...) last val)])))

(begin
  (define-syntax defsystem-class-info
    (lambda (stx)
      (syntax-case stx ()
        [(_ id type (super ...) predicate)
         (let (klass [eval-syntax #'type])
           (with-syntax ([type-id (class-type-id klass)]
                         [type-name (class-type-name klass)])
             #'(defsyntax
                 id
                 (make-class-type-info id: 'type-id name: 'type-name super:
                  (\x40;list (quote-syntax super) ...) slots: (\x40;list)
                  system?: #t type-descriptor: (quote-syntax type)
                  predicate: (quote-syntax predicate) accessors:
                  (\x40;list) mutators: (\x40;list) unchecked-accessors:
                  (\x40;list) unchecked-mutators: (\x40;list)))))])))
  (defsystem-class-info :t t::t () true)
  (defsystem-class-info :class class::t (:t) class-type?)
  (define-syntax class
    (make-class-type-info 'id: 'class 'name: 'class 'super:
     (list (quote-syntax :t)) 'slots:
     '(id name super flags fields precedence-list slot-vector
          slot-table properties constructor methods)
     'struct?: #t 'type-descriptor: (quote-syntax class::t)
     'constructor: (quote-syntax make-class-type) 'predicate:
     (quote-syntax class-type?) 'accessors:
     (list (cons* 'id (quote-syntax class-type-id))
       (cons* 'name (quote-syntax class-type-name))
       (cons* 'super (quote-syntax class-type-super))
       (cons* 'flags (quote-syntax class-type-flags))
       (cons* 'fields (quote-syntax class-type-fields))
       (cons*
         'precedence-list
         (quote-syntax class-type-precedence-list))
       (cons* 'slot-vector (quote-syntax class-type-slot-vector))
       (cons* 'slot-table (quote-syntax class-type-slot-table))
       (cons* 'properties (quote-syntax class-type-properties))
       (cons* 'constructor (quote-syntax class-type-constructor))
       (cons* 'methods (quote-syntax class-type-methods)))
     'mutators: (list) 'unchecked-accessors:
     (list (cons* 'id (quote-syntax &class-type-id))
       (cons* 'name (quote-syntax &class-type-name))
       (cons* 'super (quote-syntax &class-type-super))
       (cons* 'flags (quote-syntax &class-type-flags))
       (cons* 'fields (quote-syntax &class-type-fields))
       (cons*
         'precedence-list
         (quote-syntax &class-type-precedence-list))
       (cons* 'slot-vector (quote-syntax &class-type-slot-vector))
       (cons* 'slot-table (quote-syntax &class-type-slot-table))
       (cons* 'properties (quote-syntax &class-type-properties))
       (cons* 'constructor (quote-syntax &class-type-constructor))
       (cons* 'methods (quote-syntax &class-type-methods)))
     'unchecked-mutators: (list)))
  (defsystem-class-info :object object::t (:t) true)
  (defsystem-class-info
    :immediate
    immediate::t
    (:t)
    immediate?)
  (defsystem-class-info :char char::t (:immediate) char?)
  (defsystem-class-info
    :boolean
    boolean::t
    (:immediate)
    boolean?)
  (defsystem-class-info :atom atom::t (:immediate) atom?)
  (defsystem-class-info :void void::t (:atom) void?)
  (defsystem-class-info :eof eof::t (:atom) eof-object?)
  (defsystem-class-info :true true::t (:boolean :atom) true?)
  (defsystem-class-info :false false::t (:boolean :atom) not)
  (defsystem-class-info :special special::t (:atom) special?)
  (defsystem-class-info :number number::t (:t) number?)
  (defsystem-class-info :real real::t (:number) real?)
  (defsystem-class-info
    :integer
    integer::t
    (:real)
    exact-integer?)
  (defsystem-class-info
    :fixnum
    fixnum::t
    (:integer :immediate)
    fixnum?)
  (defsystem-class-info
    :bignum
    bignum::t
    (:integer)
    \x23;\x23;bignum?)
  (defsystem-class-info
    :ratnum
    ratnum::t
    (:real)
    \x23;\x23;ratnum?)
  (defsystem-class-info :flonum flonum::t (:real) flonum?)
  (defsystem-class-info
    :cpxnum
    cpxnum::t
    (:number)
    \x23;\x23;cpxnum?)
  (defsystem-class-info :symbolic symbolic::t (:t) symbolic?)
  (defsystem-class-info :symbol symbol::t (:symbolic) symbol?)
  (defsystem-class-info
    :keyword
    keyword::t
    (:symbolic)
    keyword?)
  (defsystem-class-info :list list::t (:t) list?)
  (defsystem-class-info :pair pair::t (:list) pair?)
  (defsystem-class-info :null null::t (:list :atom) null?)
  (defsystem-class-info :sequence sequence::t (:t) sequence?)
  (defsystem-class-info :vector vector::t (:sequence) vector?)
  (defsystem-class-info :string string::t (:sequence) string?)
  (defsystem-class-info
    :hvector
    hvector::t
    (:sequence)
    hvector?)
  (defsystem-class-info
    :u8vector
    u8vector::t
    (:hvector)
    u8vector?)
  (defsystem-class-info
    :s8vector
    s8vector::t
    (:hvector)
    s8vector?)
  (defsystem-class-info
    :u16vector
    u16vector::t
    (:hvector)
    u16vector?)
  (defsystem-class-info
    :s16vector
    s16vector::t
    (:hvector)
    s16vector?)
  (defsystem-class-info
    :u32vector
    u32vector::t
    (:hvector)
    u32vector?)
  (defsystem-class-info
    :s32vector
    s32vector::t
    (:hvector)
    s32vector?)
  (defsystem-class-info
    :u64vector
    u64vector::t
    (:hvector)
    u64vector?)
  (defsystem-class-info
    :s64vector
    s64vector::t
    (:hvector)
    s64vector?)
  (defsystem-class-info
    :f32vector
    f32vector::t
    (:hvector)
    f32vector?)
  (defsystem-class-info
    :f64vector
    f64vector::t
    (:hvector)
    f64vector?)
  (defsystem-class-info
    :values
    values::t
    (:t)
    \x23;\x23;values?)
  (defsystem-class-info :box box::t (:t) box?)
  (defsystem-class-info :frame frame::t (:t) \x23;\x23;frame?)
  (defsystem-class-info
    :continuation
    continuation::t
    (:t)
    continuation?)
  (defsystem-class-info :promise promise::t (:t) promise?)
  (defsystem-class-info :weak weak::t (:t) weak?)
  (defsystem-class-info :foreign foreign::t (:t) foreign?)
  (defsystem-class-info
    :procedure
    procedure::t
    (:t)
    procedure?)
  (defsystem-class-info :time time::t (:t) time?)
  (defsystem-class-info :thread thread::t (:t) thread?)
  (defsystem-class-info
    :thread-group
    thread-group::t
    (:t)
    thread-group?)
  (defsystem-class-info :mutex mutex::t (:t) mutex?)
  (defsystem-class-info :condvar condvar::t (:t) condvar?)
  (defsystem-class-info :port port::t (:t) port?)
  (defsystem-class-info
    :object-port
    object-port::t
    (:port)
    object-port?)
  (defsystem-class-info
    :character-port
    character-port::t
    (:object-port)
    character-port?)
  (defsystem-class-info
    :byte-port
    byte-port::t
    (:character-port)
    byte-port?)
  (defsystem-class-info
    :device-port
    device-port::t
    (:byte-port)
    device-port?)
  (defsystem-class-info
    :vector-port
    vector-port::t
    (:object-port)
    vector-port?)
  (defsystem-class-info
    :string-port
    string-port::t
    (:character-port)
    string-port?)
  (defsystem-class-info
    :u8vector-port
    u8vector-port::t
    (:byte-port)
    u8vector-port?)
  (defsystem-class-info
    :raw-device-port
    raw-device-port::t
    (:port)
    raw-device-port?)
  (defsystem-class-info
    :tcp-server-port
    tcp-server-port::t
    (:object-port)
    tcp-server-port?)
  (defsystem-class-info
    :udp-port
    udp-port::t
    (:object-port)
    udp-port?)
  (defsystem-class-info
    :directory-port
    directory-port::t
    (:object-port)
    directory-port?)
  (defsystem-class-info
    :event-queue-port
    event-queue-port::t
    (:object-port)
    event-queue-port?)
  (defsystem-class-info :table table::t (:t) table?)
  (defsystem-class-info :readenv readenv::t (:t) readenv?)
  (defsystem-class-info :writeenv writeenv::t (:t) writeenv?)
  (defsystem-class-info
    :readtable
    readtable::t
    (:t)
    readtable?)
  (defsystem-class-info
    :processor
    processor::t
    (:t)
    processor?)
  (defsystem-class-info :vm vm::t (:t) vm?)
  (defsystem-class-info
    :file-info
    file-info::t
    (:t)
    file-info?)
  (defsystem-class-info
    :socket-info
    socket-info::t
    (:t)
    socket-info?)
  (defsystem-class-info
    :address-info
    address-info::t
    (:t)
    address-info?))

