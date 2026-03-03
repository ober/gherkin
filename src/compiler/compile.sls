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
    )

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise)
            (error chez:error) (raise chez:raise))
    (only (compat gambit-compat) |##keyword?| |##keyword->string|)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax)
    (runtime eval))

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
             `(define (,name ,@(compile-params params))
                ,@(map gerbil-compile-expression real-body)))))
        ;; (def name : type expr) — type-annotated value
        ((and (pair? body) (eq? (car body) ':) (pair? (cdr body)) (pair? (cddr body)))
         `(define ,sig ,(gerbil-compile-expression (caddr body))))
        ;; (def name expr)
        (else
         `(define ,sig ,(gerbil-compile-expression (car body)))))))

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
  ;; Handles Gerbil parameter syntax: rest args, optional args
  (define (compile-params params)
    (cond
      ((null? params) '())
      ((symbol? params) params)  ;; rest arg
      ((pair? params)
       (cons (car params) (compile-params (cdr params))))
      (else params)))

  ;; --- Expression compilation ---
  (define (gerbil-compile-expression expr)
    (cond
      ((not (pair? expr))
       (cond
         ((and (symbol? expr) (keyword-symbol? expr))
          ;; Convert keyword: symbol to quoted keyword
          `(quote ,expr))
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
            `(set! ,(cadr expr) ,(gerbil-compile-expression (caddr expr))))
           ;; quote
           ((eq? head 'quote) expr)
           ;; quasiquote
           ((eq? head 'quasiquote)
            `(quasiquote ,(compile-quasiquote (cadr expr))))
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
           ;; with-catch (Gerbil-style)
           ((eq? head 'with-catch)
            `(guard (__exn (#t (,(gerbil-compile-expression (cadr expr)) __exn)))
               ,(gerbil-compile-expression (caddr expr))))
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
           ;; displayln / println
           ((eq? head 'displayln)
            (compile-displayln expr))
           ;; string-join, string-split
           ((memq head '(string-join string-split))
            (compile-string-op head expr))
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
      `(,(car clause) ,@(map gerbil-compile-expression (cdr clause)))))

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
            ;; ([hd . rest] body...) - pair destructuring
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
      ;; (? pred) - predicate
      ((and (pair? pattern) (eq? (car pattern) '?))
       (let ((pred (cadr pattern)))
         (if (and (pair? pred) (eq? (car pred) 'not))
           `(if (not (,(cadr pred) ,target)) ,success ,fail)
           `(if (,pred ,target) ,success ,fail))))
      ;; (hd . rest) - pair destructuring
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
      ;; symbol - bind it
      ((symbol? pattern)
       `(let ((,pattern ,target)) ,success))
      ;; literal
      (else
       `(if (equal? ,target ',pattern) ,success ,fail))))

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
        `(begin
           (define ,(string->symbol (string-append (symbol->string name) "::t"))
             (make-class-type ',type-id ',type-name ,parent-refs
               ',(if (list? fields) fields (list fields))
               '()
               #f))
           ;; Predicate
           (define (,(string->symbol (string-append (symbol->string name) "?")) obj)
             (|##structure-instance-of?| obj ',type-id))
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
                       acc))))))))

  ;; --- defmethod compilation ---
  (define (compile-defmethod form)
    ;; (defmethod {name type} body) or (defmethod (name obj args...) body...)
    (let ((sig (cadr form))
          (body (cddr form)))
      (cond
        ;; (defmethod {name type} lambda-expr)
        ((and (pair? sig) (eq? (car sig) '@method))
         (let ((name (cadr sig))
               (type (caddr sig)))
           `(method-set! ,type ',name ,(gerbil-compile-expression (car body)))))
        ;; (defmethod (name (self type) args...) body...)
        (else
         ;; For now, pass through
         `(begin ,@(map gerbil-compile-expression body))))))

  ;; --- defrules compilation ---
  (define (compile-defrules form)
    ;; (defrules name () (pattern template) ...)
    ;; (defrule (name pattern) template)
    (let ((name (cadr form)))
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

  ;; --- import compilation ---
  (define (compile-import form)
    ;; (import module1 module2 ...)
    ;; Gerbil imports need translation to Chez library imports
    ;; For now, pass through
    form)

  ;; --- lambda compilation (handle => annotation) ---
  (define (compile-lambda expr)
    ;; (lambda params body...) or (lambda params => type body...)
    (let ((params (cadr expr))
          (rest (cddr expr)))
      ;; Strip => type annotation if present
      (let ((body (if (and (pair? rest) (pair? (cdr rest)) (eq? (car rest) '=>))
                    (cddr rest)  ;; skip => and type
                    rest)))
        `(lambda ,(compile-params params)
           ,@(map gerbil-compile-expression body)))))

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
    ;;   (for ((var1 seq1) (var2 seq2)) body...)  — parallel bindings
    (let ((bindings (cadr expr))
          (body (cddr expr)))
      (cond
        ;; (for (var seq) body...) — single var, single seq
        ((and (pair? bindings) (= (length bindings) 2) (symbol? (car bindings)))
         (compile-for-single-binding (car bindings) (cadr bindings) body))
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

  ;; --- Helper: check if symbol ends with colon (keyword) ---
  (define (keyword-symbol? sym)
    (and (symbol? sym)
         (let ((s (symbol->string sym)))
           (and (fx> (string-length s) 1)
                (char=? (string-ref s (fx- (string-length s) 1)) #\:)))))

  ;; --- File compilation ---
  (define (gerbil-compile-file input-path)
    ;; Read and compile a Gerbil source file
    (let ((forms (read-all-forms input-path)))
      (map gerbil-compile-top forms)))

  (define (read-all-forms path)
    (call-with-input-file path
      (lambda (port)
        (let lp ((forms '()))
          (let ((datum (read port)))
            (if (eof-object? datum)
              (reverse forms)
              (lp (cons datum forms))))))))

  ;; --- Library compilation ---
  (define (gerbil-compile-to-library input-path lib-name)
    ;; Compile a Gerbil file to a Chez library
    (let ((forms (read-all-forms input-path))
          (imports '())
          (exports '())
          (body '()))
      ;; Separate imports, exports, and body
      (for-each
        (lambda (form)
          (cond
            ((and (pair? form) (eq? (car form) 'import))
             (set! imports (append imports (cdr form))))
            ((and (pair? form) (eq? (car form) 'export))
             (set! exports (append exports (cdr form))))
            ((and (pair? form) (memq (car form) '(prelude: package: namespace:)))
             #f)  ;; skip Gerbil headers
            (else
             (set! body (cons form body)))))
        forms)
      ;; Generate library
      `(library ,lib-name
         (export ,@(compile-exports (reverse exports)))
         (import (chezscheme)
                 (compat types)
                 (runtime util)
                 (runtime mop)
                 ,@(compile-library-imports imports))
         ,@(map gerbil-compile-top (reverse body)))))

  (define (compile-exports exports)
    (cond
      ((null? exports) '())
      ((and (pair? exports) (eq? (car exports) '#t))
       ;; (export #t) - export all
       '())  ;; Can't determine, skip
      (else exports)))

  (define (compile-library-imports imports)
    ;; Convert Gerbil import specs to Chez library imports
    (filter-map1
      (lambda (imp)
        (cond
          ((string? imp)
           ;; Relative path import: "./module" → (module)
           #f)  ;; skip for now
          ((symbol? imp)
           ;; Named import
           `(,imp))
          ((pair? imp) imp)
          (else #f)))
      imports))

  ) ;; end library
