(begin
  (define defalias define-alias)
  (define-syntax defrules
    (syntax-rules ()
      [(_ id kws clauses ...)
       (identifier? #'id)
       (define-syntax id (syntax-rules kws clauses ...))]))
  (define define-rules defrules)
  (define-syntax defrule
    (syntax-rules ()
      [(_ (name . args) body)
       (define-syntax name (syntax-rules () [(_ . args) body]))]
      [(_ (name . args) fender body)
       (define-syntax name
         (syntax-rules () [(_ . args) fender body]))]))
  (define-syntax defsyntax%
    (syntax-rules ()
      [(_ (id . args) body ...)
       (define-syntax id (lambda% args body ...))]
      [(_ id expr) (define-syntax id expr)]))
  (define-syntax define
    (syntax-rules ()
      [(_ (id . args) body ...)
       (define-values (id) (lambda% args body ...))]
      [(_ id expr) (define-values (id) expr)]))
  (define-syntax let*-values
    (syntax-rules ()
      [(_ () body ...) (let-values () body ...)]
      [(recur (hd . rest) body ...)
       (let-values (hd) (recur rest body ...))]))
  (define-syntax let
    (syntax-rules ()
      [(_ id ((var arg) ... . rest) body ...)
       ((letrec-values
          (((id) (lambda% (var ... . rest) body ...)))
          id)
         arg
         ...)]
      [(_ hd body ...) (~let let-values hd body ...)]))
  (define-syntax let*
    (syntax-rules ()
      [(_ hd body ...) (~let let*-values hd body ...)]))
  (define-syntax letrec
    (syntax-rules ()
      [(_ hd body ...) (~let letrec-values hd body ...)]))
  (define-syntax letrec*
    (syntax-rules ()
      [(_ hd body ...) (~let letrec*-values hd body ...)]))
  (defsyntax%
    (~let stx)
    (define-values (let-head?)
      (lambda (x)
        (syntax-case x (values)
          [(values . ids) (stx-andmap identifier? #'ids)]
          [_ (identifier? x)])))
    (define-values (let-head)
      (lambda (x)
        (syntax-case x (values)
          [(values . ids) #'ids]
          [_ (list x)])))
    (syntax-case stx ()
      [(recur form (hd e) . body)
       (let-head? #'hd)
       #'(recur form ((hd e)) . body)]
      [(_ form ((hd e) ...) body ...)
       (stx-andmap let-head? #'(hd ...))
       (with-syntax ([(hd-bind ...) (stx-map let-head #'(hd ...))])
         #'(form ((hd-bind e) ...) body ...))]))
  (define-syntax and
    (syntax-rules ()
      [(_) #t]
      [(_ x) x]
      [(recur x . rest) (if x (recur . rest) #f)]))
  (define-syntax or
    (syntax-rules ()
      [(_) #f]
      [(_ x) x]
      [(recur x . rest) (let ($e x) (if $e $e (recur . rest)))]))
  (define-syntax cond
    (syntax-rules (else =>)
      [(_) (%%void)]
      [(_ (else body ...)) (let () body ...)]
      [(_ (else . _) . _)
       (syntax-error "bad syntax; misplaced else")]
      [(recur (test) . rest)
       (let ($e test) (if $e $e (recur . rest)))]
      [(recur (test => K) . rest)
       (let ($e test) (if $e (K $e) (recur . rest)))]
      [(recur (test body ...) . rest)
       (if test (let () body ...) (recur . rest))]))
  (define-syntax when
    (syntax-rules ()
      [(_ test expr rest ...)
       (if test (begin expr rest ...) (%%void))]))
  (define-syntax unless
    (syntax-rules ()
      [(_ test expr rest ...)
       (if test (%%void) (begin expr rest ...))]))
  (defsyntax%
    (syntax-error stx)
    (syntax-case stx ()
      [(_ message detail ...)
       (stx-string? #'message)
       (apply raise-syntax-error #f (stx-e #'message) stx
         (syntax->list #'(detail ...)))]))
  (define-syntax compilation-target?
    (syntax-rules ()
      [(_ sym) (eq? (current-compilation-target) 'sym)])))

(begin
  (define-syntax lambda
    (lambda (stx)
      (define (simple-lambda? hd) (stx-andmap identifier? hd))
      (define (opt-lambda? hd)
        (let lp ([rest hd] [opt? #f])
          (syntax-case rest ()
            [(hd . hd-rest)
             (syntax-case #'hd ()
               [(id _) (identifier? #'id) (lp #'hd-rest #t)]
               [_ (and (identifier? #'hd) (not opt?) (lp #'hd-rest #f))])]
            [_ (and opt? (or (stx-null? rest) (identifier? rest)))])))
      (define (opt-lambda-split hd)
        (let lp ([rest hd] [pre '()] [opt '()])
          (syntax-case rest ()
            [(hd . hd-rest)
             (syntax-case #'hd ()
               [(id e) (lp #'hd-rest pre (cons (cons #'id #'e) opt))]
               [_ (lp #'hd-rest (cons #'hd pre) opt)])]
            [_ (values (reverse pre) (reverse opt) rest)])))
      (define (kw-lambda? hd)
        (let lp ([rest hd] [opt? #f] [key? #f])
          (syntax-case rest ()
            [(key bind . hd-rest)
             (stx-keyword? #'key)
             (syntax-case #'bind ()
               [(id _) (and (identifier? #'id) (lp #'hd-rest opt? #t))]
               [_ (and (identifier? #'bind) (lp #'hd-rest opt? #t))])]
            [(key: id . hd-rest)
             (and (identifier? #'id) (lp #'hd-rest opt? #t))]
            [(hd . hd-rest)
             (syntax-case #'hd ()
               [(id _) (and (identifier? #'id) (lp #'hd-rest #t key?))]
               [_
                (and (identifier? #'hd)
                     (not opt?)
                     (lp #'hd-rest #f key?))])]
            [_ (and key? (or (stx-null? rest) (identifier? rest)))])))
      (define (kw-lambda-split hd)
        (let lp ([rest hd] [kwvar #f] [kwargs '()] [args '()])
          (syntax-case rest ()
            [(kw bind . hd-rest)
             (stx-keyword? #'kw)
             (let (key [stx-e #'kw])
               (if (find (lambda% (kwarg) (eq? key (car kwarg))) kwargs)
                   (raise-syntax-error #f
                     "bad syntax; duplicate keyword argument" stx hd key)
                   (syntax-case #'bind ()
                     [(id default)
                      (lp #'hd-rest
                          kwvar
                          (cons (list key #'id #'default) kwargs)
                          args)]
                     [_
                      (lp #'hd-rest
                          kwvar
                          (cons
                            (list
                              key
                              #'bind
                              #'(error "Missing required keyword argument"
                                  kw))
                            kwargs)
                          args)])))]
            [(key: id . hd-rest)
             (if kwvar
                 (raise-syntax-error #f
                   "bad syntax; duplicate #!key argument" stx hd #'id)
                 (lp #'hd-rest #'id kwargs args))]
            [(hd . hd-rest)
             (lp #'hd-rest kwvar kwargs (cons #'hd args))]
            [_
             (values kwvar (reverse kwargs) (foldl cons rest args))])))
      (define (check-duplicate-bindings hd)
        (let lp ([rest hd] [ids '()])
          (syntax-case rest ()
            [(hd . hd-rest)
             (cond
               [(identifier? #'hd) (lp #'hd-rest (cons #'hd ids))]
               [(stx-pair? #'hd)
                (syntax-case #'hd ()
                  [(id _) (lp #'hd-rest (cons #'id ids))])]
               [(stx-keyword? #'hd)
                (syntax-case #'hd-rest ()
                  [(hd . hd-rest)
                   (syntax-case #'hd ()
                     [(id _) (lp #'hd-rest (cons #'id ids))]
                     [_ (lp #'hd-rest (cons #'hd ids))])])]
               [(eq? (stx-e #'hd) key:)
                (syntax-case #'hd-rest ()
                  [(id . hd-rest) (lp #'hd-rest (cons #'id ids))])]
               [else (error "BUG: check-duplicate-bindings" stx rest)])]
            [_
             (check-duplicate-identifiers
               (if (stx-null? rest) ids (cons rest ids))
               stx)])))
      (define (generate-opt-primary pre opt tail body)
        (with-syntax ([(pre ...) pre]
                      [(opt ...) (map car opt)]
                      [tail tail]
                      [body body])
          #'(lambda% (pre ... opt ... . tail) . body)))
      (define (generate-opt-dispatch primary pre opt tail)
        (cons
          (list pre (generate-opt-clause primary pre opt))
          (generate-opt-dispatch* primary pre opt tail)))
      (define (generate-opt-dispatch* primary pre opt tail)
        (let recur ([opt-rest opt] [right '()])
          (cond
            [(pair? opt-rest)
             (with-syntax*
               (((values hd) (caar opt-rest)) ((values rest) (cdr opt-rest))
                 ((values right*) (cons hd right)) ((pre-bind ...) pre)
                 ((opt-bind ...) (reverse right)) (bind hd))
               (cons
                 (list
                   #'(pre-bind ... opt-bind ... bind)
                   (generate-opt-clause
                     primary
                     (foldr cons (reverse right*) pre)
                     rest))
                 (recur rest right*)))]
            [(stx-null? tail) '()]
            [else
             (with-syntax ([(pre ...) pre]
                           [(opt ...) (reverse right)]
                           [tail tail]
                           [primary primary])
               (list
                 (list
                   #'(pre ... opt ... . tail)
                   (syntax/loc
                     stx
                     (apply primary pre ... opt ... tail)))))])))
      (define (generate-opt-clause primary pre opt)
        (let recur ([opt-rest opt] [right '()])
          (if (pair? opt-rest)
              (with-syntax*
                (((values hd) (car opt-rest))
                  ((values rest) (cdr opt-rest))
                  (bind (car hd))
                  (expr (cdr hd))
                  (body (recur rest (cons #'bind right))))
                #'(let-values ([(bind) expr]) body))
              (with-syntax ([(pre ...) pre]
                            [(opt ...) (reverse right)]
                            [primary primary])
                (syntax/loc stx (primary pre ... opt ...))))))
      (define (generate-kw-primary key kwargs args body)
        (define (make-body kwargs kwvals)
          (if (pair? kwargs)
              (let* ([kwarg (car kwargs)])
                (let* ([var (cadr kwarg)])
                  (let* ([default (caddr kwarg)])
                    (let* ([kwval (car kwvals)])
                      (let* ([rest-kwargs (cdr kwargs)])
                        (let* ([rest-kwvals (cdr kwvals)])
                          (with-syntax ([var var]
                                        [kwval kwval]
                                        [default default]
                                        [body (make-body
                                                rest-kwargs
                                                rest-kwvals)])
                            #'(let-values ([(var)
                                            (if (eq? kwval absent-value)
                                                default
                                                kwval)])
                                body))))))))
              (cons 'begin body)))
        (define (make-main)
          (with-syntax*
            ((kwvar (or key (syntax-local-introduce '\x40;@keywords)))
              ((kwval ...) (gentemps (map cadr kwargs)))
              (args args)
              (body (make-body kwargs #'(kwval ...))))
            (syntax/loc stx (lambda (kwvar kwval ... . args) body))))
        (define (make-dispatch main)
          (with-syntax*
            ((kwvar (or key (syntax-local-introduce '\x40;@keywords)))
              ((get-kw ...)
                (map (lambda%
                       (kwarg)
                       (with-syntax ([key (car kwarg)])
                         #'(symbolic-table-ref kwvar 'key absent-value)))
                     kwargs))
              (main main))
            (syntax/loc
              stx
              (lambda (kwvar . args)
                (apply main kwvar get-kw ... args)))))
        (with-syntax*
          ((main-id (genident 'kw-lambda-main))
            (dispatch (make-dispatch #'main-id))
            (main (make-main)))
          #'(let-values ([(main-id) main]) dispatch)))
      (define (generate-kw-dispatch primary kwargs strict?)
        (with-syntax ([pht (and strict?
                                (generate-kw-table (map car kwargs)))]
                      [K primary]
                      [$args (genident 'args)])
          #'(lambda% $args (apply keyword-dispatch 'pht K $args))))
      (define (generate-kw-table kws)
        (let rehash ([pht (make-vector (length kws) #f)])
          (let lp ([rest kws])
            (if (pair? rest)
                (let* ([key (car rest)])
                  (let* ([rest (cdr rest)])
                    (let* ([pos (fxmodulo
                                  (keyword-hash key)
                                  (vector-length pht))])
                      (if (vector-ref pht pos)
                          (if (fx< (vector-length pht) 8192)
                              (rehash
                                (make-vector
                                  (quotient (fx* 3 (vector-length pht)) 2)
                                  #f))
                              (error 'gerbil
                                "Unresolvable keyword collision"
                                kws))
                          (begin (vector-set! pht pos key) (lp rest))))))
                pht))))
      (syntax-case stx ()
        [(_ hd . body) (simple-lambda? #'hd) #'(lambda% hd . body)]
        [(_ hd . body)
         (opt-lambda? #'hd)
         (with-syntax*
           (((values pre opt tail) (opt-lambda-split #'hd))
             ($primary (genident 'opt-lambda))
             (primary
               (stx-wrap-source
                 (generate-opt-primary pre opt tail #'body)
                 (stx-source stx)))
             ((clause ...)
               (generate-opt-dispatch #'$primary pre opt tail))
             (dispatch (syntax/loc stx (case-lambda clause ...))))
           #'(let-values ([($primary) primary]) dispatch))]
        [(_ hd . body)
         (kw-lambda? #'hd)
         (with-syntax*
           ((_ (check-duplicate-bindings #'hd))
             ((values key kwargs args) (kw-lambda-split #'hd))
             ($primary (genident 'kw-lambda))
             (primary
               (stx-wrap-source
                 (generate-kw-primary key kwargs args #'body)
                 (stx-source stx)))
             (dispatch
               (stx-wrap-source
                 (generate-kw-dispatch #'$primary kwargs (not key))
                 (stx-source stx))))
           #'(let-values ([($primary) primary]) dispatch))])))
  (define-syntax def
    (syntax-rules ()
      [(_ ((head . rest) . args) body ...)
       (def (head . rest) (lambda args body ...))]
      [(_ (id . args) body ...)
       (define-values (id) (lambda args body ...))]
      [(_ id expr) (define-values (id) expr)]))
  (define-syntax def*
    (syntax-rules ()
      [(_ id clauses ...)
       (define-values (id) (case-lambda clauses ...))]))
  (define-syntax defvalues
    (syntax-rules () [(_ hd expr) (define-values hd expr)]))
  (define-syntax case
    (syntax-rules ()
      [(_ expr clause ...)
       (let ($e expr) (~case $e clause ...))]))
  (define-syntax ~case
    (lambda (stx)
      (define (parse-clauses e clauses)
        (let lp ([rest clauses]
                 [datums '()]
                 [dispatch '()]
                 [default #f])
          (syntax-case rest ()
            [(clause . rest)
             (syntax-case #'clause (else =>)
               [(else => K)
                (if (stx-null? #'rest)
                    (with-syntax ([e e]) (lp '() datums dispatch #'(K e)))
                    (raise-syntax-error
                      #f
                      "Misplaced else clause"
                      stx
                      #'clause))]
               [(else body ...)
                (if (stx-null? #'rest)
                    (lp '() datums dispatch #'(begin body ...))
                    (raise-syntax-error
                      #f
                      "Misplaced else clause"
                      stx
                      #'clause))]
               [((datum ...) => K)
                (if (null? #'(datum ...))
                    (lp #'rest datums dispatch default)
                    (with-syntax ([e e])
                      (lp #'rest
                          (cons (map stx-e #'(datum ...)) datums)
                          (cons #'(K e) dispatch)
                          default)))]
               [((datum ...) body ...)
                (if (null? #'(datum ...))
                    (lp #'rest datums dispatch default)
                    (lp #'rest
                        (cons (map stx-e #'(datum ...)) datums)
                        (cons #'(begin body ...) dispatch)
                        default))])]
            [()
             (begin
               (check-duplicate-datums datums)
               (values
                 (reverse datums)
                 (reverse dispatch)
                 (or default 'unreadable-value)))])))
      (define (check-duplicate-datums datums)
        (let ([ht (make-hash-table)])
          (for-each
            (lambda (lst)
              (for-each
                (lambda (datum)
                  (if (hash-get ht datum)
                      (raise-syntax-error #f "Duplicate datum" stx datum)
                      (hash-put! ht datum #t)))
                lst))
            datums)))
      (define (count-datums datums)
        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1729} (lambda (lst r)
                                                     (+ (length lst) r))])
          (fold-left
            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1730}
                     #{e dpuuv4a3mobea70icwo8nvdax-1731})
              (#{f dpuuv4a3mobea70icwo8nvdax-1729}
                #{e dpuuv4a3mobea70icwo8nvdax-1731}
                #{a dpuuv4a3mobea70icwo8nvdax-1730}))
            0
            datums)))
      (define (symbolic-datums? datums)
        (andmap (lambda (lst) (andmap symbol? lst)) datums))
      (define (char-datums? datums)
        (andmap (lambda (lst) (andmap char? lst)) datums))
      (define (fixnum-datums? datums)
        (andmap (lambda (lst) (andmap fixnum? lst)) datums))
      (define (eq-datums? datums)
        (andmap
          (lambda (lst)
            (andmap
              (lambda (x) (or (symbol? x) (keyword? x) (immediate? x)))
              lst))
          datums))
      (define (generate-simple-case e datums dispatch default)
        (with-syntax ([e e])
          (let recur ([datums datums] [dispatch dispatch])
            (syntax-case datums ()
              [((datum ...) . datums)
               (syntax-case dispatch ()
                 [(cont . rest)
                  (with-syntax ([E (recur #'datums #'rest)])
                    #'(if (or (~case-test datum e) ...) cont E))])]
              [_ default]))))
      (define (datum-dispatch-index datums)
        (let lp ([rest datums] [ix 0] [r '()])
          (syntax-case rest ()
            [((datum ...) . rest)
             (lp #'rest
                 (fx1+ ix)
                 (foldl
                   (lambda% (x r) (cons (cons x ix) r))
                   r
                   #'(datum ...)))]
            [_ r])))
      (define (duplicate-indexes? xs)
        (let ([ht (make-hash-table-eq)])
          (let lp ([rest xs])
            (if (pair? rest)
                (let ([ix (car rest)])
                  (or (hash-get ht ix)
                      (begin (hash-put! ht ix #t) (lp (cdr rest)))))
                #f))))
      (define (generate-hash-dispatch-table indexes hash-e)
        (let lp ([len (* 2 (length indexes))])
          (let* ([hs (map (lambda (x) (hash-e (car x))) indexes)])
            (let* ([xs (map (lambda (h) (fxmodulo h len)) hs)])
              (if (duplicate-indexes? xs)
                  (if (< len 131072)
                      (lp (quotient (fx* len 3) 2))
                      (raise-syntax-error
                        #f
                        "Cannot create perfect dispatch table"
                        stx
                        indexes))
                  (let ([tab (make-vector len #f)])
                    (for-each
                      (lambda (entry x) (vector-set! tab x entry))
                      indexes
                      xs)
                    tab))))))
      (define (generate-symbolic-dispatch e datums dispatch
               default)
        (let* ([indexes (datum-dispatch-index datums)])
          (let* ([tab (generate-hash-dispatch-table
                        indexes
                        symbol-hash)])
            (if (= (length dispatch) 1)
                (let ([tab (vector-map (lambda (x) (and x (car x))) tab)])
                  (with-syntax ([e e]
                                [E (genident 'default)]
                                [t (genident 'table)]
                                [(cont) dispatch]
                                [default default]
                                [tab tab]
                                [tablen (vector-length tab)])
                    #'(let ([E (lambda () default)] [t 'tab])
                        (if (symbol? e)
                            (let* ([h (\x23;\x23;symbol-hash e)]
                                   [ix (\x23;\x23;fxmodulo h tablen)]
                                   [q (\x23;\x23;vector-ref t ix)])
                              (if (eq? q e) cont (E)))
                            (E)))))
                (with-syntax ([e e]
                              [E (genident 'default)]
                              [t (genident 'table)]
                              [(dispatch ...) dispatch]
                              [default default]
                              [tab tab]
                              [tablen (vector-length tab)])
                  #'(let ([E (lambda () default)] [t 'tab])
                      (if (symbol? e)
                          (let* ([h (\x23;\x23;symbol-hash e)]
                                 [ix (\x23;\x23;fxmodulo h tablen)]
                                 [q (\x23;\x23;vector-ref t ix)])
                            (if q
                                (if (eq? (\x23;\x23;car q) e)
                                    (let (x [\x23;\x23;cdr q])
                                      (~case-dispatch x dispatch ...))
                                    (E))
                                (E)))
                          (E))))))))
      (define (max-char datums)
        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1732} (lambda (lst r)
                                                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-1733} (lambda (char
                                                                                                         r)
                                                                                                  (max (char->integer
                                                                                                         char)
                                                                                                       r))])
                                                       (fold-left
                                                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1734}
                                                                  #{e dpuuv4a3mobea70icwo8nvdax-1735})
                                                           (#{f dpuuv4a3mobea70icwo8nvdax-1733}
                                                             #{e dpuuv4a3mobea70icwo8nvdax-1735}
                                                             #{a dpuuv4a3mobea70icwo8nvdax-1734}))
                                                         r
                                                         lst)))])
          (fold-left
            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1736}
                     #{e dpuuv4a3mobea70icwo8nvdax-1737})
              (#{f dpuuv4a3mobea70icwo8nvdax-1732}
                #{e dpuuv4a3mobea70icwo8nvdax-1737}
                #{a dpuuv4a3mobea70icwo8nvdax-1736}))
            0
            datums)))
      (define (generate-char-dispatch-table indexes)
        (let* ([ixs (map (lambda (x) (char->integer (car x)))
                         indexes)])
          (let* ([len (fx1+
                        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1738} max])
                          (fold-left
                            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1739}
                                     #{e dpuuv4a3mobea70icwo8nvdax-1740})
                              (#{f dpuuv4a3mobea70icwo8nvdax-1738}
                                #{e dpuuv4a3mobea70icwo8nvdax-1740}
                                #{a dpuuv4a3mobea70icwo8nvdax-1739}))
                            0
                            ixs)))])
            (let* ([vec (make-vector len #f)])
              (for-each
                (lambda (entry x) (vector-set! vec x (cdr entry)))
                indexes
                ixs)
              vec))))
      (define (simple-char-range? tab)
        (let ([end (vector-length tab)])
          (let lp ([i 0])
            (let ([ix (vector-ref tab i)])
              (if ix
                  (let lp2 ([i (fx1+ i)])
                    (if (fx< i end)
                        (let ([ix* (vector-ref tab i)])
                          (if (eq? ix ix*) (lp2 (fx1+ i)) #f))
                        #t))
                  (lp (fx1+ i)))))))
      (define (char-range-start tab)
        (let lp ([i 0]) (if (vector-ref tab i) i (lp (fx1+ i)))))
      (define (generate-char-dispatch e datums dispatch default)
        (if (< (max-char datums) 128)
            (let* ([indexes (datum-dispatch-index datums)])
              (let* ([tab (generate-char-dispatch-table indexes)])
                (if (simple-char-range? tab)
                    (let ([start (char-range-start tab)]
                          [end (vector-length tab)])
                      (with-syntax ([e e]
                                    [E (genident 'default)]
                                    [(cont) dispatch]
                                    [default default]
                                    [start start]
                                    [end end])
                        #'(let (E [lambda () default])
                            (if (char? e)
                                (let (ix [\x23;\x23;char->integer e])
                                  (if (and (\x23;\x23;fx>= ix start)
                                           (\x23;\x23;fx< ix end))
                                      cont
                                      (E)))
                                (E)))))
                    (with-syntax ([e e]
                                  [E (genident 'default)]
                                  [t (genident 'table)]
                                  [(dispatch ...) dispatch]
                                  [default default]
                                  [tab tab]
                                  [tablen (vector-length tab)])
                      #'(let ([E (lambda () default)] [t 'tab])
                          (if (char? e)
                              (let (ix [\x23;\x23;char->integer e])
                                (if (\x23;\x23;fx< ix tablen)
                                    (let (x [\x23;\x23;vector-ref t ix])
                                      (if x
                                          (~case-dispatch x dispatch ...)
                                          (E)))
                                    (E)))
                              (E)))))))
            (generate-char-dispatch/hash e datums dispatch default)))
      (define (generate-char-dispatch/hash e datums dispatch
               default)
        (let* ([indexes (datum-dispatch-index datums)])
          (let* ([tab (generate-hash-dispatch-table
                        indexes
                        char->integer)])
            (with-syntax ([e e]
                          [E (genident 'default)]
                          [t (genident 'table)]
                          [(dispatch ...) dispatch]
                          [default default]
                          [tab tab]
                          [tablen (vector-length tab)])
              #'(let ([E (lambda () default)] [t 'tab])
                  (if (char? e)
                      (let* ([h (\x23;\x23;char->integer e)]
                             [ix (\x23;\x23;fxmodulo h tablen)]
                             [q (\x23;\x23;vector-ref t ix)])
                        (if q
                            (if (eq? (\x23;\x23;car q) e)
                                (let (x [\x23;\x23;cdr q])
                                  (~case-dispatch x dispatch ...))
                                (E))
                            (E)))
                      (E)))))))
      (define (min-fixnum datums)
        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1741} (lambda (lst r)
                                                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-1742} min])
                                                       (fold-left
                                                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1743}
                                                                  #{e dpuuv4a3mobea70icwo8nvdax-1744})
                                                           (#{f dpuuv4a3mobea70icwo8nvdax-1742}
                                                             #{e dpuuv4a3mobea70icwo8nvdax-1744}
                                                             #{a dpuuv4a3mobea70icwo8nvdax-1743}))
                                                         r
                                                         lst)))])
          (fold-left
            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1745}
                     #{e dpuuv4a3mobea70icwo8nvdax-1746})
              (#{f dpuuv4a3mobea70icwo8nvdax-1741}
                #{e dpuuv4a3mobea70icwo8nvdax-1746}
                #{a dpuuv4a3mobea70icwo8nvdax-1745}))
            \x23;\x23;max-fixnum
            datums)))
      (define (max-fixnum datums)
        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1747} (lambda (lst r)
                                                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-1748} max])
                                                       (fold-left
                                                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1749}
                                                                  #{e dpuuv4a3mobea70icwo8nvdax-1750})
                                                           (#{f dpuuv4a3mobea70icwo8nvdax-1748}
                                                             #{e dpuuv4a3mobea70icwo8nvdax-1750}
                                                             #{a dpuuv4a3mobea70icwo8nvdax-1749}))
                                                         r
                                                         lst)))])
          (fold-left
            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1751}
                     #{e dpuuv4a3mobea70icwo8nvdax-1752})
              (#{f dpuuv4a3mobea70icwo8nvdax-1747}
                #{e dpuuv4a3mobea70icwo8nvdax-1752}
                #{a dpuuv4a3mobea70icwo8nvdax-1751}))
            \x23;\x23;min-fixnum
            datums)))
      (define (generate-fixnum-dispatch-table indexes)
        (let* ([ixs (map car indexes)])
          (let* ([len (fx1+
                        (let ([#{f dpuuv4a3mobea70icwo8nvdax-1753} max])
                          (fold-left
                            (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1754}
                                     #{e dpuuv4a3mobea70icwo8nvdax-1755})
                              (#{f dpuuv4a3mobea70icwo8nvdax-1753}
                                #{e dpuuv4a3mobea70icwo8nvdax-1755}
                                #{a dpuuv4a3mobea70icwo8nvdax-1754}))
                            0
                            ixs)))])
            (let* ([vec (make-vector len #f)])
              (for-each
                (lambda (entry x) (vector-set! vec x (cdr entry)))
                indexes
                ixs)
              vec))))
      (define (generate-fixnum-dispatch e datums dispatch default)
        (if (and (>= (min-fixnum datums) 0)
                 (< (max-fixnum datums) 1024))
            (let* ([indexes (datum-dispatch-index datums)])
              (let* ([tab (generate-fixnum-dispatch-table indexes)])
                (let* ([dense? (andmap values (vector->list tab))])
                  (with-syntax ([e e]
                                [E (genident 'default)]
                                [t (genident 'table)]
                                [(dispatch ...) dispatch]
                                [default default]
                                [tab tab]
                                [tablen (vector-length tab)])
                    (with-syntax ([do-dispatch (if dense?
                                                   #'(~case-dispatch
                                                       x
                                                       dispatch
                                                       ...)
                                                   #'(if x
                                                         (~case-dispatch
                                                           x
                                                           dispatch
                                                           ...)
                                                         (E)))])
                      #'(let ([E (lambda () default)] [t 'tab])
                          (if (fixnum? e)
                              (if (and (\x23;\x23;fx>= e 0)
                                       (\x23;\x23;fx< e tablen))
                                  (let (x [\x23;\x23;vector-ref t e])
                                    do-dispatch)
                                  (E))
                              (E))))))))
            (generate-fixnum-dispatch/hash e datums dispatch default)))
      (define (generate-fixnum-dispatch/hash e datums dispatch
               default)
        (let* ([indexes (datum-dispatch-index datums)])
          (let* ([tab (generate-hash-dispatch-table indexes values)])
            (with-syntax ([e e]
                          [E (genident 'default)]
                          [t (genident 'table)]
                          [(dispatch ...) dispatch]
                          [default default]
                          [tab tab]
                          [tablen (vector-length tab)])
              #'(let ([E (lambda () default)] [t 'tab])
                  (if (fixnum? e)
                      (let* ([ix (\x23;\x23;fxmodulo e tablen)]
                             [q (\x23;\x23;vector-ref t ix)])
                        (if q
                            (if (eq? (\x23;\x23;car q) e)
                                (let (x [\x23;\x23;cdr q])
                                  (~case-dispatch x dispatch ...))
                                (E))
                            (E)))
                      (E)))))))
      (define (generate-generic-dispatch e datums dispatch
               default)
        (call-with-values
          (lambda ()
            (if (eq-datums? datums)
                (values eq?-hash 'eq?-hash 'eq?)
                (values equal?-hash 'equal?-hash 'equal?)))
          (lambda (hash-e hashf eqf)
            (let* ([indexes (datum-dispatch-index datums)])
              (let* ([tab (generate-hash-dispatch-table indexes hash-e)])
                (with-syntax ([e e]
                              [E (genident 'default)]
                              [t (genident 'table)]
                              [(dispatch ...) dispatch]
                              [default default]
                              [tab tab]
                              [tablen (vector-length tab)]
                              [hashf hashf]
                              [eqf eqf])
                  #'(let ([E (lambda () default)] [t 'tab])
                      (let* ([h (hashf e)]
                             [ix (\x23;\x23;fxmodulo h tablen)]
                             [q (\x23;\x23;vector-ref t ix)])
                        (if q
                            (if (eqf (\x23;\x23;car q) e)
                                (let (x [\x23;\x23;cdr q])
                                  (~case-dispatch x dispatch ...))
                                (E))
                            (E))))))))))
      (syntax-case stx ()
        [(_ e clause ...)
         (let* ([(values datums dispatch default) (parse-clauses
                                                    #'e
                                                    #'(clause ...))]
                [datum-count (count-datums datums)])
           (cond
             [(< datum-count 6)
              (generate-simple-case #'e datums dispatch default)]
             [(char-datums? datums)
              (generate-char-dispatch #'e datums dispatch default)]
             [(fixnum-datums? datums)
              (generate-fixnum-dispatch #'e datums dispatch default)]
             [(< datum-count 12)
              (generate-simple-case #'e datums dispatch default)]
             [(symbolic-datums? datums)
              (generate-symbolic-dispatch #'e datums dispatch default)]
             [else
              (generate-generic-dispatch
                #'e
                datums
                dispatch
                default)]))])))
  (define-syntax ~case-test
    (lambda (stx)
      (syntax-case stx ()
        [(_ datum e)
         (let (datum-e [stx-e #'datum])
           (cond
             [(or (symbol? datum-e)
                  (keyword? datum-e)
                  (immediate? datum-e))
              #'(eq? 'datum e)]
             [(number? datum-e) #'(eqv? 'datum e)]
             [else #'(equal? 'datum e)]))])))
  (define-syntax ~case-dispatch
    (syntax-rules () [(_ x K ...) (~case-dispatch* 0 x K ...)]))
  (define-syntax ~case-dispatch*
    (lambda (stx)
      (syntax-case stx ()
        [(_ d x) #'''unreadable-value]
        [(_ d x K) #'K]
        [(_ d x K1 K2)
         (with-syntax ([x0 (stx-e #'d)])
           #'(if (\x23;\x23;fx= x x0) K1 K2))]
        [(_ d x K1 K2 K3)
         (with-syntax ([x0 (stx-e #'d)] [x1 (fx1+ (stx-e #'d))])
           #'(if (\x23;\x23;fx= x x0)
                 K1
                 (if (\x23;\x23;fx= x x1) K2 K3)))]
        [(_ d x K ...) #'(~case-dispatch-bsearch d x K ...)])))
  (define-syntax ~case-dispatch-bsearch
    (lambda (stx)
      (define (split lst mid)
        (let lp ([i 0] [rest lst] [left '()])
          (if (fx< i mid)
              (lp (fx1+ i) (cdr rest) (cons (car rest) left))
              (values (reverse left) rest))))
      (syntax-case stx ()
        [(_ d x K ...)
         (let* ([len (length #'(K ...))]
                [mid (quotient len 2)]
                [(values left right) (split #'(K ...) mid)])
           (with-syntax ([mid mid]
                         [(K-left ...) left]
                         [(K-right ...) right]
                         [d* (fx+ mid (stx-e #'d))])
             #'(if (\x23;\x23;fx< x d*)
                   (~case-dispatch* d x K-left ...)
                   (~case-dispatch* d* x K-right ...))))])))
  (define-syntax begin0
    (syntax-rules ()
      [(_ expr) expr]
      [(_ expr rest ...)
       (let ($r expr) (%\x23;expression (begin rest ...)) $r)]))
  (define-syntax rec
    (syntax-rules (values)
      [(_ id expr) (letrec ([id expr]) id)]
      [(_ (values . ids) expr)
       (letrec-values ((ids expr)) (values . ids))]
      [(_ (id . hd) body ...)
       (letrec ([id (lambda hd body ...)]) id)]))
  (define-syntax alet
    (lambda (stx)
      (define (let-bind? x)
        (syntax-case x ()
          [(hd e) (let-head? #'hd)]
          [(e) #t]
          [_ #f]))
      (define (let-bind x)
        (syntax-case x () [(hd e) x] [(e) #'(_ e)]))
      (define (let-head? x)
        (syntax-case x (values)
          [(values . ids) (stx-andmap identifier? #'ids)]
          [_ (identifier? x)]))
      (define (let-head x)
        (syntax-case x (values)
          [(values . ids) #'ids]
          [_ (list x)]))
      (syntax-case stx ()
        [(recur (hd e) . body)
         (let-head? #'hd)
         #'(recur ((hd e)) . body)]
        [(_ ((e)) body ...) #'(and e (let () body ...))]
        [(_ (bind ...) body ...)
         (stx-andmap let-bind? #'(bind ...))
         (with-syntax*
           ((((hd e) ...) (stx-map let-bind #'(bind ...)))
             (($e ...) (gentemps #'(hd ...)))
             ((hd-bind ...) (stx-map let-head #'(hd ...))))
           #'(let-values ([($e) e] ...)
               (and $e ... (let-values ([hd-bind $e] ...) body ...))))])))
  (define-syntax alet*
    (syntax-rules ()
      [(_ ()) #t]
      [(_ () body ...) (let () body ...)]
      [(recur (hd . rest) body ...)
       (alet (hd) (recur rest body ...))]))
  (define and-let* alet*)
  (define-syntax \x40;list
    (syntax-rules (quote quasiquote)
      [(_) '()]
      [(_ quote tl) 'tl]
      [(_ quasiquote tl) `tl]
      [(_ :: tl) tl]
      [(_ xs dots) xs]
      [(recur xs dots . rest) (foldr cons (recur . rest) xs)]
      [(recur x . xs) (cons x (recur . xs))]
      [(_ . tl) tl]))
  (define-syntax quasiquote
    (lambda (stx)
      (define (simple-quote? e)
        (syntax-case e (unquote unquote-splicing)
          [,_ #f]
          [,@_ #f]
          [(hd . tl) (and (simple-quote? #'hd) (simple-quote? #'tl))]
          [#(e ...) (simple-quote? #'(e ...))]
          ['unreadable-record (simple-quote? #'e)]
          [_ #t]))
      (define (generate e d)
        (syntax-case e (quasiquote . ,unquote-splicing)
          [`e
           (with-syntax ([e (generate #'e (fx1+ d))])
             #'(list 'quasiquote e))]
          [,e
           (if (fxzero? d)
               #'e
               (with-syntax ([e (generate #'e (fx1- d))])
                 #'(list 'unquote e)))]
          [,@e
           (if (fxzero? d)
               #'(foldr cons '() e)
               (with-syntax ([e (generate #'e (fx1- d))])
                 #'(list 'unquote-splicing e)))]
          [(,@hd . rest)
           (fxzero? d)
           (with-syntax ([tl (generate #'rest d)])
             #'(foldr cons tl hd))]
          [(hd . tl)
           (with-syntax ([hd (generate #'hd d)] [tl (generate #'tl d)])
             #'(cons hd tl))]
          [#(e ...)
           (with-syntax ([es (generate #'(e ...) d)])
             #'(list->vector es))]
          ['unreadable-record
           (with-syntax ([e (generate #'e d)]) #'(box e))]
          [e #''e]))
      (syntax-case stx ()
        [(_ e) (if (simple-quote? #'e) #''e (generate #'e 0))])))
  (define-syntax delay
    (syntax-rules (quote)
      [(_ datum) 'datum]
      [(_ 'datum) 'datum]
      [(_ expr) (make-promise (lambda% () expr))]))
  (define-syntax delay-atomic
    (syntax-rules (quote)
      [(_ datum) 'datum]
      [(_ 'datum) 'datum]
      [(_ expr) (make-atomic-promise (lambda% () expr))]))
  (define-syntax cut
    (lambda (stx)
      (define (generate rest)
        (let lp ([rest rest] [hd '()] [body '()])
          (syntax-case rest ()
            [(e . rest)
             (syntax-case #'e (<> <...>)
               [<>
                (let (arg [genident])
                  (lp #'rest (cons arg hd) (cons arg body)))]
               [<...>
                (if (stx-null? #'rest)
                    (let (tail [genident])
                      (values
                        (foldl cons tail hd)
                        (foldl cons (list tail) body)
                        #t))
                    (raise-syntax-error
                      #f
                      "bad syntax; cut ellipsis <...> not in tail position"
                      stx
                      #'e))]
               [_ (lp #'rest hd (cons #'e body))])]
            [_ (values (reverse hd) (reverse body) #f)])))
      (syntax-case stx ()
        [(_ . body)
         (and (stx-list? #'body) (not (stx-null? #'body)))
         (with-syntax*
           (((values hd body tail?) (generate #'body))
             (hd hd)
             (body body))
           (if tail?
               #'(lambda% hd (apply . body))
               #'(lambda% hd body)))])))
  (define-syntax <> (syntax-rules ()))
  (define-syntax <...> (syntax-rules ())))

(begin
  (define-syntax defsyntax
    (syntax-rules ()
      [(_ (id . args) body ...)
       (define-syntax id (lambda args body ...))]
      [(_ id expr) (define-syntax id expr)]))
  (define-syntax definline
    (lambda (stx)
      (syntax-case stx ()
        [(_ (id arg ...) body ...)
         (and (identifier? #'id) (identifier-list? #'(arg ...)))
         (with-syntax*
           ((impl (stx-identifier #'id #'id "__impl"))
             ((xarg ...) (gentemps #'(arg ...)))
             (defstx
               (syntax/loc
                 stx
                 (defrules
                   id
                   ()
                   ((_ xarg ...) ((lambda (arg ...) body ...) xarg ...))
                   (ref (identifier? #'ref) impl))))
             (defimpl (syntax/loc stx (def (impl arg ...) body ...))))
           (syntax/loc stx (begin defimpl defstx)))])))
  (define-syntax defconst
    (syntax-rules (quote)
      [(_ id 'expr) (defrules id () (x (identifier? #'x) 'expr))]
      [(recur id expr) (recur id 'expr)])))

