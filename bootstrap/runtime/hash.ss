(begin
  (define UnboundKeyError::t
    (make-class-type 'gerbil\x23;UnboundKeyError::t 'UnboundKeyError
      (list Error::t) '() '((constructor: . :init!)) '#f))
  (define (UnboundKeyError . args)
    (apply make-UnboundKeyError args))
  (define (UnboundKeyError? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;UnboundKeyError::t))
  (define (make-UnboundKeyError . args)
    (apply make-instance UnboundKeyError::t args)))

(begin
  (define UnboundKeyError:::init! Error:::init!)
  (bind-method!
    UnboundKeyError::t
    ':init!
    UnboundKeyError:::init!))

(define (raise-unbound-key-error where message . irritants)
  (raise
    (UnboundKeyError message 'where: where 'irritants:
      irritants)))

(define unbound-key-error? UnboundKeyError?)

(begin
  (define (HashTable obj) obj)
  (define (HashTable? obj)
    (and (\x23;\x23;structure? obj) #t))
  (define (is-HashTable? obj)
    (and (\x23;\x23;structure? obj) #t))
  (define make-HashTable HashTable)
  (define (try-HashTable obj)
    (if (\x23;\x23;structure? obj) obj #f))
  (define (HashTable-ref obj key default)
    (call-method obj 'ref key default)))

(begin
  (define (Locker obj) obj)
  (define (Locker? obj) (and (\x23;\x23;structure? obj) #t))
  (define (is-Locker? obj)
    (and (\x23;\x23;structure? obj) #t))
  (define make-Locker Locker)
  (define (try-Locker obj)
    (if (\x23;\x23;structure? obj) obj #f))
  (define (Locker-read-lock! obj)
    (call-method obj 'read-lock!)))

(bind-method! __table::t 'HashTable::ref raw-table-ref)

(bind-method! __table::t 'HashTable::set! raw-table-set!)

(bind-method!
  __table::t
  'HashTable::update!
  raw-table-update!)

(bind-method!
  __table::t
  'HashTable::delete!
  raw-table-delete!)

(bind-method!
  __table::t
  'HashTable::for-each
  raw-table-for-each)

(bind-method!
  __table::t
  'HashTable::length
  &raw-table-count)

(bind-method! __table::t 'HashTable::copy raw-table-copy)

(bind-method!
  __table::t
  'HashTable::clear!
  raw-table-clear!)

(bind-method! __gc-table::t 'HashTable::ref gc-table-ref)

(bind-method! __gc-table::t 'HashTable::set! gc-table-set!)

(bind-method!
  __gc-table::t
  'HashTable::update!
  gc-table-update!)

(bind-method!
  __gc-table::t
  'HashTable::delete!
  gc-table-delete!)

(bind-method!
  __gc-table::t
  'HashTable::for-each
  gc-table-for-each)

(bind-method!
  __gc-table::t
  'HashTable::length
  gc-table-length)

(bind-method! __gc-table::t 'HashTable::copy gc-table-copy)

(bind-method!
  __gc-table::t
  'HashTable::clear!
  gc-table-clear!)

(define (gambit-table-update! table key update default)
  (let ([result (table-ref table key default)])
    (table-set! table key (update default))))

(define (gambit-table-for-each table proc)
  (table-for-each proc table))

(define (gambit-table-clear! table)
  (\x23;\x23;unchecked-structure-set! table 0 5 #f #f))

(bind-method! (macro-type-table) 'HashTable::ref table-ref)

(bind-method!
  (macro-type-table)
  'HashTable::set!
  table-set!)

(bind-method!
  (macro-type-table)
  'HashTable::update!
  gambit-table-update!)

(bind-method!
  (macro-type-table)
  'HashTable::delete!
  table-set!)

(bind-method!
  (macro-type-table)
  'HashTable::for-each
  gambit-table-for-each)

(bind-method!
  (macro-type-table)
  'HashTable::length
  table-length)

(bind-method!
  (macro-type-table)
  'HashTable::copy
  table-copy)

(bind-method!
  (macro-type-table)
  'HashTable::clear!
  gambit-table-clear!)

(define hash-table::t
  (let* ([slots '(table count free hash test seed)])
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
          (let* ([fields '#()])
            (let* ([properties `((direct-slots: ,@slots)
                                  (struct: . #t))])
              (\x23;\x23;structure class::t 'gerbil\x23;hash-table::t 'hash-table flags
                __table::t fields (list object::t t::t) slot-vector
                slot-table properties #f #f))))))))

(define gc-hash-table::t
  (let* ([slots '(gcht immediate)])
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
          (let* ([fields '#()])
            (let* ([properties `((direct-slots: ,@slots)
                                  (struct: . #t))])
              (\x23;\x23;structure class::t 'gerbil\x23;gc-hash-table::t 'hash-table flags
                __gc-table::t fields (list object::t t::t) slot-vector
                slot-table properties #f #f))))))))

(begin
  (define locked-hash-table::t
    (make-class-type 'gerbil\x23;locked-hash-table::t 'locked-hash-table
      (list object::t) '(table lock)
      '((struct: . #t) (final: . #t)) '#f))
  (define (make-locked-hash-table . args)
    (let* ([type locked-hash-table::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (locked-hash-table? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;locked-hash-table::t))
  (define (locked-hash-table-table obj)
    (unchecked-slot-ref obj 'table))
  (define (locked-hash-table-lock obj)
    (unchecked-slot-ref obj 'lock))
  (define (locked-hash-table-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (locked-hash-table-lock-set! obj val)
    (unchecked-slot-set! obj 'lock val))
  (define (&locked-hash-table-table obj)
    (unchecked-slot-ref obj 'table))
  (define (&locked-hash-table-lock obj)
    (unchecked-slot-ref obj 'lock))
  (define (&locked-hash-table-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (&locked-hash-table-lock-set! obj val)
    (unchecked-slot-set! obj 'lock val)))

(begin
  (define checked-hash-table::t
    (make-class-type 'gerbil\x23;checked-hash-table::t 'checked-hash-table
      (list object::t) '(table key-check)
      '((struct: . #t) (final: . #t)) '#f))
  (define (make-checked-hash-table . args)
    (let* ([type checked-hash-table::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (checked-hash-table? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;checked-hash-table::t))
  (define (checked-hash-table-table obj)
    (unchecked-slot-ref obj 'table))
  (define (checked-hash-table-key-check obj)
    (unchecked-slot-ref obj 'key-check))
  (define (checked-hash-table-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (checked-hash-table-key-check-set! obj val)
    (unchecked-slot-set! obj 'key-check val))
  (define (&checked-hash-table-table obj)
    (unchecked-slot-ref obj 'table))
  (define (&checked-hash-table-key-check obj)
    (unchecked-slot-ref obj 'key-check))
  (define (&checked-hash-table-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (&checked-hash-table-key-check-set! obj val)
    (unchecked-slot-set! obj 'key-check val)))

(begin
  (define eq-hash-table::t
    (\x23;\x23;structure \x23;\x23;type-type
      'gerbil\x23;eq-hash-table 'hash-table 1048 hash-table::t
      '#()))
  (define (make-eq-hash-table . args)
    (error 'make-eq-hash-table
      "not yet implemented for defstruct-type"))
  (define (eq-hash-table? obj)
    (and (\x23;\x23;structure? obj)
         (let ([t (\x23;\x23;structure-type obj)])
           (or (eq? t eq-hash-table::t)
               (and t
                    (\x23;\x23;structure? t)
                    (let walk ([td t])
                      (cond
                        [(not td) #f]
                        [(eq? td eq-hash-table::t) #t]
                        [(\x23;\x23;structure? td)
                         (walk (\x23;\x23;type-super td))]
                        [else #f]))))))))

(begin
  (define eqv-hash-table::t
    (\x23;\x23;structure \x23;\x23;type-type
      'gerbil\x23;eqv-hash-table 'hash-table 1048 hash-table::t
      '#()))
  (define (make-eqv-hash-table . args)
    (error 'make-eqv-hash-table
      "not yet implemented for defstruct-type"))
  (define (eqv-hash-table? obj)
    (and (\x23;\x23;structure? obj)
         (let ([t (\x23;\x23;structure-type obj)])
           (or (eq? t eqv-hash-table::t)
               (and t
                    (\x23;\x23;structure? t)
                    (let walk ([td t])
                      (cond
                        [(not td) #f]
                        [(eq? td eqv-hash-table::t) #t]
                        [(\x23;\x23;structure? td)
                         (walk (\x23;\x23;type-super td))]
                        [else #f]))))))))

(begin
  (define symbol-hash-table::t
    (\x23;\x23;structure \x23;\x23;type-type
      'gerbil\x23;symbol-hash-table 'hash-table 1048 hash-table::t
      '#()))
  (define (make-symbol-hash-table . args)
    (error 'make-symbol-hash-table
      "not yet implemented for defstruct-type"))
  (define (symbol-hash-table? obj)
    (and (\x23;\x23;structure? obj)
         (let ([t (\x23;\x23;structure-type obj)])
           (or (eq? t symbol-hash-table::t)
               (and t
                    (\x23;\x23;structure? t)
                    (let walk ([td t])
                      (cond
                        [(not td) #f]
                        [(eq? td symbol-hash-table::t) #t]
                        [(\x23;\x23;structure? td)
                         (walk (\x23;\x23;type-super td))]
                        [else #f]))))))))

(begin
  (define string-hash-table::t
    (\x23;\x23;structure \x23;\x23;type-type
      'gerbil\x23;string-hash-table 'hash-table 1048 hash-table::t
      '#()))
  (define (make-string-hash-table . args)
    (error 'make-string-hash-table
      "not yet implemented for defstruct-type"))
  (define (string-hash-table? obj)
    (and (\x23;\x23;structure? obj)
         (let ([t (\x23;\x23;structure-type obj)])
           (or (eq? t string-hash-table::t)
               (and t
                    (\x23;\x23;structure? t)
                    (let walk ([td t])
                      (cond
                        [(not td) #f]
                        [(eq? td string-hash-table::t) #t]
                        [(\x23;\x23;structure? td)
                         (walk (\x23;\x23;type-super td))]
                        [else #f]))))))))

(begin
  (define immediate-hash-table::t
    (\x23;\x23;structure \x23;\x23;type-type 'gerbil\x23;immediate-hash-table::t
      'hash-table 1048 hash-table::t '#()))
  (define (make-immediate-hash-table . args)
    (error 'make-immediate-hash-table
      "not yet implemented for defstruct-type"))
  (define (immediate-hash-table? obj)
    (and (\x23;\x23;structure? obj)
         (let ([t (\x23;\x23;structure-type obj)])
           (or (eq? t immediate-hash-table::t)
               (and t
                    (\x23;\x23;structure? t)
                    (let walk ([td t])
                      (cond
                        [(not td) #f]
                        [(eq? td immediate-hash-table::t) #t]
                        [(\x23;\x23;structure? td)
                         (walk (\x23;\x23;type-super td))]
                        [else #f]))))))))

(bind-method! hash-table::t 'HashTable::ref raw-table-ref)

(bind-method! hash-table::t 'HashTable::set! raw-table-set!)

(bind-method!
  hash-table::t
  'HashTable::update!
  raw-table-update!)

(bind-method!
  hash-table::t
  'HashTable::delete!
  raw-table-delete!)

(bind-method!
  hash-table::t
  'HashTable::for-each
  raw-table-for-each)

(bind-method!
  hash-table::t
  'HashTable::length
  &raw-table-count)

(bind-method! hash-table::t 'HashTable::copy raw-table-copy)

(bind-method!
  hash-table::t
  'HashTable::clear!
  raw-table-clear!)

(bind-method! eq-hash-table::t 'HashTable::ref eq-table-ref)

(bind-method!
  eq-hash-table::t
  'HashTable::set!
  eq-table-set!)

(bind-method!
  eq-hash-table::t
  'HashTable::update!
  eq-table-update!)

(bind-method!
  eq-hash-table::t
  'HashTable::delete!
  eq-table-delete!)

(bind-method!
  eqv-hash-table::t
  'HashTable::ref
  eqv-table-ref)

(bind-method!
  eqv-hash-table::t
  'HashTable::set!
  eqv-table-set!)

(bind-method!
  eqv-hash-table::t
  'HashTable::update!
  eqv-table-update!)

(bind-method!
  eqv-hash-table::t
  'HashTable::delete!
  eqv-table-delete!)

(bind-method!
  symbol-hash-table::t
  'HashTable::ref
  symbolic-table-ref)

(bind-method!
  symbol-hash-table::t
  'HashTable::set!
  symbolic-table-set!)

(bind-method!
  symbol-hash-table::t
  'HashTable::update!
  symbolic-table-update!)

(bind-method!
  symbol-hash-table::t
  'HashTable::delete!
  symbolic-table-delete!)

(bind-method!
  string-hash-table::t
  'HashTable::ref
  string-table-ref)

(bind-method!
  string-hash-table::t
  'HashTable::set!
  string-table-set!)

(bind-method!
  string-hash-table::t
  'HashTable::update!
  string-table-update!)

(bind-method!
  string-hash-table::t
  'HashTable::delete!
  string-table-delete!)

(bind-method!
  immediate-hash-table::t
  'HashTable::ref
  immediate-table-ref)

(bind-method!
  immediate-hash-table::t
  'HashTable::set!
  immediate-table-set!)

(bind-method!
  immediate-hash-table::t
  'HashTable::update!
  immediate-table-update!)

(bind-method!
  immediate-hash-table::t
  'HashTable::delete!
  immediate-table-delete!)

(bind-method! gc-hash-table::t 'HashTable::ref gc-table-ref)

(bind-method!
  gc-hash-table::t
  'HashTable::set!
  gc-table-set!)

(bind-method!
  gc-hash-table::t
  'HashTable::update!
  gc-table-update!)

(bind-method!
  gc-hash-table::t
  'HashTable::delete!
  gc-table-delete!)

(bind-method!
  gc-hash-table::t
  'HashTable::for-each
  gc-table-for-each)

(bind-method!
  gc-hash-table::t
  'HashTable::length
  gc-table-length)

(bind-method!
  gc-hash-table::t
  'HashTable::copy
  gc-table-copy)

(bind-method!
  gc-hash-table::t
  'HashTable::clear!
  gc-table-clear!)

(define hash-table? HashTable?)

(define is-hash-table? is-HashTable?)

(define-syntax deflocked-hash-method
  (syntax-rules ()
    [(_ (method arg ...) begin-lock hash-method end-lock
        continue)
     (defmethod
       (\x40;method method locked-hash-table)
       (lambda (self arg ...)
         (let ([h (&locked-hash-table-table self)]
               [l (&locked-hash-table-lock self)])
           (continue
             (dynamic-wind
               (cut begin-lock l)
               (cut hash-method h arg ...)
               (cut end-lock l)))))
       interface:
       HashTable)]
    [(recur (method arg ...) begin-lock hash-method end-lock)
     (recur (method arg ...) begin-lock hash-method end-lock
       identity)]))

(begin
  (define locked-hash-table::ref
    (lambda (self key default)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (identity
          (dynamic-wind
            (lambda () (&Locker-read-lock! l))
            (lambda () (&HashTable-ref h key default))
            (lambda () (&Locker-read-unlock! l)))))))
  (bind-method!
    locked-hash-table::t
    'ref
    locked-hash-table::ref))

(begin
  (define locked-hash-table::set!
    (lambda (self key value)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (void))))
  (bind-method!
    locked-hash-table::t
    'set!
    locked-hash-table::set!))

(begin
  (define locked-hash-table::update!
    (lambda (self key update default)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (void))))
  (bind-method!
    locked-hash-table::t
    'update!
    locked-hash-table::update!))

(begin
  (define locked-hash-table::delete!
    (lambda (self key)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (void))))
  (bind-method!
    locked-hash-table::t
    'delete!
    locked-hash-table::delete!))

(begin
  (define locked-hash-table::for-each
    (lambda (self proc)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (void))))
  (bind-method!
    locked-hash-table::t
    'for-each
    locked-hash-table::for-each))

(begin
  (define locked-hash-table::length
    (lambda (self)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        ((lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-89})
           #{cut-arg dpuuv4a3mobea70icwo8nvdax-89})
          (dynamic-wind
            (lambda () (&Locker-read-lock! l))
            (lambda () (&HashTable-length h))
            (lambda () (&Locker-read-unlock! l)))))))
  (bind-method!
    locked-hash-table::t
    'length
    locked-hash-table::length))

(begin
  (define locked-hash-table::copy
    (lambda (self)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (HashTable
          (dynamic-wind
            (lambda () (&Locker-read-lock! l))
            (lambda () (&HashTable-copy h))
            (lambda () (&Locker-read-unlock! l)))))))
  (bind-method!
    locked-hash-table::t
    'copy
    locked-hash-table::copy))

(begin
  (define locked-hash-table::clear!
    (lambda (self)
      (let ([h (&locked-hash-table-table self)]
            [l (&locked-hash-table-lock self)])
        (void))))
  (bind-method!
    locked-hash-table::t
    'clear!
    locked-hash-table::clear!))

(bind-method!
  (macro-type-mutex)
  'Locker::read-lock!
  mutex-lock!)

(bind-method!
  (macro-type-mutex)
  'Locker::read-unlock!
  mutex-unlock!)

(bind-method!
  (macro-type-mutex)
  'Locker::write-lock!
  mutex-lock!)

(bind-method!
  (macro-type-mutex)
  'Locker::write-unlock!
  mutex-unlock!)

(define-syntax defchecked-hash-method
  (syntax-rules ()
    [(_ (method self arg ...) check hash-method)
     (defmethod
       (\x40;method method checked-hash-table)
       (lambda (self arg ...)
         (let ([h (&checked-hash-table-table self)]
               [key? (&checked-hash-table-key-check self)])
           (if (check key? arg ...)
               (hash-method h arg ...)
               (abort!
                 (raise-contract-violation-error "invalid key" context: 'hash-method value:
                   (\x40;list arg ...))))))
       interface:
       HashTable)]))

(begin
  (define checked-hash-table::ref
    (lambda (self key default)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if ((lambda (key? key default) (key? key))
              key?
              key
              default)
            (&HashTable-ref h key default)
            (abort!
              (raise-contract-violation-error "invalid key" 'context: '&HashTable-ref 'value:
                (list key default)))))))
  (bind-method!
    checked-hash-table::t
    'ref
    checked-hash-table::ref))

(begin
  (define checked-hash-table::set!
    (lambda (self key value)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if ((lambda (key? key value) (key? key)) key? key value)
            (&HashTable-set! h key value)
            (abort!
              (raise-contract-violation-error "invalid key" 'context: '&HashTable-set! 'value:
                (list key value)))))))
  (bind-method!
    checked-hash-table::t
    'set!
    checked-hash-table::set!))

(begin
  (define checked-hash-table::update!
    (lambda (self key update default)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if ((lambda (key? key update default) (key? key))
              key?
              key
              update
              default)
            (&HashTable-update! h key update default)
            (abort!
              (raise-contract-violation-error "invalid key" 'context: '&HashTable-update! 'value:
                (list key update default)))))))
  (bind-method!
    checked-hash-table::t
    'update!
    checked-hash-table::update!))

(begin
  (define checked-hash-table::delete!
    (lambda (self key)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if ((lambda (key? key) (key? key)) key? key)
            (&HashTable-delete! h key)
            (abort!
              (raise-contract-violation-error "invalid key" 'context:
                '&HashTable-delete! 'value: (list key)))))))
  (bind-method!
    checked-hash-table::t
    'delete!
    checked-hash-table::delete!))

(begin
  (define checked-hash-table::for-each
    (lambda (self proc)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if ((lambda (key? proc) #t) key? proc)
            (&HashTable-for-each h proc)
            (abort!
              (raise-contract-violation-error "invalid key" 'context: '&HashTable-for-each 'value:
                (list proc)))))))
  (bind-method!
    checked-hash-table::t
    'for-each
    checked-hash-table::for-each))

(begin
  (define checked-hash-table::length
    (lambda (self)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if (void)
            (&HashTable-length h)
            (abort!
              (raise-contract-violation-error "invalid key" 'context:
                '&HashTable-length 'value: (list)))))))
  (bind-method!
    checked-hash-table::t
    'length
    checked-hash-table::length))

(begin
  (define checked-hash-table::copy
    (lambda (self)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if (void)
            (&HashTable-copy h)
            (abort!
              (raise-contract-violation-error "invalid key" 'context:
                '&HashTable-copy 'value: (list)))))))
  (bind-method!
    checked-hash-table::t
    'copy
    checked-hash-table::copy))

(begin
  (define checked-hash-table::clear!
    (lambda (self)
      (void)
      (let ([h (&checked-hash-table-table self)]
            [key? (&checked-hash-table-key-check self)])
        (if (void)
            (&HashTable-clear! h)
            (abort!
              (raise-contract-violation-error "invalid key" 'context:
                '&HashTable-clear! 'value: (list)))))))
  (bind-method!
    checked-hash-table::t
    'clear!
    checked-hash-table::clear!))

(define (make-generic-hash-table table count free hash test
         seed)
  (\x23;\x23;structure hash-table::t table count free hash
    test seed))

(define make-hash-table
  (case-lambda
    [()
     (let* ([size-hint #f]
            [seed #f]
            [test equal?]
            [hash #f]
            [lock #f]
            [check #f]
            [weak-keys #f]
            [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint)
     (let* ([seed #f]
            [test equal?]
            [hash #f]
            [lock #f]
            [check #f]
            [weak-keys #f]
            [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed)
     (let* ([test equal?]
            [hash #f]
            [lock #f]
            [check #f]
            [weak-keys #f]
            [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test)
     (let* ([hash #f]
            [lock #f]
            [check #f]
            [weak-keys #f]
            [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test hash)
     (let* ([lock #f] [check #f] [weak-keys #f] [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test hash lock)
     (let* ([check #f] [weak-keys #f] [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test hash lock check)
     (let* ([weak-keys #f] [weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test hash lock check weak-keys)
     (let* ([weak-values #f])
       (define (table-seed)
         (if (fixnum? seed)
             seed
             (random-integer (macro-max-fixnum32))))
       (begin
         (define (wrap-lock ht)
           (if lock
               (HashTable (make-locked-hash-table ht (Locker lock)))
               ht))
         (define __wrap-lock wrap-lock))
       (begin
         (define (wrap-checked ht implicit)
           (if check
               (HashTable
                 (make-checked-hash-table
                   ht
                   (if (procedure? check) check implicit)))
               ht))
         (define __wrap-checked wrap-checked))
       (define (make kons key? hash test)
         (let* ([size (raw-table-size-hint->size size-hint)])
           (let* ([table (make-vector size (macro-unused-obj))])
             (let* ([ht (HashTable
                          (kons table 0 (fxquotient size 2) hash test
                            (table-seed)))])
               (wrap-checked (wrap-lock ht) key?)))))
       (define (make-gc-hash-table)
         (let ([ht (HashTable
                     (make-gc-table size-hint gc-hash-table::t))])
           (wrap-checked (wrap-lock ht) true)))
       (define (make-gambit-table)
         (let* ([size (or size-hint (macro-absent-obj))])
           (let* ([test (or test equal?)])
             (let* ([hash (cond
                            [hash]
                            [(eq? test eq?) eq?-hash]
                            [(eq? test eqv?) eqv?-hash]
                            [else equal?-hash])])
               (let* ([ht (HashTable
                            (make-table 'size: size 'test: test 'hash: hash
                              'weak-keys: weak-keys 'weak-values:
                              weak-values))])
                 (wrap-checked (wrap-lock ht) true))))))
       (cond
         [(or weak-keys weak-values) (make-gambit-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
               (not seed))
          (make-gc-hash-table)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
          (make make-eq-hash-table true eq-hash eq?)]
         [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
               (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
          (make make-eqv-hash-table true eqv-hash eqv?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (or (eq? hash symbolic-hash)
                   (eq? hash \x23;\x23;symbol-hash)))
          (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
         [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
               (eq? hash immediate-hash))
          (make
            make-immediate-hash-table
            immediate?
            immediate-hash
            eq?)]
         [(and (or (eq? test equal?)
                   (eq? test \x23;\x23;equal?)
                   (eq? test string=?)
                   (eq? test \x23;\x23;string=?))
               (or (eq? hash string-hash)
                   (eq? hash \x23;\x23;string=?-hash)))
          (make
            make-string-hash-table
            string?
            string-hash
            \x23;\x23;string=?)]
         [(and (eq? test equal?) (not hash))
          (make make-generic-hash-table true equal?-hash equal?)]
         [(not (procedure? test))
          (abort!
            (error 'gerbil
              "bad hash table test function; expected procedure"
              test))]
         [(not (procedure? hash))
          (abort!
            (error 'gerbil
              "bad hash table hash function; expected procedure"
              hash))]
         [else (make make-generic-hash-table true hash test)]))]
    [(size-hint seed test hash lock check weak-keys weak-values)
     (define (table-seed)
       (if (fixnum? seed)
           seed
           (random-integer (macro-max-fixnum32))))
     (begin
       (define (wrap-lock ht)
         (if lock
             (HashTable (make-locked-hash-table ht (Locker lock)))
             ht))
       (define __wrap-lock wrap-lock))
     (begin
       (define (wrap-checked ht implicit)
         (if check
             (HashTable
               (make-checked-hash-table
                 ht
                 (if (procedure? check) check implicit)))
             ht))
       (define __wrap-checked wrap-checked))
     (define (make kons key? hash test)
       (let* ([size (raw-table-size-hint->size size-hint)])
         (let* ([table (make-vector size (macro-unused-obj))])
           (let* ([ht (HashTable
                        (kons table 0 (fxquotient size 2) hash test
                          (table-seed)))])
             (wrap-checked (wrap-lock ht) key?)))))
     (define (make-gc-hash-table)
       (let ([ht (HashTable
                   (make-gc-table size-hint gc-hash-table::t))])
         (wrap-checked (wrap-lock ht) true)))
     (define (make-gambit-table)
       (let* ([size (or size-hint (macro-absent-obj))])
         (let* ([test (or test equal?)])
           (let* ([hash (cond
                          [hash]
                          [(eq? test eq?) eq?-hash]
                          [(eq? test eqv?) eqv?-hash]
                          [else equal?-hash])])
             (let* ([ht (HashTable
                          (make-table 'size: size 'test: test 'hash: hash
                            'weak-keys: weak-keys 'weak-values:
                            weak-values))])
               (wrap-checked (wrap-lock ht) true))))))
     (cond
       [(or weak-keys weak-values) (make-gambit-table)]
       [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
             (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash))
             (not seed))
        (make-gc-hash-table)]
       [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
             (or (not hash) (eq? hash eq?-hash) (eq? hash eq-hash)))
        (make make-eq-hash-table true eq-hash eq?)]
       [(and (or (eq? test eqv?) (eq? test \x23;\x23;eqv?))
             (or (not hash) (eq? hash eqv?-hash) (eq? hash eqv-hash)))
        (make make-eqv-hash-table true eqv-hash eqv?)]
       [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
             (or (eq? hash symbolic-hash)
                 (eq? hash \x23;\x23;symbol-hash)))
        (make make-symbol-hash-table symbolic? symbolic-hash eq?)]
       [(and (or (eq? test eq?) (eq? test \x23;\x23;eq?))
             (eq? hash immediate-hash))
        (make
          make-immediate-hash-table
          immediate?
          immediate-hash
          eq?)]
       [(and (or (eq? test equal?)
                 (eq? test \x23;\x23;equal?)
                 (eq? test string=?)
                 (eq? test \x23;\x23;string=?))
             (or (eq? hash string-hash)
                 (eq? hash \x23;\x23;string=?-hash)))
        (make
          make-string-hash-table
          string?
          string-hash
          \x23;\x23;string=?)]
       [(and (eq? test equal?) (not hash))
        (make make-generic-hash-table true equal?-hash equal?)]
       [(not (procedure? test))
        (abort!
          (error 'gerbil
            "bad hash table test function; expected procedure"
            test))]
       [(not (procedure? hash))
        (abort!
          (error 'gerbil
            "bad hash table hash function; expected procedure"
            hash))]
       [else (make make-generic-hash-table true hash test)])]))

(define (make-hash-table-eq . args)
  (apply make-hash-table eq? args))

(define (make-hash-table-eqv . args)
  (apply make-hash-table eqv? args))

(define (make-hash-table-symbolic . args)
  (apply make-hash-table eq? symbolic-hash args))

(define (make-hash-table-string . args)
  (apply make-hash-table string=? string-hash args))

(define (make-hash-table-immediate . args)
  (apply make-hash-table eq? immediate-hash args))

(define (list->hash-table lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table (length lst) args)))

(define (list->hash-table-eq lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table-eq 'size: (length lst) args)))

(define (list->hash-table-eqv lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table-eqv 'size: (length lst) args)))

(define (list->hash-table-symbolic lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table-symbolic 'size: (length lst) args)))

(define (list->hash-table-string lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table-string 'size: (length lst) args)))

(define (list->hash-table-immediate lst . args)
  (list->hash-table!
    lst
    (apply make-hash-table-immediate 'size: (length lst) args)))

(define (list->hash-table! lst h)
  (for-each
    (lambda (el)
      (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-90} el])
        (let ([k (car #{tmp dpuuv4a3mobea70icwo8nvdax-90})]
              [v (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-90})])
          (&HashTable-set! h k v))))
    lst)
  h)

(define (plist->hash-table lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table (length lst) args)))

(define (plist->hash-table-eq lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table-eq 'size: (length lst) args)))

(define (plist->hash-table-eqv lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table-eqv 'size: (length lst) args)))

(define (plist->hash-table-symbolic lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table-symbolic 'size: (length lst) args)))

(define (plist->hash-table-string lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table-string 'size: (length lst) args)))

(define (plist->hash-table-immediate lst . args)
  (plist->hash-table!
    lst
    (apply make-hash-table-immediate 'size: (length lst) args)))

(define (plist->hash-table! lst h)
  (let loop ([rest lst])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-91} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-91})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-92} (car #{match-val dpuuv4a3mobea70icwo8nvdax-91})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-93} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-91})])
            (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-92}])
              (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-93})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-94} (car #{tl dpuuv4a3mobea70icwo8nvdax-93})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-95} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-93})])
                    (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-94}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-95}])
                        (begin (&HashTable-set! h key val) (loop rest)))))
                  (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-91})
                      (begin h)
                      (begin
                        (error 'gerbil
                          "bad property list -- uneven list"
                          lst))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-91})
              (begin h)
              (begin
                (error 'gerbil
                  "bad property list -- uneven list"
                  lst)))))))

(define-syntax defhash-method
  (syntax-rules ()
    [(defhash-method (proc h . rest) body ...)
     (def (proc (h : HashTable) . rest) body ...)]))

(begin
  (define (hash-length h) ((slot-ref h 'length)))
  (define __hash-length hash-length))

(begin
  (define hash-ref
    (case-lambda
      [(h key)
       (let* ([default (macro-absent-obj)])
         (let ([result ((slot-ref h 'ref) key default)])
           (if (eq? result (macro-absent-obj))
               (raise-unbound-key-error 'hash-ref "unknown hash key" 'hash:
                 h 'key: key)
               result)))]
      [(h key default)
       (let ([result ((slot-ref h 'ref) key default)])
         (if (eq? result (macro-absent-obj))
             (raise-unbound-key-error 'hash-ref "unknown hash key" 'hash:
               h 'key: key)
             result))]))
  (define __hash-ref hash-ref))

(begin
  (define (hash-get h key) ((slot-ref h 'ref) key #f))
  (define __hash-get hash-get))

(begin
  (define (hash-put! h key value)
    ((slot-ref h 'set!) key value))
  (define __hash-put! hash-put!))

(begin
  (define hash-update!
    (case-lambda
      [(h key update)
       (let* ([default (%%void)])
         ((slot-ref h 'update!) key update default))]
      [(h key update default)
       ((slot-ref h 'update!) key update default)]))
  (define __hash-update! hash-update!))

(begin
  (define (hash-remove! h key) ((slot-ref h 'delete!) key))
  (define __hash-remove! hash-remove!))

(begin
  (define (hash-key? h k)
    (not (eq? ((slot-ref h 'ref) k absent-value) absent-value)))
  (define __hash-key? hash-key?))

(begin
  (define (hash->list h)
    (let ([lst (list)])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! lst (cons (cons k v) lst))))
      lst))
  (define __hash->list hash->list))

(begin
  (define (hash->plist h)
    (let ([lst (list)])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! lst (cons* k v lst))))
      lst))
  (define __hash->plist hash->plist))

(begin
  (define (hash-for-each proc h)
    ((slot-ref h 'for-each) proc))
  (define __hash-for-each hash-for-each))

(begin
  (define (hash-map proc h)
    (let ([result (list)])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! result (cons (proc k v) result))))
      result))
  (define __hash-map hash-map))

(begin
  (define (hash-fold proc iv h)
    (let ([result iv])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! result (proc k v result))))
      result))
  (define __hash-fold hash-fold))

(begin
  (define hash-find
    (case-lambda
      [(proc h)
       (let* ([default-value #f])
         (call/cc
           (lambda (return)
             ((slot-ref h 'for-each)
               (lambda (k v) (cond [(proc k v) => return])))
             default-value)))]
      [(proc h default-value)
       (call/cc
         (lambda (return)
           ((slot-ref h 'for-each)
             (lambda (k v) (cond [(proc k v) => return])))
           default-value))]))
  (define __hash-find hash-find))

(begin
  (define (hash-keys h)
    (let ([result (list)])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! result (cons k result))))
      result))
  (define __hash-keys hash-keys))

(begin
  (define (hash-values h)
    (let ([result (list)])
      ((slot-ref h 'for-each)
        (lambda (k v) (set! result (cons v result))))
      result))
  (define __hash-values hash-values))

(begin
  (define (hash-copy h) ((slot-ref h 'copy)))
  (define __hash-copy hash-copy))

(begin
  (define (hash-clear! h) ((slot-ref h 'clear!)))
  (define __hash-clear! hash-clear!))

(define (hash-merge h . rest)
  (let ([copy ((slot-ref h 'copy))])
    (apply hash-merge! copy rest)
    copy))

(define (hash-merge-right h . rest)
  (let ([copy ((slot-ref h 'copy))])
    (apply hash-merge-right! copy rest)
    copy))

(define (hash-merge! h . rest)
  (for-each
    (lambda (hr)
      ((slot-ref hr 'for-each)
        (lambda (k v)
          (unless (hash-key? h k) ((slot-ref h 'set!) k v)))))
    rest)
  h)

(define (hash-merge-right! h . rest)
  (for-each
    (lambda (hr)
      ((slot-ref hr 'for-each)
        (lambda (k v) ((slot-ref h 'set!) k v))))
    rest)
  h)

