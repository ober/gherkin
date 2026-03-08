(define type-flag-opaque 1)

(define type-flag-extensible 2)

(define type-flag-macros 4)

(define type-flag-concrete 8)

(define type-flag-id 16)

(define class-type-flag-struct 1024)

(define class-type-flag-sealed 2048)

(define class-type-flag-metaclass 4096)

(define class-type-flag-system 8192)

(define t::t
  (let ([flags (\x23;\x23;fxior
                 type-flag-extensible
                 type-flag-id
                 class-type-flag-system)]
        [properties (cons
                      (cons 'direct-slots: '())
                      (cons (cons 'system: '#t) '()))]
        [slot-table (make-symbolic-table #f 0)])
    (\x23;\x23;structure #f 't 't flags #f '#() (list) '#(#f)
      slot-table properties #f #f)))

(define class::t
  (let* ([slots '(id name super flags fields precedence-list slot-vector
                     slot-table properties constructor methods)])
    (let* ([slot-vector (list->vector (cons #f slots))])
      (let* ([slot-table (let ([slot-table (make-symbolic-table
                                             #f
                                             0)])
                           (for-each
                             (lambda (slot field)
                               (symbolic-table-set! slot-table slot field)
                               (symbolic-table-set!
                                 slot-table
                                 (symbol->keyword slot)
                                 field))
                             slots
                             (iota (length slots) 1))
                           slot-table)])
        (let* ([flags (\x23;\x23;fxior
                        type-flag-extensible
                        type-flag-concrete
                        type-flag-id
                        class-type-flag-struct)])
          (let* ([fields (list->vector
                           (apply
                             append
                             (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-30})
                                    (list
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-30}
                                      5
                                      #f))
                                  (drop slots 5))))])
            (let* ([properties `((direct-slots: ,@slots)
                                  (struct: . #t))])
              (let* ([t (\x23;\x23;structure #f 'class 'class flags \x23;\x23;type-type fields
                          (list t::t) slot-vector slot-table properties #f
                          #f)])
                (\x23;\x23;structure-type-set! t t)
                t))))))))

(\x23;\x23;structure-type-set! t::t class::t)

(define object::t
  (let ([flags (\x23;\x23;fxior
                 type-flag-extensible
                 type-flag-id
                 class-type-flag-system)]
        [properties (cons
                      (cons 'direct-slots: '())
                      (cons (cons 'system: '#t) '()))]
        [slot-table (make-symbolic-table #f 0)])
    (\x23;\x23;structure class::t 'object 'object flags #f '#()
      (list t::t) '#(#f) slot-table properties #f #f)))

(define class-type?
  (lambda (obj)
    (\x23;\x23;structure-instance-of? obj 'class)))

(begin
  (define (class-type=? x y)
    (eq? (class-type-id x) (class-type-id y)))
  (define __class-type=? class-type=?))

(define-syntax fxflag-set?
  (syntax-rules ()
    [(_ value flag)
     (\x23;\x23;fx= (\x23;\x23;fxand value flag) flag)]
    [(_ value flag)
     (let (flag flag)
       (\x23;\x23;fx= (\x23;\x23;fxand value flag) flag))]))

(define-syntax fxflag-unset?
  (syntax-rules ()
    [(_ value flag)
     (\x23;\x23;fx= (\x23;\x23;fxand value flag) 0)]
    [(_ value flag)
     (let (flag flag)
       (\x23;\x23;fx= (\x23;\x23;fxand value flag) 0))]))

(begin
  (define (type-opaque? type)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags type)
        type-flag-opaque)
      type-flag-opaque))
  (define __type-opaque? type-opaque?))

(begin
  (define (type-extensible? type)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags type)
        type-flag-extensible)
      type-flag-extensible))
  (define __type-extensible? type-extensible?))

(begin
  (define (class-type-final? type)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags type)
        type-flag-extensible)
      0))
  (define __class-type-final? class-type-final?))

(begin
  (define (class-type-struct? klass)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags klass)
        class-type-flag-struct)
      class-type-flag-struct))
  (define __class-type-struct? class-type-struct?))

(begin
  (define (class-type-sealed? klass)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags klass)
        class-type-flag-sealed)
      class-type-flag-sealed))
  (define __class-type-sealed? class-type-sealed?))

(begin
  (define (class-type-metaclass? klass)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags klass)
        class-type-flag-metaclass)
      class-type-flag-metaclass))
  (define __class-type-metaclass? class-type-metaclass?))

(begin
  (define (class-type-system? klass)
    (\x23;\x23;fx=
      (\x23;\x23;fxand
        (\x23;\x23;type-flags klass)
        class-type-flag-system)
      class-type-flag-system))
  (define __class-type-system? class-type-system?))

(define (make-class-type-descriptor type-id type-name type-super
         precedence-list slot-vector properties constructor
         slot-table methods)
  (define (make-props! key)
    (define ht (make-symbolic-table #f 0))
    (define (put-slots! ht slots)
      (for-each
        (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-31})
          (symbolic-table-set!
            ht
            #{cut-arg dpuuv4a3mobea70icwo8nvdax-31}
            #t))
        slots))
    (define (put-alist! ht key alist)
      (cond
        [(agetq key alist) =>
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-32})
           (put-slots! ht #{cut-arg dpuuv4a3mobea70icwo8nvdax-32}))]))
    (put-alist! ht key properties)
    (for-each
      (lambda (mixin)
        (let ([alist (class-type-properties mixin)])
          (if (or (agetq 'transparent: alist)
                  (eq? #t (agetq key alist)))
              (put-slots! ht (class-type-slot-list mixin))
              (put-alist! ht key alist))))
      precedence-list)
    ht)
  (let* ([transparent? (agetq 'transparent: properties)])
    (let* ([all-slots-printable? (or transparent?
                                     (eq? #t (agetq 'print: properties)))])
      (let* ([printable (and (not all-slots-printable?)
                             (make-props! 'print:))])
        (let* ([all-slots-equalable? (or transparent?
                                         (eq? #t
                                              (agetq
                                                'equal:
                                                properties)))])
          (let* ([equalable (and (not all-slots-equalable?)
                                 (make-props! 'equal:))])
            (let* ([first-new-field (if (class-type? type-super)
                                        (\x23;\x23;vector-length
                                          (class-type-slot-vector
                                            type-super))
                                        1)])
              (let* ([field-info-length (\x23;\x23;fx*
                                          3
                                          (\x23;\x23;fx-
                                            (\x23;\x23;vector-length
                                              slot-vector)
                                            first-new-field))])
                (let* ([field-info (make-vector field-info-length #f)])
                  (let* ([struct? (agetq 'struct: properties)])
                    (let* ([final? (agetq 'final: properties)])
                      (let* ([metaclass (let ([metaclass (agetq
                                                           'metaclass:
                                                           properties)])
                                          (and metaclass
                                               (begin
                                                 (unless (class-type?
                                                           metaclass)
                                                   (error 'gerbil
                                                     "metaclass is not a class type"
                                                     'class:
                                                     type-id
                                                     'metaclass:
                                                     metaclass))
                                                 metaclass)))])
                        (let* ([system? (agetq 'system: properties)])
                          (let* ([opaque? (and (not (or transparent?
                                                        (agetq
                                                          'equal:
                                                          properties)))
                                               (or (not type-super)
                                                   (type-opaque?
                                                     type-super)))])
                            (let* ([type-flags (\x23;\x23;fxior type-flag-id
                                                 type-flag-concrete
                                                 (if final?
                                                     0
                                                     type-flag-extensible)
                                                 (if opaque?
                                                     type-flag-opaque
                                                     0)
                                                 (if struct?
                                                     class-type-flag-struct
                                                     0)
                                                 (if metaclass
                                                     class-type-flag-metaclass
                                                     0)
                                                 (if system?
                                                     class-type-flag-system
                                                     0))])
                              (let* ([precedence-list (cond
                                                        [(memq
                                                           t::t
                                                           precedence-list) =>
                                                         (lambda (tail)
                                                           (if (null?
                                                                 (cdr tail))
                                                               precedence-list
                                                               (error 'gerbil
                                                                 "BUG: t::t is not last in the precedence list"
                                                                 'precedence-list:
                                                                 precedence-list)))]
                                                        [else
                                                         (append
                                                           precedence-list
                                                           (list t::t))])])
                                (let loop ([i first-new-field] [j 0])
                                  (when (\x23;\x23;fx< j field-info-length)
                                    (let* ([slot (\x23;\x23;vector-ref
                                                   slot-vector
                                                   i)])
                                      (let* ([flags (if transparent?
                                                        0
                                                        (\x23;\x23;fxior
                                                          (if (or all-slots-printable?
                                                                  (symbolic-table-ref
                                                                    printable
                                                                    slot
                                                                    #f))
                                                              0
                                                              1)
                                                          (if (or all-slots-equalable?
                                                                  (symbolic-table-ref
                                                                    equalable
                                                                    slot
                                                                    #f))
                                                              0
                                                              4)))])
                                        (vector-set! field-info j slot)
                                        (vector-set!
                                          field-info
                                          (\x23;\x23;fx+ j 1)
                                          flags)
                                        (loop
                                          (\x23;\x23;fx+ i 1)
                                          (\x23;\x23;fx+ j 3))))))
                                (if metaclass
                                    (make-instance metaclass type-id type-name
                                      type-flags type-super field-info
                                      precedence-list slot-vector
                                      slot-table properties constructor
                                      methods)
                                    (\x23;\x23;structure class::t type-id type-name type-flags
                                      type-super field-info precedence-list
                                      slot-vector slot-table properties
                                      constructor methods))))))))))))))))))

(define-syntax defrefset
  (lambda (stx)
    (syntax-case stx ()
      [(_ (slot field))
       (with-syntax*
         ((klass::t (core-quote-syntax 'class::t))
           (ref (stx-identifier #'slot "class-type-" #'slot))
           (&ref (stx-identifier #'slot "&" #'ref))
           (setq (stx-identifier #'slot #'ref "-set!"))
           (&setq (stx-identifier #'slot "&" #'setq)))
         #'(begin
             (def ref
                  (begin-annotation
                    (\x40;mop.accessor klass::t slot #t)
                    (lambda (klass)
                      (\x23;\x23;structure-ref
                        klass
                        field
                        class::t
                        'slot))))
             (def &ref
                  (begin-annotation
                    (\x40;mop.accessor klass::t slot #f)
                    (lambda (klass)
                      (\x23;\x23;unchecked-structure-ref
                        klass
                        field
                        class::t
                        'slot))))
             (def setq
                  (begin-annotation
                    (\x40;mop.mutator klass::t slot #t)
                    (lambda (klass val)
                      (\x23;\x23;structure-set! klass val field class::t
                        'slot))))
             (def &setq
                  (begin-annotation
                    (\x40;mop.mutator klass::t slot #f)
                    (lambda (klass val)
                      (\x23;\x23;unchecked-structure-set! klass val field
                        class::t 'slot))))))])))

(define-syntax defrefset*
  (syntax-rules ()
    [(_ (slot field) ...)
     (begin (defrefset (slot field)) ...)]))

(begin
  (begin
    (define (class-type-id klass)
      (\x23;\x23;structure-ref klass 1 class::t 'id))
    (define (&class-type-id klass)
      (\x23;\x23;unchecked-structure-ref klass 1 class::t 'id))
    (define (class-type-id-set! klass val)
      (\x23;\x23;structure-set! klass val 1 class::t 'id))
    (define (&class-type-id-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 1 class::t
        'id)))
  (begin
    (define (class-type-name klass)
      (\x23;\x23;structure-ref klass 2 class::t 'name))
    (define (&class-type-name klass)
      (\x23;\x23;unchecked-structure-ref klass 2 class::t 'name))
    (define (class-type-name-set! klass val)
      (\x23;\x23;structure-set! klass val 2 class::t 'name))
    (define (&class-type-name-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 2 class::t
        'name)))
  (begin
    (define (class-type-flags klass)
      (\x23;\x23;structure-ref klass 3 class::t 'flags))
    (define (&class-type-flags klass)
      (\x23;\x23;unchecked-structure-ref klass 3 class::t 'flags))
    (define (class-type-flags-set! klass val)
      (\x23;\x23;structure-set! klass val 3 class::t 'flags))
    (define (&class-type-flags-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 3 class::t
        'flags)))
  (begin
    (define (class-type-super klass)
      (\x23;\x23;structure-ref klass 4 class::t 'super))
    (define (&class-type-super klass)
      (\x23;\x23;unchecked-structure-ref klass 4 class::t 'super))
    (define (class-type-super-set! klass val)
      (\x23;\x23;structure-set! klass val 4 class::t 'super))
    (define (&class-type-super-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 4 class::t
        'super)))
  (begin
    (define (class-type-fields klass)
      (\x23;\x23;structure-ref klass 5 class::t 'fields))
    (define (&class-type-fields klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        5
        class::t
        'fields))
    (define (class-type-fields-set! klass val)
      (\x23;\x23;structure-set! klass val 5 class::t 'fields))
    (define (&class-type-fields-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 5 class::t
        'fields)))
  (begin
    (define (class-type-precedence-list klass)
      (\x23;\x23;structure-ref klass 6 class::t 'precedence-list))
    (define (&class-type-precedence-list klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        6
        class::t
        'precedence-list))
    (define (class-type-precedence-list-set! klass val)
      (\x23;\x23;structure-set! klass val 6 class::t
        'precedence-list))
    (define (&class-type-precedence-list-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 6 class::t
        'precedence-list)))
  (begin
    (define (class-type-slot-vector klass)
      (\x23;\x23;structure-ref klass 7 class::t 'slot-vector))
    (define (&class-type-slot-vector klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        7
        class::t
        'slot-vector))
    (define (class-type-slot-vector-set! klass val)
      (\x23;\x23;structure-set! klass val 7 class::t
        'slot-vector))
    (define (&class-type-slot-vector-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 7 class::t
        'slot-vector)))
  (begin
    (define (class-type-slot-table klass)
      (\x23;\x23;structure-ref klass 8 class::t 'slot-table))
    (define (&class-type-slot-table klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        8
        class::t
        'slot-table))
    (define (class-type-slot-table-set! klass val)
      (\x23;\x23;structure-set! klass val 8 class::t 'slot-table))
    (define (&class-type-slot-table-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 8 class::t
        'slot-table)))
  (begin
    (define (class-type-properties klass)
      (\x23;\x23;structure-ref klass 9 class::t 'properties))
    (define (&class-type-properties klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        9
        class::t
        'properties))
    (define (class-type-properties-set! klass val)
      (\x23;\x23;structure-set! klass val 9 class::t 'properties))
    (define (&class-type-properties-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 9 class::t
        'properties)))
  (begin
    (define (class-type-constructor klass)
      (\x23;\x23;structure-ref klass 10 class::t 'constructor))
    (define (&class-type-constructor klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        10
        class::t
        'constructor))
    (define (class-type-constructor-set! klass val)
      (\x23;\x23;structure-set! klass val 10 class::t
        'constructor))
    (define (&class-type-constructor-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 10 class::t
        'constructor)))
  (begin
    (define (class-type-methods klass)
      (\x23;\x23;structure-ref klass 11 class::t 'methods))
    (define (&class-type-methods klass)
      (\x23;\x23;unchecked-structure-ref
        klass
        11
        class::t
        'methods))
    (define (class-type-methods-set! klass val)
      (\x23;\x23;structure-set! klass val 11 class::t 'methods))
    (define (&class-type-methods-set! klass val)
      (\x23;\x23;unchecked-structure-set! klass val 11 class::t
        'methods))))

(begin
  (define (class-type-slot-list klass)
    (cdr (vector->list (class-type-slot-vector klass))))
  (define __class-type-slot-list class-type-slot-list))

(begin
  (define (class-type-field-count klass)
    (\x23;\x23;fx-
      (\x23;\x23;vector-length (class-type-slot-vector klass))
      1))
  (define __class-type-field-count class-type-field-count))

(begin
  (define (class-type-seal! klass)
    (\x23;\x23;unchecked-structure-set! klass
      (\x23;\x23;fxior
        class-type-flag-sealed
        (\x23;\x23;type-flags klass))
      3 class::t class-type-seal!)
    (void))
  (define __class-type-seal! class-type-seal!))

(begin
  (define (substruct? maybe-sub-struct maybe-super-struct)
    (let ([maybe-super-struct-id (\x23;\x23;type-id
                                   maybe-super-struct)])
      (let lp ([super-struct maybe-sub-struct])
        (cond
          [(not super-struct) #f]
          [(eq? maybe-super-struct-id
                (\x23;\x23;type-id super-struct))
           #t]
          [else (lp (\x23;\x23;type-super super-struct))]))))
  (define __substruct? substruct?))

(define (base-struct/1 klass)
  (cond
    [(class-type? klass)
     (if (class-type-struct? klass)
         klass
         (\x23;\x23;type-super klass))]
    [(not klass) #f]
    [else (error 'gerbil "not a class or false" klass)]))

(define (base-struct/2 klass1 klass2)
  (let ([s1 (base-struct/1 klass1)]
        [s2 (base-struct/1 klass2)])
    (cond
      [(or (not s1) (and s2 (substruct? s1 s2))) s2]
      [(or (not s2) (and s1 (substruct? s2 s1))) s1]
      [else
       (error 'gerbil
         "bad mixin: incompatible struct bases"
         klass1
         klass2
         s1
         s2)])))

(define (base-struct/list all-supers)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-33} all-supers])
    (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-33})
        (begin #f)
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-33})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-34} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-35} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
              (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-34}])
                (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-35})
                    (begin (base-struct/1 x))
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-36} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-37} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                          (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-36}])
                            (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-37})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-38} (car #{tl dpuuv4a3mobea70icwo8nvdax-37})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-39} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-37})])
                                  (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-38}])
                                    (if (null?
                                          #{tl dpuuv4a3mobea70icwo8nvdax-39})
                                        (begin (base-struct/2 x y))
                                        (if (pair?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                                              (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                                                (if (pair?
                                                      #{tl dpuuv4a3mobea70icwo8nvdax-41})
                                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                                          [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                                                      (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                                        (if (pair?
                                                              #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                                              (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                                                (if (null?
                                                                      #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                                                    (begin
                                                                      (fold-right
                                                                        base-struct/2
                                                                        x
                                                                        y))
                                                                    (error 'match
                                                                      "no matching clause"
                                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                                            (error 'match
                                                              "no matching clause"
                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                                    (error 'match
                                                      "no matching clause"
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33})))))
                                (if (pair?
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                                      (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                                        (if (pair?
                                              #{tl dpuuv4a3mobea70icwo8nvdax-41})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                                              (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                                (if (pair?
                                                      #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                                          [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                                      (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                                        (if (null?
                                                              #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                                            (begin
                                                              (fold-right
                                                                base-struct/2
                                                                x
                                                                y))
                                                            (error 'match
                                                              "no matching clause"
                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                                    (error 'match
                                                      "no matching clause"
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                    (error 'match
                                      "no matching clause"
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33})))))
                        (if (pair?
                              #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                              (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                                (if (pair?
                                      #{tl dpuuv4a3mobea70icwo8nvdax-41})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                                      (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                        (if (pair?
                                              #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                              (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                                (if (null?
                                                      #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                                    (begin
                                                      (fold-right
                                                        base-struct/2
                                                        x
                                                        y))
                                                    (error 'match
                                                      "no matching clause"
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                    (error 'match
                                      "no matching clause"
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                            (error 'match
                              "no matching clause"
                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))))
            (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-36} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                      [#{tl dpuuv4a3mobea70icwo8nvdax-37} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                  (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-36}])
                    (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-37})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-38} (car #{tl dpuuv4a3mobea70icwo8nvdax-37})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-39} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-37})])
                          (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-38}])
                            (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-39})
                                (begin (base-struct/2 x y))
                                (if (pair?
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                                      (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                                        (if (pair?
                                              #{tl dpuuv4a3mobea70icwo8nvdax-41})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                                              (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                                (if (pair?
                                                      #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                                          [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                                      (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                                        (if (null?
                                                              #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                                            (begin
                                                              (fold-right
                                                                base-struct/2
                                                                x
                                                                y))
                                                            (error 'match
                                                              "no matching clause"
                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                                    (error 'match
                                                      "no matching clause"
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                    (error 'match
                                      "no matching clause"
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33})))))
                        (if (pair?
                              #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                              (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                                (if (pair?
                                      #{tl dpuuv4a3mobea70icwo8nvdax-41})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                                      (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                        (if (pair?
                                              #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                              (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                                (if (null?
                                                      #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                                    (begin
                                                      (fold-right
                                                        base-struct/2
                                                        x
                                                        y))
                                                    (error 'match
                                                      "no matching clause"
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                    (error 'match
                                      "no matching clause"
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                            (error 'match
                              "no matching clause"
                              #{match-val dpuuv4a3mobea70icwo8nvdax-33})))))
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-33})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-40} (car #{match-val dpuuv4a3mobea70icwo8nvdax-33})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-41} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-33})])
                      (let ([x #{hd dpuuv4a3mobea70icwo8nvdax-40}])
                        (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-41})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-42} (car #{tl dpuuv4a3mobea70icwo8nvdax-41})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-43} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-41})])
                              (let ([y #{hd dpuuv4a3mobea70icwo8nvdax-42}])
                                (if (pair?
                                      #{tl dpuuv4a3mobea70icwo8nvdax-43})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-44} (car #{tl dpuuv4a3mobea70icwo8nvdax-43})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-45} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-43})])
                                      (let ([... #{hd dpuuv4a3mobea70icwo8nvdax-44}])
                                        (if (null?
                                              #{tl dpuuv4a3mobea70icwo8nvdax-45})
                                            (begin
                                              (fold-right
                                                base-struct/2
                                                x
                                                y))
                                            (error 'match
                                              "no matching clause"
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                                    (error 'match
                                      "no matching clause"
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                            (error 'match
                              "no matching clause"
                              #{match-val dpuuv4a3mobea70icwo8nvdax-33}))))
                    (error 'match
                      "no matching clause"
                      #{match-val dpuuv4a3mobea70icwo8nvdax-33})))))))

(define (base-struct . all-supers)
  (base-struct/list all-supers))

(define (find-super-constructor super)
  (let lp ([rest super] [constructor #f])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-46} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-46})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-47} (car #{match-val dpuuv4a3mobea70icwo8nvdax-46})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-48} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-46})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-47}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-48}])
                (begin
                  (cond
                    [(&class-type-constructor hd) =>
                     (lambda (xconstructor)
                       (if (or (not constructor)
                               (eq? constructor xconstructor))
                           (lp rest xconstructor)
                           (error 'gerbil
                             "conflicting implicit constructors"
                             constructor
                             xconstructor)))]
                    [else (lp rest constructor)])))))
          (begin constructor)))))

(define (compute-class-slots class-precedence-list
         direct-slots)
  (let* ([next-slot 1])
    (let* ([slot-table (make-symbolic-table #f 0)])
      (let* ([r-slots '(__class)])
        (let* ([process-slot (lambda (slot)
                               (unless (symbol? slot)
                                 (error 'gerbil "invalid slot name" slot))
                               (when (eq? (symbolic-table-ref
                                            slot-table
                                            slot
                                            absent-value)
                                          absent-value)
                                 (symbolic-table-set!
                                   slot-table
                                   slot
                                   next-slot)
                                 (symbolic-table-set!
                                   slot-table
                                   (symbol->keyword slot)
                                   next-slot)
                                 (set! r-slots (cons slot r-slots))
                                 (set! next-slot
                                   (\x23;\x23;fx+ next-slot 1))))])
          (let* ([process-slots (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-49})
                                  (for-each
                                    process-slot
                                    #{cut-arg dpuuv4a3mobea70icwo8nvdax-49}))])
            (for-each
              (lambda (mixin)
                (process-slots
                  (agetq
                    'direct-slots:
                    (&class-type-properties mixin)
                    (list))))
              (reverse class-precedence-list))
            (process-slots direct-slots)
            (let ([slot-vector (list->vector (reverse r-slots))])
              (values slot-vector slot-table))))))))

(begin
  (define (make-class-type id name direct-supers direct-slots
           properties constructor)
    (cond
      [(find
         (lambda (#{$obj dpuuv4a3mobea70icwo8nvdax-50})
           (not (class-type? #{$obj dpuuv4a3mobea70icwo8nvdax-50})))
         direct-supers) =>
       (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-51})
         (error 'gerbil
           "Illegal super class; not a class descriptor"
           #{cut-arg dpuuv4a3mobea70icwo8nvdax-51}))]
      [(find __class-type-final? direct-supers) =>
       (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-52})
         (error 'gerbil
           "Cannot extend final class"
           #{cut-arg dpuuv4a3mobea70icwo8nvdax-52}))])
    (call-with-values
      (lambda () (compute-precedence-list direct-supers))
      (lambda (precedence-list struct-super)
        (call-with-values
          (lambda ()
            (compute-class-slots precedence-list direct-slots))
          (lambda (slot-vector slot-table)
            (let* ([properties (cons*
                                 (cons* 'direct-slots: direct-slots)
                                 (cons* 'direct-supers: direct-supers)
                                 properties)])
              (let* ([constructor* (or constructor
                                       (find-super-constructor
                                         direct-supers))])
                (let* ([precedence-list (if (or (agetq 'system: properties)
                                                (memq
                                                  object::t
                                                  precedence-list))
                                            precedence-list
                                            (let loop ([tail precedence-list]
                                                       [head (list)])
                                              (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-53} tail])
                                                (if (pair?
                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-53})
                                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-54} (car #{match-val dpuuv4a3mobea70icwo8nvdax-53})]
                                                          [#{tl dpuuv4a3mobea70icwo8nvdax-55} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-53})])
                                                      (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-54}])
                                                        (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-55}])
                                                          (begin
                                                            (if (eq? hd
                                                                     t::t)
                                                                (let ([#{f dpuuv4a3mobea70icwo8nvdax-56} cons])
                                                                  (fold-left
                                                                    (lambda (#{a dpuuv4a3mobea70icwo8nvdax-57}
                                                                             #{e dpuuv4a3mobea70icwo8nvdax-58})
                                                                      (#{f dpuuv4a3mobea70icwo8nvdax-56}
                                                                        #{e dpuuv4a3mobea70icwo8nvdax-58}
                                                                        #{a dpuuv4a3mobea70icwo8nvdax-57}))
                                                                    (cons
                                                                      object::t
                                                                      tail)
                                                                    head))
                                                                (loop
                                                                  rest
                                                                  (cons
                                                                    hd
                                                                    head)))))))
                                                    (begin
                                                      (let ([#{f dpuuv4a3mobea70icwo8nvdax-59} cons])
                                                        (fold-left
                                                          (lambda (#{a dpuuv4a3mobea70icwo8nvdax-60}
                                                                   #{e dpuuv4a3mobea70icwo8nvdax-61})
                                                            (#{f dpuuv4a3mobea70icwo8nvdax-59}
                                                              #{e dpuuv4a3mobea70icwo8nvdax-61}
                                                              #{a dpuuv4a3mobea70icwo8nvdax-60}))
                                                          (list
                                                            object::t
                                                            t::t)
                                                          head)))))))])
                  (make-class-type-descriptor id name struct-super precedence-list slot-vector
                    properties constructor* slot-table #f)))))))))
  (define __make-class-type make-class-type))

(begin
  (define (class-precedence-list klass)
    (cons klass (&class-type-precedence-list klass)))
  (define __class-precedence-list class-precedence-list))

(define (compute-precedence-list direct-supers)
  (c4-linearize (list) direct-supers class-precedence-list
    class-type-struct? eq? \x23;\x23;type-name))

(begin
  (define (make-class-predicate klass)
    (let ([tid (\x23;\x23;type-id klass)])
      (cond
        [(class-type-final? klass)
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-62})
           (\x23;\x23;structure-direct-instance-of?
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-62}
             tid))]
        [(class-type-struct? klass)
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-63})
           (\x23;\x23;structure-instance-of?
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-63}
             tid))]
        [else
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-64})
           (class-instance?
             klass
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-64}))])))
  (define __make-class-predicate make-class-predicate))

(define-syntax if-class-slot-field
  (syntax-rules ()
    [(_ klass slot if-final if-struct if-struct-field
        if-class-slot)
     (let (field
           [symbolic-table-ref (&class-type-slot-table klass) slot #f])
       (cond
         [(not field)
          (abort! (error "unknown slot" class: klass slot: slot))]
         [(class-type-final? klass) (if-final klass slot field)]
         [(class-type-struct? klass) (if-struct klass slot field)]
         [(let (strukt [base-struct/1 klass])
            (and (class-type? strukt)
                 (\x23;\x23;fx<
                   field
                   (\x23;\x23;vector-length
                     (&class-type-slot-vector strukt)))))
          (if-struct-field klass slot field)]
         [else (if-class-slot klass slot field)]))]))

(begin
  (define (make-class-slot-accessor klass slot)
    (let ([field (symbolic-table-ref
                   (&class-type-slot-table klass)
                   slot
                   #f)])
      (cond
        [(not field)
         (abort!
           (error 'gerbil "unknown slot" 'class: klass 'slot: slot))]
        [(class-type-final? klass)
         (make-final-slot-accessor klass slot field)]
        [(class-type-struct? klass)
         (make-struct-slot-accessor klass slot field)]
        [(let ([strukt (base-struct/1 klass)])
           (and (class-type? strukt)
                (\x23;\x23;fx<
                  field
                  (\x23;\x23;vector-length
                    (&class-type-slot-vector strukt)))))
         (make-struct-subclass-slot-accessor klass slot field)]
        [else (make-class-cached-slot-accessor klass slot field)])))
  (define __make-class-slot-accessor
    make-class-slot-accessor))

(begin
  (define (make-class-slot-mutator klass slot)
    (let ([field (symbolic-table-ref
                   (&class-type-slot-table klass)
                   slot
                   #f)])
      (cond
        [(not field)
         (abort!
           (error 'gerbil "unknown slot" 'class: klass 'slot: slot))]
        [(class-type-final? klass)
         (make-final-slot-mutator klass slot field)]
        [(class-type-struct? klass)
         (make-struct-slot-mutator klass slot field)]
        [(let ([strukt (base-struct/1 klass)])
           (and (class-type? strukt)
                (\x23;\x23;fx<
                  field
                  (\x23;\x23;vector-length
                    (&class-type-slot-vector strukt)))))
         (make-struct-subclass-slot-mutator klass slot field)]
        [else (make-class-cached-slot-mutator klass slot field)])))
  (define __make-class-slot-mutator make-class-slot-mutator))

(begin
  (define (make-class-slot-unchecked-accessor klass slot)
    (let ([field (symbolic-table-ref
                   (&class-type-slot-table klass)
                   slot
                   #f)])
      (cond
        [(not field)
         (abort!
           (error 'gerbil "unknown slot" 'class: klass 'slot: slot))]
        [(class-type-final? klass)
         (make-struct-slot-unchecked-accessor klass slot field)]
        [(class-type-struct? klass)
         (make-struct-slot-unchecked-accessor klass slot field)]
        [(let ([strukt (base-struct/1 klass)])
           (and (class-type? strukt)
                (\x23;\x23;fx<
                  field
                  (\x23;\x23;vector-length
                    (&class-type-slot-vector strukt)))))
         (make-struct-slot-unchecked-accessor klass slot field)]
        [else
         (make-class-cached-slot-unchecked-accessor
           klass
           slot
           field)])))
  (define __make-class-slot-unchecked-accessor
    make-class-slot-unchecked-accessor))

(begin
  (define (make-class-slot-unchecked-mutator klass slot)
    (let ([field (symbolic-table-ref
                   (&class-type-slot-table klass)
                   slot
                   #f)])
      (cond
        [(not field)
         (abort!
           (error 'gerbil "unknown slot" 'class: klass 'slot: slot))]
        [(class-type-final? klass)
         (make-struct-slot-unchecked-mutator klass slot field)]
        [(class-type-struct? klass)
         (make-struct-slot-unchecked-mutator klass slot field)]
        [(let ([strukt (base-struct/1 klass)])
           (and (class-type? strukt)
                (\x23;\x23;fx<
                  field
                  (\x23;\x23;vector-length
                    (&class-type-slot-vector strukt)))))
         (make-struct-slot-unchecked-mutator klass slot field)]
        [else
         (make-class-cached-slot-unchecked-mutator
           klass
           slot
           field)])))
  (define __make-class-slot-unchecked-mutator
    make-class-slot-unchecked-mutator))

(define not-an-instance
  (case-lambda
    [(object class)
     (let* ([slot #f])
       (apply error "not an instance" 'object: object 'class: class
         (if slot (list 'slot: slot) (list))))]
    [(object class slot)
     (apply error "not an instance" 'object: object 'class: class
       (if slot (list 'slot: slot) (list)))]))

(define (make-final-slot-accessor klass slot field)
  (lambda (obj)
    (\x23;\x23;direct-structure-ref obj field klass slot)))

(define (make-final-slot-mutator klass slot field)
  (lambda (obj val)
    (\x23;\x23;direct-structure-set! obj val field klass slot)))

(define (make-struct-slot-accessor klass slot field)
  (lambda (obj)
    (\x23;\x23;structure-ref obj field klass slot)))

(define (make-struct-slot-mutator klass slot field)
  (lambda (obj val)
    (\x23;\x23;structure-set! obj val field klass slot)))

(define (make-struct-slot-unchecked-accessor klass slot
         field)
  (lambda (obj)
    (\x23;\x23;unchecked-structure-ref obj field klass slot)))

(define (make-struct-slot-unchecked-mutator klass slot
         field)
  (lambda (obj val)
    (\x23;\x23;unchecked-structure-set! obj val field klass
      slot)))

(define (make-struct-subclass-slot-accessor klass slot
         field)
  (lambda (obj)
    (if (class-instance? klass obj)
        (unchecked-slot-ref obj field)
        (not-an-instance obj klass slot))))

(define (make-struct-subclass-slot-mutator klass slot field)
  (lambda (obj val)
    (if (class-instance? klass obj)
        (unchecked-field-set! obj field val)
        (not-an-instance obj klass slot))))

(define (make-class-cached-slot-accessor klass slot field)
  (lambda (obj)
    (cond
      [(direct-instance? klass obj)
       (unchecked-field-ref obj field)]
      [(class-instance? klass obj) (unchecked-slot-ref obj slot)]
      [else (not-an-instance obj klass slot)])))

(define (make-class-cached-slot-mutator klass slot field)
  (lambda (obj val)
    (cond
      [(direct-instance? klass obj)
       (unchecked-field-set! obj field val)]
      [(class-instance? klass obj)
       (unchecked-slot-set! obj slot val)]
      [else (not-an-instance obj klass slot)])))

(define (make-class-cached-slot-unchecked-accessor klass
         slot field)
  (lambda (obj)
    (if (direct-instance? klass obj)
        (unchecked-field-ref obj field)
        (unchecked-slot-ref obj slot))))

(define (make-class-cached-slot-unchecked-mutator klass slot
         field)
  (lambda (obj val)
    (if (direct-instance? klass obj)
        (unchecked-field-set! obj field val)
        (unchecked-slot-set! obj slot val))))

(begin
  (define (class-slot-offset klass slot)
    (symbolic-table-ref (&class-type-slot-table klass) slot #f))
  (define __class-slot-offset class-slot-offset))

(begin
  (define (class-slot-ref klass obj slot)
    (if (class-instance? klass obj)
        (let ([off (class-slot-offset
                     (\x23;\x23;structure-type obj)
                     slot)])
          (\x23;\x23;unchecked-structure-ref obj off klass slot))
        (not-an-instance obj klass)))
  (define __class-slot-ref class-slot-ref))

(begin
  (define (class-slot-set! klass obj slot val)
    (if (class-instance? klass obj)
        (let ([off (class-slot-offset
                     (\x23;\x23;structure-type obj)
                     slot)])
          (\x23;\x23;unchecked-structure-set! obj val off klass slot))
        (not-an-instance obj klass)))
  (define __class-slot-set! class-slot-set!))

(define (unchecked-field-ref obj off)
  (\x23;\x23;unchecked-structure-ref obj off #f #f))

(define (unchecked-field-set! obj off val)
  (\x23;\x23;unchecked-structure-set! obj val off #f #f))

(define (unchecked-slot-ref obj slot)
  (unchecked-field-ref
    obj
    (__class-slot-offset (\x23;\x23;structure-type obj) slot)))

(define (unchecked-slot-set! obj slot val)
  (unchecked-field-set!
    obj
    (__class-slot-offset (\x23;\x23;structure-type obj) slot)
    val))

(define-syntax __slot-e
  (syntax-rules ()
    [(_ obj slot K E)
     (let (klass [class-of obj])
       (cond
         [(class-slot-offset klass slot) => K]
         [else (E obj slot)]))]))

(begin
  (define slot-ref
    (case-lambda
      [(obj slot)
       (let* ([E __slot-error])
         (let ([klass (class-of obj)])
           (cond
             [(class-slot-offset klass slot) =>
              (lambda (off) (unchecked-field-ref obj off))]
             [else (E obj slot)])))]
      [(obj slot E)
       (let ([klass (class-of obj)])
         (cond
           [(class-slot-offset klass slot) =>
            (lambda (off) (unchecked-field-ref obj off))]
           [else (E obj slot)]))]))
  (define __slot-ref slot-ref))

(begin
  (define slot-set!
    (case-lambda
      [(obj slot val)
       (let* ([E __slot-error])
         (let ([klass (class-of obj)])
           (cond
             [(class-slot-offset klass slot) =>
              (lambda (off) (unchecked-field-set! obj off val))]
             [else (E obj slot)])))]
      [(obj slot val E)
       (let ([klass (class-of obj)])
         (cond
           [(class-slot-offset klass slot) =>
            (lambda (off) (unchecked-field-set! obj off val))]
           [else (E obj slot)]))]))
  (define __slot-set! slot-set!))

(define (__slot-error obj slot)
  (error 'gerbil "Cannot find slot" 'object: obj 'slot: slot))

(begin
  (define (subclass? maybe-sub-class maybe-super-class)
    (let ([maybe-super-class-id (\x23;\x23;type-id
                                  maybe-super-class)])
      (or (eq? maybe-super-class-id
               (\x23;\x23;type-id maybe-sub-class))
          (ormap
            (lambda (super-class)
              (eq? (\x23;\x23;type-id super-class) maybe-super-class-id))
            (&class-type-precedence-list maybe-sub-class)))))
  (define __subclass? subclass?))

(define (object? o)
  (and (\x23;\x23;structure? o)
       (class-type? (\x23;\x23;structure-type o))))

(define (object-type o)
  (if (\x23;\x23;structure? o)
      (let ([klass (\x23;\x23;structure-type o)])
        (if (class-type? klass)
            klass
            (abort! (error 'gerbil "not an object" o klass))))
      (abort! (error 'gerbil "not an object" o))))

(begin
  (define (direct-instance? klass obj)
    (\x23;\x23;structure-direct-instance-of?
      obj
      (\x23;\x23;type-id klass)))
  (define __direct-instance? direct-instance?))

(define (immediate-instance-of? klass obj)
  (and (\x23;\x23;structure? obj)
       (eq? klass (\x23;\x23;structure-type obj))))

(begin
  (define (struct-instance? klass obj)
    (\x23;\x23;structure-instance-of?
      obj
      (\x23;\x23;type-id klass)))
  (define __struct-instance? struct-instance?))

(begin
  (define (class-instance? klass obj)
    (let ([type (class-of obj)]) (subclass? type klass)))
  (define __class-instance? class-instance?))

(begin
  (define (make-object klass k)
    (if (class-type-system? klass)
        (abort!
          (error 'gerbil
            "cannot instantiate system class"
            'class:
            klass))
        (let ([obj (\x23;\x23;make-structure klass k)])
          (object-fill! obj #f))))
  (define __make-object make-object))

(begin
  (define (object-fill! obj fill)
    (let loop ([i (\x23;\x23;fx-
                    (\x23;\x23;structure-length obj)
                    1)])
      (if (\x23;\x23;fx> i 0)
          (begin
            (\x23;\x23;unchecked-structure-set! obj fill i #f #f)
            (loop (\x23;\x23;fx- i 1)))
          obj)))
  (define __object-fill! object-fill!))

(begin
  (define (new-instance klass)
    (make-object
      klass
      (\x23;\x23;vector-length (&class-type-slot-vector klass))))
  (define __new-instance new-instance))

(define (make-instance klass . args)
  (cond
    [(&class-type-constructor klass) =>
     (lambda (kons-id)
       (let ([obj (new-instance klass)])
         (___constructor-init! klass kons-id obj args)
         obj))]
    [(class-type-metaclass? klass)
     (let ([obj (new-instance klass)])
       (__metaclass-instance-init! klass obj args)
       obj)]
    [(not (class-type-struct? klass))
     (let ([obj (new-instance klass)])
       (___class-instance-init! klass obj args)
       obj)]
    [(\x23;\x23;fx=
       (class-type-field-count klass)
       (length args))
     (apply \x23;\x23;structure klass args)]
    [else
     (abort!
       (error 'gerbil
         "arguments don't match object size"
         'class:
         klass
         'slots:
         (class-type-slot-list klass)
         'args:
         args))]))

(define make-class-instance make-instance)

(define (struct-instance-init! obj . args)
  (if (\x23;\x23;fx<
        (length args)
        (\x23;\x23;structure-length obj))
      (___struct-instance-init! obj args)
      (error 'gerbil
        "too many arguments for struct"
        'object:
        obj
        'args:
        args))
  (void))

(define (___struct-instance-init! obj args)
  (let lp ([k 1] [rest args])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-65} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-65})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-66} (car #{match-val dpuuv4a3mobea70icwo8nvdax-65})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-67} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-65})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-66}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-67}])
                (begin
                  (unchecked-field-set! obj k hd)
                  (lp (\x23;\x23;fx+ k 1) rest)))))
          (begin obj)))))

(define (class-instance-init! obj . args)
  (___class-instance-init!
    (\x23;\x23;structure-type obj)
    obj
    args)
  (void))

(define (___class-instance-init! klass obj args)
  (let lp ([rest args])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-68} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-68})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-69} (car #{match-val dpuuv4a3mobea70icwo8nvdax-68})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-70} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-68})])
            (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-69}])
              (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-70})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-71} (car #{tl dpuuv4a3mobea70icwo8nvdax-70})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-72} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-70})])
                    (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-71}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-72}])
                        (begin
                          (cond
                            [(not (keyword? key))
                             (error 'gerbil
                               "non keyword slot initializer"
                               'slot:
                               key)]
                            [(__class-slot-offset klass key) =>
                             (lambda (off)
                               (unchecked-field-set! obj off val)
                               (lp rest))]
                            [else
                             (error 'gerbil
                               "unknown slot"
                               'class:
                               klass
                               'slot:
                               key)])))))
                  (begin
                    (if (null? rest)
                        obj
                        (error 'gerbil
                          "unexpected class initializer arguments"
                          'class:
                          klass
                          'rest:
                          rest))))))
          (begin
            (if (null? rest)
                obj
                (error 'gerbil
                  "unexpected class initializer arguments"
                  'class:
                  klass
                  'rest:
                  rest)))))))

(define (__metaclass-instance-init! klass obj args)
  (apply call-method klass 'instance-init! obj args))

(define (constructor-init! klass kons-id obj . args)
  (___constructor-init! klass kons-id obj args)
  (void))

(define (___constructor-init! klass kons-id obj args)
  (cond
    [(__find-method klass obj kons-id) =>
     (lambda (kons) (apply kons obj args) obj)]
    [else
     (error 'gerbil
       "missing constructor"
       'class:
       klass
       'method:
       kons-id)]))

(begin
  (define (struct-copy struct)
    (\x23;\x23;structure-copy struct))
  (define __struct-copy struct-copy))

(begin
  (define (struct->list obj)
    (let ([len (\x23;\x23;structure-length obj)])
      (let recur ([i 0])
        (if (\x23;\x23;fx< i len)
            (cons
              (\x23;\x23;unchecked-structure-ref obj i #f #f)
              (recur (\x23;\x23;fx+ i 1)))
            (list)))))
  (define __struct->list struct->list))

(begin
  (define (class->list obj)
    (let ([klass (\x23;\x23;structure-type obj)])
      (let ([slot-vector (&class-type-slot-vector klass)])
        (let loop ([index (\x23;\x23;fx-
                            (\x23;\x23;vector-length slot-vector)
                            1)]
                   [plist (list)])
          (if (\x23;\x23;fx< index 1)
              (cons klass plist)
              (let ([slot (\x23;\x23;vector-ref slot-vector index)])
                (loop
                  (\x23;\x23;fx- index 1)
                  (cons*
                    (symbol->keyword slot)
                    (unchecked-field-ref obj index)
                    plist))))))))
  (define __class->list class->list))

(define (call-method obj id . args)
  (cond
    [(method-ref obj id) =>
     (lambda (method)
       (let ([method method]) (apply method obj args)))]
    [else
     (error 'gerbil
       "cannot find method"
       'object:
       obj
       'method:
       id)]))

(begin
  (define (method-ref obj id)
    (find-method (class-of obj) obj id))
  (define __method-ref method-ref))

(define (checked-method-ref obj id)
  (or (method-ref obj id)
      (abort!
        (error 'gerbil "missing method" 'object: obj 'method: id))))

(begin
  (define (bound-method-ref obj id)
    (cond
      [(method-ref obj id) =>
       (lambda (method)
         (let ([method method])
           (lambda args (apply method obj args))))]
      [else #f]))
  (define __bound-method-ref bound-method-ref))

(begin
  (define (checked-bound-method-ref obj id)
    (let ([method (checked-method-ref obj id)])
      (lambda args (apply method obj args))))
  (define __checked-bound-method-ref
    checked-bound-method-ref))

(begin
  (define (find-method klass obj id)
    (cond
      [(direct-method-ref klass obj id)]
      [(class-type-sealed? klass) #f]
      [else (mixin-method-ref klass obj id)]))
  (define __find-method find-method))

(begin
  (define (mixin-find-method mixins obj id)
    (ormap
      (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-73})
        (direct-method-ref
          #{cut-arg dpuuv4a3mobea70icwo8nvdax-73}
          obj
          id))
      mixins))
  (define __mixin-find-method mixin-find-method))

(begin
  (define (direct-method-ref klass obj id)
    (define (metaclass-resolve-method)
      (call-method klass 'direct-method-ref obj id))
    (define (metaclass-resolve-method!)
      (let ([method (metaclass-resolve-method)])
        (symbolic-table-set!
          (&class-type-methods klass)
          id
          (if method 'resolved 'unknown))
        method))
    (cond
      [(&class-type-methods klass) =>
       (lambda (ht)
         (let ([method (symbolic-table-ref ht id #f)])
           (cond
             [(procedure? method) method]
             [(class-type-metaclass? klass)
              (case method
                [(resolved) (metaclass-resolve-method)]
                [(unknown) #f]
                [else (metaclass-resolve-method!)])]
             [else #f])))]
      [(class-type-metaclass? klass)
       (let ([tab (make-symbolic-table #f 0)])
         (&class-type-methods-set! klass tab)
         (metaclass-resolve-method!))]
      [else #f]))
  (define __direct-method-ref direct-method-ref))

(begin
  (define (mixin-method-ref klass obj id)
    (mixin-find-method
      (class-type-precedence-list klass)
      obj
      id))
  (define __mixin-method-ref mixin-method-ref))

(begin
  (define bind-method!
    (case-lambda
      [(klass id proc)
       (let* ([rebind? #f])
         (define (bind! ht)
           (if (and (not rebind?) (symbolic-table-ref ht id #f))
               (error 'gerbil
                 "method already bound"
                 'class:
                 klass
                 'method:
                 id)
               (begin (symbolic-table-set! ht id proc) (void))))
         (cond
           [(class-type? klass)
            (let ([ht (&class-type-methods klass)])
              (if ht
                  (bind! ht)
                  (let ([ht (make-symbolic-table #f 0)])
                    (&class-type-methods-set! klass ht)
                    (bind! ht))))]
           [(\x23;\x23;type? klass)
            (bind-method! (__shadow-class klass) id proc rebind?)]
           [else
            (error 'gerbil
              "bad class; expected class or builtin type"
              klass)]))]
      [(klass id proc rebind?)
       (define (bind! ht)
         (if (and (not rebind?) (symbolic-table-ref ht id #f))
             (error 'gerbil
               "method already bound"
               'class:
               klass
               'method:
               id)
             (begin (symbolic-table-set! ht id proc) (void))))
       (cond
         [(class-type? klass)
          (let ([ht (&class-type-methods klass)])
            (if ht
                (bind! ht)
                (let ([ht (make-symbolic-table #f 0)])
                  (&class-type-methods-set! klass ht)
                  (bind! ht))))]
         [(\x23;\x23;type? klass)
          (bind-method! (__shadow-class klass) id proc rebind?)]
         [else
          (error 'gerbil
            "bad class; expected class or builtin type"
            klass)])]))
  (define __bind-method! bind-method!))

(defspecialized-table make-method-specializer-table method-specializer-table-ref
  method-specializer-table-set!
  __method-specializer-table-set!
  method-specializer-table-update!
  __method-specializer-table-update!
  method-specializer-table-delete! procedure-hash eq?)

(define __method-specializers
  (make-method-specializer-table #f 0))

(define __method-specializers-mx (__make-inline-lock))

(define (bind-specializer! method-proc specializer)
  (__lock-inline! __method-specializers-mx)
  (method-specializer-table-set!
    __method-specializers
    method-proc
    specializer)
  (__unlock-inline! __method-specializers-mx))

(define (__lookup-method-specializer proc)
  (__lock-inline! __method-specializers-mx)
  (let ([specializer (method-specializer-table-ref
                       __method-specializers
                       proc
                       #f)])
    (__unlock-inline! __method-specializers-mx)
    specializer))

(define (__class-specializer-hash-key klass)
  (symbolic-hash (\x23;\x23;type-id klass)))

(defspecialized-table make-class-specializer-table class-specializer-table-ref
  class-specializer-table-set! __class-specializer-table-set!
  class-specializer-table-update!
  __class-specializer-table-update!
  class-specializer-table-delete! __class-specializer-hash-key
  eq?)

(define __class-specializers-mx (__make-inline-lock))

(define __class-specializers
  (make-class-specializer-table #f 0))

(define __class-specializers-key (cons #f #f))

(begin
  (define (specialize-class klass)
    (cond
      [(__lookup-class-specializer klass)]
      [else
       (let ([method-table (___specialize-class klass)])
         (__bind-class-specializer! klass method-table)
         method-table)]))
  (define __specialize-class specialize-class))

(define (__lookup-class-specializer klass)
  (__lock-inline! __class-specializers-mx)
  (let ([method-table (class-specializer-table-ref
                        __class-specializers
                        klass
                        #f)])
    (__unlock-inline! __class-specializers-mx)
    method-table))

(define (__bind-class-specializer! klass method-table)
  (__lock-inline! __class-specializers-mx)
  (class-specializer-table-set!
    __class-specializers
    klass
    method-table)
  (__unlock-inline! __class-specializers-mx))

(define (__specialize-method klass method-table method proc)
  (cond
    [(symbolic-table-ref method-table method #f)]
    [(__lookup-method-specializer proc) =>
     (lambda (specialize)
       (let ([specialized-proc (specialize klass method-table)])
         (symbolic-table-set!
           method-table
           method
           specialized-proc)))]
    [else (symbolic-table-set! method-table method proc)]))

(define (___specialize-class klass)
  (cond
    [(not (class-type? klass))
     (if (\x23;\x23;type? klass)
         (__specialize-class (__shadow-class klass))
         (error 'gerbil "bad class; cannot specialize" klass))]
    [(class-type-metaclass? klass)
     (call-method klass 'specialize-class)]
    [(find
       class-type-metaclass?
       (&class-type-precedence-list klass))
     (error 'gerbil
       "cannot specialize class that extends metaclass without a metaclass"
       klass)]
    [else
     (let ([method-table (make-symbolic-table #f 0)])
       (let loop ([rest (class-precedence-list klass)])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-74} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-74})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-75} (car #{match-val dpuuv4a3mobea70icwo8nvdax-74})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-76} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-74})])
                 (let ([xklass #{hd dpuuv4a3mobea70icwo8nvdax-75}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-76}])
                     (begin
                       (let ([xmethod-table (&class-type-methods xklass)])
                         (and xmethod-table
                              (begin
                                (raw-table-for-each
                                  xmethod-table
                                  (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-77}
                                           #{cut-arg dpuuv4a3mobea70icwo8nvdax-78})
                                    (__specialize-method
                                      klass
                                      method-table
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-77}
                                      #{cut-arg dpuuv4a3mobea70icwo8nvdax-78}))))))
                       (loop rest)))))
               (begin method-table)))))]))

(begin
  (define (seal-class! klass)
    (unless (class-type-sealed? klass)
      (unless (class-type-final? klass)
        (error 'gerbil "cannot seal non-final class" klass))
      (cond
        [(class-type-metaclass? klass)
         (call-method klass 'seal-class!)]
        [(find
           class-type-metaclass?
           (&class-type-precedence-list klass))
         (error 'gerbil
           "cannot seal class that extends metaclass without a metaclass"
           klass)]
        [else
         (let ([method-table (specialize-class klass)])
           (&class-type-methods-set! klass method-table))])
      (class-type-seal! klass)))
  (define __seal-class! seal-class!))

(begin
  (define (next-method subklass obj id)
    (define (find-next-method klass)
      (let lp ([rest (class-precedence-list klass)])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-79} rest])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-79})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-80} (car #{match-val dpuuv4a3mobea70icwo8nvdax-79})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-81} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-79})])
                (let ([klass #{hd dpuuv4a3mobea70icwo8nvdax-80}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-81}])
                    (begin
                      (if (eq? (\x23;\x23;type-id subklass)
                               (\x23;\x23;type-id klass))
                          (mixin-find-method rest obj id)
                          (lp rest))))))
              (begin #f)))))
    (find-next-method (class-of obj)))
  (define __next-method next-method))

(define (call-next-method subklass obj id . args)
  (cond
    [(next-method subklass obj id) =>
     (lambda (methodf) (apply methodf obj args))]
    [else
     (error 'gerbil
       "cannot find next method"
       'object:
       obj
       'method:
       id)]))

(define (write-style we) (values (macro-writeenv-style we)))

(define (write-object we obj)
  (cond
    [(method-ref obj ':wr) => (lambda (method) (method obj we))]
    [else (\x23;\x23;default-wr we obj)]))

(define __shadow-classes (make-symbolic-table #f 0))

(define __shadow-classes-mx (__make-inline-lock))

(define (__shadow-class type)
  (define (shadow-type-id type)
    (make-symbol (\x23;\x23;type-name type) "::t"))
  (define (shadow-type-name type) (\x23;\x23;type-name type))
  (define (make-shadow-class type precedence-list)
    (let* ([super (if (pair? precedence-list)
                      (list (car precedence-list))
                      (list))])
      (let* ([klass (make-class-type (shadow-type-id type) (shadow-type-name type) super
                      (list)
                      (cons*
                        (cons* 'struct: #t)
                        (cons* 'system: #t)
                        (if (type-extensible? type)
                            (list)
                            (list (cons* 'final: #t))))
                      #f)])
        (symbolic-table-set!
          __shadow-classes
          (\x23;\x23;type-id type)
          klass)
        klass)))
  (__lock-inline! __shadow-classes-mx)
  (cond
    [(symbolic-table-ref
       __shadow-classes
       (\x23;\x23;type-id type)
       #f) =>
     (lambda (klass)
       (__unlock-inline! __shadow-classes-mx)
       klass)]
    [else
     (let loop ([super (\x23;\x23;type-super type)]
                [hierarchy (list)])
       (cond
         [(not super)
          (let loop ([rest hierarchy] [precedence-list (list)])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-82} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-82})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-83} (car #{match-val dpuuv4a3mobea70icwo8nvdax-82})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-84} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-82})])
                    (let ([type #{hd dpuuv4a3mobea70icwo8nvdax-83}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-84}])
                        (begin
                          (cond
                            [(symbolic-table-ref
                               __shadow-classes
                               (\x23;\x23;type-id type)
                               #f) =>
                             (lambda (klass)
                               (loop rest (cons klass precedence-list)))]
                            [else
                             (let ([klass (make-shadow-class
                                            type
                                            precedence-list)])
                               (loop
                                 rest
                                 (cons klass precedence-list)))])))))
                  (begin
                    (let ([klass (make-shadow-class type precedence-list)])
                      (__unlock-inline! __shadow-classes-mx)
                      klass)))))]
         [else
          (loop
            (\x23;\x23;type-super super)
            (cons super hierarchy))]))]))

(begin (syntax-error "unsupported compilation target"))

(define __system-classes (make-symbolic-table #f 0))

(define (__system-class id)
  (cond
    [(symbolic-table-ref __system-classes id #f)]
    [else (error 'gerbil "unknown system class" id)]))

(define-syntax defsystem-class
  (syntax-rules ()
    [(_ type id (super ...))
     (def type
          (begin-annotation
            (\x40;mop.system id (super ...))
            (__make-system-class 'id (\x40;list super ...))))]))

(define (__make-system-class id super)
  (let ([klass (make-class-type id id super (list)
                 (cons (cons 'system: '#t) '()) #f)])
    (symbolic-table-set! __system-classes id klass)
    klass))

(define-syntax defshadow-class
  (syntax-rules ()
    [(_ type (super ...) type-expr)
     (def type
          (begin-annotation
            (\x40;mop.system type (super ...))
            (__shadow-class type-expr)))]))

