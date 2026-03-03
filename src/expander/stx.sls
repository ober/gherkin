#!chezscheme
;;; stx.sls -- Expander syntax types for Chez Scheme
;;; Provides identifier-wrap, syntax-wrap, syntax-quote types
;;; and full syntax manipulation functions needed by the expander.

(library (expander stx)
  (export
    ;; re-export runtime syntax basics
    AST::t make-AST AST? AST-e AST-source AST-e-set! AST-source-set!
    stx-e stx-source stx-wrap-source
    stx-pair? stx-null? stx-list? stx-datum? stx-boolean? stx-number?
    stx-fixnum? stx-string? stx-char? stx-keyword?
    stx-car stx-cdr stx->list stx->datum
    identifier? stx-identifier core-identifier=?
    source-location? source-location-path source-location-path?
    SyntaxError::t raise-syntax-error syntax-error?
    genident gentemps
    read-syntax read-syntax-from-file

    ;; Syntax wrap types
    identifier-wrap::t make-identifier-wrap identifier-wrap?
    &identifier-wrap-marks
    syntax-wrap::t make-syntax-wrap syntax-wrap?
    &syntax-wrap-mark
    syntax-quote::t make-syntax-quote syntax-quote?
    &syntax-quote-context &syntax-quote-marks

    ;; Unchecked AST accessors
    &AST-e &AST-source

    ;; Expander mark
    expander-mark::t make-expander-mark expander-mark?
    expander-mark-subst expander-mark-context
    expander-mark-phi expander-mark-trace

    ;; Full syntax-e (handles wraps)
    syntax-e syntax->datum datum->syntax

    ;; Mark operations
    stx-unwrap stx-wrap stx-rewrap stx-apply-mark apply-mark

    ;; Identifier utilities
    identifier-quote? sealed-syntax? sealed-syntax-unwrap
    stx-identifier-marks stx-identifier-context identifier-list?
    self-quoting?

    ;; More stx utilities
    stx-eq? stx-eqv? stx-false? stx-vector? stx-box?
    stx-pair/null?
    stx-map1 stx-map2 stx-for-each1 stx-for-each2
    stx-andmap stx-ormap stx-foldl stx-foldr
    stx-reverse stx-last stx-last-pair stx-list-tail stx-list-ref
    stx-length stx-plist? stx-getq
    syntax->list stx-map stx-for-each

    ;; bound/free identifier comparison
    free-identifier=? bound-identifier=?
    )

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise identifier?)
            (error chez:error) (raise chez:raise)
            (identifier? chez:identifier?))
    (only (compat gambit-compat) |##keyword?| |##void| box box? unbox)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax))

  ;; --- Unchecked AST accessors (fast path) ---
  (define (&AST-e obj) (|##structure-ref| obj 1))
  (define (&AST-source obj) (|##structure-ref| obj 2))

  ;; --- identifier-wrap: wraps identifier with hygiene marks ---
  (define identifier-wrap::t
    (make-class-type
      (string->symbol "gx#identifier-wrap::t")
      'syntax  ;; name is 'syntax like AST
      (list AST::t)
      '(marks)
      '((struct: . #t) (final: . #t))
      #f))

  (define (make-identifier-wrap e source marks)
    (let ((obj (make-class-instance identifier-wrap::t)))
      (|##structure-set!| obj 1 e)
      (|##structure-set!| obj 2 source)
      (|##structure-set!| obj 3 marks)
      obj))

  (define (identifier-wrap? obj)
    (|##structure-instance-of?| obj (string->symbol "gx#identifier-wrap::t")))

  (define (&identifier-wrap-marks obj) (|##structure-ref| obj 3))

  ;; --- syntax-wrap: wraps syntax with a single mark ---
  (define syntax-wrap::t
    (make-class-type
      (string->symbol "gx#syntax-wrap::t")
      'syntax
      (list AST::t)
      '(mark)
      '((struct: . #t) (final: . #t))
      #f))

  (define (make-syntax-wrap e source mark)
    (let ((obj (make-class-instance syntax-wrap::t)))
      (|##structure-set!| obj 1 e)
      (|##structure-set!| obj 2 source)
      (|##structure-set!| obj 3 mark)
      obj))

  (define (syntax-wrap? obj)
    (|##structure-instance-of?| obj (string->symbol "gx#syntax-wrap::t")))

  (define (&syntax-wrap-mark obj) (|##structure-ref| obj 3))

  ;; --- syntax-quote: quoted syntax with context and marks ---
  (define syntax-quote::t
    (make-class-type
      (string->symbol "gx#syntax-quote::t")
      'syntax
      (list AST::t)
      '(context marks)
      '((struct: . #t) (final: . #t))
      #f))

  (define (make-syntax-quote e source context marks)
    (let ((obj (make-class-instance syntax-quote::t)))
      (|##structure-set!| obj 1 e)
      (|##structure-set!| obj 2 source)
      (|##structure-set!| obj 3 context)
      (|##structure-set!| obj 4 marks)
      obj))

  (define (syntax-quote? obj)
    (|##structure-instance-of?| obj (string->symbol "gx#syntax-quote::t")))

  (define (&syntax-quote-context obj) (|##structure-ref| obj 3))
  (define (&syntax-quote-marks obj) (|##structure-ref| obj 4))

  ;; --- Expander mark ---
  (define expander-mark::t
    (make-class-type
      (string->symbol "gx#expander-mark::t")
      'expander-mark
      (list object::t)
      '(subst context phi trace)
      '((struct: . #t))
      #f))

  (define (make-expander-mark subst context phi trace)
    (let ((obj (make-class-instance expander-mark::t)))
      (|##structure-set!| obj 1 subst)
      (|##structure-set!| obj 2 context)
      (|##structure-set!| obj 3 phi)
      (|##structure-set!| obj 4 trace)
      obj))

  (define (expander-mark? obj)
    (|##structure-instance-of?| obj (string->symbol "gx#expander-mark::t")))

  (define (expander-mark-subst m)   (|##structure-ref| m 1))
  (define (expander-mark-context m) (|##structure-ref| m 2))
  (define (expander-mark-phi m)     (|##structure-ref| m 3))
  (define (expander-mark-trace m)   (|##structure-ref| m 4))

  ;; --- Full syntax-e (handles wraps/marks) ---
  (define (syntax-e stx)
    (cond
      ((syntax-wrap? stx)
       (let lp ((e (&AST-e stx)) (marks (list (&syntax-wrap-mark stx))))
         (cond
           ((and (|##structure?| e)
                 (|##structure-type| e))
            (let ((tid (type-descriptor-id (|##structure-type| e))))
              (cond
                ((eq? tid (string->symbol "gx#syntax-wrap::t"))
                 (lp (&AST-e e) (apply-mark (&syntax-wrap-mark e) marks)))
                ((or (eq? tid (string->symbol "gx#syntax-quote::t"))
                     (eq? tid (string->symbol "gx#identifier-wrap::t")))
                 (&AST-e e))
                ((eq? tid (string->symbol "gerbil#AST::t"))
                 (lp (&AST-e e) marks))
                (else e))))
           ((null? marks) e)
           ((pair? e)
            (cons (stx-wrap (car e) marks)
                  (stx-wrap (cdr e) marks)))
           ((vector? e)
            (vector-map (lambda (x) (stx-wrap x marks)) e))
           ((box? e)
            (box (stx-wrap (unbox e) marks)))
           (else e))))
      ((AST? stx) (&AST-e stx))
      (else stx)))

  ;; --- syntax->datum ---
  (define (syntax->datum stx)
    (cond
      ((AST? stx) (syntax->datum (&AST-e stx)))
      ((pair? stx)
       (cons (syntax->datum (car stx))
             (syntax->datum (cdr stx))))
      ((vector? stx)
       (vector-map syntax->datum stx))
      ((box? stx)
       (box (syntax->datum (unbox stx))))
      (else stx)))

  ;; --- datum->syntax ---
  (define datum->syntax
    (case-lambda
      ((stx datum) (datum->syntax stx datum #f #t))
      ((stx datum src) (datum->syntax stx datum src #t))
      ((stx datum src quote?)
       (cond
         ((AST? datum) datum)
         ((not stx) (make-AST datum src))
         ((identifier? stx)
          (let ((stx (stx-unwrap stx)))
            (let ((wrapped
                    (if (syntax-quote? stx)
                      (if quote?
                        (wrap-quote datum (&syntax-quote-context stx)
                                    (&syntax-quote-marks stx) src)
                        (wrap-datum datum (&syntax-quote-marks stx) src))
                      (wrap-datum datum (&identifier-wrap-marks stx) src))))
              (if (AST? wrapped) wrapped
                  (make-AST wrapped src)))))
         (else
          (chez:error 'datum->syntax "Bad template syntax; expected identifier" stx))))))

  (define (wrap-datum e marks src)
    (wrap-inner e (lambda (x) (make-identifier-wrap x src marks))))

  (define (wrap-quote e ctx marks src)
    (wrap-inner e (lambda (x) (make-syntax-quote x src ctx marks))))

  (define (wrap-inner e wrap-e)
    (let recur ((e e))
      (cond
        ((symbol? e) (wrap-e e))
        ((pair? e) (cons (recur (car e)) (recur (cdr e))))
        ((vector? e) (vector-map recur e))
        ((box? e) (box (recur (unbox e))))
        (else e))))

  ;; --- Mark operations ---
  (define stx-unwrap
    (case-lambda
      ((stx) (stx-unwrap stx '()))
      ((stx marks)
       (let lp ((e stx) (marks marks) (src (stx-source stx)))
         (cond
           ((syntax-wrap? e)
            (lp (&AST-e e)
                (apply-mark (&syntax-wrap-mark e) marks)
                (&AST-source e)))
           ((identifier-wrap? e)
            (if (null? marks) e
                (make-identifier-wrap
                  (&AST-e e)
                  (&AST-source e)
                  (foldl1 apply-mark (&identifier-wrap-marks e) marks))))
           ((syntax-quote? e) e)
           ((AST? e)
            (lp (&AST-e e) marks (&AST-source e)))
           ((symbol? e)
            (make-identifier-wrap e src (reverse marks)))
           ((null? marks) e)
           ((pair? e)
            (cons (stx-wrap (car e) marks)
                  (stx-wrap (cdr e) marks)))
           ((vector? e)
            (vector-map (lambda (x) (stx-wrap x marks)) e))
           ((box? e)
            (box (stx-wrap (unbox e) marks)))
           (else e))))))

  (define (stx-wrap stx marks)
    (foldl1 (lambda (mark stx) (stx-apply-mark stx mark))
             stx marks))

  (define (stx-rewrap stx marks)
    (foldr1 (lambda (mark stx) (stx-apply-mark stx mark))
             stx marks))

  (define (stx-apply-mark stx mark)
    (cond
      ((syntax-quote? stx) stx)
      ((and (syntax-wrap? stx)
            (eq? mark (&syntax-wrap-mark stx)))
       (&AST-e stx))
      (else
       (make-syntax-wrap stx (stx-source stx) mark))))

  (define (apply-mark mark marks)
    (cond
      ((and (pair? marks) (eq? mark (car marks)))
       (cdr marks))
      (else (cons mark marks))))

  ;; --- Predicates ---
  (define (identifier-quote? stx)
    (and (syntax-quote? stx)
         (symbol? (&AST-e stx))))

  (define (sealed-syntax? stx)
    (cond
      ((syntax-quote? stx) #t)
      ((syntax-wrap? stx) (sealed-syntax? (&AST-e stx)))
      (else #f)))

  (define (sealed-syntax-unwrap stx)
    (cond
      ((syntax-quote? stx) stx)
      ((syntax-wrap? stx) (sealed-syntax-unwrap (&AST-e stx)))
      (else #f)))

  (define (self-quoting? x)
    (or (boolean? x) (number? x) (|##keyword?| x)
        (string? x) (char? x) (null? x)
        (eq? x (|##void|))))

  ;; --- Identifier utilities ---
  (define (stx-identifier-marks stx)
    (stx-identifier-marks* (stx-unwrap stx)))

  (define (stx-identifier-marks* stx)
    (cond
      ((identifier-wrap? stx) (&identifier-wrap-marks stx))
      ((syntax-quote? stx) (&syntax-quote-marks stx))
      (else (chez:error 'stx-identifier-marks
                        "Bad wrap; expected unwrapped identifier" stx))))

  (define (stx-identifier-context stx)
    (let ((stx (stx-unwrap stx)))
      (and (identifier-quote? stx)
           (&syntax-quote-context stx))))

  (define (identifier-list? stx)
    (let ((e (stx-e stx)))
      (cond
        ((null? e) #t)
        ((pair? e)
         (and (identifier? (car e))
              (identifier-list? (cdr e))))
        (else #f))))

  ;; --- bound/free identifier comparison ---
  (define (free-identifier=? a b)
    ;; For bootstrap: simple symbol comparison
    (eq? (stx-e a) (stx-e b)))

  (define (bound-identifier=? a b)
    ;; For bootstrap: compare symbols and marks
    (and (eq? (stx-e a) (stx-e b))
         (let ((ma (if (identifier-wrap? (stx-unwrap a))
                     (&identifier-wrap-marks (stx-unwrap a)) '()))
               (mb (if (identifier-wrap? (stx-unwrap b))
                     (&identifier-wrap-marks (stx-unwrap b)) '())))
           (equal? ma mb))))

  ;; --- Additional stx utilities ---
  (define (stx-eq? x y) (eq? (stx-e x) (stx-e y)))
  (define (stx-eqv? x y) (eqv? (stx-e x) (stx-e y)))
  (define (stx-false? x) (not (stx-e x)))
  (define (stx-vector? e) (vector? (stx-e e)))
  (define (stx-box? e) (box? (stx-e e)))
  (define (stx-pair/null? e)
    (let ((e (stx-e e)))
      (or (pair? e) (null? e))))

  (define (stx-length stx)
    (let lp ((rest stx) (n 0))
      (let ((e (stx-e rest)))
        (if (pair? e)
          (lp (cdr e) (fx+ n 1))
          n))))

  ;; --- Foldings (full versions) ---
  (define (stx-for-each1 f stx)
    (let lp ((rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (f (car e)) (lp (cdr e)))
          ((null? e) (void))
          (else (f rest))))))

  (define (stx-for-each2 f xstx ystx)
    (let lp ((xrest xstx) (yrest ystx))
      (let ((xe (syntax-e xrest)))
        (when (pair? xe)
          (let ((ye (syntax-e yrest)))
            (when (pair? ye)
              (f (car xe) (car ye))
              (lp (cdr xe) (cdr ye))))))))

  (define (stx-map1 f stx)
    (let recur ((rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (cons (f (car e)) (recur (cdr e))))
          ((null? e) '())
          (else (f rest))))))

  (define (stx-map2 f xstx ystx)
    (let recur ((xrest xstx) (yrest ystx))
      (let ((xe (syntax-e xrest)))
        (cond
          ((pair? xe)
           (let ((ye (syntax-e yrest)))
             (if (pair? ye)
               (cons (f (car xe) (car ye))
                     (recur (cdr xe) (cdr ye)))
               '())))
          (else '())))))

  ;; Override stx-map/stx-for-each with multi-arg versions
  (define stx-map
    (case-lambda
      ((f stx) (stx-map1 f stx))
      ((f xstx ystx) (stx-map2 f xstx ystx))))

  (define stx-for-each
    (case-lambda
      ((f stx) (stx-for-each1 f stx))
      ((f xstx ystx) (stx-for-each2 f xstx ystx))))

  (define (stx-andmap f stx)
    (let lp ((rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (and (f (car e)) (lp (cdr e))))
          ((null? e) #t)
          (else (f rest))))))

  (define (stx-ormap f stx)
    (let lp ((rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (or (f (car e)) (lp (cdr e))))
          ((null? e) #f)
          (else (f rest))))))

  (define (stx-foldl f iv stx)
    (let lp ((r iv) (rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (lp (f (car e) r) (cdr e)))
          ((null? e) r)
          (else (f rest r))))))

  (define (stx-foldr f iv stx)
    (let recur ((rest stx))
      (let ((e (syntax-e rest)))
        (cond
          ((pair? e) (f (car e) (recur (cdr e))))
          ((null? e) iv)
          (else (f rest iv))))))

  (define (stx-reverse stx) (stx-foldl cons '() stx))

  (define (stx-last stx)
    (let lp ((rest stx))
      (let ((e (syntax-e rest)))
        (if (pair? e)
          (if (null? (let ((ee (stx-e (cdr e)))) (if (null? ee) ee (cdr e))))
            (car e)
            (lp (cdr e)))
          rest))))

  (define (stx-last-pair stx)
    (let lp ((hd stx))
      (let ((e (syntax-e hd)))
        (if (and (pair? e) (stx-pair? (cdr e)))
          (lp (cdr e))
          hd))))

  (define (stx-list-tail stx k)
    (let lp ((rest stx) (k k))
      (if (fxpositive? k)
        (let ((e (syntax-e rest)))
          (if (pair? e)
            (lp (cdr e) (fx- k 1))
            rest))
        rest)))

  (define (stx-list-ref stx k)
    (stx-car (stx-list-tail stx k)))

  (define (syntax->list stx)
    (stx-map1 values stx))

  (define stx-plist?
    (case-lambda
      ((stx) (stx-plist? stx stx-keyword?))
      ((stx key?)
       (let lp ((rest stx))
         (let ((e (stx-e rest)))
           (cond
             ((null? e) #t)
             ((pair? e)
              (and (key? (car e))
                   (let ((e2 (stx-e (cdr e))))
                     (and (pair? e2) (lp (cdr e2))))))
             (else #f)))))))

  (define stx-getq
    (case-lambda
      ((key stx) (stx-getq key stx stx-eq?))
      ((key stx key=?)
       (let lp ((rest stx))
         (let ((e (syntax-e rest)))
           (cond
             ((pair? e)
              (let ((e2 (syntax-e (cdr e))))
                (cond
                  ((pair? e2)
                   (if (key=? (car e) key) (car e2)
                       (lp (cdr e2))))
                  (else #f))))
             (else #f)))))))

  ) ;; end library
