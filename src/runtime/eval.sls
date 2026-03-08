#!chezscheme
;;; eval.sls -- Gerbil core evaluation and compilation on Chez Scheme
;;; Provides the core form bindings and compilation dispatch.

(library (runtime eval)
  (export
    ;; core bindings
    __core __core-resolve __core-bind-syntax! __core-bound-id?
    ;; syntax types
    __syntax __syntax? __syntax-e __syntax-id
    __core-form __core-form? __core-form-id __core-form-compile
    __core-expression __core-expression?
    __core-special-form __core-special-form?
    __definition-form __definition-form?
    __top-special-form __top-special-form?
    __module-special-form __module-special-form?
    __feature-expander __feature-expander?
    __macro-expander __macro-expander? __macro-expander-e
    __user-expander __user-expander? __user-expander-e __user-expander-context
    ;; compilation
    __compile
    ;; source
    __SRC
    ;; check-values
    __check-values
    ;; current parameters
    __current-expander __current-compiler __current-path
    )

  (import
    (except (chezscheme) void error error? raise with-exception-handler identifier?
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise)
            (error chez:error) (raise chez:raise))
    ;; gambit-compat not needed: structure ops come from (compat types)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax))

  ;; --- Core binding table ---
  (define __core (make-hash-table-eq))

  ;; --- Syntax types ---
  ;; These are simple structures (not full MOP classes for performance)
  (define __syntax-type
    (make-class-type (string->symbol "gerbil#__syntax") 'syntax-binding (list object::t)
      '(e id) '((struct: . #t)) #f))

  (define (__syntax e id)
    (let ((s (make-class-instance __syntax-type)))
      (|##structure-set!| s 1 e)
      (|##structure-set!| s 2 id)
      s))

  (define (__syntax? x) (|##structure-instance-of?| x (string->symbol "gerbil#__syntax")))
  (define (__syntax-e x) (|##structure-ref| x 1))
  (define (__syntax-id x) (|##structure-ref| x 2))

  ;; Core form type
  (define __core-form-type
    (make-class-type (string->symbol "gerbil#__core-form") '__core-form (list object::t)
      '(id compile) '((struct: . #t)) #f))

  (define (__core-form id compile)
    (let ((f (make-class-instance __core-form-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__core-form? x) (|##structure-instance-of?| x (string->symbol "gerbil#__core-form")))
  (define (__core-form-id x) (|##structure-ref| x 1))
  (define (__core-form-compile x) (|##structure-ref| x 2))

  ;; Core expression type
  (define __core-expression-type
    (make-class-type (string->symbol "gerbil#__core-expression") '__core-expression
      (list object::t) '(id compile) '((struct: . #t)) #f))

  (define (__core-expression id compile)
    (let ((f (make-class-instance __core-expression-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__core-expression? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__core-expression")))

  ;; Core special form
  (define __core-special-form-type
    (make-class-type (string->symbol "gerbil#__core-special-form") '__core-special-form
      (list object::t) '(id compile) '((struct: . #t)) #f))

  (define (__core-special-form id compile)
    (let ((f (make-class-instance __core-special-form-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__core-special-form? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__core-special-form")))

  ;; Definition form
  (define __definition-form-type
    (make-class-type (string->symbol "gerbil#__definition-form") '__definition-form
      (list object::t) '(id compile) '((struct: . #t)) #f))

  (define (__definition-form id compile)
    (let ((f (make-class-instance __definition-form-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__definition-form? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__definition-form")))

  ;; Top special form
  (define __top-special-form-type
    (make-class-type (string->symbol "gerbil#__top-special-form") '__top-special-form
      (list object::t) '(id compile) '((struct: . #t)) #f))

  (define (__top-special-form id compile)
    (let ((f (make-class-instance __top-special-form-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__top-special-form? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__top-special-form")))

  ;; Module special form
  (define __module-special-form-type
    (make-class-type (string->symbol "gerbil#__module-special-form") '__module-special-form
      (list object::t) '(id compile) '((struct: . #t)) #f))

  (define (__module-special-form id compile)
    (let ((f (make-class-instance __module-special-form-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 compile)
      f))

  (define (__module-special-form? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__module-special-form")))

  ;; Feature expander
  (define __feature-expander-type
    (make-class-type (string->symbol "gerbil#__feature-expander") '__feature-expander
      (list object::t) '(id e) '((struct: . #t)) #f))

  (define (__feature-expander id e)
    (let ((f (make-class-instance __feature-expander-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 e)
      f))

  (define (__feature-expander? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__feature-expander")))

  ;; Macro expander
  (define __macro-expander-type
    (make-class-type (string->symbol "gerbil#__macro-expander") '__macro-expander
      (list object::t) '(id e) '((struct: . #t)) #f))

  (define (__macro-expander id e)
    (let ((f (make-class-instance __macro-expander-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 e)
      f))

  (define (__macro-expander? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__macro-expander")))
  (define (__macro-expander-e x) (|##structure-ref| x 2))

  ;; User expander
  (define __user-expander-type
    (make-class-type (string->symbol "gerbil#__user-expander") '__user-expander
      (list object::t) '(id e context) '((struct: . #t)) #f))

  (define (__user-expander id e ctx)
    (let ((f (make-class-instance __user-expander-type)))
      (|##structure-set!| f 1 id)
      (|##structure-set!| f 2 e)
      (|##structure-set!| f 3 ctx)
      f))

  (define (__user-expander? x)
    (|##structure-instance-of?| x (string->symbol "gerbil#__user-expander")))
  (define (__user-expander-e x) (|##structure-ref| x 2))
  (define (__user-expander-context x) (|##structure-ref| x 3))

  ;; --- Core resolution ---
  (define (__core-resolve id)
    (hash-get __core id))

  ;; Accept optional maker arg from defcore-forms (maker wraps expander in class instance)
  ;; During bootstrap we just store the expander directly
  (define __core-bind-syntax!
    (case-lambda
      ((id expander) (hash-put! __core id expander))
      ((id expander maker) (hash-put! __core id expander))))

  (define (__core-bound-id? id)
    (hash-key? __core id))

  ;; --- Compilation dispatch ---
  (define (__compile stx)
    ;; Basic compilation: unwrap AST and return datum
    (stx->datum stx))

  ;; --- Source info ---
  (define (__SRC stx src)
    (if (AST? stx)
      stx
      (make-AST stx src)))

  ;; --- Check values ---
  (define (__check-values obj count)
    ;; In Chez, multiple values are handled differently
    obj)

  ;; --- Current parameters ---
  (define __current-expander (make-parameter #f))
  (define __current-compiler (make-parameter #f))
  (define __current-path (make-parameter #f))

  ) ;; end library
