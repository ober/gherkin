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
    sanitize-compiled
    resolve-import
    *default-import-map*
    *current-source-dir*
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

  ;; --- Current source directory for include resolution ---
  ;; Set this before compiling a file to resolve (include "relative/path")
  (define *current-source-dir* (make-parameter ""))

  ;; --- Compile-time macro table ---
  ;; Stores defrules/defrule macros for compile-time expansion
  (define *compile-time-macros* (make-hashtable symbol-hash eq?))

  ;; Functions that use keyword parameters — keyword objects in calls
  ;; to these should be stripped (they map to positional args)
  (define *keyword-functions* (make-hashtable symbol-hash eq?))
  (define (register-keyword-function! name)
    (hashtable-set! *keyword-functions* name #t))
  (define (keyword-function? name)
    (and (symbol? name)
         (hashtable-ref *keyword-functions* name #f)))

  ;; Check if (define Name Val) is a type-descriptor alias pattern:
  ;; Name matches Val minus "::t" suffix (e.g., Error → Error::t)
  ;; In Gambit, type descriptors are callable constructors; in Chez they're not.
  (define (type-alias-pattern? name val)
    (let ([val-str (symbol->string val)]
          [name-str (symbol->string name)])
      (and (> (string-length val-str) 3)
           (string=? (substring val-str (- (string-length val-str) 3)
                                (string-length val-str))
                     "::t")
           (string=? (substring val-str 0 (- (string-length val-str) 3))
                     name-str))))

  (define (register-compile-time-macro! name keywords clauses)
    ;; clauses: ((pattern template) ...)
    (hashtable-set! *compile-time-macros* name (cons keywords clauses)))

  (define (compile-time-macro? name)
    (and (symbol? name)
         (hashtable-ref *compile-time-macros* name #f)))

  ;; Collect pattern variable names from a pattern
  (define (pattern-variables pat keywords)
    (cond
      [(and (symbol? pat) (not (eq? pat '_)) (not (eq? pat '...))
            (not (memq pat keywords)))
       (list pat)]
      [(pair? pat)
       (if (and (pair? (cdr pat)) (eq? (cadr pat) '...))
         (pattern-variables (car pat) keywords)
         (append (pattern-variables (car pat) keywords)
                 (pattern-variables (cdr pat) keywords)))]
      [else '()]))

  ;; Simple pattern matcher for syntax-rules style patterns
  (define (match-pattern pattern form keywords env)
    ;; Returns env (alist of bindings) or #f
    (cond
      [(eq? pattern '_) env] ;; wildcard
      [(and (symbol? pattern)
            (not (memq pattern keywords))
            (not (eq? pattern '...)))
       (cons (cons pattern form) env)]
      [(and (symbol? pattern) (memq pattern keywords))
       (if (and (symbol? form) (eq? form pattern)) env #f)]
      [(null? pattern) (if (null? form) env #f)]
      [(and (pair? pattern) (pair? (cdr pattern)) (eq? (cadr pattern) '...))
       ;; pattern: (pat ... . rest)
       (let ([elem-pat (car pattern)]
             [rest-pat (cddr pattern)]
             [pvars (pattern-variables (car pattern) keywords)])
         (if (null? rest-pat)
           ;; (pat ...) — match all remaining forms
           (if (list? form)
             (let loop ([forms form] [per-form-envs '()])
               (if (null? forms)
                 ;; Collect each pattern variable into a list binding
                 (let ([reversed-envs (reverse per-form-envs)])
                   (fold-left
                     (lambda (env pvar)
                       (cons (cons pvar
                               (map (lambda (e)
                                      (let ([b (assq pvar e)])
                                        (if b (cdr b) #f)))
                                    reversed-envs))
                             env))
                     env pvars))
                 (let ([m (match-pattern elem-pat (car forms) keywords '())])
                   (if m
                     (loop (cdr forms) (cons m per-form-envs))
                     #f))))
             #f)
           ;; Has rest after ... — not handled for now
           #f))]
      [(pair? pattern)
       (if (pair? form)
         (let ([m (match-pattern (car pattern) (car form) keywords env)])
           (if m
             (match-pattern (cdr pattern) (cdr form) keywords m)
             #f))
         #f)]
      [(equal? pattern form) env]
      [else #f]))

  ;; Find template variables used with ... (ellipsis-depth > 0)
  (define (template-ellipsis-vars template env)
    (cond
      [(symbol? template)
       (let ([b (assq template env)])
         (if (and b (list? (cdr b))) (list template) '()))]
      [(pair? template)
       (if (and (pair? (cdr template)) (eq? (cadr template) '...))
         (template-ellipsis-vars (car template) env)
         (append (template-ellipsis-vars (car template) env)
                 (template-ellipsis-vars (cdr template) env)))]
      [else '()]))

  (define (substitute-template template env)
    ;; Simple template substitution with proper ellipsis handling
    (cond
      [(symbol? template)
       (let ([binding (assq template env)])
         (if binding (cdr binding) template))]
      [(pair? template)
       (if (and (pair? (cdr template)) (eq? (cadr template) '...))
         ;; (tmpl ...) — replicate tmpl for each element of list-bindings
         (let* ([sub-tmpl (car template)]
                [evars (template-ellipsis-vars sub-tmpl env)]
                [rest-tmpl (cddr template)])
           (if (null? evars)
             ;; No list variables found — just substitute normally
             (cons (substitute-template sub-tmpl env)
                   (substitute-template (cdr template) env))
             ;; Replicate: get the length from first list-bound var
             (let* ([first-binding (assq (car evars) env)]
                    [n (length (cdr first-binding))])
               (let loop ([i 0] [acc '()])
                 (if (= i n)
                   (append (reverse acc)
                           (substitute-template rest-tmpl env))
                   ;; Create a per-iteration env with scalar bindings
                   (let ([iter-env
                          (fold-left
                            (lambda (e var)
                              (let ([b (assq var env)])
                                (if (and b (list? (cdr b)))
                                  (cons (cons var (list-ref (cdr b) i)) e)
                                  e)))
                            env evars)])
                     (loop (+ i 1)
                           (cons (substitute-template sub-tmpl iter-env)
                                 acc))))))))
         (cons (substitute-template (car template) env)
               (substitute-template (cdr template) env)))]
      [else template]))

  (define (expand-compile-time-macro name form)
    ;; Try to expand using registered macro
    (let ([macro-entry (hashtable-ref *compile-time-macros* name #f)])
      (if macro-entry
        (let ([keywords (car macro-entry)]
              [clauses (cdr macro-entry)])
          (let loop ([clauses clauses])
            (if (null? clauses)
              #f ;; no clause matched
              (let* ([clause (car clauses)]
                     [pattern (car clause)]
                     [template (cadr clause)]
                     [env (match-pattern pattern form keywords '())])
                (if env
                  (substitute-template template env)
                  (loop (cdr clauses)))))))
        #f)))

  ;; --- Top-level form compilation ---
  ;; Takes a Gerbil s-expression and returns a Chez s-expression

  ;; Check if a symbol is a %# core form (like %#quote, %#if, etc.)
  (define (core-form-symbol? sym)
    (and (symbol? sym)
         (let ([s (symbol->string sym)])
           (and (>= (string-length s) 2)
                (char=? (string-ref s 0) #\%)
                (string=? (substring s 1 2) "#")))))

  ;; Get the plain name from a %# core form symbol
  (define (core-form-name sym)
    (let ([s (symbol->string sym)])
      (string->symbol (substring s 2 (string-length s)))))

  ;; Match a core form head against a known name
  (define (core-form=? head name)
    (and (core-form-symbol? head)
         (string=? (symbol->string (core-form-name head)) name)))

  ;; Translate expanded Gerbil core forms (%#xxx) back to plain Gerbil
  ;; This is needed when the Gerbil expander produces core forms and we
  ;; need to compile them through gherkin.
  (define (core-form->gerbil form)
    (cond
      [(not (pair? form)) form]
      [else
       (let ([head (car form)])
         (cond
           [(core-form=? head "quote") `(quote ,(cadr form))]
           [(core-form=? head "if")
            `(if ,(core-form->gerbil (cadr form))
                 ,(core-form->gerbil (caddr form))
                 ,@(if (null? (cdddr form)) '()
                       (list (core-form->gerbil (cadddr form)))))]
           [(core-form=? head "ref") (cadr form)]
           [(core-form=? head "set!")
            `(set! ,(cadr form) ,(core-form->gerbil (caddr form)))]
           [(core-form=? head "lambda")
            `(lambda ,(cadr form) ,@(map core-form->gerbil (cddr form)))]
           [(core-form=? head "case-lambda")
            `(case-lambda ,@(map (lambda (clause)
                                   (cons (car clause)
                                         (map core-form->gerbil (cdr clause))))
                                 (cdr form)))]
           [(core-form=? head "let-values")
            `(let-values ,(map (lambda (binding)
                                 (list (car binding) (core-form->gerbil (cadr binding))))
                               (cadr form))
               ,@(map core-form->gerbil (cddr form)))]
           [(core-form=? head "letrec-values")
            `(letrec-values ,(map (lambda (binding)
                                    (list (car binding) (core-form->gerbil (cadr binding))))
                                  (cadr form))
               ,@(map core-form->gerbil (cddr form)))]
           [(core-form=? head "letrec*-values")
            `(letrec*-values ,(map (lambda (binding)
                                     (list (car binding) (core-form->gerbil (cadr binding))))
                                   (cadr form))
               ,@(map core-form->gerbil (cddr form)))]
           [(core-form=? head "begin")
            `(begin ,@(map core-form->gerbil (cdr form)))]
           [(core-form=? head "begin-annotation")
            (core-form->gerbil (caddr form))]
           [(core-form=? head "define-values")
            (let ([ids (cadr form)]
                  [expr (core-form->gerbil (caddr form))])
              (if (and (pair? ids) (null? (cdr ids)))
                `(define ,(car ids) ,expr)
                `(define-values ,ids ,expr)))]
           [(core-form=? head "define-syntax")
            `(define-syntax ,(cadr form) ,(core-form->gerbil (caddr form)))]
           [(core-form=? head "define-alias")
            `(define ,(cadr form) ,(caddr form))]
           [(core-form=? head "call")
            `(,(core-form->gerbil (cadr form)) ,@(map core-form->gerbil (cddr form)))]
           [(core-form=? head "quote-syntax")
            `(quote ,(cadr form))]
           [(core-form=? head "struct-ref")
            `(|##structure-ref| ,(core-form->gerbil (cadr form)) ,(caddr form))]
           [(core-form=? head "struct-set!")
            `(|##structure-set!| ,(core-form->gerbil (cadr form)) ,(caddr form)
               ,(core-form->gerbil (cadddr form)))]
           [(core-form=? head "import") '(begin)]
           [(core-form=? head "export") '(begin)]
           ;; Unknown %# form — strip prefix and recurse
           [(core-form-symbol? head)
            (let ([plain (core-form-name head)])
              `(,plain ,@(map core-form->gerbil (cdr form))))]
           ;; Not a core form — recurse on subforms
           [else (map core-form->gerbil form)]))]))

  (define (gerbil-compile-top form)
    (cond
      ((not (pair? form)) form)
      ;; Handle expanded core forms from the Gerbil expander
      ((core-form-symbol? (car form))
       (let ([plain (core-form->gerbil form)])
         (gerbil-compile-top plain)))
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
           ;; defrefset — Gerbil MOP field accessor/mutator macro
           ((eq? head 'defrefset)
            (compile-defrefset form))
           ;; defpred — Gerbil MOP predicate definition
           ;; (defpred (name obj) :- :type body...)
           ;; → (define (name obj) body...)
           ((eq? head 'defpred)
            (compile-defpred form))
           ;; deftype — type alias definition
           ;; (deftype alias-name type-name) → (define alias-name type-name)
           ((eq? head 'deftype)
            (let ([alias (cadr form)]
                  [type-expr (caddr form)])
              ;; Skip @-prefixed aliases (Gerbil namespace markers)
              (let ([alias-str (symbol->string alias)])
                (if (and (> (string-length alias-str) 0)
                         (char=? (string-ref alias-str 0) #\@))
                  '(begin)  ;; no-op
                  `(define ,alias ,type-expr)))))
           ;; defraise/context — Gerbil error raise macro
           ;; (defraise/context (rule where args ...) (Klass msg irritants: irr))
           ;; → (defrules rule () ((_ where args ...) (raise (Klass msg ...))))
           ((eq? head 'defraise/context)
            (compile-defraise/context form))
           ;; deferror-class — Gerbil error class definition
           ;; (deferror-class Name () predicate?) →
           ;;   (defclass (Name Error) () transparent: #t)
           ;;   (defmethod {:init! Name} Error:::init!)
           ;;   (def predicate? Name?)
           ((eq? head 'deferror-class)
            (compile-deferror-class form))
           ;; defgeneric — :std/generic generic function definition
           ;; (defgeneric name body) → (define name body)
           ((eq? head 'defgeneric)
            (let ([name (cadr form)]
                  [body (caddr form)])
              `(define ,name ,(gerbil-compile-expression body))))
           ;; defstruct-type — Gerbil runtime struct type declaration
           ;; (defstruct-type type::t (super::t) make-fn pred?
           ;;   id: type-id name: display-name)
           ((eq? head 'defstruct-type)
            (compile-defstruct-type form))
           ;; defcore-forms — binds core syntax forms
           ((eq? head 'defcore-forms)
            (compile-defcore-forms form))
           ;; defruntime-exception(s) — Gambit runtime exception wrappers
           ((eq? head 'defruntime-exception)
            (compile-defruntime-exception form))
           ((eq? head 'defruntime-exceptions)
            `(begin ,@(map (lambda (f) (compile-defruntime-exception `(defruntime-exception ,f)))
                           (cdr form))))
           ;; module — nested module form
           ;; (module Name body...) or (module Name (export ...) body...)
           ;; Compile body forms, stripping import/export
           ((eq? head 'module)
            (if (and (pair? (cdr form)) (pair? (cddr form)))
              (let* ((body (cddr form))
                     ;; Compile body forms tolerantly — skip individual failures
                     (compiled (let loop ((forms body) (acc '()))
                                 (if (null? forms)
                                   (reverse acc)
                                   (loop (cdr forms)
                                         (cons (guard (exn [#t '(begin)])
                                                 (gerbil-compile-top (car forms)))
                                               acc)))))
                     ;; Strip import/export/empty-begin from module bodies
                     (filtered (filter
                                 (lambda (c)
                                   (not (or (and (pair? c) (memq (car c) '(import export)))
                                            (equal? c '(begin)))))
                                 compiled)))
                (if (null? filtered)
                  '(begin)
                  `(begin ,@filtered)))
              '(begin)))
           ;; define-alias / defalias — (define-alias new-name old-name)
           ((memq head '(define-alias defalias))
            (if (and (pair? (cdr form)) (pair? (cddr form)))
              `(define ,(cadr form) ,(caddr form))
              '(begin)))
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
           ;; define-syntax — pass through or translate
           ;; Handles syntax-rules (native), identifier-rules (translate to
           ;; make-variable-transformer for Chez compatibility)
           ((eq? head 'define-syntax)
            (let ((name (cadr form))
                  (transformer (caddr form)))
              (if (and (pair? transformer)
                       (eq? (car transformer) 'identifier-rules))
                ;; identifier-rules wraps a parameter for get/set
                ;; Define as a regular mutable variable initialized from the parameter
                ;; This allows both read and set! to work without syntax transformers
                (let* ((clauses (cddr transformer))
                       (getter-clause
                         (find (lambda (c) (not (and (pair? (car c)) (eq? (caar c) 'set!))))
                               clauses)))
                  (if getter-clause
                    (let ([get-body (if (and (pair? (cdr getter-clause))
                                            (pair? (cddr getter-clause)))
                                     (caddr getter-clause)
                                     (cadr getter-clause))])
                      `(define ,name ,get-body))
                    '(begin)))
                ;; Check for Gambit ## unsafe-optimization macros and skip them
                ;; These map standard functions to Gambit unsafe versions; no-op on Chez
                (letrec ((has-gambit-prim?
                           (lambda (form)
                             (cond
                               ((symbol? form)
                                (let ((s (symbol->string form)))
                                  (and (> (string-length s) 2)
                                       (string=? (substring s 0 2) "##"))))
                               ((pair? form)
                                (or (has-gambit-prim? (car form))
                                    (has-gambit-prim? (cdr form))))
                               (else #f)))))
                  (if (has-gambit-prim? transformer)
                    '(begin)  ;; skip Gambit unsafe-op macros
                    form)))))
           ;; declare / declare-inline
           ((memq head '(declare declare-inline))
            '(begin)) ;; ignore declarations
           ;; begin-syntax — compile-time definitions, treat as begin
           ((eq? head 'begin-syntax)
            (cons 'begin (map gerbil-compile-top (cdr form))))
           ;; ~let — Gerbil sugar form (can appear at top level)
           ((eq? head '~let)
            (gerbil-compile-expression form))
           ;; begin-foreign — FFI declarations, pass through body
           ((eq? head 'begin-foreign)
            (cons 'begin (map gerbil-compile-top (cdr form))))
           ;; begin-annotation — strip annotation, keep body
           ((eq? head 'begin-annotation)
            (if (and (pair? (cdr form)) (pair? (cddr form)))
              (gerbil-compile-top (caddr form))
              '(begin)))
           ;; extern — map extern declarations to no-op
           ;; (the bindings come from gambit-compat)
           ((eq? head 'extern)
            '(begin))
           ;; defmutable / defmutable* — define with set! semantics
           ((memq head '(defmutable defmutable*))
            (compile-defmutable form))
           ;; compile-time macro expansion
           ((compile-time-macro? head)
            (let ([expanded (expand-compile-time-macro head form)])
              (if expanded
                (gerbil-compile-top expanded)
                (gerbil-compile-expression form))))
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
        ;; Special case: (define (void) (void)) → non-recursive void
        ;; Gerbil defines void as a function returning #!void, but the self-reference
        ;; creates infinite recursion. Replace with safe version.
        ((and (pair? sig) (eq? (car sig) 'void) (null? (cdr sig))
              (pair? body) (null? (cdr body))
              (or (equal? (car body) '(void))
                  (void? (car body))))
         '(define (void . _) (if #f #f)))
        ;; (def (name args...) body...) or (def (name args...) => type body...)
        ;; Also handles curried: (def ((name outer...) inner...) body...)
        ((pair? sig)
         (let ((name (car sig))
               (params (cdr sig)))
           ;; Strip => type annotation if present
           (let* ((has-return-type (and (pair? body) (pair? (cdr body))
                                       (eq? (car body) '=>)))
                  (real-body (if has-return-type (cddr body) body))
                  ;; Check if any params are typed — if so, generate __ alias
                  (has-typed (and (symbol? name) ;; not curried
                                 (list? params) ;; not dotted/rest
                                 (exists typed-param? params)))
                  (def-form
                    (cond
                      ;; Curried definition: ((name outer...) inner...)
                      ((pair? name)
                       (let ((outer-name (car name))
                             (outer-params (cdr name))
                             (inner-params params))
                         `(define (,outer-name ,@(compile-params outer-params))
                            (lambda (,@(compile-params inner-params))
                              ,@(compile-body real-body)))))
                      ((has-optional-params? params)
                       ;; Register as keyword function if it has any keyword params
                       (when (and (symbol? name)
                                  (has-keyword-params? params))
                         (register-keyword-function! name))
                       (compile-def-with-optionals name params real-body))
                      (else
                       `(define (,name ,@(compile-params params))
                          ,@(compile-body real-body))))))
             ;; If typed params, generate both def and __ alias
             (if (and has-typed (symbol? name))
               (let ((alias-name (string->symbol
                                   (string-append "__" (symbol->string name)))))
                 `(begin ,def-form
                         (define ,alias-name ,name)))
               def-form))))
        ;; (def name : type expr) — type-annotated value
        ((and (pair? body) (eq? (car body) ':) (pair? (cdr body)) (pair? (cddr body)))
         `(define ,sig ,(gerbil-compile-expression (caddr body))))
        ;; (def name expr)
        (else
         (if (null? body)
           `(define ,sig (void))
           (let ([compiled-val (gerbil-compile-expression (car body))])
             ;; Detect (define Name Name::t) pattern — type descriptor aliases
             ;; In Gambit, type descriptors are callable constructors; in Chez they're not.
             ;; Generate a constructor wrapper instead.
             (if (and (symbol? sig) (symbol? compiled-val)
                      (type-alias-pattern? sig compiled-val))
               `(define (,sig . args) (apply make-instance ,compiled-val args))
               `(define ,sig ,compiled-val))))))))

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
  ;; Check if a parameter is a typed annotation: (name : type) or (name :- type) or (name :~ ...)
  ;; The separator may be a symbol or a keyword-object from the Gerbil reader
  (define (type-separator? x)
    (or (memq x '(: :- :~ :?))
        (and (|##keyword?| x)
             (member (|##keyword->string| x) '("" "-" "~" "?")))))
  (define (typed-param? p)
    (and (pair? p) (symbol? (car p))
         (pair? (cdr p))
         (type-separator? (cadr p))
         (pair? (cddr p))))

  ;; Typed param with default: (name : type := default) or (name :? type)
  (define (typed-param-with-default? p)
    (and (typed-param? p)
         (or
           ;; (name :? type) — optional typed param, default #f
           (and (pair? p) (pair? (cdr p)) (eq? (cadr p) ':?))
           ;; (name : type := default) — explicit default
           (and (>= (length p) 5)
                (let ((rest (cdddr p)))
                  (and (pair? rest)
                       (let ((sym (car rest)))
                         (and (symbol? sym)
                              (string=? (symbol->string sym) ":=")))))))))

  (define (compile-params params)
    (cond
      ((null? params) '())
      ((symbol? params) params)  ;; rest arg
      ((pair? params)
       (let ((p (car params)))
         (cond
           ;; keyword-object from Gerbil reader → skip it and its arg
           ((|##keyword?| p)
            (if (pair? (cdr params))
              (compile-params (cddr params))
              (compile-params (cdr params))))
           ;; keyword arg: name: (name default) → skip (handled at def level)
           ((keyword-symbol? p)
            ;; Skip keyword and its spec, continue with rest
            (if (and (pair? (cdr params)) (pair? (cadr params)))
              (compile-params (cddr params))
              (compile-params (cdr params))))
           ;; typed param: (name : type) → just the name
           ((typed-param? p)
            (cons (car p) (compile-params (cdr params))))
           ;; optional arg: (name default) → just the name
           ((and (pair? p) (symbol? (car p)))
            (cons (car p) (compile-params (cdr params))))
           (else
            (cons p (compile-params (cdr params)))))))
      (else params)))

  ;; Check if param list has optional args: (name default) pairs
  ;; Typed params (name : type) are NOT optional
  ;; Check if params list contains any keyword parameters (required or optional)
  (define (has-keyword-params? params)
    (cond
      ((null? params) #f)
      ((not (pair? params)) #f)
      ((keyword-symbol? (car params)) #t)
      ((|##keyword?| (car params)) #t)
      (else (has-keyword-params? (cdr params)))))

  (define (has-optional-params? params)
    (cond
      ((null? params) #f)
      ((not (pair? params)) #f)
      ((typed-param-with-default? (car params)) #t)
      ((typed-param? (car params)) (has-optional-params? (cdr params)))
      ((pair? (car params)) #t)
      ((keyword-symbol? (car params)) #t)
      (else (has-optional-params? (cdr params)))))

  ;; Extract required params (before first optional)
  (define (required-params params)
    (cond
      ((null? params) '())
      ((not (pair? params)) '())  ;; rest arg - not a required positional
      ((typed-param-with-default? (car params)) '())  ;; typed with default → optional
      ((typed-param? (car params))
       ;; (name : type) → extract name as required
       (cons (caar params) (required-params (cdr params))))
      ((pair? (car params)) '())  ;; optional arg starts
      ((keyword-symbol? (car params)) '()) ;; keyword starts
      (else (cons (car params) (required-params (cdr params))))))

  ;; Extract required keyword params: list of names (keyword args without defaults)
  ;; e.g., get-precedence-list: get-precedence-list → (get-precedence-list)
  (define (required-keyword-params params)
    (cond
      ((null? params) '())
      ((not (pair? params)) '())
      ((keyword-symbol? (car params))
       (if (and (pair? (cdr params)) (symbol? (cadr params))
                (not (keyword-symbol? (cadr params))))
         ;; keyword: symbol (no default) → required keyword
         (cons (cadr params) (required-keyword-params (cddr params)))
         ;; keyword: (name default) → optional, skip
         (if (pair? (cdr params))
           (required-keyword-params (cddr params))
           '())))
      (else (required-keyword-params (cdr params)))))

  ;; Extract optional params: list of (name default) pairs
  (define (optional-params params)
    (cond
      ((null? params) '())
      ((not (pair? params)) '())
      ((keyword-symbol? (car params))
       ;; keyword: (name default) → treat as optional
       (if (and (pair? (cdr params)) (pair? (cadr params)))
         (cons (cadr params) (optional-params (cddr params)))
         ;; keyword: symbol → required keyword, skip
         (if (pair? (cdr params))
           (optional-params (cddr params))
           '())))
      ((typed-param-with-default? (car params))
       ;; (name : type := default) or (name :? type) → extract as (name default)
       (let* ((p (car params))
              (name (car p))
              (default (if (eq? (cadr p) ':?)
                         #f  ;; :? typed param defaults to #f
                         (car (cddddr p)))))
         (cons (list name default) (optional-params (cdr params)))))
      ((typed-param? (car params))
       ;; (name : type) → NOT optional, skip
       (optional-params (cdr params)))
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
         ;; #!void → (|%%void|) - use internal name to avoid recursion with redefined void
         ((void? expr)
          '(|%%void|))
         ;; #!eof → (|%%eof|) - internal name to avoid recursion
         ((eof-object? expr)
          '(|%%eof|))
         ;; #!optional (absent) → (|%%absent|)
         ((absent-obj? expr)
          '(|%%absent|))
         ;; #!unbound → (|%%unbound|)
         ((unbound-obj? expr)
          '(|%%unbound|))
         ;; ## Gambit primitives → FFI replacements
         ((and (symbol? expr) (gambit-primitive-replacement expr))
          => (lambda (x) x))
         ;; Gambit → Chez function renames (cdr-set! → set-cdr!, etc.)
         ((and (symbol? expr) (gambit-rename expr))
          => (lambda (x) x))
         (else expr)))
      ;; Handle dotted pairs (alist entries like [key: . val]) as cons expressions
      ;; But first check if head is @list — @list can be dotted: (@list a b . rest)
      ((not (list? expr))
       (let ([a (car expr)])
         (if (eq? a '@list)
           ;; Dotted @list: (@list a b . rest) → (cons* a b rest)
           (let loop ([elts (cdr expr)] [acc '()])
             (cond
               [(pair? elts)
                (loop (cdr elts)
                      (cons (gerbil-compile-expression (car elts)) acc))]
               [else
                (let ([compiled-rest (gerbil-compile-expression elts)]
                      [rev-acc (reverse acc)])
                  (if (null? rev-acc)
                    compiled-rest
                    `(cons* ,@rev-acc ,compiled-rest)))]))
           ;; Regular dotted pair
           (let ([d (cdr expr)])
             `(cons ,(gerbil-compile-expression a)
                    ,(gerbil-compile-expression d))))))
      (else
       (let ((head (car expr)))
         (cond
           ;; lambda / lambda%
           ((memq head '(lambda lambda%))
            (compile-lambda expr))
           ;; case-lambda
           ((eq? head 'case-lambda)
            `(case-lambda
               ,@(map (lambda (clause)
                        `(,(compile-params (car clause))
                          ,@(compile-body (cdr clause))))
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
           ;; ~let — Gerbil sugar for let-values with named-let support
           ;; (~let let-values name ((var init) ...) body ...) → named let
           ;; (~let let-values ((var init) ...) body ...) → let
           ((eq? head '~let)
            (let ([let-kind (cadr expr)]
                  [rest (cddr expr)])
              (cond
                ;; Named let: (~let let-values name ((binding ...) ...) body ...)
                [(and (symbol? (car rest))
                      (not (memq (car rest) '(let-values let*-values))))
                 (let ([name (car rest)]
                       [bindings (cadr rest)]
                       [body (cddr rest)])
                   ;; For simple bindings ((var init) ...), compile as named let
                   (let ([simple-bindings
                           (map (lambda (b)
                                  (if (and (pair? b) (pair? (car b)) (null? (cdar b)))
                                    ;; ((var) init) → (var init)
                                    `(,(caar b) ,(gerbil-compile-expression (cadr b)))
                                    ;; (var init) → (var init)
                                    `(,(car b) ,(gerbil-compile-expression (cadr b)))))
                                bindings)])
                     `(let ,name ,simple-bindings
                        ,@(compile-body body))))]
                ;; Unnamed: (~let let-values ((binding ...) ...) body ...)
                [else
                 (let ([bindings (car rest)]
                       [body (cdr rest)])
                   (let ([simple-bindings
                           (map (lambda (b)
                                  (if (and (pair? b) (pair? (car b)) (null? (cdar b)))
                                    `(,(caar b) ,(gerbil-compile-expression (cadr b)))
                                    `(,(car b) ,(gerbil-compile-expression (cadr b)))))
                                bindings)])
                     `(let ,simple-bindings
                        ,@(compile-body body))))])))
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
           ;; quote — handle special values that can't be pretty-printed
           ((eq? head 'quote)
            (let ([val (cadr expr)])
              (compile-quoted-value val)))
           ;; quasiquote
           ((eq? head 'quasiquote)
            (list 'quasiquote (compile-quasiquote (cadr expr))))
           ;; match
           ((memq head '(core-ast-case ast-case))
            (compile-core-ast-case expr))
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
           ;; apply — strip keyword args when applying a keyword function
           ((eq? head 'apply)
            (let ([fn (and (pair? (cdr expr)) (cadr expr))])
              (if (and (symbol? fn) (keyword-function? fn) (pair? (cddr expr)))
                ;; Strip keywords from middle args, keep last arg (rest) for apply
                (let loop ([args (cddr expr)] [kw-args '()])
                  (if (null? (cdr args))
                    ;; Last arg is the rest-arg for apply
                    (let ([stripped (strip-keyword-args (reverse kw-args))]
                          [rest-arg (gerbil-compile-expression (car args))])
                      `(apply ,(gerbil-compile-expression fn) ,@stripped ,rest-arg))
                    (loop (cdr args) (cons (car args) kw-args))))
                `(apply ,@(map gerbil-compile-expression (cdr expr))))))
           ;; error: Gerbil (error msg args...) → Chez (error 'gerbil msg args...)
           ((eq? head 'error)
            `(error 'gerbil ,@(map gerbil-compile-expression (cdr expr))))
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
           ;; ? predicate form from Gerbil's match.ss
           ;; (? pred) → (lambda ($obj) (pred $obj))
           ;; (? (not pred)) → (lambda ($obj) (not (pred $obj)))
           ;; (? (and p1 p2 ...)) → (lambda ($obj) (and (p1 $obj) (p2 $obj) ...))
           ;; (? (or p1 p2 ...)) → (lambda ($obj) (or (p1 $obj) (p2 $obj) ...))
           ;; (? pred obj) → (pred obj)  [2-arg form, inline test]
           ((eq? head '?)
            (cond
              [(null? (cdr expr)) expr]
              ;; 2-arg form: (? pred obj) → (pred obj)
              [(and (pair? (cdr expr)) (pair? (cddr expr)) (null? (cdddr expr)))
               (let ((pred-expr (cadr expr))
                     (obj-expr (caddr expr)))
                 (compile-?-apply pred-expr (gerbil-compile-expression obj-expr)))]
              ;; 1-arg form: (? pred) → (lambda ($obj) ...)
              [else
               (let ((pred-expr (cadr expr))
                     (g (gensym "$obj")))
                 `(lambda (,g) ,(compile-?-apply pred-expr g)))]))
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
           ;; (@list a b c) → (list a b c)
           ;; (@list a b . rest) → (cons* a b rest) — spread syntax
           ((eq? head '@list)
            (let ([args (cdr expr)])
              (cond
                ;; Dotted @list: (@list a b . rest) → (cons* a b rest)
                [(not (list? args))
                 (let loop ([elts args] [acc '()])
                   (cond
                     [(pair? elts)
                      (loop (cdr elts)
                            (cons (gerbil-compile-expression (car elts)) acc))]
                     [else
                      (let ([compiled-rest (gerbil-compile-expression elts)]
                            [rev-acc (reverse acc)])
                        (if (null? rev-acc)
                          compiled-rest
                          `(cons* ,@rev-acc ,compiled-rest)))]))]
                ;; Spread: (@list a b rest ...) → (cons* a b rest)
                ;; The ... is a literal symbol at the end
                [(and (pair? args)
                      (let ([last-arg (list-ref args (- (length args) 1))])
                        (and (symbol? last-arg)
                             (string=? (symbol->string last-arg) "..."))))
                 (let* ([without-dots (reverse (cdr (reverse args)))])
                   (if (null? without-dots)
                     '(list)
                     (let ([head-elts (reverse (cdr (reverse without-dots)))]
                           [tail-elt (list-ref without-dots (- (length without-dots) 1))])
                       (if (null? head-elts)
                         (gerbil-compile-expression tail-elt)
                         `(cons* ,@(map gerbil-compile-expression head-elts)
                                 ,(gerbil-compile-expression tail-elt))))))]
                ;; [a :: r] syntax: (@list a :: r) → (cons a r)
                ;; :: means "rest of list" like . in standard Scheme
                ;; The :: may be symbol ':: or keyword-object with name ":"
                [(and (>= (length args) 3)
                      (exists (lambda (x)
                                (or (eq? x '::)
                                    (and (|##keyword?| x)
                                         (string=? (|##keyword->string| x) ":"))))
                              args))
                 (let split ([elts args] [acc '()])
                   (cond
                     [(and (pair? elts)
                           (let ([x (car elts)])
                             (or (eq? x '::)
                                 (and (|##keyword?| x)
                                      (string=? (|##keyword->string| x) ":")))))
                      ;; Everything before :: is consed onto the rest
                      (let ([rest (if (and (pair? (cdr elts)) (null? (cddr elts)))
                                    (gerbil-compile-expression (cadr elts))
                                    `(list ,@(map gerbil-compile-expression (cdr elts))))])
                        (if (null? acc)
                          rest
                          `(cons* ,@(reverse acc) ,rest)))]
                     [(pair? elts)
                      (split (cdr elts)
                             (cons (gerbil-compile-expression (car elts)) acc))]
                     [else
                      ;; No :: found after all — shouldn't happen given the guard
                      `(list ,@(reverse acc))]))]
                ;; Simple proper list: (@list a b c) → (list a b c)
                [else
                 `(list ,@(map gerbil-compile-expression args))])))
           ;; @method -- reader-generated form for {...}
           ((eq? head '@method)
            (compile-at-method expr))
           ;; hash literal: (hash (key val) ...)
           ;; Only if all args are pairs (key-value). Otherwise it's a function call.
           ((and (eq? head 'hash)
                 (pair? (cdr expr))
                 (for-all pair? (cdr expr)))
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
           ;; alet — (alet (var expr) body ...) → (let ((var expr)) (and var (begin body ...)))
           ;; Also: (alet var expr body ...) → same
           ((eq? head 'alet)
            (let ([binding (cadr expr)]
                  [body (cddr expr)])
              (if (and (pair? binding) (symbol? (car binding)))
                ;; (alet (var expr) body ...)
                (let ([var (car binding)]
                      [init (gerbil-compile-expression (cadr binding))])
                  `(let ([,var ,init])
                     (and ,var (begin ,@(compile-body body)))))
                ;; (alet var expr body ...) — var is symbol, expr is (cadr body)
                (let ([var binding]
                      [init (gerbil-compile-expression (car body))])
                  `(let ([,var ,init])
                     (and ,var (begin ,@(compile-body (cdr body)))))))))
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
           ;; abort! — Gerbil's abort: just evaluate the expression (typically a raise)
           ((eq? head 'abort!)
            (gerbil-compile-expression (cadr expr)))
           ;; exception-context — returns the enclosing function name
           ;; (exception-context name) → 'name
           ((eq? head 'exception-context)
            `(quote ,(cadr expr)))
           ;; cond-expand
           ((eq? head 'cond-expand)
            (compile-cond-expand expr))
           ;; member/assoc with custom predicate (3 args)
           ;; Gerbil: (member x lst pred) → Chez: (memp (lambda (e) (pred x e)) lst)
           ((and (eq? head 'member)
                 (= (length (cdr expr)) 3))
            (let ([x (gerbil-compile-expression (cadr expr))]
                  [lst (gerbil-compile-expression (caddr expr))]
                  [pred (gerbil-compile-expression (cadddr expr))]
                  [e-var (gensym "e")])
              `(memp (lambda (,e-var) (,pred ,x ,e-var)) ,lst)))
           ;; assoc with custom predicate (3 args)
           ((and (eq? head 'assoc)
                 (= (length (cdr expr)) 3))
            (let ([x (gerbil-compile-expression (cadr expr))]
                  [lst (gerbil-compile-expression (caddr expr))]
                  [pred (gerbil-compile-expression (cadddr expr))]
                  [e-var (gensym "e")])
              `(assp (lambda (,e-var) (,pred ,x ,e-var)) ,lst)))
           ;; rename-file: Gambit 3-arg → gambit-rename-file from compat
           ((and (eq? head 'rename-file)
                 (pair? (cdr expr))
                 (pair? (cddr expr))
                 (pair? (cdddr expr)))
            `(gambit-rename-file ,@(map gerbil-compile-expression (cdr expr))))
           ;; file-info → gambit-file-info
           ((eq? head 'file-info)
            `(gambit-file-info ,@(map gerbil-compile-expression (cdr expr))))
           ;; file-info-type → gambit-file-info-type
           ((eq? head 'file-info-type)
            `(gambit-file-info-type ,@(map gerbil-compile-expression (cdr expr))))
           ;; path-expand → gambit-path-expand
           ((eq? head 'path-expand)
            `(gambit-path-expand ,@(map gerbil-compile-expression (cdr expr))))
           ;; path-normalize → gambit-path-normalize
           ((eq? head 'path-normalize)
            `(gambit-path-normalize ,@(map gerbil-compile-expression (cdr expr))))
           ;; create-symbolic-link → gambit-create-symbolic-link
           ((eq? head 'create-symbolic-link)
            `(gambit-create-symbolic-link ,@(map gerbil-compile-expression (cdr expr))))
           ;; string->utf8 with start/end → substring first
           ((eq? head 'string->utf8)
            (let ([args (map gerbil-compile-expression (cdr expr))])
              (if (> (length args) 1)
                `(string->utf8 (substring ,(car args) ,(cadr args) ,(caddr args)))
                `(string->utf8 ,(car args)))))
           ;; begin-annotation — strip annotation, keep body
           ((eq? head 'begin-annotation)
            (if (and (pair? (cdr expr)) (pair? (cddr expr)))
              (gerbil-compile-expression (caddr expr))
              '(void)))
           ;; Type assertions: (: expr type) and (:- expr type) → just expr
           ((memq head '(: :-))
            (if (pair? (cdr expr))
              (gerbil-compile-expression (cadr expr))
              '(void)))
           ;; declare — ignore (Gambit compiler hint)
           ((eq? head 'declare)
            '(void))
           ;; core-syntax-case -- expand pattern matching on syntax objects
           ((eq? head 'core-syntax-case)
            (compile-core-syntax-case expr))
           ;; core-ast-case / ##c-code -- pass through
           ((memq head '(core-ast-case ast-case |##c-code|))
            expr)
           ;; compile-time macro expansion
           ((compile-time-macro? head)
            (let ([expanded (expand-compile-time-macro head expr)])
              (if expanded
                (gerbil-compile-expression expanded)
                (map gerbil-compile-expression expr))))
           ;; default: function application
           ;; Strip keyword arguments: (f a b key: val key2: val2)
           ;; → (f a b val val2)
           (else
            (if (list? expr)
              (let ([compiled (compile-call-args expr)])
                compiled)
              ;; Handle improper lists gracefully - just return as-is
              expr)))))))

  ;; --- Compile function call arguments ---
  ;; Strip keyword objects from args, keeping values positionally
  (define (strip-keyword-args args)
    (let loop ([args args] [result '()])
      (cond
        [(null? args) (reverse result)]
        [(|##keyword?| (car args))
         ;; Skip keyword, keep next value
         (if (pair? (cdr args))
           (loop (cddr args) (cons (gerbil-compile-expression (cadr args)) result))
           (reverse result))]
        [(and (symbol? (car args)) (keyword-symbol? (car args)))
         ;; Also skip symbol keywords like get-precedence-list:
         (if (pair? (cdr args))
           (loop (cddr args) (cons (gerbil-compile-expression (cadr args)) result))
           (reverse result))]
        [else
         (loop (cdr args) (cons (gerbil-compile-expression (car args)) result))])))

  ;; For known keyword functions, strip keyword objects from calls.
  ;; For all others, compile normally (keyword objects → quoted symbols).
  ;; Also handles (apply fn kw: val ... rest-args) where fn is a keyword function.
  (define (compile-call-args expr)
    (let ([head (car expr)])
      (cond
        ;; Direct call to keyword function: (fn kw: val ...)
        [(and (symbol? head) (keyword-function? head))
         (cons (gerbil-compile-expression head)
               (strip-keyword-args (cdr expr)))]
        ;; Apply call to keyword function: (apply fn kw: val ... rest-args)
        [(and (eq? head 'apply)
              (pair? (cdr expr))
              (symbol? (cadr expr))
              (keyword-function? (cadr expr)))
         ;; Strip keywords from middle args, keep last arg (rest) for apply
         (let* ([fn (cadr expr)]
                [middle-and-rest (cddr expr)])
           (if (null? middle-and-rest)
             (list 'apply (gerbil-compile-expression fn))
             ;; Separate rest-arg (last) from keyword args (all but last)
             (let loop ([args middle-and-rest] [kw-args '()])
               (if (null? (cdr args))
                 ;; Last arg is the rest-arg for apply
                 (let ([stripped (strip-keyword-args (reverse kw-args))]
                       [rest-arg (gerbil-compile-expression (car args))])
                   `(apply ,(gerbil-compile-expression fn) ,@stripped ,rest-arg))
                 (loop (cdr args) (cons (car args) kw-args))))))]
        ;; Not a keyword function — compile normally
        [else (map gerbil-compile-expression expr)])))

  ;; --- Quoted value compilation ---
  ;; Handle special values (void, absent, etc.) that can't be pretty-printed
  (define (has-special-value? val)
    (cond
      [(void? val) #t]
      [(eof-object? val) #t]
      [(absent-obj? val) #t]
      [(unbound-obj? val) #t]
      [(|##keyword?| val) #t]
      [(vector? val)
       (let lp ([i 0])
         (and (< i (vector-length val))
              (or (has-special-value? (vector-ref val i))
                  (lp (+ i 1)))))]
      [(pair? val)
       (or (has-special-value? (car val))
           (has-special-value? (cdr val)))]
      [else #f]))

  (define (compile-quoted-value val)
    (cond
      [(void? val) '(|%%void|)]
      [(eof-object? val) '(|%%eof|)]
      [(absent-obj? val) '(|%%absent|)]
      [(unbound-obj? val) '(|%%unbound|)]
      [(|##keyword?| val)
       `(quote ,(string->symbol (string-append (|##keyword->string| val) ":")))]
      [(and (vector? val) (has-special-value? val))
       ;; Convert to (vector ...) constructor
       `(vector ,@(map compile-quoted-value (vector->list val)))]
      [(and (pair? val) (has-special-value? val))
       `(cons ,(compile-quoted-value (car val))
              ,(compile-quoted-value (cdr val)))]
      [else `(quote ,val)]))

  ;; --- core-syntax-case expansion ---
  ;; Expands (core-syntax-case target-expr (kws...) clause ...) into
  ;; nested if/let pattern matching code against Gerbil AST objects.
  ;; This replaces the pass-through so compiled expander code can evaluate.

  (define (compile-core-syntax-case form)
    ;; form: (core-syntax-case target-expr (kws...) clause ...)
    (let* ([target-expr (cadr form)]
           [kws-raw (caddr form)]
           [kws (if (and (pair? kws-raw) (not (null? kws-raw))) kws-raw '())]
           [clauses (cdddr form)]
           [target-var (gensym "csc-e")])
      `(let ([,target-var ,(gerbil-compile-expression target-expr)])
         ,(compile-csc-clauses target-var kws clauses))))

  (define (compile-csc-clauses target kws clauses)
    (if (null? clauses)
      `(raise-syntax-error #f "Bad syntax; invalid syntax-case clause" ,target)
      (let* ([clause (car clauses)]
             [rest (cdr clauses)])
        (cond
          ;; else clause
          [(and (pair? clause) (eq? (car clause) 'else))
           (let ([body (cdr clause)])
             (if (null? (cdr body))
               (gerbil-compile-expression (car body))
               `(begin ,@(map gerbil-compile-expression body))))]
          ;; Regular clause: (pat body) or (pat fender body)
          [(pair? clause)
           (let* ([pat (car clause)]
                  [rest-clause (cdr clause)]
                  [has-fender? (and (pair? rest-clause) (pair? (cdr rest-clause)))]
                  [fender (if has-fender? (car rest-clause) #t)]
                  [body (if has-fender? (cadr rest-clause) (car rest-clause))]
                  [compiled-body (gerbil-compile-expression body)]
                  [compiled-fender (if (eq? fender #t) #t (gerbil-compile-expression fender))]
                  [fail-var (gensym "csc-E")]
                  [fail-body (compile-csc-clauses target kws rest)])
             `(let ([,fail-var (lambda () ,fail-body)])
                ,(compile-csc-match target pat kws
                   (if (eq? compiled-fender #t)
                     compiled-body
                     `(if ,compiled-fender ,compiled-body (,fail-var)))
                   `(,fail-var))))]
          [else
           `(error "Bad core-syntax-case clause")]))))

  (define (compile-csc-match target pat kws success fail)
    (cond
      ;; Wildcard _
      [(and (symbol? pat) (eq? pat '_))
       success]
      ;; Symbol in kws list (keyword identifier match)
      [(and (symbol? pat) (csc-in-kws? pat kws))
       `(if (and (identifier? ,target) (core-identifier=? ,target ',pat))
          ,success ,fail)]
      ;; Variable binding (symbol not in kws, not _)
      [(symbol? pat)
       `(let ([,pat ,target]) ,success)]
      ;; Keyword-object literal (Gerbil keyword like phi:, begin:, etc.)
      [(|##keyword?| pat)
       (let ([kw-name (|##keyword->string| pat)])
         (let ([kv (gensym "csc-kv")])
           `(let ([,kv (stx-e ,target)])
              (if (and (keyword? ,kv) (string=? (keyword->string ,kv) ,kw-name))
                ,success ,fail))))]
      ;; Pair pattern (hd . tl)
      [(pair? pat)
       (let* ([hd (car pat)]
              [tl (cdr pat)]
              [$e (gensym "csc-p")]
              [$hd (gensym "csc-h")]
              [$tl (gensym "csc-t")])
         (cond
           ;; Head is a keyword-object (like phi:, begin:)
           [(|##keyword?| hd)
            (let ([kw-name (|##keyword->string| hd)]
                  [kv (gensym "csc-kv")])
              `(if (stx-pair? ,target)
                 (let ([,$e (syntax-e ,target)])
                   (let ([,$hd (car ,$e)] [,$tl (cdr ,$e)])
                     (let ([,kv (stx-e ,$hd)])
                       (if (and (keyword? ,kv) (string=? (keyword->string ,kv) ,kw-name))
                         ,(compile-csc-match `,$tl tl kws success fail)
                         ,fail))))
                 ,fail))]
           ;; Head is in kws (symbol keyword like %#begin)
           [(and (symbol? hd) (csc-in-kws? hd kws))
            `(if (stx-pair? ,target)
               (let ([,$e (syntax-e ,target)])
                 (let ([,$hd (car ,$e)] [,$tl (cdr ,$e)])
                   (if (and (identifier? ,$hd) (core-identifier=? ,$hd ',hd))
                     ,(compile-csc-match `,$tl tl kws success fail)
                     ,fail)))
               ,fail)]
           ;; Regular head: recursively match
           [else
            `(if (stx-pair? ,target)
               (let ([,$e (syntax-e ,target)])
                 (let ([,$hd (car ,$e)] [,$tl (cdr ,$e)])
                   ,(compile-csc-match `,$hd hd kws
                      (compile-csc-match `,$tl tl kws success fail)
                      fail)))
               ,fail)]))]
      ;; Null (end of list)
      [(null? pat)
       `(if (stx-null? ,target) ,success ,fail)]
      ;; Boolean literal
      [(boolean? pat)
       `(if (eq? (stx-e ,target) ,pat) ,success ,fail)]
      ;; Number literal
      [(number? pat)
       `(if (eqv? (stx-e ,target) ,pat) ,success ,fail)]
      ;; String literal
      [(string? pat)
       `(if (equal? (stx-e ,target) ,pat) ,success ,fail)]
      ;; Char literal
      [(char? pat)
       `(if (eq? (stx-e ,target) ,pat) ,success ,fail)]
      [else
       `(error "Unsupported core-syntax-case pattern" ',pat)]))

  (define (csc-in-kws? sym kws)
    (exists (lambda (k)
              (cond
                [(and (symbol? k) (symbol? sym)) (eq? k sym)]
                [(and (|##keyword?| k) (|##keyword?| sym))
                 (string=? (|##keyword->string| k) (|##keyword->string| sym))]
                [else #f]))
            kws))

  ;; --- Sanitize compiled output ---
  ;; Walk compiled S-expression tree and replace keyword-objects with symbols.
  ;; This is needed because match/defrules expansions can embed keyword-object
  ;; records that Chez's reader can't parse back from pretty-printed output.
  (define chez-void-value (chez:void))

  (define (sanitize-compiled form)
    (cond
      [(|##keyword?| form)
       (string->symbol (string-append (|##keyword->string| form) ":"))]
      ;; Handle Chez void (special-value) — replace with (void) call
      [(eq? form chez-void-value) '(void)]
      ;; Handle absent-obj — replace with symbolic reference
      [(absent-obj? form) 'absent-obj]
      ;; Handle gerbil-struct objects — replace with a quoted placeholder
      [(gerbil-struct? form)
       (let ([tag (gerbil-struct-type-tag form)])
         (list 'quote (string->symbol
                        (string-append "#<" (if (and tag (gerbil-struct? tag))
                                              (let ([name (|##structure-ref| tag 2)])
                                                (if (symbol? name) (symbol->string name) "struct"))
                                              "struct") ">"))))]
      [(pair? form)
       (let ([a (sanitize-compiled (car form))]
             [d (sanitize-compiled (cdr form))])
         (if (and (eq? a (car form)) (eq? d (cdr form)))
           form  ;; no change, avoid allocation
           (cons a d)))]
      [(vector? form)
       (let* ([lst (vector->list form)]
              [sanitized (map sanitize-compiled lst)])
         (if (equal? lst sanitized)
           form
           (list->vector sanitized)))]
      ;; Handle other non-printable objects (records, procedures, opaque types)
      [(record? form) (list 'quote (string->symbol "unreadable-record"))]
      [(procedure? form) (list 'quote (string->symbol "unreadable-procedure"))]
      ;; Catch-all: check if the value is writable, replace if not
      [(not (or (symbol? form) (number? form) (string? form)
                (boolean? form) (char? form) (null? form)
                (eq? form chez-void-value)))
       ;; Check if it's writable by attempting to write it
       (let ([writable?
              (guard (exn [#t #f])
                (let ([s (call-with-string-output-port
                           (lambda (p) (write form p)))])
                  ;; Check for #< in the output (unreadable)
                  (not (let lp ([i 0])
                         (and (< i (- (string-length s) 1))
                              (or (and (char=? (string-ref s i) #\#)
                                       (char=? (string-ref s (+ i 1)) #\<))
                                  (lp (+ i 1))))))))])
         (if writable?
           form
           (list 'quote (string->symbol "unreadable-value"))))]
      [else form]))

  ;; --- Body compilation ---
  ;; Handles the R6RS restriction: all defines must come before expressions.
  ;; Gerbil (like Gambit) allows interleaving def and expressions in bodies.
  ;; We convert interleaved defs to letrec* + begin.
  (define (strip-type-annotations forms)
    ;; Strip => type-annotation pairs from body forms
    ;; e.g. (=> :values body...) → (body...)
    (let loop ([forms forms] [result '()])
      (cond
        [(null? forms) (reverse result)]
        ;; Bare => symbol followed by type → skip both
        [(and (eq? (car forms) '=>)
              (pair? (cdr forms)))
         (loop (cddr forms) result)]
        ;; (=> type) as a list form → skip
        [(and (pair? (car forms))
              (pair? (cdar forms))
              (eq? (caar forms) '=>))
         (loop (cdr forms) result)]
        [else (loop (cdr forms) (cons (car forms) result))])))

  (define (compile-body body-forms)
    ;; Strip type annotations, then compile
    ;; Ensure body-forms is a proper list
    (let* ([body-forms (if (list? body-forms)
                         (strip-type-annotations body-forms)
                         (strip-type-annotations (list body-forms)))]
           [compiled (map (lambda (f)
                            (if (and (pair? f) (memq (car f) '(def define def* defrules defrule defsyntax)))
                              (gerbil-compile-top f)
                              (gerbil-compile-expression f)))
                          body-forms)])
      ;; Check if defines are interleaved with expressions
      (if (body-needs-rewrite? compiled)
        ;; Rewrite: collect all defines into a letrec*, expressions into begin
        ;; define-syntax forms stay at body level (before letrec*)
        (let-values ([(bindings exprs syntax-defs) (extract-body-bindings compiled)])
          (let ([body-tail
                  (if (null? bindings)
                    (if (null? exprs) '((void)) exprs)
                    (if (null? exprs)
                      `((letrec* ,bindings (void)))
                      `((letrec* ,bindings ,@exprs))))])
            (append syntax-defs body-tail)))
        ;; No interleaving — keep as-is
        compiled)))

  (define (body-needs-rewrite? forms)
    ;; Returns #t if a define appears after an expression
    (let loop ([forms forms] [seen-expr? #f])
      (cond
        [(null? forms) #f]
        [(and (pair? (car forms))
              (memq (car (car forms)) '(define define-values define-syntax)))
         (if seen-expr? #t
             (loop (cdr forms) #f))]
        [(and (pair? (car forms)) (eq? (car (car forms)) 'begin))
         ;; Check inside begin
         (or (body-needs-rewrite? (cdr (car forms)))
             (loop (cdr forms) seen-expr?))]
        [else
         (loop (cdr forms) #t)])))

  (define (extract-body-bindings forms)
    ;; Split compiled forms into (bindings, expressions, syntax-defs)
    ;; bindings = ((name init) ...) for letrec*
    ;; exprs = non-define expressions in order
    ;; syntax-defs = (define-syntax ...) forms that stay at body level
    (let loop ([forms forms] [bindings '()] [exprs '()] [syntax-defs '()])
      (if (null? forms)
        (values (reverse bindings) (reverse exprs) (reverse syntax-defs))
        (let ([form (car forms)])
          (cond
            [(and (pair? form) (eq? (car form) 'define))
             (let ([sig (cadr form)] [body (cddr form)])
               (if (pair? sig)
                 ;; (define (name args...) body...) → (name (lambda (args) body))
                 (loop (cdr forms)
                       (cons `(,(car sig) (lambda ,(cdr sig) ,@body)) bindings)
                       exprs syntax-defs)
                 ;; (define name expr) → (name expr)
                 (loop (cdr forms)
                       (cons `(,sig ,(if (null? body) '(void) (car body))) bindings)
                       exprs syntax-defs)))]
            [(and (pair? form) (eq? (car form) 'define-syntax))
             ;; Keep define-syntax at body level
             (loop (cdr forms) bindings exprs (cons form syntax-defs))]
            [(and (pair? form) (eq? (car form) 'define-values))
             ;; (define-values (a b) expr) — harder, add as expression
             (loop (cdr forms) bindings (cons form exprs) syntax-defs)]
            [(and (pair? form) (eq? (car form) 'begin))
             ;; Flatten begin
             (let-values ([(b e s) (extract-body-bindings (cdr form))])
               (loop (cdr forms)
                     (append (reverse b) bindings)
                     (append (reverse e) exprs)
                     (append (reverse s) syntax-defs)))]
            [else
             (loop (cdr forms) bindings (cons form exprs) syntax-defs)])))))

  ;; --- let compilation ---
  ;; Extract variable name from a possibly-typed binding
  ;; (n :- node) → n, (n : :fixnum) → n, n → n
  (define (binding-var b)
    (cond
      ((symbol? b) b)
      ((and (pair? b) (symbol? (car b))
            (pair? (cdr b))
            (memq (cadr b) '(:- : :?)))
       (car b))
      ((pair? b) (car b))  ;; fallback
      (else b)))

  (define (compile-let head expr)
    (let ((bindings-or-name (cadr expr)))
      (cond
        ;; named let: (let name ((var init) ...) body...)
        ((symbol? bindings-or-name)
         `(let ,bindings-or-name
            ,(map (lambda (b)
                    `(,(binding-var (car b)) ,(gerbil-compile-expression (cadr b))))
                  (caddr expr))
            ,@(compile-body (cdddr expr))))
        ;; Gerbil-style single binding: (let (name init) body...)
        ;; vs R6RS: (let ((name init) ...) body...)
        ((and (pair? bindings-or-name)
              (symbol? (car bindings-or-name))
              (not (pair? (car bindings-or-name))))
         ;; Single binding: (let (x expr) body...) → (let ((x expr)) body...)
         `(,head ((,(car bindings-or-name)
                   ,(gerbil-compile-expression (cadr bindings-or-name))))
                 ,@(compile-body (cddr expr))))
        ;; Standard bindings — may contain (values ...) destructuring
        (else
         (compile-let-bindings head bindings-or-name (cddr expr))))))

  ;; Handle let/let* bindings, converting (values v1 v2 ...) destructuring
  ;; to call-with-values
  (define (compile-let-bindings head bindings body)
    (if (null? bindings)
      `(begin ,@(compile-body body))
      (let ((b (car bindings))
            (rest (cdr bindings)))
        (if (and (pair? (car b))
                 (eq? (caar b) 'values))
          ;; (let* ([(values a b) expr] ...) body)
          ;; → (call-with-values (lambda () expr)
          ;;     (lambda (a b) (let* (...) body)))
          (let ((vars (cdar b))
                (init (gerbil-compile-expression (cadr b))))
            `(call-with-values
               (lambda () ,init)
               (lambda ,vars
                 ,(compile-let-bindings head rest body))))
          (if (and (pair? (car b))
                   (eq? (caar b) '@list))
            ;; (@list k . v) pattern destructuring
            (let* ([pat (cdar b)]
                   [init (gerbil-compile-expression (cadr b))]
                   [tmp (gensym "tmp")]
                   [pat-binds (compile-pattern-bindings (car b) tmp)])
              `(let ([,tmp ,init])
                 (let (,@(map (lambda (p) (list (car p) (cdr p))) pat-binds))
                   ,(compile-let-bindings head rest body))))
          ;; normal binding — strip type annotations from var name
          (if (null? rest)
            `(,head ((,(binding-var (car b)) ,(gerbil-compile-expression (cadr b))))
                    ,@(compile-body body))
            ;; For let*, chain one binding at a time
            (if (eq? head 'let*)
              `(let* ((,(binding-var (car b)) ,(gerbil-compile-expression (cadr b))))
                 ,(compile-let-bindings head rest body))
              ;; For let, collect all normal bindings
              `(,head ,(map (lambda (b)
                              `(,(binding-var (car b)) ,(gerbil-compile-expression (cadr b))))
                            bindings)
                      ,@(compile-body body)))))))))

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
      ((not (pair? expr))
       (cond
         [(|##keyword?| expr)
          (string->symbol (string-append (|##keyword->string| expr) ":"))]
         [(void? expr) '(unquote (|%%void|))]
         [(absent-obj? expr) '(unquote (|%%absent|))]
         [(unbound-obj? expr) '(unquote (|%%unbound|))]
         [else expr]))
      ((and (eq? (car expr) 'unquote) (pair? (cdr expr)))
       (list 'unquote (gerbil-compile-expression (cadr expr))))
      ((and (eq? (car expr) 'unquote-splicing) (pair? (cdr expr)))
       (list 'unquote-splicing (gerbil-compile-expression (cadr expr))))
      (else
       (cons (compile-quasiquote (car expr))
             (compile-quasiquote (cdr expr))))))

  ;; --- match compilation ---
  ;; Translates (match expr (pattern body...) ...) to cond/let chains
  ;; --- defruntime-exception compilation ---
  ;; (defruntime-exception (is? getf ...))
  ;; Generates RuntimeException-aware predicate and accessor wrappers
  (define (compile-defruntime-exception form)
    (let* ([spec (cadr form)]
           [is? (car spec)]
           [getfs (cdr spec)]
           [macro-is? (string->symbol (string-append "macro-" (symbol->string is?)))])
      `(begin
         ;; Predicate wrapper
         (define (,is? exn)
           (if (RuntimeException? exn)
             (let ([e (&RuntimeException-exception exn)])
               (,macro-is? e))
             (,macro-is? exn)))
         ;; Accessor wrappers
         ,@(map (lambda (getf)
                  (let ([macro-getf (string->symbol
                                      (string-append "macro-" (symbol->string getf)))])
                    `(define (,getf exn)
                       (if (RuntimeException? exn)
                         (let ([e (&RuntimeException-exception exn)])
                           (if (,macro-is? e)
                             (,macro-getf e)
                             (error "not an instance" ',is? (list ',getf e))))
                         (if (,macro-is? exn)
                           (,macro-getf exn)
                           (error "not an instance" ',is? (list ',getf exn)))))))
                getfs))))

  ;; --- defcore-forms compilation ---
  ;; (defcore-forms (%#id special: compile-fn) (%#id expr: compile-fn) (%#id) ...)
  ;; → (begin (__core-bind-syntax! 'id __compile-fn maker) ...)
  (define (compile-defcore-forms form)
    (let ([entries (cdr form)])
      `(begin
         ,@(map (lambda (entry)
                  ;; entry is (%#id keyword: compile-fn) or (%#id)
                  ;; The reader may produce keyword objects or quoted symbols
                  (let* ([id (car entry)]
                         [rest (cdr entry)])
                    (cond
                      [(null? rest)
                       ;; (%#id) — compile-error form
                       `(__core-bind-syntax! ',id __compile-error make-__core-form)]
                      [else
                       ;; Parse keyword and compile-fn
                       (let parse ([r rest] [kw #f] [cfn #f])
                         (cond
                           [(null? r)
                            (let* ([eid (string->symbol
                                          (string-append "__" (symbol->string (or cfn 'compile-error))))]
                                   [maker (cond
                                            [(eq? kw 'special) 'make-__core-special-form]
                                            [(eq? kw 'expr) 'make-__core-expression]
                                            [else 'make-__core-form])])
                              `(__core-bind-syntax! ',id ,eid ,maker))]
                           ;; Handle 'special: or 'expr: (quoted keywords from reader)
                           [(and (pair? (car r)) (eq? (caar r) 'quote))
                            (let ([sym (cadar r)])
                              (cond
                                [(or (eq? sym 'special:)
                                     (and (|##keyword?| sym)
                                          (string=? (|##keyword->string| sym) "special")))
                                 (parse (cdr r) 'special cfn)]
                                [(or (eq? sym 'expr:)
                                     (and (|##keyword?| sym)
                                          (string=? (|##keyword->string| sym) "expr")))
                                 (parse (cdr r) 'expr cfn)]
                                [else (parse (cdr r) kw sym)]))]
                           ;; keyword object directly
                           [(|##keyword?| (car r))
                            (let ([kstr (|##keyword->string| (car r))])
                              (parse (cdr r)
                                     (cond [(string=? kstr "special") 'special]
                                           [(string=? kstr "expr") 'expr]
                                           [else kw])
                                     cfn))]
                           ;; Symbol: it's the compile function name
                           [(symbol? (car r))
                            (let ([s (symbol->string (car r))])
                              (cond
                                [(or (string=? s "special:") (string=? s "expr:"))
                                 (parse (cdr r)
                                        (if (string=? s "special:") 'special 'expr)
                                        cfn)]
                                [else (parse (cdr r) kw (car r))]))]
                           [else (parse (cdr r) kw cfn)]))])))
                entries))))

  ;; --- core-ast-case compilation ---
  ;; (core-ast-case expr (kws...) (pattern body) ...)
  ;; Compiles to nested conditionals using __AST-pair?, __AST-e, etc.
  (define (compile-core-ast-case form)
    (let* ([expr-form (cadr form)]
           [kws (caddr form)]
           [clauses (cdddr form)]
           [tmp (gensym "ast-val")])
      `(let ([,tmp ,(gerbil-compile-expression expr-form)])
         ,(compile-ast-clauses tmp kws clauses))))

  (define (compile-ast-clauses tgt kws clauses)
    (if (null? clauses)
      `(,(string->symbol "__raise-syntax-error")
        #f "Bad syntax; malformed ast clause" ,tgt)
      (let* ([clause (car clauses)]
             [rest (cdr clauses)])
        (cond
          ;; (else expr ...)
          [(and (pair? clause) (eq? (car clause) 'else))
           `(begin ,@(map gerbil-compile-expression (cdr clause)))]
          ;; (pattern expr) or (pattern fender expr)
          [(pair? clause)
           (let ([pat (car clause)]
                 [body-forms (cdr clause)]
                 [fail (gensym "fail")])
             `(let ([,fail (lambda ()
                             ,(compile-ast-clauses tgt kws rest))])
                ,(compile-ast-pattern pat tgt
                   (if (= (length body-forms) 1)
                     (gerbil-compile-expression (car body-forms))
                     ;; pattern fender expr
                     (let ([fender (car body-forms)]
                           [expr (cadr body-forms)])
                       `(if ,(gerbil-compile-expression fender)
                          ,(gerbil-compile-expression expr)
                          (,fail))))
                   `(,fail)
                   kws)))]
          [else
           (compile-ast-clauses tgt kws rest)]))))

  (define (compile-ast-pattern pat tgt success fail kws)
    (cond
      ;; Pair pattern: (hd . rest)
      [(pair? pat)
       (let ([hd-pat (car pat)]
             [rest-pat (cdr pat)]
             [etgt (gensym "etgt")]
             [ehd (gensym "ehd")]
             [etl (gensym "etl")])
         `(if (__AST-pair? ,tgt)
            (let* ([,etgt (__AST-e ,tgt)]
                   [,ehd (,(string->symbol "##car") ,etgt)]
                   [,etl (,(string->symbol "##cdr") ,etgt)])
              ,(compile-ast-pattern hd-pat ehd
                 (compile-ast-pattern rest-pat etl success fail kws)
                 fail kws))
            ,fail))]
      ;; Wildcard: _
      [(and (symbol? pat) (eq? pat '_))
       success]
      ;; Keyword: check AST identity match
      [(and (symbol? pat)
            (pair? kws)
            (memq pat kws))
       `(if (and (__AST-id? ,tgt)
                 (eq? (__AST-e ,tgt) ',pat))
          ,success ,fail)]
      ;; Variable binding
      [(symbol? pat)
       `(let ([,pat ,tgt]) ,success)]
      ;; Null pattern: ()
      [(null? pat)
       `(if (null? (__AST-e ,tgt)) ,success ,fail)]
      ;; Literal
      [else
       `(if (equal? (__AST-e ,tgt) ',pat) ,success ,fail)]))

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
            ;; symbol — variable binding (catch-all)
            ((symbol? pattern)
             `(let ((,pattern ,target))
                ,@(map gerbil-compile-expression body)))
            ;; literal (number, string, char, boolean, etc.)
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
    ;; Handle :: rest syntax: [a :: r] → (a . r) cons match
    (cond
      ((null? pats)
       `(if (null? ,target) ,success ,fail))
      ((and (not (pair? pats)) (symbol? pats))
       ;; Rest binding: (... . rest)
       `(let ((,pats ,target)) ,success))
      ;; [a :: r] pattern — :: means "rest of list" (cons destructuring)
      ;; The :: may be a symbol or a keyword-object from the Gerbil reader
      ((and (pair? pats) (pair? (cdr pats))
            (let ([sep (cadr pats)])
              (or (eq? sep '::)
                  (and (|##keyword?| sep)
                       (string=? (|##keyword->string| sep) ":")))))
       (let ((hd-pat (car pats))
             (rest-pat (if (pair? (cddr pats)) (caddr pats) '_))
             (hd-tmp (gensym "hd"))
             (tl-tmp (gensym "tl")))
         `(if (pair? ,target)
            (let ((,hd-tmp (car ,target))
                  (,tl-tmp (cdr ,target)))
              ,(compile-match-pattern hd-tmp hd-pat
                 (compile-match-pattern tl-tmp rest-pat success fail)
                 fail))
            ,fail)))
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
  ;; Helper for (? ...) predicate form
  ;; Recursively handles (not pred), (and p1 p2 ...), (or p1 p2 ...)
  (define (compile-?-apply pred-expr obj-expr)
    (cond
      ;; (? (not pred) obj) → (not (pred obj))
      [(and (pair? pred-expr) (eq? (car pred-expr) 'not)
            (pair? (cdr pred-expr)) (null? (cddr pred-expr)))
       `(not ,(compile-?-apply (cadr pred-expr) obj-expr))]
      ;; (? (and p1 p2 ...) obj) → (and (p1 obj) (p2 obj) ...)
      [(and (pair? pred-expr) (eq? (car pred-expr) 'and))
       `(and ,@(map (lambda (p) (compile-?-apply p obj-expr)) (cdr pred-expr)))]
      ;; (? (or p1 p2 ...) obj) → (or (p1 obj) (p2 obj) ...)
      [(and (pair? pred-expr) (eq? (car pred-expr) 'or))
       `(or ,@(map (lambda (p) (compile-?-apply p obj-expr)) (cdr pred-expr)))]
      ;; simple: (? pred obj) → (pred obj)
      [else
       `(,(gerbil-compile-expression pred-expr) ,obj-expr)]))

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
             ;; Compile the generated call through expression compiler
             ;; to apply rewrites (e.g. rename-file 3-arg → gambit-rename-file)
             `(lambda ,params ,(gerbil-compile-expression call))))
          ((eq? (car rest) '<>)
           (let ((tmp (gensym "cut-arg")))
             (lp (cdr rest) (cons tmp params) (cons tmp call-parts))))
          (else
           (lp (cdr rest) params (cons (gerbil-compile-expression (car rest)) call-parts)))))))

  ;; --- with compilation ---
  ;; Compile a pattern binding from @list or regular list destructuring
  ;; Returns a list of (var . accessor-expr) pairs
  (define (compile-pattern-bindings pat tmp-sym)
    (cond
      ;; (@list k . v) → cons destructuring
      [(and (pair? pat) (eq? (car pat) '@list))
       (let lp ([elems (cdr pat)] [idx 0] [bindings '()])
         (cond
           [(null? elems) (reverse bindings)]
           [(symbol? elems)
            ;; dotted tail: rest of list
            (reverse (cons (cons elems
                            (let loop ([i idx] [e tmp-sym])
                              (if (= i 0) e
                                (loop (- i 1) `(cdr ,e)))))
                          bindings))]
           [(pair? elems)
            (let ([accessor (let loop ([i idx] [e tmp-sym])
                              (if (= i 0) `(car ,e)
                                (loop (- i 1) `(cdr ,e))))])
              (lp (cdr elems) (+ idx 1)
                  (cons (cons (car elems) accessor) bindings)))]
           [else (reverse bindings)]))]
      ;; Regular cons pair: (k . v)
      [(and (pair? pat) (pair? (cdr pat)) (symbol? (cddr pat)))
       (list (cons (car pat) `(car ,tmp-sym))
             (cons (cddr pat) `(cdr ,tmp-sym)))]
      ;; Regular list destructuring
      [else #f]))

  (define (compile-with form)
    ;; (with ((@list k . v) expr) body...) → (let ([k (car expr)] [v (cdr expr)]) body...)
    ;; (with ([a b] expr) body...) → (let-values (((a b) expr)) body...)
    ;; (with (name expr) body...) → (let ((name expr)) body...)
    (let ((binding (cadr form))
          (body (cddr form)))
      (cond
        ;; @list pattern: (with ((@list k . v) expr) body...)
        ;; (car binding) is (@list k . v), (car (car binding)) is @list
        ((and (pair? (car binding))
              (eq? (car (car binding)) '@list))
         (let* ([pat (car binding)]
                [val-expr (gerbil-compile-expression (cadr binding))]
                [tmp (gensym "tmp")]
                [pat-bindings (compile-pattern-bindings pat tmp)])
           `(let ([,tmp ,val-expr])
              (let (,@(map (lambda (p) (list (car p) (cdr p))) pat-bindings))
                ,@(map gerbil-compile-expression body)))))
        ;; Struct destructuring: (with ((type-name f1 f2 ...) obj) body...)
        ;; → extract fields using ##structure-ref
        ((and (pair? (car binding))
              (symbol? (caar binding))
              (not (null? (cdar binding))))
         (let* ([pat (car binding)]
                [type-name (car pat)]
                [fields (cdr pat)]
                [val-expr (gerbil-compile-expression (cadr binding))]
                [tmp (gensym "with-obj")])
           `(let ([,tmp ,val-expr])
              (let (,@(let loop ([fs fields] [idx 1] [binds '()])
                        (if (null? fs)
                          (reverse binds)
                          (let ([f (car fs)])
                            (if (eq? f '_)
                              (loop (cdr fs) (+ idx 1) binds)
                              (loop (cdr fs) (+ idx 1)
                                    (cons `(,f (|##structure-ref| ,tmp ,idx))
                                          binds)))))))
                ,@(map gerbil-compile-expression body)))))
        ;; Regular list destructuring: (with ([a b] expr) body...)
        ((and (pair? (car binding)) (pair? (car (car binding))))
         (let* ([pat (car binding)]
                [val-expr (gerbil-compile-expression (cadr binding))])
           `(let-values (((,@pat) ,val-expr))
              ,@(map gerbil-compile-expression body))))
        (else
         ;; simple: (with (name expr) body...)
         `(let ((,(car binding) ,(gerbil-compile-expression (cadr binding))))
            ,@(map gerbil-compile-expression body))))))

  ;; --- defstruct compilation ---
  ;; Extract field name from a possibly-typed field spec
  ;; e.g., signature → signature, (signature :? !signature) → signature
  (define (field-name f)
    (if (pair? f) (car f) f))

  (define (compile-defstruct form)
    ;; (defstruct name (field1 field2 ...))
    ;; (defstruct (name parent) (field1 field2 ...))
    ;; With optional properties: id:, name:, print:, etc.
    (let* ((name-spec (cadr form))
           (fields-and-props (cddr form))
           (name (if (pair? name-spec) (car name-spec) name-spec))
           (parent (if (pair? name-spec) (cadr name-spec) #f))
           (raw-fields (if (pair? fields-and-props) (car fields-and-props) '()))
           (fields (map field-name (if (list? raw-fields) raw-fields (list raw-fields))))
           (props (if (and (pair? fields-and-props) (pair? (cdr fields-and-props)))
                    (cdr fields-and-props) '())))
      (let* ((type-id (extract-prop 'id: props
                       (string->symbol (string-append "gerbil#" (symbol->string name) "::t"))))
             (type-name (extract-prop 'name: props name))
             (parent-type (if parent
                           (string->symbol (string-append (symbol->string parent) "::t"))
                           #f))
             (parent-ref (if parent-type `(list ,parent-type) `(list object::t))))
        (let* ((struct-props (cons '(struct: . #t)
                                  (compile-class-properties props)))
               (constructor (extract-prop 'constructor: props #f)))
        `(begin
           ;; Create type descriptor
           (define ,(string->symbol (string-append (symbol->string name) "::t"))
             (make-class-type ',type-id ',type-name ,parent-ref
               ',(if (list? fields) fields (list fields))
               ',struct-props
               ',constructor))
           ;; Constructor: use make-instance when constructor: is specified
           ;; (handles :init! method lookup), otherwise direct allocation
           ,(if constructor
              `(define (,(string->symbol (string-append "make-" (symbol->string name))) . args)
                 (apply make-instance ,(string->symbol (string-append (symbol->string name) "::t")) args))
              `(define (,(string->symbol (string-append "make-" (symbol->string name))) . args)
                 (let* ((type ,(string->symbol (string-append (symbol->string name) "::t")))
                        (n (class-type-field-count type))
                        (obj (apply |##structure| type (make-list n #f))))
                   (let lp ((rest args) (i 1))
                     (when (and (pair? rest) (<= i n))
                       (|##structure-set!| obj i (car rest))
                       (lp (cdr rest) (+ i 1))))
                   obj)))
           ;; Predicate
           (define (,(string->symbol (string-append (symbol->string name) "?")) obj)
             (|##structure-instance-of?| obj ',type-id))
           ;; Accessors — use unchecked-slot-ref for compatibility with compiled MOP
           ,@(let lp ((fs fields) (acc '()))
               (if (null? fs)
                 (reverse acc)
                 (lp (cdr fs)
                     (cons `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))))
                                    obj)
                              (unchecked-slot-ref obj ',(car fs)))
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
                              (unchecked-slot-set! obj ',(car fs) val))
                           mut))))
           ;; Unchecked accessors (&name-field)
           ,@(let lp ((fs fields) (acc '()))
               (if (null? fs)
                 (reverse acc)
                 (lp (cdr fs)
                     (cons `(define (,(string->symbol
                                       (string-append "&" (symbol->string name) "-"
                                                      (symbol->string (car fs))))
                                    obj)
                              (unchecked-slot-ref obj ',(car fs)))
                           acc))))
           ;; Unchecked mutators (&name-field-set!)
           ,@(let lp ((fs fields) (mut '()))
               (if (null? fs)
                 (reverse mut)
                 (lp (cdr fs)
                     (cons `(define (,(string->symbol
                                       (string-append "&" (symbol->string name) "-"
                                                      (symbol->string (car fs))
                                                      "-set!"))
                                    obj val)
                              (unchecked-slot-set! obj ',(car fs) val))
                           mut)))))))))

  ;; --- defraise/context compilation ---
  ;; (defraise/context (rule where args ...) (Klass message irritants: irritants))
  ;; → (defrules rule () ((_ where args ...) (raise (Klass message where: 'where irritants: (cons 'where irritants)))))
  (define (compile-defraise/context form)
    (let* ((sig (cadr form))       ;; (rule where args ...)
           (body (caddr form))     ;; (Klass message irritants: irritants)
           (rule-name (car sig))   ;; rule
           (where (cadr sig))      ;; where
           (args (cddr sig))       ;; (args ...)
           (klass (car body))      ;; Klass
           (message (cadr body)))  ;; message
      ;; Generate: (defrules rule () ((_ where args ...) (raise (klass message where: 'where irritants: [args ...]))))
      ;; Simplified: just define a function that raises
      (gerbil-compile-top
        `(def (,rule-name ,where ,@args)
           (raise (,klass ,message where: (quote ,where) irritants: (list (quote ,where) ,@args)))))))

  ;; --- deferror-class compilation ---
  ;; (deferror-class Name () pred?) → (defclass (Name Error) () transparent: #t) + init + pred
  ;; (deferror-class (Name Parent ...) () pred?) → (defclass (Name Parent ...) ...) + init + pred
  ;; (deferror-class Name () pred? kons) → ... with custom constructor
  (define (compile-deferror-class form)
    (let* ((args (cdr form))
           (name-spec (car args))
           ;; Parse: name-spec is either Name or (Name Parent ...)
           (name (if (pair? name-spec) (car name-spec) name-spec))
           (parents (if (pair? name-spec)
                      (cdr name-spec)
                      '(Error)))
           (slots (if (pair? (cdr args)) (cadr args) '()))
           (pred-alias (if (and (pair? (cdr args)) (pair? (cddr args)))
                         (caddr args) #f))
           (kons (if (and (pair? (cdr args)) (pair? (cddr args)) (pair? (cdddr args)))
                   (cadddr args) 'Error:::init!)))
      ;; Compile as defclass + defmethod + optional predicate alias
      (let ((class-form `(defclass (,name ,@parents) ,slots transparent: #t))
            (method-form `(defmethod (:init! ,name) ,kons)))
        `(begin
           ,(gerbil-compile-top class-form)
           ,(gerbil-compile-top method-form)
           ,@(if (and pred-alias (not (eq? pred-alias #f)))
               (let ((pred-name (string->symbol
                                  (string-append (symbol->string name) "?"))))
                 `((define ,pred-alias ,pred-name)))
               '())))))

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
          (let* ((class-props (compile-class-properties props))
                 (constructor (extract-prop 'constructor: props #f)))
          `(begin
             (define ,type-sym
               (make-class-type ',type-id ',type-name ,parent-refs
                 ',(if (list? fields) fields (list fields))
                 ',class-props
                 ',constructor))
             ;; Bare class name as constructor wrapper
             ;; In Gambit, type descriptors are callable; in Chez, they're not.
             ;; Delegate to make-<Name> which handles keyword arg stripping.
             (define (,name . args) (apply ,make-sym args))
             ;; Predicate
             (define (,(string->symbol (string-append (symbol->string name) "?")) obj)
               (|##structure-instance-of?| obj ',type-id))
             ;; Constructor: (make-<name> args...) → delegates to make-instance
             ;; make-instance handles constructor lookup (:init!), keyword dispatch, etc.
             (define (,make-sym . args)
               (apply make-instance ,type-sym args))
             ;; Accessors and mutators for each field (checked + unchecked &prefix)
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
                              (unchecked-slot-ref obj ',(car fs)))
                           `(define (,(string->symbol
                                       (string-append (symbol->string name) "-"
                                                      (symbol->string (car fs))
                                                      "-set!"))
                                    obj val)
                              (unchecked-slot-set! obj ',(car fs) val))
                           `(define (,(string->symbol
                                       (string-append "&" (symbol->string name) "-"
                                                      (symbol->string (car fs))))
                                    obj)
                              (unchecked-slot-ref obj ',(car fs)))
                           `(define (,(string->symbol
                                       (string-append "&" (symbol->string name) "-"
                                                      (symbol->string (car fs))
                                                      "-set!"))
                                    obj val)
                              (unchecked-slot-set! obj ',(car fs) val)))
                         acc))))))))))

  ;; Extract class properties from defclass/defstruct options
  ;; Returns an alist of (key . value) pairs
  (define (compile-class-properties props)
    (let loop ([rest props] [result '()])
      (cond
        [(null? rest) (reverse result)]
        ;; keyword: value pair
        [(and (symbol? (car rest))
              (pair? (cdr rest))
              (let ([s (symbol->string (car rest))])
                (and (> (string-length s) 0)
                     (char=? (string-ref s (- (string-length s) 1)) #\:))))
         (let ([key (car rest)]
               [val (cadr rest)])
           (loop (cddr rest) (cons (cons key val) result)))]
        [(and (|##keyword?| (car rest))
              (pair? (cdr rest)))
         (let ([key (string->symbol
                      (string-append (|##keyword->string| (car rest)) ":"))]
               [val (cadr rest)])
           (loop (cddr rest) (cons (cons key val) result)))]
        [else (loop (cdr rest) result)])))

  ;; --- defmethod compilation ---
  (define (compile-defmethod form)
    ;; (defmethod {name type} body) or (defmethod (name (self type) args...) body...)
    (let ((sig (cadr form))
          (body (cddr form)))
      (cond
        ;; (defmethod {name type} lambda-expr)
        ;; Generates: (begin (define Type::name proc) (bind-method! Type 'name proc))
        ((and (pair? sig) (eq? (car sig) '@method))
         (let* ((name (cadr sig))
                (type-base (caddr sig))
                ;; @method uses bare type name; append ::t for the type descriptor
                (type-str (symbol->string type-base))
                (type (if (and (>= (string-length type-str) 3)
                              (string=? (substring type-str
                                          (- (string-length type-str) 3)
                                          (string-length type-str))
                                        "::t"))
                        type-base
                        (string->symbol (string-append type-str "::t"))))
                (compiled-body (gerbil-compile-expression (car body)))
                (named-binding (string->symbol
                                 (string-append type-str "::"
                                                (symbol->string name)))))
           ;; Also strip interface: and keyword args from body rest
           `(begin
              (define ,named-binding ,compiled-body)
              (bind-method! ,type ',name ,named-binding))))
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
           `(bind-method! ,type-sym ',method-name
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
         ;; Interface name as constructor (identity for duck typing)
         (define (,name obj) obj)
         ;; Predicate (duck-typing: anything can satisfy an interface)
         (define (,(string->symbol (string-append name-str "?")) obj)
           (and (|##structure?| obj) #t))
         ;; Satisfies predicate
         (define (,(string->symbol (string-append "is-" name-str "?")) obj)
           (and (|##structure?| obj) #t))
         ;; Constructor (identity for duck typing)
         (define ,(string->symbol (string-append "make-" name-str)) ,name)
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

  ;; Strip (declare ...) forms from macro templates
  (define (clean-defrule-template tmpl)
    (cond
      [(not (pair? tmpl))
       (cond
         [(|##keyword?| tmpl)
          (string->symbol (string-append (|##keyword->string| tmpl) ":"))]
         [(void? tmpl) '(|%%void|)]
         [(absent-obj? tmpl) '(|%%absent|)]
         [(unbound-obj? tmpl) '(|%%unbound|)]
         [else tmpl])]
      [(and (pair? tmpl) (eq? (car tmpl) 'declare)) '(begin)]
      [(memq (car tmpl) '(let let* letrec letrec* let-values))
       ;; Strip declares from let-style bodies
       (if (and (pair? (cdr tmpl)) (pair? (cadr tmpl)))
         ;; (let bindings body...) or (let name bindings body...)
         (let* ((has-name (symbol? (cadr tmpl)))
                (bindings (if has-name (caddr tmpl) (cadr tmpl)))
                (body (if has-name (cdddr tmpl) (cddr tmpl)))
                (cleaned-body (filter (lambda (f)
                                        (not (and (pair? f) (eq? (car f) 'declare))))
                                      body))
                (cleaned-body (map clean-defrule-template cleaned-body)))
           (if has-name
             `(,(car tmpl) ,(cadr tmpl) ,bindings ,@cleaned-body)
             `(,(car tmpl) ,bindings ,@cleaned-body)))
         tmpl)]
      [(memq (car tmpl) '(begin lambda))
       `(,(car tmpl) ,@(map clean-defrule-template
                            (filter (lambda (f)
                                      (not (and (pair? f) (eq? (car f) 'declare))))
                                    (cdr tmpl))))]
      [else (cons (clean-defrule-template (car tmpl))
                  (clean-defrule-template (cdr tmpl)))]))

  ;; --- defrules compilation ---
  (define (compile-defrules form)
    ;; (defrules name () (pattern template) ...)
    ;; (defrule (name pattern) template)
    (let ((name (if (eq? (car form) 'defrule)
                  (caadr form)   ;; defrule: (defrule (NAME . pattern) template)
                  (cadr form)))) ;; defrules: (defrules NAME (kws) clauses...)
      ;; Skip defrules that define Gerbil-only annotation macros
      (if (eq? name 'declare-inline)
        '(begin)
      (if (eq? (car form) 'defrule)
        ;; (defrule (name . pattern) template)
        (let* ((pattern (cdr (cadr form)))
               (template (clean-defrule-template (caddr form))))
          ;; Register for compile-time expansion
          (register-compile-time-macro! name '()
            (list (list (cons '_ pattern) (caddr form))))
          `(define-syntax ,name
             (syntax-rules ()
               ((,name ,@pattern) ,template))))
        ;; (defrules name (kws...) (pattern [fender] template) ...)
        ;; Clauses with fenders have 3+ elements; without fenders have 2.
        ;; Since syntax-rules doesn't support fenders, skip fender clauses
        ;; and use the non-fender fallback versions.
        (let ((kws (caddr form))
              (clauses (cdddr form)))
          ;; Separate clauses: those with fenders (3+ elements) vs without (exactly 2)
          (let ([non-fender-clauses
                 (filter (lambda (clause) (= (length clause) 2)) clauses)]
                [fender-clauses
                 (filter (lambda (clause) (> (length clause) 2)) clauses)])
            ;; For compile-time expansion, include fender clauses but handle carefully
            ;; For now, register non-fender clauses only
            (register-compile-time-macro! name kws
              (append
                ;; Include fender clauses as-is for compile-time (where fender is ignored)
                (map (lambda (clause)
                       ;; Treat 3-element clause as (pattern template) using last element
                       (list (car clause) (list-ref clause (- (length clause) 1))))
                     fender-clauses)
                non-fender-clauses))
            `(define-syntax ,name
               (syntax-rules ,kws
                 ,@(map (lambda (clause)
                          (let ((pattern (car clause))
                                (template (clean-defrule-template
                                            ;; Use last element as template
                                            (list-ref clause (- (length clause) 1)))))
                            ;; Pattern already includes the macro name as head
                            ;; e.g. (my-when test body ...) — don't add name again
                            `(,(if (pair? pattern) pattern (list name pattern))
                              ,template)))
                        ;; Prefer fender clauses (more specific), then non-fender
                        ;; But since syntax-rules matches first matching pattern,
                        ;; and fender clauses often have same pattern as fallback,
                        ;; just use all clauses with last-element-as-template
                        clauses)))))))))

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

  ;; --- defrefset compilation (Gerbil MOP field accessors) ---
  (define (compile-defrefset form)
    ;; (defrefset (slot field)) →
    ;; Generates checked/unchecked accessor/mutator for class-type fields
    (let* ([pair (cadr form)]
           [slot (car pair)]
           [field (cadr pair)]
           [slot-str (symbol->string slot)]
           [ref-name (string->symbol (string-append "class-type-" slot-str))]
           [&ref-name (string->symbol (string-append "&class-type-" slot-str))]
           [set-name (string->symbol (string-append "class-type-" slot-str "-set!"))]
           [&set-name (string->symbol (string-append "&class-type-" slot-str "-set!"))]
           [struct-ref (string->symbol "##structure-ref")]
           [unchecked-struct-ref (string->symbol "##unchecked-structure-ref")]
           [struct-set! (string->symbol "##structure-set!")]
           [unchecked-struct-set! (string->symbol "##unchecked-structure-set!")])
      `(begin
         (define (,ref-name klass)
           (,struct-ref klass ,field class::t ',slot))
         (define (,&ref-name klass)
           (,unchecked-struct-ref klass ,field class::t ',slot))
         (define (,set-name klass val)
           (,struct-set! klass val ,field class::t ',slot))
         (define (,&set-name klass val)
           (,unchecked-struct-set! klass val ,field class::t ',slot)))))

  ;; --- defpred compilation (Gerbil MOP predicate definitions) ---
  (define (compile-defpred form)
    ;; (defpred (name obj) :- :type body...)
    ;; → (define (name obj) body...)
    ;; The :- and :type are type annotations stripped away
    (let* ([sig (cadr form)]
           [name (car sig)]
           [param (cadr sig)]
           ;; Skip :- and type annotation, find body
           [rest (cddr form)]
           [body (let skip ([r rest])
                   (cond
                     [(null? r) r]
                     [(memq (car r) '(:- =>)) (skip (cddr r))]
                     [(and (symbol? (car r))
                           (let ([s (symbol->string (car r))])
                             (and (> (string-length s) 0)
                                  (char=? (string-ref s 0) #\:))))
                      ;; keyword-like symbol, skip it
                      (skip (cdr r))]
                     [(and (|##keyword?| (car r)))
                      ;; keyword object, skip it and next
                      (skip (cddr r))]
                     [else r]))])
      `(define (,name ,param) ,@(map gerbil-compile-expression body))))

  ;; --- defstruct-type compilation ---
  ;; (defstruct-type type::t (super::t) make-fn pred?
  ;;   id: type-id name: display-name)
  ;; Creates a type descriptor, constructor, and predicate.
  (define (compile-defstruct-type form)
    (let* ([args (cdr form)]
           [type-name (car args)]        ;; e.g. eq-hash-table::t
           [supers-list (cadr args)]     ;; e.g. (hash-table::t)
           [make-fn (caddr args)]        ;; e.g. make-eq-hash-table
           [pred (cadddr args)]          ;; e.g. eq-hash-table?
           ;; Parse keyword args
           [rest (cddddr args)]
           [id-sym (let find-kw ([r rest])
                     (cond
                       [(null? r) type-name]
                       [(or (eq? (car r) 'id:)
                            (and (|##keyword?| (car r))
                                 (string=? (|##keyword->string| (car r)) "id")))
                        (cadr r)]
                       [else (find-kw (cdr r))]))]
           [name-sym (let find-kw ([r rest])
                       (cond
                         [(null? r) type-name]
                         [(or (eq? (car r) 'name:)
                              (and (|##keyword?| (car r))
                                   (string=? (|##keyword->string| (car r)) "name")))
                          (cadr r)]
                         [else (find-kw (cdr r))]))]
           [super (if (null? supers-list) #f (car supers-list))]
           ;; Flags: struct(1024) + concrete(8) + nongenerative(16) = 1048
           [flags 1048])
      `(begin
         ;; Create type descriptor using ##structure ##type-type
         (define ,type-name
           (,(string->symbol "##structure")
            ,(string->symbol "##type-type")
            ',id-sym ',name-sym ,flags ,super '#()))
         ;; Constructor (skip if #f)
         ,@(if make-fn
             `((define (,make-fn . args)
                 (error ',make-fn "not yet implemented for defstruct-type")))
             '())
         ;; Predicate
         (define (,pred obj)
           (and (,(string->symbol "##structure?") obj)
                (let ([t (,(string->symbol "##structure-type") obj)])
                  (or (eq? t ,type-name)
                      (and t (,(string->symbol "##structure?") t)
                           (let walk ([td t])
                             (cond
                               [(not td) #f]
                               [(eq? td ,type-name) #t]
                               [(,(string->symbol "##structure?") td)
                                (walk (,(string->symbol "##type-super") td))]
                               [else #f]))))))))))

  ;; --- set! compilation (handles accessor targets and dot notation) ---
  (define (compile-set! expr)
    ;; (set! (accessor obj) val) → (accessor-set! obj val)
    ;; (set! self.field val) → (slot-set! self 'field val)
    ;; (set! var val) → (set! var val)
    (let ((target (cadr expr))
          (val (caddr expr)))
      (cond
        ;; (set! (accessor obj) val) → (accessor-set! obj val)
        ;; With Gambit→Chez rename: cdr-set! → set-cdr!, car-set! → set-car!
        ((pair? target)
         (let* ((accessor (car target))
                (obj (cadr target))
                (raw-setter (string->symbol
                              (string-append (symbol->string accessor) "-set!")))
                (setter (or (gambit-rename raw-setter) raw-setter)))
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
  ;; Gambit → Chez function rename table
  ;; Maps Gambit/Gerbil function names to their Chez Scheme equivalents
  ;; Gambit → Chez function rename map
  ;; IMPORTANT: Only include names that are genuinely different between Gambit and Chez.
  ;; Do NOT include hash-*, fx*, fl* — these are provided by gambit-compat.sls
  ;; and renaming them would break the expander which uses Gerbil naming internally.
  (define *gambit-rename-map*
    '((cdr-set!              . set-cdr!)
      (car-set!              . set-car!)
      (nonnegative-fixnum?   . fxnonnegative?)
      (random-integer        . random)
      (default-random-source . #f)
      (fxquotient            . fxdiv)
      (fxremainder           . fxmod)
      (fxarithmetic-shift-left  . fxsll)
      (fxarithmetic-shift-right . fxsra)
      ))

  (define (gambit-rename sym)
    (let ((entry (assq sym *gambit-rename-map*)))
      (and entry (cdr entry))))

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
                    ((char=? (string-ref s i) #\.)
                     ;; Found a dot — check that the right side isn't a file extension.
                     ;; Symbols like gerbil.pkg, module.ss are variable names, not field access.
                     (let ((right (substring s (+ i 1) (string-length s))))
                       (not (member right
                              '("pkg" "ss" "sls" "scm" "sld" "md" "txt" "json" "xml"
                                "yml" "yaml" "toml" "cfg" "ini" "log" "csv" "html"
                                "c" "h" "o" "a" "so" "ssi")))))
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
    (let ((req (append (required-params params) (required-keyword-params params)))
          (opts (optional-params params))
          (rest (rest-param params)))
      ;; Generate case-lambda with clauses for each arity
      ;; Clause for N required args (all optionals use defaults)
      ;; Clause for N+1 (first optional supplied) etc.
      ;; Clause for N+M (all optionals supplied)
      (let ((compiled-body (compile-body body)))
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
    ;; Resolves relative paths using *current-source-dir*
    (let ((path (cadr form)))
      (if (string? path)
        (let ((resolved
                (if (and (> (string-length path) 0)
                         (char=? (string-ref path 0) #\/))
                  path  ;; absolute path
                  (let ((dir (*current-source-dir*)))
                    (if (string=? dir "")
                      path
                      (string-append dir "/" path))))))
          (guard (exn
                   [#t `(begin)]) ;; silently skip if file not found
            (let ((forms (read-all-forms resolved)))
              ;; Compile each form individually — skip failures
              `(begin ,@(filter-map
                          (lambda (f)
                            (guard (exn [#t #f])
                              (gerbil-compile-top f)))
                          forms)))))
        `(begin))))

  ;; --- defvalues compilation ---
  ;; --- defmutable / defmutable* compilation ---
  (define (compile-defmutable form)
    ;; (defmutable* name init : type) or (defmutable* name init)
    ;; → (begin (define __name init) (define (name) __name) (define (name-set! v) (set! __name v)))
    ;; (defmutable name init : type) — same but with identifier-rules
    ;; For simplicity, compile both the same way
    (let* ((rest (cdr form))
           (name (car rest))
           (init-and-rest (cdr rest))
           ;; Find the init expression (skip type annotations)
           (init (if (null? init-and-rest)
                   '(void)
                   (car init-and-rest)))
           (internal-name (string->symbol (string-append "__" (symbol->string name))))
           (setter-name (string->symbol (string-append (symbol->string name) "-set!"))))
      `(begin
         (define ,internal-name ,(gerbil-compile-expression init))
         (define (,name) ,internal-name)
         (define (,setter-name v) (set! ,internal-name v)))))

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
              `(begin ,@(map gerbil-compile-top body)))
             ((cond-expand-feature? feature)
              `(begin ,@(map gerbil-compile-top body)))
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
  ;; Keep spawn as a function call — the target compat layer provides it.
  ;; spawn already creates and starts a thread, so no need to expand to
  ;; thread-start!/make-thread (which may not be available in all compat layers).
  (define (compile-spawn form)
    ;; (spawn expr) → (spawn (lambda () expr))
    ;; (spawn thunk) → (spawn thunk)
    ;; (spawn proc arg...) → (spawn (lambda () (proc arg...)))
    (let ((args (cdr form)))
      (if (= (length args) 1)
        (let ((arg (car args)))
          (if (and (pair? arg) (memq (car arg) '(lambda #%lambda)))
            ;; Already a lambda — use directly
            `(spawn ,(gerbil-compile-expression arg))
            ;; Wrap in thunk
            `(spawn (lambda () ,(gerbil-compile-expression arg)))))
        ;; Multiple args: (spawn proc arg1 arg2...) → wrap in thunk
        `(spawn
           (lambda ()
             (,(gerbil-compile-expression (car args))
              ,@(map gerbil-compile-expression (cdr args))))))))

  (define (compile-spawn/name form)
    ;; spawn/name not available in all compat layers — compile as spawn
    ;; (spawn/name name expr) → (spawn (lambda () expr))
    (let ((name (gerbil-compile-expression (cadr form)))
          (args (cddr form)))
      (if (= (length args) 1)
        (let ((arg (car args)))
          (if (and (pair? arg) (memq (car arg) '(lambda #%lambda)))
            `(spawn ,(gerbil-compile-expression arg))
            `(spawn (lambda () ,(gerbil-compile-expression arg)))))
        `(spawn
           (lambda ()
             (,(gerbil-compile-expression (car args))
              ,@(map gerbil-compile-expression (cdr args))))))))

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
             ,@(compile-body body))))))

  (define (compile-lambda-with-optionals params body)
    (let ((req (append (required-params params) (required-keyword-params params)))
          (opts (optional-params params))
          (rest (rest-param params)))
      (let ((compiled-body (compile-body body)))
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
    ;; Strip keyword args since make-hash-table uses positional case-lambda.
    (cons (gerbil-compile-expression head)
          (strip-keyword-args (cdr expr))))

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
  ;; Gerbil's `using` has several forms:
  ;; 1. (using (var :- Type) body...) — single binding, var refers to itself
  ;; 2. (using (var expr :- Type) body...) — single binding with init expr
  ;; 3. (using ((var1 expr1 :- T1) (var2 expr2 :- T2) ...) body...) — multiple bindings
  ;; 4. (using (n :- Type) body...) — just type assertion, var = var
  ;; All type annotations are stripped; compiled as let bindings.
  (define (compile-using form)
    (let ((spec (cadr form))
          (body (cddr form)))
      ;; Determine if it's a single binding or multiple bindings
      ;; Multiple: ((var1 ...) (var2 ...)) — first element is a list
      ;; Single: (var :- Type ...) — first element is a symbol
      (if (and (pair? spec) (pair? (car spec)) (not (symbol? (car spec))))
        ;; Multiple bindings
        (let ((bindings (map compile-using-binding spec)))
          `(let ,bindings
             ,@(compile-body body)))
        ;; Single binding
        (let ((binding (compile-using-binding spec)))
          `(let (,binding)
             ,@(compile-body body))))))

  ;; Parse a single using binding spec into (var expr)
  ;; Formats: (var :- Type), (var expr :- Type), (var expr), (var)
  (define (compile-using-binding spec)
    (cond
      ;; (var) — identity
      ((and (pair? spec) (null? (cdr spec)))
       (list (car spec) (gerbil-compile-expression (car spec))))
      ;; (var :- Type) — var binds to itself
      ((and (pair? spec) (symbol? (car spec))
            (pair? (cdr spec)) (memq (cadr spec) '(:- : :?)))
       (list (car spec) (gerbil-compile-expression (car spec))))
      ;; (var expr :- Type) — var binds to expr, type stripped
      ((and (pair? spec) (symbol? (car spec))
            (pair? (cdr spec)) (pair? (cddr spec))
            (memq (caddr spec) '(:- : :?)))
       (list (car spec) (gerbil-compile-expression (cadr spec))))
      ;; (var expr) — plain binding
      ((and (pair? spec) (symbol? (car spec)) (pair? (cdr spec)))
       (list (car spec) (gerbil-compile-expression (cadr spec))))
      ;; Fallback — identity
      ((symbol? spec)
       (list spec spec))
      (else
       (list (car spec) (gerbil-compile-expression (car spec))))))

  ;; --- @method compilation ---
  (define (compile-at-method form)
    ;; Three forms:
    ;; 1. (@method obj.method) — dotted name, no args → (slot-ref obj 'method)
    ;; 2. (@method method-name obj) — field access → (slot-ref obj 'method-name)
    ;; 3. (@method method-name obj args...) — method call → (call-method obj 'method args)
    (cond
      [(and (= (length form) 2) (symbol? (cadr form)))
       ;; Dotted name form: (@method obj.method) → split on dot
       (let* ([name (symbol->string (cadr form))]
              [dot-pos (let loop ([i (- (string-length name) 1)])
                         (cond [(< i 0) #f]
                               [(char=? (string-ref name i) #\.) i]
                               [else (loop (- i 1))]))])
         (if dot-pos
           (let ([obj (string->symbol (substring name 0 dot-pos))]
                 [method (string->symbol (substring name (+ dot-pos 1) (string-length name)))])
             `(slot-ref ,(gerbil-compile-expression obj) ',method))
           ;; No dot — treat as a symbol reference
           (gerbil-compile-expression (cadr form))))]
      [(null? (cdddr form))
       ;; Method call with no args: (@method method-name obj) → (call-method obj 'method-name)
       (let ([method-name (cadr form)]
             [obj (caddr form)])
         `(call-method ,(gerbil-compile-expression obj) ',method-name))]
      [else
       ;; Method call: (@method method-name obj args...) → (call-method obj 'method args)
       (let ([method-name (cadr form)]
             [obj (caddr form)]
             [args (cdddr form)])
         `(call-method ,(gerbil-compile-expression obj) ',method-name
                       ,@(map gerbil-compile-expression args)))]))

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
  ;; Match a property key against a keyword symbol like constructor:
  ;; Handles both keyword symbols and Gerbil keyword objects
  (define (prop-key-match? key candidate)
    (or (eq? candidate key)
        ;; Match keyword object against keyword symbol:
        ;; key = constructor: (symbol), candidate = #[keyword-object "constructor"]
        (and (|##keyword?| candidate) (symbol? key)
             (let ((ks (symbol->string key)))
               (and (fx> (string-length ks) 1)
                    (char=? (string-ref ks (fx- (string-length ks) 1)) #\:)
                    (string=? (|##keyword->string| candidate)
                              (substring ks 0 (fx- (string-length ks) 1))))))))

  (define (extract-prop key props default)
    (cond
      ((null? props) default)
      ((and (pair? (car props)) (prop-key-match? key (caar props)))
       (cdar props))
      ((and (pair? props) (prop-key-match? key (car props)) (pair? (cdr props)))
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
      (:gerbil/gambit   . #f)  ;; stripped — Gambit primitives handled by compiler
      (:gerbil/gambit/ports . #f)
      (:gerbil/gambit/bits . #f)
      (:gerbil/gambit/threads . #f)
      (:gerbil/gambit/continuations . #f)
      (:gerbil/gambit/os . #f)
      (:gerbil/gambit/misc . #f)
      (:gerbil/gambit/exceptions . #f)
      (:gerbil/gambit/readtables . #f)
      (:gerbil/gambit/fixnum . #f)
      (:gerbil/gambit/flonum . #f)
      (:gerbil/gambit/hash . #f)
      (:gerbil/gambit/exact . #f)
      (:gerbil/core     . #f)  ;; stripped — core forms handled by compiler
      (:gerbil/expander  . #f)
      (:std/values       . (compat std-values))
      (:std/misc/func   . #f)  ;; stripped — identity, compose, etc. handled inline
      (:std/misc/deque   . #f)  ;; will be self-hosted
      (:std/misc/pqueue  . #f)  ;; will be self-hosted
      (:std/misc/shuffle . #f)  ;; will be self-hosted
      (:std/misc/walist  . #f)  ;; will be self-hosted
      (:std/misc/atom    . #f)  ;; will be self-hosted
      (:std/misc/timeout . #f)  ;; will be self-hosted
      (:std/misc/lru     . #f)  ;; will be self-hosted
      (:std/misc/rbtree  . #f)  ;; will be self-hosted
      (:std/srfi/8      . #f)  ;; receive — handled by compiler
      (:std/srfi/9      . #f)  ;; define-record-type — use Chez native
      (:std/srfi/14     . #f)  ;; char-sets
      (:std/srfi/41     . #f)  ;; streams
      (:std/srfi/43     . #f)  ;; vector-lib
      (:std/srfi/srfi-support . #f)  ;; stripped
      (:std/hash-table   . #f)  ;; stripped — use Chez native hashtables
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
