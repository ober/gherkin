(begin
  (define identifier-wrap::t
    (make-class-type 'gerbil\x23;identifier-wrap::t 'identifier-wrap
      (list AST::t) '(marks)
      '((struct: . #t) (name: . syntax) (final: . #t)) '#f))
  (define (make-identifier-wrap . args)
    (let* ([type identifier-wrap::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (identifier-wrap? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;identifier-wrap::t))
  (define (identifier-wrap-marks obj)
    (unchecked-slot-ref obj 'marks))
  (define (identifier-wrap-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val))
  (define (&identifier-wrap-marks obj)
    (unchecked-slot-ref obj 'marks))
  (define (&identifier-wrap-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val)))

(begin
  (define syntax-wrap::t
    (make-class-type 'gerbil\x23;syntax-wrap::t 'syntax-wrap (list AST::t)
      '(mark) '((struct: . #t) (name: . syntax) (final: . #t))
      '#f))
  (define (make-syntax-wrap . args)
    (let* ([type syntax-wrap::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (syntax-wrap? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;syntax-wrap::t))
  (define (syntax-wrap-mark obj)
    (unchecked-slot-ref obj 'mark))
  (define (syntax-wrap-mark-set! obj val)
    (unchecked-slot-set! obj 'mark val))
  (define (&syntax-wrap-mark obj)
    (unchecked-slot-ref obj 'mark))
  (define (&syntax-wrap-mark-set! obj val)
    (unchecked-slot-set! obj 'mark val)))

(begin
  (define syntax-quote::t
    (make-class-type 'gerbil\x23;syntax-quote::t 'syntax-quote (list AST::t)
      '(context marks)
      '((struct: . #t) (name: . syntax) (final: . #t)) '#f))
  (define (make-syntax-quote . args)
    (let* ([type syntax-quote::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (syntax-quote? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;syntax-quote::t))
  (define (syntax-quote-context obj)
    (unchecked-slot-ref obj 'context))
  (define (syntax-quote-marks obj)
    (unchecked-slot-ref obj 'marks))
  (define (syntax-quote-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (syntax-quote-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val))
  (define (&syntax-quote-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&syntax-quote-marks obj)
    (unchecked-slot-ref obj 'marks))
  (define (&syntax-quote-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&syntax-quote-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val)))

(define (identifier? stx) (symbol? (stx-e stx)))

(define (identifier-quote? stx)
  (and (syntax-quote? stx) (symbol? (&AST-e stx))))

(define (sealed-syntax? stx)
  (cond
    [(syntax-quote? stx) #t]
    [(syntax-wrap? stx) (sealed-syntax? (&AST-e stx))]
    [else #f]))

(define (sealed-syntax-unwrap stx)
  (cond
    [(syntax-quote? stx) stx]
    [(syntax-wrap? stx) (sealed-syntax-unwrap (&AST-e stx))]
    [else #f]))

(define (syntax-e stx)
  (cond
    [(syntax-wrap? stx)
     (let lp ([e (&AST-e stx)]
              [marks (list (&syntax-wrap-mark stx))])
       (cond
         [(\x23;\x23;structure? e)
          (case (\x23;\x23;type-id (\x23;\x23;structure-type e))
            [(gx\x23;syntax-wrap::t)
             (lp (&AST-e e) (apply-mark (&syntax-wrap-mark e) marks))]
            [(gx\x23;syntax-quote::t gx\x23;identifier-wrap::t)
             (&AST-e e)]
            [(gerbil\x23;AST::t) (lp (&AST-e e) marks)]
            [else e])]
         [(null? marks) e]
         [(pair? e)
          (cons (stx-wrap (car e) marks) (stx-wrap (cdr e) marks))]
         [(vector? e)
          (vector-map
            (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-421})
              (stx-wrap #{cut-arg dpuuv4a3mobea70icwo8nvdax-421} marks))
            e)]
         [(box? e) (box (stx-wrap (unbox e) marks))]
         [else e]))]
    [(AST? stx) (&AST-e stx)]
    [else stx]))

(define (syntax->datum stx)
  (cond
    [(AST? stx) (syntax->datum (&AST-e stx))]
    [(pair? stx)
     (cons (syntax->datum (car stx)) (syntax->datum (cdr stx)))]
    [(vector? stx) (vector-map syntax->datum stx)]
    [(box? stx) (box (syntax->datum (unbox stx)))]
    [else stx]))

(define datum->syntax
  (case-lambda
    [(stx datum)
     (let* ([src #f] [quote? #t])
       (define (wrap-datum e marks)
         (wrap-inner
           e
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-422})
             (make-identifier-wrap
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-422}
               src
               marks))))
       (define (wrap-quote e ctx marks)
         (wrap-inner
           e
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-423})
             (make-syntax-quote
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-423}
               src
               ctx
               marks))))
       (define (wrap-inner e wrap-e)
         (let recur ([e e])
           (cond
             [(symbol? e) (wrap-e e)]
             [(pair? e) (cons (recur (car e)) (recur (cdr e)))]
             [(vector? e) (vector-map recur e)]
             [(box? e) (box (recur (unbox e)))]
             [else e])))
       (define (wrap-outer e) (if (AST? e) e (make-AST e src)))
       (cond
         [(AST? datum) datum]
         [(not stx) (make-AST datum src)]
         [(identifier? stx)
          (let ([stx (stx-unwrap stx)])
            (wrap-outer
              (if (syntax-quote? stx)
                  (if quote?
                      (wrap-quote
                        datum
                        (&syntax-quote-context stx)
                        (&syntax-quote-marks stx))
                      (wrap-datum datum (&syntax-quote-marks stx)))
                  (wrap-datum datum (&identifier-wrap-marks stx)))))]
         [else
          (error 'gerbil
            "Bad template syntax; expected identifier"
            stx)]))]
    [(stx datum src)
     (let* ([quote? #t])
       (define (wrap-datum e marks)
         (wrap-inner
           e
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-422})
             (make-identifier-wrap
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-422}
               src
               marks))))
       (define (wrap-quote e ctx marks)
         (wrap-inner
           e
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-423})
             (make-syntax-quote
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-423}
               src
               ctx
               marks))))
       (define (wrap-inner e wrap-e)
         (let recur ([e e])
           (cond
             [(symbol? e) (wrap-e e)]
             [(pair? e) (cons (recur (car e)) (recur (cdr e)))]
             [(vector? e) (vector-map recur e)]
             [(box? e) (box (recur (unbox e)))]
             [else e])))
       (define (wrap-outer e) (if (AST? e) e (make-AST e src)))
       (cond
         [(AST? datum) datum]
         [(not stx) (make-AST datum src)]
         [(identifier? stx)
          (let ([stx (stx-unwrap stx)])
            (wrap-outer
              (if (syntax-quote? stx)
                  (if quote?
                      (wrap-quote
                        datum
                        (&syntax-quote-context stx)
                        (&syntax-quote-marks stx))
                      (wrap-datum datum (&syntax-quote-marks stx)))
                  (wrap-datum datum (&identifier-wrap-marks stx)))))]
         [else
          (error 'gerbil
            "Bad template syntax; expected identifier"
            stx)]))]
    [(stx datum src quote?)
     (define (wrap-datum e marks)
       (wrap-inner
         e
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-422})
           (make-identifier-wrap
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-422}
             src
             marks))))
     (define (wrap-quote e ctx marks)
       (wrap-inner
         e
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-423})
           (make-syntax-quote
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-423}
             src
             ctx
             marks))))
     (define (wrap-inner e wrap-e)
       (let recur ([e e])
         (cond
           [(symbol? e) (wrap-e e)]
           [(pair? e) (cons (recur (car e)) (recur (cdr e)))]
           [(vector? e) (vector-map recur e)]
           [(box? e) (box (recur (unbox e)))]
           [else e])))
     (define (wrap-outer e) (if (AST? e) e (make-AST e src)))
     (cond
       [(AST? datum) datum]
       [(not stx) (make-AST datum src)]
       [(identifier? stx)
        (let ([stx (stx-unwrap stx)])
          (wrap-outer
            (if (syntax-quote? stx)
                (if quote?
                    (wrap-quote
                      datum
                      (&syntax-quote-context stx)
                      (&syntax-quote-marks stx))
                    (wrap-datum datum (&syntax-quote-marks stx)))
                (wrap-datum datum (&identifier-wrap-marks stx)))))]
       [else
        (error 'gerbil
          "Bad template syntax; expected identifier"
          stx)])]))

(define stx-unwrap
  (case-lambda
    [(stx)
     (let* ([marks (list)])
       (let lp ([e stx] [marks marks] [src (stx-source stx)])
         (cond
           [(syntax-wrap? e)
            (lp (&AST-e e)
                (apply-mark (&syntax-wrap-mark e) marks)
                (&AST-source e))]
           [(identifier-wrap? e)
            (if (null? marks)
                e
                (make-identifier-wrap
                  (&AST-e e)
                  (&AST-source e)
                  (let ([#{f dpuuv4a3mobea70icwo8nvdax-424} apply-mark])
                    (fold-left
                      (lambda (#{a dpuuv4a3mobea70icwo8nvdax-425}
                               #{e dpuuv4a3mobea70icwo8nvdax-426})
                        (#{f dpuuv4a3mobea70icwo8nvdax-424}
                          #{e dpuuv4a3mobea70icwo8nvdax-426}
                          #{a dpuuv4a3mobea70icwo8nvdax-425}))
                      (&identifier-wrap-marks e)
                      marks))))]
           [(syntax-quote? e) e]
           [(AST? e) (lp (&AST-e e) marks (&AST-source e))]
           [(symbol? e) (make-identifier-wrap e src (reverse marks))]
           [(null? marks) e]
           [(pair? e)
            (cons (stx-wrap (car e) marks) (stx-wrap (cdr e) marks))]
           [(vector? e)
            (vector-map
              (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-427})
                (stx-wrap #{cut-arg dpuuv4a3mobea70icwo8nvdax-427} marks))
              e)]
           [(box? e) (box (stx-wrap (unbox e) marks))]
           [else e])))]
    [(stx marks)
     (let lp ([e stx] [marks marks] [src (stx-source stx)])
       (cond
         [(syntax-wrap? e)
          (lp (&AST-e e)
              (apply-mark (&syntax-wrap-mark e) marks)
              (&AST-source e))]
         [(identifier-wrap? e)
          (if (null? marks)
              e
              (make-identifier-wrap
                (&AST-e e)
                (&AST-source e)
                (let ([#{f dpuuv4a3mobea70icwo8nvdax-424} apply-mark])
                  (fold-left
                    (lambda (#{a dpuuv4a3mobea70icwo8nvdax-425}
                             #{e dpuuv4a3mobea70icwo8nvdax-426})
                      (#{f dpuuv4a3mobea70icwo8nvdax-424}
                        #{e dpuuv4a3mobea70icwo8nvdax-426}
                        #{a dpuuv4a3mobea70icwo8nvdax-425}))
                    (&identifier-wrap-marks e)
                    marks))))]
         [(syntax-quote? e) e]
         [(AST? e) (lp (&AST-e e) marks (&AST-source e))]
         [(symbol? e) (make-identifier-wrap e src (reverse marks))]
         [(null? marks) e]
         [(pair? e)
          (cons (stx-wrap (car e) marks) (stx-wrap (cdr e) marks))]
         [(vector? e)
          (vector-map
            (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-427})
              (stx-wrap #{cut-arg dpuuv4a3mobea70icwo8nvdax-427} marks))
            e)]
         [(box? e) (box (stx-wrap (unbox e) marks))]
         [else e]))]))

(define (stx-wrap stx marks)
  (let ([#{f dpuuv4a3mobea70icwo8nvdax-428} (lambda (mark stx)
                                              (stx-apply-mark stx mark))])
    (fold-left
      (lambda (#{a dpuuv4a3mobea70icwo8nvdax-429}
               #{e dpuuv4a3mobea70icwo8nvdax-430})
        (#{f dpuuv4a3mobea70icwo8nvdax-428}
          #{e dpuuv4a3mobea70icwo8nvdax-430}
          #{a dpuuv4a3mobea70icwo8nvdax-429}))
      stx
      marks)))

(define (stx-rewrap stx marks)
  (fold-right
    (lambda (mark stx) (stx-apply-mark stx mark))
    stx
    marks))

(define (stx-apply-mark stx mark)
  (cond
    [(syntax-quote? stx) stx]
    [(and (syntax-wrap? stx) (eq? mark (&syntax-wrap-mark stx)))
     (&AST-e stx)]
    [else (make-syntax-wrap stx (stx-source stx) mark)]))

(define (apply-mark mark marks)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-431} marks])
    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-431})
        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-432} (car #{match-val dpuuv4a3mobea70icwo8nvdax-431})]
              [#{tl dpuuv4a3mobea70icwo8nvdax-433} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-431})])
          (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-432}])
            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-433}])
              (begin (if (eq? mark hd) rest (cons mark marks))))))
        (begin (cons mark marks)))))

(define (stx-e stx)
  (cond
    [(syntax-wrap? stx) (stx-e (&AST-e stx))]
    [(AST? stx) (&AST-e stx)]
    [else stx]))

(define (stx-source stx) (and (AST? stx) (&AST-source stx)))

(define (stx-wrap-source stx src)
  (if (or (AST? stx) (not src)) stx (make-AST stx src)))

(define (stx-datum? stx) (self-quoting? (stx-e stx)))

(define (self-quoting? x)
  (or (immediate? x)
      (number? x)
      (keyword? x)
      (string? x)
      (vector? x)
      (u8vector? x)))

(define (stx-boolean? e) (boolean? (stx-e e)))

(define (stx-keyword? e) (keyword? (stx-e e)))

(define (stx-char? e) (char? (stx-e e)))

(define (stx-number? e) (number? (stx-e e)))

(define (stx-fixnum? e) (fixnum? (stx-e e)))

(define (stx-string? e) (string? (stx-e e)))

(define (stx-null? e) (null? (stx-e e)))

(define (stx-pair? e) (pair? (stx-e e)))

(define (stx-list? e)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-434} (stx-e
                                                      e)])
    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-434})
        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-435} (car #{match-val dpuuv4a3mobea70icwo8nvdax-434})]
              [#{tl dpuuv4a3mobea70icwo8nvdax-436} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-434})])
          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-436}])
            (begin (stx-list? rest))))
        (let ([tail #{match-val dpuuv4a3mobea70icwo8nvdax-434}])
          (null? tail)))))

(define (stx-pair/null? e)
  (let ([e (stx-e e)]) (or (pair? e) (null? e))))

(define (stx-vector? e) (vector? (stx-e e)))

(define (stx-box? e) (box? (stx-e e)))

(define (stx-eq? x y) (eq? (stx-e x) (stx-e y)))

(define (stx-eqv? x y) (eqv? (stx-e x) (stx-e y)))

(define (stx-equal? x y) (equal? (stx-e x) (stx-e y)))

(define (stx-false? x) (not (stx-e x)))

(define (stx-identifier template . args)
  (datum->syntax
    template
    (apply make-symbol (syntax->datum args))
    (stx-source template)))

(define (stx-identifier-marks stx)
  (stx-identifier-marks* (stx-unwrap stx)))

(define (stx-identifier-marks* stx)
  (cond
    [(identifier-wrap? stx) (&identifier-wrap-marks stx)]
    [(syntax-quote? stx) (&syntax-quote-marks stx)]
    [else
     (error 'gerbil
       "Bad wrap; expected unwrapped identifier"
       stx)]))

(define (stx-identifier-context stx)
  (let ([stx (stx-unwrap stx)])
    (and (identifier-quote? stx) (&syntax-quote-context stx))))

(define (identifier-list? stx)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-437} (stx-e
                                                      stx)])
    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-437})
        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-438} (car #{match-val dpuuv4a3mobea70icwo8nvdax-437})]
              [#{tl dpuuv4a3mobea70icwo8nvdax-439} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-437})])
          (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-438}])
            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-439}])
              (begin (and (identifier? hd) (identifier-list? rest))))))
        (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-437})
            (begin #t)
            (begin #f)))))

(define genident
  (case-lambda
    [()
     (let* ([e 'g] [src #f])
       (stx-wrap-source
         (gensym
           (let ([x (let ([e (stx-e e)])
                      (if (interned-symbol? e) e 'g))])
             (if (symbol? x) (symbol->string x) x)))
         (or (stx-source e) src)))]
    [(e)
     (let* ([src #f])
       (stx-wrap-source
         (gensym
           (let ([x (let ([e (stx-e e)])
                      (if (interned-symbol? e) e 'g))])
             (if (symbol? x) (symbol->string x) x)))
         (or (stx-source e) src)))]
    [(e src)
     (stx-wrap-source
       (gensym
         (let ([x (let ([e (stx-e e)])
                    (if (interned-symbol? e) e 'g))])
           (if (symbol? x) (symbol->string x) x)))
       (or (stx-source e) src))]))

(define (gentemps stx-lst) (stx-map genident stx-lst))

(define (syntax->list stx) (stx-map values stx))

(define (stx-car stx) (void) (car (syntax-e stx)))

(define (stx-cdr stx) (void) (cdr (syntax-e stx)))

(define (stx-length stx)
  (let lp ([rest stx] [n 0])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-440} (stx-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-440})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-441} (car #{match-val dpuuv4a3mobea70icwo8nvdax-440})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-442} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-440})])
            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-442}])
              (begin (lp rest (fx1+ n)))))
          (begin n)))))

(define stx-for-each
  (case-lambda
    [(f stx) (stx-for-each1 f stx)]
    [(f xstx ystx) (stx-for-each2 f xstx ystx)]))

(define (stx-for-each1 f stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let lp ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-443} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-443})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-444} (car #{match-val dpuuv4a3mobea70icwo8nvdax-443})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-445} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-443})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-444}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-445}])
                (begin (f hd) (lp rest)))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-443})
              (begin (%%void))
              (begin (f rest)))))))

(define (stx-for-each2 f xstx ystx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let lp ([xrest xstx] [yrest ystx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-446} (syntax-e
                                                        xrest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-446})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-447} (car #{match-val dpuuv4a3mobea70icwo8nvdax-446})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-448} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-446})])
            (let ([xhd #{hd dpuuv4a3mobea70icwo8nvdax-447}])
              (let ([xrest #{tl dpuuv4a3mobea70icwo8nvdax-448}])
                (begin
                  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-449} (syntax-e
                                                                      yrest)])
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-449})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-450} (car #{match-val dpuuv4a3mobea70icwo8nvdax-449})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-451} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-449})])
                          (let ([yhd #{hd dpuuv4a3mobea70icwo8nvdax-450}])
                            (let ([yrest #{tl dpuuv4a3mobea70icwo8nvdax-451}])
                              (begin (f xhd yhd) (lp xrest yrest)))))
                        (error 'match
                          "no matching clause"
                          #{match-val dpuuv4a3mobea70icwo8nvdax-449})))))))
          (if (not (null? #{match-val dpuuv4a3mobea70icwo8nvdax-446}))
              (begin
                (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-452} yrest])
                  (if (not (stx-null?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-452}))
                      (begin (f xrest yrest))
                      (error 'match
                        "no matching clause"
                        #{match-val dpuuv4a3mobea70icwo8nvdax-452}))))
              (begin (%%void)))))))

(define stx-map
  (case-lambda
    [(f stx) (stx-map1 f stx)]
    [(f xstx ystx) (stx-map2 f xstx ystx)]))

(define (stx-map1 f stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let recur ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-453} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-453})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-454} (car #{match-val dpuuv4a3mobea70icwo8nvdax-453})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-455} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-453})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-454}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-455}])
                (begin (cons (f hd) (recur rest))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-453})
              (begin (list))
              (begin (f rest)))))))

(define (stx-map2 f xstx ystx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let recur ([xrest xstx] [yrest ystx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-456} (syntax-e
                                                        xrest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-456})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-457} (car #{match-val dpuuv4a3mobea70icwo8nvdax-456})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-458} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-456})])
            (let ([xhd #{hd dpuuv4a3mobea70icwo8nvdax-457}])
              (let ([xrest #{tl dpuuv4a3mobea70icwo8nvdax-458}])
                (begin
                  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-459} (syntax-e
                                                                      yrest)])
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-459})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-460} (car #{match-val dpuuv4a3mobea70icwo8nvdax-459})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-461} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-459})])
                          (let ([yhd #{hd dpuuv4a3mobea70icwo8nvdax-460}])
                            (let ([yrest #{tl dpuuv4a3mobea70icwo8nvdax-461}])
                              (begin
                                (cons (f xhd yhd) (recur xrest yrest))))))
                        (error 'match
                          "no matching clause"
                          #{match-val dpuuv4a3mobea70icwo8nvdax-459})))))))
          (if (not (null? #{match-val dpuuv4a3mobea70icwo8nvdax-456}))
              (begin
                (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-462} yrest])
                  (if (not (stx-null?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-462}))
                      (begin (f xrest yrest))
                      (error 'match
                        "no matching clause"
                        #{match-val dpuuv4a3mobea70icwo8nvdax-462}))))
              (begin (list)))))))

(define (stx-andmap f stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let lp ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-463} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-463})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-464} (car #{match-val dpuuv4a3mobea70icwo8nvdax-463})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-465} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-463})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-464}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-465}])
                (begin (and (f hd) (lp rest))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-463})
              (begin #t)
              (begin (f rest)))))))

(define (stx-ormap f stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let lp ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-466} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-466})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-467} (car #{match-val dpuuv4a3mobea70icwo8nvdax-466})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-468} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-466})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-467}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-468}])
                (begin (or (f hd) (lp rest))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-466})
              (begin #f)
              (begin (f rest)))))))

(define (stx-foldl f iv stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let lp ([r iv] [rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-469} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-469})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-470} (car #{match-val dpuuv4a3mobea70icwo8nvdax-469})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-471} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-469})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-470}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-471}])
                (begin (lp (f hd r) rest)))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-469})
              (begin r)
              (begin (f rest r)))))))

(define (stx-foldr f iv stx)
  (unless (procedure? f)
    (error 'gerbil "expected procedure" f))
  (let recur ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-472} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-472})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-473} (car #{match-val dpuuv4a3mobea70icwo8nvdax-472})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-474} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-472})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-473}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-474}])
                (begin (f hd (recur rest))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-472})
              (begin iv)
              (begin (f rest iv)))))))

(define (stx-reverse stx) (stx-foldl cons (list) stx))

(define (stx-last stx)
  (let lp ([rest stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-475} (syntax-e
                                                        rest)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-475})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-476} (car #{match-val dpuuv4a3mobea70icwo8nvdax-475})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-477} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-475})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-476}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-477}])
                (begin (if (stx-null? rest) hd (lp rest))))))
          (begin rest)))))

(define (stx-last-pair stx)
  (let lp ([hd stx])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-478} (syntax-e
                                                        hd)])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-478})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-479} (car #{match-val dpuuv4a3mobea70icwo8nvdax-478})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-480} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-478})])
            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-480}])
              (begin (if (stx-pair? rest) (lp rest) hd))))
          (error 'match
            "no matching clause"
            #{match-val dpuuv4a3mobea70icwo8nvdax-478})))))

(define (stx-list-tail stx k)
  (let lp ([rest stx] [k k])
    (if (fxpositive? k)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-481} (syntax-e
                                                            rest)])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-481})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-482} (car #{match-val dpuuv4a3mobea70icwo8nvdax-481})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-483} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-481})])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-483}])
                  (begin (lp rest (fx1- k)))))
              (error 'match
                "no matching clause"
                #{match-val dpuuv4a3mobea70icwo8nvdax-481})))
        rest)))

(define (stx-list-ref stx k)
  (stx-car (stx-list-tail stx k)))

(define stx-plist?
  (case-lambda
    [(stx)
     (let* ([key? stx-keyword?])
       (unless (procedure? key?)
         (error 'gerbil "expected procedure" key?))
       (let lp ([rest stx])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-484} (stx-e
                                                             rest)])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-484})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-485} (car #{match-val dpuuv4a3mobea70icwo8nvdax-484})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-486} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-484})])
                 (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-485}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-486}])
                     (begin
                       (and (key? hd)
                            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-487} (stx-e
                                                                                rest)])
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-487})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-488} (car #{match-val dpuuv4a3mobea70icwo8nvdax-487})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-489} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-487})])
                                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-489}])
                                      (begin (lp rest))))
                                  (begin #f))))))))
               (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-484})
                   (begin #t)
                   (begin #f))))))]
    [(stx key?)
     (unless (procedure? key?)
       (error 'gerbil "expected procedure" key?))
     (let lp ([rest stx])
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-484} (stx-e
                                                           rest)])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-484})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-485} (car #{match-val dpuuv4a3mobea70icwo8nvdax-484})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-486} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-484})])
               (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-485}])
                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-486}])
                   (begin
                     (and (key? hd)
                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-487} (stx-e
                                                                              rest)])
                            (if (pair?
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-487})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-488} (car #{match-val dpuuv4a3mobea70icwo8nvdax-487})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-489} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-487})])
                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-489}])
                                    (begin (lp rest))))
                                (begin #f))))))))
             (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-484})
                 (begin #t)
                 (begin #f)))))]))

(define stx-getq
  (case-lambda
    [(key stx)
     (let* ([key=? stx-eq?])
       (unless (procedure? key=?)
         (error 'gerbil "expected procedure" key=?))
       (let lp ([rest stx])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-490} (syntax-e
                                                             rest)])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-490})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-491} (car #{match-val dpuuv4a3mobea70icwo8nvdax-490})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-492} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-490})])
                 (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-491}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-492}])
                     (begin
                       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-493} (syntax-e
                                                                           rest)])
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-493})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-494} (car #{match-val dpuuv4a3mobea70icwo8nvdax-493})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-495} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-493})])
                               (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-494}])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-495}])
                                   (begin
                                     (if (key=? hd key) val (lp rest))))))
                             (error 'match
                               "no matching clause"
                               #{match-val dpuuv4a3mobea70icwo8nvdax-493})))))))
               (begin #f)))))]
    [(key stx key=?)
     (unless (procedure? key=?)
       (error 'gerbil "expected procedure" key=?))
     (let lp ([rest stx])
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-490} (syntax-e
                                                           rest)])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-490})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-491} (car #{match-val dpuuv4a3mobea70icwo8nvdax-490})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-492} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-490})])
               (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-491}])
                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-492}])
                   (begin
                     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-493} (syntax-e
                                                                         rest)])
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-493})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-494} (car #{match-val dpuuv4a3mobea70icwo8nvdax-493})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-495} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-493})])
                             (let ([val #{hd dpuuv4a3mobea70icwo8nvdax-494}])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-495}])
                                 (begin
                                   (if (key=? hd key) val (lp rest))))))
                           (error 'match
                             "no matching clause"
                             #{match-val dpuuv4a3mobea70icwo8nvdax-493})))))))
             (begin #f))))]))

