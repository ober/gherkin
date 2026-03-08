(define __table::t.id 'gerbil\x23;__table::t)

(define __table::t
  (\x23;\x23;structure \x23;\x23;type-type __table::t.id 'raw-table 26 #f
    '#(table 5 #f count 5 #f free 5 #f hash 5 #f test 5 #f seed
       5 #f)))

(define (&raw-table-table tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    1
    __table::t
    'raw-table-table))

(define (&raw-table-count tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    2
    __table::t
    'raw-table-count))

(define (&raw-table-free tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    3
    __table::t
    'raw-table-free))

(define (&raw-table-hash tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    4
    __table::t
    'raw-table-hash))

(define (&raw-table-test tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    5
    __table::t
    'raw-table-test))

(define (&raw-table-seed tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    6
    __table::t
    'raw-table-seed))

(define (&raw-table-table-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 1 __table::t
    'raw-table-table-set!))

(define (&raw-table-count-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 2 __table::t
    'raw-table-count-set!))

(define (&raw-table-free-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 3 __table::t
    'raw-table-free-set!))

(define (&raw-table-hash-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 4 __table::t
    'raw-table-hash-set!))

(define (&raw-table-test-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 5 __table::t
    'raw-table-test-set!))

(define (&raw-table-seed-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 6 __table::t
    'raw-table-seed-set!))

(define __raw-table-lock (__make-inline-lock))

(define (raw-table-size-hint->size size-hint)
  (if (and (fixnum? size-hint) (fx> size-hint 0))
      (fx* (fxmax 2 (expt 2 (integer-length size-hint))) 4)
      16))

(define make-raw-table
  (case-lambda
    [(size-hint hash test)
     (let* ([seed 0])
       (let* ([size (raw-table-size-hint->size size-hint)])
         (let* ([table (make-vector size (macro-unused-obj))])
           (\x23;\x23;structure __table::t table 0 (fxquotient size 2)
             hash test seed))))]
    [(size-hint hash test seed)
     (let* ([size (raw-table-size-hint->size size-hint)])
       (let* ([table (make-vector size (macro-unused-obj))])
         (\x23;\x23;structure __table::t table 0 (fxquotient size 2)
           hash test seed)))]))

(define (raw-table-ref tab key default)
  (__lock-inline! __raw-table-lock)
  (let ([table (&raw-table-table tab)]
        [seed (&raw-table-seed tab)]
        [hash (&raw-table-hash tab)]
        [test (&raw-table-test tab)])
    (let ([result (let* ([h (fxxor (hash key) seed)])
                    (let* ([size (vector-length table)])
                      (let* ([entries (fxquotient size 2)])
                        (let* ([start (fxarithmetic-shift-left
                                        (fxmodulo h entries)
                                        1)])
                          (let loop ([probe start] [i 1] [deleted #f])
                            (let ([k (vector-ref table probe)])
                              (cond
                                [(eq? k (macro-unused-obj)) default]
                                [(eq? k (macro-deleted-obj))
                                 (loop
                                   (let ([next-probe (fx+ start
                                                          i
                                                          (fx* i i))])
                                     (fxmodulo next-probe size))
                                   (fx+ i 1)
                                   (or deleted probe))]
                                [(test key k)
                                 (vector-ref table (fx+ probe 1))]
                                [else
                                 (loop
                                   (let ([next-probe (fx+ start
                                                          i
                                                          (fx* i i))])
                                     (fxmodulo next-probe size))
                                   (fx+ i 1)
                                   deleted)])))))))])
      (__unlock-inline! __raw-table-lock)
      result)))

(define (raw-table-set! tab key value)
  (__lock-inline! __raw-table-lock)
  (when (fx< (&raw-table-free tab)
             (fxquotient (vector-length (&raw-table-table tab)) 4))
    (__raw-table-rehash! tab))
  (__raw-table-set! tab key value)
  (__unlock-inline! __raw-table-lock))

(define (raw-table-update! tab key update default)
  (__lock-inline! __raw-table-lock)
  (when (fx< (&raw-table-free tab)
             (fxquotient (vector-length (&raw-table-table tab)) 4))
    (__raw-table-rehash! tab))
  (__raw-table-update! tab key update default)
  (__unlock-inline! __raw-table-lock))

(define (raw-table-delete! tab key)
  (__lock-inline! __raw-table-lock)
  (let ([table (&raw-table-table tab)]
        [seed (&raw-table-seed tab)]
        [hash (&raw-table-hash tab)]
        [test (&raw-table-test tab)])
    (let* ([h (fxxor (hash key) seed)])
      (let* ([size (vector-length table)])
        (let* ([entries (fxquotient size 2)])
          (let* ([start (fxarithmetic-shift-left
                          (fxmodulo h entries)
                          1)])
            (let loop ([probe start] [i 1])
              (let ([k (vector-ref table probe)])
                (cond
                  [(eq? k (macro-unused-obj)) (void)]
                  [(eq? k (macro-deleted-obj))
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1))]
                  [(test key k)
                   (vector-set! table probe (macro-deleted-obj))
                   (vector-set! table (fx+ probe 1) (macro-absent-obj))
                   ((lambda ()
                      (&raw-table-count-set!
                        tab
                        (fx- (&raw-table-count tab) 1))))]
                  [else
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1))]))))))))
  (__unlock-inline! __raw-table-lock))

(define (raw-table-for-each tab proc)
  (__lock-inline! __raw-table-lock)
  (let* ([table (&raw-table-table tab)])
    (let* ([size (vector-length table)])
      (__unlock-inline! __raw-table-lock)
      (let loop ([i 0])
        (when (fx< i size)
          (let ([key (vector-ref table i)])
            (when (and (not (eq? key (macro-unused-obj)))
                       (not (eq? key (macro-deleted-obj))))
              (let ([value (vector-ref table (fx+ i 1))])
                (proc key value))))
          (loop (fx+ i 2)))))))

(define (raw-table-copy tab)
  (__lock-inline! __raw-table-lock)
  (let ([new-tab (\x23;\x23;structure-copy tab)])
    (&raw-table-table-set!
      new-tab
      (vector-copy (&raw-table-table tab)))
    (__unlock-inline! __raw-table-lock)
    new-tab))

(define (raw-table-clear! tab)
  (__lock-inline! __raw-table-lock)
  (vector-fill! (&raw-table-table tab) (macro-unused-obj))
  (&raw-table-count-set! tab 0)
  (&raw-table-free-set!
    tab
    (fxquotient (vector-length (&raw-table-table tab)) 2))
  (__unlock-inline! __raw-table-lock))

(define (__raw-table-set! tab key value)
  (let ([table (&raw-table-table tab)]
        [seed (&raw-table-seed tab)]
        [hash (&raw-table-hash tab)]
        [test (&raw-table-test tab)])
    (let* ([h (fxxor (hash key) seed)])
      (let* ([size (vector-length table)])
        (let* ([entries (fxquotient size 2)])
          (let* ([start (fxarithmetic-shift-left
                          (fxmodulo h entries)
                          1)])
            (let loop ([probe start] [i 1] [deleted #f])
              (let ([k (vector-ref table probe)])
                (cond
                  [(eq? k (macro-unused-obj))
                   (if deleted
                       (begin
                         (vector-set! table deleted key)
                         (vector-set! table (fx+ deleted 1) value)
                         ((lambda ()
                            (&raw-table-count-set!
                              tab
                              (fx+ (&raw-table-count tab) 1)))))
                       (begin
                         (vector-set! table probe key)
                         (vector-set! table (fx+ probe 1) value)
                         ((lambda ()
                            (&raw-table-free-set!
                              tab
                              (fx- (&raw-table-free tab) 1))
                            (&raw-table-count-set!
                              tab
                              (fx+ (&raw-table-count tab) 1))))))]
                  [(eq? k (macro-deleted-obj))
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1)
                     (or deleted probe))]
                  [(test key k)
                   (vector-set! table probe key)
                   (vector-set! table (fx+ probe 1) value)]
                  [else
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1)
                     deleted)])))))))))

(define (__raw-table-update! tab key update default)
  (let ([table (&raw-table-table tab)]
        [seed (&raw-table-seed tab)]
        [hash (&raw-table-hash tab)]
        [test (&raw-table-test tab)])
    (let* ([h (fxxor (hash key) seed)])
      (let* ([size (vector-length table)])
        (let* ([entries (fxquotient size 2)])
          (let* ([start (fxarithmetic-shift-left
                          (fxmodulo h entries)
                          1)])
            (let loop ([probe start] [i 1] [deleted #f])
              (let ([k (vector-ref table probe)])
                (cond
                  [(eq? k (macro-unused-obj))
                   (if deleted
                       (begin
                         (vector-set! table deleted key)
                         (vector-set!
                           table
                           (fx+ deleted 1)
                           (update default))
                         ((lambda ()
                            (&raw-table-count-set!
                              tab
                              (fx+ (&raw-table-count tab) 1)))))
                       (begin
                         (vector-set! table probe key)
                         (vector-set! table (fx+ probe 1) (update default))
                         ((lambda ()
                            (&raw-table-free-set!
                              tab
                              (fx- (&raw-table-free tab) 1))
                            (&raw-table-count-set!
                              tab
                              (fx+ (&raw-table-count tab) 1))))))]
                  [(eq? k (macro-deleted-obj))
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1)
                     (or deleted probe))]
                  [(test key k)
                   (vector-set! table probe key)
                   (vector-set!
                     table
                     (fx+ probe 1)
                     (update (vector-ref table (fx+ probe 1))))]
                  [else
                   (loop
                     (let ([next-probe (fx+ start i (fx* i i))])
                       (fxmodulo next-probe size))
                     (fx+ i 1)
                     deleted)])))))))))

(define (__raw-table-rehash! tab)
  (let* ([old-table (&raw-table-table tab)])
    (let* ([old-size (vector-length old-table)])
      (let* ([new-size (if (fx< (&raw-table-count tab)
                                (fxquotient old-size 4))
                           (vector-length old-table)
                           (fx* 2 (vector-length old-table)))])
        (let* ([new-table (make-vector
                            new-size
                            (macro-unused-obj))])
          (&raw-table-table-set! tab new-table)
          (&raw-table-count-set! tab 0)
          (&raw-table-free-set! tab (fxquotient new-size 2))
          (let lp ([i 0])
            (when (fx< i old-size)
              (let ([key (vector-ref old-table i)])
                (when (and (not (eq? key (macro-unused-obj)))
                           (not (eq? key (macro-deleted-obj))))
                  (let ([value (vector-ref old-table (fx+ i 1))])
                    (__raw-table-set! tab key value))))
              (lp (fx+ i 2)))))))))

(define (eq-hash obj)
  (let ([t (\x23;\x23;type obj)])
    (cond
      [(fx= (fxand t 1) 0)
       (fxand
         (\x23;\x23;type-cast obj (macro-type-fixnum))
         (macro-max-fixnum32))]
      [(symbolic? obj) (symbolic-hash obj)]
      [(procedure? obj) (procedure-hash obj)]
      [else (fxand (__eq-hash obj) (macro-max-fixnum32))])))

(define (procedure-hash obj)
  (let ([h (if (\x23;\x23;closure? obj)
               (__eq-hash obj)
               (\x23;\x23;type-cast obj 0))])
    (fxand h (macro-max-fixnum32))))

(begin
  (define (__eq-hash obj) (void) (__object->eq-hash obj)))

(define (eqv-hash obj)
  (define (combine a b)
    (fxand
      (fx* (fx+ a (fxarithmetic-shift-left b 1)) 331804471)
      (macro-max-fixnum32)))
  (define (hash obj)
    (macro-number-dispatch obj (eq-hash obj) (fxand obj (macro-max-fixnum32))
      (modulo obj 331804481)
      (combine
        (let ([#{ht dpuuv4a3mobea70icwo8nvdax-85} (make-hash-table)])
          (hash-put!
            #{ht dpuuv4a3mobea70icwo8nvdax-85}
            'macro-ratnum-numerator
            obj)
          #{ht dpuuv4a3mobea70icwo8nvdax-85})
        (let ([#{ht dpuuv4a3mobea70icwo8nvdax-86} (make-hash-table)])
          (hash-put!
            #{ht dpuuv4a3mobea70icwo8nvdax-86}
            'macro-ratnum-denominator
            obj)
          #{ht dpuuv4a3mobea70icwo8nvdax-86}))
      (combine
        (\x23;\x23;u16vector-ref obj 0)
        (combine
          (\x23;\x23;u16vector-ref obj 1)
          (combine
            (\x23;\x23;u16vector-ref obj 2)
            (\x23;\x23;u16vector-ref obj 3))))
      (combine
        (let ([#{ht dpuuv4a3mobea70icwo8nvdax-87} (make-hash-table)])
          (hash-put!
            #{ht dpuuv4a3mobea70icwo8nvdax-87}
            'macro-cpxnum-real
            obj)
          #{ht dpuuv4a3mobea70icwo8nvdax-87})
        (let ([#{ht dpuuv4a3mobea70icwo8nvdax-88} (make-hash-table)])
          (hash-put!
            #{ht dpuuv4a3mobea70icwo8nvdax-88}
            'macro-cpxnum-imag
            obj)
          #{ht dpuuv4a3mobea70icwo8nvdax-88}))))
  (hash obj))

(define (symbolic? obj) (or (symbol? obj) (keyword? obj)))

(define (symbolic-hash obj) (\x23;\x23;symbol-hash obj))

(define (string-hash obj) (\x23;\x23;string=?-hash obj))

(define (immediate-hash obj)
  (\x23;\x23;type-cast obj (macro-type-fixnum)))

(define-syntax defspecialized-table
  (syntax-rules ()
    [(_ make ref set __set update __update del hash eq)
     (begin
       (def (make (size-hint #f) (seed 0))
            (make-raw-table size-hint hash eq seed))
       (def (ref tab key default)
            (__lock-inline! __raw-table-lock)
            (let ([table (&raw-table-table tab)]
                  [seed (&raw-table-seed tab)])
              (let (result [__table-ref table seed hash eq key default])
                (__unlock-inline! __raw-table-lock)
                result)))
       (def (set tab key value) (__lock-inline! __raw-table-lock)
            (when (fx< (&raw-table-free tab)
                       (fxquotient
                         (vector-length (&raw-table-table tab))
                         4))
              (__raw-table-rehash! tab))
            (__set tab key value) (__unlock-inline! __raw-table-lock))
       (def (__set tab key value)
            (let ([table (&raw-table-table tab)]
                  [seed (&raw-table-seed tab)])
              (__table-set! table seed hash eq key value
                (lambda ()
                  (set! (&raw-table-free tab)
                    (fx- (&raw-table-free tab) 1))
                  (set! (&raw-table-count tab)
                    (fx+ (&raw-table-count tab) 1)))
                (lambda ()
                  (set! (&raw-table-count tab)
                    (fx+ (&raw-table-count tab) 1))))))
       (def (update tab key update default)
            (__lock-inline! __raw-table-lock)
            (when (fx< (&raw-table-free tab)
                       (fxquotient
                         (vector-length (&raw-table-table tab))
                         4))
              (__raw-table-rehash! tab))
            (__update tab key update default)
            (__unlock-inline! __raw-table-lock))
       (def (__update tab key update default)
            (let ([table (&raw-table-table tab)]
                  [seed (&raw-table-seed tab)])
              (__table-update! table seed hash eq key update default
                (lambda ()
                  (set! (&raw-table-free tab)
                    (fx- (&raw-table-free tab) 1))
                  (set! (&raw-table-count tab)
                    (fx+ (&raw-table-count tab) 1)))
                (lambda ()
                  (set! (&raw-table-count tab)
                    (fx+ (&raw-table-count tab) 1))))))
       (def (del tab key)
            (__lock-inline! __raw-table-lock)
            (let ([table (&raw-table-table tab)]
                  [seed (&raw-table-seed tab)])
              (__table-del! table seed hash eq key
                (lambda ()
                  (set! (&raw-table-count tab)
                    (fx- (&raw-table-count tab) 1)))))
            (__unlock-inline! __raw-table-lock)))]))

(begin
  (define make-eq-table
    (case-lambda
      [()
       (let* ([size-hint #f] [seed 0])
         (make-raw-table size-hint eq-hash eq? seed))]
      [(size-hint)
       (let* ([seed 0])
         (make-raw-table size-hint eq-hash eq? seed))]
      [(size-hint seed)
       (make-raw-table size-hint eq-hash eq? seed)]))
  (define (eq-table-ref tab key default)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let ([result (let* ([h (fxxor (eq-hash key) seed)])
                      (let* ([size (vector-length table)])
                        (let* ([entries (fxquotient size 2)])
                          (let* ([start (fxarithmetic-shift-left
                                          (fxmodulo h entries)
                                          1)])
                            (let loop ([probe start] [i 1] [deleted #f])
                              (let ([k (vector-ref table probe)])
                                (cond
                                  [(eq? k (macro-unused-obj)) default]
                                  [(eq? k (macro-deleted-obj))
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     (or deleted probe))]
                                  [(eq? key k)
                                   (vector-ref table (fx+ probe 1))]
                                  [else
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     deleted)])))))))])
        (__unlock-inline! __raw-table-lock)
        result)))
  (define (eq-table-set! tab key value)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__eq-table-set! tab key value)
    (__unlock-inline! __raw-table-lock))
  (define (__eq-table-set! tab key value)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eq-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set! table (fx+ deleted 1) value)
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set! table (fx+ probe 1) value)
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set! table (fx+ probe 1) value)]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (eq-table-update! tab key eq-table-update! default)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__eq-table-update! tab key eq-table-update! default)
    (__unlock-inline! __raw-table-lock))
  (define (__eq-table-update! tab key eq-table-update!
           default)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eq-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set!
                             table
                             (fx+ deleted 1)
                             (eq-table-update! default))
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set!
                             table
                             (fx+ probe 1)
                             (eq-table-update! default))
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set!
                       table
                       (fx+ probe 1)
                       (eq-table-update!
                         (vector-ref table (fx+ probe 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (eq-table-delete! tab key)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eq-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj)) (void)]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]
                    [(eq? key k)
                     (vector-set! table probe (macro-deleted-obj))
                     (vector-set! table (fx+ probe 1) (macro-absent-obj))
                     ((lambda ()
                        (&raw-table-count-set!
                          tab
                          (fx- (&raw-table-count tab) 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]))))))))
    (__unlock-inline! __raw-table-lock)))

(begin
  (define make-eqv-table
    (case-lambda
      [()
       (let* ([size-hint #f] [seed 0])
         (make-raw-table size-hint eqv-hash eqv? seed))]
      [(size-hint)
       (let* ([seed 0])
         (make-raw-table size-hint eqv-hash eqv? seed))]
      [(size-hint seed)
       (make-raw-table size-hint eqv-hash eqv? seed)]))
  (define (eqv-table-ref tab key default)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let ([result (let* ([h (fxxor (eqv-hash key) seed)])
                      (let* ([size (vector-length table)])
                        (let* ([entries (fxquotient size 2)])
                          (let* ([start (fxarithmetic-shift-left
                                          (fxmodulo h entries)
                                          1)])
                            (let loop ([probe start] [i 1] [deleted #f])
                              (let ([k (vector-ref table probe)])
                                (cond
                                  [(eq? k (macro-unused-obj)) default]
                                  [(eq? k (macro-deleted-obj))
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     (or deleted probe))]
                                  [(eqv? key k)
                                   (vector-ref table (fx+ probe 1))]
                                  [else
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     deleted)])))))))])
        (__unlock-inline! __raw-table-lock)
        result)))
  (define (eqv-table-set! tab key value)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__eqv-table-set! tab key value)
    (__unlock-inline! __raw-table-lock))
  (define (__eqv-table-set! tab key value)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eqv-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set! table (fx+ deleted 1) value)
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set! table (fx+ probe 1) value)
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eqv? key k)
                     (vector-set! table probe key)
                     (vector-set! table (fx+ probe 1) value)]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (eqv-table-update! tab key eqv-table-update!
           default)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__eqv-table-update! tab key eqv-table-update! default)
    (__unlock-inline! __raw-table-lock))
  (define (__eqv-table-update! tab key eqv-table-update!
           default)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eqv-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set!
                             table
                             (fx+ deleted 1)
                             (eqv-table-update! default))
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set!
                             table
                             (fx+ probe 1)
                             (eqv-table-update! default))
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eqv? key k)
                     (vector-set! table probe key)
                     (vector-set!
                       table
                       (fx+ probe 1)
                       (eqv-table-update!
                         (vector-ref table (fx+ probe 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (eqv-table-delete! tab key)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (eqv-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj)) (void)]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]
                    [(eqv? key k)
                     (vector-set! table probe (macro-deleted-obj))
                     (vector-set! table (fx+ probe 1) (macro-absent-obj))
                     ((lambda ()
                        (&raw-table-count-set!
                          tab
                          (fx- (&raw-table-count tab) 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]))))))))
    (__unlock-inline! __raw-table-lock)))

(begin
  (define make-symbolic-table
    (case-lambda
      [()
       (let* ([size-hint #f] [seed 0])
         (make-raw-table size-hint symbolic-hash eq? seed))]
      [(size-hint)
       (let* ([seed 0])
         (make-raw-table size-hint symbolic-hash eq? seed))]
      [(size-hint seed)
       (make-raw-table size-hint symbolic-hash eq? seed)]))
  (define (symbolic-table-ref tab key default)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let ([result (let* ([h (fxxor (symbolic-hash key) seed)])
                      (let* ([size (vector-length table)])
                        (let* ([entries (fxquotient size 2)])
                          (let* ([start (fxarithmetic-shift-left
                                          (fxmodulo h entries)
                                          1)])
                            (let loop ([probe start] [i 1] [deleted #f])
                              (let ([k (vector-ref table probe)])
                                (cond
                                  [(eq? k (macro-unused-obj)) default]
                                  [(eq? k (macro-deleted-obj))
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     (or deleted probe))]
                                  [(eq? key k)
                                   (vector-ref table (fx+ probe 1))]
                                  [else
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     deleted)])))))))])
        (__unlock-inline! __raw-table-lock)
        result)))
  (define (symbolic-table-set! tab key value)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__symbolic-table-set! tab key value)
    (__unlock-inline! __raw-table-lock))
  (define (__symbolic-table-set! tab key value)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (symbolic-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set! table (fx+ deleted 1) value)
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set! table (fx+ probe 1) value)
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set! table (fx+ probe 1) value)]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (symbolic-table-update! tab key
           symbolic-table-update! default)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__symbolic-table-update!
      tab
      key
      symbolic-table-update!
      default)
    (__unlock-inline! __raw-table-lock))
  (define (__symbolic-table-update! tab key
           symbolic-table-update! default)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (symbolic-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set!
                             table
                             (fx+ deleted 1)
                             (symbolic-table-update! default))
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set!
                             table
                             (fx+ probe 1)
                             (symbolic-table-update! default))
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set!
                       table
                       (fx+ probe 1)
                       (symbolic-table-update!
                         (vector-ref table (fx+ probe 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (symbolic-table-delete! tab key)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (symbolic-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj)) (void)]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]
                    [(eq? key k)
                     (vector-set! table probe (macro-deleted-obj))
                     (vector-set! table (fx+ probe 1) (macro-absent-obj))
                     ((lambda ()
                        (&raw-table-count-set!
                          tab
                          (fx- (&raw-table-count tab) 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]))))))))
    (__unlock-inline! __raw-table-lock)))

(begin
  (define make-string-table
    (case-lambda
      [()
       (let* ([size-hint #f] [seed 0])
         (make-raw-table
           size-hint
           string-hash
           \x23;\x23;string=?
           seed))]
      [(size-hint)
       (let* ([seed 0])
         (make-raw-table
           size-hint
           string-hash
           \x23;\x23;string=?
           seed))]
      [(size-hint seed)
       (make-raw-table
         size-hint
         string-hash
         \x23;\x23;string=?
         seed)]))
  (define (string-table-ref tab key default)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let ([result (let* ([h (fxxor (string-hash key) seed)])
                      (let* ([size (vector-length table)])
                        (let* ([entries (fxquotient size 2)])
                          (let* ([start (fxarithmetic-shift-left
                                          (fxmodulo h entries)
                                          1)])
                            (let loop ([probe start] [i 1] [deleted #f])
                              (let ([k (vector-ref table probe)])
                                (cond
                                  [(eq? k (macro-unused-obj)) default]
                                  [(eq? k (macro-deleted-obj))
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     (or deleted probe))]
                                  [(\x23;\x23;string=? key k)
                                   (vector-ref table (fx+ probe 1))]
                                  [else
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     deleted)])))))))])
        (__unlock-inline! __raw-table-lock)
        result)))
  (define (string-table-set! tab key value)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__string-table-set! tab key value)
    (__unlock-inline! __raw-table-lock))
  (define (__string-table-set! tab key value)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (string-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set! table (fx+ deleted 1) value)
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set! table (fx+ probe 1) value)
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(\x23;\x23;string=? key k)
                     (vector-set! table probe key)
                     (vector-set! table (fx+ probe 1) value)]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (string-table-update! tab key string-table-update!
           default)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__string-table-update!
      tab
      key
      string-table-update!
      default)
    (__unlock-inline! __raw-table-lock))
  (define (__string-table-update! tab key string-table-update!
           default)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (string-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set!
                             table
                             (fx+ deleted 1)
                             (string-table-update! default))
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set!
                             table
                             (fx+ probe 1)
                             (string-table-update! default))
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(\x23;\x23;string=? key k)
                     (vector-set! table probe key)
                     (vector-set!
                       table
                       (fx+ probe 1)
                       (string-table-update!
                         (vector-ref table (fx+ probe 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (string-table-delete! tab key)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (string-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj)) (void)]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]
                    [(\x23;\x23;string=? key k)
                     (vector-set! table probe (macro-deleted-obj))
                     (vector-set! table (fx+ probe 1) (macro-absent-obj))
                     ((lambda ()
                        (&raw-table-count-set!
                          tab
                          (fx- (&raw-table-count tab) 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]))))))))
    (__unlock-inline! __raw-table-lock)))

(begin
  (define make-immediate-table
    (case-lambda
      [()
       (let* ([size-hint #f] [seed 0])
         (make-raw-table size-hint immediate-hash eq? seed))]
      [(size-hint)
       (let* ([seed 0])
         (make-raw-table size-hint immediate-hash eq? seed))]
      [(size-hint seed)
       (make-raw-table size-hint immediate-hash eq? seed)]))
  (define (immediate-table-ref tab key default)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let ([result (let* ([h (fxxor (immediate-hash key) seed)])
                      (let* ([size (vector-length table)])
                        (let* ([entries (fxquotient size 2)])
                          (let* ([start (fxarithmetic-shift-left
                                          (fxmodulo h entries)
                                          1)])
                            (let loop ([probe start] [i 1] [deleted #f])
                              (let ([k (vector-ref table probe)])
                                (cond
                                  [(eq? k (macro-unused-obj)) default]
                                  [(eq? k (macro-deleted-obj))
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     (or deleted probe))]
                                  [(eq? key k)
                                   (vector-ref table (fx+ probe 1))]
                                  [else
                                   (loop
                                     (let ([next-probe (fx+ start
                                                            i
                                                            (fx* i i))])
                                       (fxmodulo next-probe size))
                                     (fx+ i 1)
                                     deleted)])))))))])
        (__unlock-inline! __raw-table-lock)
        result)))
  (define (immediate-table-set! tab key value)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__immediate-table-set! tab key value)
    (__unlock-inline! __raw-table-lock))
  (define (__immediate-table-set! tab key value)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (immediate-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set! table (fx+ deleted 1) value)
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set! table (fx+ probe 1) value)
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set! table (fx+ probe 1) value)]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (immediate-table-update! tab key
           immediate-table-update! default)
    (__lock-inline! __raw-table-lock)
    (when (fx< (&raw-table-free tab)
               (fxquotient (vector-length (&raw-table-table tab)) 4))
      (__raw-table-rehash! tab))
    (__immediate-table-update!
      tab
      key
      immediate-table-update!
      default)
    (__unlock-inline! __raw-table-lock))
  (define (__immediate-table-update! tab key
           immediate-table-update! default)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (immediate-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1] [deleted #f])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj))
                     (if deleted
                         (begin
                           (vector-set! table deleted key)
                           (vector-set!
                             table
                             (fx+ deleted 1)
                             (immediate-table-update! default))
                           ((lambda ()
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1)))))
                         (begin
                           (vector-set! table probe key)
                           (vector-set!
                             table
                             (fx+ probe 1)
                             (immediate-table-update! default))
                           ((lambda ()
                              (&raw-table-free-set!
                                tab
                                (fx- (&raw-table-free tab) 1))
                              (&raw-table-count-set!
                                tab
                                (fx+ (&raw-table-count tab) 1))))))]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       (or deleted probe))]
                    [(eq? key k)
                     (vector-set! table probe key)
                     (vector-set!
                       table
                       (fx+ probe 1)
                       (immediate-table-update!
                         (vector-ref table (fx+ probe 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1)
                       deleted)])))))))))
  (define (immediate-table-delete! tab key)
    (__lock-inline! __raw-table-lock)
    (let ([table (&raw-table-table tab)]
          [seed (&raw-table-seed tab)])
      (let* ([h (fxxor (immediate-hash key) seed)])
        (let* ([size (vector-length table)])
          (let* ([entries (fxquotient size 2)])
            (let* ([start (fxarithmetic-shift-left
                            (fxmodulo h entries)
                            1)])
              (let loop ([probe start] [i 1])
                (let ([k (vector-ref table probe)])
                  (cond
                    [(eq? k (macro-unused-obj)) (void)]
                    [(eq? k (macro-deleted-obj))
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]
                    [(eq? key k)
                     (vector-set! table probe (macro-deleted-obj))
                     (vector-set! table (fx+ probe 1) (macro-absent-obj))
                     ((lambda ()
                        (&raw-table-count-set!
                          tab
                          (fx- (&raw-table-count tab) 1))))]
                    [else
                     (loop
                       (let ([next-probe (fx+ start i (fx* i i))])
                         (fxmodulo next-probe size))
                       (fx+ i 1))]))))))))
    (__unlock-inline! __raw-table-lock)))

(define-syntax probe-step
  (syntax-rules ()
    [(_ start i size)
     (let (next-probe [fx+ start i (fx* i i)])
       (fxmodulo next-probe size))]))

(define-syntax __table-ref
  (syntax-rules ()
    [(_ table seed hash test key default-value)
     (let* ([h (fxxor (hash key) seed)]
            [size (vector-length table)]
            [entries (fxquotient size 2)]
            [start (fxarithmetic-shift-left (fxmodulo h entries) 1)])
       (let loop ([probe start] [i 1] [deleted #f])
         (let (k [vector-ref table probe])
           (cond
             [(eq? k (macro-unused-obj)) default-value]
             [(eq? k (macro-deleted-obj))
              (loop
                (probe-step start i size)
                (fx+ i 1)
                (or deleted probe))]
             [(test key k) (vector-ref table (fx+ probe 1))]
             [else
              (loop (probe-step start i size) (fx+ i 1) deleted)]))))]))

(define-syntax __table-set!
  (syntax-rules ()
    [(_ table seed hash test key value inserted ressurected)
     (let* ([h (fxxor (hash key) seed)]
            [size (vector-length table)]
            [entries (fxquotient size 2)]
            [start (fxarithmetic-shift-left (fxmodulo h entries) 1)])
       (let loop ([probe start] [i 1] [deleted #f])
         (let (k [vector-ref table probe])
           (cond
             [(eq? k (macro-unused-obj))
              (if deleted
                  (begin
                    (vector-set! table deleted key)
                    (vector-set! table (fx+ deleted 1) value)
                    (ressurected))
                  (begin
                    (vector-set! table probe key)
                    (vector-set! table (fx+ probe 1) value)
                    (inserted)))]
             [(eq? k (macro-deleted-obj))
              (loop
                (probe-step start i size)
                (fx+ i 1)
                (or deleted probe))]
             [(test key k)
              (vector-set! table probe key)
              (vector-set! table (fx+ probe 1) value)]
             [else
              (loop (probe-step start i size) (fx+ i 1) deleted)]))))]))

(define-syntax __table-update!
  (syntax-rules ()
    [(_ table seed hash test key update default inserted
        ressurected)
     (let* ([h (fxxor (hash key) seed)]
            [size (vector-length table)]
            [entries (fxquotient size 2)]
            [start (fxarithmetic-shift-left (fxmodulo h entries) 1)])
       (let loop ([probe start] [i 1] [deleted #f])
         (let (k [vector-ref table probe])
           (cond
             [(eq? k (macro-unused-obj))
              (if deleted
                  (begin
                    (vector-set! table deleted key)
                    (vector-set! table (fx+ deleted 1) (update default))
                    (ressurected))
                  (begin
                    (vector-set! table probe key)
                    (vector-set! table (fx+ probe 1) (update default))
                    (inserted)))]
             [(eq? k (macro-deleted-obj))
              (loop
                (probe-step start i size)
                (fx+ i 1)
                (or deleted probe))]
             [(test key k)
              (vector-set! table probe key)
              (vector-set!
                table
                (fx+ probe 1)
                (update (vector-ref table (fx+ probe 1))))]
             [else
              (loop (probe-step start i size) (fx+ i 1) deleted)]))))]))

(define-syntax __table-del!
  (syntax-rules ()
    [(_ table seed hash test key deleted)
     (let* ([h (fxxor (hash key) seed)]
            [size (vector-length table)]
            [entries (fxquotient size 2)]
            [start (fxarithmetic-shift-left (fxmodulo h entries) 1)])
       (let loop ([probe start] [i 1])
         (let (k [vector-ref table probe])
           (cond
             [(eq? k (macro-unused-obj)) (void)]
             [(eq? k (macro-deleted-obj))
              (loop (probe-step start i size) (fx+ i 1))]
             [(test key k)
              (vector-set! table probe (macro-deleted-obj))
              (vector-set! table (fx+ probe 1) (macro-absent-obj))
              (deleted)]
             [else (loop (probe-step start i size) (fx+ i 1))]))))]))

(define __gc-table::t.id 'gerbil\x23;__gc-table::t)

(define __gc-table::t
  (\x23;\x23;structure \x23;\x23;type-type __gc-table::t.id
    'gc-table 26 #f '#(gcht 5 #f immediate 5 #f)))

(define __gc-table-loads '#f)

(define (&gc-table-gcht tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    1
    __gc-table::t
    'gc-table-gcht))

(define (&gc-table-immediate tab)
  (\x23;\x23;unchecked-structure-ref
    tab
    2
    __gc-table::t
    'gc-table-immediate))

(define (&gc-table-gcht-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 1 __gc-table::t
    'gc-table-gcht-set!))

(define (&gc-table-immediate-set! tab val)
  (\x23;\x23;unchecked-structure-set! tab val 2 __gc-table::t
    'gc-table-immediate-set!))

(define __gc-table-lock (__make-inline-lock))

(define make-gc-table
  (case-lambda
    [(size-hint)
     (let* ([klass __gc-table::t] [flags 0])
       (let ([gcht (__gc-table-new
                     (if (fixnum? size-hint) size-hint 16)
                     flags)])
         (\x23;\x23;structure klass gcht #f)))]
    [(size-hint klass)
     (let* ([flags 0])
       (let ([gcht (__gc-table-new
                     (if (fixnum? size-hint) size-hint 16)
                     flags)])
         (\x23;\x23;structure klass gcht #f)))]
    [(size-hint klass flags)
     (let ([gcht (__gc-table-new
                   (if (fixnum? size-hint) size-hint 16)
                   flags)])
       (\x23;\x23;structure klass gcht #f))]))

(define (__gc-table-immediate tab)
  (cond
    [(&gc-table-immediate tab)]
    [else
     (__lock-inline! __gc-table-lock)
     (cond
       [(&gc-table-immediate tab) =>
        (lambda (imm) (__unlock-inline! __gc-table-lock) imm)]
       [else
        (let ([immediate (make-immediate-table #f 0)])
          (&gc-table-immediate-set! tab immediate)
          (__unlock-inline! __gc-table-lock)
          immediate)])]))

(define (__gc-table-new size flags)
  (let* ([flags (fxand
                  flags
                  (fxnot (macro-gc-hash-table-flag-need-rehash)))])
    (let* ([flags (fxior
                    flags
                    (macro-gc-hash-table-flag-mem-alloc-keys))])
      (let* ([gcht (\x23;\x23;gc-hash-table-allocate
                     size
                     flags
                     __gc-table-loads)])
        gcht))))

(define (__gc-table-e tab)
  (let ([gcht (&gc-table-gcht tab)])
    (if (fx= 0
             (fxand
               (macro-gc-hash-table-flags gcht)
               (macro-gc-hash-table-flag-need-rehash)))
        gcht
        (begin (__gc-table-rehash! tab) (&gc-table-gcht tab)))))

(define (__gc-table-rehash! tab)
  (__lock-inline! __gc-table-lock)
  (let* ([old-table (&gc-table-gcht tab)])
    (let* ([new-table (\x23;\x23;gc-hash-table-resize!
                        old-table
                        __gc-table-loads)])
      (let* ([result (\x23;\x23;gc-hash-table-rehash!
                       old-table
                       new-table)])
        (&gc-table-gcht-set! tab result)
        (__unlock-inline! __gc-table-lock)))))

(define (gc-table-ref tab key default)
  (cond
    [(\x23;\x23;mem-allocated? key)
     (let ([gcht (__gc-table-e tab)])
       (let ([value (\x23;\x23;gc-hash-table-ref gcht key)])
         (if (eq? value (macro-unused-obj)) default value)))]
    [(&gc-table-immediate tab) =>
     (lambda (immediate)
       (immediate-table-ref immediate key default))]
    [else default]))

(define (gc-table-set! tab key value)
  (if (\x23;\x23;mem-allocated? key)
      (let ([gcht (__gc-table-e tab)])
        (when (\x23;\x23;gc-hash-table-set! gcht key value)
          (__gc-table-rehash! tab)
          (gc-table-set! tab key value))
        (unless (\x23;\x23;eq? gcht (&gc-table-gcht tab))
          (gc-table-set! tab key value)))
      (immediate-table-set!
        (__gc-table-immediate tab)
        key
        value)))

(define (gc-table-update! tab key update default)
  (if (\x23;\x23;mem-allocated? key)
      (let ([value (gc-table-ref tab key default)])
        (gc-table-set! tab key (update value)))
      (immediate-table-update!
        (__gc-table-immediate tab)
        key
        update
        default)))

(define (gc-table-delete! tab key)
  (cond
    [(\x23;\x23;mem-allocated? key)
     (let ([gcht (__gc-table-e tab)])
       (when (\x23;\x23;gc-hash-table-set!
               gcht
               key
               (macro-absent-obj))
         (__gc-table-rehash! tab)
         (gc-table-delete! tab key))
       (unless (\x23;\x23;eq? gcht (&gc-table-gcht tab))
         (gc-table-delete! tab key)))]
    [(&gc-table-immediate tab) =>
     (lambda (immediate)
       (immediate-table-delete! immediate key))]))

(define (gc-table-for-each tab proc)
  (let ([gcht (__gc-table-e tab)])
    (\x23;\x23;gc-hash-table-for-each proc gcht))
  (cond
    [(&gc-table-immediate tab) =>
     (lambda (immediate) (raw-table-for-each immediate proc))]))

(define (gc-table-copy tab)
  (let* ([gcht (__gc-table-e tab)])
    (let* ([new-table (__gc-table-new
                        (macro-gc-hash-table-count gcht)
                        (macro-gc-hash-table-flags gcht))])
      (let* ([result (\x23;\x23;structure
                       (\x23;\x23;structure-type tab)
                       new-table
                       #f)])
        (gc-table-for-each
          tab
          (lambda (k v) (gc-table-set! result k v)))
        result))))

(define (gc-table-clear! tab)
  (let* ([gcht (__gc-table-e tab)])
    (let* ([new-table (__gc-table-new
                        16
                        (macro-gc-hash-table-flags gcht))])
      (__lock-inline! __gc-table-lock)
      (&gc-table-gcht-set! tab new-table)
      (&gc-table-immediate-set! tab #f)
      (__unlock-inline! __gc-table-lock))))

(define (gc-table-length tab)
  (let ([gcht (__gc-table-e tab)])
    (fx+ (macro-gc-hash-table-count gcht)
         (cond
           [(&gc-table-immediate tab) => &raw-table-count]
           [else 0]))))

(define __object-eq-hash-next 0)

(define __object-eq-hash
  (make-gc-table
    1024
    __gc-table::t
    (macro-gc-hash-table-flag-weak-keys)))

(define (__object->eq-hash obj)
  (let ([val (gc-table-ref __object-eq-hash obj #f)])
    (if val
        val
        (let* ([mix __object-eq-hash-next])
          (let* ([ptr (\x23;\x23;type-cast obj 0)])
            (let* ([h (fxand (fxxor mix ptr) (macro-max-fixnum32))])
              (set! __object-eq-hash-next
                (or (\x23;\x23;fx+? __object-eq-hash-next 1) 0))
              (gc-table-set! __object-eq-hash obj h)
              h))))))

