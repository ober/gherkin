(begin
  (define AST::t
    (make-class-type 'gerbil\x23;AST::t 'AST (list object::t) '(e source)
      '((struct: . #t)
         (id: . gerbil\x23;AST::t)
         (name: . syntax)
         (print: e))
      '#f))
  (define (make-AST . args)
    (let* ([type AST::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (AST? obj)
    (\x23;\x23;structure-instance-of? obj 'gerbil\x23;AST::t))
  (define (AST-e obj) (unchecked-slot-ref obj 'e))
  (define (AST-source obj) (unchecked-slot-ref obj 'source))
  (define (AST-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (AST-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (&AST-e obj) (unchecked-slot-ref obj 'e))
  (define (&AST-source obj) (unchecked-slot-ref obj 'source))
  (define (&AST-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&AST-source-set! obj val)
    (unchecked-slot-set! obj 'source val)))

(define-syntax check-procedure
  (syntax-rules ()
    [(_ proc)
     (unless (procedure? proc)
       (error "expected procedure" proc))]))

(define-syntax core-syntax-case
  (lambda (stx)
    (define (generate tgt kws clauses)
      (define (generate-clause hd E)
        (syntax-case hd ()
          [(pat body) (generate1 hd #'pat #t #'body E)]
          [(pat fender body) (generate1 hd #'pat #'fender #'body E)]
          [_
           (raise-syntax-error
             #f
             "Bad syntax; invalid syntax-case pattern"
             stx
             hd)]))
      (define (generate1 where hd fender body E)
        (define (recur hd tgt K)
          (syntax-case hd ()
            [(hd-first . hd-rest)
             (with-syntax*
               ((target tgt) ($e (genident 'e)) ($hd (genident 'hd))
                 ($tl (genident 'tl))
                 (K (recur #'hd-first #'$hd (recur #'hd-rest #'$tl K)))
                 (E E))
               #'(if (stx-pair? target)
                     (let ([$e (syntax-e target)])
                       (let ([$hd (\x23;\x23;car $e)]
                             [$tl (\x23;\x23;cdr $e)])
                         K))
                     E))]
            [_
             (cond
               [(identifier? hd)
                (cond
                  [(underscore? hd) K]
                  [(find (cut bound-identifier=? <> hd) kws)
                   (with-syntax ([target tgt] [id hd])
                     (\x40;list
                       #'if
                       #'(and (identifier? target)
                              (core-identifier=? target 'id))
                       K
                       E))]
                  [else
                   (with-syntax ([target tgt] [id hd])
                     (\x40;list #'let #'((id target)) K))])]
               [(stx-null? hd)
                (with-syntax ([target tgt])
                  (\x40;list #'if #'(stx-null? target) K E))]
               [(stx-datum? hd)
                (with-syntax ([target tgt]
                              [datum hd]
                              [eql (let (e [stx-e hd])
                                     (cond
                                       [(or (keyword? e) (immediate? e))
                                        #'eq?]
                                       [(number? e) #'eqv?]
                                       [else #'equal?]))])
                  (\x40;list #'if #'(eql (stx-e target) 'datum) K E))]
               [else
                (raise-syntax-error #f
                  "Bad syntax; invalid syntax-case head" stx where hd)])]))
        (recur hd tgt (list #'if fender body E)))
      (define (generate-clauses clauses)
        (let lp ([rest clauses] [E (genident 'E)] [r (list)])
          (syntax-case rest ()
            [(hd . rest)
             (syntax-case #'hd (else)
               [(else . body)
                (if (stx-null? #'rest)
                    (if (and (stx-list? #'body) (not (stx-null? #'body)))
                        (cons
                          (\x40;list
                            E
                            (stx-wrap-source
                              #'(lambda () (begin . body))
                              (stx-source #'hd)))
                          r)
                        (raise-syntax-error
                          #f
                          "Bad syntax; invalid else body"
                          stx
                          #'hd))
                    (raise-syntax-error
                      #f
                      "Bad syntax; misplaced else"
                      stx
                      #'hd))]
               [_
                (with-syntax*
                  (($E (genident 'E))
                    (body (generate-clause #'hd #'($E)))
                    (try (stx-wrap-source
                           #'(lambda () body)
                           (stx-source #'hd))))
                  (lp #'rest #'$E (cons (\x40;list E #'try) r)))])]
            [_
             (with-syntax ([target tgt])
               (cons
                 (\x40;list
                   E
                   (stx-wrap-source
                     #'(lambda ()
                         (raise-syntax-error
                           #f
                           "Bad syntax; invalid syntax-case clause"
                           target))
                     (stx-source stx)))
                 r))])))
      (with-syntax*
        (((values bind) (generate-clauses clauses))
          ((bind-try ...) bind)
          (K (car (last bind))))
        #'(let* (bind-try ...) (K))))
    (syntax-case stx ()
      [(_ expr kws . clauses)
       (and (identifier-list? #'kws) (stx-list? #'clauses))
       (with-syntax*
         (($e (genident 'e))
           (body (generate #'$e (syntax->list #'kws) #'clauses)))
         #'(let ([$e expr]) body))])))

