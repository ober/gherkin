(begin
  (begin
    (define setq-macro::t
      (make-class-type 'gerbil\x23;setq-macro::t 'setq-macro
        (list macro-object::t) '() '() '#f))
    (define (setq-macro . args) (apply make-setq-macro args))
    (define (setq-macro? obj)
      (\x23;\x23;structure-instance-of?
        obj
        'gerbil\x23;setq-macro::t))
    (define (make-setq-macro . args)
      (apply make-instance setq-macro::t args)))
  (begin
    (define setf-macro::t
      (make-class-type 'gerbil\x23;setf-macro::t 'setf-macro
        (list macro-object::t) '() '() '#f))
    (define (setf-macro . args) (apply make-setf-macro args))
    (define (setf-macro? obj)
      (\x23;\x23;structure-instance-of?
        obj
        'gerbil\x23;setf-macro::t))
    (define (make-setf-macro . args)
      (apply make-instance setf-macro::t args)))
  (define (syntax-local-setf-macro? stx)
    (and (identifier? stx)
         (setf-macro? (syntax-local-value stx false))))
  (define (syntax-local-setq-macro? stx)
    (and (identifier? stx)
         (setq-macro? (syntax-local-value stx false))))
  (define (expand-set! stx)
    (syntax-case stx ()
      [(_ (setf-id . _) expr)
       (syntax-local-setf-macro? #'setfid)
       (core-apply-expander (syntax-local-e #'setf-id) stx)]
      [(_ (getf arg ...) expr)
       (identifier? #'getf)
       (with-syntax ([setf (stx-identifier #'getf #'getf "-set!")])
         #'(setf arg ... expr))]
      [(_ setq-id . _)
       (syntax-local-setq-macro? #'setq-id)
       (core-apply-expander (syntax-local-e #'setq-id) stx)]
      [(_ id expr) (identifier? #'id) #'(%\x23;set! id expr)])))

(define-syntax set! (lambda (stx) (expand-set! stx)))

(define-syntax values-set!
  (lambda (stx)
    (syntax-case stx ()
      [(_ tgt ... expr)
       (with-syntax ([($e ...) (gentemps #'(tgt ...))])
         #'(let-values ([($e ...) expr]) (set! tgt $e) ...))])))

(define-syntax parameterize
  (syntax-rules ()
    [(_ () body ...) (let () body ...)]
    [(_ ((param value)) body ...)
     (call-with-parameters (lambda () body ...) param value)]
    [(recur ((param value) rest ...) body ...)
     (call-with-parameters
       (lambda () (recur (rest ...) body ...))
       param
       value)]))

(define-syntax let/cc
  (syntax-rules ()
    [(_ id body ...) (call/cc (lambda (id) body ...))]))

(define-syntax unwind-protect
  (syntax-rules ()
    [(_ body postlude rest ...)
     (with-unwind-protect
       (lambda () body)
       (lambda () postlude rest ...))]))

(define-syntax do
  (syntax-rules ()
    [(_ ((var init step ...) ...) (test fini ...) body ...)
     (let $loop ([var init] ...)
       (if test
           (begin 'unreadable-value fini ...)
           (let () body ... ($loop (begin var step ...) ...))))]))

(define-syntax do-while
  (syntax-rules ()
    [(_ ((var init step ...) ...) (test fini ...) body ...)
     (let $loop ([var init] ...)
       body
       ...
       (if test
           ($loop (begin var step ...) ...)
           (begin 'unreadable-value fini ...)))]))

(define-syntax while
  (syntax-rules ()
    [(while test body ...)
     (let lp () (when test body ... (lp)))]))

(define-syntax until
  (syntax-rules ()
    [(until test body ...)
     (let lp () (unless test body ... (lp)))]))

(define-syntax catch (syntax-rules ()))

(define-syntax finally (syntax-rules ()))

(define-syntax try
  (lambda (stx)
    (define (generate-thunk body)
      (if (null? body)
          (raise-syntax-error #f "Bad syntax; missing body" stx)
          (with-syntax ([(e ...) (reverse body)])
            #'(lambda () e ...))))
    (define (generate-fini thunk fini)
      (with-syntax ([thunk thunk] [(e ...) fini])
        #'(with-unwind-protect thunk (lambda () e ...))))
    (define (generate-catch handlers thunk)
      (with-syntax ([$e (genident)])
        (let lp ([rest handlers] [clauses (\x40;list)])
          (match rest
            [(\x40;list hd . rest)
             (syntax-case hd (=>)
               [(pred => K)
                (lp rest (cons #'(((? pred) $e) => K) clauses))]
               [((pred var) body ...)
                (identifier? #'var)
                (lp rest
                    (cons
                      #'(((? pred) $e) (let ([var $e]) body ...))
                      clauses))]
               [((var) body ...)
                (identifier? #'var)
                (lp rest (cons #'(#t (let ([var $e]) body ...)) clauses))]
               [(us body ...)
                (underscore? #'us)
                (lp rest (cons #'(#t (begin body ...)) clauses))])]
            [else
             (with-syntax ([(clause ...) clauses] [thunk thunk])
               #'(with-catch
                   (lambda ($e) (cond clause ... [else (raise $e)]))
                   thunk))]))))
    (syntax-case stx ()
      [(_ e ...)
       (let lp ([rest #'(e ...)] [body (\x40;list)])
         (syntax-case rest ()
           [(hd . rest)
            (syntax-case #'hd (catch finally)
              [(finally fini ...)
               (if (stx-null? #'rest)
                   (generate-fini (generate-thunk body) #'(fini ...))
                   (raise-syntax-error #f "Misplaced finally clause" stx))]
              [(catch handler ...)
               (let lp ([rest #'rest]
                        [handlers (\x40;list #'(handler ...))])
                 (syntax-case rest (catch finally)
                   [((catch handler ...) . rest)
                    (lp #'rest (\x40;list #'(handler ...) . handlers))]
                   [((finally fini ...))
                    (with-syntax ([body (generate-catch
                                          handlers
                                          (generate-thunk body))])
                      (generate-fini #'(lambda () body) #'(fini ...)))]
                   [() (generate-catch handlers (generate-thunk body))]))]
              [_ (lp #'rest (cons #'hd body))])]
           [() (cons 'begin (reverse body))]))])))

(define-syntax hash
  (syntax-rules ()
    [(hash (key val) ...)
     (~hash-table make-hash-table (key val) ...)]))

(define-syntax hash-eq
  (syntax-rules ()
    [(hash-eq (key val) ...)
     (~hash-table make-hash-table-eq (key val) ...)]))

(define-syntax hash-eqv
  (syntax-rules ()
    [(hash-eqv (key val) ...)
     (~hash-table make-hash-table-eqv (key val) ...)]))

(define-syntax ~hash-table
  (lambda (stx)
    (syntax-case stx ()
      [(_ make-ht entry ...)
       (with-syntax*
         ((size (stx-length #'(entry ...)))
           (((key val) ...) #'(entry ...)))
         #'(let (ht [make-ht size: size])
             (hash-put! ht `key val)
             ...
             ht))])))

(define-syntax \x40;bytes
  (lambda (stx)
    (syntax-case stx ()
      [(_ str)
       (stx-string? #'str)
       (with-syntax ([e (string->bytes (stx-e #'str))]) #''e)])))

(define-syntax eval-when-compile
  (lambda (stx)
    (syntax-case stx ()
      [(_ expr)
       (begin
         (when (current-expander-compiling?) (eval-syntax #'expr))
         #'(void))])))

