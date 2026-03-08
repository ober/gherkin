(begin
  (begin
    (define interface-info::t
      (make-class-type 'gerbil\x23;interface-info::t 'interface-info
        (list object::t)
        '(name namespace interface-mixin interface-methods
           interface-precedence-list interface-descriptor instance-type
           instance-constructor instance-try-constructor
           instance-predicate instance-satisfies-predicate
           implementation-methods unchecked-implementation-methods)
        '() '#f))
    (define (interface-info . args)
      (apply make-interface-info args))
    (define (interface-info? obj)
      (\x23;\x23;structure-instance-of?
        obj
        'gerbil\x23;interface-info::t))
    (define (make-interface-info . args)
      (apply make-instance interface-info::t args))
    (define (&interface-info-name-set! obj val)
      (unchecked-slot-set! obj 'name val))
    (define (&interface-info-name obj)
      (unchecked-slot-ref obj 'name))
    (define (interface-info-name-set! obj val)
      (unchecked-slot-set! obj 'name val))
    (define (interface-info-name obj)
      (unchecked-slot-ref obj 'name))
    (define (&interface-info-namespace-set! obj val)
      (unchecked-slot-set! obj 'namespace val))
    (define (&interface-info-namespace obj)
      (unchecked-slot-ref obj 'namespace))
    (define (interface-info-namespace-set! obj val)
      (unchecked-slot-set! obj 'namespace val))
    (define (interface-info-namespace obj)
      (unchecked-slot-ref obj 'namespace))
    (define (&interface-info-interface-mixin-set! obj val)
      (unchecked-slot-set! obj 'interface-mixin val))
    (define (&interface-info-interface-mixin obj)
      (unchecked-slot-ref obj 'interface-mixin))
    (define (interface-info-interface-mixin-set! obj val)
      (unchecked-slot-set! obj 'interface-mixin val))
    (define (interface-info-interface-mixin obj)
      (unchecked-slot-ref obj 'interface-mixin))
    (define (&interface-info-interface-methods-set! obj val)
      (unchecked-slot-set! obj 'interface-methods val))
    (define (&interface-info-interface-methods obj)
      (unchecked-slot-ref obj 'interface-methods))
    (define (interface-info-interface-methods-set! obj val)
      (unchecked-slot-set! obj 'interface-methods val))
    (define (interface-info-interface-methods obj)
      (unchecked-slot-ref obj 'interface-methods))
    (define (&interface-info-interface-precedence-list-set! obj
             val)
      (unchecked-slot-set! obj 'interface-precedence-list val))
    (define (&interface-info-interface-precedence-list obj)
      (unchecked-slot-ref obj 'interface-precedence-list))
    (define (interface-info-interface-precedence-list-set! obj
             val)
      (unchecked-slot-set! obj 'interface-precedence-list val))
    (define (interface-info-interface-precedence-list obj)
      (unchecked-slot-ref obj 'interface-precedence-list))
    (define (&interface-info-interface-descriptor-set! obj val)
      (unchecked-slot-set! obj 'interface-descriptor val))
    (define (&interface-info-interface-descriptor obj)
      (unchecked-slot-ref obj 'interface-descriptor))
    (define (interface-info-interface-descriptor-set! obj val)
      (unchecked-slot-set! obj 'interface-descriptor val))
    (define (interface-info-interface-descriptor obj)
      (unchecked-slot-ref obj 'interface-descriptor))
    (define (&interface-info-instance-type-set! obj val)
      (unchecked-slot-set! obj 'instance-type val))
    (define (&interface-info-instance-type obj)
      (unchecked-slot-ref obj 'instance-type))
    (define (interface-info-instance-type-set! obj val)
      (unchecked-slot-set! obj 'instance-type val))
    (define (interface-info-instance-type obj)
      (unchecked-slot-ref obj 'instance-type))
    (define (&interface-info-instance-constructor-set! obj val)
      (unchecked-slot-set! obj 'instance-constructor val))
    (define (&interface-info-instance-constructor obj)
      (unchecked-slot-ref obj 'instance-constructor))
    (define (interface-info-instance-constructor-set! obj val)
      (unchecked-slot-set! obj 'instance-constructor val))
    (define (interface-info-instance-constructor obj)
      (unchecked-slot-ref obj 'instance-constructor))
    (define (&interface-info-instance-try-constructor-set! obj
             val)
      (unchecked-slot-set! obj 'instance-try-constructor val))
    (define (&interface-info-instance-try-constructor obj)
      (unchecked-slot-ref obj 'instance-try-constructor))
    (define (interface-info-instance-try-constructor-set! obj
             val)
      (unchecked-slot-set! obj 'instance-try-constructor val))
    (define (interface-info-instance-try-constructor obj)
      (unchecked-slot-ref obj 'instance-try-constructor))
    (define (&interface-info-instance-predicate-set! obj val)
      (unchecked-slot-set! obj 'instance-predicate val))
    (define (&interface-info-instance-predicate obj)
      (unchecked-slot-ref obj 'instance-predicate))
    (define (interface-info-instance-predicate-set! obj val)
      (unchecked-slot-set! obj 'instance-predicate val))
    (define (interface-info-instance-predicate obj)
      (unchecked-slot-ref obj 'instance-predicate))
    (define (&interface-info-instance-satisfies-predicate-set!
             obj val)
      (unchecked-slot-set! obj 'instance-satisfies-predicate val))
    (define (&interface-info-instance-satisfies-predicate obj)
      (unchecked-slot-ref obj 'instance-satisfies-predicate))
    (define (interface-info-instance-satisfies-predicate-set!
             obj val)
      (unchecked-slot-set! obj 'instance-satisfies-predicate val))
    (define (interface-info-instance-satisfies-predicate obj)
      (unchecked-slot-ref obj 'instance-satisfies-predicate))
    (define (&interface-info-implementation-methods-set! obj
             val)
      (unchecked-slot-set! obj 'implementation-methods val))
    (define (&interface-info-implementation-methods obj)
      (unchecked-slot-ref obj 'implementation-methods))
    (define (interface-info-implementation-methods-set! obj val)
      (unchecked-slot-set! obj 'implementation-methods val))
    (define (interface-info-implementation-methods obj)
      (unchecked-slot-ref obj 'implementation-methods))
    (define (&interface-info-unchecked-implementation-methods-set!
             obj val)
      (unchecked-slot-set!
        obj
        'unchecked-implementation-methods
        val))
    (define (&interface-info-unchecked-implementation-methods
             obj)
      (unchecked-slot-ref obj 'unchecked-implementation-methods))
    (define (interface-info-unchecked-implementation-methods-set!
             obj val)
      (unchecked-slot-set!
        obj
        'unchecked-implementation-methods
        val))
    (define (interface-info-unchecked-implementation-methods
             obj)
      (unchecked-slot-ref obj 'unchecked-implementation-methods)))
  (begin
    (define interface-info::apply-macro-expander
      (with-syntax ([cast (quote-syntax cast)]
                    [immediate-instance-of? (quote-syntax
                                              immediate-instance-of?)])
        (lambda (self stx)
          (syntax-case stx ()
            [(_ obj)
             (with-syntax ([klass (interface-info-instance-type self)]
                           [descriptor (interface-info-interface-descriptor
                                         self)]
                           [instance-type (interface-info-instance-type
                                            self)])
               #'(let ($obj obj)
                   (begin-annotation
                     (\x40;type instance-type)
                     (if (immediate-instance-of? klass $obj)
                         $obj
                         (cast descriptor $obj)))))]
            [_
             (identifier? stx)
             (with-syntax ([descriptor (interface-info-interface-descriptor
                                         self)])
               #'descriptor)]))))
    (bind-method!
      interface-info::t
      'apply-macro-expander
      interface-info::apply-macro-expander))
  (define (interface-identifier->precedence-list id)
    (cons
      id
      (interface-info-interface-precedence-list
        (syntax-local-value id))))
  (define (interface-mixin->precedence-list lst)
    (let ([values linearized] [c4-linearize (list)])
      linearized))
  (define (interface-info-method-signature info method)
    (let ([sig (find
                 (lambda (sig) (eq? method (car sig)))
                 (interface-info-interface-methods info))])
      (and sig (begin (cdr sig)))))
  (define syntax-local-interface-info?
    (case-lambda
      [(stx)
       (let* ([is? true])
         (and (identifier? stx)
              (let ([e (syntax-local-value stx false)])
                (and e (begin (and (interface-info? e) (is? e)))))))]
      [(stx is?)
       (and (identifier? stx)
            (let ([e (syntax-local-value stx false)])
              (and e (begin (and (interface-info? e) (is? e))))))])))

(begin
  (begin
    (begin
      (define type-reference::t
        (make-class-type 'gerbil\x23;type-reference::t
          'type-reference (list object::t) '(identifier) '() '#f))
      (define (type-reference . args)
        (apply make-type-reference args))
      (define (type-reference? obj)
        (\x23;\x23;structure-instance-of?
          obj
          'gerbil\x23;type-reference::t))
      (define (make-type-reference . args)
        (apply make-instance type-reference::t args))
      (define (&type-reference-identifier-set! obj val)
        (unchecked-slot-set! obj 'identifier val))
      (define (&type-reference-identifier obj)
        (unchecked-slot-ref obj 'identifier))
      (define (type-reference-identifier-set! obj val)
        (unchecked-slot-set! obj 'identifier val))
      (define (type-reference-identifier obj)
        (unchecked-slot-ref obj 'identifier)))
    (define (type-identifier? id)
      (and (identifier? id)
           (let ([t (syntax-local-value id false)])
             (and t
                  (begin
                    (or (class-type-info? t)
                        (interface-info? t)
                        (type-reference? t)))))))
    (define (resolve-type stx id)
      (let loop ([t (syntax-local-value id false)])
        (cond
          [(class-type-info? t) t]
          [(interface-info? t) t]
          [(type-reference? t)
           (loop
             (syntax-local-value (type-reference-identifier t) false))]
          [(not t) (raise-syntax-error #f "unresolved type" stx id)]
          [else
           (raise-syntax-error #f
             "unexpected type; expected class, interface or type reference"
             stx id t)])))
    (define (resolve-type->identifier stx id)
      (let loop ([id id] [t (syntax-local-value id false)])
        (cond
          [(class-type-info? t) id]
          [(interface-info? t) id]
          [(type-reference? t)
           (let ([id (type-reference-identifier t)])
             (loop id (syntax-local-value id false)))]
          [(not t) (raise-syntax-error #f "unresolved type" stx id)]
          [else
           (raise-syntax-error #f
             "unexpected type; expected class, interface or type reference"
             stx id t)])))
    (define (resolve-type->type-descriptor stx id)
      (let ([t (resolve-type stx id)])
        (cond
          [(class-type-info? t) (!class-type-descriptor t)]
          [(interface-info? t) (interface-info-instance-type t)]
          [else
           (raise-syntax-error #f
             "unexpected type; expected class, interface or type reference"
             stx id t)]))))
  (define-syntax deftype
    (syntax-rules ()
      [(_ reference-id type-id)
       (defsyntax
         reference-id
         (make-type-reference
           identifier:
           (quote-syntax type-id)))])))

(begin
  (define-syntax :
    (lambda (stx)
      (syntax-case stx ()
        [(_ expr type)
         (identifier? #'type)
         (let (meta [resolve-type stx #'type])
           (cond
             [(class-type-info? meta)
              (with-syntax ([klass (!class-type-descriptor meta)]
                            [predicate (!class-type-predicate meta)])
                (if (memq (!class-type-id meta) '(t void))
                    #'(begin-annotation (\x40;type klass) expr)
                    #'(begin-annotation
                        (\x40;type klass)
                        (let (val expr)
                          (if (predicate val)
                              val
                              (error "bad cast" klass val))))))]
             [(interface-info? meta)
              (with-syntax ([klass (interface-info-instance-type meta)]
                            [cast-it (resolve-type->identifier
                                       stx
                                       #'type)])
                #'(begin-annotation (\x40;type klass) (cast-it expr)))]
             [else
              (raise-syntax-error
                #f
                "not a class type or interface"
                stx
                #'type)]))])))
  (define-syntax :?
    (lambda (stx)
      (syntax-case stx ()
        [(_ expr type)
         (identifier? #'type)
         (let (meta [resolve-type stx #'type])
           (cond
             [(class-type-info? meta)
              (with-syntax ([klass (!class-type-descriptor meta)]
                            [predicate (!class-type-predicate meta)])
                (if (memq (!class-type-id meta) '(t void))
                    #'(begin-annotation (\x40;type klass) expr)
                    #'(begin-annotation
                        (\x40;type klass)
                        (let (val expr)
                          (if (or (not val) (predicate val))
                              val
                              (contract-violation!
                                "bad cast"
                                expr
                                predicate
                                val))))))]
             [(interface-info? meta)
              (with-syntax ([klass (interface-info-instance-type meta)]
                            [cast-it (resolve-type->identifier
                                       stx
                                       #'type)])
                #'(begin-annotation
                    (\x40;type klass)
                    (let (val expr) (and val (cast-it val)))))]
             [else
              (raise-syntax-error
                #f
                "not a class type or interface"
                stx
                #'type)]))])))
  (define-syntax :-
    (lambda (stx)
      (syntax-case stx ()
        [(_ expr type)
         (identifier? #'type)
         (with-syntax ([klass (resolve-type->type-descriptor
                                stx
                                #'type)])
           #'(begin-annotation (\x40;type klass) expr))])))
  (define-syntax :~
    (syntax-rules (:-)
      [(_ expr predicate)
       (let (val expr)
         (if (predicate val)
             val
             (contract-violation! expr predicate val)))]
      [(_ expr predicate :- type) (:- (:~ expr predicate) type)]))
  (define-syntax ::- (syntax-rules ()))
  (define-syntax := (syntax-rules ()))
  (define-syntax check-nil!
    (syntax-rules ()
      [(_ expr) (or expr (nil-dereference! expr))]))
  (define-syntax contract-violation!
    (lambda (stx)
      (syntax-case stx ()
        [(macro ctx contract-expr value)
         (with-syntax ([src-ctx (cond
                                  [(or (stx-source #'ctx)
                                       (stx-source stx)
                                       (stx-source #'macro)) =>
                                   (lambda (locat)
                                     (call-with-output-string
                                       ""
                                       (cut \x23;\x23;display-locat
                                            locat
                                            #t
                                            <>)))]
                                  [else
                                   (expander-context-id
                                     (core-context-top))])])
           #'(abort!
               (raise-contract-violation-error "contract violation" context: 'src-ctx contract:
                 'contract-expr value: value)))])))
  (define-syntax nil-dereference!
    (lambda (stx)
      (syntax-case stx ()
        [(macro expr)
         (with-syntax ([src-ctx (cond
                                  [(or (stx-source #'expr)
                                       (stx-source stx)
                                       (stx-source #'macro)) =>
                                   (lambda (locat)
                                     (call-with-output-string
                                       ""
                                       (cut \x23;\x23;display-locat
                                            locat
                                            #t
                                            <>)))]
                                  [else
                                   (expander-context-id
                                     (core-context-top))])])
           #'(abort!
               (raise-contract-violation-error "nil (#f) derefence" context: 'src-ctx contract:
                 '(check-nil! expr) value: #f)))])))
  (define-syntax abort!
    (syntax-rules ()
      [(abort! expr)
       (begin-annotation (\x40;abort) (begin expr (void)))])))

(begin
  (begin
    (define type-env::t
      (make-class-type 'gerbil\x23;type-env::t 'type-env (list object::t)
        '(var type checked? super) '((struct: . #t) (final: . #t))
        '#f))
    (define (make-type-env . args)
      (let* ([type type-env::t]
             [n (class-type-field-count type)]
             [obj (apply \x23;\x23;structure type (make-list n #f))])
        (let lp ([rest args] [i 1])
          (when (and (pair? rest) (<= i n))
            (\x23;\x23;structure-set! obj i (car rest))
            (lp (cdr rest) (+ i 1))))
        obj))
    (define (type-env? obj)
      (\x23;\x23;structure-instance-of?
        obj
        'gerbil\x23;type-env::t))
    (define (type-env-var obj) (unchecked-slot-ref obj 'var))
    (define (type-env-type obj) (unchecked-slot-ref obj 'type))
    (define (type-env-checked? obj)
      (unchecked-slot-ref obj 'checked?))
    (define (type-env-super obj)
      (unchecked-slot-ref obj 'super))
    (define (type-env-var-set! obj val)
      (unchecked-slot-set! obj 'var val))
    (define (type-env-type-set! obj val)
      (unchecked-slot-set! obj 'type val))
    (define (type-env-checked?-set! obj val)
      (unchecked-slot-set! obj 'checked? val))
    (define (type-env-super-set! obj val)
      (unchecked-slot-set! obj 'super val))
    (define (&type-env-var obj) (unchecked-slot-ref obj 'var))
    (define (&type-env-type obj) (unchecked-slot-ref obj 'type))
    (define (&type-env-checked? obj)
      (unchecked-slot-ref obj 'checked?))
    (define (&type-env-super obj)
      (unchecked-slot-ref obj 'super))
    (define (&type-env-var-set! obj val)
      (unchecked-slot-set! obj 'var val))
    (define (&type-env-type-set! obj val)
      (unchecked-slot-set! obj 'type val))
    (define (&type-env-checked?-set! obj val)
      (unchecked-slot-set! obj 'checked? val))
    (define (&type-env-super-set! obj val)
      (unchecked-slot-set! obj 'super val)))
  (define (current-type-env)
    (syntax-local-value
      (syntax-local-introduce '\x40;@type)
      false))
  (define (type-env-lookup var)
    (let loop ([te (current-type-env)])
      (cond
        [(not te) #f]
        [(free-identifier=? var (type-env-var te)) te]
        [else (loop (type-env-super te))]))))

(begin
  (define-syntax using
    (lambda (stx)
      (syntax-case stx (:~)
        [(_ (id expr ~ contract) body ...)
         (and (identifier? #'id)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':~)
                  (free-identifier=? #'~ #':?)))
         #'(let (id expr) (using (id ~ contract) body ...))]
        [(_ (id expr :~ contract ~ Type) body ...)
         (and (identifier? #'id)
              (identifier? #'Type)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         #'(let (id expr)
             (using (id :~ contract) (using (id ~ Type) body ...)))]
        [(_ (id ~ Type) body ...)
         (and (identifier? #'id)
              (identifier? #'Type)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (let (meta [resolve-type stx #'Type])
           (cond
             [(interface-info? meta)
              #'(with-interface (id ~ Type) body ...)]
             [(class-type-info? meta)
              #'(with-class (id ~ Type) body ...)]
             [else
              (raise-syntax-error #f
                "unexpected type; must be a class type or interface" stx
                #'Type meta)]))]
        [(_ (id :~ pred) body ...)
         (identifier? #'id)
         #'(with-contract (id :~ pred) body ...)]
        [(_ (id :~ pred ~ Type) body ...)
         (and (identifier? #'id)
              (identifier? #'Type)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         #'(using (id :~ pred) (using (id ~ Type) body ...))]
        [(_ ((hd . contract) . rest) body ...)
         (identifier? #'hd)
         #'(using (hd . contract) (using rest body ...))]
        [(_ () body ...) #'(let () body ...)])))
  (define-syntax with-contract
    (syntax-rules (:~)
      [(_ (id :~ predicate-expr) body ...)
       (if (predicate-expr id)
           (let () body ...)
           (contract-violation! id predicate-expr id))]))
  (begin
    (define (!class-slot-type klass slot)
      (cond
        [(!class-type-slot-types klass) =>
         (lambda (slot-types) (agetq slot slot-types))]
        [else #f]))
    (define (!class-slot-default klass slot)
      (cond
        [(!class-type-slot-defaults klass) =>
         (lambda (slot-defaults)
           (cond
             [(agetq slot slot-defaults) => syntax-local-introduce]
             [else #f]))]
        [else #f]))
    (define (!class-slot-contract klass slot)
      (cond
        [(!class-type-slot-defaults klass) =>
         (lambda (slot-defaults)
           (cond
             [(agetq slot slot-defaults) => syntax-local-introduce]
             [else #f]))]
        [else #f]))
    (define (!class-slot-checked-method-contract? klass slot)
      (let ([contract (!class-slot-contract klass slot)])
        (and contract
             (begin
               (syntax-case contract (:~ : :- ::- :?)
                 [(~ type)
                  (and (identifier? #'~)
                       (or (free-identifier=? #'~ #':)
                           (free-identifier=? #'~ #':-)
                           (free-identifier=? #'~ #'::-)
                           (free-identifier=? #'~ #':?)))
                  (not (free-identifier=? #'~ #':-))]
                 [(:~ pred-expr ~ type)
                  (and (identifier? #'~)
                       (or (free-identifier=? #'~ #':)
                           (free-identifier=? #'~ #':-)
                           (free-identifier=? #'~ #'::-)
                           (free-identifier=? #'~ #':?)))
                  (not (free-identifier=? #'~ #':-))]
                 [(:~ pred-expr) #f])))))
    (define (!class-slot-checked-mutator-contract? klass slot)
      (let ([contract (!class-slot-contract klass slot)])
        (and contract
             (begin
               (syntax-case contract (:~ : :- ::- :?)
                 [(~ type)
                  (and (identifier? #'~)
                       (or (free-identifier=? #'~ #':)
                           (free-identifier=? #'~ #':-)
                           (free-identifier=? #'~ #'::-)
                           (free-identifier=? #'~ #':?)))
                  (not (free-identifier=? #'~ #':-))]
                 [(:~ pred-expr ~ type)
                  (and (identifier? #'~)
                       (or (free-identifier=? #'~ #':)
                           (free-identifier=? #'~ #':-)
                           (free-identifier=? #'~ #'::-)
                           (free-identifier=? #'~ #':?)))
                  #t]
                 [(:~ pred-expr) #t])))))
    (define (dotted-identifier? id)
      (and (identifier? id)
           (let ([str (symbol->string (stx-e id))])
             (let ([index (string-index str #\.)])
               (and index
                    (begin
                      (and (fx> index 0)
                           (not (ormap
                                  string-empty?
                                  (let ([#{str dpuuv4a3mobea70icwo8nvdax-1763} str]
                                        [#{sep dpuuv4a3mobea70icwo8nvdax-1764} (if (char?
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
                                              #{str dpuuv4a3mobea70icwo8nvdax-1763}))
                                         (reverse
                                           (cons
                                             (substring
                                               #{str dpuuv4a3mobea70icwo8nvdax-1763}
                                               start
                                               i)
                                             acc))]
                                        [(char=?
                                           (string-ref
                                             #{str dpuuv4a3mobea70icwo8nvdax-1763}
                                             i)
                                           #{sep dpuuv4a3mobea70icwo8nvdax-1764})
                                         (split-lp
                                           (+ i 1)
                                           (+ i 1)
                                           (cons
                                             (substring
                                               #{str dpuuv4a3mobea70icwo8nvdax-1763}
                                               start
                                               i)
                                             acc))]
                                        [else
                                         (split-lp
                                           (+ i 1)
                                           start
                                           acc)]))))))))))))
    (define (split-dotted-identifier stx id)
      (let ([parts (let ([#{str dpuuv4a3mobea70icwo8nvdax-1765} (symbol->string
                                                                  (stx-e
                                                                    id))]
                         [#{sep dpuuv4a3mobea70icwo8nvdax-1766} (if (char?
                                                                      #\.)
                                                                    #\.
                                                                    (string-ref
                                                                      #\.
                                                                      0))])
                     (let split-lp ([i 0] [start 0] [acc '()])
                       (cond
                         [(= i
                             (string-length
                               #{str dpuuv4a3mobea70icwo8nvdax-1765}))
                          (reverse
                            (cons
                              (substring
                                #{str dpuuv4a3mobea70icwo8nvdax-1765}
                                start
                                i)
                              acc))]
                         [(char=?
                            (string-ref
                              #{str dpuuv4a3mobea70icwo8nvdax-1765}
                              i)
                            #{sep dpuuv4a3mobea70icwo8nvdax-1766})
                          (split-lp
                            (+ i 1)
                            (+ i 1)
                            (cons
                              (substring
                                #{str dpuuv4a3mobea70icwo8nvdax-1765}
                                start
                                i)
                              acc))]
                         [else (split-lp (+ i 1) start acc)])))])
        (if (find string-empty? parts)
            (raise-syntax-error #f "bad dotted identifier" stx id)
            (cons
              (stx-identifier id (car parts))
              (map string->symbol (cdr parts))))))
    (define (get-slot-accessor stx klass-or-id slot)
      (let* ([klass (if (identifier? klass-or-id)
                        (resolve-type stx klass-or-id)
                        klass-or-id)])
        (let* ([accessors (!class-type-unchecked-accessors klass)])
          (cond
            [(agetq slot accessors)]
            [else
             (raise-syntax-error #f "no accessor for slot" stx klass
               slot)]))))
    (define (get-slot-mutator stx klass-or-id slot checked?)
      (let* ([klass (if (identifier? klass-or-id)
                        (resolve-type stx klass-or-id)
                        klass-or-id)])
        (let* ([mutators (if checked?
                             (!class-type-mutators klass)
                             (!class-type-unchecked-mutators klass))])
          (cond
            [(agetq slot mutators)]
            [else
             (raise-syntax-error #f "no mutator for slot" stx klass
               slot)])))))
  (define-syntax with-class
    (lambda (stx)
      (define (expand-body klass var Type body checked?)
        (with-syntax ([\x40;@type (syntax-local-introduce
                                    '\x40;@type)]
                      [Type::t (!class-type-descriptor klass)]
                      [var var]
                      [klass klass]
                      [checked? checked?]
                      [cte (current-type-env)]
                      [(body ...) body])
          #'(let (var [begin-annotation (\x40;type Type::t) var])
              (let-syntax ([\x40;@type (make-type-env
                                         (quote-syntax var)
                                         'klass
                                         checked?
                                         'cte)])
                (let () body ...)))))
      (define (expand var Type body checked? checked-mutators?
               maybe?)
        (let* ([klass (syntax-local-value Type false)])
          (let* ([expr-body (expand-body klass var Type body
                              (or checked? checked-mutators?))])
            (if checked?
                (with-syntax ([predicate (let (instance?
                                               [!class-type-predicate klass])
                                           (if maybe?
                                               `(? (or not ,instance?))
                                               instance?))]
                              [var var]
                              [expr-body expr-body])
                  #'(with-contract (var :~ predicate) expr-body))
                expr-body))))
      (syntax-case stx (: :? :- ::-)
        [(_ (var ~ \x40;Type) body ...)
         (type-reference? (syntax-local-value #'\x40;Type false))
         (with-syntax ([Type (type-reference-identifier
                               (syntax-local-value #'\x40;Type))])
           #'(with-class (var ~ Type) body ...))]
        [(_ (var : Type) body ...)
         (syntax-local-class-type-info? #'Type)
         (expand #'var #'Type #'(body ...) #t #t #f)]
        [(_ (var :? Type) body ...)
         (syntax-local-class-type-info? #'Type)
         (expand #'var #'Type #'(body ...) #t #t #t)]
        [(_ (var :- Type) body ...)
         (syntax-local-class-type-info? #'Type)
         (expand #'var #'Type #'(body ...) #f #f #f)]
        [(_ (var ::- Type) body ...)
         (syntax-local-class-type-info? #'Type)
         (expand #'var #'Type #'(body ...) #f #t #f)])))
  (define-syntax with-interface
    (lambda (stx)
      (define (expand-body var Interface body checked?)
        (let ([type (resolve-type stx Interface)])
          (with-syntax ([\x40;@type (syntax-local-introduce
                                      '\x40;@type)]
                        [type type]
                        [Instance::t (interface-info-instance-type type)]
                        [var var]
                        [checked? checked?]
                        [cte (current-type-env)]
                        [(body ...) body])
            #'(let (var [begin-annotation (\x40;type Instance::t) var])
                (let-syntax ([\x40;@type (make-type-env
                                           (quote-syntax var)
                                           'type
                                           checked?
                                           'cte)])
                  (let () body ...))))))
      (define (expand var Interface body checked? checked-methods?
               maybe?)
        (with-syntax ([expr-body (expand-body
                                   var
                                   Interface
                                   body
                                   (or checked? checked-methods?))])
          (if checked?
              (if maybe?
                  (with-syntax ([var var] [Interface Interface])
                    #'(let (var [Interface var])
                        (if var expr-body (nil-dereference! var))))
                  (with-syntax ([var var] [Interface Interface])
                    #'(let (var [Interface var]) expr-body)))
              (if maybe?
                  (with-syntax ([var var])
                    #'(if var expr-body (nil-dereference! var)))
                  #'expr-body))))
      (syntax-case stx (: :? :- ::-)
        [(_ (var ~ \x40;Type) body ...)
         (type-reference? (syntax-local-value #'\x40;Type false))
         (with-syntax ([Type (type-reference-identifier
                               (syntax-local-value #'\x40;Type))])
           #'(with-interface (var ~ Type) body ...))]
        [(_ (var : Interface) body ...)
         (and (identifier? #'var)
              (syntax-local-interface-info? #'Interface))
         (expand #'var #'Interface #'(body ...) #t #t #f)]
        [(_ (var :? Interface) body ...)
         (and (identifier? #'var)
              (syntax-local-interface-info? #'Interface))
         (expand #'var #'Interface #'(body ...) #t #t #t)]
        [(_ (var :- Interface) body ...)
         (and (identifier? #'var)
              (syntax-local-interface-info? #'Interface))
         (expand #'var #'Interface #'(body ...) #f #f #f)]
        [(_ (var ::- Interface) body ...)
         (and (identifier? #'var)
              (syntax-local-interface-info? #'Interface))
         (expand #'var #'Interface #'(body ...) #f #t #f)])))
  (define-syntax %%app-dotted
    (lambda (stx)
      (syntax-case stx (%%ref-dotted)
        [(_ id rand ...)
         (identifier? #'id)
         #'(%%app-dotted (%%ref-dotted id) rand ...)]
        [(_ (%%ref-dotted id) rand ...)
         (if (dotted-identifier? #'id)
             (with ([\x40;list var . parts]
                    [split-dotted-identifier stx #'id])
               (cond
                 [(type-env-lookup var) =>
                  (lambda (te)
                    (let loop ([parts parts]
                               [type (type-env-type te)]
                               [object var]
                               [checked-method? (type-env-checked? te)]
                               [nil-check? #f])
                      (match parts
                        [(\x40;list part . rest)
                         (cond
                           [(and (not nil-check?)
                                 (string-prefix?
                                   "?"
                                   (symbol->string part)))
                            (let (str [symbol->string part])
                              (loop
                                (cons
                                  (string->symbol
                                    (substring str 1 (string-length str)))
                                  rest)
                                type object checked-method? #t))]
                           [(class-type-info? type)
                            (with-syntax ([object (if nil-check?
                                                      (\x40;list
                                                        'check-nil!
                                                        object)
                                                      object)]
                                          [accessor (get-slot-accessor
                                                      stx
                                                      type
                                                      part)])
                              (cond
                                [(null? rest)
                                 #'(%%app (accessor object) rand ...)]
                                [(!class-slot-type type part) =>
                                 (lambda (slot-type)
                                   (let (slot-type
                                         [resolve-type stx slot-type])
                                     (loop rest slot-type #'(accessor object)
                                       (!class-slot-checked-method-contract?
                                         type
                                         part)
                                       #f)))]
                                [else
                                 (raise-syntax-error #f
                                   "unresolved dotted reference; unknown type for slot"
                                   stx #'id part)]))]
                           [(interface-info? type)
                            (if (null? rest)
                                (with-syntax ([object (if nil-check?
                                                          (\x40;list
                                                            'check-nil!
                                                            object)
                                                          object)]
                                              [method (stx-identifier #'id
                                                        (if checked-method?
                                                            ""
                                                            "&")
                                                        (interface-info-name
                                                          type)
                                                        "-" part)])
                                  #'(method object rand ...))
                                (raise-syntax-error #f
                                  "illegal dotted reference; interface has no slots"
                                  stx #'id part))]
                           [else
                            (raise-syntax-error
                              #f
                              "unexpected type"
                              stx
                              type)])]
                        [else
                         (with-syntax ([rator object])
                           #'(%%app rator rand ...))])))]
                 [else #'(%%app id rand ...)]))
             #'(%%app id rand ...))]
        [(_ arg ...) #'(%%app arg ...)])))
  (define-syntax %%ref-dotted
    (lambda (stx)
      (syntax-case stx ()
        [(_ id)
         (dotted-identifier? #'id)
         (with ([\x40;list var . parts]
                [split-dotted-identifier stx #'id])
           (cond
             [(type-env-lookup var) =>
              (lambda (te)
                (let loop ([parts parts]
                           [type (type-env-type te)]
                           [object var]
                           [nil-check? #f])
                  (match parts
                    [(\x40;list part . rest)
                     (cond
                       [(and (not nil-check?)
                             (string-prefix? "?" (symbol->string part)))
                        (let (str [symbol->string part])
                          (loop
                            (cons
                              (string->symbol
                                (substring str 1 (string-length str)))
                              rest)
                            type
                            object
                            #t))]
                       [(class-type-info? type)
                        (with-syntax ([object (if nil-check?
                                                  `(check-nil! ,object)
                                                  object)]
                                      [accessor (get-slot-accessor
                                                  stx
                                                  type
                                                  part)])
                          (cond
                            [(null? rest)
                             (cond
                               [(!class-slot-type type part) =>
                                (lambda (slot-type)
                                  (with-syntax ([slot-type (resolve-type->type-descriptor
                                                             stx
                                                             slot-type)])
                                    #'(begin-annotation
                                        (\x40;type slot-type)
                                        (accessor object))))]
                               [nil-check?
                                #'(accessor (check-nil! object))]
                               [else #'(accessor object)])]
                            [(!class-slot-type type part) =>
                             (lambda (type)
                               (let (type [resolve-type stx type])
                                 (if nil-check?
                                     (loop
                                       rest
                                       type
                                       #'(accessor (check-nil! object))
                                       #f)
                                     (loop
                                       rest
                                       type
                                       #'(accessor object)
                                       #f))))]
                            [else
                             (raise-syntax-error #f
                               "unresolved dotted reference; unknown type for slot"
                               stx #'id part)]))]
                       [(interface-info? type)
                        (raise-syntax-error
                          #f
                          "illegal dotted reference; interface has no slots")]
                       [else
                        (raise-syntax-error
                          #f
                          "unexpected type"
                          stx
                          type)])]
                    [else object])))]
             [else #'(%%ref id)]))]
        [(_ id) #'(%%ref id)])))
  (define-syntax %%set-dotted!
    (lambda (stx)
      (syntax-case stx ()
        [(_ id value)
         (dotted-identifier? #'id)
         (with ([\x40;list var . parts]
                [split-dotted-identifier stx #'id])
           (cond
             [(type-env-lookup var) =>
              (lambda (te)
                (let loop ([parts parts]
                           [type (type-env-type te)]
                           [object var]
                           [checked-mutator? (type-env-checked? te)]
                           [nil-check? #f])
                  (match parts
                    [(\x40;list part . rest)
                     (cond
                       [(and (not nil-check?)
                             (string-prefix? "?" (symbol->string part)))
                        (let (str [symbol->string part])
                          (loop
                            (cons
                              (string->symbol
                                (substring str 1 (string-length str)))
                              rest)
                            type object checked-mutator? #t))]
                       [(class-type-info? type)
                        (cond
                          [(null? rest)
                           (with-syntax ([object object]
                                         [mutator (get-slot-mutator
                                                    stx
                                                    type
                                                    part
                                                    (and checked-mutator?
                                                         (!class-slot-contract
                                                           type
                                                           part)))])
                             (if nil-check?
                                 #'(mutator (check-nil! object) value)
                                 #'(mutator object value)))]
                          [(!class-slot-type type part) =>
                           (lambda (type)
                             (let (type [resolve-type stx type])
                               (with-syntax ([object (if nil-check?
                                                         `(check-nil!
                                                            ,object)
                                                         object)]
                                             [accessor (get-slot-accessor
                                                         stx
                                                         type
                                                         part)])
                                 (loop rest type #'(accessor object)
                                   (!class-slot-checked-mutator-contract?
                                     type
                                     part)
                                   #f))))]
                          [else
                           (raise-syntax-error #f
                             "unresolved dotted reference; unknown type for slot"
                             stx #'id part)])]
                       [(interface-info? type)
                        (raise-syntax-error
                          #f
                          "illegal dotted reference; interface has no slots")]
                       [else
                        (raise-syntax-error
                          #f
                          "unexpected type"
                          stx
                          type)])])))]
             [else (expand-set! stx)]))]
        [(_ target value) (expand-set! stx)]))))

(begin
  (define-syntax maybe
    (syntax-rules () [(maybe pred) (? (or not pred))]))
  (define-syntax in-range?
    (syntax-rules ()
      [(in-range? start end)
       (lambda (o) (and (fixnum? o) (fx>= o start) (fx< o end)))]))
  (define-syntax in-range-inclusive?
    (syntax-rules ()
      [(in-range-inclusive? start end)
       (lambda (o) (and (fixnum? o) (fx<= start o end)))]))
  (define-syntax list-of?
    (syntax-rules ()
      [(list-of? pred)
       (lambda (o) (and (list? o) (andmap pred o)))])))

(begin
  (define (!class-precedence-list klass)
    (cond
      [(!class-type-precedence-list klass)]
      [else
       (call-with-values
         (lambda ()
           (c4-linearize (list) (!class-type-super klass)
             (lambda (klass-id)
               (cons
                 klass-id
                 (!class-precedence-list (syntax-local-value klass-id))))
             (lambda (klass-id)
               (!class-type-struct? (syntax-local-value klass-id)))
             free-identifier=?))
         (lambda (precedence-list base-struct)
           (let* ([precedence-list (cond
                                     [(memq
                                        (!class-type-id klass)
                                        '(t object class))
                                      precedence-list]
                                     [(memp
                                        (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1767})
                                          (free-identifier=?
                                            ':object
                                            #{e dpuuv4a3mobea70icwo8nvdax-1767}))
                                        precedence-list)
                                      precedence-list]
                                     [(!class-type-system? klass)
                                      (if (memp
                                            (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1768})
                                              (free-identifier=?
                                                ':t
                                                #{e dpuuv4a3mobea70icwo8nvdax-1768}))
                                            precedence-list)
                                          precedence-list
                                          (append
                                            precedence-list
                                            (list
                                              (core-quote-syntax ':t))))]
                                     [else
                                      (let loop ([tail precedence-list]
                                                 [head (list)])
                                        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1769} tail])
                                          (if (pair?
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-1769})
                                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1770} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1769})]
                                                    [#{tl dpuuv4a3mobea70icwo8nvdax-1771} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1769})])
                                                (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1770}])
                                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1771}])
                                                    (begin
                                                      (if (free-identifier=?
                                                            hd
                                                            ':t)
                                                          (let ([#{f dpuuv4a3mobea70icwo8nvdax-1772} cons])
                                                            (fold-left
                                                              (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1773}
                                                                       #{e dpuuv4a3mobea70icwo8nvdax-1774})
                                                                (#{f dpuuv4a3mobea70icwo8nvdax-1772}
                                                                  #{e dpuuv4a3mobea70icwo8nvdax-1774}
                                                                  #{a dpuuv4a3mobea70icwo8nvdax-1773}))
                                                              (cons
                                                                (core-quote-syntax
                                                                  ':object)
                                                                tail)
                                                              head))
                                                          (loop
                                                            rest
                                                            (cons
                                                              hd
                                                              head)))))))
                                              (begin
                                                (let ([#{f dpuuv4a3mobea70icwo8nvdax-1775} cons])
                                                  (fold-left
                                                    (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1776}
                                                             #{e dpuuv4a3mobea70icwo8nvdax-1777})
                                                      (#{f dpuuv4a3mobea70icwo8nvdax-1775}
                                                        #{e dpuuv4a3mobea70icwo8nvdax-1777}
                                                        #{a dpuuv4a3mobea70icwo8nvdax-1776}))
                                                    (list
                                                      (core-quote-syntax
                                                        ':object)
                                                      (core-quote-syntax
                                                        ':t))
                                                    head))))))])])
             (!class-type-precedence-list-set! klass precedence-list)
             precedence-list)))])))

(begin
  (begin
    (define check-signature!
      (case-lambda
        [(stx args return)
         (let* ([optionals-allowed? #t] [keywords-allowed? #t])
           (when (stx-e return) (check-valid-type! stx return))
           (check-signature-spec!
             stx
             args
             optionals-allowed?
             keywords-allowed?))]
        [(stx args return optionals-allowed?)
         (let* ([keywords-allowed? #t])
           (when (stx-e return) (check-valid-type! stx return))
           (check-signature-spec!
             stx
             args
             optionals-allowed?
             keywords-allowed?))]
        [(stx args return optionals-allowed? keywords-allowed?)
         (when (stx-e return) (check-valid-type! stx return))
         (check-signature-spec!
           stx
           args
           optionals-allowed?
           keywords-allowed?)]))
    (define (check-valid-type! stx id)
      (let ([info (syntax-local-value id false)])
        (cond
          [(or (class-type-info? info)
               (interface-info? info)
               (type-reference? info))]
          [(not info)
           (raise-syntax-error
             #f
             "invalid signature; unknown type"
             stx
             id)]
          [else
           (raise-syntax-error #f
             "invalid signature; not a a class type or interface" stx id
             info)])))
    (define check-signature-spec!
      (case-lambda
        [(stx signature)
         (let* ([optionals-allowed? #t] [keywords-allowed? #t])
           (let lp ([rest signature]
                    [have-optional? #f]
                    [ids (list)]
                    [kws (list)])
             (syntax-case rest ()
               [(id . rest)
                (identifier? #'id)
                (cond
                  [have-optional?
                   (raise-syntax-error #f
                     "invalid signature; required argument after optionals"
                     stx signature #'id)]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else (lp #'rest have-optional? (cons #'id ids) kws)])]
               [((id _) . rest)
                (identifier? #'id)
                (cond
                  [(not optionals-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; optionals not allowed"
                     stx
                     signature)]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else (lp #'rest #t (cons #'id ids) kws)])]
               [((id . contract) . rest)
                (and (identifier? #'id) (signature-contract? #'contract))
                (cond
                  [(not optionals-allowed?)
                   (syntax-case #'contract (:=)
                     [(_ ... := default)
                      (raise-syntax-error
                        #f
                        "invalid signature; optionals not allowed"
                        stx
                        signature)]
                     [_ (void)])]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [have-optional?
                   (syntax-case #'contract (:=)
                     [(_ ... := default)
                      (begin
                        (check-signature-contract-types! stx #'contract)
                        (lp #'rest #t (cons #'id ids) kws))]
                     [_
                      (raise-syntax-error #f "invalid signature; expected optional argument"
                        stx signature #'contract)])]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else
                   (check-signature-contract-types! stx #'contract)
                   (lp #'rest have-optional? (cons #'id ids) kws)])]
               [(kw id . rest)
                (and (stx-keyword? #'kw) (identifier? #'id))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [(kw (id _) . rest)
                (and (stx-keyword? #'kw) (identifier? #'id))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [(kw (id . contract) . rest)
                (and (stx-keyword? #'kw)
                     (identifier? #'id)
                     (signature-contract? #'contract))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (check-signature-contract-types! stx #'contract)
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [id (identifier? #'id) #t]
               [() #t]
               [_
                (raise-syntax-error #f "invalid signature" stx signature
                  rest)])))]
        [(stx signature optionals-allowed?)
         (let* ([keywords-allowed? #t])
           (let lp ([rest signature]
                    [have-optional? #f]
                    [ids (list)]
                    [kws (list)])
             (syntax-case rest ()
               [(id . rest)
                (identifier? #'id)
                (cond
                  [have-optional?
                   (raise-syntax-error #f
                     "invalid signature; required argument after optionals"
                     stx signature #'id)]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else (lp #'rest have-optional? (cons #'id ids) kws)])]
               [((id _) . rest)
                (identifier? #'id)
                (cond
                  [(not optionals-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; optionals not allowed"
                     stx
                     signature)]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else (lp #'rest #t (cons #'id ids) kws)])]
               [((id . contract) . rest)
                (and (identifier? #'id) (signature-contract? #'contract))
                (cond
                  [(not optionals-allowed?)
                   (syntax-case #'contract (:=)
                     [(_ ... := default)
                      (raise-syntax-error
                        #f
                        "invalid signature; optionals not allowed"
                        stx
                        signature)]
                     [_ (void)])]
                  [(not (null? kws))
                   (raise-syntax-error
                     #f
                     "invalid signature; positional arguments must precede keyword arguments")]
                  [have-optional?
                   (syntax-case #'contract (:=)
                     [(_ ... := default)
                      (begin
                        (check-signature-contract-types! stx #'contract)
                        (lp #'rest #t (cons #'id ids) kws))]
                     [_
                      (raise-syntax-error #f "invalid signature; expected optional argument"
                        stx signature #'contract)])]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [else
                   (check-signature-contract-types! stx #'contract)
                   (lp #'rest have-optional? (cons #'id ids) kws)])]
               [(kw id . rest)
                (and (stx-keyword? #'kw) (identifier? #'id))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [(kw (id _) . rest)
                (and (stx-keyword? #'kw) (identifier? #'id))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [(kw (id . contract) . rest)
                (and (stx-keyword? #'kw)
                     (identifier? #'id)
                     (signature-contract? #'contract))
                (cond
                  [(not keywords-allowed?)
                   (raise-syntax-error
                     #f
                     "invalid signature; keywords not allowed"
                     stx
                     signature)]
                  [(find (cut bound-identifier=? <> #'id) ids)
                   (raise-syntax-error #f
                     "invalid signature; duplicate identifier" stx
                     signature #'id)]
                  [(memq (stx-e #'kw) kws)
                   (raise-syntax-error #f
                     "invalid signature; duplicate keyword" stx signature
                     #'kw)]
                  [else
                   (check-signature-contract-types! stx #'contract)
                   (lp #'rest
                       have-optional?
                       (cons #'id ids)
                       (cons (stx-e #'kw) kws))])]
               [id (identifier? #'id) #t]
               [() #t]
               [_
                (raise-syntax-error #f "invalid signature" stx signature
                  rest)])))]
        [(stx signature optionals-allowed? keywords-allowed?)
         (let lp ([rest signature]
                  [have-optional? #f]
                  [ids (list)]
                  [kws (list)])
           (syntax-case rest ()
             [(id . rest)
              (identifier? #'id)
              (cond
                [have-optional?
                 (raise-syntax-error #f
                   "invalid signature; required argument after optionals"
                   stx signature #'id)]
                [(not (null? kws))
                 (raise-syntax-error
                   #f
                   "invalid signature; positional arguments must precede keyword arguments")]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [else (lp #'rest have-optional? (cons #'id ids) kws)])]
             [((id _) . rest)
              (identifier? #'id)
              (cond
                [(not optionals-allowed?)
                 (raise-syntax-error
                   #f
                   "invalid signature; optionals not allowed"
                   stx
                   signature)]
                [(not (null? kws))
                 (raise-syntax-error
                   #f
                   "invalid signature; positional arguments must precede keyword arguments")]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [else (lp #'rest #t (cons #'id ids) kws)])]
             [((id . contract) . rest)
              (and (identifier? #'id) (signature-contract? #'contract))
              (cond
                [(not optionals-allowed?)
                 (syntax-case #'contract (:=)
                   [(_ ... := default)
                    (raise-syntax-error
                      #f
                      "invalid signature; optionals not allowed"
                      stx
                      signature)]
                   [_ (void)])]
                [(not (null? kws))
                 (raise-syntax-error
                   #f
                   "invalid signature; positional arguments must precede keyword arguments")]
                [have-optional?
                 (syntax-case #'contract (:=)
                   [(_ ... := default)
                    (begin
                      (check-signature-contract-types! stx #'contract)
                      (lp #'rest #t (cons #'id ids) kws))]
                   [_
                    (raise-syntax-error #f
                      "invalid signature; expected optional argument" stx
                      signature #'contract)])]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [else
                 (check-signature-contract-types! stx #'contract)
                 (lp #'rest have-optional? (cons #'id ids) kws)])]
             [(kw id . rest)
              (and (stx-keyword? #'kw) (identifier? #'id))
              (cond
                [(not keywords-allowed?)
                 (raise-syntax-error
                   #f
                   "invalid signature; keywords not allowed"
                   stx
                   signature)]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [(memq (stx-e #'kw) kws)
                 (raise-syntax-error #f
                   "invalid signature; duplicate keyword" stx signature
                   #'kw)]
                [else
                 (lp #'rest
                     have-optional?
                     (cons #'id ids)
                     (cons (stx-e #'kw) kws))])]
             [(kw (id _) . rest)
              (and (stx-keyword? #'kw) (identifier? #'id))
              (cond
                [(not keywords-allowed?)
                 (raise-syntax-error
                   #f
                   "invalid signature; keywords not allowed"
                   stx
                   signature)]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [(memq (stx-e #'kw) kws)
                 (raise-syntax-error #f
                   "invalid signature; duplicate keyword" stx signature
                   #'kw)]
                [else
                 (lp #'rest
                     have-optional?
                     (cons #'id ids)
                     (cons (stx-e #'kw) kws))])]
             [(kw (id . contract) . rest)
              (and (stx-keyword? #'kw)
                   (identifier? #'id)
                   (signature-contract? #'contract))
              (cond
                [(not keywords-allowed?)
                 (raise-syntax-error
                   #f
                   "invalid signature; keywords not allowed"
                   stx
                   signature)]
                [(find (cut bound-identifier=? <> #'id) ids)
                 (raise-syntax-error #f
                   "invalid signature; duplicate identifier" stx signature
                   #'id)]
                [(memq (stx-e #'kw) kws)
                 (raise-syntax-error #f
                   "invalid signature; duplicate keyword" stx signature
                   #'kw)]
                [else
                 (check-signature-contract-types! stx #'contract)
                 (lp #'rest
                     have-optional?
                     (cons #'id ids)
                     (cons (stx-e #'kw) kws))])]
             [id (identifier? #'id) #t]
             [() #t]
             [_
              (raise-syntax-error #f "invalid signature" stx signature
                rest)]))]))
    (define (signature-contract? contract)
      (syntax-case contract (:~ :=)
        [(~ type)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (identifier? #'type)]
        [(~ type := default)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (identifier? #'type)]
        [(:~ predicate-expr) #t]
        [(:~ predicate-expr := default) #t]
        [(:~ predicate-expr ~ type)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (identifier? #'type)]
        [(:~ predicate-expr ~ type := default)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (identifier? #'type)]
        [_ #f]))
    (define (check-signature-contract-types! stx contract)
      (syntax-case contract (:~)
        [(~ type . maybe-default)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (check-valid-type! stx #'type)]
        [(:~ predicate-expr ~ type . maybe-default)
         (and (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':-)
                  (free-identifier=? #'~ #'::-)
                  (free-identifier=? #'~ #':?)))
         (check-valid-type! stx #'type)]
        [_ (void)]))
    (define (signature-arguments-in signature)
      (let loop ([rest signature] [result (list)])
        (syntax-case rest ()
          [(id . rest)
           (identifier? #'id)
           (loop #'rest (cons #'id result))]
          [((id default) . rest)
           (identifier? #'id)
           (loop #'rest (cons #'(id default) result))]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           (syntax-case #'contract (:=)
             [(_ ... := default)
              (loop #'rest (cons #'(id default) result))]
             [_ (loop #'rest (cons #'id result))])]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest (cons* #'id #'kw result))]
          [(kw (id default) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest (cons* #'(id default) #'kw result))]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           (syntax-case #'contract (:=)
             [(_ ... := default)
              (loop #'rest (cons* #'(id default) #'kw result))]
             [_ (loop #'rest (cons* #'id #'kw result))])]
          [id (identifier? #'id) (foldl cons #'id result)]
          [_ (reverse! result)])))
    (define (signature-arguments-out signature)
      (let loop ([rest signature] [result (list)])
        (syntax-case rest ()
          [(id . rest)
           (identifier? #'id)
           (loop #'rest (cons #'id result))]
          [((id _) . rest)
           (identifier? #'id)
           (loop #'rest (cons #'id result))]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           (loop #'rest (cons #'id result))]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest (cons* #'id #'kw result))]
          [(kw (id default) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest (cons* #'id #'kw result))]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           (loop #'rest (cons* #'id #'kw result))]
          [id (identifier? #'id) (foldl cons (\x40;list #'id) result)]
          [_ (reverse! result)])))
    (define (signature-has-keywords? signature)
      (let loop ([rest signature])
        (syntax-case rest ()
          [(id . rest) (identifier? #'id) (loop #'rest)]
          [((id default) . rest) (identifier? #'id) (loop #'rest)]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           (loop #'rest)]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           #t]
          [(kw (id default) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           #t]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           #t]
          [_ #f])))
    (define (make-interface-method-lambda-signature stx self
             Interface signature return unchecked-proc)
      (if (stx-e unchecked-proc)
          (make-procedure-lambda-signature
            stx
            (cons (list self ': Interface) signature)
            return
            unchecked-proc)
          (let ([return-type (resolve-type->type-descriptor
                               stx
                               return)])
            (list 'return: return-type))))
    (define (make-interface-method-contract stx self Interface
             signature checked?)
      (make-procedure-contract
        stx
        (cons (list self (if checked? ': '::-) Interface) signature)
        checked?))
    (define (make-procedure-lambda-signature stx signature
             return unchecked)
      (define (type-e contract)
        (syntax-case contract (: :? :~ :- ::- :=)
          [(: type . maybe-default)
           (resolve-type->type-descriptor stx #'type)]
          [(~ type . maybe-default)
           (and (identifier? #'~)
                (or (free-identifier=? #'~ #':-)
                    (free-identifier=? #'~ #'::-)))
           (core-quote-syntax 't::t)]
          [(:~ pred-expr : type . maybe-default)
           (resolve-type->type-descriptor stx #'type)]
          [(:~ pred-expr ~ type . maybe-default)
           (and (identifier? #'~)
                (or (free-identifier=? #'~ #':-)
                    (free-identifier=? #'~ #'::-)))
           (core-quote-syntax 't::t)]
          [_ #f]))
      (let loop ([rest signature]
                 [has-keywords? #f]
                 [result (list)])
        (syntax-case rest ()
          [(id . rest)
           (identifier? #'id)
           (loop #'rest #f (cons (core-quote-syntax 't::t) result))]
          [((id _) . rest)
           (identifier? #'id)
           (loop #'rest #f (cons (core-quote-syntax 't::t) result))]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           (loop #'rest #f (cons (type-e #'contract) result))]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest #t (cons (core-quote-syntax 't::t) result))]
          [(kw (id _) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest #t (cons (core-quote-syntax 't::t) result))]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           (loop #'rest #t (cons (type-e #'contract) result))]
          [id
           (identifier? #'id)
           (let* ([arguments (if has-keywords?
                                 (core-quote-syntax 't::t)
                                 (foldl
                                   cons
                                   (core-quote-syntax 't::t)
                                   result))]
                  [return-type (resolve-type->type-descriptor stx return)]
                  [unchecked (and (not has-keywords?)
                                  (stx-e unchecked)
                                  (core-quote-syntax unchecked))])
             (\x40;list arguments: arguments return: return-type
               unchecked: unchecked))]
          [()
           (let* ([arguments (if has-keywords?
                                 (core-quote-syntax 't::t)
                                 (reverse! result))]
                  [return-type (resolve-type->type-descriptor stx return)]
                  [unchecked (and (not has-keywords?)
                                  (stx-e unchecked)
                                  (core-quote-syntax unchecked))])
             (\x40;list arguments: arguments return: return-type
               unchecked: unchecked))])))
    (define (make-procedure-contract stx signature checked?)
      (define (contract-e id contract)
        (with-syntax ([id id])
          (syntax-case contract (: :? :~ :- ::- :=)
            [(~ type . maybe-default)
             (or (free-identifier=? #'~ #'::-)
                 (free-identifier=? #'~ #':)
                 (free-identifier=? #'~ #':?))
             (if checked? #'(id ~ type) #'(id ::- type))]
            [(:- type . maybe-default) #'(id :- type)]
            [(:~ predicate-expr ~ type . maybe-default)
             (or (free-identifier=? #'~ #'::-)
                 (free-identifier=? #'~ #':)
                 (free-identifier=? #'~ #':?))
             (if checked?
                 #'(id :~ predicate-expr ~ type)
                 #'(id ::- type))]
            [(:~ predicate-expr ~ type . maybe-default)
             (or (free-identifier=? #'~ #'::-)
                 (free-identifier=? #'~ #':)
                 (free-identifier=? #'~ #':?))
             (if checked?
                 #'(id :~ predicate-expr ~ type)
                 #'(id ::- type))]
            [(:~ predicate-expr :- type . maybe-default)
             (if checked?
                 #'(id :~ predicate-expr :- type)
                 #'(id :- type))]
            [(:~ predicate-expr . maybe-default)
             (if checked? #'(id :~ predicate-expr) #'(id :- :t))])))
      (let loop ([rest signature] [result (list)])
        (syntax-case rest ()
          [(id . rest) (identifier? #'id) (loop #'rest result)]
          [((id _) . rest) (identifier? #'id) (loop #'rest result)]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           (loop #'rest (cons (contract-e #'id #'contract) result))]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest result)]
          [(kw (id _) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop #'rest result)]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           (loop #'rest (cons (contract-e #'id #'contract) result))]
          [_ (reverse! (filter identity result))])))
    (define (compatible-signatures? left right)
      (let ([left (syntax->list left)]
            [right (syntax->list right)])
        (let ([left-args (cadr left)]
              [left-return (caddr left)]
              [right-args (cadr right)]
              [right-return (caddr right)])
          (call/cc
            (lambda (return)
              (let ([left-arity (signature-arity left-args)]
                    [right-arity (signature-arity right-args)])
                (unless (equal? left-arity right-arity) (return #f)))
              (let ([left-kws (signature-keywords left-args)]
                    [right-kws (signature-keywords right-args)])
                (unless (equal? left-kws right-kws) (return #f)))
              (call-with-values
                (lambda () (signature-type-contract left-args))
                (lambda (left-positional-contract left-kw-contract)
                  (call-with-values
                    (lambda () (signature-type-contract right-args))
                    (lambda (right-positional-contract right-kw-contract)
                      (begin
                        (let ([left-contract (append
                                               left-positional-contract
                                               (fold-right
                                                 (lambda (kwc r)
                                                   (cons (cdr kwc) r))
                                                 (list)
                                                 left-kw-contract))]
                              [right-contract (append
                                                right-positional-contract
                                                (fold-right
                                                  (lambda (kwc r)
                                                    (cons (cdr kwc) r))
                                                  (list)
                                                  right-kw-contract))])
                          (unless (compatible-signature-type-contract?
                                    left-contract
                                    right-contract)
                            (return #f))))))))
              (unless (free-identifier=?
                        (resolve-type->identifier left left-return)
                        (resolve-type->identifier right right-return))
                (return #f))
              #t)))))
    (define (compatible-signature-type-contract? left right)
      (let loop ([left-rest left] [right-rest right])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1778} left-rest])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1778})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1779} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1778})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-1780} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1778})])
                (let ([left #{hd dpuuv4a3mobea70icwo8nvdax-1779}])
                  (let ([left-rest #{tl dpuuv4a3mobea70icwo8nvdax-1780}])
                    (begin
                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1781} right-rest])
                        (if (pair?
                              #{match-val dpuuv4a3mobea70icwo8nvdax-1781})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1782} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1781})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1783} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1781})])
                              (let ([right #{hd dpuuv4a3mobea70icwo8nvdax-1782}])
                                (let ([right-rest #{tl dpuuv4a3mobea70icwo8nvdax-1783}])
                                  (begin
                                    (and (compatible-type-contract?
                                           left
                                           right)
                                         (loop left-rest right-rest))))))
                            (begin #f)))))))
              (begin (null? right-rest))))))
    (define (compatible-type-contract? left right)
      (andmap
        (lambda (a b)
          (syntax-case a (: :? :- :~ :=)
            [(~ type-a . _)
             (or (free-identifier=? #'~ #':)
                 (free-identifier=? #'~ #':-))
             (syntax-case b (:~)
               [(~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred ~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred := _) #t])]
            [(:? type-a . _)
             (syntax-case b (:~ :?)
               [(:? type-b . _) (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred :? type-b . _)
                (contract-type-subtype? #'type-a #'type-b)]
               [_ #f])]
            [(:- type-a . _)
             (syntax-case b (:~ :=)
               [(~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred ~ type-b . rest)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred := _) #t])]
            [(:~ pred-a : type-a . _)
             (syntax-case b (:~)
               [(~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred-b ~ type-b . _)
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred := _) #t])]
            [(:~ pred-a :? type-a . _)
             (syntax-case b (:? :~)
               [(:? type-b . _) (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred-b :? type-b . _)
                (contract-type-subtype? #'type-a #'type-b)]
               [_ #f])]
            [(:~ pred-a :- type-a . _)
             (syntax-case b (:~)
               [(~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred-b ~ type-b . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                (contract-type-subtype? #'type-a #'type-b)]
               [(:~ pred-b := _) #t])]
            [(:~ pred-a . _)
             (syntax-case b (: :? :- :~)
               [(~ . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                #f]
               [(:~ pred-b ~ . _)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-))
                #f]
               [_ #t])]))
        left
        right))
    (define (contract-type-subtype? type-a type-b)
      (cond
        [(not type-a) (not type-b)]
        [(not type-b) #f]
        [(free-identifier=? type-a type-b) #t]
        [else
         (let again ([klass-a (syntax-local-value type-a)]
                     [klass-b (syntax-local-value type-b)])
           (cond
             [(eq? klass-a klass-b) #t]
             [(class-type-info? klass-a)
              (cond
                [(class-type-info? klass-b)
                 (cond
                   [(eq? (!class-type-id klass-a) (!class-type-id klass-b))
                    #t]
                   [(memp
                      (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1784})
                        (free-identifier=?
                          type-b
                          #{e dpuuv4a3mobea70icwo8nvdax-1784}))
                      (!class-precedence-list klass-a))
                    #t]
                   [else #f])]
                [(type-reference? klass-b)
                 (cond
                   [(syntax-local-value
                      (type-reference-identifier klass-b)
                      false) =>
                    (lambda (klass-b) (again klass-a klass-b))]
                   [(free-identifier=?
                      type-a
                      (type-reference-identifier klass-b))
                    #t]
                   [else #f])]
                [else #f])]
             [(interface-info? klass-a)
              (cond
                [(interface-info? klass-b)
                 (cond
                   [(memp
                      (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1785})
                        (free-identifier=?
                          type-b
                          #{e dpuuv4a3mobea70icwo8nvdax-1785}))
                      (interface-info-interface-precedence-list klass-a))
                    #t]
                   [else #f])]
                [(type-reference? klass-b)
                 (cond
                   [(syntax-local-value
                      (type-reference-identifier klass-b)
                      false) =>
                    (lambda (klass-b) (again klass-a klass-b))]
                   [(free-identifier=?
                      type-a
                      (type-reference-identifier klass-b))
                    #t]
                   [else #f])]
                [else #f])]
             [(type-reference? klass-a)
              (cond
                [(syntax-local-value
                   (type-reference-identifier klass-a)
                   false) =>
                 (lambda (klass-a) (again klass-a klass-b))]
                [(type-reference? klass-b)
                 (cond
                   [(syntax-local-value
                      (type-reference-identifier klass-b)
                      false) =>
                    (lambda (klass-b) (again klass-a klass-b))]
                   [(free-identifier=?
                      (type-reference-identifier klass-a)
                      (type-reference-identifier klass-b))
                    #t]
                   [else #f])]
                [(free-identifier=?
                   type-b
                   (type-reference-identifier klass-a))
                 #t]
                [else #f])]
             [else #f]))]))
    (define (signature-type-contract signature)
      (let loop ([rest signature]
                 [positionals (list)]
                 [keywords (list)])
        (syntax-case #'rest ()
          [(id . rest)
           (identifier? #'id)
           (loop #'rest (cons #'(:- :t) positionals) keywords)]
          [((id default) . rest)
           (identifier? #'id)
           (loop #'rest (cons #'(:- :t) positionals) keywords)]
          [(id . contract)
           (identifier? #'id)
           (loop #'rest (cons #'contract positionals) keywords)]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop
             #'rest
             positionals
             (cons (cons* (stx-e #'kw) #'id #'(:- :t)) keywords))]
          [(kw (id default) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (loop
             #'rest
             positionals
             (cons (cons* (stx-e #'kw) #'id #'(:- :t)) keywords))]
          [(kw (id . contract) . rest)
           (loop
             #'rest
             positionals
             (cons (cons* (stx-e #'kw) #'id #'contract) keywords))]
          [_
           (values
             (reverse! positionals)
             (list-sort
               (lambda (a b) (keyword<? (stx-car a) (stx-car b)))
               keywords))])))
    (define (signature-arity spec)
      (let lp ([rest spec] [required 0] [optional 0])
        (syntax-case rest (:=)
          [(id . rest)
           (identifier? #'id)
           (lp #'rest (\x31;+ required) optional)]
          [((id default) . rest)
           (identifier? #'id)
           (lp #'rest required (\x31;+ optional))]
          [((_ ... := default) . rest)
           (lp #'rest required (\x31;+ optional))]
          [((id . _) . rest)
           (identifier? #'id)
           (lp #'rest (\x31;+ required) optional)]
          [(kw _ . rest)
           (stx-keyword? #'kw)
           (lp #'rest required optional)]
          [id (identifier? #'id) (\x40;list required optional '...)]
          [() (\x40;list required optional)])))
    (define (signature-keywords spec)
      (let lp ([rest spec] [keywords (list)])
        (syntax-case rest ()
          [(id . rest) (identifier? #'id) (lp #'rest keywords)]
          [((id . _) . rest) (identifier? #'id) (lp #'rest keywords)]
          [(kw _ . rest)
           (stx-keyword? #'kw)
           (lp #'rest (cons (stx-e #'kw) keywords))]
          [_ (list-sort keyword<? keywords)])))
    (define (symbol<? x y)
      (string<?
        (symbol->string (stx-e x))
        (symbol->string (stx-e y))))
    (define (keyword<? x y)
      (string<?
        (keyword->string (stx-e x))
        (keyword->string (stx-e y)))))
  (define-syntax interface
    (lambda (stx)
      (define (fold-methods mixin specs)
        (let* ([methods (fold-specs specs)])
          (let* ([methods (fold-mixins mixin methods)])
            (let lp ([rest methods] [methods (list)])
              (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1786} rest])
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1786})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1787} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1786})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-1788} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1786})])
                      (let ([method #{hd dpuuv4a3mobea70icwo8nvdax-1787}])
                        (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1788}])
                          (begin
                            (cond
                              [(find
                                 (lambda (other)
                                   (stx-eq?
                                     (stx-car method)
                                     (stx-car other)))
                                 rest) =>
                               (lambda (duplicate)
                                 (if (compatible-signatures?
                                       duplicate
                                       method)
                                     (lp rest methods)
                                     (raise-syntax-error #f
                                       "invalid interface specification; incompatible method signatures"
                                       stx method duplicate)))]
                              [else (lp rest (cons method methods))])))))
                    (begin
                      (list-sort
                        (lambda (x y) (symbol<? (stx-car x) (stx-car y)))
                        methods))))))))
      (define (fold-mixins mixin methods)
        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1789} (lambda (mixin
                                                            methods)
                                                     (cond
                                                       [(syntax-local-value
                                                          mixin
                                                          false) =>
                                                        (lambda (info)
                                                          (if (interface-info?
                                                                info)
                                                              (let ([#{f dpuuv4a3mobea70icwo8nvdax-1790} cons])
                                                                (fold-left
                                                                  (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1791}
                                                                           #{e dpuuv4a3mobea70icwo8nvdax-1792})
                                                                    (#{f dpuuv4a3mobea70icwo8nvdax-1790}
                                                                      #{e dpuuv4a3mobea70icwo8nvdax-1792}
                                                                      #{a dpuuv4a3mobea70icwo8nvdax-1791}))
                                                                  methods
                                                                  (map syntax-local-introduce
                                                                       (interface-info-interface-methods
                                                                         info))))
                                                              (raise-syntax-error #f
                                                                "invalid mixin; not an interface type"
                                                                stx mixin
                                                                info)))]
                                                       [else
                                                        (raise-syntax-error
                                                          #f
                                                          "invalid mixin; unknown type"
                                                          stx
                                                          mixin)]))])
          (fold-left
            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1793}
                     #{e dpuuv4a3mobea70icwo8nvdax-1794})
              (#{f dpuuv4a3mobea70icwo8nvdax-1789}
                #{e dpuuv4a3mobea70icwo8nvdax-1794}
                #{a dpuuv4a3mobea70icwo8nvdax-1793}))
            methods
            mixin)))
      (define (fold-specs specs)
        (let loop ([rest specs] [methods (list)])
          (syntax-case rest (=>)
            [((id . args) => return-type . rest)
             (and (identifier? #'id) (identifier? #'return-type))
             (begin
               (check-signature! stx #'args #'return-type)
               (loop
                 #'rest
                 (cons (\x40;list #'id #'args #'return-type) methods)))]
            [((id . args) . rest)
             (identifier? #'id)
             (begin
               (check-signature! stx #'args #f)
               (loop
                 #'rest
                 (cons
                   (\x40;list #'id #'args (core-quote-syntax ':t))
                   methods)))]
            [() methods]
            [bad
             (raise-syntax-error
               #f
               "invalid interface specification"
               stx
               #'bad)])))
      (define (make-method-defs Interface)
        (lambda (method offset)
          (let ([signature (stx-car (stx-cdr method))])
            (with-syntax ([Interface Interface]
                          [method method]
                          [method-name (stx-car method)]
                          [self (syntax-local-introduce 'self)]
                          [offset offset]
                          [(out ...) (signature-arguments-out signature)])
              (if (stx-list? signature)
                  (syntax/loc
                    stx
                    (definterface-method
                      Interface
                      method
                      (declare (not safe))
                      (let ([obj (\x23;\x23;unchecked-structure-ref
                                   self
                                   1
                                   #f
                                   'method-name)]
                            [f (\x23;\x23;unchecked-structure-ref
                                 self
                                 offset
                                 #f
                                 'method-name)])
                        (f obj out ...))))
                  (syntax/loc
                    stx
                    (definterface-method
                      Interface
                      method
                      (declare (not safe))
                      (let ([obj (\x23;\x23;unchecked-structure-ref
                                   self
                                   1
                                   #f
                                   'method-name)]
                            [f (\x23;\x23;unchecked-structure-ref
                                 self
                                 offset
                                 #f
                                 'method-name)])
                        (\x23;\x23;apply f obj out ...)))))))))
      (define (make-interface-namespace name)
        (if (module-context? (current-expander-context))
            (cond
              [(module-context-ns (current-expander-context)) =>
               (lambda (ns) (make-symbol ns "::" name))]
              [else name])
            (make-symbol
              (gensym
                (let ([x name]) (if (symbol? x) (symbol->string x) x))))))
      (define (make-method-name-spec method-name namespace mixin)
        (let loop ([rest mixin]
                   [result (list
                             (make-symbol namespace "::" method-name))])
          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1795} rest])
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1795})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1796} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1795})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-1797} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1795})])
                  (let ([info #{hd dpuuv4a3mobea70icwo8nvdax-1796}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1797}])
                      (begin
                        (if (find
                              (lambda (ms) (eq? method-name (car ms)))
                              (interface-info-interface-methods info))
                            (loop
                              rest
                              (cons
                                (make-symbol
                                  (interface-info-namespace info)
                                  "::"
                                  method-name)
                                result))
                            (loop rest result))))))
                (begin (reverse! (cons method-name result)))))))
      (syntax-case stx ()
        [(_ hd spec ...)
         (or (identifier? #'hd) (identifier-list? #'hd))
         (with-syntax*
           ((name (if (identifier? #'hd) #'hd (stx-car #'hd)))
            (namespace (make-interface-namespace (stx-e #'name)))
            (klass (stx-identifier #'name #'name "::t"))
            (klass-quoted (core-quote-syntax #'klass))
            (klass-type-id (make-class-type-id #'name))
            (descriptor (stx-identifier #'name #'name "::interface"))
            (make (stx-identifier #'name "make-" #'name))
            (try-make (stx-identifier #'name "try-" #'name))
            (predicate (stx-identifier #'name #'name "?"))
            (instance-predicate
              (stx-identifier #'name "is-" #'name "?"))
            ((mixin ...)
              (if (identifier? #'hd)
                  (\x40;list)
                  (syntax->list (stx-cdr #'hd))))
            ((method ...) (fold-methods #'(mixin ...) #'(spec ...)))
            ((method-name ...) (map stx-car #'(method ...)))
            ((mixin-precedence-list ...)
              (interface-mixin->precedence-list #'(mixin ...)))
            ((values linearized-mixins)
              (map syntax-local-value #'(mixin-precedence-list ...)))
            ((method-name-spec ...)
              (map (cut make-method-name-spec
                        <>
                        (stx-e #'namespace)
                        linearized-mixins)
                   (map stx-e #'(method-name ...))))
            ((method-signature ...) (map stx-cdr #'(method ...)))
            ((method-impl-name ...)
              (map (lambda (method-name)
                     (stx-identifier #'name #'name "-" method-name))
                   #'(method-name ...)))
            ((unchecked-method-impl-name ...)
              (map (lambda (method-name)
                     (stx-identifier #'name "&" #'name "-" method-name))
                   #'(method-name ...)))
            ((defmethod-impl ...)
              (map (make-method-defs #'name)
                   #'(method ...)
                   (iota (length #'(method-name ...)) 2)))
            (defklass
              #'(def klass
                     (begin-annotation
                       (\x40;mop.class klass-type-id
                         (interface-instance::t) (method-name ...) #f #t #t
                         #f)
                       (make-class-type 'klass-type-id 'name
                         (\x40;list interface-instance::t)
                         '(method-name ...) '((final: . #t) (struct: . #t))
                         #f))))
            (defdescriptor
              #'(def descriptor
                     (begin-annotation
                       (\x40;interface klass-quoted (method-name ...))
                       (make-interface-descriptor
                         klass
                         '(method-name-spec ...)))))
            (defmake
              #'(def (make obj)
                     (begin-annotation
                       (\x40;type.signature return: klass-quoted effect:
                         (cast) arguments: (t::t))
                       (cast descriptor obj))))
            (deftry-make
              #'(def (try-make obj)
                     (begin-annotation
                       (\x40;type.signature return: t::t effect: (cast)
                         arguments: (t::t))
                       (try-cast descriptor obj))))
            (defpred
              #'(def predicate
                     (begin-annotation
                       (\x40;mop.predicate klass-quoted)
                       (lambda (obj) (direct-instance? klass obj)))))
            (defpred-instance
              #'(def (instance-predicate obj)
                     (begin-annotation
                       (\x40;type.signature return: boolean::t effect:
                         (pure) arguments: (t::t))
                       (and (satisfies? descriptor obj) #t))))
            (definfo
              #'(defsyntax
                  name
                  (make-interface-info name: 'name namespace: 'namespace
                   interface-mixin: (\x40;list (quote-syntax mixin) ...)
                   interface-precedence-list:
                   (\x40;list (quote-syntax mixin-precedence-list) ...)
                   interface-methods: '(method ...) instance-type:
                   (quote-syntax klass) interface-descriptor:
                   (quote-syntax descriptor) instance-constructor:
                   (quote-syntax make) instance-try-constructor:
                   (quote-syntax try-make) instance-predicate:
                   (quote-syntax predicate) instance-satisfies-predicate:
                   (quote-syntax instance-predicate)
                   implementation-methods:
                   (\x40;list (quote-syntax method-impl-name) ...)
                   unchecked-implementation-methods:
                   (\x40;list
                     (quote-syntax unchecked-method-impl-name)
                     ...)))))
           #'(begin
               defklass
               defdescriptor
               defmake
               deftry-make
               defpred
               defpred-instance
               definfo
               defmethod-impl
               ...))])))
  (define-syntax definterface-method
    (lambda (stx)
      (define (emit-raw-method? return)
        (let ([return-type (syntax-local-value return)])
          (if (and (class-type-info? return-type)
                   (memq (!class-type-id return-type) '(t void)))
              #f
              #t)))
      (define (make-checked-method-def Interface method-name
               raw-method-name unchecked-method-name signature return)
        (with-syntax ([Interface Interface]
                      [method method-name]
                      [target-method (if (emit-raw-method? return)
                                         raw-method-name
                                         unchecked-method-name)]
                      [self (syntax-local-introduce 'self)]
                      [in (signature-arguments-in signature)]
                      [(out ...) (signature-arguments-out signature)]
                      [signature signature]
                      [return return])
          (if (stx-list? #'signature)
              (syntax/loc
                stx
                (def (method self . in)
                     (with-interface-checked-method
                       self
                       (Interface signature return target-method)
                       (:- (target-method self out ...) return))))
              (syntax/loc
                stx
                (def (method self . in)
                     (with-interface-checked-method
                       self
                       (Interface signature return target-method)
                       (:- (\x23;\x23;apply target-method self out ...)
                           return)))))))
      (define (make-raw-method-def Interface raw-method-name
               unchecked-method-name signature return)
        (if (emit-raw-method? return)
            (with-syntax ([Interface Interface]
                          [raw-method raw-method-name]
                          [unchecked-method unchecked-method-name]
                          [self (syntax-local-introduce 'self)]
                          [in (signature-arguments-in signature)]
                          [(out ...) (signature-arguments-out signature)]
                          [signature signature]
                          [return return])
              (if (stx-list? #'signature)
                  (syntax/loc
                    stx
                    (def (raw-method self . in)
                         (with-interface-unchecked-method
                           self
                           (Interface signature return)
                           (: (unchecked-method self out ...) return))))
                  (syntax/loc
                    stx
                    (def (raw-method self . in)
                         (with-interface-unchecked-method
                           self
                           (Interface signature return)
                           (: (\x23;\x23;apply
                                unchecked-method
                                self
                                out
                                ...)
                              return))))))
            '(begin)))
      (define (make-unchecked-method-def Interface
               unchecked-method-name signature return body)
        (with-syntax ([Interface Interface]
                      [unchecked-method unchecked-method-name]
                      [self (syntax-local-introduce 'self)]
                      [in (signature-arguments-in signature)]
                      [signature signature]
                      [return return]
                      [(body ...) body])
          (syntax/loc
            stx
            (def (unchecked-method self . in)
                 (with-interface-unchecked-method
                   self
                   (Interface signature return)
                   (:- (let () body ...) return))))))
      (syntax-case stx ()
        [(_ Interface (method signature return) body ...)
         (and (syntax-local-interface-info? #'Interface)
              (identifier? #'method))
         (let* ([info (syntax-local-value #'Interface)]
                [interface-name (interface-info-name info)]
                [method-name (stx-identifier
                               #'Interface
                               interface-name
                               "-"
                               #'method)]
                [raw-method-name (stx-identifier
                                   #'Interface
                                   "__"
                                   method-name)]
                [unchecked-method-name (stx-identifier
                                         #'Interface
                                         "&"
                                         method-name)])
           (check-signature! stx #'signature #'return)
           (with-syntax ([defchecked (make-checked-method-def #'Interface method-name
                                       raw-method-name
                                       unchecked-method-name #'signature
                                       #'return)]
                         [defraw (make-raw-method-def #'Interface raw-method-name
                                   unchecked-method-name #'signature
                                   #'return)]
                         [defunchecked (make-unchecked-method-def #'Interface unchecked-method-name
                                         #'signature #'return
                                         #'(body ...))])
             #'(begin defchecked defraw defunchecked)))])))
  (define-syntax with-interface-method
    (lambda (stx)
      (syntax-case stx ()
        [(_ self
            (Interface signature return unchecked-proc)
            body
            ...)
         (let (checked? [and (stx-e #'unchecked-proc) #t])
           (with-syntax ([lambda-signature (make-interface-method-lambda-signature stx #'self #'Interface
                                             #'signature #'return
                                             #'unchecked-proc)]
                         [contract (make-interface-method-contract stx #'self #'Interface #'signature
                                     checked?)])
             #'(begin-annotation
                 (\x40;type.signature . lambda-signature)
                 (using contract body ...))))])))
  (define-syntax with-interface-checked-method
    (syntax-rules ()
      [(with-interface-checked-method
         self
         (Interface signature return raw-method)
         body
         ...)
       (with-interface-method
         self
         (Interface signature return raw-method)
         body
         ...)]))
  (define-syntax with-interface-unchecked-method
    (syntax-rules ()
      [(with-interface-unchecked-method
         self
         (Interface signature return)
         body
         ...)
       (with-interface-method
         self
         (Interface signature return #f)
         body
         ...)]))
  (define-syntax interface-out
    (make-export-expander
      (lambda (stx)
        (define (expand body unchecked?)
          (syntax-case body ()
            [(id ...)
             (identifier-list? #'(id ...))
             (let lp ([rest #'(id ...)] [ids (\x40;list)])
               (syntax-case rest ()
                 [(id . rest)
                  (let (info [syntax-local-value #'id false])
                    (unless (interface-info? info)
                      (raise-syntax-error
                        #f
                        "not an interface type"
                        stx
                        #'id))
                    (with ([interface-info instance-type:
                             type
                             interface-descriptor:
                             descriptor
                             instance-constructor:
                             constructor
                             instance-try-constructor:
                             try-constructor
                             instance-predicate:
                             predicate
                             instance-satisfies-predicate:
                             satisfies-predicate
                             implementation-methods:
                             method-impl
                             unchecked-implementation-methods:
                             unchecked-impl]
                           info)
                      (lp #'rest
                          (\x40;list #'id type descriptor constructor
                            try-constructor predicate satisfies-predicate
                            method-impl ...
                            (if unchecked? unchecked-impl (\x40;list)) ...
                            ids ...))))]
                 [_ (cons begin: ids)]))]))
        (syntax-case stx ()
          [(_ unchecked: unchecked? body ...)
           (expand #'(body ...) (stx-e #'unchecked?))]
          [(_ body ...) (expand #'(body ...) #t)])))))

(begin
  (begin
    (define (is-signature? formals)
      (let lp ([rest formals])
        (syntax-case rest ()
          [(id . rest) (identifier? #'id) (lp #'rest)]
          [((id _) . rest) (lp #'rest)]
          [((id . contract) . rest)
           (and (identifier? #'id) (signature-contract? #'contract))
           #t]
          [(kw id . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (lp #'rest)]
          [(kw (id _) . rest)
           (and (stx-keyword? #'kw) (identifier? #'id))
           (lp #'rest)]
          [(kw (id . contract) . rest)
           (and (stx-keyword? #'kw)
                (identifier? #'id)
                (signature-contract? #'contract))
           #t]
          [_ #f]))))
  (define-syntax def/c
    (lambda (stx)
      (define (make-definition id args return body)
        (check-signature! stx args return)
        (if (signature-has-keywords? args)
            (make-keyword-def id args return body)
            (let ([unchecked-id (stx-identifier id "__" id)])
              (with-syntax ([defchecked (make-checked-def
                                          id
                                          unchecked-id
                                          args
                                          return)]
                            [defunchecked (make-unchecked-def
                                            unchecked-id
                                            args
                                            return
                                            body)])
                #'(begin defchecked defunchecked)))))
      (define (make-keyword-def id signature return body)
        (with-syntax ([id id]
                      [in (signature-arguments-in signature)]
                      [signature signature]
                      [return return]
                      [return-type (resolve-type->type-descriptor
                                     stx
                                     return)]
                      [(body ...) body])
          (syntax/loc
            stx
            (def (id . in)
                 (with-procedure-signature
                   (signature return #f)
                   (begin-annotation
                     (\x40;type return-type)
                     (with-procedure-contract signature body ...)))))))
      (define (make-checked-def id unchecked-id signature return)
        (with-syntax ([id id]
                      [unchecked-id unchecked-id]
                      [in (signature-arguments-in signature)]
                      [(out ...) (signature-arguments-out signature)]
                      [signature signature]
                      [return return]
                      [return-type (resolve-type->type-descriptor
                                     stx
                                     return)])
          (if (stx-list? #'signature)
              (syntax/loc
                stx
                (def (id . in)
                     (with-procedure-signature
                       (signature return unchecked-id)
                       (begin-annotation
                         (\x40;type return-type)
                         (with-procedure-contract
                           signature
                           (unchecked-id out ...))))))
              (syntax/loc
                stx
                (def (id . in)
                     (with-procedure-signature
                       (signature return unchecked-id)
                       (begin-annotation
                         (\x40;type return-type)
                         (with-procedure-contract
                           signature
                           (\x23;\x23;apply unchecked-id out ...)))))))))
      (define (make-unchecked-def unchecked-id signature return
               body)
        (with-syntax ([unchecked-id unchecked-id]
                      [in (signature-arguments-in signature)]
                      [signature signature]
                      [return return]
                      [(body ...) body])
          (syntax/loc
            stx
            (def (unchecked-id . in)
                 (with-procedure-signature
                   (#f return #f)
                   (with-procedure-unchecked-contract
                     signature
                     body
                     ...))))))
      (syntax-case stx (=>)
        [(_ (id . args) => return body ...)
         (identifier? #'id)
         (if (is-signature? #'args)
             (make-definition #'id #'args #'return #'(body ...))
             #'(def (id . args)
                    (with-procedure-signature (#f return #f) body ...)))]
        [(_ (id . args) body ...)
         (identifier? #'id)
         (if (is-signature? #'args)
             #'(def/c (id . args) => :t body ...)
             #'(def (id . args) body ...))]
        [(_ ((head . rest) . args) body ...)
         #'(def/c (head . rest) (lambda/c args body ...))]
        [(_ id expr) (identifier? #'id) #'(def id expr)])))
  (define-syntax with-procedure-signature
    (lambda (stx)
      (syntax-case stx ()
        [(_ (#f return #f) body ...)
         (with-syntax ([return-type (resolve-type->type-descriptor
                                      stx
                                      #'return)])
           #'(begin-annotation
               (\x40;type.signature return: return-type)
               (let () body ...)))]
        [(_ (signature return unchecked) body ...)
         (with-syntax ([lambda-signature (make-procedure-lambda-signature
                                           stx
                                           #'signature
                                           #'return
                                           #'unchecked)])
           #'(begin-annotation
               (\x40;type.signature . lambda-signature)
               (let () body ...)))])))
  (define-syntax with-procedure-contract
    (lambda (stx)
      (syntax-case stx ()
        [(_ signature body ...)
         (with-syntax ([contract (make-procedure-contract
                                   stx
                                   #'signature
                                   #t)])
           #'(using contract body ...))])))
  (define-syntax with-procedure-unchecked-contract
    (lambda (stx)
      (syntax-case stx ()
        [(_ signature body ...)
         (with-syntax ([contract (make-procedure-contract
                                   stx
                                   #'signature
                                   #f)])
           #'(using contract body ...))])))
  (define-syntax lambda/c
    (lambda (stx)
      (define (make-lambda signature return body)
        (with-syntax ([in (signature-arguments-in signature)]
                      [signature signature]
                      [return return]
                      [(body ...) body])
          (syntax/loc
            stx
            (lambda in
              (with-procedure-signature
                (signature return #f)
                (with-procedure-contract signature body ...))))))
      (syntax-case stx (=>)
        [(_ args => return body ...)
         (if (is-signature? #'args)
             (make-lambda #'args #'return #'(body ...))
             #'(lambda args
                 (with-procedure-signature (#f return #f) body ...)))]
        [(_ args body ...)
         (if (is-signature? #'args)
             #'(lambda/c args => :t body ...)
             #'(lambda args body ...))])))
  (define-syntax def*/c
    (syntax-rules ()
      [(def*/c id clause ...)
       (def id (case-lambda/c clause ...))]))
  (define-syntax case-lambda/c
    (lambda (stx)
      (define (is-clause-signature? clause)
        (syntax-case clause (=>)
          [(args => return body ...) #t]
          [(args body ...) (is-signature? #'args)]))
      (define (clause-e clause)
        (syntax-case clause (=>)
          [(args => return body ...)
           (if (is-signature? #'args)
               (begin
                 (check-signature! stx #'args #'return keywords: #f
                   optionals: #f)
                 (with-syntax ([in (signature-arguments-in #'args)])
                   #'(in (with-procedure-signature
                           (args return #f)
                           (with-procedure-contract args body ...)))))
               #'(args
                   (with-procedure-signature (#f return #f) body ...)))]
          [(args body ...)
           (if (is-signature? #'args)
               (clause-e #'(args => :t body ...))
               clause)]))
      (syntax-case stx ()
        [(_ clause ...)
         (ormap is-clause-signature? #'(clause ...))
         (with-syntax ([(clause ...) (map clause-e #'(clause ...))])
           #'(case-lambda clause ...))]
        [(_ clause ...) #'(case-lambda clause ...)])))
  (define-syntax \x40;method
    (lambda (stx)
      (syntax-case stx ()
        [(_ id arg ...)
         (dotted-identifier? #'id)
         (let* ([str (symbol->string (stx-e #'id))]
                [ix (string-rindex str #\.)])
           (with-syntax ([receiver (stx-identifier
                                     #'id
                                     (substring str 0 ix))]
                         [method (string->symbol
                                   (substring
                                     str
                                     (fx1+ ix)
                                     (string-length str)))])
             #'(call-method (%%ref-dotted receiver) 'method arg ...)))]
        [(_ method receiver arg ...)
         (identifier? #'method)
         #'(call-method receiver 'method arg ...)])))
  (define-syntax defmethod/c
    (lambda (stx)
      (define (interface-declaration? body)
        (syntax-case body ()
          [(interface: _ . rest) #t]
          [(key _ . rest)
           (stx-keyword? #'key)
           (interface-declaration? #'rest)]
          [() #f]
          [_
           (raise-syntax-error
             #f
             "illegal method definition attributes"
             stx
             body)]))
      (define (interface-declaration body)
        (let loop ([rest body] [pre (list)])
          (syntax-case rest ()
            [(interface: Interface . rest)
             (if (identifier? #'Interface)
                 (if (syntax-local-interface-info? #'Interface)
                     (if (interface-declaration? #'rest)
                         (raise-syntax-error
                           #f
                           "duplicate interface declaration"
                           stx)
                         (\x40;list #'Interface (reverse! pre) ...
                           (syntax->list #'rest) ...))
                     (raise-syntax-error
                       #f
                       "not defined as an interface"
                       stx
                       #'Interface))
                 (raise-syntax-error
                   #f
                   "bad interface specification"
                   stx
                   #'Interface))]
            [(key detail . rest)
             (stx-keyword? #'key)
             (loop #'rest (cons* #'detail #'key pre))])))
      (define (generate-interface-method method-id type-id impl
               rest)
        (with-syntax ([(Interface rest ...) (interface-declaration
                                              rest)]
                      [Type type-id])
          (let* ([info (syntax-local-value #'Interface)]
                 [method-name (stx-e method-id)]
                 [method-sig (interface-info-method-signature
                               info
                               method-name)])
            (unless method-sig
              (raise-syntax-error #f "uknown interface method" stx
                #'Interface method-id))
            (with-syntax ([interface-method-name (generate-interface-method-name
                                                   info
                                                   method-id)]
                          [method-implementation (generate-interface-method-implementation
                                                   type-id
                                                   method-id
                                                   impl
                                                   method-sig)])
              #'(defmethod
                  (\x40;method~ interface-method-name Type)
                  method-implementation
                  rest
                  ...)))))
      (define (generate-interface-method-name info method-id)
        (stx-identifier
          method-id
          (interface-info-namespace info)
          "::"
          method-id))
      (define (generate-interface-method-implementation type-id
               method-id impl method-sig)
        (syntax-case impl ()
          [(form (self . args) body ...)
           (and (identifier? #'form)
                (or (free-identifier=? #'form #'lambda/c)
                    (free-identifier=? #'form #'lambda))
                (method-receiver? #'self))
           (with-syntax*
             (((receiver . head)
                (generate-interface-lambda-head #'self #'args type-id
                  method-id (car method-sig)))
               (return-type (syntax-local-introduce (cadr method-sig)))
               ((body ...) (method-body #'receiver #'(body ...) #t)))
             #'(lambda/c head => return-type body ...))]
          [_ impl]))
      (define (generate-interface-lambda-head self args type-id
               method-id sig)
        (let* ([receiver (lambda-receiver self)])
          (call-with-values
            (lambda () (lambda-signature-explode sig))
            (lambda (positionals keywords tail)
              (let* ([head (lambda-head self args positionals keywords
                             tail type-id)])
                (cons* receiver head))))))
      (define (method-receiver? self)
        (syntax-case self ()
          [(id ~ type)
           (and (identifier? #'id)
                (identifier? #'~)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':-)
                    (free-identifier=? #'~ #'::-)))]
          [_ (identifier? self)]))
      (define (method-receiver self type-id)
        (if (identifier? self)
            (list self '::- type-id)
            (syntax-case self ()
              [(id ~ type)
               (if (eq? (resolve-type stx #'type)
                        (resolve-type stx type-id))
                   (if (or (free-identifier=? #'~ #':)
                           (free-identifier=? #'~ #'::-))
                       (\x40;list #'id '::- type-id)
                       (\x40;list #'id ':- type-id))
                   (raise-syntax-error #f "unexpected self type" stx self
                     type-id))])))
      (define (method-body receiver body interface?)
        (with-syntax ([receiver receiver])
          (syntax-case body (=>)
            [(=> return-type body ...)
             (if interface?
                 (raise-syntax-error
                   #f
                   "unexpected return type"
                   stx
                   #'return-type)
                 (\x40;list
                   #'=>
                   #'return-type
                   (syntax/loc stx (with-receiver receiver body ...))))]
            [(body ...)
             (\x40;list
               (syntax/loc stx (with-receiver receiver body ...)))])))
      (define (lambda-receiver self)
        (if (identifier? self) self (stx-car self)))
      (define (lambda-signature-explode sig)
        (let loop ([rest sig] [args (list)] [kws (list)])
          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1798} rest])
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1798})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1799} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1798})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-1800} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1798})])
                  (if (keyword? #{hd dpuuv4a3mobea70icwo8nvdax-1799})
                      (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1799}])
                        (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1800})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1801} (car #{tl dpuuv4a3mobea70icwo8nvdax-1800})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1802} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1800})])
                              (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1801}])
                                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1802}])
                                  (begin
                                    (loop
                                      rest
                                      args
                                      (cons*
                                        (argument-type hd)
                                        key
                                        kws))))))
                            (if (pair?
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-1798})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1803} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1798})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-1804} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1798})])
                                  (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1803}])
                                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1804}])
                                      (begin
                                        (loop
                                          rest
                                          (cons (argument-type hd) args)
                                          kws)))))
                                (let ([tail #{match-val dpuuv4a3mobea70icwo8nvdax-1798}])
                                  (values
                                    (reverse! args)
                                    (reverse! kws)
                                    tail)))))
                      (if (pair?
                            #{match-val dpuuv4a3mobea70icwo8nvdax-1798})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1803} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1798})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-1804} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1798})])
                            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1803}])
                              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1804}])
                                (begin
                                  (loop
                                    rest
                                    (cons (argument-type hd) args)
                                    kws)))))
                          (let ([tail #{match-val dpuuv4a3mobea70icwo8nvdax-1798}])
                            (values
                              (reverse! args)
                              (reverse! kws)
                              tail)))))
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1798})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1803} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1798})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-1804} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1798})])
                      (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1803}])
                        (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1804}])
                          (begin
                            (loop
                              rest
                              (cons (argument-type hd) args)
                              kws)))))
                    (let ([tail #{match-val dpuuv4a3mobea70icwo8nvdax-1798}])
                      (values (reverse! args) (reverse! kws) tail)))))))
      (define (argument-type arg)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1805} arg])
          (if (symbol? #{match-val dpuuv4a3mobea70icwo8nvdax-1805})
              (let ([id #{match-val dpuuv4a3mobea70icwo8nvdax-1805}])
                (begin '(:- :t)))
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1805})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1806} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1805})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-1807} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1805})])
                    (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1806}])
                      (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1807})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1808} (car #{tl dpuuv4a3mobea70icwo8nvdax-1807})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-1809} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1807})])
                            (let ([default #{hd dpuuv4a3mobea70icwo8nvdax-1808}])
                              (if (null?
                                    #{tl dpuuv4a3mobea70icwo8nvdax-1809})
                                  (begin '(:- :t))
                                  (if (pair?
                                        #{match-val dpuuv4a3mobea70icwo8nvdax-1805})
                                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1810} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1805})]
                                            [#{tl dpuuv4a3mobea70icwo8nvdax-1811} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1805})])
                                        (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1810}])
                                          (let ([contract #{tl dpuuv4a3mobea70icwo8nvdax-1811}])
                                            (begin
                                              (extract-type contract)))))
                                      (begin
                                        (raise-syntax-error
                                          #f
                                          "BUG: unexpected argument in signature"
                                          stx
                                          arg))))))
                          (if (pair?
                                #{match-val dpuuv4a3mobea70icwo8nvdax-1805})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1810} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1805})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-1811} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1805})])
                                (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1810}])
                                  (let ([contract #{tl dpuuv4a3mobea70icwo8nvdax-1811}])
                                    (begin (extract-type contract)))))
                              (begin
                                (raise-syntax-error
                                  #f
                                  "BUG: unexpected argument in signature"
                                  stx
                                  arg))))))
                  (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1805})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1810} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1805})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-1811} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1805})])
                        (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1810}])
                          (let ([contract #{tl dpuuv4a3mobea70icwo8nvdax-1811}])
                            (begin (extract-type contract)))))
                      (begin
                        (raise-syntax-error
                          #f
                          "BUG: unexpected argument in signature"
                          stx
                          arg)))))))
      (define (extract-type contract)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1812} contract])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1812})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1813} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1812})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-1814} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1812})])
                (let ([sigil #{hd dpuuv4a3mobea70icwo8nvdax-1813}])
                  (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1814})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1815} (car #{tl dpuuv4a3mobea70icwo8nvdax-1814})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-1816} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1814})])
                        (let ([detail #{hd dpuuv4a3mobea70icwo8nvdax-1815}])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1816}])
                            (begin
                              (case sigil
                                [(: ::-)
                                 (list
                                   '::-
                                   (syntax-local-introduce detail))]
                                [(:-)
                                 (list
                                   ':-
                                   (syntax-local-introduce detail))]
                                [(:?)
                                 (list
                                   ':?
                                   (syntax-local-introduce detail))]
                                [(:~ :=) (extract-type rest)]
                                [else
                                 (raise-syntax-error
                                   #f
                                   "BUG: unexpected contract sigil in signature"
                                   stx
                                   sigil)])))))
                      (if (null?
                            #{match-val dpuuv4a3mobea70icwo8nvdax-1812})
                          (begin '(:- :t))
                          (error 'match
                            "no matching clause"
                            #{match-val dpuuv4a3mobea70icwo8nvdax-1812})))))
              (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-1812})
                  (begin '(:- :t))
                  (error 'match
                    "no matching clause"
                    #{match-val dpuuv4a3mobea70icwo8nvdax-1812})))))
      (define (lambda-argument? arg)
        (or (identifier? arg)
            (syntax-case arg ()
              [(id contract ...) (identifier? #'id)]
              [_ #f])))
      (define (lambda-argument-contract arg sig-contract)
        (define (verify-type type sig-type)
          (unless (eq? (resolve-type stx type)
                       (resolve-type stx sig-type))
            (raise-syntax-error #f
              "invalid interface method implementation; unexpected argument type"
              stx arg type sig-type)))
        (if (identifier? arg)
            (cons arg sig-contract)
            (syntax-case arg ()
              [(id contract ...)
               (let loop ([rest #'(contract ...)])
                 (syntax-case rest (:-)
                   [(:- Type . _)
                    (begin
                      (verify-type #'Type (cadr sig-contract))
                      #'(id :- Type))]
                   [(~ Type . _)
                    (or (free-identifier=? #'~ #':)
                        (free-identifier=? #'~ #'::-)
                        (free-identifier=? #'~ #':?))
                    (begin
                      (verify-type #'Type (cadr sig-contract))
                      (cons #'id sig-contract))]
                   [(sigil what . rest) (loop #'rest)]
                   [_
                    (raise-syntax-error #f stx
                      "invalid interface method implementation; unexpected argument contract"
                      stx arg)]))])))
      (define (lambda-head self args positionals keywords tail
               type-id)
        (define (syntax-error! what detail)
          (raise-syntax-error #f
            (string-append
              "invalid interface method implementation; "
              what)
            stx args detail))
        (define (finish pos kws tail)
          (let loop ([rest keywords])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1817} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1817})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1818} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1817})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-1819} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1817})])
                    (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1818}])
                      (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1819})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1820} (car #{tl dpuuv4a3mobea70icwo8nvdax-1819})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-1821} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1819})])
                            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1821}])
                              (begin
                                (if (memq key kws)
                                    (loop rest)
                                    (syntax-error!
                                      "missing keyword argument"
                                      key)))))
                          (begin
                            (cons* (method-receiver self type-id)
                              (reverse! pos) ... (reverse! kws) ...
                              tail)))))
                  (begin
                    (cons* (method-receiver self type-id) (reverse! pos)
                      ... (reverse! kws) ... tail))))))
        (let loop ([rest-args args]
                   [rest-pos positionals]
                   [pos (list)]
                   [kws (list)])
          (syntax-case rest-args ()
            [(arg . rest-args)
             (lambda-argument? #'arg)
             (match rest-pos
               [(\x40;list contract . rest-pos)
                (loop
                  #'rest-args
                  rest-pos
                  (cons (lambda-argument-contract #'arg contract) pos)
                  kws)]
               [else
                (syntax-error! "unexpected positional argument" #'arg)])]
            [(key arg . rest-args)
             (and (stx-keyword? #'key) (lambda-argument? #'arg))
             (let (key [stx-e #'key])
               (cond
                 [(memq key kws)
                  (syntax-error! "duplicate keyword argument" key)]
                 [(pgetq key keywords) =>
                  (lambda (contract)
                    (loop
                      #'rest-args
                      rest-pos
                      args
                      (cons*
                        (lambda-argument-contract #'arg contract)
                        key
                        kws)))]
                 [else
                  (syntax-error! "unexpected keyword argument" key)]))]
            [last
             (identifier? #'last)
             (if (symbol? tail)
                 (finish pos kws #'last)
                 (syntax-error! "unpexted tail argument" #'last))]
            [()
             (if (null? tail)
                 (finish pos kws (\x40;list))
                 (syntax-error! "missing tail argument" tail))]
            [_
             (syntax-error! "unexpected formal in lambda" rest-args)])))
      (define (generate-class-method method-id type-id impl rest)
        (syntax-case impl ()
          [(form (self . args) body ...)
           (and (identifier? #'form)
                (or (free-identifier=? #'form #'lambda/c)
                    (free-identifier=? #'form #'lambda))
                (method-receiver? #'self))
           (with-syntax*
             ((receiver (lambda-receiver #'self)) (self (method-receiver #'self type-id))
               ((body ...) (method-body #'receiver #'(body ...) #f))
               (procedure
                 (syntax/loc stx (lambda/c (self . args) body ...)))
               ((rest ...) rest) (method method-id) (Type type-id))
             #'(defmethod
                 (\x40;method~ method Type)
                 procedure
                 rest
                 ...))]
          [(form ((self . args) body ...) ...)
           (and (identifier? #'form)
                (or (free-identifier=? #'form #'case-lambda/c)
                    (free-identifier=? #'form #'case-lambda))
                (stx-map method-receiver? #'(self ...)))
           (with-syntax*
             (((receiver ...) (stx-map lambda-receiver #'(self ...)))
               (((body ...) ...)
                 (stx-map
                   (cut method-body <> <> #f)
                   #'(receiver ...)
                   #'((body ...) ...)))
               ((self ...)
                 (stx-map (cut method-receiver <> type-id) #'(self ...)))
               (procedure
                 (syntax/loc
                   stx
                   (case-lambda/c ((self . args) body ...) ...)))
               ((rest ...) rest) (method method-id) (Type type-id))
             #'(defmethod
                 (\x40;method~ method Type)
                 procedure
                 rest
                 ...))]
          [_
           (with-syntax ([method method-id]
                         [Type type-id]
                         [procedure impl]
                         [(rest ...) rest])
             #'(defmethod
                 (\x40;method~ method Type)
                 procedure
                 rest
                 ...))]))
      (syntax-case stx (\x40;method)
        [(_ (\x40;method method Type) impl rest ...)
         (and (identifier? #'method) (identifier? #'Type))
         (if (syntax-local-class-type-info? #'Type)
             (if (interface-declaration? #'(rest ...))
                 (generate-interface-method
                   #'method
                   #'Type
                   #'impl
                   #'(rest ...))
                 (generate-class-method
                   #'method
                   #'Type
                   #'impl
                   #'(rest ...)))
             (raise-syntax-error #f "not defined as class" stx #'Type))]
        [(_ (wtf method Type) . _)
         (cond
           [(resolve-identifier #'wtf) =>
            (lambda (b)
              (raise-syntax-error #f "booooo!" stx (binding-id b)))]
           [else (raise-syntax-error #f "booooo!" stx)])])))
  (define-syntax with-receiver
    (lambda (stx)
      (syntax-case stx ()
        [(_ receiver expr)
         (with-syntax ([receiver (core-quote-syntax #'receiver)])
           #'(begin-annotation (\x40;receiver receiver) expr))]
        [(recur receiver expr rest ...)
         #'(recur receiver (let () expr rest ...))])))
  (define-syntax let/c
    (lambda (stx)
      (syntax-case stx (=>)
        [(_ id ((var init) ...) => return body ...)
         (identifier? #'id)
         (with-syntax ([proc (syntax/loc
                               stx
                               (lambda/c (var ...) => return body ...))])
           #'((letrec ([id proc]) id) init ...))]
        [(_ id ((var init) ...) body ...)
         (and (identifier? #'id) (is-signature? #'(var ...)))
         #'(let/c id ((var init) ...) => :t body ...)]
        [(_ . body) #'(let . body)])))
  (define-syntax defclass/c
    (lambda (stx)
      (define (generate hd slots body)
        (syntax-case hd ()
          [(id super ...)
           (and (identifier? #'id)
                (andmap syntax-local-class-type-info? #'(super ...)))
           (generate-defclass #'id #'(super ...) slots body)]
          [id
           (identifier? #'id)
           (generate-defclass #'id (\x40;list) slots body)]
          [_ (raise-syntax-error #f "bad class head" stx hd)]))
      (define (check-typedef-body! body)
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
        (unless (stx-plist? body body-opt?)
          (raise-syntax-error #f "invalid defclass body" stx body)))
      (define (slot-name slot-spec)
        (stx-e
          (if (identifier? slot-spec) slot-spec (stx-car slot-spec))))
      (define (slot-contract slot-spec)
        (syntax-case slot-spec ()
          [id (identifier? #'id) #f]
          [(id defult) #f]
          [(id . contract) #'contract]))
      (define (slot-contract-normalize slot-spec)
        (let ([contract (slot-contract slot-spec)])
          (and contract (begin (contract-normalize contract)))))
      (define (contract-normalize contract)
        (syntax-case contract (:~ :? := :-)
          [(pre ... := _) (contract-normalize #'(pre ...))]
          [(:~ pred :? type) #'(:~ (? (or not pred)) :? type)]
          [(:- type) #f]
          [_ contract]))
      (define (slot-contract-type slot-spec)
        (let ([contract (slot-contract slot-spec)])
          (and contract (begin (contract-type contract)))))
      (define (contract-type contract)
        (syntax-case contract (:~)
          [(~ type . maybe-default)
           (and (identifier? #'~)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-)
                    (free-identifier=? #'~ #'::-)))
           #'type]
          [(:~ pred ~ type . maybe-default)
           (and (identifier? #'~)
                (or (free-identifier=? #'~ #':)
                    (free-identifier=? #'~ #':?)
                    (free-identifier=? #'~ #':-)
                    (free-identifier=? #'~ #'::-)))
           #'type]
          [_ #f]))
      (define (slot-contract-predicate slot-spec)
        (let ([contract (slot-contract slot-spec)])
          (and contract (begin (contract-predicate contract)))))
      (define (contract-predicate contract)
        (syntax-case contract (:~)
          [(:~ pred . contract-rest) #'pred]
          [_ #f]))
      (define (slot-default slot-spec)
        (syntax-case slot-spec (:=)
          [(id default) #'default]
          [(id ... := default) #'default]
          [_ #f]))
      (define (infer-slot-type slot type-a type-b)
        (cond
          [(not type-a) type-b]
          [(not type-b) type-a]
          [(free-identifier=? type-a type-b) type-a]
          [else
           (let again ([klass-a (syntax-local-value type-a)]
                       [klass-b (syntax-local-value type-b)])
             (cond
               [(eq? klass-a klass-b) type-a]
               [(class-type-info? klass-a)
                (cond
                  [(class-type-info? klass-b)
                   (cond
                     [(eq? (!class-type-id klass-a)
                           (!class-type-id klass-b))
                      type-a]
                     [(memp
                        (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1822})
                          (free-identifier=?
                            type-a
                            #{e dpuuv4a3mobea70icwo8nvdax-1822}))
                        (!class-precedence-list klass-b))
                      type-b]
                     [(memp
                        (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1823})
                          (free-identifier=?
                            type-b
                            #{e dpuuv4a3mobea70icwo8nvdax-1823}))
                        (!class-precedence-list klass-a))
                      type-a]
                     [else
                      (raise-syntax-error #f "incompatible slot types" stx
                        slot type-a type-b)])]
                  [(type-reference? klass-b)
                   (cond
                     [(syntax-local-value
                        (type-reference-identifier klass-b)
                        false) =>
                      (lambda (klass-b) (again klass-a klass-b))]
                     [(free-identifier=?
                        type-a
                        (type-reference-identifier klass-b))
                      type-a]
                     [else
                      (raise-syntax-error #f
                        "cannot resolve type reference to determine slot type compatibility"
                        stx slot type-a type-b)])]
                  [else
                   (raise-syntax-error #f "incompatible slot types" stx
                     slot type-a type-b)])]
               [(interface-info? klass-a)
                (cond
                  [(interface-info? klass-b)
                   (cond
                     [(memp
                        (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1824})
                          (free-identifier=?
                            type-a
                            #{e dpuuv4a3mobea70icwo8nvdax-1824}))
                        (interface-info-interface-precedence-list klass-b))
                      type-b]
                     [(memp
                        (lambda (#{e dpuuv4a3mobea70icwo8nvdax-1825})
                          (free-identifier=?
                            type-b
                            #{e dpuuv4a3mobea70icwo8nvdax-1825}))
                        (interface-info-interface-precedence-list klass-a))
                      type-a]
                     [else
                      (raise-syntax-error #f "incompatible slot types" stx
                        slot type-a type-b)])]
                  [(type-reference? klass-b)
                   (cond
                     [(syntax-local-value
                        (type-reference-identifier klass-b)
                        false) =>
                      (lambda (klass-b) (again klass-a klass-b))]
                     [(free-identifier=?
                        type-a
                        (type-reference-identifier klass-b))
                      type-a]
                     [else
                      (raise-syntax-error #f
                        "cannot resolve type reference to determine slot type compatibility"
                        stx slot type-a type-b)])]
                  [else
                   (raise-syntax-error #f "incompatible slot types" stx
                     slot type-a type-b)])]
               [(type-reference? klass-a)
                (cond
                  [(syntax-local-value
                     (type-reference-identifier klass-a)
                     false) =>
                   (lambda (klass-a) (again klass-a klass-b))]
                  [(type-reference? klass-b)
                   (cond
                     [(syntax-local-value
                        (type-reference-identifier klass-b)
                        false) =>
                      (lambda (klass-b) (again klass-a klass-b))]
                     [(free-identifier=?
                        (type-reference-identifier klass-a)
                        (type-reference-identifier klass-b))
                      type-a]
                     [else
                      (raise-syntax-error #f
                        "cannot resolve type reference to determine slot type compatibility"
                        stx slot type-a type-b)])]
                  [(free-identifier=?
                     type-b
                     (type-reference-identifier klass-a))
                   type-b]
                  [else
                   (raise-syntax-error #f
                     "cannot resolve type reference to determine slot type compatibility"
                     stx slot type-a type-b)])]
               [else
                (raise-syntax-error #f "unexpected slot type" stx slot
                  type-a klass-a)]))]))
      (define (get-mixin-slots super)
        (define tab (make-hash-table-eq))
        (let loop ([rest super] [result (list)])
          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1826} rest])
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1826})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1827} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1826})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-1828} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1826})])
                  (let ([type-id #{hd dpuuv4a3mobea70icwo8nvdax-1827}])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1828}])
                      (begin
                        (let* ([klass (resolve-type stx type-id)])
                          (let* ([slots (!class-type-slots klass)])
                            (let loop-inner ([rest-slots slots]
                                             [result result])
                              (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1829} rest-slots])
                                (if (pair?
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-1829})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1830} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1829})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-1831} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1829})])
                                      (let ([slot #{hd dpuuv4a3mobea70icwo8nvdax-1830}])
                                        (let ([rest-slots #{tl dpuuv4a3mobea70icwo8nvdax-1831}])
                                          (begin
                                            (let ([slot-type (hash-ref
                                                               tab
                                                               slot
                                                               absent-value)])
                                              (cond
                                                [(eq? slot-type
                                                      absent-value)
                                                 (hash-put!
                                                   tab
                                                   slot
                                                   (!class-slot-type
                                                     klass
                                                     slot))
                                                 (loop-inner
                                                   rest-slots
                                                   (cons slot result))]
                                                [(not slot-type)
                                                 (hash-put!
                                                   tab
                                                   slot
                                                   (!class-slot-type
                                                     klass
                                                     slot))
                                                 (loop-inner
                                                   rest-slots
                                                   result)]
                                                [else
                                                 (let ([other-slot-type (!class-slot-type
                                                                          klass
                                                                          slot)])
                                                   (let ([slot-type (infer-slot-type
                                                                      slot
                                                                      other-slot-type
                                                                      slot-type)])
                                                     (hash-put!
                                                       tab
                                                       slot
                                                       slot-type)
                                                     (loop-inner
                                                       rest-slots
                                                       result)))]))))))
                                    (begin
                                      (loop
                                        (fold-right
                                          cons
                                          rest
                                          (!class-type-super klass))
                                        result)))))))))))
                (begin (values (reverse! result) tab))))))
      (define (get-slot-table slots mixin-slots super contract-e
               getf mixf)
        (define tab (make-hash-table-eq))
        (for-each
          (lambda (slot)
            (for-each
              (lambda (super-type)
                (let ([klass (syntax-local-value super-type)])
                  (cond
                    [(hash-get tab slot) =>
                     (lambda (a)
                       (cond
                         [(getf klass slot) =>
                          (lambda (b)
                            (hash-put! tab slot (mixf slot a b)))]))]
                    [(getf klass slot) =>
                     (lambda (a) (hash-put! tab slot a))])))
              super))
          mixin-slots)
        (for-each
          (lambda (slot-spec)
            (let ([slot (slot-name slot-spec)]
                  [a (contract-e slot-spec)])
              (when a
                (cond
                  [(hash-get tab slot) =>
                   (lambda (b) (hash-put! tab slot (mixf slot a b)))]
                  [else (hash-put! tab slot a)]))))
          slots)
        tab)
      (define (get-slot-contracts slots mixin-slots super
               slot-type-table)
        (get-slot-table slots mixin-slots super slot-contract-normalize
          !class-slot-contract
          (lambda (slot a b)
            (define-syntax incompatible-contracts!
              (syntax-rules ()
                [(_)
                 (raise-syntax-error #f "incompatible slot contracts" stx
                   slot a b)]))
            (syntax-case a (: :? :- :~)
              [(: . _)
               (syntax-case b (:? :~)
                 [(~ . _)
                  (or (free-identifier=? #'~ #':)
                      (free-identifier=? #'~ #':?)
                      (free-identifier=? #'~ #':-))
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(: type))]
                 [(:~ pred . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred : type))])]
              [(:? . _)
               (syntax-case b (:~ :?)
                 [(:? . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:? type))]
                 [(:~ pred :? . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred :? type))]
                 [_ (incompatible-contracts!)])]
              [(:- . _)
               (syntax-case b (:~)
                 [(~ . _)
                  (or (free-identifier=? #'~ #':)
                      (free-identifier=? #'~ #':?)
                      (free-identifier=? #'~ #':-))
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:- type))]
                 [(:~ pred . rest)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred :- type))])]
              [(:~ pred-a : . _)
               (syntax-case b (:~)
                 [(:~ pred-b . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ (? (and pred-a pred-b)) : type))]
                 [_
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred-a : type))])]
              [(:~ pred-a :? . _)
               (syntax-case b (:? :~)
                 [(:? . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred-a :? type))]
                 [(:~ pred-b :? . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ (? (and pred-a pred-b)) :? type))]
                 [(:~ pred-b . _) (incompatible-contracts!)]
                 [_ (incompatible-contracts!)])]
              [(:~ pred-a :- . _)
               (syntax-case b (:~)
                 [(~ . _)
                  (or (free-identifier=? #'~ #':)
                      (free-identifier=? #'~ #':?)
                      (free-identifier=? #'~ #':-))]
                 [(:~ pred-b . _)
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ (? (and pred-a pred-b)) :- type))])]
              [(:~ pred-a . _)
               (syntax-case b (: :? :- :~)
                 [(:~ pred-b ~ . _)
                  (or (free-identifier=? #'~ #':)
                      (free-identifier=? #'~ #':?)
                      (free-identifier=? #'~ #':-))
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ (? (and pred-a pred-b)) : type))]
                 [_
                  (with-syntax ([type (hash-ref slot-type-table slot)])
                    #'(:~ pred-a : type))])]))))
      (define (get-slot-defaults slots mixin-slots super)
        (get-slot-table slots mixin-slots super slot-default
          !class-slot-default (lambda (slot a b) a)))
      (define (update-slot-types! slots slot-type-table)
        (for-each
          (lambda (slot-spec)
            (let ([slot (slot-name slot-spec)])
              (let ([slot-type (slot-contract-type slot-spec)])
                (and slot-type
                     (begin
                       (cond
                         [(hash-get slot-type-table slot) =>
                          (lambda (other-slot-type)
                            (let ([slot-type (infer-slot-type
                                               slot
                                               other-slot-type
                                               slot-type)])
                              (hash-put! slot-type-table slot slot-type)))]
                         [else
                          (hash-put! slot-type-table slot slot-type)]))))))
          slots))
      (define (syntax-local-value/context id)
        (syntax-local-value
          id
          (lambda (id)
            (raise-syntax-error
              #f
              "not a class meta type binding"
              stx
              id))))
      (define (order-slots slots super)
        (call-with-values
          (lambda ()
            (c4-linearize (list) super
              (lambda (klass-id)
                (cons
                  klass-id
                  (!class-precedence-list
                    (syntax-local-value/context klass-id))))
              (lambda (klass-id)
                (!class-type-struct?
                  (syntax-local-value/context klass-id)))
              free-identifier=?))
          (lambda (precedence-list base-struct)
            (let* ([base-fields (if base-struct
                                    (let ([klass (syntax-local-value
                                                   base-struct)])
                                      (cond
                                        [(!class-type-ordered-slots klass)]
                                        [else
                                         (let ([ordered (order-slots
                                                          (!class-type-slots
                                                            klass)
                                                          (!class-type-super
                                                            klass))])
                                           (!class-type-ordered-slots-set!
                                             klass
                                             ordered)
                                           ordered)]))
                                    (list))])
              (let* ([r-fields (reverse base-fields)])
                (let* ([seen-slots (let ([tab (make-hash-table-eq)])
                                     (for-each
                                       (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1832})
                                         (hash-put!
                                           tab
                                           #{cut-arg dpuuv4a3mobea70icwo8nvdax-1832}
                                           #t))
                                       base-fields)
                                     tab)])
                  (let* ([process-slot (lambda (slot)
                                         (unless (hash-get seen-slots slot)
                                           (hash-put! seen-slots slot #t)
                                           (set! r-fields
                                             (cons slot r-fields))))])
                    (for-each
                      (lambda (mixin)
                        (let ([klass (syntax-local-value mixin)])
                          (unless (!class-type-struct? klass)
                            (cond
                              [(!class-type-ordered-slots klass) =>
                               (lambda (ordered)
                                 (for-each process-slot ordered))]
                              [else
                               (let ([ordered (order-slots
                                                (!class-type-slots klass)
                                                (!class-type-super
                                                  klass))])
                                 (!class-type-ordered-slots-set!
                                   klass
                                   ordered)
                                 (for-each process-slot ordered))]))))
                      precedence-list)
                    (for-each process-slot slots)
                    (reverse r-fields))))))))
      (define (wrap e-stx)
        (stx-wrap-source e-stx (stx-source stx)))
      (define (generate-defclass id super-ref slots body)
        (define (make-id . args) (apply stx-identifier id args))
        (check-duplicate-identifiers (map slot-name slots) stx)
        (check-signature-spec! stx slots #f)
        (check-typedef-body! body)
        (call-with-values
          (lambda () (get-mixin-slots super-ref))
          (lambda (mixin-slots slot-type-table)
            (let* ([slot-contract-table (get-slot-contracts
                                          slots
                                          mixin-slots
                                          super-ref
                                          slot-type-table)])
              (let* ([slot-default-table (get-slot-defaults
                                           slots
                                           mixin-slots
                                           super-ref)])
                (let* ([ordered-slots (order-slots
                                        (map slot-name slots)
                                        super-ref)])
                  (update-slot-types! slots slot-type-table)
                  (with-syntax*
                    (((values slots) (map slot-name slots))
                     ((values mixin-slots)
                       (filter
                         (lambda (slot) (not (memq slot slots)))
                         mixin-slots))
                     ((values name) (symbol->string (stx-e id)))
                     ((values super) (map syntax-local-value super-ref))
                     ((values struct?) (stx-getq struct: body)) (type id)
                     (type::t (make-id name "::t"))
                     (make-type (make-id "make-" name))
                     (type? (make-id name "?"))
                     (type-super (map !class-type-descriptor super))
                     ((slot ...) slots) ((ordered-slot ...) ordered-slots)
                     ((getf ...) (stx-map (cut make-id name "-" <>) slots))
                     ((setf ...)
                       (stx-map (cut make-id name "-" <> "-set!") slots))
                     ((rawsetf ...)
                       (stx-map
                         (cut make-id name "-unchecked-" <> "-set!")
                         slots))
                     ((mixin-slot ...) mixin-slots)
                     ((mixin-getf ...)
                       (stx-map (cut make-id name "-" <>) mixin-slots))
                     ((mixin-setf ...)
                       (stx-map
                         (cut make-id name "-" <> "-set!")
                         mixin-slots))
                     ((mixin-rawsetf ...)
                       (stx-map
                         (cut make-id name "-unchecked-" <> "-set!")
                         mixin-slots))
                     ((ugetf ...)
                       (stx-map (cut make-id "&" <>) #'(getf ...)))
                     ((usetf ...)
                       (stx-map (cut make-id "&" <>) #'(setf ...)))
                     ((mixin-ugetf ...)
                       (stx-map (cut make-id "&" <>) #'(mixin-getf ...)))
                     ((mixin-usetf ...)
                       (stx-map (cut make-id "&" <>) #'(mixin-setf ...)))
                     ((values type-slots)
                       (cond
                         [(stx-null? slots) (\x40;list)]
                         [else
                          (\x40;list
                            slots:
                            (map (lambda (slot getf setf rawsetf)
                                   (with-syntax ([slot slot]
                                                 [getf getf]
                                                 [setf setf]
                                                 [rawsetf rawsetf])
                                     (if (hash-get
                                           slot-contract-table
                                           (stx-e #'slot))
                                         #'(slot getf rawsetf)
                                         #'(slot getf setf))))
                                 #'(slot ...) #'(getf ...) #'(setf ...)
                                 #'(rawsetf ...)))]))
                     ((values type-mixin-slots)
                       (cond
                         [(stx-null? mixin-slots) (\x40;list)]
                         [else
                          (\x40;list
                            mixin:
                            (map (lambda (slot getf setf rawsetf)
                                   (with-syntax ([slot slot]
                                                 [getf getf]
                                                 [setf setf]
                                                 [rawsetf rawsetf])
                                     (if (hash-get
                                           slot-contract-table
                                           (stx-e #'slot))
                                         #'(slot getf rawsetf)
                                         #'(slot getf setf))))
                                 #'(mixin-slot ...) #'(mixin-getf ...)
                                 #'(mixin-setf ...)
                                 #'(mixin-rawsetf ...)))]))
                     ((values type-name)
                       (\x40;list name: (or (stx-getq name: body) id)))
                     ((values type-id)
                       (\x40;list
                         id:
                         (or (stx-getq id: body)
                             (make-class-type-id #'type))))
                     ((values type-constructor)
                       (or (alet
                             (e (stx-getq constructor: body))
                             (\x40;list constructor: e))
                           (\x40;list)))
                     ((values properties)
                       (let* ([properties (if (stx-e
                                                (stx-getq
                                                  transparent:
                                                  body))
                                              (\x40;list
                                                (\x40;list
                                                  transparent:
                                                  .
                                                  #t))
                                              (\x40;list))]
                              [properties (cond
                                            [(stx-e (stx-getq print: body)) =>
                                             (lambda (print)
                                               (let (print
                                                     [if (eq? print #t)
                                                       #'(slot ...)
                                                       print])
                                                 (cons
                                                   (\x40;list
                                                     print:
                                                     .
                                                     print)
                                                   properties)))]
                                            [else properties])]
                              [properties (cond
                                            [(stx-e (stx-getq equal: body)) =>
                                             (lambda (equal)
                                               (let (equal
                                                     [if (eq? equal #t)
                                                       #'(slot ...)
                                                       equal])
                                                 (cons
                                                   (\x40;list
                                                     equal:
                                                     .
                                                     equal)
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
                     ((values final?) (stx-e (stx-getq final: body)))
                     ((values type-struct) (\x40;list struct: struct?))
                     ((values type-final) (\x40;list final: final?))
                     ((values type-metaclass)
                       (if metaclass
                           (\x40;list 'metaclass: metaclass)
                           (\x40;list)))
                     ((type-body ...)
                       (\x40;list type-id ... type-name ... type-constructor ...
                         type-struct ... type-final ... type-metaclass ...
                         type-properties ... type-slots ...
                         type-mixin-slots ...))
                     (raw-make
                       (if (or (not (null? type-constructor))
                               (and (zero?
                                      (hash-length slot-contract-table))
                                    (zero?
                                      (hash-length slot-default-table)))
                               metaclass)
                           #'make-type
                           #f))
                     (defklass
                       (wrap
                         #'(defclass-type type::t type-super raw-make type?
                             type-body ...)))
                     (meta-type-id
                       (with-syntax ([(id: id) type-id]) #''id))
                     (meta-type-name
                       (with-syntax ([type-name (stx-car
                                                  (stx-cdr type-name))])
                         #''type-name))
                     (meta-type-super
                       (with-syntax ([(super-id ...) super-ref])
                         #'(\x40;list (quote-syntax super-id) ...)))
                     (meta-type-slots #''(slot ...))
                     (meta-type-ordered-slots #''(ordered-slot ...))
                     (meta-type-slot-types
                       (with-syntax ([((slot . type) ...) (filter
                                                            (lambda (st)
                                                              (cdr st))
                                                            (hash->list
                                                              slot-type-table))])
                         #'(\x40;list
                             (\x40;list 'slot :: (quote-syntax type))
                             ...)))
                     (meta-type-slot-contracts
                       (with-syntax ([((slot . contract) ...) (hash->list
                                                                slot-contract-table)])
                         #'(\x40;list (\x40;list 'slot :: 'contract) ...)))
                     (meta-type-slot-defaults
                       (with-syntax ([((slot . default) ...) (hash->list
                                                               slot-default-table)])
                         #'(\x40;list (\x40;list 'slot :: 'default) ...)))
                     (meta-type-struct? struct?) (meta-type-final? final?)
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
                           (\x40;list
                             'mixin-slot
                             ::
                             (quote-syntax mixin-getf))
                           ...))
                     (meta-type-unchecked-accessors
                       #'(\x40;list
                           (\x40;list 'slot :: (quote-syntax ugetf))
                           ...
                           (\x40;list
                             'mixin-slot
                             ::
                             (quote-syntax mixin-ugetf))
                           ...))
                     (meta-type-mutators
                       #'(\x40;list
                           (\x40;list 'slot :: (quote-syntax setf))
                           ...
                           (\x40;list
                             'mixin-slot
                             ::
                             (quote-syntax mixin-setf))
                           ...))
                     ((values map-slot-usetf)
                       (lambda (slot setf rawsetf)
                         (\x40;list
                           'cons
                           `',slot
                           (if (hash-get slot-contract-table (stx-e slot))
                               `(quote-syntax
                                  ,(stx-identifier rawsetf "&" rawsetf))
                               `(quote-syntax ,setf)))))
                     (meta-type-unchecked-mutators
                       (with-syntax ([(slot-usetf ...) (map map-slot-usetf
                                                            #'(slot ...)
                                                            #'(usetf ...)
                                                            #'(rawsetf
                                                                ...))]
                                     [(mixin-slot-usetf ...) (map map-slot-usetf
                                                                  #'(mixin-slot
                                                                      ...)
                                                                  #'(mixin-usetf
                                                                      ...)
                                                                  #'(mixin-rawsetf
                                                                      ...))])
                         #'(\x40;list
                             slot-usetf
                             ...
                             mixin-slot-usetf
                             ...)))
                     (defmeta
                       (wrap
                         #'(defsyntax
                             type
                             (make-class-type-info id: meta-type-id name:
                              meta-type-name slots: meta-type-slots
                              ordered-slots: meta-type-ordered-slots super:
                              meta-type-super struct?: meta-type-struct?
                              final?: meta-type-final? metaclass:
                              meta-type-metaclass constructor-method:
                              meta-type-constructor-method type-descriptor:
                              meta-type-descriptor constructor:
                              meta-type-constructor predicate:
                              meta-type-predicate accessors:
                              meta-type-accessors mutators:
                              meta-type-mutators unchecked-accessors:
                              meta-type-unchecked-accessors
                              unchecked-mutators:
                              meta-type-unchecked-mutators slot-types:
                              meta-type-slot-types slot-contracts:
                              meta-type-slot-contracts slot-defaults:
                              meta-type-slot-defaults))))
                     (defmake
                       (cond
                         [(or (not (null? type-constructor))
                              (and (zero?
                                     (hash-length slot-contract-table))
                                   (zero?
                                     (hash-length slot-default-table)))
                              metaclass)
                          #'(begin)]
                         [(and struct?
                               (zero? (hash-length slot-default-table)))
                          (with-syntax ([contract (foldr
                                                    (lambda (slot r)
                                                      (cond
                                                        [(hash-get
                                                           slot-contract-table
                                                           (stx-e slot)) =>
                                                         (lambda (contract)
                                                           (with-syntax ([slot slot]
                                                                         [(contract
                                                                            ...) contract])
                                                             (cons
                                                               #'(slot
                                                                   contract
                                                                   ...)
                                                               r)))]
                                                        [else
                                                         (cons slot r)]))
                                                    (\x40;list)
                                                    #'(ordered-slot ...))]
                                        [type::t (core-quote-syntax
                                                   #'type::t)])
                            (wrap
                              #'(def/c
                                  (make-type . contract)
                                  =>
                                  type
                                  (begin-annotation
                                    (\x40;type type::t)
                                    (\x23;\x23;structure
                                      type::t
                                      ordered-slot
                                      ...)))))]
                         [else
                          (with-syntax ([contract (foldr
                                                    (lambda (slot r)
                                                      (let (default
                                                            [hash-get slot-default-table
                                                              (stx-e
                                                                slot)])
                                                        (cond
                                                          [(hash-get
                                                             slot-contract-table
                                                             (stx-e slot)) =>
                                                           (lambda (contract)
                                                             (with-syntax ([slot slot]
                                                                           [(contract
                                                                              ...) contract]
                                                                           [(default
                                                                              ...) (if default
                                                                                       (\x40;list
                                                                                         ':=
                                                                                         default)
                                                                                       (\x40;list))])
                                                               (cons*
                                                                 (symbol->keyword
                                                                   (stx-e
                                                                     #'slot))
                                                                 #'(slot
                                                                     contract
                                                                     ...
                                                                     default
                                                                     ...)
                                                                 r)))]
                                                          [else
                                                           (cons*
                                                             (symbol->keyword
                                                               (stx-e
                                                                 slot))
                                                             (\x40;list
                                                               slot
                                                               default)
                                                             r)])))
                                                    (\x40;list)
                                                    #'(ordered-slot ...))]
                                        [type::t (core-quote-syntax
                                                   #'type::t)])
                            (wrap
                              #'(def/c
                                  (make-type . contract)
                                  =>
                                  type
                                  (begin-annotation
                                    (\x40;type type::t)
                                    (\x23;\x23;structure
                                      type::t
                                      ordered-slot
                                      ...)))))]))
                     ((defsetf ...)
                       (filter
                         identity
                         (map (lambda (slot setf rawsetf)
                                (alet
                                  (contract
                                    (hash-get
                                      slot-contract-table
                                      (stx-e slot)))
                                  (with-syntax ([slot-spec (cons
                                                             slot
                                                             contract)]
                                                [slot slot]
                                                [setf setf]
                                                [usetf (stx-identifier
                                                         rawsetf
                                                         "&"
                                                         rawsetf)])
                                    (wrap
                                      #'(def/c
                                          (setf ($obj : type) slot-spec)
                                          =>
                                          :void
                                          (usetf $obj slot))))))
                              #'(slot ...)
                              #'(setf ...)
                              #'(rawsetf ...)))))
                    #'(begin defklass defmeta defmake defsetf ...))))))))
      (syntax-case stx ()
        [(_ hd (slot ...) . body)
         (generate #'hd #'(slot ...) #'body)])))
  (define-syntax defstruct/c
    (syntax-rules ()
      [(defstruct/c hd slots . body)
       (defclass/c hd slots struct: #t . body)]))
  (define-syntax do/c
    (lambda (stx)
      (syntax-case stx ()
        [(_ ((var/c init step ...) ...) (test fini ...) body ...)
         (with-syntax ([(var ...) (map (lambda (b)
                                         (if (identifier? b)
                                             b
                                             (stx-car b)))
                                       #'(var/c ...))])
           #'(let/c
               $loop
               ((var/c init) ...)
               (if test
                   (do-loop-result fini ...)
                   (let ()
                     body
                     ...
                     ($loop (do-loop-step var step ...) ...)))))])))
  (define-syntax do-loop-result
    (syntax-rules ()
      [(_) (%%void)]
      [(_ expr) expr]
      [(_ expr rest ...) (begin expr rest ...)]))
  (define-syntax do-loop-step
    (syntax-rules ()
      [(_ var) var]
      [(_ var expr) expr]
      [(_ var expr rest ...) (begin expr rest ...)]))
  (define-syntax do-while/c
    (lambda (stx)
      (syntax-case stx ()
        [(_ ((var/c init step ...) ...) (test fini ...) body ...)
         (with-syntax ([(var ...) (map (lambda (b)
                                         (if (identifier? b)
                                             b
                                             (stx-car b)))
                                       #'(var/c ...))])
           #'(let/c $loop ((var/c init) ...) body ...
               (if test
                   ($loop (do-loop-step var step ...) ...)
                   (do-loop-result fini ...))))])))
  (define-syntax defmutable*
    (lambda (stx)
      (syntax-case stx ()
        [(_ var value ~ . contract)
         (and (identifier? #'var)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':?)
                  (free-identifier=? #'~ #':~)))
         (with-syntax ([__var (stx-identifier #'var "__" #'var)]
                       [var-set! (stx-identifier #'var #'var "-set!")])
           #'(begin
               (def __var value)
               (def (var) __var)
               (def/c
                 (var-set! (new-value ~ . contract))
                 (set! __var new-value))))]
        [(_ var value) #'(defmutable* var value : :t)])))
  (define-syntax defmutable
    (lambda (stx)
      (syntax-case stx ()
        [(_ var value ~ . contract)
         (and (identifier? #'var)
              (identifier? #'~)
              (or (free-identifier=? #'~ #':)
                  (free-identifier=? #'~ #':?)
                  (free-identifier=? #'~ #':~)))
         (with-syntax ([__var (stx-identifier #'var "__" #'var)]
                       [var-set! (stx-identifier #'var #'var "-set!")])
           #'(begin
               (def __var value)
               (def/c
                 (var-set! (new-value ~ . contract))
                 (set! __var new-value))
               (defsyntax
                 var
                 (identifier-rules (set! %%set-dotted!)
                   ((set! the-var new-value) (var-set! new-value))
                   ((%%set-dotted! the-var new-value) (var-set! new-value))
                   (the-var (identifier? #'the-var) __var)
                   ((the-var arg (... ...)) (__var arg (... ...)))))))]
        [(_ var value) #'(defmutable var value : :t)]))))

