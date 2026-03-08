(define c4-linearize
  (case-lambda
    [(rhead supers get-precedence-list struct?)
     (let* ([eq eq?] [get-name identity])
       (cond
         [(null? supers) (values (reverse rhead) #f)]
         [(null? (cdr supers))
          (let ([pl (get-precedence-list (car supers))])
            (values (append-reverse rhead pl) (find struct? pl)))]
         [else
          (let ([pls (map get-precedence-list supers)] [sis (list)])
            (letrec* ([get-names (lambda (lst) (map get-name lst))]
                      [err (lambda a
                             (apply error "Inconsistent precedence graph" 'head:
                               (get-names (reverse rhead))
                               'precedence-lists: (map get-names pls)
                               'single-inheritance-suffix: (get-names sis)
                               a))]
                      [eqlist? (lambda (l1 l2)
                                 (or (eq? l1 l2)
                                     (and (andmap eq l1 l2)
                                          (fx= (length l1) (length l2)))))]
                      [merge-sis! (lambda (sis2)
                                    (cond
                                      [(null? sis2) (void)]
                                      [(null? sis) (set! sis sis2)]
                                      [else
                                       (let loop ([t1 sis] [t2 sis2])
                                         (cond
                                           [(eqlist? t1 sis2) (void)]
                                           [(eqlist? t2 sis)
                                            (set! sis sis2)]
                                           [(null? t1)
                                            (if (memp
                                                  (lambda (#{e dpuuv4a3mobea70icwo8nvdax-6})
                                                    (eq (car sis)
                                                        #{e dpuuv4a3mobea70icwo8nvdax-6}))
                                                  t2)
                                                (set! sis sis2)
                                                (err 'struct-incompatibility:
                                                     (list
                                                       (get-names sis)
                                                       (get-names sis2))))]
                                           [(null? t2)
                                            (if (memp
                                                  (lambda (#{e dpuuv4a3mobea70icwo8nvdax-7})
                                                    (eq (car sis2)
                                                        #{e dpuuv4a3mobea70icwo8nvdax-7}))
                                                  t1)
                                                (void)
                                                (err 'struct-incompatibility:
                                                     (list
                                                       (get-names sis)
                                                       (get-names sis2))))]
                                           [else
                                            (loop (cdr t1) (cdr t2))]))]))]
                      [rpls (map (lambda (pl)
                                   (let-values ([(tl rh)
                                                 (append-reverse-until
                                                   struct?
                                                   pl
                                                   (list))])
                                     (merge-sis! tl)
                                     rh))
                                 pls)]
                      [unsisr-rpl (lambda (rpl)
                                    (let u ([pl-rhead rpl]
                                            [pl-tail (list)]
                                            [sis-rhead (reverse sis)]
                                            [sis-tail (list)])
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-8} pl-rhead])
                                        (if (null?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                            (begin pl-tail)
                                            (if (pair?
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-9} (car #{match-val dpuuv4a3mobea70icwo8nvdax-8})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-10} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-8})])
                                                  (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-9}])
                                                    (let ([plrh #{tl dpuuv4a3mobea70icwo8nvdax-10}])
                                                      (begin
                                                        (if (memp
                                                              (lambda (#{e dpuuv4a3mobea70icwo8nvdax-11})
                                                                (eq c
                                                                    #{e dpuuv4a3mobea70icwo8nvdax-11}))
                                                              sis-tail)
                                                            (err 'precedence-list-head:
                                                                 (get-names
                                                                   (reverse
                                                                     pl-rhead))
                                                                 'precedence-list-tail:
                                                                 (get-names
                                                                   pl-tail)
                                                                 'single-inheritance-head:
                                                                 (get-names
                                                                   (reverse
                                                                     sis-rhead))
                                                                 'single-inheritance-tail:
                                                                 (get-names
                                                                   sis-tail)
                                                                 'super-out-of-order-vs-single-inheritance-tail:
                                                                 (get-name
                                                                   c))
                                                            (let-values ([(sis-rh2 sis-tl2)
                                                                          (append-reverse-until
                                                                            (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-12})
                                                                              (eq c
                                                                                  #{cut-arg dpuuv4a3mobea70icwo8nvdax-12}))
                                                                            sis-rhead
                                                                            sis-tail)])
                                                              (if (null?
                                                                    sis-rh2)
                                                                  (u plrh
                                                                     (cons
                                                                       c
                                                                       pl-tail)
                                                                     (list)
                                                                     sis-tl2)
                                                                  (u plrh
                                                                     pl-tail
                                                                     (cdr sis-rh2)
                                                                     sis-tl2))))))))
                                                (error 'match
                                                  "no matching clause"
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-8}))))))]
                      [hpls (map unsisr-rpl rpls)]
                      [c3-select-next (lambda (tails)
                                        (let ([candidate? (lambda (c)
                                                            (andmap
                                                              (lambda (tail)
                                                                (not (memp
                                                                       (lambda (#{e dpuuv4a3mobea70icwo8nvdax-13})
                                                                         (eq c
                                                                             #{e dpuuv4a3mobea70icwo8nvdax-13}))
                                                                       (cdr tail))))
                                                              tails))])
                                          (let loop ([ts tails])
                                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-14} ts])
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-14})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-15} (car #{match-val dpuuv4a3mobea70icwo8nvdax-14})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-16} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-14})])
                                                    (if (pair?
                                                          #{hd dpuuv4a3mobea70icwo8nvdax-15})
                                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-17} (car #{hd dpuuv4a3mobea70icwo8nvdax-15})]
                                                              [#{tl dpuuv4a3mobea70icwo8nvdax-18} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-15})])
                                                          (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-17}])
                                                            (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-18}])
                                                              (let ([rts #{tl dpuuv4a3mobea70icwo8nvdax-16}])
                                                                (begin
                                                                  (if (candidate?
                                                                        c)
                                                                      c
                                                                      (loop
                                                                        rts)))))))
                                                        (begin (err))))
                                                  (begin (err)))))))]
                      [remove-next! (lambda (next tails)
                                      (let loop ([t tails])
                                        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-19} t])
                                          (if (null?
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                              (begin tails)
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-20} (car #{match-val dpuuv4a3mobea70icwo8nvdax-19})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-21} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-19})])
                                                    (if (pair?
                                                          #{hd dpuuv4a3mobea70icwo8nvdax-20})
                                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-22} (car #{hd dpuuv4a3mobea70icwo8nvdax-20})]
                                                              [#{tl dpuuv4a3mobea70icwo8nvdax-23} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-20})])
                                                          (let ([head #{hd dpuuv4a3mobea70icwo8nvdax-22}])
                                                            (let ([tail #{tl dpuuv4a3mobea70icwo8nvdax-23}])
                                                              (let ([more #{tl dpuuv4a3mobea70icwo8nvdax-21}])
                                                                (begin
                                                                  (when (eq head
                                                                            next)
                                                                    (set-car!
                                                                      t
                                                                      tail))
                                                                  (loop
                                                                    more))))))
                                                        (error 'match
                                                          "no matching clause"
                                                          #{match-val dpuuv4a3mobea70icwo8nvdax-19})))
                                                  (error 'match
                                                    "no matching clause"
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-19}))))))]
                      [precedence-list (let c3loop ([rhead rhead]
                                                    [tails hpls])
                                         (let ([tails (remove-nulls!
                                                        tails)])
                                           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-24} tails])
                                             (if (null?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                                 (begin
                                                   (append-reverse
                                                     rhead
                                                     sis))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-25} (car #{match-val dpuuv4a3mobea70icwo8nvdax-24})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-26} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-24})])
                                                       (let ([tail #{hd dpuuv4a3mobea70icwo8nvdax-25}])
                                                         (if (null?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-26})
                                                             (begin
                                                               (append-reverse
                                                                 rhead
                                                                 (append
                                                                   tail
                                                                   sis)))
                                                             (begin
                                                               (let* ([next (c3-select-next
                                                                              tails)])
                                                                 (c3loop
                                                                   (cons
                                                                     next
                                                                     rhead)
                                                                   (remove-next!
                                                                     next
                                                                     tails)))))))
                                                     (begin
                                                       (let* ([next (c3-select-next
                                                                      tails)])
                                                         (c3loop
                                                           (cons
                                                             next
                                                             rhead)
                                                           (remove-next!
                                                             next
                                                             tails)))))))))]
                      [super-struct (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-27} sis])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-27})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-28} (car #{match-val dpuuv4a3mobea70icwo8nvdax-27})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-29} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-27})])
                                            (let ([s #{hd dpuuv4a3mobea70icwo8nvdax-28}])
                                              (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-29}])
                                                (begin s))))
                                          (begin #f)))])
              (append1! rpls (reverse supers))
              (values precedence-list super-struct)))]))]
    [(rhead supers get-precedence-list struct? eq)
     (let* ([get-name identity])
       (cond
         [(null? supers) (values (reverse rhead) #f)]
         [(null? (cdr supers))
          (let ([pl (get-precedence-list (car supers))])
            (values (append-reverse rhead pl) (find struct? pl)))]
         [else
          (let ([pls (map get-precedence-list supers)] [sis (list)])
            (letrec* ([get-names (lambda (lst) (map get-name lst))]
                      [err (lambda a
                             (apply error "Inconsistent precedence graph" 'head:
                               (get-names (reverse rhead))
                               'precedence-lists: (map get-names pls)
                               'single-inheritance-suffix: (get-names sis)
                               a))]
                      [eqlist? (lambda (l1 l2)
                                 (or (eq? l1 l2)
                                     (and (andmap eq l1 l2)
                                          (fx= (length l1) (length l2)))))]
                      [merge-sis! (lambda (sis2)
                                    (cond
                                      [(null? sis2) (void)]
                                      [(null? sis) (set! sis sis2)]
                                      [else
                                       (let loop ([t1 sis] [t2 sis2])
                                         (cond
                                           [(eqlist? t1 sis2) (void)]
                                           [(eqlist? t2 sis)
                                            (set! sis sis2)]
                                           [(null? t1)
                                            (if (memp
                                                  (lambda (#{e dpuuv4a3mobea70icwo8nvdax-6})
                                                    (eq (car sis)
                                                        #{e dpuuv4a3mobea70icwo8nvdax-6}))
                                                  t2)
                                                (set! sis sis2)
                                                (err 'struct-incompatibility:
                                                     (list
                                                       (get-names sis)
                                                       (get-names sis2))))]
                                           [(null? t2)
                                            (if (memp
                                                  (lambda (#{e dpuuv4a3mobea70icwo8nvdax-7})
                                                    (eq (car sis2)
                                                        #{e dpuuv4a3mobea70icwo8nvdax-7}))
                                                  t1)
                                                (void)
                                                (err 'struct-incompatibility:
                                                     (list
                                                       (get-names sis)
                                                       (get-names sis2))))]
                                           [else
                                            (loop (cdr t1) (cdr t2))]))]))]
                      [rpls (map (lambda (pl)
                                   (let-values ([(tl rh)
                                                 (append-reverse-until
                                                   struct?
                                                   pl
                                                   (list))])
                                     (merge-sis! tl)
                                     rh))
                                 pls)]
                      [unsisr-rpl (lambda (rpl)
                                    (let u ([pl-rhead rpl]
                                            [pl-tail (list)]
                                            [sis-rhead (reverse sis)]
                                            [sis-tail (list)])
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-8} pl-rhead])
                                        (if (null?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                            (begin pl-tail)
                                            (if (pair?
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-9} (car #{match-val dpuuv4a3mobea70icwo8nvdax-8})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-10} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-8})])
                                                  (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-9}])
                                                    (let ([plrh #{tl dpuuv4a3mobea70icwo8nvdax-10}])
                                                      (begin
                                                        (if (memp
                                                              (lambda (#{e dpuuv4a3mobea70icwo8nvdax-11})
                                                                (eq c
                                                                    #{e dpuuv4a3mobea70icwo8nvdax-11}))
                                                              sis-tail)
                                                            (err 'precedence-list-head:
                                                                 (get-names
                                                                   (reverse
                                                                     pl-rhead))
                                                                 'precedence-list-tail:
                                                                 (get-names
                                                                   pl-tail)
                                                                 'single-inheritance-head:
                                                                 (get-names
                                                                   (reverse
                                                                     sis-rhead))
                                                                 'single-inheritance-tail:
                                                                 (get-names
                                                                   sis-tail)
                                                                 'super-out-of-order-vs-single-inheritance-tail:
                                                                 (get-name
                                                                   c))
                                                            (let-values ([(sis-rh2 sis-tl2)
                                                                          (append-reverse-until
                                                                            (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-12})
                                                                              (eq c
                                                                                  #{cut-arg dpuuv4a3mobea70icwo8nvdax-12}))
                                                                            sis-rhead
                                                                            sis-tail)])
                                                              (if (null?
                                                                    sis-rh2)
                                                                  (u plrh
                                                                     (cons
                                                                       c
                                                                       pl-tail)
                                                                     (list)
                                                                     sis-tl2)
                                                                  (u plrh
                                                                     pl-tail
                                                                     (cdr sis-rh2)
                                                                     sis-tl2))))))))
                                                (error 'match
                                                  "no matching clause"
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-8}))))))]
                      [hpls (map unsisr-rpl rpls)]
                      [c3-select-next (lambda (tails)
                                        (let ([candidate? (lambda (c)
                                                            (andmap
                                                              (lambda (tail)
                                                                (not (memp
                                                                       (lambda (#{e dpuuv4a3mobea70icwo8nvdax-13})
                                                                         (eq c
                                                                             #{e dpuuv4a3mobea70icwo8nvdax-13}))
                                                                       (cdr tail))))
                                                              tails))])
                                          (let loop ([ts tails])
                                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-14} ts])
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-14})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-15} (car #{match-val dpuuv4a3mobea70icwo8nvdax-14})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-16} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-14})])
                                                    (if (pair?
                                                          #{hd dpuuv4a3mobea70icwo8nvdax-15})
                                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-17} (car #{hd dpuuv4a3mobea70icwo8nvdax-15})]
                                                              [#{tl dpuuv4a3mobea70icwo8nvdax-18} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-15})])
                                                          (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-17}])
                                                            (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-18}])
                                                              (let ([rts #{tl dpuuv4a3mobea70icwo8nvdax-16}])
                                                                (begin
                                                                  (if (candidate?
                                                                        c)
                                                                      c
                                                                      (loop
                                                                        rts)))))))
                                                        (begin (err))))
                                                  (begin (err)))))))]
                      [remove-next! (lambda (next tails)
                                      (let loop ([t tails])
                                        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-19} t])
                                          (if (null?
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                              (begin tails)
                                              (if (pair?
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-20} (car #{match-val dpuuv4a3mobea70icwo8nvdax-19})]
                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-21} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-19})])
                                                    (if (pair?
                                                          #{hd dpuuv4a3mobea70icwo8nvdax-20})
                                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-22} (car #{hd dpuuv4a3mobea70icwo8nvdax-20})]
                                                              [#{tl dpuuv4a3mobea70icwo8nvdax-23} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-20})])
                                                          (let ([head #{hd dpuuv4a3mobea70icwo8nvdax-22}])
                                                            (let ([tail #{tl dpuuv4a3mobea70icwo8nvdax-23}])
                                                              (let ([more #{tl dpuuv4a3mobea70icwo8nvdax-21}])
                                                                (begin
                                                                  (when (eq head
                                                                            next)
                                                                    (set-car!
                                                                      t
                                                                      tail))
                                                                  (loop
                                                                    more))))))
                                                        (error 'match
                                                          "no matching clause"
                                                          #{match-val dpuuv4a3mobea70icwo8nvdax-19})))
                                                  (error 'match
                                                    "no matching clause"
                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-19}))))))]
                      [precedence-list (let c3loop ([rhead rhead]
                                                    [tails hpls])
                                         (let ([tails (remove-nulls!
                                                        tails)])
                                           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-24} tails])
                                             (if (null?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                                 (begin
                                                   (append-reverse
                                                     rhead
                                                     sis))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-25} (car #{match-val dpuuv4a3mobea70icwo8nvdax-24})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-26} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-24})])
                                                       (let ([tail #{hd dpuuv4a3mobea70icwo8nvdax-25}])
                                                         (if (null?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-26})
                                                             (begin
                                                               (append-reverse
                                                                 rhead
                                                                 (append
                                                                   tail
                                                                   sis)))
                                                             (begin
                                                               (let* ([next (c3-select-next
                                                                              tails)])
                                                                 (c3loop
                                                                   (cons
                                                                     next
                                                                     rhead)
                                                                   (remove-next!
                                                                     next
                                                                     tails)))))))
                                                     (begin
                                                       (let* ([next (c3-select-next
                                                                      tails)])
                                                         (c3loop
                                                           (cons
                                                             next
                                                             rhead)
                                                           (remove-next!
                                                             next
                                                             tails)))))))))]
                      [super-struct (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-27} sis])
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-27})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-28} (car #{match-val dpuuv4a3mobea70icwo8nvdax-27})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-29} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-27})])
                                            (let ([s #{hd dpuuv4a3mobea70icwo8nvdax-28}])
                                              (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-29}])
                                                (begin s))))
                                          (begin #f)))])
              (append1! rpls (reverse supers))
              (values precedence-list super-struct)))]))]
    [(rhead supers get-precedence-list struct? eq get-name)
     (cond
       [(null? supers) (values (reverse rhead) #f)]
       [(null? (cdr supers))
        (let ([pl (get-precedence-list (car supers))])
          (values (append-reverse rhead pl) (find struct? pl)))]
       [else
        (let ([pls (map get-precedence-list supers)] [sis (list)])
          (letrec* ([get-names (lambda (lst) (map get-name lst))]
                    [err (lambda a
                           (apply error "Inconsistent precedence graph" 'head:
                             (get-names (reverse rhead)) 'precedence-lists:
                             (map get-names pls)
                             'single-inheritance-suffix: (get-names sis)
                             a))]
                    [eqlist? (lambda (l1 l2)
                               (or (eq? l1 l2)
                                   (and (andmap eq l1 l2)
                                        (fx= (length l1) (length l2)))))]
                    [merge-sis! (lambda (sis2)
                                  (cond
                                    [(null? sis2) (void)]
                                    [(null? sis) (set! sis sis2)]
                                    [else
                                     (let loop ([t1 sis] [t2 sis2])
                                       (cond
                                         [(eqlist? t1 sis2) (void)]
                                         [(eqlist? t2 sis) (set! sis sis2)]
                                         [(null? t1)
                                          (if (memp
                                                (lambda (#{e dpuuv4a3mobea70icwo8nvdax-6})
                                                  (eq (car sis)
                                                      #{e dpuuv4a3mobea70icwo8nvdax-6}))
                                                t2)
                                              (set! sis sis2)
                                              (err 'struct-incompatibility:
                                                   (list
                                                     (get-names sis)
                                                     (get-names sis2))))]
                                         [(null? t2)
                                          (if (memp
                                                (lambda (#{e dpuuv4a3mobea70icwo8nvdax-7})
                                                  (eq (car sis2)
                                                      #{e dpuuv4a3mobea70icwo8nvdax-7}))
                                                t1)
                                              (void)
                                              (err 'struct-incompatibility:
                                                   (list
                                                     (get-names sis)
                                                     (get-names sis2))))]
                                         [else
                                          (loop (cdr t1) (cdr t2))]))]))]
                    [rpls (map (lambda (pl)
                                 (let-values ([(tl rh)
                                               (append-reverse-until
                                                 struct?
                                                 pl
                                                 (list))])
                                   (merge-sis! tl)
                                   rh))
                               pls)]
                    [unsisr-rpl (lambda (rpl)
                                  (let u ([pl-rhead rpl]
                                          [pl-tail (list)]
                                          [sis-rhead (reverse sis)]
                                          [sis-tail (list)])
                                    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-8} pl-rhead])
                                      (if (null?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                          (begin pl-tail)
                                          (if (pair?
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-8})
                                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-9} (car #{match-val dpuuv4a3mobea70icwo8nvdax-8})]
                                                    [#{tl dpuuv4a3mobea70icwo8nvdax-10} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-8})])
                                                (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-9}])
                                                  (let ([plrh #{tl dpuuv4a3mobea70icwo8nvdax-10}])
                                                    (begin
                                                      (if (memp
                                                            (lambda (#{e dpuuv4a3mobea70icwo8nvdax-11})
                                                              (eq c
                                                                  #{e dpuuv4a3mobea70icwo8nvdax-11}))
                                                            sis-tail)
                                                          (err 'precedence-list-head:
                                                               (get-names
                                                                 (reverse
                                                                   pl-rhead))
                                                               'precedence-list-tail:
                                                               (get-names
                                                                 pl-tail)
                                                               'single-inheritance-head:
                                                               (get-names
                                                                 (reverse
                                                                   sis-rhead))
                                                               'single-inheritance-tail:
                                                               (get-names
                                                                 sis-tail)
                                                               'super-out-of-order-vs-single-inheritance-tail:
                                                               (get-name
                                                                 c))
                                                          (let-values ([(sis-rh2 sis-tl2)
                                                                        (append-reverse-until
                                                                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-12})
                                                                            (eq c
                                                                                #{cut-arg dpuuv4a3mobea70icwo8nvdax-12}))
                                                                          sis-rhead
                                                                          sis-tail)])
                                                            (if (null?
                                                                  sis-rh2)
                                                                (u plrh
                                                                   (cons
                                                                     c
                                                                     pl-tail)
                                                                   (list)
                                                                   sis-tl2)
                                                                (u plrh
                                                                   pl-tail
                                                                   (cdr sis-rh2)
                                                                   sis-tl2))))))))
                                              (error 'match
                                                "no matching clause"
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-8}))))))]
                    [hpls (map unsisr-rpl rpls)]
                    [c3-select-next (lambda (tails)
                                      (let ([candidate? (lambda (c)
                                                          (andmap
                                                            (lambda (tail)
                                                              (not (memp
                                                                     (lambda (#{e dpuuv4a3mobea70icwo8nvdax-13})
                                                                       (eq c
                                                                           #{e dpuuv4a3mobea70icwo8nvdax-13}))
                                                                     (cdr tail))))
                                                            tails))])
                                        (let loop ([ts tails])
                                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-14} ts])
                                            (if (pair?
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-14})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-15} (car #{match-val dpuuv4a3mobea70icwo8nvdax-14})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-16} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-14})])
                                                  (if (pair?
                                                        #{hd dpuuv4a3mobea70icwo8nvdax-15})
                                                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-17} (car #{hd dpuuv4a3mobea70icwo8nvdax-15})]
                                                            [#{tl dpuuv4a3mobea70icwo8nvdax-18} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-15})])
                                                        (let ([c #{hd dpuuv4a3mobea70icwo8nvdax-17}])
                                                          (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-18}])
                                                            (let ([rts #{tl dpuuv4a3mobea70icwo8nvdax-16}])
                                                              (begin
                                                                (if (candidate?
                                                                      c)
                                                                    c
                                                                    (loop
                                                                      rts)))))))
                                                      (begin (err))))
                                                (begin (err)))))))]
                    [remove-next! (lambda (next tails)
                                    (let loop ([t tails])
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-19} t])
                                        (if (null?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                            (begin tails)
                                            (if (pair?
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-19})
                                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-20} (car #{match-val dpuuv4a3mobea70icwo8nvdax-19})]
                                                      [#{tl dpuuv4a3mobea70icwo8nvdax-21} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-19})])
                                                  (if (pair?
                                                        #{hd dpuuv4a3mobea70icwo8nvdax-20})
                                                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-22} (car #{hd dpuuv4a3mobea70icwo8nvdax-20})]
                                                            [#{tl dpuuv4a3mobea70icwo8nvdax-23} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-20})])
                                                        (let ([head #{hd dpuuv4a3mobea70icwo8nvdax-22}])
                                                          (let ([tail #{tl dpuuv4a3mobea70icwo8nvdax-23}])
                                                            (let ([more #{tl dpuuv4a3mobea70icwo8nvdax-21}])
                                                              (begin
                                                                (when (eq head
                                                                          next)
                                                                  (set-car!
                                                                    t
                                                                    tail))
                                                                (loop
                                                                  more))))))
                                                      (error 'match
                                                        "no matching clause"
                                                        #{match-val dpuuv4a3mobea70icwo8nvdax-19})))
                                                (error 'match
                                                  "no matching clause"
                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-19}))))))]
                    [precedence-list (let c3loop ([rhead rhead]
                                                  [tails hpls])
                                       (let ([tails (remove-nulls! tails)])
                                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-24} tails])
                                           (if (null?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                               (begin
                                                 (append-reverse
                                                   rhead
                                                   sis))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-24})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-25} (car #{match-val dpuuv4a3mobea70icwo8nvdax-24})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-26} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-24})])
                                                     (let ([tail #{hd dpuuv4a3mobea70icwo8nvdax-25}])
                                                       (if (null?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-26})
                                                           (begin
                                                             (append-reverse
                                                               rhead
                                                               (append
                                                                 tail
                                                                 sis)))
                                                           (begin
                                                             (let* ([next (c3-select-next
                                                                            tails)])
                                                               (c3loop
                                                                 (cons
                                                                   next
                                                                   rhead)
                                                                 (remove-next!
                                                                   next
                                                                   tails)))))))
                                                   (begin
                                                     (let* ([next (c3-select-next
                                                                    tails)])
                                                       (c3loop
                                                         (cons next rhead)
                                                         (remove-next!
                                                           next
                                                           tails)))))))))]
                    [super-struct (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-27} sis])
                                    (if (pair?
                                          #{match-val dpuuv4a3mobea70icwo8nvdax-27})
                                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-28} (car #{match-val dpuuv4a3mobea70icwo8nvdax-27})]
                                              [#{tl dpuuv4a3mobea70icwo8nvdax-29} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-27})])
                                          (let ([s #{hd dpuuv4a3mobea70icwo8nvdax-28}])
                                            (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-29}])
                                              (begin s))))
                                        (begin #f)))])
            (append1! rpls (reverse supers))
            (values precedence-list super-struct)))])]))

