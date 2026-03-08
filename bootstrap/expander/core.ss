(define current-expander-context (make-parameter #f))

(define current-expander-marks (make-parameter (list)))

(define current-expander-phi (make-parameter 0))

(define current-expander-path (make-parameter (list)))

(define current-expander-eval (make-parameter #f))

(define current-expander-compile (make-parameter #f))

(define current-expander-module-eval (make-parameter #f))

(define current-expander-module-import (make-parameter #f))

(define current-expander-module-prelude (make-parameter #f))

(define current-expander-allow-rebind? (make-parameter #f))

(define current-expander-compiling? (make-parameter #f))

(define current-compilation-target (make-parameter #f))

(begin
  (define expander-context::t
    (make-class-type 'gerbil\x23;expander-context::t 'expander-context
      (list object::t) '(id table)
      '((struct: . #t) (constructor: . :init!) (print: id)) '#f))
  (define (make-expander-context . args)
    (let* ([type expander-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (expander-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;expander-context::t))
  (define (expander-context-id obj)
    (unchecked-slot-ref obj 'id))
  (define (expander-context-table obj)
    (unchecked-slot-ref obj 'table))
  (define (expander-context-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (expander-context-table-set! obj val)
    (unchecked-slot-set! obj 'table val))
  (define (&expander-context-id obj)
    (unchecked-slot-ref obj 'id))
  (define (&expander-context-table obj)
    (unchecked-slot-ref obj 'table))
  (define (&expander-context-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&expander-context-table-set! obj val)
    (unchecked-slot-set! obj 'table val)))

(begin
  (define root-context::t
    (make-class-type 'gerbil\x23;root-context::t 'root-context
      (list expander-context::t) '() '((struct: . #t)) '#f))
  (define (make-root-context . args)
    (let* ([type root-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (root-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;root-context::t)))

(begin
  (define phi-context::t
    (make-class-type 'gerbil\x23;phi-context::t 'phi-context
      (list expander-context::t) '(super up down)
      '((struct: . #t)) '#f))
  (define (make-phi-context . args)
    (let* ([type phi-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (phi-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;phi-context::t))
  (define (phi-context-super obj)
    (unchecked-slot-ref obj 'super))
  (define (phi-context-up obj) (unchecked-slot-ref obj 'up))
  (define (phi-context-down obj)
    (unchecked-slot-ref obj 'down))
  (define (phi-context-super-set! obj val)
    (unchecked-slot-set! obj 'super val))
  (define (phi-context-up-set! obj val)
    (unchecked-slot-set! obj 'up val))
  (define (phi-context-down-set! obj val)
    (unchecked-slot-set! obj 'down val))
  (define (&phi-context-super obj)
    (unchecked-slot-ref obj 'super))
  (define (&phi-context-up obj) (unchecked-slot-ref obj 'up))
  (define (&phi-context-down obj)
    (unchecked-slot-ref obj 'down))
  (define (&phi-context-super-set! obj val)
    (unchecked-slot-set! obj 'super val))
  (define (&phi-context-up-set! obj val)
    (unchecked-slot-set! obj 'up val))
  (define (&phi-context-down-set! obj val)
    (unchecked-slot-set! obj 'down val)))

(begin
  (define top-context::t
    (make-class-type 'gerbil\x23;top-context::t 'top-context
      (list phi-context::t) '() '((struct: . #t)) '#f))
  (define (make-top-context . args)
    (let* ([type top-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (top-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;top-context::t)))

(begin
  (define module-context::t
    (make-class-type 'gerbil\x23;module-context::t 'module-context
      (list top-context::t) '(ns path import export e code)
      '((struct: . #t)) '#f))
  (define (make-module-context . args)
    (let* ([type module-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (module-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;module-context::t))
  (define (module-context-ns obj)
    (unchecked-slot-ref obj 'ns))
  (define (module-context-path obj)
    (unchecked-slot-ref obj 'path))
  (define (module-context-import obj)
    (unchecked-slot-ref obj 'import))
  (define (module-context-export obj)
    (unchecked-slot-ref obj 'export))
  (define (module-context-e obj) (unchecked-slot-ref obj 'e))
  (define (module-context-code obj)
    (unchecked-slot-ref obj 'code))
  (define (module-context-ns-set! obj val)
    (unchecked-slot-set! obj 'ns val))
  (define (module-context-path-set! obj val)
    (unchecked-slot-set! obj 'path val))
  (define (module-context-import-set! obj val)
    (unchecked-slot-set! obj 'import val))
  (define (module-context-export-set! obj val)
    (unchecked-slot-set! obj 'export val))
  (define (module-context-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (module-context-code-set! obj val)
    (unchecked-slot-set! obj 'code val))
  (define (&module-context-ns obj)
    (unchecked-slot-ref obj 'ns))
  (define (&module-context-path obj)
    (unchecked-slot-ref obj 'path))
  (define (&module-context-import obj)
    (unchecked-slot-ref obj 'import))
  (define (&module-context-export obj)
    (unchecked-slot-ref obj 'export))
  (define (&module-context-e obj) (unchecked-slot-ref obj 'e))
  (define (&module-context-code obj)
    (unchecked-slot-ref obj 'code))
  (define (&module-context-ns-set! obj val)
    (unchecked-slot-set! obj 'ns val))
  (define (&module-context-path-set! obj val)
    (unchecked-slot-set! obj 'path val))
  (define (&module-context-import-set! obj val)
    (unchecked-slot-set! obj 'import val))
  (define (&module-context-export-set! obj val)
    (unchecked-slot-set! obj 'export val))
  (define (&module-context-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&module-context-code-set! obj val)
    (unchecked-slot-set! obj 'code val)))

(begin
  (define prelude-context::t
    (make-class-type 'gerbil\x23;prelude-context::t 'prelude-context
      (list top-context::t) '(path import e) '((struct: . #t))
      '#f))
  (define (make-prelude-context . args)
    (let* ([type prelude-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (prelude-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;prelude-context::t))
  (define (prelude-context-path obj)
    (unchecked-slot-ref obj 'path))
  (define (prelude-context-import obj)
    (unchecked-slot-ref obj 'import))
  (define (prelude-context-e obj) (unchecked-slot-ref obj 'e))
  (define (prelude-context-path-set! obj val)
    (unchecked-slot-set! obj 'path val))
  (define (prelude-context-import-set! obj val)
    (unchecked-slot-set! obj 'import val))
  (define (prelude-context-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&prelude-context-path obj)
    (unchecked-slot-ref obj 'path))
  (define (&prelude-context-import obj)
    (unchecked-slot-ref obj 'import))
  (define (&prelude-context-e obj)
    (unchecked-slot-ref obj 'e))
  (define (&prelude-context-path-set! obj val)
    (unchecked-slot-set! obj 'path val))
  (define (&prelude-context-import-set! obj val)
    (unchecked-slot-set! obj 'import val))
  (define (&prelude-context-e-set! obj val)
    (unchecked-slot-set! obj 'e val)))

(begin
  (define local-context::t
    (make-class-type 'gerbil\x23;local-context::t 'local-context
      (list phi-context::t) '() '((struct: . #t)) '#f))
  (define (make-local-context . args)
    (let* ([type local-context::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (local-context? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;local-context::t)))

(begin
  (define phi-context:::init!
    (case-lambda
      [(self id)
       (let* ([super (current-expander-context)])
         (struct-instance-init! self id (make-hash-table-eq) super))]
      [(self id super)
       (struct-instance-init!
         self
         id
         (make-hash-table-eq)
         super)]))
  (bind-method! phi-context::t ':init! phi-context:::init!))

(begin
  (define local-context:::init!
    (case-lambda
      [(self)
       (let* ([super (current-expander-context)])
         (struct-instance-init!
           self
           (gensym "L")
           (make-hash-table-eq)
           super))]
      [(self super)
       (struct-instance-init!
         self
         (gensym "L")
         (make-hash-table-eq)
         super)]))
  (bind-method!
    local-context::t
    ':init!
    local-context:::init!))

(begin
  (define binding::t
    (make-class-type 'gerbil\x23;binding::t 'binding (list object::t)
      '(id key phi) '((struct: . #t) (transparent: . #t)) '#f))
  (define (make-binding . args)
    (let* ([type binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;binding::t))
  (define (binding-id obj) (unchecked-slot-ref obj 'id))
  (define (binding-key obj) (unchecked-slot-ref obj 'key))
  (define (binding-phi obj) (unchecked-slot-ref obj 'phi))
  (define (binding-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (binding-key-set! obj val)
    (unchecked-slot-set! obj 'key val))
  (define (binding-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&binding-id obj) (unchecked-slot-ref obj 'id))
  (define (&binding-key obj) (unchecked-slot-ref obj 'key))
  (define (&binding-phi obj) (unchecked-slot-ref obj 'phi))
  (define (&binding-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&binding-key-set! obj val)
    (unchecked-slot-set! obj 'key val))
  (define (&binding-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val)))

(begin
  (define runtime-binding::t
    (make-class-type 'gerbil\x23;runtime-binding::t 'runtime-binding
      (list binding::t) '() '((struct: . #t) (transparent: . #t))
      '#f))
  (define (make-runtime-binding . args)
    (let* ([type runtime-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (runtime-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;runtime-binding::t)))

(begin
  (define local-binding::t
    (make-class-type 'gerbil\x23;local-binding::t 'local-binding
      (list runtime-binding::t) '()
      '((struct: . #t) (transparent: . #t)) '#f))
  (define (make-local-binding . args)
    (let* ([type local-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (local-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;local-binding::t)))

(begin
  (define top-binding::t
    (make-class-type 'gerbil\x23;top-binding::t 'top-binding
      (list runtime-binding::t) '()
      '((struct: . #t) (transparent: . #t)) '#f))
  (define (make-top-binding . args)
    (let* ([type top-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (top-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;top-binding::t)))

(begin
  (define module-binding::t
    (make-class-type 'gerbil\x23;module-binding::t 'module-binding
      (list top-binding::t) '(context)
      '((struct: . #t) (transparent: . #t)) '#f))
  (define (make-module-binding . args)
    (let* ([type module-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (module-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;module-binding::t))
  (define (module-binding-context obj)
    (unchecked-slot-ref obj 'context))
  (define (module-binding-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&module-binding-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&module-binding-context-set! obj val)
    (unchecked-slot-set! obj 'context val)))

(begin
  (define extern-binding::t
    (make-class-type 'gerbil\x23;extern-binding::t 'extern-binding
      (list top-binding::t) '()
      '((struct: . #t) (transparent: . #t)) '#f))
  (define (make-extern-binding . args)
    (let* ([type extern-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (extern-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;extern-binding::t)))

(begin
  (define syntax-binding::t
    (make-class-type 'gerbil\x23;syntax-binding::t 'syntax-binding
      (list binding::t) '(e)
      '((struct: . #t) (final: . #t) (transparent: . #t)) '#f))
  (define (make-syntax-binding . args)
    (let* ([type syntax-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (syntax-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;syntax-binding::t))
  (define (syntax-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (syntax-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&syntax-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (&syntax-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val)))

(begin
  (define import-binding::t
    (make-class-type 'gerbil\x23;import-binding::t 'import-binding
      (list binding::t) '(e context weak?)
      '((struct: . #t) (final: . #t) (transparent: . #t)) '#f))
  (define (make-import-binding . args)
    (let* ([type import-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (import-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;import-binding::t))
  (define (import-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (import-binding-context obj)
    (unchecked-slot-ref obj 'context))
  (define (import-binding-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (import-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (import-binding-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (import-binding-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val))
  (define (&import-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (&import-binding-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&import-binding-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (&import-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&import-binding-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&import-binding-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val)))

(begin
  (define alias-binding::t
    (make-class-type 'gerbil\x23;alias-binding::t 'alias-binding
      (list binding::t) '(e)
      '((struct: . #t) (final: . #t) (transparent: . #t)) '#f))
  (define (make-alias-binding . args)
    (let* ([type alias-binding::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (alias-binding? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;alias-binding::t))
  (define (alias-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (alias-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&alias-binding-e obj) (unchecked-slot-ref obj 'e))
  (define (&alias-binding-e-set! obj val)
    (unchecked-slot-set! obj 'e val)))

(begin
  (define expander::t
    (make-class-type 'gerbil\x23;expander::t 'expander
      (list object::t) '(e) '((struct: . #t)) '#f))
  (define (make-expander . args)
    (let* ([type expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;expander::t))
  (define (expander-e obj) (unchecked-slot-ref obj 'e))
  (define (expander-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&expander-e obj) (unchecked-slot-ref obj 'e))
  (define (&expander-e-set! obj val)
    (unchecked-slot-set! obj 'e val)))

(begin
  (define core-expander::t
    (make-class-type 'gerbil\x23;core-expander::t 'core-expander
      (list expander::t) '(id compile-top) '((struct: . #t)) '#f))
  (define (make-core-expander . args)
    (let* ([type core-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (core-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;core-expander::t))
  (define (core-expander-id obj) (unchecked-slot-ref obj 'id))
  (define (core-expander-compile-top obj)
    (unchecked-slot-ref obj 'compile-top))
  (define (core-expander-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (core-expander-compile-top-set! obj val)
    (unchecked-slot-set! obj 'compile-top val))
  (define (&core-expander-id obj)
    (unchecked-slot-ref obj 'id))
  (define (&core-expander-compile-top obj)
    (unchecked-slot-ref obj 'compile-top))
  (define (&core-expander-id-set! obj val)
    (unchecked-slot-set! obj 'id val))
  (define (&core-expander-compile-top-set! obj val)
    (unchecked-slot-set! obj 'compile-top val)))

(begin
  (define expression-form::t
    (make-class-type 'gerbil\x23;expression-form::t 'expression-form
      (list core-expander::t) '() '((struct: . #t)) '#f))
  (define (make-expression-form . args)
    (let* ([type expression-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (expression-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;expression-form::t)))

(begin
  (define special-form::t
    (make-class-type 'gerbil\x23;special-form::t 'special-form
      (list core-expander::t) '() '((struct: . #t)) '#f))
  (define (make-special-form . args)
    (let* ([type special-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (special-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;special-form::t)))

(begin
  (define definition-form::t
    (make-class-type 'gerbil\x23;definition-form::t 'definition-form
      (list special-form::t) '() '((struct: . #t)) '#f))
  (define (make-definition-form . args)
    (let* ([type definition-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (definition-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;definition-form::t)))

(begin
  (define top-special-form::t
    (make-class-type 'gerbil\x23;top-special-form::t 'top-special-form
      (list special-form::t) '() '((struct: . #t)) '#f))
  (define (make-top-special-form . args)
    (let* ([type top-special-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (top-special-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;top-special-form::t)))

(begin
  (define module-special-form::t
    (make-class-type 'gerbil\x23;module-special-form::t 'module-special-form
      (list top-special-form::t) '() '((struct: . #t)) '#f))
  (define (make-module-special-form . args)
    (let* ([type module-special-form::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (module-special-form? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;module-special-form::t)))

(begin
  (define feature-expander::t
    (make-class-type 'gerbil\x23;feature-expander::t 'feature-expander
      (list expander::t) '() '((struct: . #t)) '#f))
  (define (make-feature-expander . args)
    (let* ([type feature-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (feature-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;feature-expander::t)))

(begin
  (define private-feature-expander::t
    (make-class-type 'gerbil\x23;private-feature-expander::t
      'private-feature-expander (list feature-expander::t) '()
      '((struct: . #t)) '#f))
  (define (make-private-feature-expander . args)
    (let* ([type private-feature-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (private-feature-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;private-feature-expander::t)))

(begin
  (define reserved-expander::t
    (make-class-type 'gerbil\x23;reserved-expander::t 'reserved-expander
      (list expander::t) '() '((struct: . #t)) '#f))
  (define (make-reserved-expander . args)
    (let* ([type reserved-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (reserved-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;reserved-expander::t)))

(begin
  (define macro-expander::t
    (make-class-type 'gerbil\x23;macro-expander::t
      'macro-expander (list expander::t) '() '((struct: . #t))
      '#f))
  (define (make-macro-expander . args)
    (let* ([type macro-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (macro-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;macro-expander::t)))

(begin
  (define rename-macro-expander::t
    (make-class-type 'gerbil\x23;rename-macro-expander::t 'rename-macro-expander
      (list macro-expander::t) '() '((struct: . #t)) '#f))
  (define (make-rename-macro-expander . args)
    (let* ([type rename-macro-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (rename-macro-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;rename-macro-expander::t)))

(begin
  (define user-expander::t
    (make-class-type 'gerbil\x23;user-expander::t 'user-expander
      (list macro-expander::t) '(context phi) '((struct: . #t))
      '#f))
  (define (make-user-expander . args)
    (let* ([type user-expander::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (user-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;user-expander::t))
  (define (user-expander-context obj)
    (unchecked-slot-ref obj 'context))
  (define (user-expander-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (user-expander-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (user-expander-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&user-expander-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&user-expander-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (&user-expander-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&user-expander-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val)))

(begin
  (define expander-mark::t
    (make-class-type 'gerbil\x23;expander-mark::t 'expander-mark
      (list object::t) '(subst context phi trace)
      '((struct: . #t)) '#f))
  (define (make-expander-mark . args)
    (let* ([type expander-mark::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (expander-mark? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;expander-mark::t))
  (define (expander-mark-subst obj)
    (unchecked-slot-ref obj 'subst))
  (define (expander-mark-context obj)
    (unchecked-slot-ref obj 'context))
  (define (expander-mark-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (expander-mark-trace obj)
    (unchecked-slot-ref obj 'trace))
  (define (expander-mark-subst-set! obj val)
    (unchecked-slot-set! obj 'subst val))
  (define (expander-mark-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (expander-mark-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (expander-mark-trace-set! obj val)
    (unchecked-slot-set! obj 'trace val))
  (define (&expander-mark-subst obj)
    (unchecked-slot-ref obj 'subst))
  (define (&expander-mark-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&expander-mark-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (&expander-mark-trace obj)
    (unchecked-slot-ref obj 'trace))
  (define (&expander-mark-subst-set! obj val)
    (unchecked-slot-set! obj 'subst val))
  (define (&expander-mark-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&expander-mark-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&expander-mark-trace-set! obj val)
    (unchecked-slot-set! obj 'trace val)))

(define (raise-syntax-error ctx message stx . details)
  (let ([ctx (cond
               [ctx]
               [(core-context-top) =>
                (lambda (ctx) `(expand ,(expander-context-id ctx)))]
               [else #f])])
    (raise
      (make-syntax-error message (cons stx details) ctx (current-expander-context)
        (current-expander-marks) (current-expander-phi)))))

(define eval-syntax
  (case-lambda
    [(stx)
     (let* ([expression? #f])
       (eval-syntax* (core-expand stx expression?)))]
    [(stx expression?)
     (eval-syntax* (core-expand stx expression?))]))

(define (eval-syntax* stx)
  ((current-expander-eval) ((current-expander-compile) stx)))

(define core-expand
  (case-lambda
    [(stx)
     (let* ([expression? #f])
       (if expression?
           (core-expand-expression stx)
           (core-expand-top stx)))]
    [(stx expression?)
     (if expression?
         (core-expand-expression stx)
         (core-expand-top stx))]))

(define (core-expand-top stx)
  (let ([stx (core-expand* stx)])
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-619} stx])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-620} (lambda ()
                                                      (core-expand-expression
                                                        stx))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-619})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-621} (syntax-e
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-619})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-622} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-621})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-623} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-621})])
                (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-622}])
                  (if (core-bound-identifier? form)
                      stx
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-620})))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-620}))))))

(define (core-expand-expression stx)
  (define (sealed-expression? hd)
    (and (sealed-syntax? hd)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-624} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-625} (lambda ()
                                                           #f)])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-624})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-626} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-624})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-627} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-626})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-628} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-626})])
                     (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-627}])
                       (core-bound-identifier?
                         form
                         expression-form-binding?))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-625}))))))
  (define (illegal-expression hd . _)
    (raise-syntax-error
      #f
      "Bad syntax; illegal expression"
      stx
      hd))
  (define (expand-e form hd)
    (let ([bind (if (binding? form)
                    form
                    (resolve-identifier form))])
      (cond
        [(core-expander-binding? bind)
         (core-apply-expander
           (&syntax-binding-e bind)
           (stx-wrap-source hd (stx-source stx)))]
        [(syntax-binding? bind)
         (core-expand-expression
           (core-apply-expander
             (&syntax-binding-e bind)
             (stx-wrap-source hd (stx-source stx))))]
        [else
         (raise-syntax-error
           #f
           "Bad syntax; missing expander"
           stx
           form)])))
  (let ([hd (core-expand-head stx)])
    (cond
      [(sealed-expression? hd) hd]
      [(stx-pair? hd)
       (let* ([form (stx-car hd)])
         (let* ([bind (and (identifier? form)
                           (resolve-identifier form))])
           (cond
             [(or (not bind) (not (core-expander-binding? bind)))
              (expand-e '%%app (cons* '%%app hd))]
             [(eq? (&binding-id bind) '%\x23;begin)
              (core-expand-block* hd illegal-expression)]
             [(expression-form-binding? bind) (expand-e bind hd)]
             [(direct-special-form-binding? bind)
              (core-expand-expression (expand-e bind hd))]
             [else (illegal-expression hd)])))]
      [(core-bound-identifier? hd) (illegal-expression hd)]
      [(identifier? hd) (expand-e '%%ref (list '%%ref hd))]
      [(stx-datum? hd)
       (expand-e '%\x23;quote (list '%\x23;quote hd))]
      [else (illegal-expression hd)])))

(define (core-expand-expression+1 stx)
  (parameterize ([current-expander-phi
                  (fx1+ (current-expander-phi))])
    (let ([stx (core-expand-expression stx)])
      (values stx (eval-syntax* stx)))))

(define core-expand*
  (case-lambda
    [(stx)
     (let* ([stop? false])
       (let lp ([stx stx])
         (if (stop? stx)
             stx
             (let ([rstx (core-expand1 stx)])
               (if (eq? stx rstx) stx (lp rstx))))))]
    [(stx stop?)
     (let lp ([stx stx])
       (if (stop? stx)
           stx
           (let ([rstx (core-expand1 stx)])
             (if (eq? stx rstx) stx (lp rstx)))))]))

(define (core-expand1 stx)
  (define (step hd)
    (let ([bind (resolve-identifier hd)])
      (cond
        [(runtime-binding? bind) stx]
        [(syntax-binding? bind)
         (core-apply-expander (&syntax-binding-e bind) stx)]
        [(not bind) stx]
        [else
         (raise-syntax-error
           #f
           "Bad syntax; no binding for head"
           stx)])))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-629} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-630} (lambda ()
                                                    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-631} (lambda ()
                                                                                                    stx)])
                                                      (let ([hd #{csc-e dpuuv4a3mobea70icwo8nvdax-629}])
                                                        (if (identifier?
                                                              hd)
                                                            (step hd)
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-631})))))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-629})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-632} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-629})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-633} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-632})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-634} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-632})])
              (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-633}])
                (if (identifier? hd)
                    (step hd)
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-630})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-630})))))

(define (core-expand-head stx)
  (define (stop? stx)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-635} stx])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-636} (lambda ()
                                                      #f)])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-635})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-637} (syntax-e
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-635})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-638} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-637})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-639} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-637})])
                (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-638}])
                  (core-bound-identifier? hd))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-636})))))
  (core-expand* stx stop?))

(define core-expand-block
  (case-lambda
    [(stx expand-special)
     (let* ([begin-form '%\x23;begin]
            [expand-e core-expand-expression])
       (define (expand-splice hd body rest r)
         (if (stx-list? body)
             (K (stx-foldr cons rest body) r)
             (raise-syntax-error
               #f
               "Bad syntax; splice body isn't a list"
               stx
               hd)))
       (define (expand-cond-expand hd rest r)
         (K (cons (core-expand-cond-expand% hd) rest) r))
       (define (expand-include hd rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-640} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-641} (lambda ()
                                                           (raise-syntax-error
                                                             #f
                                                             "Bad syntax; invalid syntax-case clause"
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-640}))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-640})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-642} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-640})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-643} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-642})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-644} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-642})])
                     (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-644})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-645} (syntax-e
                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-644})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-646} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-645})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-647} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-645})])
                             (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-646}])
                               (if (stx-null?
                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-647})
                                   (if (stx-string? path)
                                       (let* ([rpath (core-resolve-path
                                                       path
                                                       (stx-source hd))])
                                         (let* ([block (core-expand-include%
                                                         hd
                                                         rpath)])
                                           (let* ([rbody (parameterize ([current-expander-path
                                                                         (cons
                                                                           rpath
                                                                           (current-expander-path))])
                                                           (core-expand-block
                                                             block
                                                             expand-special
                                                             #f
                                                             expand-e))])
                                             (K rest
                                                (fold-right
                                                  cons
                                                  r
                                                  rbody)))))
                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
       (define (expand-expression hd rest r)
         (K rest (cons (expand-e hd) r)))
       (define (K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-648} rest])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-649} (lambda ()
                                                           (if begin-form
                                                               (core-quote-syntax
                                                                 (core-cons
                                                                   begin-form
                                                                   (reverse
                                                                     r))
                                                                 (stx-source
                                                                   stx))
                                                               r))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-648})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-650} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-648})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-651} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-650})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-652} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-650})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-651}])
                       (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-652}])
                         (let ([hd (core-expand-head hd)])
                           (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-653} hd])
                             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-654} (lambda ()
                                                                             (expand-expression
                                                                               hd
                                                                               rest
                                                                               r))])
                               (if (stx-pair?
                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-653})
                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-655} (syntax-e
                                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-653})])
                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-656} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-655})]
                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-657} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-655})])
                                       (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-656}])
                                         (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-657}])
                                           (let ([bind (and (identifier?
                                                              form)
                                                            (resolve-identifier
                                                              form))])
                                             (if (special-form-binding?
                                                   bind)
                                                 (case (&binding-id bind)
                                                   [(%\x23;begin)
                                                    (expand-splice
                                                      hd
                                                      body
                                                      rest
                                                      r)]
                                                   [(%\x23;cond-expand)
                                                    (expand-cond-expand
                                                      hd
                                                      rest
                                                      r)]
                                                   [(%\x23;include)
                                                    (expand-include
                                                      hd
                                                      rest
                                                      r)]
                                                   [else
                                                    (expand-special
                                                      hd
                                                      K
                                                      rest
                                                      r)])
                                                 (expand-expression
                                                   hd
                                                   rest
                                                   r)))))))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-654})))))))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-649})))))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-658} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-659} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-658}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-658})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-660} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-658})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-661} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-660})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-662} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-660})])
                   (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-662}])
                     (if (stx-list? body)
                         (K body (list))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-659})))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-659})))))]
    [(stx expand-special begin-form)
     (let* ([expand-e core-expand-expression])
       (define (expand-splice hd body rest r)
         (if (stx-list? body)
             (K (stx-foldr cons rest body) r)
             (raise-syntax-error
               #f
               "Bad syntax; splice body isn't a list"
               stx
               hd)))
       (define (expand-cond-expand hd rest r)
         (K (cons (core-expand-cond-expand% hd) rest) r))
       (define (expand-include hd rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-640} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-641} (lambda ()
                                                           (raise-syntax-error
                                                             #f
                                                             "Bad syntax; invalid syntax-case clause"
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-640}))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-640})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-642} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-640})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-643} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-642})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-644} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-642})])
                     (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-644})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-645} (syntax-e
                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-644})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-646} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-645})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-647} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-645})])
                             (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-646}])
                               (if (stx-null?
                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-647})
                                   (if (stx-string? path)
                                       (let* ([rpath (core-resolve-path
                                                       path
                                                       (stx-source hd))])
                                         (let* ([block (core-expand-include%
                                                         hd
                                                         rpath)])
                                           (let* ([rbody (parameterize ([current-expander-path
                                                                         (cons
                                                                           rpath
                                                                           (current-expander-path))])
                                                           (core-expand-block
                                                             block
                                                             expand-special
                                                             #f
                                                             expand-e))])
                                             (K rest
                                                (fold-right
                                                  cons
                                                  r
                                                  rbody)))))
                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
       (define (expand-expression hd rest r)
         (K rest (cons (expand-e hd) r)))
       (define (K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-648} rest])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-649} (lambda ()
                                                           (if begin-form
                                                               (core-quote-syntax
                                                                 (core-cons
                                                                   begin-form
                                                                   (reverse
                                                                     r))
                                                                 (stx-source
                                                                   stx))
                                                               r))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-648})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-650} (syntax-e
                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-648})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-651} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-650})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-652} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-650})])
                     (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-651}])
                       (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-652}])
                         (let ([hd (core-expand-head hd)])
                           (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-653} hd])
                             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-654} (lambda ()
                                                                             (expand-expression
                                                                               hd
                                                                               rest
                                                                               r))])
                               (if (stx-pair?
                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-653})
                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-655} (syntax-e
                                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-653})])
                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-656} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-655})]
                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-657} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-655})])
                                       (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-656}])
                                         (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-657}])
                                           (let ([bind (and (identifier?
                                                              form)
                                                            (resolve-identifier
                                                              form))])
                                             (if (special-form-binding?
                                                   bind)
                                                 (case (&binding-id bind)
                                                   [(%\x23;begin)
                                                    (expand-splice
                                                      hd
                                                      body
                                                      rest
                                                      r)]
                                                   [(%\x23;cond-expand)
                                                    (expand-cond-expand
                                                      hd
                                                      rest
                                                      r)]
                                                   [(%\x23;include)
                                                    (expand-include
                                                      hd
                                                      rest
                                                      r)]
                                                   [else
                                                    (expand-special
                                                      hd
                                                      K
                                                      rest
                                                      r)])
                                                 (expand-expression
                                                   hd
                                                   rest
                                                   r)))))))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-654})))))))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-649})))))
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-658} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-659} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-658}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-658})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-660} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-658})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-661} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-660})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-662} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-660})])
                   (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-662}])
                     (if (stx-list? body)
                         (K body (list))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-659})))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-659})))))]
    [(stx expand-special begin-form expand-e)
     (define (expand-splice hd body rest r)
       (if (stx-list? body)
           (K (stx-foldr cons rest body) r)
           (raise-syntax-error
             #f
             "Bad syntax; splice body isn't a list"
             stx
             hd)))
     (define (expand-cond-expand hd rest r)
       (K (cons (core-expand-cond-expand% hd) rest) r))
     (define (expand-include hd rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-640} hd])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-641} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-640}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-640})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-642} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-640})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-643} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-642})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-644} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-642})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-644})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-645} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-644})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-646} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-645})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-647} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-645})])
                           (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-646}])
                             (if (stx-null?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-647})
                                 (if (stx-string? path)
                                     (let* ([rpath (core-resolve-path
                                                     path
                                                     (stx-source hd))])
                                       (let* ([block (core-expand-include%
                                                       hd
                                                       rpath)])
                                         (let* ([rbody (parameterize ([current-expander-path
                                                                       (cons
                                                                         rpath
                                                                         (current-expander-path))])
                                                         (core-expand-block
                                                           block
                                                           expand-special
                                                           #f
                                                           expand-e))])
                                           (K rest
                                              (fold-right cons r rbody)))))
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-641}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-641})))))
     (define (expand-expression hd rest r)
       (K rest (cons (expand-e hd) r)))
     (define (K rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-648} rest])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-649} (lambda ()
                                                         (if begin-form
                                                             (core-quote-syntax
                                                               (core-cons
                                                                 begin-form
                                                                 (reverse
                                                                   r))
                                                               (stx-source
                                                                 stx))
                                                             r))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-648})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-650} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-648})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-651} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-650})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-652} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-650})])
                   (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-651}])
                     (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-652}])
                       (let ([hd (core-expand-head hd)])
                         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-653} hd])
                           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-654} (lambda ()
                                                                           (expand-expression
                                                                             hd
                                                                             rest
                                                                             r))])
                             (if (stx-pair?
                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-653})
                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-655} (syntax-e
                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-653})])
                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-656} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-655})]
                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-657} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-655})])
                                     (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-656}])
                                       (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-657}])
                                         (let ([bind (and (identifier?
                                                            form)
                                                          (resolve-identifier
                                                            form))])
                                           (if (special-form-binding? bind)
                                               (case (&binding-id bind)
                                                 [(%\x23;begin)
                                                  (expand-splice
                                                    hd
                                                    body
                                                    rest
                                                    r)]
                                                 [(%\x23;cond-expand)
                                                  (expand-cond-expand
                                                    hd
                                                    rest
                                                    r)]
                                                 [(%\x23;include)
                                                  (expand-include
                                                    hd
                                                    rest
                                                    r)]
                                                 [else
                                                  (expand-special
                                                    hd
                                                    K
                                                    rest
                                                    r)])
                                               (expand-expression
                                                 hd
                                                 rest
                                                 r)))))))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-654})))))))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-649})))))
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-658} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-659} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; invalid syntax-case clause"
                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-658}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-658})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-660} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-658})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-661} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-660})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-662} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-660})])
                 (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-662}])
                   (if (stx-list? body)
                       (K body (list))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-659})))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-659}))))]))

(define (core-expand-block* stx expand-special)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-663} (core-expand-block
                                                      stx
                                                      expand-special
                                                      #f)])
    (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-663})
        (begin
          (raise-syntax-error #f "Bad syntax; empty block" stx))
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-663})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-664} (car #{match-val dpuuv4a3mobea70icwo8nvdax-663})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-665} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-663})])
              (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-664}])
                (if (null? #{tl dpuuv4a3mobea70icwo8nvdax-665})
                    (begin expr)
                    (let ([body #{match-val dpuuv4a3mobea70icwo8nvdax-663}])
                      (core-quote-syntax
                        (core-cons '%\x23;begin (reverse body))
                        (stx-source stx))))))
            (let ([body #{match-val dpuuv4a3mobea70icwo8nvdax-663}])
              (core-quote-syntax
                (core-cons '%\x23;begin (reverse body))
                (stx-source stx)))))))

(define (core-expand-cond-expand% stx)
  (define (satisfied? condition)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-666} condition])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-667} (lambda ()
                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-668} (lambda ()
                                                                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-669} (lambda ()
                                                                                                                                                      (raise-syntax-error
                                                                                                                                                        #f
                                                                                                                                                        "Bad syntax; invalid syntax-case clause"
                                                                                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-666}))])
                                                                                                        (if (stx-pair?
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-666})
                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-670} (syntax-e
                                                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-666})])
                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-671} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-670})]
                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-672} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-670})])
                                                                                                                (let ([combinator #{csc-h dpuuv4a3mobea70icwo8nvdax-671}])
                                                                                                                  (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-672}])
                                                                                                                    (if (stx-list?
                                                                                                                          body)
                                                                                                                        (case (stx-e
                                                                                                                                combinator)
                                                                                                                          [(not)
                                                                                                                           (not (stx-ormap
                                                                                                                                  satisfied?
                                                                                                                                  body))]
                                                                                                                          [(and)
                                                                                                                           (stx-andmap
                                                                                                                             satisfied?
                                                                                                                             body)]
                                                                                                                          [(or)
                                                                                                                           (stx-ormap
                                                                                                                             satisfied?
                                                                                                                             body)]
                                                                                                                          [(defined)
                                                                                                                           (stx-andmap
                                                                                                                             core-resolve-identifier
                                                                                                                             body)]
                                                                                                                          [else
                                                                                                                           (raise-syntax-error
                                                                                                                             #f
                                                                                                                             "Bad syntax; bad cond-expannd combinator"
                                                                                                                             stx
                                                                                                                             combinator)])
                                                                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-669}))))))
                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-669}))))])
                                                        (if (stx-pair?
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-666})
                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-673} (syntax-e
                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-666})])
                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-674} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-673})]
                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-675} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-673})])
                                                                (if (and (identifier?
                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-674})
                                                                         (core-identifier=?
                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-674}
                                                                           'unquote))
                                                                    (if (stx-pair?
                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-675})
                                                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-676} (syntax-e
                                                                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-675})])
                                                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-677} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-676})]
                                                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-678} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-676})])
                                                                            (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-677}])
                                                                              (if (stx-null?
                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-678})
                                                                                  (parameterize ([current-expander-phi
                                                                                                  (fx1+
                                                                                                    (current-expander-phi))])
                                                                                    (eval-syntax
                                                                                      expr))
                                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-668})))))
                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-668}))
                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-668}))))
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-668}))))])
        (let ([id #{csc-e dpuuv4a3mobea70icwo8nvdax-666}])
          (if (identifier? id)
              (core-bound-identifier? id feature-binding?)
              (#{csc-E dpuuv4a3mobea70icwo8nvdax-667}))))))
  (define (loop rest)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-679} rest])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-680} (lambda ()
                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-681} (lambda ()
                                                                                                      (raise-syntax-error
                                                                                                        #f
                                                                                                        "Bad syntax; invalid syntax-case clause"
                                                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-679}))])
                                                        (if (stx-null?
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-679})
                                                            (list)
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-681}))))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-679})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-682} (syntax-e
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-679})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-683} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-682})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-684} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-682})])
                (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-683}])
                  (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-684}])
                    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-685} hd])
                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-686} (lambda ()
                                                                      (raise-syntax-error
                                                                        #f
                                                                        "Bad syntax; invalid syntax-case clause"
                                                                        #{csc-e dpuuv4a3mobea70icwo8nvdax-685}))])
                        (if (stx-pair?
                              #{csc-e dpuuv4a3mobea70icwo8nvdax-685})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-687} (syntax-e
                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-685})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-688} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-687})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-689} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-687})])
                                (let ([condition #{csc-h dpuuv4a3mobea70icwo8nvdax-688}])
                                  (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-689}])
                                    (cond
                                      [(stx-eq? condition 'else)
                                       (if (stx-null? rest)
                                           body
                                           (raise-syntax-error
                                             #f
                                             "Bad syntax; clauses after else"
                                             stx
                                             hd))]
                                      [(satisfied? condition) body]
                                      [else (loop rest)])))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-686}))))))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-680})))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-690} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-691} (lambda ()
                                                    (raise-syntax-error
                                                      #f
                                                      "Bad syntax; invalid syntax-case clause"
                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-690}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-690})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-692} (syntax-e
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-690})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-693} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-692})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-694} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-692})])
              (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-694}])
                (if (stx-list? clauses)
                    (core-cons 'begin (loop clauses))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-691})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-691})))))

(define core-expand-include%
  (case-lambda
    [(stx)
     (let* ([rpath #f])
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-695} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-696} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Bad syntax; invalid syntax-case clause"
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-695}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-695})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-697} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-695})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-698} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-697})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-699} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-697})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-699})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-700} (syntax-e
                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-699})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-701} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-700})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-702} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-700})])
                           (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-701}])
                             (if (stx-null?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-702})
                                 (if (stx-string? path)
                                     (let ([rpath (or rpath
                                                      (core-resolve-path
                                                        path
                                                        (stx-source
                                                          stx)))])
                                       (if (member
                                             rpath
                                             (current-expander-path))
                                           (raise-syntax-error
                                             #f
                                             "Bad syntax; cyclic expansion"
                                             stx)
                                           (syntax-local-rewrap
                                             (stx-wrap-source
                                               (core-cons
                                                 'begin
                                                 (read-syntax-from-file
                                                   rpath))
                                               (stx-source stx)))))
                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-696}))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-696})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-696}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-696})))))]
    [(stx rpath)
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-695} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-696} (lambda ()
                                                       (raise-syntax-error
                                                         #f
                                                         "Bad syntax; invalid syntax-case clause"
                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-695}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-695})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-697} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-695})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-698} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-697})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-699} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-697})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-699})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-700} (syntax-e
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-699})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-701} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-700})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-702} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-700})])
                         (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-701}])
                           (if (stx-null?
                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-702})
                               (if (stx-string? path)
                                   (let ([rpath (or rpath
                                                    (core-resolve-path
                                                      path
                                                      (stx-source stx)))])
                                     (if (member
                                           rpath
                                           (current-expander-path))
                                         (raise-syntax-error
                                           #f
                                           "Bad syntax; cyclic expansion"
                                           stx)
                                         (syntax-local-rewrap
                                           (stx-wrap-source
                                             (core-cons
                                               'begin
                                               (read-syntax-from-file
                                                 rpath))
                                             (stx-source stx)))))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-696}))
                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-696})))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-696}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-696}))))]))

(define core-apply-expander
  (case-lambda
    [(K stx)
     (let* ([method 'apply-macro-expander])
       (cond
         [(procedure? K)
          (cond
            [(stx-source stx) =>
             (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-703})
               (stx-wrap-source
                 (K stx)
                 #{cut-arg dpuuv4a3mobea70icwo8nvdax-703}))]
            [else (K stx)])]
         [(bound-method-ref K method) =>
          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-704})
            (core-apply-expander
              #{cut-arg dpuuv4a3mobea70icwo8nvdax-704}
              stx
              method))]
         [else
          (raise-syntax-error
            #f
            "Bad syntax; no expander method"
            stx
            method)]))]
    [(K stx method)
     (cond
       [(procedure? K)
        (cond
          [(stx-source stx) =>
           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-703})
             (stx-wrap-source
               (K stx)
               #{cut-arg dpuuv4a3mobea70icwo8nvdax-703}))]
          [else (K stx)])]
       [(bound-method-ref K method) =>
        (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-704})
          (core-apply-expander
            #{cut-arg dpuuv4a3mobea70icwo8nvdax-704}
            stx
            method))]
       [else
        (raise-syntax-error
          #f
          "Bad syntax; no expander method"
          stx
          method)])]))

(begin
  (define expander::apply-macro-expander
    (lambda (self stx)
      (raise-syntax-error
        #f
        "Bad syntax; bottom method for apply-macro-expander"
        stx)))
  (bind-method!
    expander::t
    'apply-macro-expander
    expander::apply-macro-expander))

(begin
  (define macro-expander::apply-macro-expander
    (lambda (self stx)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-705} self])
        (let ([K (\x23;\x23;structure-ref
                   #{with-obj dpuuv4a3mobea70icwo8nvdax-705}
                   1)])
          (core-apply-expander K stx)))))
  (bind-method!
    macro-expander::t
    'apply-macro-expander
    macro-expander::apply-macro-expander))

(begin
  (define core-expander::apply-macro-expander
    (lambda (self stx)
      (if (sealed-syntax? stx)
          stx
          (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-706} self])
            (let ([K (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-706}
                       1)])
              (core-apply-expander K stx))))))
  (bind-method!
    core-expander::t
    'apply-macro-expander
    core-expander::apply-macro-expander))

(begin
  (define top-special-form::apply-macro-expander
    (case-lambda
      [(self stx)
       (let* ([top? top-context?])
         (if (top? (current-expander-context))
             (core-expander::apply-macro-expander self stx)
             (raise-syntax-error #f "Bad syntax; illegal context" stx)))]
      [(self stx top?)
       (if (top? (current-expander-context))
           (core-expander::apply-macro-expander self stx)
           (raise-syntax-error
             #f
             "Bad syntax; illegal context"
             stx))]))
  (bind-method!
    top-special-form::t
    'apply-macro-expander
    top-special-form::apply-macro-expander))

(begin
  (define module-special-form::apply-macro-expander
    (lambda (self stx)
      (top-special-form::apply-macro-expander
        self
        stx
        module-context?)))
  (bind-method!
    module-special-form::t
    'apply-macro-expander
    module-special-form::apply-macro-expander))

(begin
  (define rename-macro-expander::apply-macro-expander
    (lambda (self stx)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-707} self])
        (let ([id (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-707}
                    1)])
          (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-708} stx])
            (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-709} (lambda ()
                                                            (raise-syntax-error
                                                              #f
                                                              "Bad syntax; invalid syntax-case clause"
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-708}))])
              (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-708})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-710} (syntax-e
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-708})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-711} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-710})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-712} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-710})])
                      (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-712}])
                        (core-cons id body))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-709}))))))))
  (bind-method!
    rename-macro-expander::t
    'apply-macro-expander
    rename-macro-expander::apply-macro-expander))

(define core-apply-user-expander
  (case-lambda
    [(self stx)
     (let* ([method 'apply-macro-expander])
       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-713} self])
         (let ([K (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                    1)]
               [ctx (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                      2)]
               [phi (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                      3)])
           (core-apply-user-macro K stx ctx phi method))))]
    [(self stx method)
     (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-713} self])
       (let ([K (\x23;\x23;structure-ref
                  #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                  1)]
             [ctx (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                    2)]
             [phi (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-713}
                    3)])
         (core-apply-user-macro K stx ctx phi method)))]))

(define (core-apply-user-macro K stx ctx phi method)
  (let ([mark (make-expander-mark #f ctx phi stx)])
    (parameterize ([current-expander-marks
                    (cons mark (current-expander-marks))])
      (stx-apply-mark
        (core-apply-expander K (stx-apply-mark stx mark) method)
        mark))))

(begin
  (define user-expander::apply-macro-expander
    core-apply-user-expander)
  (bind-method!
    user-expander::t
    'apply-macro-expander
    user-expander::apply-macro-expander))

(define resolve-identifier
  (case-lambda
    [(stx)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let lp ([bind (core-resolve-identifier stx phi ctx)])
         (cond
           [(import-binding? bind) (lp (&import-binding-e bind))]
           [(alias-binding? bind)
            (lp (core-resolve-identifier
                  (&alias-binding-e bind)
                  phi
                  ctx))]
           [else bind])))]
    [(stx phi)
     (let* ([ctx (current-expander-context)])
       (let lp ([bind (core-resolve-identifier stx phi ctx)])
         (cond
           [(import-binding? bind) (lp (&import-binding-e bind))]
           [(alias-binding? bind)
            (lp (core-resolve-identifier
                  (&alias-binding-e bind)
                  phi
                  ctx))]
           [else bind])))]
    [(stx phi ctx)
     (let lp ([bind (core-resolve-identifier stx phi ctx)])
       (cond
         [(import-binding? bind) (lp (&import-binding-e bind))]
         [(alias-binding? bind)
          (lp (core-resolve-identifier
                (&alias-binding-e bind)
                phi
                ctx))]
         [else bind]))]))

(define bind-identifier!
  (case-lambda
    [(stx val)
     (let* ([rebind? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let ([rebind? (cond
                        [(not rebind?) core-context-rebind?]
                        [(procedure? rebind?) rebind?]
                        [else true])])
         (core-bind! (core-identifier-key stx) val rebind? phi
           ctx)))]
    [(stx val rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let ([rebind? (cond
                        [(not rebind?) core-context-rebind?]
                        [(procedure? rebind?) rebind?]
                        [else true])])
         (core-bind! (core-identifier-key stx) val rebind? phi
           ctx)))]
    [(stx val rebind? phi)
     (let* ([ctx (current-expander-context)])
       (let ([rebind? (cond
                        [(not rebind?) core-context-rebind?]
                        [(procedure? rebind?) rebind?]
                        [else true])])
         (core-bind! (core-identifier-key stx) val rebind? phi
           ctx)))]
    [(stx val rebind? phi ctx)
     (let ([rebind? (cond
                      [(not rebind?) core-context-rebind?]
                      [(procedure? rebind?) rebind?]
                      [else true])])
       (core-bind! (core-identifier-key stx) val rebind? phi
         ctx))]))

(define core-resolve-identifier
  (case-lambda
    [(stx)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (let lp ([e stx] [marks (current-expander-marks)])
         (cond
           [(symbol? e)
            (core-resolve-binding e phi phi ctx (reverse marks))]
           [(identifier-quote? e)
            (core-resolve-binding (&AST-e e) phi 0
              (&syntax-quote-context e) (&syntax-quote-marks e))]
           [(identifier-wrap? e)
            (core-resolve-binding (&AST-e e) phi phi ctx
              (let ([#{f dpuuv4a3mobea70icwo8nvdax-714} apply-mark])
                (fold-left
                  (lambda (#{a dpuuv4a3mobea70icwo8nvdax-715}
                           #{e dpuuv4a3mobea70icwo8nvdax-716})
                    (#{f dpuuv4a3mobea70icwo8nvdax-714}
                      #{e dpuuv4a3mobea70icwo8nvdax-716}
                      #{a dpuuv4a3mobea70icwo8nvdax-715}))
                  (&identifier-wrap-marks e)
                  marks)))]
           [(syntax-wrap? e)
            (lp (&AST-e e) (apply-mark (&syntax-wrap-mark e) marks))]
           [(AST? e) (lp (&AST-e e) marks)]
           [else (raise-syntax-error #f "Bad identifier" stx)])))]
    [(stx phi)
     (let* ([ctx (current-expander-context)])
       (let lp ([e stx] [marks (current-expander-marks)])
         (cond
           [(symbol? e)
            (core-resolve-binding e phi phi ctx (reverse marks))]
           [(identifier-quote? e)
            (core-resolve-binding (&AST-e e) phi 0
              (&syntax-quote-context e) (&syntax-quote-marks e))]
           [(identifier-wrap? e)
            (core-resolve-binding (&AST-e e) phi phi ctx
              (let ([#{f dpuuv4a3mobea70icwo8nvdax-714} apply-mark])
                (fold-left
                  (lambda (#{a dpuuv4a3mobea70icwo8nvdax-715}
                           #{e dpuuv4a3mobea70icwo8nvdax-716})
                    (#{f dpuuv4a3mobea70icwo8nvdax-714}
                      #{e dpuuv4a3mobea70icwo8nvdax-716}
                      #{a dpuuv4a3mobea70icwo8nvdax-715}))
                  (&identifier-wrap-marks e)
                  marks)))]
           [(syntax-wrap? e)
            (lp (&AST-e e) (apply-mark (&syntax-wrap-mark e) marks))]
           [(AST? e) (lp (&AST-e e) marks)]
           [else (raise-syntax-error #f "Bad identifier" stx)])))]
    [(stx phi ctx)
     (let lp ([e stx] [marks (current-expander-marks)])
       (cond
         [(symbol? e)
          (core-resolve-binding e phi phi ctx (reverse marks))]
         [(identifier-quote? e)
          (core-resolve-binding (&AST-e e) phi 0
            (&syntax-quote-context e) (&syntax-quote-marks e))]
         [(identifier-wrap? e)
          (core-resolve-binding (&AST-e e) phi phi ctx
            (let ([#{f dpuuv4a3mobea70icwo8nvdax-714} apply-mark])
              (fold-left
                (lambda (#{a dpuuv4a3mobea70icwo8nvdax-715}
                         #{e dpuuv4a3mobea70icwo8nvdax-716})
                  (#{f dpuuv4a3mobea70icwo8nvdax-714}
                    #{e dpuuv4a3mobea70icwo8nvdax-716}
                    #{a dpuuv4a3mobea70icwo8nvdax-715}))
                (&identifier-wrap-marks e)
                marks)))]
         [(syntax-wrap? e)
          (lp (&AST-e e) (apply-mark (&syntax-wrap-mark e) marks))]
         [(AST? e) (lp (&AST-e e) marks)]
         [else (raise-syntax-error #f "Bad identifier" stx)]))]))

(define (core-resolve-binding id phi src-phi ctx marks)
  (define (resolve ctx src-phi key)
    (let lp ([ctx (core-context-shift ctx phi)]
             [dphi (fx- phi src-phi)])
      (cond
        [(core-context-resolve ctx key)]
        [(fxzero? dphi) #f]
        [(fxpositive? dphi)
         (lp (core-context-shift ctx -1) (fx1- dphi))]
        [else (lp (core-context-shift ctx 1) (fx1+ dphi))])))
  (let lp ([ctx ctx] [src-phi src-phi] [rest marks])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-717} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-717})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-718} (car #{match-val dpuuv4a3mobea70icwo8nvdax-717})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-719} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-717})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-718}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-719}])
                (begin
                  (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-720} hd])
                    (let ([subst (\x23;\x23;structure-ref
                                   #{with-obj dpuuv4a3mobea70icwo8nvdax-720}
                                   1)])
                      (or (let ([key (and subst (hash-get subst id))])
                            (and key (resolve ctx src-phi key)))
                          (lp (&expander-mark-context hd)
                              (&expander-mark-phi hd)
                              rest))))))))
          (begin (resolve ctx src-phi id))))))

(define core-bind!
  (case-lambda
    [(key val)
     (let* ([rebind? false]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (define (update-binding xval)
         (cond
           [(or (rebind? ctx xval val)
                (and (import-binding? xval)
                     (or (&import-binding-weak? xval)
                         (and (binding? val) (not (import-binding? val)))))
                (and (extern-binding? xval)
                     (runtime-binding? val)
                     (eq? (&binding-id val) (&binding-id xval))))
            val]
           [(and (import-binding? val)
                 (or (&import-binding-weak? val)
                     (and (binding? xval)
                          (eq? (&binding-id val) (&binding-id xval)))))
            xval]
           [(and (import-binding? val) (binding? xval))
            (raise-syntax-error #f "Bad binding; import conflict" key
              (list
                (&binding-id val)
                (expander-context-id (&import-binding-context val)))
              (list
                (&binding-id xval)
                (if (import-binding? xval)
                    (expander-context-id (&import-binding-context xval))
                    xval)))]
           [else
            (raise-syntax-error #f "Bad binding; rebind conflict" key
              val xval)]))
       (define (gensubst subst id)
         (let ([eid (gensym
                      (let ([x (if (uninterned-symbol? id) '% id)])
                        (if (symbol? x) (symbol->string x) x)))])
           (hash-put! subst id eid)
           eid))
       (define (subst! key)
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-721} key])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-721})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-722} (car #{match-val dpuuv4a3mobea70icwo8nvdax-721})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-723} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-721})])
                 (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-722}])
                   (let ([mark #{tl dpuuv4a3mobea70icwo8nvdax-723}])
                     (begin
                       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-724} mark])
                         (let ([subst (\x23;\x23;structure-ref
                                        #{with-obj dpuuv4a3mobea70icwo8nvdax-724}
                                        1)])
                           (cond
                             [(not subst)
                              (let ([subst (make-hash-table-eq)])
                                (&expander-mark-subst-set! mark subst)
                                (gensubst subst id))]
                             [(hash-get subst id)]
                             [else (gensubst subst id)])))))))
               (begin key))))
       (core-context-bind!
         (core-context-shift ctx phi)
         (subst! key)
         val
         update-binding))]
    [(key val rebind?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (define (update-binding xval)
         (cond
           [(or (rebind? ctx xval val)
                (and (import-binding? xval)
                     (or (&import-binding-weak? xval)
                         (and (binding? val) (not (import-binding? val)))))
                (and (extern-binding? xval)
                     (runtime-binding? val)
                     (eq? (&binding-id val) (&binding-id xval))))
            val]
           [(and (import-binding? val)
                 (or (&import-binding-weak? val)
                     (and (binding? xval)
                          (eq? (&binding-id val) (&binding-id xval)))))
            xval]
           [(and (import-binding? val) (binding? xval))
            (raise-syntax-error #f "Bad binding; import conflict" key
              (list
                (&binding-id val)
                (expander-context-id (&import-binding-context val)))
              (list
                (&binding-id xval)
                (if (import-binding? xval)
                    (expander-context-id (&import-binding-context xval))
                    xval)))]
           [else
            (raise-syntax-error #f "Bad binding; rebind conflict" key
              val xval)]))
       (define (gensubst subst id)
         (let ([eid (gensym
                      (let ([x (if (uninterned-symbol? id) '% id)])
                        (if (symbol? x) (symbol->string x) x)))])
           (hash-put! subst id eid)
           eid))
       (define (subst! key)
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-721} key])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-721})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-722} (car #{match-val dpuuv4a3mobea70icwo8nvdax-721})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-723} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-721})])
                 (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-722}])
                   (let ([mark #{tl dpuuv4a3mobea70icwo8nvdax-723}])
                     (begin
                       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-724} mark])
                         (let ([subst (\x23;\x23;structure-ref
                                        #{with-obj dpuuv4a3mobea70icwo8nvdax-724}
                                        1)])
                           (cond
                             [(not subst)
                              (let ([subst (make-hash-table-eq)])
                                (&expander-mark-subst-set! mark subst)
                                (gensubst subst id))]
                             [(hash-get subst id)]
                             [else (gensubst subst id)])))))))
               (begin key))))
       (core-context-bind!
         (core-context-shift ctx phi)
         (subst! key)
         val
         update-binding))]
    [(key val rebind? phi)
     (let* ([ctx (current-expander-context)])
       (define (update-binding xval)
         (cond
           [(or (rebind? ctx xval val)
                (and (import-binding? xval)
                     (or (&import-binding-weak? xval)
                         (and (binding? val) (not (import-binding? val)))))
                (and (extern-binding? xval)
                     (runtime-binding? val)
                     (eq? (&binding-id val) (&binding-id xval))))
            val]
           [(and (import-binding? val)
                 (or (&import-binding-weak? val)
                     (and (binding? xval)
                          (eq? (&binding-id val) (&binding-id xval)))))
            xval]
           [(and (import-binding? val) (binding? xval))
            (raise-syntax-error #f "Bad binding; import conflict" key
              (list
                (&binding-id val)
                (expander-context-id (&import-binding-context val)))
              (list
                (&binding-id xval)
                (if (import-binding? xval)
                    (expander-context-id (&import-binding-context xval))
                    xval)))]
           [else
            (raise-syntax-error #f "Bad binding; rebind conflict" key
              val xval)]))
       (define (gensubst subst id)
         (let ([eid (gensym
                      (let ([x (if (uninterned-symbol? id) '% id)])
                        (if (symbol? x) (symbol->string x) x)))])
           (hash-put! subst id eid)
           eid))
       (define (subst! key)
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-721} key])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-721})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-722} (car #{match-val dpuuv4a3mobea70icwo8nvdax-721})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-723} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-721})])
                 (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-722}])
                   (let ([mark #{tl dpuuv4a3mobea70icwo8nvdax-723}])
                     (begin
                       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-724} mark])
                         (let ([subst (\x23;\x23;structure-ref
                                        #{with-obj dpuuv4a3mobea70icwo8nvdax-724}
                                        1)])
                           (cond
                             [(not subst)
                              (let ([subst (make-hash-table-eq)])
                                (&expander-mark-subst-set! mark subst)
                                (gensubst subst id))]
                             [(hash-get subst id)]
                             [else (gensubst subst id)])))))))
               (begin key))))
       (core-context-bind!
         (core-context-shift ctx phi)
         (subst! key)
         val
         update-binding))]
    [(key val rebind? phi ctx)
     (define (update-binding xval)
       (cond
         [(or (rebind? ctx xval val)
              (and (import-binding? xval)
                   (or (&import-binding-weak? xval)
                       (and (binding? val) (not (import-binding? val)))))
              (and (extern-binding? xval)
                   (runtime-binding? val)
                   (eq? (&binding-id val) (&binding-id xval))))
          val]
         [(and (import-binding? val)
               (or (&import-binding-weak? val)
                   (and (binding? xval)
                        (eq? (&binding-id val) (&binding-id xval)))))
          xval]
         [(and (import-binding? val) (binding? xval))
          (raise-syntax-error #f "Bad binding; import conflict" key
            (list
              (&binding-id val)
              (expander-context-id (&import-binding-context val)))
            (list
              (&binding-id xval)
              (if (import-binding? xval)
                  (expander-context-id (&import-binding-context xval))
                  xval)))]
         [else
          (raise-syntax-error #f "Bad binding; rebind conflict" key
            val xval)]))
     (define (gensubst subst id)
       (let ([eid (gensym
                    (let ([x (if (uninterned-symbol? id) '% id)])
                      (if (symbol? x) (symbol->string x) x)))])
         (hash-put! subst id eid)
         eid))
     (define (subst! key)
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-721} key])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-721})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-722} (car #{match-val dpuuv4a3mobea70icwo8nvdax-721})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-723} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-721})])
               (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-722}])
                 (let ([mark #{tl dpuuv4a3mobea70icwo8nvdax-723}])
                   (begin
                     (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-724} mark])
                       (let ([subst (\x23;\x23;structure-ref
                                      #{with-obj dpuuv4a3mobea70icwo8nvdax-724}
                                      1)])
                         (cond
                           [(not subst)
                            (let ([subst (make-hash-table-eq)])
                              (&expander-mark-subst-set! mark subst)
                              (gensubst subst id))]
                           [(hash-get subst id)]
                           [else (gensubst subst id)])))))))
             (begin key))))
     (core-context-bind!
       (core-context-shift ctx phi)
       (subst! key)
       val
       update-binding)]))

(define (core-identifier-key stx)
  (cond
    [(symbol? stx)
     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-725} (current-expander-marks)])
       (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-725})
           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-726} (car #{match-val dpuuv4a3mobea70icwo8nvdax-725})]
                 [#{tl dpuuv4a3mobea70icwo8nvdax-727} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-725})])
             (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-726}])
               (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-727}])
                 (begin (cons stx hd)))))
           (begin stx)))]
    [(identifier? stx)
     (let* ([id (syntax-local-unwrap stx)])
       (let* ([eid (stx-e id)])
         (let* ([marks (stx-identifier-marks* id)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-728} marks])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-728})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-729} (car #{match-val dpuuv4a3mobea70icwo8nvdax-728})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-730} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-728})])
                   (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-729}])
                     (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-730}])
                       (begin (cons eid hd)))))
                 (begin eid))))))]
    [else (raise-syntax-error #f "Bad identifier" stx)]))

(begin (define &phi-context? phi-context?))

(define (core-context-shift ctx phi)
  (define (make-phi super)
    (make-phi-context (gensym "phi") super))
  (define (make-phi/up ctx super)
    (let ([ctx+1 (make-phi super)])
      (&phi-context-up-set! ctx ctx+1)
      (&phi-context-down-set! ctx+1 ctx)
      ctx+1))
  (define (make-phi/down ctx super)
    (let ([ctx-1 (make-phi super)])
      (&phi-context-up-set! ctx-1 ctx)
      (&phi-context-down-set! ctx ctx-1)
      ctx-1))
  (define (shift ctx delta make-delta-context phi K)
    (cond
      [(&phi-context-super ctx) =>
       (lambda (super)
         (let* ([super (K super delta)])
           (let* ([ctx+d (make-delta-context ctx super)])
             (K ctx+d (fx- phi delta)))))]
      [else (error 'gerbil "Bad context" ctx)]))
  (let K ([ctx ctx] [phi phi])
    (cond
      [(fxzero? phi) ctx]
      [(&phi-context? ctx)
       (if (fxpositive? phi)
           (cond
             [(&phi-context-up ctx) =>
              (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-731})
                (K #{cut-arg dpuuv4a3mobea70icwo8nvdax-731} (fx1- phi)))]
             [else (shift ctx 1 make-phi/up phi K)])
           (cond
             [(&phi-context-down ctx) =>
              (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-732})
                (K #{cut-arg dpuuv4a3mobea70icwo8nvdax-732} (fx1+ phi)))]
             [else (shift ctx -1 make-phi/down phi K)]))]
      [else ctx])))

(define (core-context-get ctx key)
  (hash-get (&expander-context-table ctx) key))

(define (core-context-put! ctx key val)
  (hash-put! (&expander-context-table ctx) key val))

(define (core-context-resolve ctx key)
  (let lp ([ctx ctx])
    (cond
      [(core-context-get ctx key)]
      [(and (&phi-context? ctx) (&phi-context-super ctx)) => lp]
      [else #f])))

(define (core-context-bind! ctx key val rebind)
  (cond
    [(core-context-get ctx key) =>
     (lambda (xval) (core-context-put! ctx key (rebind xval)))]
    [else (core-context-put! ctx key val)]))

(define core-context-top
  (case-lambda
    [()
     (let* ([ctx (current-expander-context)]
            [stop? top-context?])
       (let lp ([ctx ctx])
         (cond
           [(stop? ctx) ctx]
           [(phi-context? ctx) (lp (&phi-context-super ctx))]
           [else #f])))]
    [(ctx)
     (let* ([stop? top-context?])
       (let lp ([ctx ctx])
         (cond
           [(stop? ctx) ctx]
           [(phi-context? ctx) (lp (&phi-context-super ctx))]
           [else #f])))]
    [(ctx stop?)
     (let lp ([ctx ctx])
       (cond
         [(stop? ctx) ctx]
         [(phi-context? ctx) (lp (&phi-context-super ctx))]
         [else #f]))]))

(define core-context-root
  (case-lambda
    [()
     (let* ([ctx (current-expander-context)])
       (let lp ([ctx ctx])
         (if (phi-context? ctx) (lp (&phi-context-super ctx)) ctx)))]
    [(ctx)
     (let lp ([ctx ctx])
       (if (phi-context? ctx)
           (lp (&phi-context-super ctx))
           ctx))]))

(define (core-context-rebind? . __rest-args)
  (let* ([ctx (if (> (length __rest-args) 0)
                  (list-ref __rest-args 0)
                  (current-expander-context))])
    (or (current-expander-allow-rebind?)
        (and (top-context? ctx)
             (not (module-context? ctx))
             (not (prelude-context? ctx))))))

(define core-context-namespace
  (case-lambda
    [()
     (let* ([ctx (current-expander-context)])
       (cond
         [(core-context-top ctx) =>
          (lambda (ctx)
            (and (module-context? ctx) (&module-context-ns ctx)))]
         [else #f]))]
    [(ctx)
     (cond
       [(core-context-top ctx) =>
        (lambda (ctx)
          (and (module-context? ctx) (&module-context-ns ctx)))]
       [else #f])]))

(define expander-binding?
  (case-lambda
    [(bind)
     (let* ([is? expander?])
       (and (syntax-binding? bind)
            (is? (&syntax-binding-e bind))))]
    [(bind is?)
     (and (syntax-binding? bind)
          (is? (&syntax-binding-e bind)))]))

(define (core-expander-binding? bind)
  (expander-binding? bind core-expander?))

(define (expression-form-binding? bind)
  (expander-binding? bind expression-form?))

(define (direct-special-form-binding? bind)
  (define (direct-special-form? obj)
    (direct-instance? special-form::t obj))
  (expander-binding? bind direct-special-form?))

(define (special-form-binding? bind)
  (expander-binding? bind special-form?))

(define (feature-binding? bind)
  (define (feature? e)
    (or (feature-expander? e) (module-context? e)))
  (expander-binding? bind feature?))

(define (private-feature-binding? bind)
  (expander-binding? bind private-feature-expander?))

(define core-bound-identifier?
  (case-lambda
    [(id)
     (let* ([bound? core-expander-binding?])
       (and (identifier? id) (bound? (resolve-identifier id))))]
    [(id bound?)
     (and (identifier? id) (bound? (resolve-identifier id)))]))

(define (core-identifier=? x y)
  (define (y=? xid) ((if (list? y) memq eq?) xid y))
  (let ([bind (resolve-identifier x)])
    (if (binding? bind)
        (y=? (&binding-id bind))
        (y=? (stx-e x)))))

(define (core-extern-symbol? e)
  (and (interned-symbol? e)
       (string-index (symbol->string e) #\#)))

(define core-quote-syntax
  (case-lambda
    [(stx)
     (let* ([src #f]
            [ctx (current-expander-context)]
            [marks (current-expander-marks)])
       (if (\x23;\x23;structure? stx)
           (cond
             [(sealed-syntax-unwrap stx)]
             [(identifier? stx)
              (let ([id (stx-unwrap stx marks)])
                (make-syntax-quote
                  (&AST-e id)
                  (or (&AST-source id) src)
                  ctx
                  (&identifier-wrap-marks id)))]
             [else
              (make-syntax-quote
                (stx-e stx)
                (or (stx-source stx) src)
                ctx
                (reverse marks))])
           (make-syntax-quote stx src ctx (reverse marks))))]
    [(stx src)
     (let* ([ctx (current-expander-context)]
            [marks (current-expander-marks)])
       (if (\x23;\x23;structure? stx)
           (cond
             [(sealed-syntax-unwrap stx)]
             [(identifier? stx)
              (let ([id (stx-unwrap stx marks)])
                (make-syntax-quote
                  (&AST-e id)
                  (or (&AST-source id) src)
                  ctx
                  (&identifier-wrap-marks id)))]
             [else
              (make-syntax-quote
                (stx-e stx)
                (or (stx-source stx) src)
                ctx
                (reverse marks))])
           (make-syntax-quote stx src ctx (reverse marks))))]
    [(stx src ctx)
     (let* ([marks (current-expander-marks)])
       (if (\x23;\x23;structure? stx)
           (cond
             [(sealed-syntax-unwrap stx)]
             [(identifier? stx)
              (let ([id (stx-unwrap stx marks)])
                (make-syntax-quote
                  (&AST-e id)
                  (or (&AST-source id) src)
                  ctx
                  (&identifier-wrap-marks id)))]
             [else
              (make-syntax-quote
                (stx-e stx)
                (or (stx-source stx) src)
                ctx
                (reverse marks))])
           (make-syntax-quote stx src ctx (reverse marks))))]
    [(stx src ctx marks)
     (if (\x23;\x23;structure? stx)
         (cond
           [(sealed-syntax-unwrap stx)]
           [(identifier? stx)
            (let ([id (stx-unwrap stx marks)])
              (make-syntax-quote
                (&AST-e id)
                (or (&AST-source id) src)
                ctx
                (&identifier-wrap-marks id)))]
           [else
            (make-syntax-quote
              (stx-e stx)
              (or (stx-source stx) src)
              ctx
              (reverse marks))])
         (make-syntax-quote stx src ctx (reverse marks)))]))

(define (core-cons hd tl) (cons (core-quote-syntax hd) tl))

(define (core-list hd . rest)
  (cons (core-quote-syntax hd) rest))

(define (core-cons* hd . rest)
  (apply cons* (core-quote-syntax hd) rest))

(define core-resolve-path
  (case-lambda
    [(stx-path)
     (let* ([rel #f])
       (let ([path (stx-e stx-path)]
             [reldir (let lp ([relsrc (or (stx-source stx-path) rel)])
                       (cond
                         [(AST? relsrc)
                          (lp (or (stx-source relsrc) (stx-e relsrc)))]
                         [(source-location-path? relsrc)
                          (path-directory (source-location-path relsrc))]
                         [(string? relsrc) (path-directory relsrc)]
                         [(not (null? (current-expander-path)))
                          (path-directory (car (current-expander-path)))]
                         [else (current-directory)]))])
         (gambit-path-expand path (gambit-path-normalize reldir))))]
    [(stx-path rel)
     (let ([path (stx-e stx-path)]
           [reldir (let lp ([relsrc (or (stx-source stx-path) rel)])
                     (cond
                       [(AST? relsrc)
                        (lp (or (stx-source relsrc) (stx-e relsrc)))]
                       [(source-location-path? relsrc)
                        (path-directory (source-location-path relsrc))]
                       [(string? relsrc) (path-directory relsrc)]
                       [(not (null? (current-expander-path)))
                        (path-directory (car (current-expander-path)))]
                       [else (current-directory)]))])
       (gambit-path-expand path (gambit-path-normalize reldir)))]))

(define core-deserialize-mark
  (case-lambda
    [(repr)
     (let* ([ctx (current-expander-context)])
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-733} repr])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-733})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-734} (car #{match-val dpuuv4a3mobea70icwo8nvdax-733})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-735} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-733})])
               (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-734}])
                 (let ([subs #{tl dpuuv4a3mobea70icwo8nvdax-735}])
                   (begin
                     (let ([subst (and (not (null? subs))
                                       (list->hash-table-eq subs))])
                       (make-expander-mark subst ctx phi #f))))))
             (error 'match
               "no matching clause"
               #{match-val dpuuv4a3mobea70icwo8nvdax-733}))))]
    [(repr ctx)
     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-733} repr])
       (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-733})
           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-734} (car #{match-val dpuuv4a3mobea70icwo8nvdax-733})]
                 [#{tl dpuuv4a3mobea70icwo8nvdax-735} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-733})])
             (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-734}])
               (let ([subs #{tl dpuuv4a3mobea70icwo8nvdax-735}])
                 (begin
                   (let ([subst (and (not (null? subs))
                                     (list->hash-table-eq subs))])
                     (make-expander-mark subst ctx phi #f))))))
           (error 'match
             "no matching clause"
             #{match-val dpuuv4a3mobea70icwo8nvdax-733})))]))

(define (syntax-local-rewrap stx)
  (stx-rewrap stx (current-expander-marks)))

(define (syntax-local-unwrap stx)
  (stx-unwrap stx (current-expander-marks)))

(define (syntax-local-introduce stx)
  (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-736} (current-expander-marks)])
    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-736})
        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-737} (car #{match-val dpuuv4a3mobea70icwo8nvdax-736})]
              [#{tl dpuuv4a3mobea70icwo8nvdax-738} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-736})])
          (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-737}])
            (let ([_ #{tl dpuuv4a3mobea70icwo8nvdax-738}])
              (begin (stx-apply-mark stx hd)))))
        (begin stx))))

(define syntax-local-e
  (case-lambda
    [(stx)
     (let* ([E raise-syntax-ref-error])
       (let ([bind (resolve-identifier stx)])
         (if (syntax-binding? bind)
             (&syntax-binding-e bind)
             (E stx))))]
    [(stx E)
     (let ([bind (resolve-identifier stx)])
       (if (syntax-binding? bind)
           (&syntax-binding-e bind)
           (E stx)))]))

(define syntax-local-value
  (case-lambda
    [(stx)
     (let* ([E raise-syntax-ref-error])
       (let ([e (syntax-local-e stx E)])
         (if (expander? e) (expander-e e) e)))]
    [(stx E)
     (let ([e (syntax-local-e stx E)])
       (if (expander? e) (expander-e e) e))]))

(define (raise-syntax-ref-error stx)
  (raise-syntax-error
    #f
    "Bad syntax; not a syntax binding"
    stx))

