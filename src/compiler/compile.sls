#!chezscheme
;;; compile.sls -- Gerbil to Chez Scheme compiler
;;; Translates Gerbil source forms to Chez Scheme code.
;;; This is the bootstrap compiler that handles core Gerbil forms.

(library (compiler compile)
  (export
    gerbil-compile-top
    gerbil-compile-expression
    gerbil-compile-file
    gerbil-compile-to-library
    gerbil-compile-to-program
    collect-defined-names
    strip-annotations
    resolve-import
    *default-import-map*
    )

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise void)
            (error chez:error) (raise chez:raise) (void chez:void))
    (only (compat gambit-compat) |##keyword?| |##keyword->string|
          void? absent-obj? unbound-obj?)
    (compat types)
    (except (runtime util) void?)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax)
    (runtime eval)
    (only (reader reader)
          gerbil-read-file annotated-datum? annotated-datum-value))

  ;; --- Top-level form compilation ---
  ;; Takes a Gerbil s-expression and returns a Chez s-expression

  (define (gerbil-compile-top form)
    (cond
      ((not (pair? form)) form)
      (else
       (let ((head (car form)))
         (cond
           ;; def / define
           ((memq head '(def define))
            (compile-def form))
           ;; def* (case-lambda define)
           ((eq? head 'def*)
            (compile-def* form))
           ;; defstruct
           ((eq? head 'defstruct)
            (compile-defstruct form))
           ;; defclass
           ((eq? head 'defclass)
            (compile-defclass form))
           ;; defmethod
           ((eq? head 'defmethod)
            (compile-defmethod form))
           ;; defrules / defrule
           ((memq head '(defrules defrule))
            (compile-defrules form))
           ;; defsyntax
           ((eq? head 'defsyntax)
            (compile-defsyntax form))
           ;; begin
           ((eq? head 'begin)
            (cons 'begin (map gerbil-compile-top (cdr form))))
           ;; import
           ((eq? head 'import)
            (compile-import form))
           ;; export
           ((eq? head 'export)
            form) ;; pass through for now
           ;; interface
           ((eq? head 'interface)
            (compile-interface form))
           ;; defvalues
           ((eq? head 'defvalues)
            (compile-defvalues form))
           ;; include
           ((eq? head 'include)
            (compile-include form))
           ;; declare
           ((eq? head 'declare)
            '(begin)) ;; ignore declarations
           ;; expression
           (else
            (gerbil-compile-expression form)))))))

  ;; --- def / define compilation ---
  (define (compile-def form)
    ;; (def name expr) or (def (name args...) body...)
    ;; Also handles => type annotations:
    ;;   (def (name args...) => type body...)
    ;;   (def name : type expr)
    ;; Also handles optional args:
    ;;   (def (name req (opt default)) body...) → case-lambda
    ;; Also handles keyword args:
    ;;   (def (name req kw: (kw default)) body...) → case-lambda
    (let ((sig (cadr form))
          (body (cddr form)))
      (cond
        ;; (def (name args...) body...) or (def (name args...) => type body...)
        ((pair? sig)
         (let ((name (car sig))
               (params (cdr sig)))
           ;; Strip => type annotation if present
           (let ((real-body (if (and (pair? body) (pair? (cdr body))
                                    (eq? (car body) '=>))
                              (cddr body)  ;; skip => and type
                              body)))
             (if (has-optional-params? params)
               (compile-def-with-optionals name params real-body)
               `(define (,name ,@(compile-params params))
                  ,@(map gerbil-compile-expression real-body))))))
        ;; (def name : type expr) — type-annotated value
        ((and (pair? body) (eq? (car body) ':) (pair? (cdr body)) (pair? (cddr body)))
         `(define ,sig ,(gerbil-compile-expression (caddr body))))
        ;; (def name expr)
        (else
         (if (null? body)
           `(define ,sig (void))
           `(define ,sig ,(gerbil-compile-expression (car body))))))))

  ;; --- def* (case-lambda define) ---
  (define (compile-def* form)
    ;; (def* name (args body...) (args body...) ...)
    (let ((name (cadr form))
          (clauses (cddr form)))
      `(define ,name
         (case-lambda
           ,@(map (lambda (clause)
                    (let ((params (car clause))
                          (body (cdr clause)))
                      `(,(compile-params params) ,@(map gerbil-compile-expression body))))
                  clauses)))))

  ;; --- Parameter compilation ---
  ;; Handles Gerbil parameter syntax: rest args, optional args, keyword args
  (define (compile-params params)
    (cond
      ((null? params) '())
      ((symbol? params) params)  ;; rest arg
      ((pair? params)
       (let ((p (car params)))
         (cond
           ;; keyword arg: name: (name default) → skip (handled at def level)
           ((keyword-symbol? p)
            ;; Skip keyword and its spec, continue with rest
            (if (and (pair? (cdr params)) (pair? (cadr params)))
              (compile-params (cddr params))
              (compile-params (cdr params))))
           ;; optional arg: (name default) → just the name
           ((and (pair? p) (symbol? (car p)))
            (cons (car p) (compile-params (cdr params))))
           (else
            (cons p (compile-params (cdr params)))))))
      (else params)))

  ;; Check if param list has optional args: (name default) pairs
  (define (has-optional-params? params)
    (cond
      ((null? params) #f)
      ((not (pair? params)) #f)
      ((pair? (car params)) #t)
      ((keyword-symbol? (car params)) #t)
      (else (has-optional-params? (cdr params)))))

  ;; Extract required params (before first optional)
  (define (required-params params)
    (cond
      ((null? params) '())
      ((not (pair? params)) '())  ;; rest arg - not a required positional
      ((pair? (car params)) '())  ;; optional arg starts
      ((keyword-symbol? (car params)) '()) ;; keyword starts
      (else (cons (car params) (required-params (cdr params))))))

  ;; Extract optional params: list of (name default) pairs
  (define (optional-params params)
    (cond
      ((null? params) '())
      ((not (pair? params)) '())
      ((keyword-symbol? (car params))
       ;; keyword: (name default) → treat as optional
       (if (and (pair? (cdr params)) (pair? (cadr params)))
         (cons (cadr params) (optional-params (cddr params)))
         (optional-params (cdr params))))
      ((pair? (car params))
       (cons (car params) (optional-params (cdr params))))
      (else (optional-params (cdr params)))))

  ;; Extract rest param if any
  (define (rest-param params)
    (cond
      ((null? params) #f)
      ((symbol? params) params)
      ((pair? params)
       (if (null? (cdr params))
         #f
         (rest-param (cdr params))))
      (else #f)))

  ;; --- Expression compilation ---
  (define (gerbil-compile-expression expr)
    (cond
      ((not (pair? expr))
       (cond
         ;; Gerbil keyword object → quoted keyword string
         ((|##keyword?| expr)
          `(quote ,(string->symbol (string-append (|##keyword->string| expr) ":"))))
         ((and (symbol? expr) (keyword-symbol? expr))
          ;; Convert keyword: symbol to quoted keyword
          `(quote ,expr))
         ;; self.field dot notation → (slot-ref self 'field)
         ((and (symbol? expr) (dot-notation? expr))
          (compile-dot-ref expr))
         ;; #!void → (void)
         ((void? expr)
          '(void))
         ;; #!eof → (eof-object)
         ((eof-object? expr)
          '(eof-object))
         ;; #!optional (absent) → (absent-obj)
         ((absent-obj? expr)
          '(absent-obj))
         ;; #!unbound → (unbound-obj)
         ((unbound-obj? expr)
          '(unbound-obj))
         ;; ## Gambit primitives → FFI replacements
         ((and (symbol? expr) (gambit-primitive-replacement expr))
          => (lambda (x) x))
         (else expr)))
      (else
       (let ((head (car expr)))
         (cond
           ;; lambda
           ((eq? head 'lambda)
            (compile-lambda expr))
           ;; case-lambda
           ((eq? head 'case-lambda)
            `(case-lambda
               ,@(map (lambda (clause)
                        `(,(compile-params (car clause))
                          ,@(map gerbil-compile-expression (cdr clause))))
                      (cdr expr))))
           ;; let / let* / letrec / letrec*
           ((memq head '(let let* letrec letrec*))
            (compile-let head expr))
           ;; let-values / let*-values
           ((memq head '(let-values let*-values))
            `(,head ,(map (lambda (b)
                           `(,(car b) ,(gerbil-compile-expression (cadr b))))
                         (cadr expr))
                    ,@(map gerbil-compile-expression (cddr expr))))
           ;; let-hash
           ((eq? head 'let-hash)
            (compile-let-hash expr))
           ;; let/cc
           ((eq? head 'let/cc)
            (compile-let/cc expr))
           ;; awhen
           ((eq? head 'awhen)
            (compile-awhen expr))
           ;; and-let*
           ((eq? head 'and-let*)
            (compile-and-let* expr))
           ;; when / unless
           ((memq head '(when unless))
            `(,head ,(gerbil-compile-expression (cadr expr))
                    ,@(map gerbil-compile-expression (cddr expr))))
           ;; if
           ((eq? head 'if)
            `(if ,@(map gerbil-compile-expression (cdr expr))))
           ;; cond
           ((eq? head 'cond)
            `(cond ,@(map compile-cond-clause (cdr expr))))
           ;; case
           ((eq? head 'case)
            `(case ,(gerbil-compile-expression (cadr expr))
               ,@(map compile-case-clause (cddr expr))))
           ;; and / or
           ((memq head '(and or))
            `(,head ,@(map gerbil-compile-expression (cdr expr))))
           ;; begin
           ((eq? head 'begin)
            `(begin ,@(map gerbil-compile-expression (cdr expr))))
           ;; set!
           ((eq? head 'set!)
            (compile-set! expr))
           ;; quote
           ((eq? head 'quote) expr)
           ;; quasiquote
           ((eq? head 'quasiquote)
            (list 'quasiquote (compile-quasiquote (cadr expr))))
           ;; match
           ((eq? head 'match)
            (compile-match expr))
           ;; with ([id expr] ...) body -- destructuring
           ((eq? head 'with)
            (compile-with expr))
           ;; parameterize
           ((eq? head 'parameterize)
            `(parameterize ,(map (lambda (b)
                                  `(,(car b) ,(gerbil-compile-expression (cadr b))))
                                (cadr expr))
                           ,@(map gerbil-compile-expression (cddr expr))))
           ;; do
           ((eq? head 'do)
            `(do ,(map (lambda (b)
                        `(,(car b) ,(gerbil-compile-expression (cadr b))
                          ,@(if (null? (cddr b)) '() (list (gerbil-compile-expression (caddr b))))))
                      (cadr expr))
                 (,(gerbil-compile-expression (car (caddr expr)))
                  ,@(map gerbil-compile-expression (cdr (caddr expr))))
                 ,@(map gerbil-compile-expression (cdddr expr))))
           ;; values
           ((eq? head 'values)
            `(values ,@(map gerbil-compile-expression (cdr expr))))
           ;; receive -- (receive (vars...) producer body...)
           ((eq? head 'receive)
            (compile-receive expr))
           ;; apply
           ((eq? head 'apply)
            `(apply ,@(map gerbil-compile-expression (cdr expr))))
           ;; error
           ((eq? head 'error)
            `(error ,@(map gerbil-compile-expression (cdr expr))))
           ;; for-each / map / filter / fold
           ((memq head '(for-each map filter foldl foldr))
            (compile-stdlib-hof head expr))
           ;; Gerbil hash table operations → Chez hashtable
           ((memq head '(make-hash-table make-hash-table-eq make-hash-table-eqv))
            (compile-hash-constructor head expr))
           ((memq head '(hash-ref hash-get hash-put! hash-set!
                         hash-remove! hash-delete!
                         hash-key? hash-length
                         hash-keys hash-values hash->list hash->plist
                         list->hash-table list->hash-table-eq
                         hash-for-each hash-map hash-fold
                         hash-copy hash-merge hash-merge!
                         hash-update! hash-clear!))
            (compile-hash-op head expr))
           ;; for iteration
           ((memq head '(for for/collect for/fold for/or for/and))
            (compile-for head expr))
           ;; while / until loops
           ((eq? head 'while)
            (compile-while expr))
           ((eq? head 'until)
            (compile-until expr))
           ;; cut
           ((eq? head 'cut)
            (compile-cut expr))
           ;; syntax-case
           ((eq? head 'syntax-case)
            expr)  ;; pass through
           ;; with-syntax / with-syntax*
           ((memq head '(with-syntax with-syntax*))
            expr)  ;; pass through
           ;; try / catch / finally
           ((eq? head 'try)
            (compile-try expr))
           ;; with-exception-handler
           ((eq? head 'with-exception-handler)
            `(with-exception-handler
               ,(gerbil-compile-expression (cadr expr))
               ,(gerbil-compile-expression (caddr expr))))
           ;; with-catch (Gerbil-style): (with-catch handler (lambda () body ...))
           ;; → (guard (__exn (#t (handler __exn))) body ...)
           ;; Must unwrap the thunk since guard evaluates body directly
           ((eq? head 'with-catch)
            (let ((handler (gerbil-compile-expression (cadr expr)))
                  (body-form (caddr expr)))
              ;; If body is (lambda () expr ...), unwrap the thunk
              (let ((body-exprs
                      (if (and (pair? body-form)
                               (memq (car body-form) '(lambda #%lambda))
                               (null? (cadr body-form)))  ;; no args = thunk
                        (map gerbil-compile-expression (cddr body-form))
                        ;; Not a lambda — call the compiled thunk
                        (list `(,(gerbil-compile-expression body-form))))))
                `(guard (__exn (#t (,handler __exn)))
                   ,@body-exprs))))
           ;; with-unwind-protect
           ((eq? head 'with-unwind-protect)
            (compile-unwind-protect expr))
           ;; dynamic-wind
           ((eq? head 'dynamic-wind)
            `(dynamic-wind ,@(map gerbil-compile-expression (cdr expr))))
           ;; chain
           ((eq? head 'chain)
            (compile-chain expr))
           ;; using (type-checked binding)
           ((eq? head 'using)
            (compile-using expr))
           ;; => type annotation (strip it)
           ((eq? head '=>)
            (gerbil-compile-expression (cadr expr)))
           ;; assert / assume
           ((eq? head 'assert)
            `(assert ,(gerbil-compile-expression (cadr expr))))
           ((eq? head 'assume)
            ;; (assume type expr) → just compile expr (strip type annotation)
            (gerbil-compile-expression (caddr expr)))
           ;; gensym: convert symbol arg to string (Gambit accepts symbols, Chez requires strings)
           ((eq? head 'gensym)
            (if (null? (cdr expr))
              '(gensym)
              (let ((arg (cadr expr)))
                (cond
                  ;; (gensym 'sym) → (gensym "sym")
                  ((and (pair? arg) (eq? (car arg) 'quote) (symbol? (cadr arg)))
                   `(gensym ,(symbol->string (cadr arg))))
                  ;; (gensym "str") → pass through
                  ((string? arg) `(gensym ,arg))
                  ;; anything else → compile and convert at runtime
                  (else `(gensym (let ((x ,(gerbil-compile-expression arg)))
                                   (if (symbol? x) (symbol->string x) x))))))))
           ;; spawn / spawn/name
           ((eq? head 'spawn)
            (compile-spawn expr))
           ((eq? head 'spawn/name)
            (compile-spawn/name expr))
           ;; with-lock
           ((eq? head 'with-lock)
            (compile-with-lock expr))
           ;; void
           ((eq? head 'void)
            '(void))
           ;; def/define in expression context (inside function body)
           ((memq head '(def define))
            (compile-def expr))
           ;; def* in expression context
           ((eq? head 'def*)
            (compile-def* expr))
           ;; @list -- reader-generated form for [...]
           ((eq? head '@list)
            `(list ,@(map gerbil-compile-expression (cdr expr))))
           ;; @method -- reader-generated form for {...}
           ((eq? head '@method)
            (compile-at-method expr))
           ;; hash literal: (hash (key val) ...)
           ((eq? head 'hash)
            (compile-hash-literal expr))
           ;; displayln / println
           ((eq? head 'displayln)
            (compile-displayln expr))
           ;; string-join, string-split
           ((memq head '(string-join string-split))
            (compile-string-op head expr))
           ;; Gambit/Gerbil string utilities compiled inline
           ((eq? head 'string-contains)
            (compile-string-contains expr))
           ((eq? head 'string-prefix?)
            (compile-string-prefix? expr))
           ((eq? head 'string-suffix?)
            (compile-string-suffix? expr))
           ;; read-line: Gambit read-line → Chez get-line
           ((eq? head 'read-line)
            (if (null? (cdr expr))
              '(get-line (current-input-port))
              `(get-line ,(gerbil-compile-expression (cadr expr)))))
           ;; force-output: Gambit force-output → Chez flush-output-port
           ((eq? head 'force-output)
            (if (null? (cdr expr))
              '(flush-output-port (current-output-port))
              `(flush-output-port ,(gerbil-compile-expression (cadr expr)))))
           ;; pp / pretty-print
           ((memq head '(pp pretty-print))
            `(pretty-print ,@(map gerbil-compile-expression (cdr expr))))
           ;; time->seconds
           ((eq? head 'time->seconds)
            (if (null? (cdr expr))
              ;; (time->seconds) → current time as float
              '(let ((t (current-time)))
                 (+ (time-second t)
                    (/ (time-nanosecond t) 1000000000.0)))
              ;; (time->seconds t) → convert time object
              (let ((t (gerbil-compile-expression (cadr expr))))
                `(let ((t ,t))
                   (if (time? t)
                     (+ (time-second t)
                        (/ (time-nanosecond t) 1000000000.0))
                     t)))))
           ;; ##current-time
           ((eq? head '|##current-time|)
            '(current-time))
           ;; make-parameter → Chez make-parameter
           ((eq? head 'make-parameter)
            `(make-parameter ,@(map gerbil-compile-expression (cdr expr))))
           ;; make-will → Chez guardian
           ((eq? head 'make-will)
            (compile-make-will expr))
           ;; subvector
           ((eq? head 'subvector)
            (compile-subvector expr))
           ;; open-input-string / open-output-string / get-output-string
           ((memq head '(open-input-string open-output-string
                         get-output-string with-input-from-string))
            `(,head ,@(map gerbil-compile-expression (cdr expr))))
           ;; object->u8vector / u8vector->object (Gambit serialization)
           ((eq? head 'object->u8vector)
            (compile-object->u8vector expr))
           ((eq? head 'u8vector->object)
            (compile-u8vector->object expr))
           ;; if-let
           ((eq? head 'if-let)
            (compile-if-let expr))
           ;; when-let
           ((eq? head 'when-let)
            (compile-when-let expr))
           ;; ignore-errors
           ((eq? head 'ignore-errors)
            (compile-ignore-errors expr))
           ;; with-destroy
           ((eq? head 'with-destroy)
            (compile-with-destroy expr))
           ;; do-while
           ((eq? head 'do-while)
            (compile-do-while expr))
           ;; values-set!
           ((eq? head 'values-set!)
            (compile-values-set! expr))
           ;; delay / force / lazy — pass through to Chez
           ((memq head '(delay force lazy))
            `(,head ,@(map gerbil-compile-expression (cdr expr))))
           ;; cond-expand
           ((eq? head 'cond-expand)
            (compile-cond-expand expr))
           ;; default: function application
           (else
            (map gerbil-compile-expression expr)))))))

  ;; --- let compilation ---
  (define (compile-let head expr)
    (let ((bindings-or-name (cadr expr)))
      (cond
        ;; named let: (let name ((var init) ...) body...)
        ((symbol? bindings-or-name)
         `(let ,bindings-or-name
            ,(map (lambda (b)
                    `(,(car b) ,(gerbil-compile-expression (cadr b))))
                  (caddr expr))
            ,@(map gerbil-compile-expression (cdddr expr))))
        ;; Gerbil-style single binding: (let (name init) body...)
        ;; vs R6RS: (let ((name init) ...) body...)
        ((and (pair? bindings-or-name)
              (symbol? (car bindings-or-name))
              (not (pair? (car bindings-or-name))))
         ;; Single binding: (let (x expr) body...) → (let ((x expr)) body...)
         `(,head ((,(car bindings-or-name)
                   ,(gerbil-compile-expression (cadr bindings-or-name))))
                 ,@(map gerbil-compile-expression (cddr expr))))
        ;; Standard bindings
        (else
         `(,head ,(map (lambda (b)
                         `(,(car b) ,(gerbil-compile-expression (cadr b))))
                       bindings-or-name)
                 ,@(map gerbil-compile-expression (cddr expr)))))))

  ;; --- cond clause compilation ---
  (define (compile-cond-clause clause)
    (cond
      ((eq? (car clause) 'else)
       `(else ,@(map gerbil-compile-expression (cdr clause))))
      ((and (pair? (cdr clause)) (eq? (cadr clause) '=>))
       `(,(gerbil-compile-expression (car clause)) => ,(gerbil-compile-expression (caddr clause))))
      (else
       (map gerbil-compile-expression clause))))

  ;; --- case clause compilation ---
  (define (compile-case-clause clause)
    (if (eq? (car clause) 'else)
      `(else ,@(map gerbil-compile-expression (cdr clause)))
      ;; Compile datums: convert keyword objects to symbols
      (let ((datums (map (lambda (d)
                           (cond
                             ((|##keyword?| d)
                              (string->symbol (string-append (|##keyword->string| d) ":")))
                             (else d)))
                         (car clause))))
        `(,datums ,@(map gerbil-compile-expression (cdr clause))))))

  ;; --- quasiquote compilation ---
  (define (compile-quasiquote expr)
    (cond
      ((not (pair? expr)) expr)
      ((eq? (car expr) 'unquote)
       (list 'unquote (gerbil-compile-expression (cadr expr))))
      ((eq? (car expr) 'unquote-splicing)
       (list 'unquote-splicing (gerbil-compile-expression (cadr expr))))
      (else
       (cons (compile-quasiquote (car expr))
             (compile-quasiquote (cdr expr))))))

  ;; --- match compilation ---
  ;; Translates (match expr (pattern body...) ...) to cond/let chains
  (define (compile-match form)
    (let ((expr (cadr form))
          (clauses (cddr form)))
      (let ((tmp (gensym "match-val")))
        `(let ((,tmp ,(gerbil-compile-expression expr)))
           ,(compile-match-clauses tmp clauses)))))

  (define (compile-match-clauses target clauses)
    (if (null? clauses)
      `(error 'match "no matching clause" ,target)
      (let ((clause (car clauses))
            (rest (cdr clauses)))
        (let ((pattern (car clause))
              (body (cdr clause)))
          (cond
            ;; (else body...)
            ((eq? pattern 'else)
             `(begin ,@(map gerbil-compile-expression body)))
            ;; (_ body...) - wildcard
            ((eq? pattern '_)
             `(begin ,@(map gerbil-compile-expression body)))
            ;; #(pats...) - vector pattern
            ((vector? pattern)
             (compile-match-pattern target pattern
               `(begin ,@(map gerbil-compile-expression body))
               (compile-match-clauses target rest)))
            ;; ([hd . rest] body...) - pair destructuring / struct / quoted etc.
            ((pair? pattern)
             (compile-match-pattern target pattern
               `(begin ,@(map gerbil-compile-expression body))
               (compile-match-clauses target rest)))
            ;; literal
            (else
             `(if (equal? ,target ',pattern)
                ,(if (null? body) #t
                     `(begin ,@(map gerbil-compile-expression body)))
                ,(compile-match-clauses target rest))))))))

  (define (compile-match-pattern target pattern success fail)
    (cond
      ;; wildcard
      ((eq? pattern '_) success)

      ;; (? pred) — bare predicate test
      ;; (? pred var) — predicate test + bind var
      ;; (? pred => pat) — predicate test, bind result to pat
      ((and (pair? pattern) (eq? (car pattern) '?))
       (compile-match-predicate target pattern success fail))

      ;; (and pat1 pat2 ...) — all patterns must match
      ((and (pair? pattern) (eq? (car pattern) 'and))
       (compile-match-and target (cdr pattern) success fail))

      ;; (or pat1 pat2 ...) — first matching pattern wins
      ((and (pair? pattern) (eq? (car pattern) 'or))
       (compile-match-or target (cdr pattern) success fail))

      ;; (not pat) — pattern must NOT match
      ((and (pair? pattern) (eq? (car pattern) 'not))
       (compile-match-pattern target (cadr pattern) fail success))

      ;; (apply func pat) — apply func, match result against pat
      ((and (pair? pattern) (eq? (car pattern) 'apply))
       (let ((func (cadr pattern))
             (pat (caddr pattern))
             (tmp (gensym "apply-val")))
         `(let ((,tmp (,(gerbil-compile-expression func) ,target)))
            ,(compile-match-pattern tmp pat success fail))))

      ;; (quote datum) — quoted literal comparison
      ((and (pair? pattern) (eq? (car pattern) 'quote))
       (let ((datum (cadr pattern)))
         (cond
           ((or (symbol? datum) (boolean? datum) (char? datum) (null? datum))
            `(if (eq? ,target ',datum) ,success ,fail))
           ((number? datum)
            `(if (eqv? ,target ',datum) ,success ,fail))
           (else
            `(if (equal? ,target ',datum) ,success ,fail)))))

      ;; #(pat ...) — vector pattern
      ((vector? pattern)
       (compile-match-vector target (vector->list pattern) success fail))

      ;; (@list pat ...) — list pattern from reader
      ((and (pair? pattern) (eq? (car pattern) '@list))
       (compile-match-list-pattern target (cdr pattern) success fail))

      ;; (StructName pat ...) — struct pattern if name ends with known type conventions
      ;; We detect struct patterns by checking if the head symbol has a companion
      ;; predicate (Name?) in scope. Since we can't check scope at compile time,
      ;; we use a heuristic: if the head is a capitalized symbol, treat as struct pattern.
      ((and (pair? pattern)
            (symbol? (car pattern))
            (let ((s (symbol->string (car pattern))))
              (and (> (string-length s) 0)
                   (char-upper-case? (string-ref s 0)))))
       (compile-match-struct target (car pattern) (cdr pattern) success fail))

      ;; (hd . rest) — pair/cons destructuring
      ((pair? pattern)
       (let ((hd-pattern (car pattern))
             (rest-pattern (cdr pattern)))
         (let ((hd-tmp (gensym "hd"))
               (tl-tmp (gensym "tl")))
           `(if (pair? ,target)
              (let ((,hd-tmp (car ,target))
                    (,tl-tmp (cdr ,target)))
                ,(compile-match-pattern hd-tmp hd-pattern
                   (compile-match-pattern tl-tmp rest-pattern success fail)
                   fail))
              ,fail))))

      ;; [] - null
      ((null? pattern)
       `(if (null? ,target) ,success ,fail))

      ;; symbol — bind it
      ((symbol? pattern)
       `(let ((,pattern ,target)) ,success))

      ;; literal (number, string, char, boolean)
      (else
       `(if (equal? ,target ',pattern) ,success ,fail))))

  ;; --- Match: predicate patterns ---
  (define (compile-match-predicate target pattern success fail)
    ;; (? pred) — bare predicate
    ;; (? pred var) — predicate + bind
    ;; (? (lambda (v) ...) var) — lambda predicate + bind
    ;; (? (not pred)) — negated predicate
    (let ((pred-expr (cadr pattern))
          (rest (cddr pattern)))
      (cond
        ;; (? (not pred)) — negated
        ((and (pair? pred-expr) (eq? (car pred-expr) 'not))
         `(if (not (,(gerbil-compile-expression (cadr pred-expr)) ,target))
            ,success ,fail))
        ;; (? pred var) — test and bind
        ((and (pair? rest) (symbol? (car rest)))
         `(if (,(gerbil-compile-expression pred-expr) ,target)
            (let ((,(car rest) ,target)) ,success)
            ,fail))
        ;; (? pred pat) — test and match sub-pattern
        ((pair? rest)
         `(if (,(gerbil-compile-expression pred-expr) ,target)
            ,(compile-match-pattern target (car rest) success fail)
            ,fail))
        ;; (? pred) — bare test
        (else
         `(if (,(gerbil-compile-expression pred-expr) ,target)
            ,success ,fail)))))

  ;; --- Match: and patterns ---
  (define (compile-match-and target patterns success fail)
    ;; All patterns must match
    (if (null? patterns)
      success
      (compile-match-pattern target (car patterns)
        (compile-match-and target (cdr patterns) success fail)
        fail)))

  ;; --- Match: or patterns ---
  (define (compile-match-or target patterns success fail)
    ;; First matching pattern wins
    (if (null? patterns)
      fail
      (compile-match-pattern target (car patterns)
        success
        (compile-match-or target (cdr patterns) success fail))))

  ;; --- Match: vector patterns ---
  (define (compile-match-vector target pats success fail)
    ;; Match against vector elements
    (let ((n (length pats)))
      `(if (and (vector? ,target) (= (vector-length ,target) ,n))
         ,(compile-match-vector-elems target pats 0 success fail)
         ,fail)))

  (define (compile-match-vector-elems target pats idx success fail)
    (if (null? pats)
      success
      (let ((tmp (gensym "vec-elem")))
        `(let ((,tmp (vector-ref ,target ,idx)))
           ,(compile-match-pattern tmp (car pats)
              (compile-match-vector-elems target (cdr pats) (+ idx 1) success fail)
              fail)))))

  ;; --- Match: list pattern from @list ---
  (define (compile-match-list-pattern target pats success fail)
    ;; (@list a b c) from [a b c] → match against list elements
    ;; Handle dotted pairs too: (@list a b . rest)
    (cond
      ((null? pats)
       `(if (null? ,target) ,success ,fail))
      ((and (not (pair? pats)) (symbol? pats))
       ;; Rest binding: (... . rest)
       `(let ((,pats ,target)) ,success))
      ((pair? pats)
       (let ((hd-tmp (gensym "hd"))
             (tl-tmp (gensym "tl")))
         `(if (pair? ,target)
            (let ((,hd-tmp (car ,target))
                  (,tl-tmp (cdr ,target)))
              ,(compile-match-pattern hd-tmp (car pats)
                 (compile-match-list-pattern tl-tmp (cdr pats) success fail)
                 fail))
            ,fail)))
      (else fail)))

  ;; --- Match: struct patterns ---
  (define (compile-match-struct target struct-name field-pats success fail)
    ;; (StructName pat1 pat2 ...) → check predicate, extract fields
    ;; Generates: (if (StructName? target)
    ;;              (let ((tmp1 (StructName-field1 target)) ...)
    ;;                (match-pattern tmp1 pat1 ... success fail))
    ;;              fail)
    (let* ((pred-name (string->symbol
                        (string-append (symbol->string struct-name) "?")))
           (type-sym (string->symbol
                       (string-append (symbol->string struct-name) "::t"))))
      ;; Use slot-ref for field access (works with inherited fields)
      ;; We need to get field names from the type at runtime
      `(if (,pred-name ,target)
         ,(compile-match-struct-fields target type-sym field-pats 1 success fail)
         ,fail)))

  (define (compile-match-struct-fields target type-sym field-pats idx success fail)
    ;; Extract struct fields positionally using |##structure-ref|
    (if (null? field-pats)
      success
      (let ((pat (car field-pats))
            (tmp (gensym "field")))
        (if (eq? pat '_)
          ;; Wildcard — skip this field
          (compile-match-struct-fields target type-sym (cdr field-pats) (+ idx 1) success fail)
          `(let ((,tmp (|##structure-ref| ,target ,idx)))
             ,(compile-match-pattern tmp pat
                (compile-match-struct-fields target type-sym (cdr field-pats) (+ idx 1) success fail)
                fail))))))

  ;; --- cut compilation ---
  (define (compile-cut form)
    ;; (cut proc <> arg) → (lambda (x) (proc x arg))
    (let ((parts (cdr form))
          (args '())
          (call '()))
      (let lp ((rest parts) (params '()) (call-parts '()))
        (cond
          ((null? rest)
           (let ((params (reverse params))
                 (call (reverse call-parts)))
             `(lambda ,params ,call)))
          ((eq? (car rest) '<>)
           (let ((tmp (gensym "cut-arg")))
             (lp (cdr rest) (cons tmp params) (cons tmp call-parts))))
          (else
           (lp (cdr rest) params (cons (gerbil-compile-expression (car rest)) call-parts)))))))

  ;; --- with compilation ---
  (define (compile-with form)
    ;; (with ([a b] expr) body...) → (let-values (((a b) expr)) body...)
    ;; (with (name expr) body...) → (let ((name expr)) body...)
    (let ((binding (cadr form))
          (body (cddr form)))
      (cond
        ((and (pair? (car binding)) (pair? (car (car binding))))
         ;; destructuring: (with ([a b] expr) body...)
         `(let-values (((,@(car binding)) ,(gerbil-compile-expression (cadr binding))))
            ,@(map gerbil-compile-expression body)))
        (else
         ;; simple: (with (name expr) body...)
         `(let ((,(car binding) ,(gerbil-compile-expression (cadr binding))))
            ,@(map gerbil-compile-expression body))))))

  ;; --- defstruct compilation ---
  (define (compile-defstruct form)
    ;; (defstruct name (field1 field2 ...))
    ;; (defstruct (name parent) (field1 field2 ...))
    ;; With optional properties: id:, name:, print:, etc.
    (let* ((name-spec (cadr form))
           (fields-and-props (cddr form))
           (name (if (pair? name-spec) (car name-spec) name-spec))
           (parent (if (pair? name-spec) (cadr name-spec) #f))
           (fields (if (pair? fields-and-props) (car fields-and-props) '()))
           (props (if (and (pair? fields-and-props) (pair? (cdr fields-and-props)))
                    (cdr fields-and-props) '())))
      (let* ((type-id (extract-prop 'id: props
                       (string->symbol (string-append "gerbil#" (symbol->string name) "::t"))))
             (type-name (extract-prop 'name: props name))
             (parent-type (if parent
                           (string->symbol (string-append (symbol->string parent) "::t"))
                           #f))
             (parent-ref (if parent-type `(list ,parent-type) `(list object::t))))
        `(begin
           ;; Create type descriptor
           (define ,(string->symbol (string-append (symbol->string name) "::t"))
             (make-class-type ',type-id ',type-name ,parent-ref
               ',(if (list? fields) fields (list fields))
               '((struct: . #t))
               #f))
           ;; Constructor: takes all fields (inherited + own) positionally
           ;; Uses runtime slot-vector to determine field order
           (define (,(string->symbol (string-append "make-" (symbol->string name))) . args)
             (let* ((type ,(string->symbol (string-append (symbol->string name) "::t")))
                    (all-slots (cdr (vector->list (class-type-slot-vector type))))
                    (obj (make-class-instance type)))
               (let lp ((slots all-slots) (rest args) (i 1))
                 (when (and (pair? slots) (pair? rest))
                   (|##structure-set!| obj i (car rest))
                   (lp (cdr slots) (cdr rest) (+ i 1))))
               obj))
           ;; Predicate
           (define (,(string->symbol (string-append (symbol->string name) "?")) obj)
             (|##structure-instance-of?| obj ',type-id))
           ;; Accessors (use slot-ref for correctness with inheritance)
           ,@(let lp ((fs fields) (acc '()))
               (if (null? fs)
                 (reverse acc)
                 (lp (cdr fs)
                     (cons `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))))
                                    obj)
                              (slot-ref obj ',(car fs)))
                           acc))))
           ;; Mutators
           ,@(let lp ((fs fields) (mut '()))
               (if (null? fs)
                 (reverse mut)
                 (lp (cdr fs)
                     (cons `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))
                                                      "-set!"))
                                    obj val)
                              (slot-set! obj ',(car fs) val))
                           mut))))))))

  ;; --- defclass compilation ---
  (define (compile-defclass form)
    ;; (defclass name (field1 field2 ...) options...)
    ;; (defclass (name parent1 parent2 ...) (field1 field2 ...) options...)
    (let* ((name-spec (cadr form))
           (rest (cddr form))
           (name (if (pair? name-spec) (car name-spec) name-spec))
           (parents (if (pair? name-spec) (cdr name-spec) '()))
           (fields (if (pair? rest) (car rest) '()))
           (props (if (and (pair? rest) (pair? (cdr rest))) (cdr rest) '())))
      (let* ((type-id (extract-prop 'id: props
                       (string->symbol (string-append "gerbil#" (symbol->string name) "::t"))))
             (type-name (extract-prop 'name: props name))
             (parent-type-refs (map (lambda (p)
                                      (string->symbol (string-append (symbol->string p) "::t")))
                                    parents))
             (parent-refs (if (null? parent-type-refs) `(list object::t)
                            `(list ,@parent-type-refs))))
        (let ((type-sym (string->symbol (string-append (symbol->string name) "::t")))
              (make-sym (string->symbol (string-append "make-" (symbol->string name)))))
          `(begin
             (define ,type-sym
               (make-class-type ',type-id ',type-name ,parent-refs
                 ',(if (list? fields) fields (list fields))
                 '()
                 #f))
             ;; Bare class name alias (for method-set!, etc.)
             (define ,name ,type-sym)
             ;; Predicate
             (define (,(string->symbol (string-append (symbol->string name) "?")) obj)
               (|##structure-instance-of?| obj ',type-id))
             ;; Constructor: (make-<name> keyword-args...) → creates instance, calls :init!
             (define (,make-sym . args)
               (let ((obj (make-class-instance ,type-sym))
                     (init-fn (method-ref ,type-sym ':init!)))
                 (when init-fn
                   ;; Strip keyword symbols from args: 'parent: val 'name: val → val val
                   (let ((positional (let lp ((rest args) (acc '()))
                                      (cond
                                        ((null? rest) (reverse acc))
                                        ((and (pair? (cdr rest))
                                              (symbol? (car rest))
                                              (let ((s (symbol->string (car rest))))
                                                (and (> (string-length s) 0)
                                                     (char=? (string-ref s (- (string-length s) 1)) #\:))))
                                         ;; keyword: value pair → take value, skip keyword
                                         (lp (cddr rest) (cons (cadr rest) acc)))
                                        (else (lp (cdr rest) (cons (car rest) acc)))))))
                     (apply init-fn obj positional)))
                 obj))
             ;; Accessors and mutators for each field
             ,@(let lp ((fs (if (list? fields) fields (list fields))) (acc '()))
                 (if (null? fs)
                   (reverse acc)
                   (lp (cdr fs)
                       (append
                         (list
                           `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))))
                                    obj)
                              (slot-ref obj ',(car fs)))
                           `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))
                                                      "-set!"))
                                    obj val)
                              (slot-set! obj ',(car fs) val)))
                         acc)))))))))

  ;; --- defmethod compilation ---
  (define (compile-defmethod form)
    ;; (defmethod {name type} body) or (defmethod (name (self type) args...) body...)
    (let ((sig (cadr form))
          (body (cddr form)))
      (cond
        ;; (defmethod {name type} lambda-expr)
        ((and (pair? sig) (eq? (car sig) '@method))
         (let ((name (cadr sig))
               (type (caddr sig)))
           `(method-set! ,type ',name ,(gerbil-compile-expression (car body)))))
        ;; (defmethod (name (self type) args...) body...)
        ;; → (method-set! type::t 'name (lambda (self args...) body...))
        ((and (pair? sig) (symbol? (car sig)) (pair? (cdr sig))
              (pair? (cadr sig)))
         (let* ((method-name (car sig))
                (typed-param (cadr sig))
                (self-name (car typed-param))
                (type-name (cadr typed-param))
                (other-args (cddr sig))
                (type-sym (string->symbol
                            (string-append (symbol->string type-name) "::t")))
                ;; Strip => type annotation from body if present
                (real-body (if (and (pair? body) (pair? (cdr body))
                                   (eq? (car body) '=>))
                             (cddr body)
                             body)))
           `(method-set! ,type-sym ',method-name
              (lambda (,self-name ,@other-args)
                ,@(map gerbil-compile-expression real-body)))))
        ;; Fallback: just compile body
        (else
         `(begin ,@(map gerbil-compile-expression body))))))

  ;; --- interface compilation ---
  ;; (interface Name (method1 arg1 ...) (method2 arg1 ...))
  ;; (interface (Name Parent1 Parent2) (method arg ...))
  ;; Generates:
  ;;   - Name-method dispatchers that call call-method
  ;;   - Name? predicate (always #t for duck typing)
  ;;   - is-Name? satisfies predicate
  ;;   - make-Name constructor (identity — relies on duck typing)
  (define (compile-interface form)
    (let* ((spec (cadr form))
           (name (if (pair? spec) (car spec) spec))
           (methods-raw (cddr form))
           ;; Parse method specs, stripping => type annotations
           (methods (let lp ((ms methods-raw) (result '()))
                      (cond
                        ((null? ms) (reverse result))
                        ;; Skip => type annotation at end
                        ((eq? (car ms) '=>) (reverse result))
                        ((pair? (car ms))
                         (lp (cdr ms) (cons (car ms) result)))
                        (else (lp (cdr ms) result)))))
           (name-str (symbol->string name)))
      `(begin
         ;; Predicate (duck-typing: anything can satisfy an interface)
         (define (,(string->symbol (string-append name-str "?")) obj)
           (and (|##structure?| obj) #t))
         ;; Satisfies predicate
         (define (,(string->symbol (string-append "is-" name-str "?")) obj)
           (and (|##structure?| obj) #t))
         ;; Constructor (identity for duck typing)
         (define (,(string->symbol (string-append "make-" name-str)) obj) obj)
         ;; Try-constructor (identity, returns #f on failure)
         (define (,(string->symbol (string-append "try-" name-str)) obj)
           (if (|##structure?| obj) obj #f))
         ;; Method dispatchers
         ,@(map (lambda (method-spec)
                  (let* ((method-name (car method-spec))
                         (args (cdr method-spec))
                         ;; Strip type annotations from args
                         (clean-args (let lp ((as args) (result '()))
                                       (cond
                                         ((null? as) (reverse result))
                                         ;; Skip : type and :? type annotations
                                         ((memq (car as) '(: :? =>))
                                          (if (pair? (cdr as))
                                            (lp (cddr as) result)
                                            (lp (cdr as) result)))
                                         ;; Skip keyword-like symbols
                                         ((and (symbol? (car as))
                                               (let ((s (symbol->string (car as))))
                                                 (and (> (string-length s) 0)
                                                      (char=? (string-ref s (- (string-length s) 1)) #\:))))
                                          ;; keyword: value pair
                                          (if (pair? (cdr as))
                                            (lp (cddr as) result)
                                            (lp (cdr as) result)))
                                         (else
                                          (let ((arg (car as)))
                                            (lp (cdr as)
                                                (cons (if (pair? arg) (car arg) arg)
                                                      result)))))))
                         (disp-name (string->symbol
                                      (string-append name-str "-"
                                                     (symbol->string method-name)))))
                    `(define (,disp-name obj ,@clean-args)
                       (call-method obj ',(compile-method-symbol method-name)
                                    ,@clean-args))))
                methods))))

  ;; Compile method name symbol - strip trailing ! if present for method lookup
  (define (compile-method-symbol sym) sym)

  ;; --- defrules compilation ---
  (define (compile-defrules form)
    ;; (defrules name () (pattern template) ...)
    ;; (defrule (name pattern) template)
    (let ((name (if (eq? (car form) 'defrule)
                  (caadr form)   ;; defrule: (defrule (NAME . pattern) template)
                  (cadr form)))) ;; defrules: (defrules NAME (kws) clauses...)
      (if (eq? (car form) 'defrule)
        ;; (defrule (name . pattern) template)
        (let ((pattern (cdr (cadr form)))
              (template (caddr form)))
          `(define-syntax ,name
             (syntax-rules ()
               ((,name ,@pattern) ,template))))
        ;; (defrules name (kws...) (pattern template) ...)
        (let ((kws (caddr form))
              (clauses (cdddr form)))
          `(define-syntax ,name
             (syntax-rules ,kws
               ,@(map (lambda (clause)
                        (let ((pattern (car clause))
                              (template (cadr clause)))
                          `((,name ,@(if (pair? pattern) pattern (list pattern)))
                            ,template)))
                      clauses)))))))

  ;; --- defsyntax compilation ---
  (define (compile-defsyntax form)
    ;; (defsyntax (name stx) body...)
    ;; (defsyntax name expr)
    (let ((sig (cadr form))
          (body (cddr form)))
      (if (pair? sig)
        `(define-syntax ,(car sig)
           (lambda ,(cdr sig)
             ,@(map gerbil-compile-expression body)))
        `(define-syntax ,sig ,(gerbil-compile-expression (car body))))))

  ;; --- set! compilation (handles accessor targets and dot notation) ---
  (define (compile-set! expr)
    ;; (set! (accessor obj) val) → (accessor-set! obj val)
    ;; (set! self.field val) → (slot-set! self 'field val)
    ;; (set! var val) → (set! var val)
    (let ((target (cadr expr))
          (val (caddr expr)))
      (cond
        ;; (set! (accessor obj) val) → (accessor-set! obj val)
        ((pair? target)
         (let* ((accessor (car target))
                (obj (cadr target))
                (setter (string->symbol
                          (string-append (symbol->string accessor) "-set!"))))
           `(,setter ,(gerbil-compile-expression obj)
                     ,(gerbil-compile-expression val))))
        ;; (set! self.field val) → (slot-set! self 'field val)
        ((and (symbol? target) (dot-notation? target))
         (let-values (((obj-sym field-sym) (split-dot-notation target)))
           `(slot-set! ,obj-sym ',field-sym ,(gerbil-compile-expression val))))
        ;; Normal set!
        (else
         `(set! ,target ,(gerbil-compile-expression val))))))

  ;; --- Gambit primitive replacements ---
  ;; Map ##-prefixed Gambit primitives to Chez equivalents
  (define *gambit-primitive-map*
    '((|##os-getpid|  . ffi-getpid)
      (|##os-getppid| . ffi-getppid)))

  (define (gambit-primitive-replacement sym)
    (let ((s (symbol->string sym)))
      (and (>= (string-length s) 2)
           (char=? (string-ref s 0) #\#)
           (char=? (string-ref s 1) #\#)
           (let ((entry (assq sym *gambit-primitive-map*)))
             (and entry (cdr entry))))))

  ;; --- Dot notation: self.field ---
  ;; Only treat as dot-notation if the left side starts with a lowercase
  ;; letter (object variables). Symbols starting with uppercase like
  ;; CompletionItemKind.Snippet are constant names, not slot access.
  (define (dot-notation? sym)
    (and (symbol? sym)
         (let ((s (symbol->string sym)))
           (and (> (string-length s) 2)
                (char-lower-case? (string-ref s 0))
                (let lp ((i 1))
                  (cond
                    ((>= i (- (string-length s) 1)) #f)
                    ((char=? (string-ref s i) #\.) #t)
                    (else (lp (+ i 1)))))))))

  (define (split-dot-notation sym)
    (let* ((s (symbol->string sym))
           (dot-pos (let lp ((i 0))
                      (if (char=? (string-ref s i) #\.)
                        i (lp (+ i 1))))))
      (values (string->symbol (substring s 0 dot-pos))
              (string->symbol (substring s (+ dot-pos 1) (string-length s))))))

  (define (compile-dot-ref sym)
    ;; self.field → (slot-ref self 'field)
    (let-values (((obj-sym field-sym) (split-dot-notation sym)))
      `(slot-ref ,obj-sym ',field-sym)))

  ;; --- hash literal compilation ---
  (define (compile-hash-literal expr)
    ;; (hash (key val) ...) → (let ((ht (make-hash-table))) (hash-put! ht 'key val)... ht)
    ;; In Gerbil, hash literal keys are implicitly quoted symbols
    (let ((pairs (cdr expr))
          (ht (gensym "ht")))
      (define (compile-hash-key k)
        (cond
          ((symbol? k) `(quote ,k))     ;; symbol keys → quoted
          ((string? k) k)               ;; string keys stay as-is
          (else (gerbil-compile-expression k))))
      `(let ((,ht (make-hash-table)))
         ,@(map (lambda (pair)
                  (if (pair? pair)
                    `(hash-put! ,ht ,(compile-hash-key (car pair))
                                ,(gerbil-compile-expression (cadr pair)))
                    `(hash-put! ,ht ,(compile-hash-key pair) #t)))
                pairs)
         ,ht)))

  ;; --- def with optional/keyword args → case-lambda ---
  (define (compile-def-with-optionals name params body)
    (let ((req (required-params params))
          (opts (optional-params params))
          (rest (rest-param params)))
      ;; Generate case-lambda with clauses for each arity
      ;; Clause for N required args (all optionals use defaults)
      ;; Clause for N+1 (first optional supplied) etc.
      ;; Clause for N+M (all optionals supplied)
      (let ((compiled-body (map gerbil-compile-expression body)))
        (if rest
          ;; Has rest arg — just one clause with let defaults
          `(define (,name ,@req . __rest-args)
             (let* (,@(let lp ((opts opts) (i 0) (bindings '()))
                        (if (null? opts)
                          (reverse bindings)
                          (let ((opt-name (caar opts))
                                (opt-default (cadar opts)))
                            (lp (cdr opts) (+ i 1)
                                (cons `(,opt-name
                                        (if (> (length __rest-args) ,i)
                                          (list-ref __rest-args ,i)
                                          ,(gerbil-compile-expression opt-default)))
                                      bindings))))))
               ,@compiled-body))
          ;; No rest arg — generate case-lambda
          (let ((n-req (length req)))
            `(define ,name
               (case-lambda
                 ,@(let lp ((opts-remaining opts) (clause-idx 0) (clauses '()))
                     (if (null? opts-remaining)
                       ;; Final clause: all optionals supplied
                       (reverse
                         (cons
                           `((,@req ,@(map car opts))
                             ,@compiled-body)
                           clauses))
                       ;; Clause where opts-remaining[0..] use defaults
                       (let* ((supplied-opts (take-n opts clause-idx))
                              (defaulted-opts opts-remaining)
                              (clause-params (append req (map car supplied-opts)))
                              (default-bindings
                                (map (lambda (o)
                                       `(,(car o) ,(gerbil-compile-expression (cadr o))))
                                     defaulted-opts)))
                         (lp (cdr opts-remaining) (+ clause-idx 1)
                             (cons
                               `(,clause-params
                                 (let* ,default-bindings
                                   ,@compiled-body))
                               clauses))))))))))))

  ;; --- include compilation ---
  (define (compile-include form)
    ;; (include "file.ss") → read and compile the file's forms inline
    (let ((path (cadr form)))
      (if (string? path)
        (guard (exn
                 [#t `(begin)]) ;; silently skip if file not found
          (let ((forms (read-all-forms path)))
            `(begin ,@(map gerbil-compile-top forms))))
        `(begin))))

  ;; --- defvalues compilation ---
  (define (compile-defvalues form)
    ;; (defvalues (a b c) expr) → (define-values (a b c) expr)
    (let ((vars (cadr form))
          (expr (caddr form)))
      `(define-values ,vars ,(gerbil-compile-expression expr))))

  ;; --- let-hash compilation ---
  (define (compile-let-hash form)
    ;; (let-hash ht-expr body...)
    ;; Inside body, symbols starting with . are transformed:
    ;;   .x  → (hash-ref ht 'x)     ; strong accessor (error if missing)
    ;;   .?x → (hash-get ht 'x)     ; weak accessor (#f if missing)
    ;;   .$x → (hash-get ht "x")    ; string weak accessor
    ;;   ..x → .x                    ; escape (literal dot symbol)
    (let ((ht-expr (cadr form))
          (body (cddr form))
          (ht-var (gensym "ht")))
      `(let ((,ht-var ,(gerbil-compile-expression ht-expr)))
         ,@(map (lambda (b) (compile-let-hash-expr b ht-var)) body))))

  (define (compile-let-hash-expr expr ht-var)
    ;; Walk expression, replacing .field symbols with hash lookups
    (cond
      ((and (symbol? expr) (let-hash-accessor? expr))
       (compile-let-hash-ref expr ht-var))
      ((not (pair? expr))
       (gerbil-compile-expression expr))
      (else
       ;; Recursively walk the form, but handle special forms properly
       (let ((head (car expr)))
         (cond
           ;; Nested let-hash: don't transform .refs in inner body
           ((eq? head 'let-hash)
            (gerbil-compile-expression expr))
           ;; quote: don't transform
           ((eq? head 'quote) expr)
           ;; lambda: transform body but not params
           ((eq? head 'lambda)
            `(lambda ,(cadr expr)
               ,@(map (lambda (b) (compile-let-hash-expr b ht-var)) (cddr expr))))
           ;; let/let*/letrec: transform init exprs and body
           ((memq head '(let let* letrec letrec*))
            (compile-let-hash-let head expr ht-var))
           ;; General: transform all subforms
           (else
            (map (lambda (e) (compile-let-hash-expr e ht-var)) expr)))))))

  (define (compile-let-hash-let head expr ht-var)
    ;; Handle let forms inside let-hash: transform init exprs and body
    (let ((bindings-or-name (cadr expr)))
      (cond
        ;; named let
        ((symbol? bindings-or-name)
         `(,head ,bindings-or-name
            ,(map (lambda (b)
                    `(,(car b) ,(compile-let-hash-expr (cadr b) ht-var)))
                  (caddr expr))
            ,@(map (lambda (b) (compile-let-hash-expr b ht-var)) (cdddr expr))))
        ;; Gerbil single binding: (let (x expr) body...)
        ((and (pair? bindings-or-name)
              (symbol? (car bindings-or-name))
              (not (pair? (car bindings-or-name))))
         `(,head ((,(car bindings-or-name)
                   ,(compile-let-hash-expr (cadr bindings-or-name) ht-var)))
                 ,@(map (lambda (b) (compile-let-hash-expr b ht-var)) (cddr expr))))
        ;; Standard bindings
        (else
         `(,head ,(map (lambda (b)
                         `(,(car b) ,(compile-let-hash-expr (cadr b) ht-var)))
                       bindings-or-name)
                 ,@(map (lambda (b) (compile-let-hash-expr b ht-var)) (cddr expr)))))))

  (define (let-hash-accessor? sym)
    ;; Check if symbol starts with . (but not ..)
    (let ((s (symbol->string sym)))
      (and (> (string-length s) 1)
           (char=? (string-ref s 0) #\.))))

  (define (compile-let-hash-ref sym ht-var)
    ;; Transform a .field symbol into a hash lookup
    (let ((s (symbol->string sym)))
      (cond
        ;; ..x → escape, reference .x literally
        ((and (> (string-length s) 2)
              (char=? (string-ref s 1) #\.))
         (gerbil-compile-expression
           (string->symbol (substring s 1 (string-length s)))))
        ;; .?x → (hash-get ht 'x) — weak accessor
        ((and (> (string-length s) 2)
              (char=? (string-ref s 1) #\?))
         (let ((field (string->symbol (substring s 2 (string-length s)))))
           `(hash-get ,ht-var ',field)))
        ;; .$x → (hash-get ht "x") — string weak accessor
        ((and (> (string-length s) 2)
              (char=? (string-ref s 1) #\$))
         (let ((field-str (substring s 2 (string-length s))))
           `(hash-get ,ht-var ,field-str)))
        ;; .x → (hash-ref ht 'x) — strong accessor
        (else
         (let ((field (string->symbol (substring s 1 (string-length s)))))
           `(hash-ref ,ht-var ',field))))))

  ;; --- let/cc compilation ---
  (define (compile-let/cc form)
    ;; (let/cc k body...) → (call/cc (lambda (k) body...))
    (let ((var (cadr form))
          (body (cddr form)))
      `(call/cc (lambda (,var) ,@(map gerbil-compile-expression body)))))

  ;; --- awhen compilation ---
  (define (compile-awhen form)
    ;; (awhen (var test) body...) → (let ((var test)) (when var body...))
    (let ((binding (cadr form))
          (body (cddr form)))
      (let ((var (car binding))
            (test (cadr binding)))
        `(let ((,var ,(gerbil-compile-expression test)))
           (when ,var ,@(map gerbil-compile-expression body))))))

  ;; --- and-let* compilation ---
  (define (compile-and-let* form)
    ;; (and-let* ((var expr) ...) body...)
    ;; Short-circuiting let*: if any binding is #f, return #f
    (let ((bindings (cadr form))
          (body (cddr form)))
      (if (null? bindings)
        `(begin ,@(map gerbil-compile-expression body))
        (let lp ((bindings bindings))
          (let ((binding (car bindings))
                (rest (cdr bindings)))
            (cond
              ;; (pred?) — bare test, no binding
              ((and (pair? binding) (null? (cdr binding)))
               (let ((test (gerbil-compile-expression (car binding))))
                 (if (null? rest)
                   `(and ,test (begin ,@(map gerbil-compile-expression body)))
                   `(and ,test ,(lp rest)))))
              ;; (var expr) — binding with test
              ((pair? binding)
               (let ((var (car binding))
                     (init (gerbil-compile-expression (cadr binding))))
                 (if (null? rest)
                   `(let ((,var ,init))
                      (and ,var (begin ,@(map gerbil-compile-expression body))))
                   `(let ((,var ,init))
                      (and ,var ,(lp rest))))))
              ;; bare symbol — just test truthiness
              (else
               (let ((test (gerbil-compile-expression binding)))
                 (if (null? rest)
                   `(and ,test (begin ,@(map gerbil-compile-expression body)))
                   `(and ,test ,(lp rest)))))))))))

  ;; --- if-let compilation ---
  (define (compile-if-let form)
    ;; (if-let (var expr) then else) → (let ((var expr)) (if var then else))
    ;; (if-let (var expr) then) → (let ((var expr)) (if var then (void)))
    (let* ((binding (cadr form))
           (var (car binding))
           (init (gerbil-compile-expression (cadr binding)))
           (then (gerbil-compile-expression (caddr form)))
           (else-expr (if (null? (cdddr form))
                        '(void)
                        (gerbil-compile-expression (cadddr form)))))
      `(let ((,var ,init))
         (if ,var ,then ,else-expr))))

  ;; --- when-let compilation ---
  (define (compile-when-let form)
    ;; (when-let (var expr) body...) → (let ((var expr)) (when var body...))
    (let* ((binding (cadr form))
           (var (car binding))
           (init (gerbil-compile-expression (cadr binding)))
           (body (map gerbil-compile-expression (cddr form))))
      `(let ((,var ,init))
         (when ,var ,@body))))

  ;; --- ignore-errors compilation ---
  (define (compile-ignore-errors form)
    ;; (ignore-errors body...) → (guard (__exn (#t #f)) body...)
    (let ((body (map gerbil-compile-expression (cdr form))))
      `(guard (__exn (#t #f)) ,@body)))

  ;; --- with-destroy compilation ---
  (define (compile-with-destroy form)
    ;; (with-destroy obj body...) → (let (($obj obj)) (dynamic-wind (lambda () #f) (lambda () body...) (lambda () (call-method $obj 'destroy))))
    (let ((obj (gerbil-compile-expression (cadr form)))
          (body (map gerbil-compile-expression (cddr form)))
          (tmp (gensym "$obj")))
      `(let ((,tmp ,obj))
         (dynamic-wind
           (lambda () #f)
           (lambda () ,@body)
           (lambda () (call-method ,tmp 'destroy))))))

  ;; --- do-while compilation ---
  (define (compile-do-while form)
    ;; (do-while (test) body...) → (let loop () body... (when test (loop)))
    (let ((test (gerbil-compile-expression (cadr form)))
          (body (map gerbil-compile-expression (cddr form)))
          (loop (gensym "loop")))
      `(let ,loop ()
         ,@body
         (when ,test (,loop)))))

  ;; --- values-set! compilation ---
  (define (compile-values-set! form)
    ;; (values-set! (var1 var2 ...) expr) → (let-values (((tmp1 tmp2 ...) expr)) (set! var1 tmp1) ...)
    (let* ((vars (cadr form))
           (expr (gerbil-compile-expression (caddr form)))
           (tmps (map (lambda (v) (gensym (symbol->string v))) vars)))
      `(let-values (((,@tmps) ,expr))
         ,@(map (lambda (var tmp) `(set! ,var ,tmp)) vars tmps))))

  ;; --- cond-expand compilation ---
  (define (compile-cond-expand form)
    ;; (cond-expand (feature body...) ... (else body...))
    ;; For Chez/Gherkin, we support: chez-scheme, gherkin, r6rs, else
    ;; Unsupported features (gambit, etc.) are false
    (let lp ((clauses (cdr form)))
      (cond
        ((null? clauses)
         '(void))
        (else
         (let* ((clause (car clauses))
                (feature (car clause))
                (body (cdr clause)))
           (cond
             ((eq? feature 'else)
              `(begin ,@(map gerbil-compile-expression body)))
             ((cond-expand-feature? feature)
              `(begin ,@(map gerbil-compile-expression body)))
             (else
              (lp (cdr clauses)))))))))

  (define (cond-expand-feature? feature)
    (cond
      ((symbol? feature)
       (memq feature '(chez-scheme gherkin r6rs)))
      ((and (pair? feature) (eq? (car feature) 'and))
       (for-all cond-expand-feature? (cdr feature)))
      ((and (pair? feature) (eq? (car feature) 'or))
       (exists cond-expand-feature? (cdr feature)))
      ((and (pair? feature) (eq? (car feature) 'not))
       (not (cond-expand-feature? (cadr feature))))
      (else #f)))

  ;; --- spawn / spawn/name compilation ---
  (define (compile-spawn form)
    ;; (spawn expr) → (thread-start! (make-thread (lambda () expr)))
    ;; (spawn thunk) → (thread-start! (make-thread thunk))
    ;; (spawn proc arg...) → (thread-start! (make-thread (lambda () (proc arg...))))
    (let ((args (cdr form)))
      (if (= (length args) 1)
        ;; Single arg: could be a thunk or expression
        (let ((arg (car args)))
          (if (and (pair? arg) (memq (car arg) '(lambda #%lambda)))
            ;; Already a lambda — use directly
            `(thread-start! (make-thread ,(gerbil-compile-expression arg)))
            ;; Wrap in thunk
            `(thread-start! (make-thread (lambda () ,(gerbil-compile-expression arg))))))
        ;; Multiple args: (spawn proc arg1 arg2...) → apply
        `(thread-start!
           (make-thread
             (lambda ()
               (,(gerbil-compile-expression (car args))
                ,@(map gerbil-compile-expression (cdr args)))))))))

  (define (compile-spawn/name form)
    ;; (spawn/name name expr) → (thread-start! (make-thread (lambda () expr) name))
    ;; (spawn/name name proc arg...) → (thread-start! (make-thread (lambda () (proc arg...)) name))
    (let ((name (gerbil-compile-expression (cadr form)))
          (args (cddr form)))
      (if (= (length args) 1)
        (let ((arg (car args)))
          (if (and (pair? arg) (memq (car arg) '(lambda #%lambda)))
            `(thread-start! (make-thread ,(gerbil-compile-expression arg) ,name))
            `(thread-start! (make-thread (lambda () ,(gerbil-compile-expression arg)) ,name))))
        `(thread-start!
           (make-thread
             (lambda ()
               (,(gerbil-compile-expression (car args))
                ,@(map gerbil-compile-expression (cdr args))))
             ,name)))))

  ;; --- with-lock compilation ---
  (define (compile-with-lock form)
    ;; (with-lock mutex body...) → (dynamic-wind (lambda () (mutex-lock! mutex))
    ;;                                           (lambda () body...)
    ;;                                           (lambda () (mutex-unlock! mutex)))
    ;; Also handles: (with-lock mutex thunk) where thunk is already a lambda
    (let ((mutex-expr (gerbil-compile-expression (cadr form)))
          (rest (cddr form))
          (mtx (gensym "mtx")))
      (if (and (= (length rest) 1)
               (pair? (car rest))
               (memq (caar rest) '(lambda #%lambda)))
        ;; (with-lock mutex (lambda () body...)) — thunk form
        `(let ((,mtx ,mutex-expr))
           (dynamic-wind
             (lambda () (mutex-lock! ,mtx))
             ,(gerbil-compile-expression (car rest))
             (lambda () (mutex-unlock! ,mtx))))
        ;; (with-lock mutex body...) — body form
        `(let ((,mtx ,mutex-expr))
           (dynamic-wind
             (lambda () (mutex-lock! ,mtx))
             (lambda () ,@(map gerbil-compile-expression rest))
             (lambda () (mutex-unlock! ,mtx)))))))

  ;; --- import compilation ---
  (define (compile-import form)
    ;; (import module1 module2 ...)
    ;; Gerbil imports need translation to Chez library imports
    ;; For now, pass through
    form)

  ;; --- lambda compilation (handle => annotation, optional args) ---
  (define (compile-lambda expr)
    ;; (lambda params body...) or (lambda params => type body...)
    (let ((params (cadr expr))
          (rest (cddr expr)))
      ;; Strip => type annotation if present
      (let ((body (if (and (pair? rest) (pair? (cdr rest)) (eq? (car rest) '=>))
                    (cddr rest)  ;; skip => and type
                    rest)))
        (if (and (pair? params) (has-optional-params? params))
          ;; Lambda with optional/keyword args → case-lambda
          (compile-lambda-with-optionals params body)
          `(lambda ,(compile-params params)
             ,@(map gerbil-compile-expression body))))))

  (define (compile-lambda-with-optionals params body)
    (let ((req (required-params params))
          (opts (optional-params params))
          (rest (rest-param params)))
      (let ((compiled-body (map gerbil-compile-expression body)))
        (if rest
          ;; Has rest arg — single clause with let defaults
          `(lambda (,@req . __rest-args)
             (let* (,@(let lp ((opts opts) (i 0) (bindings '()))
                        (if (null? opts)
                          (reverse bindings)
                          (let ((opt-name (caar opts))
                                (opt-default (cadar opts)))
                            (lp (cdr opts) (+ i 1)
                                (cons `(,opt-name
                                        (if (> (length __rest-args) ,i)
                                          (list-ref __rest-args ,i)
                                          ,(gerbil-compile-expression opt-default)))
                                      bindings))))))
               ,@compiled-body))
          ;; No rest arg — case-lambda
          `(case-lambda
             ,@(let lp ((opts-remaining opts) (clause-idx 0) (clauses '()))
                 (if (null? opts-remaining)
                   (reverse
                     (cons
                       `((,@req ,@(map car opts))
                         ,@compiled-body)
                       clauses))
                   (let* ((supplied-opts (take-n opts clause-idx))
                          (defaulted-opts opts-remaining)
                          (clause-params (append req (map car supplied-opts)))
                          (default-bindings
                            (map (lambda (o)
                                   `(,(car o) ,(gerbil-compile-expression (cadr o))))
                                 defaulted-opts)))
                     (lp (cdr opts-remaining) (+ clause-idx 1)
                         (cons
                           `(,clause-params
                             (let* ,default-bindings
                               ,@compiled-body))
                           clauses))))))))))

  ;; --- take-n utility ---
  (define (take-n lst n)
    (if (or (= n 0) (null? lst))
      '()
      (cons (car lst) (take-n (cdr lst) (- n 1)))))

  ;; --- try/catch/finally compilation ---
  (define (compile-try form)
    ;; Handles:
    ;; (try body... (catch (pred var) handler...) ... (finally cleanup...))
    ;; (try body... (catch (var) handler...))
    (let-values (((body-forms catch-clauses finally-clause)
                  (parse-try-clauses (cdr form))))
      (let ((body-expr (if (= (length body-forms) 1)
                         (gerbil-compile-expression (car body-forms))
                         `(begin ,@(map gerbil-compile-expression body-forms)))))
        (let ((guarded
                (if (null? catch-clauses)
                  body-expr
                  (compile-try-catches body-expr catch-clauses))))
          (if finally-clause
            `(dynamic-wind
               (lambda () (void))
               (lambda () ,guarded)
               (lambda () ,@(map gerbil-compile-expression (cdr finally-clause))))
            guarded)))))

  (define (parse-try-clauses forms)
    ;; Returns: (values body-forms catch-clauses finally-clause)
    (let lp ((rest forms) (body '()) (catches '()) (finally #f))
      (cond
        ((null? rest)
         (values (reverse body) (reverse catches) finally))
        ((and (pair? (car rest)) (eq? (caar rest) 'catch))
         (lp (cdr rest) body (cons (car rest) catches) finally))
        ((and (pair? (car rest)) (eq? (caar rest) 'finally))
         (lp (cdr rest) body catches (car rest)))
        (else
         (lp (cdr rest) (cons (car rest) body) catches finally)))))

  (define (compile-try-catches body-expr catch-clauses)
    ;; Generate guard form from catch clauses
    ;; catch forms: (catch (var) handler...) or (catch (pred var) handler...)
    (let ((exn-var (gensym "exn")))
      `(guard (,exn-var
               ,@(map (lambda (clause)
                        (let ((spec (cadr clause))
                              (handler (cddr clause)))
                          (cond
                            ;; (catch (var) handler...) — catch all
                            ((and (pair? spec) (= (length spec) 1))
                             `(#t (let ((,(car spec) ,exn-var))
                                    ,@(map gerbil-compile-expression handler))))
                            ;; (catch (pred var) handler...) — typed catch
                            ((and (pair? spec) (= (length spec) 2))
                             (let ((pred (car spec))
                                   (var (cadr spec)))
                               `((,pred ,exn-var)
                                 (let ((,var ,exn-var))
                                   ,@(map gerbil-compile-expression handler)))))
                            (else
                             `(#t ,@(map gerbil-compile-expression handler))))))
                      catch-clauses))
         ,body-expr)))

  ;; --- chain compilation ---
  (define (compile-chain form)
    ;; (chain val (f1 args...) (f2 args...) ...)
    (let ((init (gerbil-compile-expression (cadr form)))
          (steps (cddr form)))
      (foldl1 (lambda (step acc)
                (if (pair? step)
                  `(,(car step) ,acc ,@(map gerbil-compile-expression (cdr step)))
                  `(,step ,acc)))
              init steps)))

  ;; --- with-unwind-protect compilation ---
  (define (compile-unwind-protect form)
    ;; (with-unwind-protect thunk cleanup)
    (let ((thunk (gerbil-compile-expression (cadr form)))
          (cleanup (gerbil-compile-expression (caddr form))))
      `(dynamic-wind
         (lambda () (void))
         ,thunk
         ,cleanup)))

  ;; --- receive compilation ---
  (define (compile-receive form)
    ;; (receive (var...) producer body...)
    ;; → (call-with-values (lambda () producer) (lambda (var...) body...))
    (let ((formals (cadr form))
          (producer (caddr form))
          (body (cdddr form)))
      `(call-with-values
         (lambda () ,(gerbil-compile-expression producer))
         (lambda ,formals ,@(map gerbil-compile-expression body)))))

  ;; --- Hash table operations ---
  (define (compile-hash-constructor head expr)
    ;; The runtime/hash module already exports these functions.
    ;; Just pass through — they work as-is in the eval environment.
    (map gerbil-compile-expression expr))

  (define (compile-hash-op head expr)
    ;; The runtime/hash module provides full high-level hash API.
    ;; Just compile the arguments and pass through.
    (map gerbil-compile-expression expr))

  ;; --- for iteration compilation ---
  (define (compile-for head expr)
    ;; (for (binding ...) body...)
    ;; (for/collect (binding ...) body...)
    ;; (for/fold ((acc init) ...) (binding ...) body...)
    ;; (for/or (binding ...) body...)
    ;; (for/and (binding ...) body...)
    ;; Binding: (var list-expr) or ((var ...) list-expr)
    (case head
      ((for)
       (compile-for-each-form expr))
      ((for/collect)
       (compile-for-collect expr))
      ((for/fold)
       (compile-for-fold expr))
      ((for/or)
       (compile-for-bool 'or expr))
      ((for/and)
       (compile-for-bool 'and expr))
      (else
       `(begin ,@(map gerbil-compile-expression (cdr expr))))))

  (define (compile-for-each-form expr)
    ;; (for (bindings...) body...) → iterate over sequences
    ;; Forms:
    ;;   (for (var seq-expr) body...)           — single binding
    ;;   (for ([k . v] seq-expr) body...)       — destructuring binding
    ;;   (for ((var1 seq1) (var2 seq2)) body...)  — parallel bindings
    (let ((bindings (cadr expr))
          (body (cddr expr)))
      (cond
        ;; (for (var seq) body...) — single var, single seq
        ((and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
         (compile-for-single-binding (car bindings) (cadr bindings) body))
        ;; (for ([k . v] seq) body...) — destructuring pair binding
        ;; The car of bindings is a dotted pair (not a proper list of bindings)
        ((and (pair? bindings) (= (length bindings) 2)
              (pair? (car bindings)) (not (list? (car bindings))))
         (compile-for-destructure-binding (car bindings) (cadr bindings) body))
        ;; (for ([k v] seq) body...) — destructuring list binding
        ((and (pair? bindings) (= (length bindings) 2)
              (pair? (car bindings)) (list? (car bindings))
              (for-all symbol? (car bindings)))
         (compile-for-destructure-list-binding (car bindings) (cadr bindings) body))
        ;; (for ((var1 seq1) ...) body...) — list of bindings
        ((and (pair? bindings) (pair? (car bindings)))
         (compile-for-parallel-bindings bindings body))
        ;; Fallback
        (else
         `(begin ,@(map gerbil-compile-expression body))))))

  (define (compile-for-single-binding var seq body)
    ;; (for (var seq) body) → (for-each (lambda (var) body) seq)
    (let ((compiled-seq (compile-for-sequence seq)))
      `(for-each (lambda (,var) ,@(map gerbil-compile-expression body))
                 ,compiled-seq)))

  (define (compile-for-destructure-binding pattern seq body)
    ;; Handle dotted pair patterns in for-loops
    ;; Reader produces (@list k . v) for [k . v]
    ;; Or plain (k . v) for other cases
    (let ((compiled-seq (compile-for-sequence seq))
          (tmp (gensym "pair")))
      (let-values (((key-var val-var)
                    (if (and (pair? pattern) (eq? (car pattern) '@list))
                      ;; (@list k . v) → k is cadr, v is cddr
                      (values (cadr pattern) (cddr pattern))
                      ;; (k . v)
                      (values (car pattern) (cdr pattern)))))
        `(for-each (lambda (,tmp)
                     (let ((,key-var (car ,tmp))
                           (,val-var (cdr ,tmp)))
                       ,@(map gerbil-compile-expression body)))
                   ,compiled-seq))))

  (define (compile-for-destructure-list-binding pattern seq body)
    ;; (for ([a b] seq) body) → (for-each (lambda (tmp) (let ((a (car tmp)) (b (cadr tmp))) body)) seq)
    (let ((compiled-seq (compile-for-sequence seq))
          (tmp (gensym "elem")))
      (let ((binds (let lp ((vars pattern) (idx 0) (acc '()))
                     (if (null? vars)
                       (reverse acc)
                       (lp (cdr vars) (+ idx 1)
                           (cons `(,(car vars) (list-ref ,tmp ,idx)) acc))))))
        `(for-each (lambda (,tmp) (let ,binds ,@(map gerbil-compile-expression body)))
                   ,compiled-seq))))

  (define (compile-for-parallel-bindings bindings body)
    ;; Each binding is (var seq-expr)
    ;; Simple case: iterate in parallel using for-each
    (if (and (pair? bindings) (pair? (car bindings)))
      (let ((vars (map car bindings))
            (seqs (map (lambda (b) (compile-for-sequence (cadr b))) bindings)))
        `(for-each (lambda ,vars ,@(map gerbil-compile-expression body))
                   ,@seqs))
      ;; Fallback
      `(begin ,@(map gerbil-compile-expression body))))

  (define (compile-for-collect expr)
    ;; (for/collect (bindings...) body) → (map (lambda (vars) body) seqs)
    (let ((bindings (cadr expr))
          (body (cddr expr)))
      (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
        ;; Single binding
        (let ((var (car bindings))
              (seq (compile-for-sequence (cadr bindings))))
          `(map (lambda (,var) ,@(map gerbil-compile-expression body)) ,seq))
        ;; Multiple bindings
        (let ((vars (map car bindings))
              (seqs (map (lambda (b) (compile-for-sequence (cadr b))) bindings)))
          `(map (lambda ,vars ,@(map gerbil-compile-expression body)) ,@seqs)))))

  (define (compile-for-fold expr)
    ;; (for/fold ((acc init) ...) ((var seq) ...) body...)
    (let ((accumulators (cadr expr))
          (bindings (caddr expr))
          (body (cdddr expr)))
      (if (= (length accumulators) 1)
        ;; Single accumulator
        (let ((acc-name (caar accumulators))
              (acc-init (gerbil-compile-expression (cadar accumulators))))
          (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
            ;; Single binding: (for/fold ((acc init)) (var seq) body)
            (let ((var (car bindings))
                  (seq (compile-for-sequence (cadr bindings))))
              `(fold-left (lambda (,acc-name ,var) ,@(map gerbil-compile-expression body))
                          ,acc-init ,seq))
            ;; List of bindings
            (let ((var (caar bindings))
                  (seq (compile-for-sequence (cadar bindings))))
              `(fold-left (lambda (,acc-name ,var) ,@(map gerbil-compile-expression body))
                          ,acc-init ,seq))))
        ;; Multiple accumulators — use let loop
        (let ((loop (gensym "loop"))
              (var (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
                     (car bindings)
                     (caar bindings)))
              (seq (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
                     (compile-for-sequence (cadr bindings))
                     (compile-for-sequence (cadar bindings))))
              (rest-sym (gensym "rest")))
          `(let ,loop ((,rest-sym ,seq)
                       ,@(map (lambda (a) `(,(car a) ,(gerbil-compile-expression (cadr a))))
                              accumulators))
             (if (null? ,rest-sym)
               (values ,@(map car accumulators))
               (let ((,var (car ,rest-sym)))
                 (let-values (((,@(map car accumulators))
                               (let () ,@(map gerbil-compile-expression body))))
                   (,loop (cdr ,rest-sym) ,@(map car accumulators))))))))))

  (define (compile-for-bool op expr)
    ;; (for/or (var seq) body) or (for/and (var seq) body)
    (let ((bindings (cadr expr))
          (body (cddr expr)))
      (let ((var (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
                   (car bindings) (caar bindings)))
            (seq (if (and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
                   (compile-for-sequence (cadr bindings))
                   (compile-for-sequence (cadar bindings))))
            (loop (gensym "loop"))
            (rest-sym (gensym "rest")))
        (case op
          ((or)
           `(let ,loop ((,rest-sym ,seq))
              (if (null? ,rest-sym)
                #f
                (let ((,var (car ,rest-sym)))
                  (or (begin ,@(map gerbil-compile-expression body))
                      (,loop (cdr ,rest-sym)))))))
          ((and)
           `(let ,loop ((,rest-sym ,seq))
              (if (null? ,rest-sym)
                #t
                (let ((,var (car ,rest-sym)))
                  (and (begin ,@(map gerbil-compile-expression body))
                       (,loop (cdr ,rest-sym)))))))))))

  (define (compile-for-sequence seq-expr)
    ;; Convert Gerbil sequence expressions to Chez lists
    (cond
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-range))
       ;; (in-range n) or (in-range start end) or (in-range start end step)
       (let ((args (cdr seq-expr)))
         (cond
           ((= (length args) 1)
            `(iota ,(gerbil-compile-expression (car args))))
           ((= (length args) 2)
            (let ((start (gerbil-compile-expression (car args)))
                  (end (gerbil-compile-expression (cadr args))))
              `(let range-lp ((i ,start) (acc '()))
                 (if (>= i ,end) (reverse acc)
                   (range-lp (+ i 1) (cons i acc))))))
           ((= (length args) 3)
            (let ((start (gerbil-compile-expression (car args)))
                  (end (gerbil-compile-expression (cadr args)))
                  (step (gerbil-compile-expression (caddr args))))
              `(let range-lp ((i ,start) (acc '()))
                 (if (>= i ,end) (reverse acc)
                   (range-lp (+ i ,step) (cons i acc))))))
           (else (gerbil-compile-expression seq-expr)))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-naturals))
       ;; Can't produce infinite list; error
       `(error 'for "in-naturals requires bounded usage"))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-iota))
       ;; (in-iota count) or (in-iota count start step)
       (let ((args (cdr seq-expr)))
         (cond
           ((= (length args) 1)
            `(iota ,(gerbil-compile-expression (car args))))
           ((= (length args) 2)
            `(iota ,(gerbil-compile-expression (car args))
                   ,(gerbil-compile-expression (cadr args))))
           ((= (length args) 3)
            `(iota ,(gerbil-compile-expression (car args))
                   ,(gerbil-compile-expression (cadr args))
                   ,(gerbil-compile-expression (caddr args))))
           (else (gerbil-compile-expression seq-expr)))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-hash-keys))
       ;; (in-hash-keys ht) → (hash-keys ht)
       `(hash-keys ,(gerbil-compile-expression (cadr seq-expr))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-hash-values))
       ;; (in-hash-values ht) → (hash-values ht)
       `(hash-values ,(gerbil-compile-expression (cadr seq-expr))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-hash))
       ;; (in-hash ht) → (hash->list ht)
       `(hash->list ,(gerbil-compile-expression (cadr seq-expr))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-string))
       `(string->list ,(gerbil-compile-expression (cadr seq-expr))))
      ((and (pair? seq-expr) (eq? (car seq-expr) 'in-vector))
       `(vector->list ,(gerbil-compile-expression (cadr seq-expr))))
      (else
       (gerbil-compile-expression seq-expr))))

  ;; --- while / until compilation ---
  (define (compile-while form)
    ;; (while test body...) → (let loop () (when test body... (loop)))
    (let ((test (gerbil-compile-expression (cadr form)))
          (body (map gerbil-compile-expression (cddr form)))
          (loop (gensym "while-loop")))
      `(let ,loop ()
         (when ,test ,@body (,loop)))))

  (define (compile-until form)
    ;; (until test body...) → (let loop () (unless test body... (loop)))
    (let ((test (gerbil-compile-expression (cadr form)))
          (body (map gerbil-compile-expression (cddr form)))
          (loop (gensym "until-loop")))
      `(let ,loop ()
         (unless ,test ,@body (,loop)))))

  ;; --- using compilation ---
  (define (compile-using form)
    ;; (using (var :- Type) body...) → (let ((var var)) body...)
    ;; (using (var :- Type expr) body...) → (let ((var expr)) body...)
    ;; For now, strip the type annotation and compile as let binding
    (let ((binding (cadr form))
          (body (cddr form)))
      (if (and (pair? binding) (>= (length binding) 3))
        (let* ((var (car binding))
               ;; Skip :- and Type, get optional expr
               (expr (if (>= (length binding) 4)
                       (gerbil-compile-expression (cadddr binding))
                       var)))
          `(let ((,var ,expr))
             ,@(map gerbil-compile-expression body)))
        ;; Fallback: just compile body
        `(begin ,@(map gerbil-compile-expression body)))))

  ;; --- @method compilation ---
  (define (compile-at-method form)
    ;; (@method method-name obj args...) — from {method obj args}
    ;; → (method-ref obj 'method-name) call
    (let ((method-name (cadr form))
          (obj (caddr form))
          (args (cdddr form)))
      (if (null? args)
        ;; Field access: {field obj} → (slot-ref obj 'field)
        `(slot-ref ,(gerbil-compile-expression obj) ',method-name)
        ;; Method call: {method obj args} → (call-method obj 'method args)
        `(call-method ,(gerbil-compile-expression obj) ',method-name
                      ,@(map gerbil-compile-expression args)))))

  ;; --- displayln compilation ---
  (define (compile-displayln form)
    ;; (displayln arg...) → (begin (display arg)... (newline))
    (let ((args (cdr form)))
      (if (null? args)
        '(newline)
        `(begin
           ,@(map (lambda (a) `(display ,(gerbil-compile-expression a))) args)
           (newline)))))

  ;; --- stdlib higher-order functions ---
  (define (compile-stdlib-hof head expr)
    (let ((args (map gerbil-compile-expression (cdr expr))))
      (case head
        ((foldl)
         ;; Gerbil foldl: (foldl proc init lst) where proc is (elem acc) → acc
         ;; Chez fold-left: (fold-left proc init lst) where proc is (acc elem) → acc
         ;; Need to swap argument order
         (let ((f (gensym "f"))
               (a (gensym "a"))
               (e (gensym "e")))
           `(let ((,f ,(car args)))
              (fold-left (lambda (,a ,e) (,f ,e ,a))
                         ,(cadr args) ,(caddr args)))))
        ((foldr)
         ;; Gerbil foldr: (foldr proc init lst) where proc is (elem acc) → acc
         ;; Chez fold-right: (fold-right proc init lst) where proc is (elem acc) → acc
         ;; Same argument order!
         `(fold-right ,@args))
        ((filter)
         `(filter ,@args))
        (else
         `(,head ,@args)))))

  ;; --- string operations ---
  (define (compile-string-op head expr)
    (let ((args (map gerbil-compile-expression (cdr expr))))
      (case head
        ((string-join)
         ;; (string-join lst sep) → fold with string-append
         (if (= (length args) 1)
           ;; (string-join lst) → join with ""
           (let ((strs (gensym "strs")))
             `(let ((,strs ,(car args)))
                (apply string-append ,strs)))
           ;; (string-join lst sep)
           (let ((strs (gensym "strs"))
                 (sep (gensym "sep"))
                 (result (gensym "result"))
                 (first (gensym "first")))
             `(let ((,strs ,(car args))
                    (,sep ,(cadr args)))
                (if (null? ,strs) ""
                  (let lp ((,result (car ,strs)) (rest (cdr ,strs)))
                    (if (null? rest) ,result
                      (lp (string-append ,result ,sep (car rest))
                          (cdr rest)))))))))
        ((string-split)
         ;; (string-split str sep) — basic split on single char or string
         ;; Implement as a simple split
         (let ((str (gensym "str"))
               (sep (gensym "sep")))
           `(let ((,str ,(car args))
                  (,sep (if (char? ,(cadr args)) ,(cadr args)
                          (string-ref ,(cadr args) 0))))
              (let split-lp ((i 0) (start 0) (acc '()))
                (cond
                  ((= i (string-length ,str))
                   (reverse (cons (substring ,str start i) acc)))
                  ((char=? (string-ref ,str i) ,sep)
                   (split-lp (+ i 1) (+ i 1)
                             (cons (substring ,str start i) acc)))
                  (else (split-lp (+ i 1) start acc)))))))
        (else `(,head ,@args)))))

  ;; --- string-contains compilation ---
  (define (compile-string-contains expr)
    ;; (string-contains haystack needle) → index or #f
    (let ((args (map gerbil-compile-expression (cdr expr))))
      (let ((hay (gensym "hay"))
            (ndl (gensym "ndl")))
        `(let ((,hay ,(car args))
               (,ndl ,(cadr args)))
           (let ((hlen (string-length ,hay))
                 (nlen (string-length ,ndl)))
             (let lp ((i 0))
               (cond
                 ((> (+ i nlen) hlen) #f)
                 ((string=? (substring ,hay i (+ i nlen)) ,ndl) i)
                 (else (lp (+ i 1))))))))))

  ;; --- string-prefix? compilation ---
  (define (compile-string-prefix? expr)
    (let ((args (map gerbil-compile-expression (cdr expr))))
      (let ((pfx (gensym "pfx"))
            (str (gensym "str")))
        `(let ((,pfx ,(car args))
               (,str ,(cadr args)))
           (let ((plen (string-length ,pfx)))
             (and (<= plen (string-length ,str))
                  (string=? ,pfx (substring ,str 0 plen))))))))

  ;; --- string-suffix? compilation ---
  (define (compile-string-suffix? expr)
    (let ((args (map gerbil-compile-expression (cdr expr))))
      (let ((sfx (gensym "sfx"))
            (str (gensym "str")))
        `(let ((,sfx ,(car args))
               (,str ,(cadr args)))
           (let ((slen (string-length ,sfx))
                 (len (string-length ,str)))
             (and (<= slen len)
                  (string=? ,sfx (substring ,str (- len slen) len))))))))

  ;; --- make-will compilation ---
  (define (compile-make-will expr)
    ;; (make-will obj action) → Chez guardian
    ;; Gambit will testators: action is called with obj when obj is GC'd
    ;; Chez guardians: (guardian obj) registers, (guardian) retrieves
    ;; We approximate with a guardian
    (let ((args (map gerbil-compile-expression (cdr expr))))
      `(let ((g (make-guardian)))
         (g ,(car args))
         g)))

  ;; --- subvector compilation ---
  (define (compile-subvector expr)
    ;; Gambit (subvector vec start end) → Chez doesn't have direct equivalent
    ;; Need to build: (let ((v vec)) (vector-copy v start end))
    ;; But Chez vector-copy is (vector-copy vec) for full copy
    ;; Use our own implementation
    (let ((args (map gerbil-compile-expression (cdr expr)))
          (v (gensym "v")))
      (case (length args)
        ((2) `(let ((,v ,(car args)))
                (let* ((start ,(cadr args))
                       (end (vector-length ,v))
                       (len (- end start))
                       (result (make-vector len)))
                  (do ((i 0 (+ i 1)))
                      ((= i len) result)
                    (vector-set! result i (vector-ref ,v (+ start i)))))))
        ((3) `(let ((,v ,(car args)))
                (let* ((start ,(cadr args))
                       (end ,(caddr args))
                       (len (- end start))
                       (result (make-vector len)))
                  (do ((i 0 (+ i 1)))
                      ((= i len) result)
                    (vector-set! result i (vector-ref ,v (+ start i)))))))
        (else `(error 'subvector "wrong number of arguments")))))

  ;; --- object->u8vector compilation ---
  (define (compile-object->u8vector expr)
    ;; Use Chez fasl-write for serialization
    (let ((obj (gerbil-compile-expression (cadr expr))))
      `(let ((port (open-output-bytevector)))
         (fasl-write ',obj port)
         (get-output-bytevector port))))

  ;; --- u8vector->object compilation ---
  (define (compile-u8vector->object expr)
    ;; Use Chez fasl-read for deserialization
    (let ((bv (gerbil-compile-expression (cadr expr))))
      `(let ((port (open-input-bytevector ,bv)))
         (fasl-read port))))

  ;; --- Helper: extract property from property list ---
  (define (extract-prop key props default)
    (cond
      ((null? props) default)
      ((and (pair? (car props)) (eq? (caar props) key))
       (cdar props))
      ((and (pair? props) (eq? (car props) key) (pair? (cdr props)))
       (cadr props))
      ((pair? props) (extract-prop key (cdr props) default))
      (else default)))

  ;; --- Helper: check if value is a keyword (symbol ending with : or Gerbil keyword object) ---
  (define (keyword-symbol? sym)
    (or (|##keyword?| sym)
        (and (symbol? sym)
             (let ((s (symbol->string sym)))
               (and (fx> (string-length s) 1)
                    (char=? (string-ref s (fx- (string-length s) 1)) #\:))))))

  ;; Extract the keyword name string from a keyword symbol or keyword object
  (define (keyword-name kw)
    (if (|##keyword?| kw)
      (|##keyword->string| kw)
      (let ((s (symbol->string kw)))
        (substring s 0 (fx- (string-length s) 1)))))

  ;; --- File compilation ---
  (define (gerbil-compile-file input-path)
    ;; Read and compile a Gerbil source file
    (let ((forms (read-all-forms input-path)))
      (map gerbil-compile-top forms)))

  (define (read-all-forms path)
    ;; Use the Gerbil reader to handle ## symbols, [] brackets, {} braces, etc.
    ;; Then strip source annotations to get plain s-expressions.
    (map strip-annotations (gerbil-read-file path)))

  ;; Strip annotated-datum wrappers from reader output, recursively
  (define (strip-annotations datum)
    (cond
      ((annotated-datum? datum)
       (strip-annotations (annotated-datum-value datum)))
      ((pair? datum)
       (cons (strip-annotations (car datum))
             (strip-annotations (cdr datum))))
      ((vector? datum)
       (vector-map strip-annotations datum))
      (else datum)))

  ;; --- Library compilation ---
  ;; import-map: optional alist mapping Gerbil module paths to Chez library names
  ;; e.g. ((:std/sugar . (compat sugar)) (:std/iter . #f) ...)
  ;; #f means strip (don't import)
  ;; base-imports: optional list of Chez import specs to include by default
  (define (gerbil-compile-to-library input-path lib-name . rest)
    (let ((import-map (if (pair? rest) (car rest) '()))
          (base-imports (if (and (pair? rest) (pair? (cdr rest)))
                         (cadr rest)
                         '((chezscheme))))
          ;; Extract source directory from input-path for relative import resolution
          (source-dir (let ((s (if (string? input-path) input-path "")))
                        (let lp ((i (- (string-length s) 1)))
                          (cond
                            ((< i 0) "")
                            ((char=? (string-ref s i) #\/)
                             (substring s 0 i))
                            (else (lp (- i 1))))))))
      ;; Compile a Gerbil file to a Chez library
      (let ((forms (read-all-forms input-path))
            (imports '())
            (for-syntax-imports '())
            (exports '())
            (body '()))
        ;; Separate imports, exports, and body
        (for-each
          (lambda (form)
            (cond
              ((and (pair? form) (eq? (car form) 'import))
               ;; Expand group-in, then scan for (for-syntax ...) wrappers
               (for-each
                 (lambda (spec)
                   (if (and (pair? spec) (eq? (car spec) 'for-syntax))
                     ;; (for-syntax :std/stxutil) → collect the inner module specs
                     (set! for-syntax-imports
                       (append for-syntax-imports
                               (expand-group-in (cdr spec))))
                     (set! imports (append imports (list spec)))))
                 (expand-group-in (cdr form))))
              ((and (pair? form) (eq? (car form) 'export))
               (set! exports (append exports (cdr form))))
              ((and (pair? form) (memq (car form) '(prelude: package: namespace:)))
               #f)  ;; skip Gerbil headers
              (else
               (set! body (cons form body)))))
          forms)
        ;; Compile the body
        (let* ((compiled-body (map gerbil-compile-top (reverse body)))
               ;; R6RS requires definitions before expressions in library bodies.
               ;; Reorder: all define/define-syntax/begin-with-defines first,
               ;; then all expressions (method-set!, etc.)
               (compiled-body (reorder-library-body compiled-body))
               ;; Check if any defsyntax forms are present in the original body
               (has-defsyntax?
                 (exists (lambda (form)
                           (and (pair? form) (eq? (car form) 'defsyntax)))
                         (reverse body)))
               ;; Resolve for-syntax imports to R6RS (for lib expand)
               (effective-map (append import-map *default-import-map*))
               (phase1-imports
                 (let lp ((specs for-syntax-imports) (result '()))
                   (if (null? specs)
                     (reverse result)
                     (let ((resolved (resolve-import (car specs) effective-map source-dir)))
                       (if resolved
                         (lp (cdr specs) (cons `(for ,resolved expand) result))
                         (lp (cdr specs) result))))))
               ;; Auto-inject (for (runtime syntax) expand) when defsyntax is present
               (phase1-imports
                 (if (and has-defsyntax?
                          (not (exists (lambda (imp)
                                         (and (pair? imp)
                                              (equal? (cadr imp) '(runtime syntax))))
                                       phase1-imports)))
                   (cons '(for (runtime syntax) expand) phase1-imports)
                   phase1-imports)))
          ;; Generate library
          `(library ,lib-name
             (export ,@(compile-exports exports compiled-body))
             (import ,@base-imports
                     ,@(compile-library-imports imports import-map base-imports
                                                source-dir)
                     ,@phase1-imports)
             ,@compiled-body)))))

  ;; --- Program compilation ---
  ;; Compile a Gerbil source file to a Chez Scheme program (not a library).
  ;; Returns a list of forms: ((import ...) body-form1 body-form2 ...)
  ;; import-map: optional alist mapping Gerbil module paths to Chez library names
  ;; base-imports: Chez imports always included (runtime, gambit-compat, etc.)

  ;; Compat libraries that shadow names from (chezscheme).
  ;; When a compat lib is imported into a program, these names must be
  ;; excluded from (chezscheme) to avoid "multiple definitions" errors.
  (define *compat-chez-exclusions*
    '(((compat misc)          . (filter iota remove partition fold-right
                                  last-pair path-extension))
      ((compat std-getopt)    . (filter find))
      ((compat std-logger)    . (errorf))
      ((compat std-os-path)   . (path-extension))
      ((compat std-srfi-13)   . ())
      ((compat signal-handler) . (filter))
      ((compat std-misc-alist) . (filter))
      ((compat gambit-compat) . (void box box? unbox set-box!))))

  ;; Always excluded from (chezscheme) — these are redefined by our runtime
  (define *always-excluded-from-chez*
    '(void box box? unbox set-box!
      andmap ormap iota last-pair find
      1+ 1- fx/ fx1+ fx1-
      error error? raise with-exception-handler identifier?
      hash-table? make-hash-table))

  (define (gerbil-compile-to-program input-path . rest)
    (let ((import-map (if (pair? rest) (car rest) '()))
          (base-imports-override
            (and (pair? rest) (pair? (cdr rest)) (cadr rest)))
          (source-dir (let ((s (if (string? input-path) input-path "")))
                        (let lp ((i (- (string-length s) 1)))
                          (cond
                            ((< i 0) "")
                            ((char=? (string-ref s i) #\/)
                             (substring s 0 i))
                            (else (lp (- i 1))))))))
      (let ((forms (read-all-forms input-path))
            (imports '())
            (body '()))
        ;; Separate imports and body; strip exports
        (for-each
          (lambda (form)
            (cond
              ((and (pair? form) (eq? (car form) 'import))
               (set! imports
                 (append imports (expand-group-in (cdr form)))))
              ((and (pair? form) (eq? (car form) 'export))
               #f)  ;; strip exports for programs
              ((and (pair? form) (memq (car form) '(prelude: package: namespace:)))
               #f)  ;; skip Gerbil headers
              (else
               (set! body (cons form body)))))
          forms)
        ;; Compile the body
        (let* ((compiled-body (map gerbil-compile-top (reverse body)))
               ;; Resolve Gerbil imports to Chez library specs
               (resolved-imports
                 (compile-library-imports imports import-map '() source-dir))
               ;; Compute Chez exclusions based on which compat libs are imported
               (extra-exclusions
                 (let lp ((libs resolved-imports) (excl '()))
                   (if (null? libs)
                     excl
                     (let ((entry (assoc (car libs) *compat-chez-exclusions*)))
                       (lp (cdr libs)
                           (if entry
                             (append (cdr entry) excl)
                             excl))))))
               (all-exclusions
                 (let lp ((syms (append *always-excluded-from-chez*
                                        extra-exclusions))
                          (seen '()) (result '()))
                   (cond
                     ((null? syms) (reverse result))
                     ((memq (car syms) seen) (lp (cdr syms) seen result))
                     (else (lp (cdr syms)
                               (cons (car syms) seen)
                               (cons (car syms) result))))))
               (chez-import
                 (if (null? all-exclusions)
                   '(chezscheme)
                   `(except (chezscheme) ,@all-exclusions)))
               (base-imports
                 (or base-imports-override
                     `(,chez-import (compat gambit-compat)))))
          ;; Generate program
          (cons `(import ,@base-imports ,@resolved-imports)
                compiled-body)))))

  ;; --- R6RS body reordering ---
  ;; Partition body into definitions and expressions, with definitions first.
  (define (reorder-library-body forms)
    (let lp ((forms forms) (defs '()) (exprs '()))
      (if (null? forms)
        (append (reverse defs) (reverse exprs))
        (let ((form (car forms)))
          (if (definition-form? form)
            (lp (cdr forms) (cons form defs) exprs)
            (lp (cdr forms) defs (cons form exprs)))))))

  (define (definition-form? form)
    (and (pair? form)
         (or (eq? (car form) 'define)
             (eq? (car form) 'define-syntax)
             (eq? (car form) 'define-record-type)
             ;; (begin ...) containing only definitions
             (and (eq? (car form) 'begin)
                  (not (null? (cdr form)))
                  (for-all definition-form? (cdr form))))))

  ;; --- (export #t) resolution ---
  ;; When exports contain #t, collect all defined names from the compiled body
  (define (compile-exports exports compiled-body)
    (cond
      ((null? exports) '())
      ((memq #t exports)
       ;; (export #t) - export all defined names
       (collect-defined-names compiled-body))
      (else
       ;; Filter and expand exports:
       ;; - (struct-out name) → expand to all struct-generated names from body
       ;; - regular symbols pass through
       (let ((all-names (collect-defined-names compiled-body)))
         (let lp ((exps exports) (result '()))
           (cond
             ((null? exps) (reverse result))
             ((and (pair? (car exps)) (eq? (caar exps) 'struct-out))
              ;; (struct-out name) → find all generated names for that struct
              (let* ((struct-name (cadar exps))
                     (prefix (symbol->string struct-name))
                     (struct-names
                       (filter (lambda (n)
                                 (let ((s (symbol->string n)))
                                   (or (string=? s (string-append "make-" prefix))
                                       (string=? s (string-append prefix "?"))
                                       (string-prefix? (string-append prefix "-") s)
                                       (string=? s (string-append prefix "::t")))))
                               all-names)))
                (lp (cdr exps) (append (reverse struct-names) result))))
             ((and (pair? (car exps)) (eq? (caar exps) 'interface-out))
              ;; (interface-out Name) → expand to all interface-generated names
              (let* ((iface-name (cadar exps))
                     (prefix (symbol->string iface-name))
                     (iface-names
                       (filter (lambda (n)
                                 (let ((s (symbol->string n)))
                                   (or (string=? s (string-append "make-" prefix))
                                       (string=? s (string-append "try-" prefix))
                                       (string=? s (string-append prefix "?"))
                                       (string=? s (string-append "is-" prefix "?"))
                                       (string-prefix? (string-append prefix "-") s))))
                               all-names)))
                (lp (cdr exps) (append (reverse iface-names) result))))
             ;; (rename-out (old new) ...) → (rename (old new) ...)
             ((and (pair? (car exps)) (eq? (caar exps) 'rename-out))
              (lp (cdr exps)
                  (cons `(rename ,@(cdar exps)) result)))
             ;; (prefix-out pfx sym ...) → export prefixed symbols
             ((and (pair? (car exps)) (eq? (caar exps) 'prefix-out))
              (let ((pfx (symbol->string (cadar exps)))
                    (syms (cddar exps)))
                (lp (cdr exps)
                    (append (reverse
                              (map (lambda (s)
                                     (string->symbol
                                       (string-append pfx (symbol->string s))))
                                   syms))
                            result))))
             ;; (except-out sym ...) → export all except listed
             ((and (pair? (car exps)) (eq? (caar exps) 'except-out))
              (let ((excluded (cdar exps)))
                (lp (cdr exps)
                    (append (reverse
                              (filter (lambda (n) (not (memq n excluded)))
                                      all-names))
                            result))))
             ((symbol? (car exps))
              (lp (cdr exps) (cons (car exps) result)))
             (else
              ;; Skip unrecognized export forms
              (lp (cdr exps) result))))))))

  (define (string-prefix? prefix str)
    (let ((plen (string-length prefix)))
      (and (<= plen (string-length str))
           (string=? prefix (substring str 0 plen)))))

  ;; Collect all top-level defined names from compiled body forms
  (define (collect-defined-names forms)
    (let lp ((forms forms) (names '()))
      (if (null? forms)
        (reverse names)
        (let ((form (car forms)))
          (lp (cdr forms)
              (append (extract-names-from-form form) names))))))

  (define (extract-names-from-form form)
    (cond
      ((not (pair? form)) '())
      ((eq? (car form) 'define)
       (let ((sig (cadr form)))
         (list (if (pair? sig) (car sig) sig))))
      ((eq? (car form) 'define-syntax)
       (let ((name-or-sig (cadr form)))
         (list (if (pair? name-or-sig) (car name-or-sig) name-or-sig))))
      ((eq? (car form) 'begin)
       ;; Recurse into begin blocks (defstruct/defclass expand to begin)
       (let lp ((rest (cdr form)) (names '()))
         (if (null? rest) names
           (lp (cdr rest) (append (extract-names-from-form (car rest)) names)))))
      (else '())))

  ;; --- Import path mapping ---
  ;; Default import map for gerbil-shell modules
  (define *default-import-map*
    '((:std/sugar       . #f)  ;; stripped — compiler handles sugar forms natively
      (:std/format      . (compat format))
      (:std/sort        . (compat sort))
      (:std/pregexp     . (compat pregexp))
      (:std/misc/string . (compat misc))
      (:std/misc/list   . (compat misc))
      (:std/misc/path   . (compat misc))
      (:std/misc/hash   . (compat misc))
      (:std/misc/ports  . (compat std-misc-ports))
      (:std/test        . (compat std-test))
      (:std/text/json   . (compat json))
      (:std/text/base64 . (compat std-text-base64))
      (:std/text/hex    . (compat std-text-hex))
      (:std/sync/completion . (compat std-sync-completion))
      (:std/misc/completion . (compat std-sync-completion))
      (:std/sync/channel . (compat std-sync-channel))
      (:std/misc/channel . (compat std-sync-channel))
      (:std/xml         . (compat std-xml))
      (:std/markup/xml  . (compat std-xml))
      (:std/net/request . (compat std-net-request))
      (:std/crypto/digest . (compat std-crypto-digest))
      (:std/net/httpd    . (compat std-net-httpd))
      (:std/db/dbi       . (compat std-db-dbi))
      (:std/stxutil      . (compat std-stxutil))
      (:std/disasm       . (compat std-disasm))
      (:std/iter        . #f)  ;; stripped — Gherkin compiles for-loops natively
      (:std/error       . (runtime error))
      (:std/os/signal   . (compat signal))
      (:std/os/signal-handler . (compat signal-handler))
      (:std/os/fdio     . (compat fdio))
      (:std/srfi/1      . (compat misc))
      (:std/getopt      . (compat std-getopt))
      (:std/cli/getopt  . (compat std-getopt))
      (:std/logger      . (compat std-logger))
      (:std/os/path     . (compat std-os-path))
      (:std/os/env      . (compat std-os-env))
      (:std/os/temporaries . (compat std-os-env))
      (:std/srfi/13     . (compat std-srfi-13))
      (:std/srfi/19     . (compat std-srfi-19))
      (:std/misc/repr   . (compat std-misc-repr))
      (:std/misc/bytes  . (compat std-misc-bytes))
      (:std/text/csv    . (compat std-text-csv))
      (:std/text/utf8   . (compat std-text-utf8))
      (:std/misc/process . (compat std-misc-process))
      (:std/misc/alist  . (compat std-misc-alist))
      (:std/misc/uuid   . (compat std-misc-uuid))
      (:std/misc/queue  . (compat std-misc-queue))
      (:std/os/temporaries . (compat std-os-temporaries))
      (:std/misc/number . #f)  ;; stripped — use Chez native number ops
      (:std/misc/list-builder . #f)  ;; stripped
      (:std/generic     . #f)  ;; stripped
      (:std/foreign     . #f)  ;; stripped
      (:gerbil/runtime  . #f)  ;; stripped
      ))

  ;; Extract the bare library name from an import spec, stripping
  ;; except/only/rename wrappers. E.g.:
  ;;   (except (runtime error) with-catch) → (runtime error)
  ;;   (only (compat gambit) foo) → (compat gambit)
  ;;   (runtime mop) → (runtime mop)
  (define (import-spec-library-name spec)
    (cond
      ((and (pair? spec)
            (memq (car spec) '(except only rename prefix)))
       (import-spec-library-name (cadr spec)))
      (else spec)))

  (define (compile-library-imports imports import-map . rest)
    ;; Convert Gerbil import specs to Chez library imports
    ;; Uses import-map (merged with defaults) to resolve paths
    ;; Optional rest args: base-imports to deduplicate against, source-dir for relative imports
    (let* ((base-imports (if (pair? rest) (car rest) '()))
           (source-dir (if (and (pair? rest) (pair? (cdr rest)))
                         (cadr rest)
                         ""))
           (effective-map (append import-map *default-import-map*))
           ;; Extract library names already covered by base imports
           (base-libs (map import-spec-library-name base-imports)))
      (let lp ((imports (expand-group-in imports)) (result '()) (seen '()))
        (if (null? imports)
          (reverse result)
          (let ((resolved (resolve-import (car imports) effective-map source-dir)))
            (if (or (not resolved)
                    (member resolved seen)
                    ;; Skip if this library is already in base imports
                    (member resolved base-libs))
              (lp (cdr imports) result seen)
              (lp (cdr imports)
                  (cons resolved result)
                  (cons resolved seen))))))))

  ;; Expand (group-in base sub1 sub2 ...) → (base/sub1 base/sub2 ...)
  ;; e.g. (group-in :std/misc string list hash) → (:std/misc/string :std/misc/list :std/misc/hash)
  (define (expand-group-in imports)
    (let lp ((imports imports) (result '()))
      (if (null? imports)
        (reverse result)
        (let ((imp (car imports)))
          (if (and (pair? imp) (eq? (car imp) 'group-in))
            ;; Expand group-in: (group-in base sub1 sub2 ...)
            (let ((base (symbol->string (cadr imp)))
                  (subs (cddr imp)))
              (lp (cdr imports)
                  (append (reverse
                            (map (lambda (sub)
                                   (string->symbol
                                     (string-append base "/" (symbol->string sub))))
                                 subs))
                          result)))
            (lp (cdr imports) (cons imp result)))))))

  ;; Strip relative path prefixes (./ and ../) and normalize to a base module name.
  ;; Converts path separators to hyphens for flat R6RS library names.
  ;; Examples:
  ;;   "./server"           → "server"
  ;;   "../server"          → "server"
  ;;   "./compat/compat"    → "compat"      (use last path component)
  ;;   "../util/log"        → "util-log"    (join path with hyphens)
  ;;   "../handlers/sync"   → "handlers-sync"
  (define (normalize-relative-path s)
    (let* ((stripped (cond
                       ((string-prefix-ci? "./" s)
                        (substring s 2 (string-length s)))
                       ((string-prefix-ci? "../" s)
                        (substring s 3 (string-length s)))
                       (else s))))
      ;; Replace / with - for flat library naming
      (let loop ((i 0) (result '()))
        (if (>= i (string-length stripped))
          (list->string (reverse result))
          (let ((c (string-ref stripped i)))
            (loop (+ i 1)
                  (cons (if (char=? c #\/) #\- c) result)))))))

  ;; Get the default package name from the import map.
  ;; Looks for a (*default-package* . pkg-symbol) entry.
  ;; Falls back to 'gsh for backward compatibility.
  (define (get-default-package import-map)
    (let ((entry (assq '*default-package* import-map)))
      (if entry (cdr entry) 'gsh)))

  (define (resolve-import imp import-map . rest)
    (let ((default-pkg (get-default-package import-map))
          (source-dir (if (pair? rest) (car rest) "")))
      ;; Resolve a relative path using source directory context.
      ;; For ./parser from lsp/analysis/symbols.ss (source-dir="lsp/analysis"),
      ;; resolve to "lsp/analysis/parser", strip the package prefix ("lsp/"),
      ;; then flatten slashes to hyphens → "analysis-parser".
      (define (resolve-with-context rel-path)
        (let* ((rel-str (if (string? rel-path) rel-path (symbol->string rel-path)))
               (name (normalize-relative-path rel-str))
               ;; If source-dir has more than the package prefix, resolve relative
               (pkg-str (symbol->string default-pkg))
               (pkg-prefix (string-append pkg-str "/"))
               (full-path
                 (if (and (> (string-length source-dir) 0)
                          (string-prefix-ci? pkg-prefix source-dir))
                   ;; source-dir is "lsp/analysis", strip "lsp/" → "analysis"
                   (let ((subdir (substring source-dir
                                   (string-length pkg-prefix)
                                   (string-length source-dir))))
                     (if (> (string-length subdir) 0)
                       ;; For ./parser: subdir="analysis", name="parser" → "analysis-parser"
                       ;; For ../util/log: name="util-log" (already normalized)
                       ;; Only prepend subdir for ./ (same-dir) imports, not ../ (parent-dir)
                       (if (string-prefix-ci? "./" rel-str)
                         (string-append subdir "-" name)
                         name)
                       name))
                   name)))
          `(,default-pkg ,(string->symbol full-path))))
      (cond
        ;; String import: "./module" or "../compat/compat"
        ((string? imp)
         (let ((mapped (assq-string imp import-map)))
           (if mapped
             (cdr mapped)
             ;; Try with ./ prefix normalization
             (let* ((name (normalize-relative-path imp))
                    (mapped2 (assq-string (string-append "./" name) import-map)))
               (if mapped2
                 (cdr mapped2)
                 ;; Default: resolve with source directory context
                 (resolve-with-context imp))))))
        ;; Symbol import: :std/sugar, :pkg/ast, ./foo, ../bar/baz, etc.
        ((symbol? imp)
         (let* ((s (symbol->string imp))
                (mapped (or (assq imp import-map)
                            ;; Also check string key form
                            (assq-string s import-map))))
           (cond
             (mapped (cdr mapped))
             ;; ./ or ../ relative import → resolve with source directory context
             ((or (string-prefix-ci? "./" s)
                  (string-prefix-ci? "../" s))
              (resolve-with-context imp))
             ;; :pkg/<name> → check if pkg matches default-package or known packages
             ;; Generic :prefix/name pattern → (prefix name)
             ((and (> (string-length s) 1)
                   (char=? (string-ref s 0) #\:))
              (let ((slash-idx (let lp ((i 1))
                                 (cond
                                   ((>= i (string-length s)) #f)
                                   ((char=? (string-ref s i) #\/) i)
                                   (else (lp (+ i 1)))))))
                (cond
                  ((not slash-idx)
                   ;; No slash — just a symbol, try prefix match
                   (let ((prefix-match (find-prefix-match s import-map)))
                     (if prefix-match (cdr prefix-match) #f)))
                  (else
                   (let* ((pkg-name (substring s 1 slash-idx))
                          (mod-path (substring s (+ slash-idx 1) (string-length s)))
                          (mod-sym (string->symbol
                                     (let loop ((i 0) (result '()))
                                       (if (>= i (string-length mod-path))
                                         (list->string (reverse result))
                                         (let ((c (string-ref mod-path i)))
                                           (loop (+ i 1)
                                                 (cons (if (char=? c #\/) #\- c)
                                                       result))))))))
                     (cond
                       ;; :std/* → check map, otherwise skip
                       ((string=? pkg-name "std")
                        (let ((prefix-match (find-prefix-match s import-map)))
                          (if prefix-match (cdr prefix-match) #f)))
                       ;; :gerbil/* → strip
                       ((string=? pkg-name "gerbil") #f)
                       ;; :other-pkg/name → (other-pkg name)
                       (else
                        `(,(string->symbol pkg-name) ,mod-sym))))))))
             ;; :gerbil/* → strip (fallback)
             ((string-prefix-ci? ":gerbil/" s) #f)
             (else
              ;; Unknown → try as-is
              `(,imp)))))
        ;; Pair import: already a library spec, or (only-in ...) etc.
        ((pair? imp)
         ;; Check for (only-in mod sym...) etc.
         (if (memq (car imp) '(only-in except-in rename-in prefix-in
                                 only except rename prefix))
           ;; Resolve the module part; convert Gerbil names to R6RS
           (let ((resolved-mod (resolve-import (cadr imp) import-map source-dir))
                 (r6rs-head (case (car imp)
                              ((only-in only) 'only)
                              ((except-in except) 'except)
                              ((rename-in rename) 'rename)
                              ((prefix-in prefix) 'prefix)
                              (else (car imp)))))
             (if resolved-mod
               `(,r6rs-head ,resolved-mod ,@(cddr imp))
               #f))
           imp))
        (else #f))))

  ;; Helper: string prefix check (case-insensitive)
  (define (string-prefix-ci? prefix str)
    (let ((plen (string-length prefix))
          (slen (string-length str)))
      (and (<= plen slen)
           (string=? prefix (substring str 0 plen)))))

  ;; Helper: find an import-map entry matching a prefix
  (define (find-prefix-match str import-map)
    (cond
      ((null? import-map) #f)
      ((let ((key (caar import-map)))
         (and (symbol? key)
              (string-prefix-ci? (symbol->string key) str)))
       (car import-map))
      (else (find-prefix-match str (cdr import-map)))))

  ;; Helper: assq for string keys
  (define (assq-string key alist)
    (cond
      ((null? alist) #f)
      ((and (string? (caar alist)) (string=? (caar alist) key))
       (car alist))
      (else (assq-string key (cdr alist)))))

  ) ;; end library
