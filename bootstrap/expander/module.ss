(define __module-registry (make-hash-table))

(define __module-pkg-cache (make-hash-table))

(begin
  (define module-import::t
    (make-class-type 'gerbil\x23;module-import::t 'module-import
      (list object::t) '(source name phi weak?)
      '((struct: . #t) (final: . #t) (print: . #t)) '#f))
  (define (make-module-import . args)
    (let* ([type module-import::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (module-import? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;module-import::t))
  (define (module-import-source obj)
    (unchecked-slot-ref obj 'source))
  (define (module-import-name obj)
    (unchecked-slot-ref obj 'name))
  (define (module-import-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (module-import-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (module-import-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (module-import-name-set! obj val)
    (unchecked-slot-set! obj 'name val))
  (define (module-import-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (module-import-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val))
  (define (&module-import-source obj)
    (unchecked-slot-ref obj 'source))
  (define (&module-import-name obj)
    (unchecked-slot-ref obj 'name))
  (define (&module-import-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (&module-import-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (&module-import-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (&module-import-name-set! obj val)
    (unchecked-slot-set! obj 'name val))
  (define (&module-import-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&module-import-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val)))

(begin
  (define module-export::t
    (make-class-type 'gerbil\x23;module-export::t 'module-export
      (list object::t) '(context key phi name weak?)
      '((struct: . #t) (final: . #t) (transparent: . #t)) '#f))
  (define (make-module-export . args)
    (let* ([type module-export::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (module-export? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;module-export::t))
  (define (module-export-context obj)
    (unchecked-slot-ref obj 'context))
  (define (module-export-key obj)
    (unchecked-slot-ref obj 'key))
  (define (module-export-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (module-export-name obj)
    (unchecked-slot-ref obj 'name))
  (define (module-export-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (module-export-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (module-export-key-set! obj val)
    (unchecked-slot-set! obj 'key val))
  (define (module-export-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (module-export-name-set! obj val)
    (unchecked-slot-set! obj 'name val))
  (define (module-export-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val))
  (define (&module-export-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&module-export-key obj)
    (unchecked-slot-ref obj 'key))
  (define (&module-export-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (&module-export-name obj)
    (unchecked-slot-ref obj 'name))
  (define (&module-export-weak? obj)
    (unchecked-slot-ref obj 'weak?))
  (define (&module-export-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&module-export-key-set! obj val)
    (unchecked-slot-set! obj 'key val))
  (define (&module-export-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&module-export-name-set! obj val)
    (unchecked-slot-set! obj 'name val))
  (define (&module-export-weak?-set! obj val)
    (unchecked-slot-set! obj 'weak? val)))

(begin
  (define import-set::t
    (make-class-type 'gerbil\x23;import-set::t 'import-set (list object::t)
      '(source phi imports)
      '((struct: . #t) (final: . #t) (print: source phi)) '#f))
  (define (make-import-set . args)
    (let* ([type import-set::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (import-set? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;import-set::t))
  (define (import-set-source obj)
    (unchecked-slot-ref obj 'source))
  (define (import-set-phi obj) (unchecked-slot-ref obj 'phi))
  (define (import-set-imports obj)
    (unchecked-slot-ref obj 'imports))
  (define (import-set-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (import-set-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (import-set-imports-set! obj val)
    (unchecked-slot-set! obj 'imports val))
  (define (&import-set-source obj)
    (unchecked-slot-ref obj 'source))
  (define (&import-set-phi obj) (unchecked-slot-ref obj 'phi))
  (define (&import-set-imports obj)
    (unchecked-slot-ref obj 'imports))
  (define (&import-set-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (&import-set-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&import-set-imports-set! obj val)
    (unchecked-slot-set! obj 'imports val)))

(begin
  (define export-set::t
    (make-class-type 'gerbil\x23;export-set::t 'export-set (list object::t)
      '(source phi exports)
      '((struct: . #t) (final: . #t) (print: source phi)) '#f))
  (define (make-export-set . args)
    (let* ([type export-set::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (export-set? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;export-set::t))
  (define (export-set-source obj)
    (unchecked-slot-ref obj 'source))
  (define (export-set-phi obj) (unchecked-slot-ref obj 'phi))
  (define (export-set-exports obj)
    (unchecked-slot-ref obj 'exports))
  (define (export-set-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (export-set-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (export-set-exports-set! obj val)
    (unchecked-slot-set! obj 'exports val))
  (define (&export-set-source obj)
    (unchecked-slot-ref obj 'source))
  (define (&export-set-phi obj) (unchecked-slot-ref obj 'phi))
  (define (&export-set-exports obj)
    (unchecked-slot-ref obj 'exports))
  (define (&export-set-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (&export-set-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&export-set-exports-set! obj val)
    (unchecked-slot-set! obj 'exports val)))

(begin
  (define import-expander::t
    (make-class-type 'gerbil\x23;import-expander::t 'import-expander
      (list user-expander::t) '() '((constructor: . :init!)) '#f))
  (define (import-expander . args)
    (apply make-import-expander args))
  (define (import-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;import-expander::t))
  (define (make-import-expander . args)
    (apply make-instance import-expander::t args)))

(begin
  (define export-expander::t
    (make-class-type 'gerbil\x23;export-expander::t 'export-expander
      (list user-expander::t) '() '((constructor: . :init!)) '#f))
  (define (export-expander . args)
    (apply make-export-expander args))
  (define (export-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;export-expander::t))
  (define (make-export-expander . args)
    (apply make-instance export-expander::t args)))

(begin
  (define import-export-expander::t
    (make-class-type 'gerbil\x23;import-export-expander::t
      'import-export-expander
      (list import-expander::t export-expander::t) '()
      '((constructor: . :init!)) '#f))
  (define (import-export-expander . args)
    (apply make-import-export-expander args))
  (define (import-export-expander? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;import-export-expander::t))
  (define (make-import-export-expander . args)
    (apply make-instance import-export-expander::t args)))

(define current-import-expander-phi (make-parameter #f))

(define current-export-expander-phi (make-parameter #f))

(define current-module-reader-path (make-parameter #f))

(define current-module-reader-args (make-parameter #f))

(define source-file-settings
  (cons
    'char-encoding:
    (cons 'UTF-8 (cons 'eol-encoding: '(lf)))))

(define (call-with-input-source-file path fun)
  (call-with-input-file
    (cons* 'path: path source-file-settings)
    fun))

(begin
  (define module-context:::init!
    (lambda (self id super ns path)
      (struct-instance-init! self id (make-hash-table-eq) super #f
        #f ns path (list) (list) #f #f)))
  (bind-method!
    module-context::t
    ':init!
    module-context:::init!))

(begin
  (define prelude-context:::init!
    (case-lambda
      [(self ctx)
       (let* ([root #f])
         (let ([super (or root
                          (core-context-root)
                          (make-root-context))])
           (if ctx
               (let ([id (expander-context-id ctx)]
                     [path (module-context-path ctx)]
                     [in (map core-module-export->import
                              (module-context-export ctx))]
                     [e (delay-atomic (eval-module ctx))])
                 (struct-instance-init! self id
                   (make-hash-table-eq (length in)) super #f #f path in e)
                 (for-each
                   (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1207})
                     (core-bind-weak-import!
                       #{cut-arg dpuuv4a3mobea70icwo8nvdax-1207}
                       self))
                   in))
               (struct-instance-init! self #f (make-hash-table-eq) super #f
                 #f #f (list) #f))))]
      [(self ctx root)
       (let ([super (or root
                        (core-context-root)
                        (make-root-context))])
         (if ctx
             (let ([id (expander-context-id ctx)]
                   [path (module-context-path ctx)]
                   [in (map core-module-export->import
                            (module-context-export ctx))]
                   [e (delay-atomic (eval-module ctx))])
               (struct-instance-init! self id
                 (make-hash-table-eq (length in)) super #f #f path in e)
               (for-each
                 (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1207})
                   (core-bind-weak-import!
                     #{cut-arg dpuuv4a3mobea70icwo8nvdax-1207}
                     self))
                 in))
             (struct-instance-init! self #f (make-hash-table-eq) super #f
               #f #f (list) #f)))]))
  (bind-method!
    prelude-context::t
    ':init!
    prelude-context:::init!))

(define (import-export-expander-init! self e)
  (struct-instance-init!
    self
    e
    (current-expander-context)
    (fx1- (current-expander-phi))))

(begin
  (define import-expander:::init!
    import-export-expander-init!)
  (bind-method!
    import-expander::t
    ':init!
    import-expander:::init!))

(begin
  (define export-expander:::init!
    import-export-expander-init!)
  (bind-method!
    export-expander::t
    ':init!
    export-expander:::init!))

(begin
  (define import-export-expander:::init!
    import-export-expander-init!)
  (bind-method!
    import-export-expander::t
    ':init!
    import-export-expander:::init!))

(begin
  (define import-expander::apply-import-expander
    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1208}
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-1209})
      (core-apply-user-expander
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1208}
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1209}
        'apply-import-expander)))
  (bind-method!
    import-expander::t
    'apply-import-expander
    import-expander::apply-import-expander))

(begin
  (define export-expander::apply-export-expander
    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1210}
             #{cut-arg dpuuv4a3mobea70icwo8nvdax-1211})
      (core-apply-user-expander
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1210}
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1211}
        'apply-export-expander)))
  (bind-method!
    export-expander::t
    'apply-export-expander
    export-expander::apply-export-expander))

(define (module-source-path ctx)
  (let* ([path (module-context-path ctx)])
    (let* ([path (if (pair? path) (last path) path)])
      (and (string? path) path))))

(define import-module
  (case-lambda
    [(path)
     (let* ([reload? #f] [eval? #f])
       (let ([ctx ((current-expander-module-import) path reload?)])
         (when (and ctx eval?) (eval-module ctx))
         ctx))]
    [(path reload?)
     (let* ([eval? #f])
       (let ([ctx ((current-expander-module-import) path reload?)])
         (when (and ctx eval?) (eval-module ctx))
         ctx))]
    [(path reload? eval?)
     (let ([ctx ((current-expander-module-import) path reload?)])
       (when (and ctx eval?) (eval-module ctx))
       ctx)]))

(define (eval-module mod)
  ((current-expander-module-eval) mod))

(define (core-eval-module obj)
  (define (force-e getf e)
    (parameterize ([current-expander-context e]
                   [current-expander-phi 0])
      (force (getf e))))
  (let recur ([e obj])
    (cond
      [(module-context? e)
       (cond [(core-context-prelude e) => recur])
       (force-e module-context-e e)]
      [(prelude-context? e) (force-e prelude-context-e e)]
      [(stx-string? e)
       (recur (import-module (core-resolve-module-path e)))]
      [(core-library-module-path? e)
       (recur
         (import-module (core-resolve-library-module-path e)))]
      [else (error 'gerbil "cannot eval module" obj)])))

(define core-context-prelude
  (case-lambda
    [()
     (let* ([ctx (current-expander-context)])
       (let lp ([e ctx])
         (cond
           [(or (module-context? e) (local-context? e))
            (lp (&phi-context-super e))]
           [(prelude-context? e) e]
           [else #f])))]
    [(ctx)
     (let lp ([e ctx])
       (cond
         [(or (module-context? e) (local-context? e))
          (lp (&phi-context-super e))]
         [(prelude-context? e) e]
         [else #f]))]))

(define (core-module->prelude-context ctx)
  (cond
    [(hash-get __module-registry ctx)]
    [else
     (let ([pre (make-prelude-context ctx)])
       (hash-put! __module-registry ctx pre)
       pre)]))

(define core-import-module
  (case-lambda
    [(rpath)
     (let* ([reload? #f])
       (define (import-source path)
         (when (member path (current-expander-path))
           (error 'gerbil "Cyclic expansion" path))
         (parameterize ([current-expander-context
                         (core-context-root)]
                        [current-expander-marks (list)]
                        [current-expander-phi 0]
                        [current-expander-path
                         (cons path (current-expander-path))]
                        [current-import-expander-phi #f]
                        [current-export-expander-phi #f])
           (let-values ([(pre id ns body) (core-read-module path)])
             (let* ([prelude (cond
                               [(prelude-context? pre) pre]
                               [(module-context? pre)
                                (core-module->prelude-context pre)]
                               [(string? pre)
                                (core-module->prelude-context
                                  (core-import-module pre))]
                               [(not pre)
                                (or (current-expander-module-prelude)
                                    (make-prelude-context #f))]
                               [else
                                (error 'gerbil
                                  "cannot import module; unknown prelude"
                                  rpath
                                  pre)])])
               (let* ([ctx (make-module-context id prelude ns path)])
                 (let* ([body (core-expand-module-begin body ctx)])
                   (let* ([body (core-quote-syntax
                                  (core-cons '%\x23;begin body)
                                  path
                                  ctx
                                  (list))])
                     (&module-context-e-set!
                       ctx
                       (delay-atomic (eval-syntax* body)))
                     (&module-context-code-set! ctx body)
                     (hash-put! __module-registry path ctx)
                     (hash-put! __module-registry id ctx)
                     ctx)))))))
       (define (import-submodule rpath)
         (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1212} rpath])
           (let ([origin (car #{tmp dpuuv4a3mobea70icwo8nvdax-1212})]
                 [refs (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1212})])
             (let ([ctx (if origin
                            (core-import-module origin reload?)
                            (current-expander-context))])
               (let lp ([rest refs] [ctx ctx])
                 (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1213} rest])
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1213})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1214} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1213})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-1215} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1213})])
                         (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1214}])
                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1215}])
                             (begin
                               (let ([bind (resolve-identifier id 0 ctx)])
                                 (if (and (syntax-binding? bind)
                                          (module-context?
                                            (&syntax-binding-e bind)))
                                     (lp rest (&syntax-binding-e bind))
                                     (error 'gerbil
                                       "cannot import submodule; not bound as a module"
                                       rpath
                                       id
                                       bind)))))))
                       (begin ctx))))))))
       (cond
         [(and (not reload?) (hash-get __module-registry rpath))]
         [(list? rpath) (import-submodule rpath)]
         [(core-library-module-path? rpath)
          (let ([ctx (core-import-module
                       (core-resolve-library-module-path rpath)
                       reload?)])
            (hash-put! __module-registry rpath ctx)
            ctx)]
         [else
          (let ([npath (gambit-path-normalize rpath)])
            (cond
              [(and (not reload?) (hash-get __module-registry npath))]
              [else (import-source npath)]))]))]
    [(rpath reload?)
     (define (import-source path)
       (when (member path (current-expander-path))
         (error 'gerbil "Cyclic expansion" path))
       (parameterize ([current-expander-context
                       (core-context-root)]
                      [current-expander-marks (list)]
                      [current-expander-phi 0]
                      [current-expander-path
                       (cons path (current-expander-path))]
                      [current-import-expander-phi #f]
                      [current-export-expander-phi #f])
         (let-values ([(pre id ns body) (core-read-module path)])
           (let* ([prelude (cond
                             [(prelude-context? pre) pre]
                             [(module-context? pre)
                              (core-module->prelude-context pre)]
                             [(string? pre)
                              (core-module->prelude-context
                                (core-import-module pre))]
                             [(not pre)
                              (or (current-expander-module-prelude)
                                  (make-prelude-context #f))]
                             [else
                              (error 'gerbil
                                "cannot import module; unknown prelude"
                                rpath
                                pre)])])
             (let* ([ctx (make-module-context id prelude ns path)])
               (let* ([body (core-expand-module-begin body ctx)])
                 (let* ([body (core-quote-syntax
                                (core-cons '%\x23;begin body)
                                path
                                ctx
                                (list))])
                   (&module-context-e-set!
                     ctx
                     (delay-atomic (eval-syntax* body)))
                   (&module-context-code-set! ctx body)
                   (hash-put! __module-registry path ctx)
                   (hash-put! __module-registry id ctx)
                   ctx)))))))
     (define (import-submodule rpath)
       (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1212} rpath])
         (let ([origin (car #{tmp dpuuv4a3mobea70icwo8nvdax-1212})]
               [refs (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1212})])
           (let ([ctx (if origin
                          (core-import-module origin reload?)
                          (current-expander-context))])
             (let lp ([rest refs] [ctx ctx])
               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1213} rest])
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1213})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1214} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1213})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-1215} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1213})])
                       (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1214}])
                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1215}])
                           (begin
                             (let ([bind (resolve-identifier id 0 ctx)])
                               (if (and (syntax-binding? bind)
                                        (module-context?
                                          (&syntax-binding-e bind)))
                                   (lp rest (&syntax-binding-e bind))
                                   (error 'gerbil
                                     "cannot import submodule; not bound as a module"
                                     rpath
                                     id
                                     bind)))))))
                     (begin ctx))))))))
     (cond
       [(and (not reload?) (hash-get __module-registry rpath))]
       [(list? rpath) (import-submodule rpath)]
       [(core-library-module-path? rpath)
        (let ([ctx (core-import-module
                     (core-resolve-library-module-path rpath)
                     reload?)])
          (hash-put! __module-registry rpath ctx)
          ctx)]
       [else
        (let ([npath (gambit-path-normalize rpath)])
          (cond
            [(and (not reload?) (hash-get __module-registry npath))]
            [else (import-source npath)]))])]))

(define (core-read-module path)
  (guard (__exn
           [#t
            ((lambda (exn)
               (if (and (datum-parsing-exception? exn)
                        (eq? (datum-parsing-exception-filepos exn) 0))
                   (core-read-module/lang path)
                   (raise-syntax-error
                     'read-module
                     "error reading module"
                     path
                     (parameterize ([dump-stack-trace? #f])
                       (call-with-output-string
                         ""
                         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1216})
                           (display-exception
                             exn
                             #{cut-arg dpuuv4a3mobea70icwo8nvdax-1216})))))))
              __exn)])
    ((lambda () (core-read-module/sexp path)))))

(define (core-read-module/sexp path)
  (let lp ([body (read-syntax-from-file path)]
           [pre #f]
           [ns #f]
           [pkg #f])
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1217} body])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1218} (lambda ()
                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1219} (lambda ()
                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1220} (lambda ()
                                                                                                                                                         (call-with-values
                                                                                                                                                           (lambda ()
                                                                                                                                                             (if pkg
                                                                                                                                                                 (values
                                                                                                                                                                   pre
                                                                                                                                                                   ns
                                                                                                                                                                   pkg)
                                                                                                                                                                 (core-read-module-package
                                                                                                                                                                   path
                                                                                                                                                                   pre
                                                                                                                                                                   ns)))
                                                                                                                                                           (lambda (pre
                                                                                                                                                                    ns
                                                                                                                                                                    pkg)
                                                                                                                                                             (let* ([prelude (cond
                                                                                                                                                                               [(core-bound-module-prelude?
                                                                                                                                                                                  pre)
                                                                                                                                                                                (syntax-local-e
                                                                                                                                                                                  pre)]
                                                                                                                                                                               [(core-library-module-path?
                                                                                                                                                                                  pre)
                                                                                                                                                                                (core-resolve-library-module-path
                                                                                                                                                                                  pre)]
                                                                                                                                                                               [(stx-string?
                                                                                                                                                                                  pre)
                                                                                                                                                                                (core-resolve-module-path
                                                                                                                                                                                  pre
                                                                                                                                                                                  path)]
                                                                                                                                                                               [else
                                                                                                                                                                                (stx-e
                                                                                                                                                                                  pre)])])
                                                                                                                                                               (let* ([path-id (core-module-path->namespace
                                                                                                                                                                                 path)])
                                                                                                                                                                 (let* ([pkg-id (if pkg
                                                                                                                                                                                    (string-append
                                                                                                                                                                                      pkg
                                                                                                                                                                                      "/"
                                                                                                                                                                                      path-id)
                                                                                                                                                                                    path-id)])
                                                                                                                                                                   (let* ([module-id (string->symbol
                                                                                                                                                                                       pkg-id)])
                                                                                                                                                                     (let* ([module-ns (if (void?
                                                                                                                                                                                             ns)
                                                                                                                                                                                           #f
                                                                                                                                                                                           (or ns
                                                                                                                                                                                               pkg-id))])
                                                                                                                                                                       (values
                                                                                                                                                                         prelude
                                                                                                                                                                         module-id
                                                                                                                                                                         module-ns
                                                                                                                                                                         body)))))))))])
                                                                                                          (if (stx-pair?
                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})
                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1221} (syntax-e
                                                                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})])
                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1222} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1221})]
                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1223} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1221})])
                                                                                                                  (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1224} (stx-e
                                                                                                                                                                    #{csc-h dpuuv4a3mobea70icwo8nvdax-1222})])
                                                                                                                    (if (and (keyword?
                                                                                                                               #{csc-kv dpuuv4a3mobea70icwo8nvdax-1224})
                                                                                                                             (string=?
                                                                                                                               (keyword->string
                                                                                                                                 #{csc-kv dpuuv4a3mobea70icwo8nvdax-1224})
                                                                                                                               "package"))
                                                                                                                        (if (stx-pair?
                                                                                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1223})
                                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1225} (syntax-e
                                                                                                                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1223})])
                                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1226} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1225})]
                                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1227} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1225})])
                                                                                                                                (let ([pkg #{csc-h dpuuv4a3mobea70icwo8nvdax-1226}])
                                                                                                                                  (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1227}])
                                                                                                                                    (let ([pkg (cond
                                                                                                                                                 [(identifier?
                                                                                                                                                    pkg)
                                                                                                                                                  (symbol->string
                                                                                                                                                    (stx-e
                                                                                                                                                      pkg))]
                                                                                                                                                 [(or (stx-string?
                                                                                                                                                        pkg)
                                                                                                                                                      (stx-false?
                                                                                                                                                        pkg))
                                                                                                                                                  (stx-e
                                                                                                                                                    pkg)]
                                                                                                                                                 [else
                                                                                                                                                  (raise-syntax-error
                                                                                                                                                    'import
                                                                                                                                                    "Bad syntax; Illegal package name"
                                                                                                                                                    pkg)])])
                                                                                                                                      (lp rest
                                                                                                                                          pre
                                                                                                                                          ns
                                                                                                                                          pkg))))))
                                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1220}))
                                                                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1220})))))
                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1220}))))])
                                                         (if (stx-pair?
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})
                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1228} (syntax-e
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})])
                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1229} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1228})]
                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1230} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1228})])
                                                                 (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1231} (stx-e
                                                                                                                   #{csc-h dpuuv4a3mobea70icwo8nvdax-1229})])
                                                                   (if (and (keyword?
                                                                              #{csc-kv dpuuv4a3mobea70icwo8nvdax-1231})
                                                                            (string=?
                                                                              (keyword->string
                                                                                #{csc-kv dpuuv4a3mobea70icwo8nvdax-1231})
                                                                              "namespace"))
                                                                       (if (stx-pair?
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1230})
                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1232} (syntax-e
                                                                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1230})])
                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1233} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1232})]
                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-1234} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1232})])
                                                                               (let ([ns #{csc-h dpuuv4a3mobea70icwo8nvdax-1233}])
                                                                                 (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1234}])
                                                                                   (let ([ns (cond
                                                                                               [(identifier?
                                                                                                  ns)
                                                                                                (symbol->string
                                                                                                  (stx-e
                                                                                                    ns))]
                                                                                               [(stx-string?
                                                                                                  ns)
                                                                                                (stx-e
                                                                                                  ns)]
                                                                                               [(stx-false?
                                                                                                  ns)
                                                                                                (%%void)]
                                                                                               [else
                                                                                                (raise-syntax-error
                                                                                                  'import
                                                                                                  "Bad syntax; illegal namespace"
                                                                                                  ns)])])
                                                                                     (lp rest
                                                                                         pre
                                                                                         ns
                                                                                         pkg))))))
                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1219}))
                                                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1219})))))
                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1219}))))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1235} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1217})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1236} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1235})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1237} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1235})])
                (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1238} (stx-e
                                                                  #{csc-h dpuuv4a3mobea70icwo8nvdax-1236})])
                  (if (and (keyword?
                             #{csc-kv dpuuv4a3mobea70icwo8nvdax-1238})
                           (string=?
                             (keyword->string
                               #{csc-kv dpuuv4a3mobea70icwo8nvdax-1238})
                             "prelude"))
                      (if (stx-pair?
                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1237})
                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1239} (syntax-e
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1237})])
                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1240} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1239})]
                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1241} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1239})])
                              (let ([prelude #{csc-h dpuuv4a3mobea70icwo8nvdax-1240}])
                                (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1241}])
                                  (lp rest prelude ns pkg)))))
                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1218}))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1218})))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1218}))))))

(define (core-read-module/lang path)
  (define (default-read-module-body inp)
    (let lp ([body (list)])
      (let ([next (read-syntax inp)])
        (if (eof-object? next)
            (reverse body)
            (lp (cons next body))))))
  (define (read-body inp pre ns pkg args)
    (call-with-values
      (lambda ()
        (if pkg
            (values pre ns pkg)
            (core-read-module-package path pre ns)))
      (lambda (pre ns pkg)
        (let* ([prelude (import-module pre)])
          (let* ([read-module-body (cond
                                     [(find
                                        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1242} <>])
                                          (if (pair?
                                                #{match-val dpuuv4a3mobea70icwo8nvdax-1242})
                                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1243} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1242})]
                                                    [#{tl dpuuv4a3mobea70icwo8nvdax-1244} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1242})])
                                                (let ([module-export #{hd dpuuv4a3mobea70icwo8nvdax-1243}])
                                                  (if (pair?
                                                        #{tl dpuuv4a3mobea70icwo8nvdax-1244})
                                                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1245} (car #{tl dpuuv4a3mobea70icwo8nvdax-1244})]
                                                            [#{tl dpuuv4a3mobea70icwo8nvdax-1246} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1244})])
                                                        (if (pair?
                                                              #{tl dpuuv4a3mobea70icwo8nvdax-1246})
                                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1247} (car #{tl dpuuv4a3mobea70icwo8nvdax-1246})]
                                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1248} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1246})])
                                                              (if (pair?
                                                                    #{tl dpuuv4a3mobea70icwo8nvdax-1248})
                                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1249} (car #{tl dpuuv4a3mobea70icwo8nvdax-1248})]
                                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-1250} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1248})])
                                                                    (if (equal?
                                                                          #{hd dpuuv4a3mobea70icwo8nvdax-1249}
                                                                          '1)
                                                                        (if (pair?
                                                                              #{tl dpuuv4a3mobea70icwo8nvdax-1250})
                                                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1251} (car #{tl dpuuv4a3mobea70icwo8nvdax-1250})]
                                                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1252} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1250})])
                                                                              (if (pair?
                                                                                    #{hd dpuuv4a3mobea70icwo8nvdax-1251})
                                                                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1253} (car #{hd dpuuv4a3mobea70icwo8nvdax-1251})]
                                                                                        [#{tl dpuuv4a3mobea70icwo8nvdax-1254} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-1251})])
                                                                                    (let ([eq? #{hd dpuuv4a3mobea70icwo8nvdax-1253}])
                                                                                      (if (pair?
                                                                                            #{tl dpuuv4a3mobea70icwo8nvdax-1254})
                                                                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1255} (car #{tl dpuuv4a3mobea70icwo8nvdax-1254})]
                                                                                                [#{tl dpuuv4a3mobea70icwo8nvdax-1256} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1254})])
                                                                                            (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-1255}
                                                                                                     'read-module-body)
                                                                                                (if (null?
                                                                                                      #{tl dpuuv4a3mobea70icwo8nvdax-1256})
                                                                                                    (if (null?
                                                                                                          #{tl dpuuv4a3mobea70icwo8nvdax-1252})
                                                                                                        (begin
                                                                                                          #t)
                                                                                                        (begin
                                                                                                          #f))
                                                                                                    (begin
                                                                                                      #f))
                                                                                                (begin
                                                                                                  #f)))
                                                                                          (begin
                                                                                            #f))))
                                                                                  (begin
                                                                                    #f)))
                                                                            (begin
                                                                              #f))
                                                                        (begin
                                                                          #f)))
                                                                  (begin
                                                                    #f)))
                                                            (begin #f)))
                                                      (begin #f))))
                                              (begin #f)))
                                        (&module-context-export prelude)) =>
                                      (lambda (xport)
                                        (let ([proc (guard (__exn
                                                             [#t
                                                              (void
                                                                __exn)])
                                                      ((lambda ()
                                                         (eval-syntax
                                                           (binding-id
                                                             (core-resolve-module-export
                                                               xport))))))])
                                          (if (procedure? proc)
                                              proc
                                              (raise-syntax-error #f
                                                "Illegal #lang prelude; read-module-body is not a procedure"
                                                path pre proc))))]
                                     [else default-read-module-body])])
            (let* ([path-id (core-module-path->namespace path)])
              (let* ([pkg-id (if pkg
                                 (string-append pkg "/" path-id)
                                 path-id)])
                (let* ([module-id (string->symbol pkg-id)])
                  (let* ([module-ns (or ns pkg-id)])
                    (let* ([body (parameterize ([current-module-reader-path
                                                 path]
                                                [current-module-reader-args
                                                 args])
                                   (read-module-body inp))])
                      (values prelude module-id module-ns body)))))))))))
  (define (string-e obj what)
    (cond
      [(string? obj) obj]
      [(symbol? obj) (symbol->string obj)]
      [else
       (raise-syntax-error
         #f
         (string-append "Illegal module " what)
         path
         obj)]))
  (define (read-lang-args inp args)
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1257} args])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1257})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1258} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1257})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-1259} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1257})])
            (let ([prelude #{hd dpuuv4a3mobea70icwo8nvdax-1258}])
              (let ([args #{tl dpuuv4a3mobea70icwo8nvdax-1259}])
                (begin
                  (let* ([pkg (pgetq 'package: args)])
                    (let* ([pkg (and pkg (string-e pkg "package"))])
                      (let* ([ns (pgetq 'namespace: args)])
                        (let* ([ns (and ns (string-e ns "namespace"))])
                          (read-body inp prelude ns pkg args)))))))))
          (begin
            (raise-syntax-error
              #f
              "Illegal #lang arguments; missing prelude"
              path)))))
  (define (read-lang inp)
    (let ([head (get-line inp)])
      (cond
        [(string-index head #\space) =>
         (lambda (ix)
           (let ([lang (substring head 0 ix)])
             (if (equal? lang "#lang")
                 (let* ([rest (substring
                                head
                                (fx1+ ix)
                                (string-length head))])
                   (let* ([args (guard (__exn
                                         [#t
                                          ((lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1260})
                                             (raise-syntax-error
                                               #f
                                               "Illegal #lang arguments"
                                               path
                                               #{cut-arg dpuuv4a3mobea70icwo8nvdax-1260}))
                                            __exn)])
                                  ((lambda ()
                                     (call-with-input-string
                                       rest
                                       (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1261})
                                         (read-all
                                           #{cut-arg dpuuv4a3mobea70icwo8nvdax-1261}
                                           read))))))])
                     (read-lang-args inp args)))
                 (raise-syntax-error #f "Illegal module syntax" path))))]
        [else
         (raise-syntax-error #f "Illegal module syntax" path)])))
  (define (read-e inp)
    (if (eq? (peek-char inp) #\#)
        (read-lang inp)
        (raise-syntax-error #f "Illegal module syntax" path)))
  (call-with-input-source-file path read-e))

(define (core-read-module-package path pre ns)
  (define (string-e e)
    (cond
      [(symbol? e) (symbol->string e)]
      [(string? e) e]
      [else
       (raise-syntax-error
         #f
         "Malformed package info; unexpected datum"
         e)]))
  (let lp ([dir (path-directory path)] [pkg-path (list)])
    (let ([gerbil.pkg (gambit-path-expand "gerbil.pkg" dir)])
      (if (file-exists? gerbil.pkg)
          (let ([plist (core-library-package-plist dir #t)])
            (cond
              [(null? plist)
               (let ([pkg (and (not (null? pkg-path))
                               (let ([#{strs dpuuv4a3mobea70icwo8nvdax-1262} pkg-path]
                                     [#{sep dpuuv4a3mobea70icwo8nvdax-1263} "/"])
                                 (if (null?
                                       #{strs dpuuv4a3mobea70icwo8nvdax-1262})
                                     ""
                                     (let lp ([#{result dpuuv4a3mobea70icwo8nvdax-1264} (car #{strs dpuuv4a3mobea70icwo8nvdax-1262})]
                                              [rest (cdr #{strs dpuuv4a3mobea70icwo8nvdax-1262})])
                                       (if (null? rest)
                                           #{result dpuuv4a3mobea70icwo8nvdax-1264}
                                           (lp (string-append
                                                 #{result dpuuv4a3mobea70icwo8nvdax-1264}
                                                 #{sep dpuuv4a3mobea70icwo8nvdax-1263}
                                                 (car rest))
                                               (cdr rest)))))))])
                 (values pre ns pkg))]
              [(list? plist)
               (let* ([root (pgetq 'package: plist)])
                 (let* ([pkg (let ([pkg-path (if root
                                                 (cons
                                                   (string-e root)
                                                   pkg-path)
                                                 pkg-path)])
                               (and (not (null? pkg-path))
                                    (let ([#{strs dpuuv4a3mobea70icwo8nvdax-1265} pkg-path]
                                          [#{sep dpuuv4a3mobea70icwo8nvdax-1266} "/"])
                                      (if (null?
                                            #{strs dpuuv4a3mobea70icwo8nvdax-1265})
                                          ""
                                          (let lp ([#{result dpuuv4a3mobea70icwo8nvdax-1267} (car #{strs dpuuv4a3mobea70icwo8nvdax-1265})]
                                                   [rest (cdr #{strs dpuuv4a3mobea70icwo8nvdax-1265})])
                                            (if (null? rest)
                                                #{result dpuuv4a3mobea70icwo8nvdax-1267}
                                                (lp (string-append
                                                      #{result dpuuv4a3mobea70icwo8nvdax-1267}
                                                      #{sep dpuuv4a3mobea70icwo8nvdax-1266}
                                                      (car rest))
                                                    (cdr rest))))))))])
                   (let* ([ns (let ([ns (or ns (pgetq 'namespace: plist))])
                                (and ns (string-e ns)))])
                     (let* ([pre (or pre (pgetq 'prelude: plist))])
                       (values pre ns pkg)))))]
              [else
               (raise-syntax-error
                 #f
                 "Malformed package info; unexpected datum"
                 plist)]))
          (let ([dir* (path-strip-trailing-directory-separator dir)])
            (if (or (string-empty? dir*) (equal? dir dir*))
                (values pre ns #f)
                (let ([xpath (path-strip-directory dir*)]
                      [xdir (path-directory dir*)])
                  (lp xdir (cons xpath pkg-path)))))))))

(define (core-module-path->namespace path)
  (path-strip-extension (path-strip-directory path)))

(define (core-module-path->id path)
  (string->symbol (core-module-path->namespace path)))

(define core-resolve-module-path
  (case-lambda
    [(stx-path)
     (let* ([rel #f])
       (let* ([path (stx-e stx-path)])
         (let* ([path (if (string-empty? (path-extension path))
                          (string-append path ".ss")
                          path)])
           (core-resolve-path path (or (stx-source stx-path) rel)))))]
    [(stx-path rel)
     (let* ([path (stx-e stx-path)])
       (let* ([path (if (string-empty? (path-extension path))
                        (string-append path ".ss")
                        path)])
         (core-resolve-path path (or (stx-source stx-path) rel))))]))

(define (core-resolve-library-module-path libpath)
  (let* ([spath (symbol->string (stx-e libpath))])
    (let* ([spath (substring spath 1 (string-length spath))])
      (let* ([ext (path-extension spath)])
        (let* ([ssi (if (string-empty? ext)
                        (string-append spath ".ssi")
                        (string-append
                          (path-strip-extension spath)
                          ".ssi"))])
          (let* ([srcs (if (string-empty? ext)
                           (map (lambda (ext) (string-append spath ext))
                                '(".ss" ".sld" ".scm"))
                           (list spath))])
            (let lp ([rest (load-path)])
              (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1268} rest])
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1268})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1269} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1268})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-1270} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1268})])
                      (let ([dir #{hd dpuuv4a3mobea70icwo8nvdax-1269}])
                        (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1270}])
                          (begin
                            (define (resolve ssi srcs)
                              (let ([compiled-path (gambit-path-expand
                                                     ssi
                                                     dir)])
                                (if (file-exists? compiled-path)
                                    (gambit-path-normalize compiled-path)
                                    (let lpr ([rest-src srcs])
                                      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1271} rest-src])
                                        (if (pair?
                                              #{match-val dpuuv4a3mobea70icwo8nvdax-1271})
                                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1272} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1271})]
                                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1273} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1271})])
                                              (let ([src #{hd dpuuv4a3mobea70icwo8nvdax-1272}])
                                                (let ([rest-src #{tl dpuuv4a3mobea70icwo8nvdax-1273}])
                                                  (begin
                                                    (let ([src-path (gambit-path-expand
                                                                      src
                                                                      dir)])
                                                      (if (file-exists?
                                                            src-path)
                                                          (gambit-path-normalize
                                                            src-path)
                                                          (lpr rest-src)))))))
                                            (begin (lp rest))))))))
                            (cond
                              [(core-library-package-path-prefix dir) =>
                               (lambda (prefix)
                                 (if (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-1274} prefix]
                                           [#{str dpuuv4a3mobea70icwo8nvdax-1275} spath])
                                       (let ([plen (string-length
                                                     #{pfx dpuuv4a3mobea70icwo8nvdax-1274})])
                                         (and (<= plen
                                                  (string-length
                                                    #{str dpuuv4a3mobea70icwo8nvdax-1275}))
                                              (string=?
                                                #{pfx dpuuv4a3mobea70icwo8nvdax-1274}
                                                (substring
                                                  #{str dpuuv4a3mobea70icwo8nvdax-1275}
                                                  0
                                                  plen)))))
                                     (let ([ssi (substring
                                                  ssi
                                                  (string-length prefix)
                                                  (string-length ssi))]
                                           [srcs (map (lambda (src)
                                                        (substring
                                                          src
                                                          (string-length
                                                            prefix)
                                                          (string-length
                                                            src)))
                                                      srcs)])
                                       (resolve ssi srcs))
                                     (lp rest)))]
                              [else (resolve ssi srcs)])))))
                    (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-1268})
                        (begin
                          (raise-syntax-error
                            #f
                            "cannot find library module"
                            libpath))
                        (error 'match
                          "no matching clause"
                          #{match-val dpuuv4a3mobea70icwo8nvdax-1268})))))))))))

(define (core-resolve-library-relative-module-path modpath)
  (define (resolve path base)
    (cond
      [(string-rindex base #\/) =>
       (lambda (idx)
         (core-resolve-library-module-path
           (string->symbol
             (string-append ":" (substring base 0 idx) "/" path))))]
      [else
       (core-resolve-library-module-path
         (string->symbol (string-append ":" path)))]))
  (let ([spath (symbol->string (stx-e modpath))]
        [mod (core-context-top
               (current-expander-context)
               module-context?)])
    (unless mod
      (raise-syntax-error
        #f
        "cannot resolve relative module path; not in module context"
        modpath))
    (let ([mpath (symbol->string (expander-context-id mod))])
      (let lp ([spath spath] [mpath mpath])
        (cond
          [(let ([#{pfx dpuuv4a3mobea70icwo8nvdax-1276} "../"]
                 [#{str dpuuv4a3mobea70icwo8nvdax-1277} spath])
             (let ([plen (string-length
                           #{pfx dpuuv4a3mobea70icwo8nvdax-1276})])
               (and (<= plen
                        (string-length
                          #{str dpuuv4a3mobea70icwo8nvdax-1277}))
                    (string=?
                      #{pfx dpuuv4a3mobea70icwo8nvdax-1276}
                      (substring
                        #{str dpuuv4a3mobea70icwo8nvdax-1277}
                        0
                        plen)))))
           (cond
             [(string-rindex mpath #\/) =>
              (lambda (idx)
                (lp (substring spath 3 (string-length spath))
                    (substring mpath 0 idx)))]
             [else
              (raise-syntax-error
                #f
                "cannot resolve relative module path; illegal traversal"
                modpath)])]
          [(let ([#{pfx dpuuv4a3mobea70icwo8nvdax-1278} "./"]
                 [#{str dpuuv4a3mobea70icwo8nvdax-1279} spath])
             (let ([plen (string-length
                           #{pfx dpuuv4a3mobea70icwo8nvdax-1278})])
               (and (<= plen
                        (string-length
                          #{str dpuuv4a3mobea70icwo8nvdax-1279}))
                    (string=?
                      #{pfx dpuuv4a3mobea70icwo8nvdax-1278}
                      (substring
                        #{str dpuuv4a3mobea70icwo8nvdax-1279}
                        0
                        plen)))))
           (lp (substring spath 2 (string-length spath)) mpath)]
          [else (resolve spath mpath)])))))

(define (core-library-package-path-prefix dir)
  (cond
    [(pgetq 'package: (core-library-package-plist dir)) =>
     (lambda (pkg) (string-append (symbol->string pkg) "/"))]
    [else #f]))

(define core-library-package-plist
  (case-lambda
    [(dir)
     (let* ([exists? #f])
       (cond
         [(hash-get __module-pkg-cache dir)]
         [else
          (let* ([gerbil.pkg (gambit-path-expand "gerbil.pkg" dir)])
            (let* ([plist (if (or exists? (file-exists? gerbil.pkg))
                              (let ([e (call-with-input-source-file
                                         gerbil.pkg
                                         read)])
                                (cond
                                  [(eof-object? e) (list)]
                                  [(list? e) e]
                                  [else
                                   (raise-syntax-error
                                     #f
                                     "Malformed package info; unexpected datum"
                                     gerbil.pkg
                                     e)]))
                              (list))])
              (hash-put! __module-pkg-cache dir plist)
              plist))]))]
    [(dir exists?)
     (cond
       [(hash-get __module-pkg-cache dir)]
       [else
        (let* ([gerbil.pkg (gambit-path-expand "gerbil.pkg" dir)])
          (let* ([plist (if (or exists? (file-exists? gerbil.pkg))
                            (let ([e (call-with-input-source-file
                                       gerbil.pkg
                                       read)])
                              (cond
                                [(eof-object? e) (list)]
                                [(list? e) e]
                                [else
                                 (raise-syntax-error
                                   #f
                                   "Malformed package info; unexpected datum"
                                   gerbil.pkg
                                   e)]))
                            (list))])
            (hash-put! __module-pkg-cache dir plist)
            plist))])]))

(define (core-library-module-path? stx)
  (core-special-module-path? stx #\:))

(define (core-library-relative-module-path? stx)
  (core-special-module-path? stx #\.))

(define (core-special-module-path? stx char)
  (and (identifier? stx)
       (interned-symbol? (stx-e stx))
       (let ([str (symbol->string (stx-e stx))])
         (and (fx> (string-length str) 1)
              (eq? (string-ref str 0) char)))))

(define (core-bound-prelude? stx)
  (core-bound-identifier?
    stx
    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1280})
      (expander-binding?
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1280}
        prelude-context?))))

(define (core-bound-module? stx)
  (core-bound-identifier?
    stx
    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1281})
      (expander-binding?
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1281}
        module-context?))))

(define (core-bound-module-prelude? stx)
  (define (module-prelude? e)
    (or (module-context? e) (prelude-context? e)))
  (core-bound-identifier?
    stx
    (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1282})
      (expander-binding?
        #{cut-arg dpuuv4a3mobea70icwo8nvdax-1282}
        module-prelude?))))

(define core-bind-import!
  (case-lambda
    [(in)
     (let* ([ctx (current-expander-context)] [force-weak? #f])
       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1283} in])
         (let ([source (\x23;\x23;structure-ref
                         #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                         1)]
               [key (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                      2)]
               [phi (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                      3)]
               [weak? (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                        4)])
           (core-bind! key
             (let ([e (core-resolve-module-export source)])
               (make-import-binding (&binding-id e) key phi e
                 (&module-export-context source) (or force-weak? weak?)))
             core-context-rebind? phi ctx))))]
    [(in ctx)
     (let* ([force-weak? #f])
       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1283} in])
         (let ([source (\x23;\x23;structure-ref
                         #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                         1)]
               [key (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                      2)]
               [phi (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                      3)]
               [weak? (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                        4)])
           (core-bind! key
             (let ([e (core-resolve-module-export source)])
               (make-import-binding (&binding-id e) key phi e
                 (&module-export-context source) (or force-weak? weak?)))
             core-context-rebind? phi ctx))))]
    [(in ctx force-weak?)
     (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1283} in])
       (let ([source (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                       1)]
             [key (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                    2)]
             [phi (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                    3)]
             [weak? (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1283}
                      4)])
         (core-bind! key
           (let ([e (core-resolve-module-export source)])
             (make-import-binding (&binding-id e) key phi e
               (&module-export-context source) (or force-weak? weak?)))
           core-context-rebind? phi ctx)))]))

(define core-bind-weak-import!
  (case-lambda
    [(in)
     (let* ([ctx (current-expander-context)])
       (core-bind-import! in ctx #t))]
    [(in ctx) (core-bind-import! in ctx #t)]))

(define (core-resolve-module-export out)
  (define (subst key)
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1284} key])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1284})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1285} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1284})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-1286} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1284})])
            (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-1285}])
              (let ([mark #{tl dpuuv4a3mobea70icwo8nvdax-1286}])
                (begin
                  (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1287} mark])
                    (let ([subst (\x23;\x23;structure-ref
                                   #{with-obj dpuuv4a3mobea70icwo8nvdax-1287}
                                   1)])
                      (or (and subst (hash-get subst id))
                          (raise-syntax-error
                            #f
                            "Illegal key; missing substitution"
                            key))))))))
          (begin key))))
  (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1288} out])
    (let ([ctx (\x23;\x23;structure-ref
                 #{with-obj dpuuv4a3mobea70icwo8nvdax-1288}
                 1)]
          [key (\x23;\x23;structure-ref
                 #{with-obj dpuuv4a3mobea70icwo8nvdax-1288}
                 2)]
          [phi (\x23;\x23;structure-ref
                 #{with-obj dpuuv4a3mobea70icwo8nvdax-1288}
                 3)])
      (core-context-resolve
        (core-context-shift ctx phi)
        (subst key)))))

(define core-module-export->import
  (case-lambda
    [(out)
     (let* ([rename #f] [dphi 0])
       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1289} out])
         (let ([ctx (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      1)]
               [key (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      2)]
               [phi (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      3)]
               [name (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                       4)]
               [weak? (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                        5)])
           (make-module-import
             out
             (or rename name)
             (fx+ phi dphi)
             weak?))))]
    [(out rename)
     (let* ([dphi 0])
       (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1289} out])
         (let ([ctx (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      1)]
               [key (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      2)]
               [phi (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      3)]
               [name (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                       4)]
               [weak? (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                        5)])
           (make-module-import
             out
             (or rename name)
             (fx+ phi dphi)
             weak?))))]
    [(out rename dphi)
     (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1289} out])
       (let ([ctx (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                    1)]
             [key (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                    2)]
             [phi (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                    3)]
             [name (\x23;\x23;structure-ref
                     #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                     4)]
             [weak? (\x23;\x23;structure-ref
                      #{with-obj dpuuv4a3mobea70icwo8nvdax-1289}
                      5)])
         (make-module-import
           out
           (or rename name)
           (fx+ phi dphi)
           weak?)))]))

(define (core-expand-module% stx)
  (define (make-context id)
    (let* ([super (current-expander-context)])
      (let* ([bind-id (stx-e id)])
        (let* ([mod-id (if (module-context? super)
                           (make-symbol
                             (expander-context-id super)
                             "~"
                             bind-id)
                           bind-id)])
          (let* ([ns (symbol->string mod-id)])
            (let* ([path (if (module-context? super)
                             (let ([path (&module-context-path super)])
                               (cond
                                 [(or (pair? path) (null? path))
                                  (cons bind-id path)]
                                 [(not path) bind-id]
                                 [else (list bind-id path)]))
                             bind-id)])
              (make-module-context mod-id super ns path)))))))
  (define (valid-module-id? id)
    (let* ([str (symbol->string id)])
      (let* ([len (string-length str)])
        (and (fx>= len 1)
             (let loop ([index (fx- (string-length str) 1)])
               (if (fx>= index 0)
                   (let ([c (string-ref str index)])
                     (and (or (and (char>=? c #\a) (char<=? c #\z))
                              (and (char>=? c #\A) (char<=? c #\Z))
                              (and (char>=? c #\0) (char<=? c #\9))
                              (char=? c #\_)
                              (char=? c #\-))
                          (loop (fx- index 1))))
                   #t))))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1290} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1291} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1290}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1290})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1292} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1290})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1293} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1292})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1294} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1292})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1294})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1295} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1294})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1296} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1295})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1297} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1295})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1296}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1297}])
                          (if (and (identifier? id) (stx-list? body))
                              (if (valid-module-id? (stx-e #'id))
                                  (let* ([ctx (make-context id)])
                                    (let* ([body (core-expand-module-begin
                                                   body
                                                   ctx)])
                                      (let* ([body (core-quote-syntax
                                                     (core-cons
                                                       '%\x23;begin
                                                       body)
                                                     (stx-source stx))])
                                        (&module-context-e-set!
                                          ctx
                                          (delay-atomic
                                            (eval-syntax* body)))
                                        (&module-context-code-set!
                                          ctx
                                          body)
                                        (core-bind-syntax! id ctx)
                                        (core-quote-syntax
                                          (core-list
                                            '%\x23;module
                                            (core-quote-syntax id)
                                            body)
                                          (stx-source stx)))))
                                  (raise-syntax-error
                                    #f
                                    "invalid module id; allowed characters are A-Z,a-z,0-9,_,-"
                                    stx
                                    #'id))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1291}))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1291}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1291})))))

(define (core-expand-module-begin body ctx)
  (parameterize ([current-expander-context ctx]
                 [current-expander-phi 0])
    (core-bind-feature! 'gerbil-module #t)
    (let ([stx (core-expand-head (cons '%%begin-module body))])
      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1298} stx])
        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1299} (lambda ()
                                                         (raise-syntax-error
                                                           #f
                                                           "Illegal module body expansion"
                                                           stx))])
          (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1298})
              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1300} (syntax-e
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1298})])
                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1301} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1300})]
                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1302} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1300})])
                  (if (and (identifier?
                             #{csc-h dpuuv4a3mobea70icwo8nvdax-1301})
                           (core-identifier=?
                             #{csc-h dpuuv4a3mobea70icwo8nvdax-1301}
                             '%\x23;begin-module))
                      (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1302}])
                        (if (sealed-syntax? stx)
                            body
                            (core-expand-module-body body)))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1299}))))
              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1299})))))))

(define (core-expand-module-body body)
  (define (expand-special hd K rest r)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1303} hd])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1304} (lambda ()
                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1305} (lambda ()
                                                                                                        (K rest
                                                                                                           (cons
                                                                                                             (core-expand-top
                                                                                                               hd)
                                                                                                             r)))])
                                                         (if (stx-pair?
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1303})
                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1306} (syntax-e
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1303})])
                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1307} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1306})]
                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1308} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1306})])
                                                                 (if (and (identifier?
                                                                            #{csc-h dpuuv4a3mobea70icwo8nvdax-1307})
                                                                          (core-identifier=?
                                                                            #{csc-h dpuuv4a3mobea70icwo8nvdax-1307}
                                                                            '%\x23;export))
                                                                     (K rest
                                                                        (cons
                                                                          hd
                                                                          r))
                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1305}))))
                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1305}))))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1303})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1309} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1303})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1310} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1309})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1311} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1309})])
                (if (and (identifier?
                           #{csc-h dpuuv4a3mobea70icwo8nvdax-1310})
                         (core-identifier=?
                           #{csc-h dpuuv4a3mobea70icwo8nvdax-1310}
                           '%\x23;define-values))
                    (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1311})
                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1312} (syntax-e
                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1311})])
                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1313} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1312})]
                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-1314} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1312})])
                            (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-1313}])
                              (if (stx-pair?
                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1314})
                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1315} (syntax-e
                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1314})])
                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1316} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1315})]
                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1317} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1315})])
                                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1316}])
                                        (if (stx-null?
                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1317})
                                            (if (core-bind-values? hd-bind)
                                                (begin
                                                  (core-bind-values!
                                                    hd-bind)
                                                  (K rest (cons hd r)))
                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304}))
                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304})))))
                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304})))))
                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304}))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304}))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1304})))))
  (define (expand-body rbody)
    (let lp ([rest rbody] [body (list)])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1318} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1318})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1319} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1318})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-1320} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1318})])
              (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1319}])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1320}])
                  (begin
                    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1321} hd])
                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1322} (lambda ()
                                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1323} (lambda ()
                                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1324} (lambda ()
                                                                                                                                                                         (lp rest
                                                                                                                                                                             (cons
                                                                                                                                                                               (core-expand-expression
                                                                                                                                                                                 hd)
                                                                                                                                                                               body)))])
                                                                                                                          (if (stx-pair?
                                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})
                                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1325} (syntax-e
                                                                                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})])
                                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1326} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1325})]
                                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1327} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1325})])
                                                                                                                                  (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-1326}])
                                                                                                                                    (if (core-bound-identifier?
                                                                                                                                          form
                                                                                                                                          special-form-binding?)
                                                                                                                                        (lp rest
                                                                                                                                            (cons
                                                                                                                                              hd
                                                                                                                                              body))
                                                                                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1324})))))
                                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1324}))))])
                                                                         (if (stx-pair?
                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})
                                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1328} (syntax-e
                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})])
                                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1329} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1328})]
                                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1330} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1328})])
                                                                                 (if (and (identifier?
                                                                                            #{csc-h dpuuv4a3mobea70icwo8nvdax-1329})
                                                                                          (core-identifier=?
                                                                                            #{csc-h dpuuv4a3mobea70icwo8nvdax-1329}
                                                                                            '%\x23;export))
                                                                                     (lp rest
                                                                                         (cons
                                                                                           (core-expand-export%
                                                                                             hd)
                                                                                           body))
                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1323}))))
                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1323}))))])
                        (if (stx-pair?
                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1331} (syntax-e
                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1321})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1332} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1331})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1333} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1331})])
                                (if (and (identifier?
                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-1332})
                                         (core-identifier=?
                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-1332}
                                           '%\x23;define-values))
                                    (if (stx-pair?
                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1333})
                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1334} (syntax-e
                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1333})])
                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1335} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1334})]
                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-1336} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1334})])
                                            (let ([hd-bind #{csc-h dpuuv4a3mobea70icwo8nvdax-1335}])
                                              (if (stx-pair?
                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1336})
                                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1337} (syntax-e
                                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1336})])
                                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1338} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1337})]
                                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1339} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1337})])
                                                      (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1338}])
                                                        (if (stx-null?
                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1339})
                                                            (lp rest
                                                                (cons
                                                                  (core-quote-syntax
                                                                    (core-list
                                                                      '%\x23;define-values
                                                                      (core-quote-bind-values
                                                                        hd-bind)
                                                                      (core-expand-expression
                                                                        expr))
                                                                    (stx-source
                                                                      hd))
                                                                  body))
                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1322})))))
                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1322})))))
                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1322}))
                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1322}))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1322}))))))))
            (begin body)))))
  (expand-body
    (core-expand-block
      (cons '%\x23;begin-module body)
      expand-special
      #f
      values)))

(define (core-expand-import/export stx expanded? method
         current-phi expand1)
  (define (K rest r)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1340} rest])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1341} (lambda ()
                                                       r)])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1340})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1342} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1340})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1343} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1342})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1344} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1342})])
                (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1343}])
                  (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1344}])
                    (step hd rest r)))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1341})))))
  (define (step hd rest r)
    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1345} hd])
      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1346} (lambda ()
                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1347} (lambda ()
                                                                                                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1348} (lambda ()
                                                                                                                                                         (if (expanded?
                                                                                                                                                               (stx-e
                                                                                                                                                                 hd))
                                                                                                                                                             (K rest
                                                                                                                                                                (cons
                                                                                                                                                                  (stx-e
                                                                                                                                                                    hd)
                                                                                                                                                                  r))
                                                                                                                                                             (expand1
                                                                                                                                                               hd
                                                                                                                                                               K
                                                                                                                                                               rest
                                                                                                                                                               r)))])
                                                                                                          (if (stx-pair?
                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})
                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1349} (syntax-e
                                                                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})])
                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1350} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1349})]
                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1351} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1349})])
                                                                                                                  (let ([macro #{csc-h dpuuv4a3mobea70icwo8nvdax-1350}])
                                                                                                                    (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1351}])
                                                                                                                      (if (core-bound-identifier?
                                                                                                                            macro
                                                                                                                            syntax-binding?)
                                                                                                                          (K (cons
                                                                                                                               (core-apply-expander
                                                                                                                                 (syntax-local-e
                                                                                                                                   macro)
                                                                                                                                 hd
                                                                                                                                 method)
                                                                                                                               rest)
                                                                                                                             r)
                                                                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1348}))))))
                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1348}))))])
                                                         (if (stx-pair?
                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})
                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1352} (syntax-e
                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})])
                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1353} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1352})]
                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1354} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1352})])
                                                                 (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1355} (stx-e
                                                                                                                   #{csc-h dpuuv4a3mobea70icwo8nvdax-1353})])
                                                                   (if (and (keyword?
                                                                              #{csc-kv dpuuv4a3mobea70icwo8nvdax-1355})
                                                                            (string=?
                                                                              (keyword->string
                                                                                #{csc-kv dpuuv4a3mobea70icwo8nvdax-1355})
                                                                              "begin"))
                                                                       (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1354}])
                                                                         (K (stx-foldr
                                                                              cons
                                                                              rest
                                                                              body)
                                                                            r))
                                                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1347})))))
                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1347}))))])
        (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})
            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1356} (syntax-e
                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1345})])
              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1357} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1356})]
                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1358} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1356})])
                (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1359} (stx-e
                                                                  #{csc-h dpuuv4a3mobea70icwo8nvdax-1357})])
                  (if (and (keyword?
                             #{csc-kv dpuuv4a3mobea70icwo8nvdax-1359})
                           (string=?
                             (keyword->string
                               #{csc-kv dpuuv4a3mobea70icwo8nvdax-1359})
                             "phi"))
                      (if (stx-pair?
                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1358})
                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1360} (syntax-e
                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1358})])
                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1361} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1360})]
                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1362} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1360})])
                              (let ([dphi #{csc-h dpuuv4a3mobea70icwo8nvdax-1361}])
                                (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1362}])
                                  (if (stx-fixnum? dphi)
                                      (let ([rbody (parameterize ([current-phi
                                                                   (fx+ (stx-e
                                                                          dphi)
                                                                        (current-phi))])
                                                     (K body (list)))])
                                        (K rest (fold-right cons r rbody)))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1346}))))))
                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1346}))
                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1346})))))
            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1346})))))
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1363} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1364} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1363}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1363})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1365} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1363})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1366} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1365})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1367} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1365})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1367}])
                (cond
                  [(current-phi) (K body (list))]
                  [else
                   (parameterize ([current-phi (current-expander-phi)])
                     (K body (list)))]))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1364})))))

(define core-expand-import%
  (case-lambda
    [(stx)
     (let* ([internal-expand? #f])
       (define (expand1 hd K rest r)
         (cond
           [(core-bound-module? hd)
            (import1 (syntax-local-e hd) K rest r)]
           [(core-library-module-path? hd)
            (import1
              (import-module (core-resolve-library-module-path hd))
              K
              rest
              r)]
           [(core-library-relative-module-path? hd)
            (import1
              (import-module
                (core-resolve-library-relative-module-path hd))
              K
              rest
              r)]
           [else
            (let ([e (stx-e hd)])
              (cond
                [(pair? e)
                 (case (stx-e (car e))
                   [(spec:) (import-spec hd K rest r)]
                   [(in:) (import-submodule hd K rest r)]
                   [(runtime:) (import-runtime hd K rest r)]
                   [else
                    (raise-syntax-error
                      #f
                      "Bad syntax; illegal import"
                      stx
                      hd)])]
                [(string? e)
                 (import1
                   (import-module
                     (core-resolve-module-path hd (stx-source stx)))
                   K
                   rest
                   r)]
                [(module-context? e) (K rest (cons e r))]
                [else
                 (raise-syntax-error
                   #f
                   "Bad syntax; illegal import"
                   stx
                   hd)]))]))
       (define (import1 ctx K rest r)
         (let ([dphi (fx- (current-import-expander-phi)
                          (current-expander-phi))])
           (K rest
              (cons
                (make-import-set
                  ctx
                  dphi
                  (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1368})
                         (core-module-export->import
                           #{cut-arg dpuuv4a3mobea70icwo8nvdax-1368}
                           #f
                           dphi))
                       (&module-context-export ctx)))
                r))))
       (define (import-submodule hd K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1369} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1370} (lambda ()
                                                            (raise-syntax-error
                                                              #f
                                                              "Bad syntax; invalid syntax-case clause"
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1369}))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1369})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1371} (syntax-e
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1369})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1372} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1371})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1373} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1371})])
                     (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1373}])
                       (import1 (import-spec-source spath) K rest r))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1370})))))
       (define (import-runtime hd K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1374} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1375} (lambda ()
                                                            (raise-syntax-error
                                                              #f
                                                              "Bad syntax; invalid syntax-case clause"
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1374}))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1374})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1376} (syntax-e
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1374})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1377} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1376})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1378} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1376})])
                     (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1378}])
                       (K rest (cons (import-spec-source spath) r)))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1375})))))
       (define (import-spec hd K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1379} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1380} (lambda ()
                                                            (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1381} (lambda ()
                                                                                                             (raise-syntax-error
                                                                                                               #f
                                                                                                               "Bad syntax; invalid syntax-case clause"
                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1379}))])
                                                              (if (stx-pair?
                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})
                                                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1382} (syntax-e
                                                                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})])
                                                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1383} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1382})]
                                                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1384} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1382})])
                                                                      (if (stx-pair?
                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1384})
                                                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1385} (syntax-e
                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1384})])
                                                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1386} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1385})]
                                                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1387} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1385})])
                                                                              (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-1386}])
                                                                                (let ([specs #{csc-t dpuuv4a3mobea70icwo8nvdax-1387}])
                                                                                  (let ([src-ctx (import-spec-source
                                                                                                   path)]
                                                                                        [exports (make-hash-table)]
                                                                                        [specs (syntax->list
                                                                                                 specs)])
                                                                                    (for-each
                                                                                      (lambda (out)
                                                                                        (hash-put!
                                                                                          exports
                                                                                          (cons
                                                                                            (&module-export-phi
                                                                                              out)
                                                                                            (&module-export-name
                                                                                              out))
                                                                                          out))
                                                                                      (&module-context-export
                                                                                        src-ctx))
                                                                                    (K rest
                                                                                       (let ([#{f dpuuv4a3mobea70icwo8nvdax-1388} (lambda (spec
                                                                                                                                           r)
                                                                                                                                    (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1389} spec])
                                                                                                                                      (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1390} (lambda ()
                                                                                                                                                                                       (raise-syntax-error
                                                                                                                                                                                         #f
                                                                                                                                                                                         "Bad syntax; invalid syntax-case clause"
                                                                                                                                                                                         #{csc-e dpuuv4a3mobea70icwo8nvdax-1389}))])
                                                                                                                                        (if (stx-pair?
                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1389})
                                                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1391} (syntax-e
                                                                                                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1389})])
                                                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1392} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1391})]
                                                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1393} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1391})])
                                                                                                                                                (let ([phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1392}])
                                                                                                                                                  (if (stx-pair?
                                                                                                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1393})
                                                                                                                                                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1394} (syntax-e
                                                                                                                                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1393})])
                                                                                                                                                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1395} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1394})]
                                                                                                                                                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-1396} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1394})])
                                                                                                                                                          (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1395}])
                                                                                                                                                            (if (stx-pair?
                                                                                                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1396})
                                                                                                                                                                (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1397} (syntax-e
                                                                                                                                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1396})])
                                                                                                                                                                  (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1398} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1397})]
                                                                                                                                                                        [#{csc-t dpuuv4a3mobea70icwo8nvdax-1399} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1397})])
                                                                                                                                                                    (let ([src-phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1398}])
                                                                                                                                                                      (if (stx-pair?
                                                                                                                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1399})
                                                                                                                                                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1400} (syntax-e
                                                                                                                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1399})])
                                                                                                                                                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1401} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1400})]
                                                                                                                                                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1402} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1400})])
                                                                                                                                                                              (let ([src-name #{csc-h dpuuv4a3mobea70icwo8nvdax-1401}])
                                                                                                                                                                                (if (stx-null?
                                                                                                                                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1402})
                                                                                                                                                                                    (if (and (stx-fixnum?
                                                                                                                                                                                               src-phi)
                                                                                                                                                                                             (identifier?
                                                                                                                                                                                               src-name)
                                                                                                                                                                                             (stx-fixnum?
                                                                                                                                                                                               phi)
                                                                                                                                                                                             (identifier?
                                                                                                                                                                                               name))
                                                                                                                                                                                        (let ([src-phi (stx-e
                                                                                                                                                                                                         src-phi)]
                                                                                                                                                                                              [src-name (core-identifier-key
                                                                                                                                                                                                          src-name)]
                                                                                                                                                                                              [phi (stx-e
                                                                                                                                                                                                     phi)]
                                                                                                                                                                                              [name (core-identifier-key
                                                                                                                                                                                                      name)])
                                                                                                                                                                                          (cond
                                                                                                                                                                                            [(hash-get
                                                                                                                                                                                               exports
                                                                                                                                                                                               (cons
                                                                                                                                                                                                 src-phi
                                                                                                                                                                                                 src-name)) =>
                                                                                                                                                                                             (lambda (out)
                                                                                                                                                                                               (cons
                                                                                                                                                                                                 (core-module-export->import
                                                                                                                                                                                                   out
                                                                                                                                                                                                   name
                                                                                                                                                                                                   (fx- phi
                                                                                                                                                                                                        src-phi))
                                                                                                                                                                                                 r))]
                                                                                                                                                                                            [else
                                                                                                                                                                                             (raise-syntax-error
                                                                                                                                                                                               #f
                                                                                                                                                                                               "Bad syntax; no matching export"
                                                                                                                                                                                               stx
                                                                                                                                                                                               hd)]))
                                                                                                                                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390}))
                                                                                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))])
                                                                                         (fold-left
                                                                                           (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1403}
                                                                                                    #{e dpuuv4a3mobea70icwo8nvdax-1404})
                                                                                             (#{f dpuuv4a3mobea70icwo8nvdax-1388}
                                                                                               #{e dpuuv4a3mobea70icwo8nvdax-1404}
                                                                                               #{a dpuuv4a3mobea70icwo8nvdax-1403}))
                                                                                           r
                                                                                           specs))))))))
                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1381}))))
                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1381}))))])
             (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})
                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1405} (syntax-e
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})])
                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1406} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1405})]
                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1407} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1405})])
                     (if (stx-pair?
                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1407})
                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1408} (syntax-e
                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1407})])
                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1409} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1408})]
                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-1410} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1408})])
                             (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-1409}])
                               (if (stx-null?
                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1410})
                                   (K rest
                                      (cons (import-spec-source path) r))
                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380})))))
                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380}))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380})))))
       (define (import-spec-source spath)
         (core-import-nested-module spath stx))
       (define (import! rbody)
         (define current-ctx (current-expander-context))
         (define deps (make-hash-table-eq))
         (define (bind! hd) (core-bind-import! hd current-ctx))
         (let lp ([rest rbody] [body (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1411} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1411})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1412} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1411})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-1413} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1411})])
                   (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1412}])
                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1413}])
                       (begin
                         (cond
                           [(module-import? hd)
                            (bind! hd)
                            (when (and (fxpositive?
                                         (&module-import-phi hd))
                                       (fxzero?
                                         (&module-export-phi
                                           (&module-import-source hd))))
                              (hash-put!
                                deps
                                (&module-export-context
                                  (&module-import-source hd))
                                #t))]
                           [(import-set? hd)
                            (for-each bind! (&import-set-imports hd))
                            (when (fxpositive? (&import-set-phi hd))
                              (hash-put! deps (&import-set-source hd) #t))]
                           [(module-context? hd)]
                           [else
                            (raise-syntax-error
                              #f
                              "Unexpected import"
                              stx
                              hd)])
                         (lp rest (cons hd body))))))
                 (begin
                   (when (module-context? current-ctx)
                     (&module-context-import-set!
                       current-ctx
                       (let ([#{f dpuuv4a3mobea70icwo8nvdax-1414} cons])
                         (fold-left
                           (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1415}
                                    #{e dpuuv4a3mobea70icwo8nvdax-1416})
                             (#{f dpuuv4a3mobea70icwo8nvdax-1414}
                               #{e dpuuv4a3mobea70icwo8nvdax-1416}
                               #{a dpuuv4a3mobea70icwo8nvdax-1415}))
                           (&module-context-import current-ctx)
                           body))))
                   (hash-for-each (lambda (ctx _) (eval-module ctx)) deps)
                   body)))))
       (define (expanded-import? e)
         (or (import-set? e) (module-import? e) (module-context? e)))
       (let ([rbody (core-expand-import/export stx expanded-import? 'apply-import-expander
                      current-import-expander-phi expand1)])
         (if internal-expand?
             (reverse rbody)
             (core-quote-syntax
               (core-cons '%\x23;import (import! rbody))
               (stx-source stx)))))]
    [(stx internal-expand?)
     (define (expand1 hd K rest r)
       (cond
         [(core-bound-module? hd)
          (import1 (syntax-local-e hd) K rest r)]
         [(core-library-module-path? hd)
          (import1
            (import-module (core-resolve-library-module-path hd))
            K
            rest
            r)]
         [(core-library-relative-module-path? hd)
          (import1
            (import-module
              (core-resolve-library-relative-module-path hd))
            K
            rest
            r)]
         [else
          (let ([e (stx-e hd)])
            (cond
              [(pair? e)
               (case (stx-e (car e))
                 [(spec:) (import-spec hd K rest r)]
                 [(in:) (import-submodule hd K rest r)]
                 [(runtime:) (import-runtime hd K rest r)]
                 [else
                  (raise-syntax-error
                    #f
                    "Bad syntax; illegal import"
                    stx
                    hd)])]
              [(string? e)
               (import1
                 (import-module
                   (core-resolve-module-path hd (stx-source stx)))
                 K
                 rest
                 r)]
              [(module-context? e) (K rest (cons e r))]
              [else
               (raise-syntax-error
                 #f
                 "Bad syntax; illegal import"
                 stx
                 hd)]))]))
     (define (import1 ctx K rest r)
       (let ([dphi (fx- (current-import-expander-phi)
                        (current-expander-phi))])
         (K rest
            (cons
              (make-import-set
                ctx
                dphi
                (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1368})
                       (core-module-export->import
                         #{cut-arg dpuuv4a3mobea70icwo8nvdax-1368}
                         #f
                         dphi))
                     (&module-context-export ctx)))
              r))))
     (define (import-submodule hd K rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1369} hd])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1370} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; invalid syntax-case clause"
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1369}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1369})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1371} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1369})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1372} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1371})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1373} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1371})])
                   (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1373}])
                     (import1 (import-spec-source spath) K rest r))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1370})))))
     (define (import-runtime hd K rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1374} hd])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1375} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; invalid syntax-case clause"
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1374}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1374})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1376} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1374})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1377} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1376})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1378} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1376})])
                   (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1378}])
                     (K rest (cons (import-spec-source spath) r)))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1375})))))
     (define (import-spec hd K rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1379} hd])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1380} (lambda ()
                                                          (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1381} (lambda ()
                                                                                                           (raise-syntax-error
                                                                                                             #f
                                                                                                             "Bad syntax; invalid syntax-case clause"
                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1379}))])
                                                            (if (stx-pair?
                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})
                                                                (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1382} (syntax-e
                                                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})])
                                                                  (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1383} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1382})]
                                                                        [#{csc-t dpuuv4a3mobea70icwo8nvdax-1384} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1382})])
                                                                    (if (stx-pair?
                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1384})
                                                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1385} (syntax-e
                                                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1384})])
                                                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1386} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1385})]
                                                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-1387} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1385})])
                                                                            (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-1386}])
                                                                              (let ([specs #{csc-t dpuuv4a3mobea70icwo8nvdax-1387}])
                                                                                (let ([src-ctx (import-spec-source
                                                                                                 path)]
                                                                                      [exports (make-hash-table)]
                                                                                      [specs (syntax->list
                                                                                               specs)])
                                                                                  (for-each
                                                                                    (lambda (out)
                                                                                      (hash-put!
                                                                                        exports
                                                                                        (cons
                                                                                          (&module-export-phi
                                                                                            out)
                                                                                          (&module-export-name
                                                                                            out))
                                                                                        out))
                                                                                    (&module-context-export
                                                                                      src-ctx))
                                                                                  (K rest
                                                                                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-1388} (lambda (spec
                                                                                                                                         r)
                                                                                                                                  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1389} spec])
                                                                                                                                    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1390} (lambda ()
                                                                                                                                                                                     (raise-syntax-error
                                                                                                                                                                                       #f
                                                                                                                                                                                       "Bad syntax; invalid syntax-case clause"
                                                                                                                                                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1389}))])
                                                                                                                                      (if (stx-pair?
                                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1389})
                                                                                                                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1391} (syntax-e
                                                                                                                                                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1389})])
                                                                                                                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1392} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1391})]
                                                                                                                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1393} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1391})])
                                                                                                                                              (let ([phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1392}])
                                                                                                                                                (if (stx-pair?
                                                                                                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1393})
                                                                                                                                                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1394} (syntax-e
                                                                                                                                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1393})])
                                                                                                                                                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1395} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1394})]
                                                                                                                                                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-1396} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1394})])
                                                                                                                                                        (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1395}])
                                                                                                                                                          (if (stx-pair?
                                                                                                                                                                #{csc-t dpuuv4a3mobea70icwo8nvdax-1396})
                                                                                                                                                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1397} (syntax-e
                                                                                                                                                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-1396})])
                                                                                                                                                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1398} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1397})]
                                                                                                                                                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1399} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1397})])
                                                                                                                                                                  (let ([src-phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1398}])
                                                                                                                                                                    (if (stx-pair?
                                                                                                                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1399})
                                                                                                                                                                        (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1400} (syntax-e
                                                                                                                                                                                                                         #{csc-t dpuuv4a3mobea70icwo8nvdax-1399})])
                                                                                                                                                                          (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1401} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1400})]
                                                                                                                                                                                [#{csc-t dpuuv4a3mobea70icwo8nvdax-1402} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1400})])
                                                                                                                                                                            (let ([src-name #{csc-h dpuuv4a3mobea70icwo8nvdax-1401}])
                                                                                                                                                                              (if (stx-null?
                                                                                                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1402})
                                                                                                                                                                                  (if (and (stx-fixnum?
                                                                                                                                                                                             src-phi)
                                                                                                                                                                                           (identifier?
                                                                                                                                                                                             src-name)
                                                                                                                                                                                           (stx-fixnum?
                                                                                                                                                                                             phi)
                                                                                                                                                                                           (identifier?
                                                                                                                                                                                             name))
                                                                                                                                                                                      (let ([src-phi (stx-e
                                                                                                                                                                                                       src-phi)]
                                                                                                                                                                                            [src-name (core-identifier-key
                                                                                                                                                                                                        src-name)]
                                                                                                                                                                                            [phi (stx-e
                                                                                                                                                                                                   phi)]
                                                                                                                                                                                            [name (core-identifier-key
                                                                                                                                                                                                    name)])
                                                                                                                                                                                        (cond
                                                                                                                                                                                          [(hash-get
                                                                                                                                                                                             exports
                                                                                                                                                                                             (cons
                                                                                                                                                                                               src-phi
                                                                                                                                                                                               src-name)) =>
                                                                                                                                                                                           (lambda (out)
                                                                                                                                                                                             (cons
                                                                                                                                                                                               (core-module-export->import
                                                                                                                                                                                                 out
                                                                                                                                                                                                 name
                                                                                                                                                                                                 (fx- phi
                                                                                                                                                                                                      src-phi))
                                                                                                                                                                                               r))]
                                                                                                                                                                                          [else
                                                                                                                                                                                           (raise-syntax-error
                                                                                                                                                                                             #f
                                                                                                                                                                                             "Bad syntax; no matching export"
                                                                                                                                                                                             stx
                                                                                                                                                                                             hd)]))
                                                                                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390}))
                                                                                                                                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))
                                                                                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1390})))))])
                                                                                       (fold-left
                                                                                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1403}
                                                                                                  #{e dpuuv4a3mobea70icwo8nvdax-1404})
                                                                                           (#{f dpuuv4a3mobea70icwo8nvdax-1388}
                                                                                             #{e dpuuv4a3mobea70icwo8nvdax-1404}
                                                                                             #{a dpuuv4a3mobea70icwo8nvdax-1403}))
                                                                                         r
                                                                                         specs))))))))
                                                                        (#{csc-E dpuuv4a3mobea70icwo8nvdax-1381}))))
                                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1381}))))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1405} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1379})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1406} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1405})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1407} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1405})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1407})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1408} (syntax-e
                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1407})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1409} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1408})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-1410} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1408})])
                           (let ([path #{csc-h dpuuv4a3mobea70icwo8nvdax-1409}])
                             (if (stx-null?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1410})
                                 (K rest
                                    (cons (import-spec-source path) r))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1380})))))
     (define (import-spec-source spath)
       (core-import-nested-module spath stx))
     (define (import! rbody)
       (define current-ctx (current-expander-context))
       (define deps (make-hash-table-eq))
       (define (bind! hd) (core-bind-import! hd current-ctx))
       (let lp ([rest rbody] [body (list)])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1411} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1411})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1412} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1411})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-1413} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1411})])
                 (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1412}])
                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1413}])
                     (begin
                       (cond
                         [(module-import? hd)
                          (bind! hd)
                          (when (and (fxpositive? (&module-import-phi hd))
                                     (fxzero?
                                       (&module-export-phi
                                         (&module-import-source hd))))
                            (hash-put!
                              deps
                              (&module-export-context
                                (&module-import-source hd))
                              #t))]
                         [(import-set? hd)
                          (for-each bind! (&import-set-imports hd))
                          (when (fxpositive? (&import-set-phi hd))
                            (hash-put! deps (&import-set-source hd) #t))]
                         [(module-context? hd)]
                         [else
                          (raise-syntax-error
                            #f
                            "Unexpected import"
                            stx
                            hd)])
                       (lp rest (cons hd body))))))
               (begin
                 (when (module-context? current-ctx)
                   (&module-context-import-set!
                     current-ctx
                     (let ([#{f dpuuv4a3mobea70icwo8nvdax-1414} cons])
                       (fold-left
                         (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1415}
                                  #{e dpuuv4a3mobea70icwo8nvdax-1416})
                           (#{f dpuuv4a3mobea70icwo8nvdax-1414}
                             #{e dpuuv4a3mobea70icwo8nvdax-1416}
                             #{a dpuuv4a3mobea70icwo8nvdax-1415}))
                         (&module-context-import current-ctx)
                         body))))
                 (hash-for-each (lambda (ctx _) (eval-module ctx)) deps)
                 body)))))
     (define (expanded-import? e)
       (or (import-set? e) (module-import? e) (module-context? e)))
     (let ([rbody (core-expand-import/export stx expanded-import? 'apply-import-expander
                    current-import-expander-phi expand1)])
       (if internal-expand?
           (reverse rbody)
           (core-quote-syntax
             (core-cons '%\x23;import (import! rbody))
             (stx-source stx))))]))

(define (core-import-nested-module spath where)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1417} spath])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1418} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1417}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1417})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1419} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1417})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1420} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1419})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1421} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1419})])
              (let ([origin #{csc-h dpuuv4a3mobea70icwo8nvdax-1420}])
                (let ([sub #{csc-t dpuuv4a3mobea70icwo8nvdax-1421}])
                  (let ([origin-ctx (if (stx-false? origin)
                                        (current-expander-context)
                                        (import-module origin))])
                    (let lp ([rest sub] [ctx origin-ctx])
                      (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1422} rest])
                        (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1423} (lambda ()
                                                                         ctx)])
                          (if (stx-pair?
                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1422})
                              (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1424} (syntax-e
                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1422})])
                                (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1425} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1424})]
                                      [#{csc-t dpuuv4a3mobea70icwo8nvdax-1426} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1424})])
                                  (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1425}])
                                    (let ([rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1426}])
                                      (let ([bind (resolve-identifier
                                                    id
                                                    0
                                                    ctx)])
                                        (unless (and (syntax-binding? bind)
                                                     (module-context?
                                                       (&syntax-binding-e
                                                         bind)))
                                          (raise-syntax-error #f
                                            "Bad syntax; not bound as module"
                                            where spath id))
                                        (lp rest
                                            (&syntax-binding-e bind)))))))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1423}))))))))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1418})))))

(define (core-expand-import-source hd)
  (core-expand-import% (list 'import-internal% hd) #t))

(define core-expand-export%
  (case-lambda
    [(stx)
     (let* ([internal-expand? #f])
       (define make-export
         (case-lambda
           [(bind)
            (let* ([phi (current-export-expander-phi)]
                   [ctx (current-expander-context)]
                   [name #f])
              (let* ([key (&binding-key bind)])
                (let* ([export-key (if name
                                       (core-identifier-key name)
                                       key)])
                  (make-module-export ctx key phi export-key
                    (or (extern-binding? bind) (import-binding? bind))))))]
           [(bind phi)
            (let* ([ctx (current-expander-context)] [name #f])
              (let* ([key (&binding-key bind)])
                (let* ([export-key (if name
                                       (core-identifier-key name)
                                       key)])
                  (make-module-export ctx key phi export-key
                    (or (extern-binding? bind) (import-binding? bind))))))]
           [(bind phi ctx)
            (let* ([name #f])
              (let* ([key (&binding-key bind)])
                (let* ([export-key (if name
                                       (core-identifier-key name)
                                       key)])
                  (make-module-export ctx key phi export-key
                    (or (extern-binding? bind) (import-binding? bind))))))]
           [(bind phi ctx name)
            (let* ([key (&binding-key bind)])
              (let* ([export-key (if name
                                     (core-identifier-key name)
                                     key)])
                (make-module-export ctx key phi export-key
                  (or (extern-binding? bind) (import-binding? bind)))))]))
       (define (expand1 hd K rest r)
         (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1427} hd])
           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1428} (lambda ()
                                                            (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1429} (lambda ()
                                                                                                             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1430} (lambda ()
                                                                                                                                                              (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1431} (lambda ()
                                                                                                                                                                                                               (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1432} (lambda ()
                                                                                                                                                                                                                                                                (raise-syntax-error
                                                                                                                                                                                                                                                                  #f
                                                                                                                                                                                                                                                                  "Bad syntax; illegal export"
                                                                                                                                                                                                                                                                  stx
                                                                                                                                                                                                                                                                  hd))])
                                                                                                                                                                                                                 (if (stx-pair?
                                                                                                                                                                                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                                                                                                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1433} (syntax-e
                                                                                                                                                                                                                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                                                                                                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1434} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1433})]
                                                                                                                                                                                                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-1435} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1433})])
                                                                                                                                                                                                                         (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1436} (stx-e
                                                                                                                                                                                                                                                                           #{csc-h dpuuv4a3mobea70icwo8nvdax-1434})])
                                                                                                                                                                                                                           (if (and (keyword?
                                                                                                                                                                                                                                      #{csc-kv dpuuv4a3mobea70icwo8nvdax-1436})
                                                                                                                                                                                                                                    (string=?
                                                                                                                                                                                                                                      (keyword->string
                                                                                                                                                                                                                                        #{csc-kv dpuuv4a3mobea70icwo8nvdax-1436})
                                                                                                                                                                                                                                      "import"))
                                                                                                                                                                                                                               (let ([in #{csc-t dpuuv4a3mobea70icwo8nvdax-1435}])
                                                                                                                                                                                                                                 (if (stx-list?
                                                                                                                                                                                                                                       in)
                                                                                                                                                                                                                                     (let lp ([in-rest in]
                                                                                                                                                                                                                                              [r r])
                                                                                                                                                                                                                                       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1437} in-rest])
                                                                                                                                                                                                                                         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1438} (lambda ()
                                                                                                                                                                                                                                                                                          (K rest
                                                                                                                                                                                                                                                                                             r))])
                                                                                                                                                                                                                                           (if (stx-pair?
                                                                                                                                                                                                                                                 #{csc-e dpuuv4a3mobea70icwo8nvdax-1437})
                                                                                                                                                                                                                                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1439} (syntax-e
                                                                                                                                                                                                                                                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1437})])
                                                                                                                                                                                                                                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1440} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1439})]
                                                                                                                                                                                                                                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1441} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1439})])
                                                                                                                                                                                                                                                   (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1440}])
                                                                                                                                                                                                                                                     (let ([in-rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1441}])
                                                                                                                                                                                                                                                       (let ([src (cond
                                                                                                                                                                                                                                                                    [(core-bound-module?
                                                                                                                                                                                                                                                                       hd)
                                                                                                                                                                                                                                                                     (syntax-local-e
                                                                                                                                                                                                                                                                       hd)]
                                                                                                                                                                                                                                                                    [(core-library-module-path?
                                                                                                                                                                                                                                                                       hd)
                                                                                                                                                                                                                                                                     (import-module
                                                                                                                                                                                                                                                                       (core-resolve-library-module-path
                                                                                                                                                                                                                                                                         hd))]
                                                                                                                                                                                                                                                                    [(core-library-relative-module-path?
                                                                                                                                                                                                                                                                       hd)
                                                                                                                                                                                                                                                                     (import-module
                                                                                                                                                                                                                                                                       (core-resolve-library-relative-module-path
                                                                                                                                                                                                                                                                         hd))]
                                                                                                                                                                                                                                                                    [(stx-string?
                                                                                                                                                                                                                                                                       hd)
                                                                                                                                                                                                                                                                     (import-module
                                                                                                                                                                                                                                                                       (core-resolve-module-path
                                                                                                                                                                                                                                                                         hd
                                                                                                                                                                                                                                                                         (stx-source
                                                                                                                                                                                                                                                                           stx)))]
                                                                                                                                                                                                                                                                    [else
                                                                                                                                                                                                                                                                     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1442} hd])
                                                                                                                                                                                                                                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1443} (lambda ()
                                                                                                                                                                                                                                                                                                                        (raise-syntax-error
                                                                                                                                                                                                                                                                                                                          #f
                                                                                                                                                                                                                                                                                                                          "Bad syntax; illegal re-export"
                                                                                                                                                                                                                                                                                                                          stx
                                                                                                                                                                                                                                                                                                                          hd))])
                                                                                                                                                                                                                                                                         (if (stx-pair?
                                                                                                                                                                                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1442})
                                                                                                                                                                                                                                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1444} (syntax-e
                                                                                                                                                                                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1442})])
                                                                                                                                                                                                                                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1445} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1444})]
                                                                                                                                                                                                                                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1446} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1444})])
                                                                                                                                                                                                                                                                                 (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1447} (stx-e
                                                                                                                                                                                                                                                                                                                                   #{csc-h dpuuv4a3mobea70icwo8nvdax-1445})])
                                                                                                                                                                                                                                                                                   (if (and (keyword?
                                                                                                                                                                                                                                                                                              #{csc-kv dpuuv4a3mobea70icwo8nvdax-1447})
                                                                                                                                                                                                                                                                                            (string=?
                                                                                                                                                                                                                                                                                              (keyword->string
                                                                                                                                                                                                                                                                                                #{csc-kv dpuuv4a3mobea70icwo8nvdax-1447})
                                                                                                                                                                                                                                                                                              "in"))
                                                                                                                                                                                                                                                                                       (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1446}])
                                                                                                                                                                                                                                                                                         (core-import-nested-module
                                                                                                                                                                                                                                                                                           spath
                                                                                                                                                                                                                                                                                           stx))
                                                                                                                                                                                                                                                                                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1443})))))
                                                                                                                                                                                                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1443}))))])])
                                                                                                                                                                                                                                                         (lp in-rest
                                                                                                                                                                                                                                                             (export-imports
                                                                                                                                                                                                                                                               src
                                                                                                                                                                                                                                                               r)))))))
                                                                                                                                                                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1438})))))
                                                                                                                                                                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432})))
                                                                                                                                                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432})))))
                                                                                                                                                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432}))))])
                                                                                                                                                                (if (stx-pair?
                                                                                                                                                                      #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                                                                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1448} (syntax-e
                                                                                                                                                                                                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                                                                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1449} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1448})]
                                                                                                                                                                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-1450} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1448})])
                                                                                                                                                                        (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1451} (stx-e
                                                                                                                                                                                                                          #{csc-h dpuuv4a3mobea70icwo8nvdax-1449})])
                                                                                                                                                                          (if (and (keyword?
                                                                                                                                                                                     #{csc-kv dpuuv4a3mobea70icwo8nvdax-1451})
                                                                                                                                                                                   (string=?
                                                                                                                                                                                     (keyword->string
                                                                                                                                                                                       #{csc-kv dpuuv4a3mobea70icwo8nvdax-1451})
                                                                                                                                                                                     "rename"))
                                                                                                                                                                              (if (stx-pair?
                                                                                                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1450})
                                                                                                                                                                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1452} (syntax-e
                                                                                                                                                                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1450})])
                                                                                                                                                                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1453} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1452})]
                                                                                                                                                                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1454} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1452})])
                                                                                                                                                                                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1453}])
                                                                                                                                                                                        (if (stx-pair?
                                                                                                                                                                                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1454})
                                                                                                                                                                                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1455} (syntax-e
                                                                                                                                                                                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1454})])
                                                                                                                                                                                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1456} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1455})]
                                                                                                                                                                                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1457} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1455})])
                                                                                                                                                                                                (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1456}])
                                                                                                                                                                                                  (if (stx-null?
                                                                                                                                                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1457})
                                                                                                                                                                                                      (let ([phi (current-export-expander-phi)])
                                                                                                                                                                                                        (cond
                                                                                                                                                                                                          [(core-resolve-identifier
                                                                                                                                                                                                             id
                                                                                                                                                                                                             phi) =>
                                                                                                                                                                                                           (lambda (bind)
                                                                                                                                                                                                             (K rest
                                                                                                                                                                                                                (cons
                                                                                                                                                                                                                  (make-export
                                                                                                                                                                                                                    bind
                                                                                                                                                                                                                    phi
                                                                                                                                                                                                                    (current-expander-context)
                                                                                                                                                                                                                    name)
                                                                                                                                                                                                                  r)))]
                                                                                                                                                                                                          [else
                                                                                                                                                                                                           (raise-syntax-error
                                                                                                                                                                                                             #f
                                                                                                                                                                                                             "Reference to unbound identifier"
                                                                                                                                                                                                             stx
                                                                                                                                                                                                             hd
                                                                                                                                                                                                             id)]))
                                                                                                                                                                                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431}))
                                                                                                                                                                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431}))))])
                                                                                                               (if (stx-pair?
                                                                                                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1458} (syntax-e
                                                                                                                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1459} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1458})]
                                                                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1460} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1458})])
                                                                                                                       (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1461} (stx-e
                                                                                                                                                                         #{csc-h dpuuv4a3mobea70icwo8nvdax-1459})])
                                                                                                                         (if (and (keyword?
                                                                                                                                    #{csc-kv dpuuv4a3mobea70icwo8nvdax-1461})
                                                                                                                                  (string=?
                                                                                                                                    (keyword->string
                                                                                                                                      #{csc-kv dpuuv4a3mobea70icwo8nvdax-1461})
                                                                                                                                    "spec"))
                                                                                                                             (if (stx-pair?
                                                                                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1460})
                                                                                                                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1462} (syntax-e
                                                                                                                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1460})])
                                                                                                                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1463} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1462})]
                                                                                                                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1464} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1462})])
                                                                                                                                     (let ([phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1463}])
                                                                                                                                       (if (stx-pair?
                                                                                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1464})
                                                                                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1465} (syntax-e
                                                                                                                                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1464})])
                                                                                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1466} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1465})]
                                                                                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-1467} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1465})])
                                                                                                                                               (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1466}])
                                                                                                                                                 (if (stx-pair?
                                                                                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1467})
                                                                                                                                                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1468} (syntax-e
                                                                                                                                                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1467})])
                                                                                                                                                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1469} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1468})]
                                                                                                                                                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-1470} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1468})])
                                                                                                                                                         (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1469}])
                                                                                                                                                           (if (stx-null?
                                                                                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1470})
                                                                                                                                                               (if (and (stx-fixnum?
                                                                                                                                                                          phi)
                                                                                                                                                                        (identifier?
                                                                                                                                                                          id)
                                                                                                                                                                        (identifier?
                                                                                                                                                                          name))
                                                                                                                                                                   (let ([phi (stx-e
                                                                                                                                                                                phi)])
                                                                                                                                                                     (cond
                                                                                                                                                                       [(core-resolve-identifier
                                                                                                                                                                          id
                                                                                                                                                                          phi) =>
                                                                                                                                                                        (lambda (bind)
                                                                                                                                                                          (K rest
                                                                                                                                                                             (cons
                                                                                                                                                                               (make-export
                                                                                                                                                                                 bind
                                                                                                                                                                                 phi
                                                                                                                                                                                 (current-expander-context)
                                                                                                                                                                                 name)
                                                                                                                                                                               r)))]
                                                                                                                                                                       [else
                                                                                                                                                                        (raise-syntax-error
                                                                                                                                                                          #f
                                                                                                                                                                          "Reference to unbound identifier"
                                                                                                                                                                          stx
                                                                                                                                                                          hd
                                                                                                                                                                          id)]))
                                                                                                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))
                                                                                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))
                                                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))))])
                                                              (let ([id #{csc-e dpuuv4a3mobea70icwo8nvdax-1427}])
                                                                (if (identifier?
                                                                      id)
                                                                    (cond
                                                                      [(core-resolve-identifier
                                                                         id
                                                                         (current-export-expander-phi)) =>
                                                                       (lambda (bind)
                                                                         (K rest
                                                                            (cons
                                                                              (make-export
                                                                                bind)
                                                                              r)))]
                                                                      [else
                                                                       (raise-syntax-error
                                                                         #f
                                                                         "Reference to unbound identifier"
                                                                         stx
                                                                         hd)])
                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1429})))))])
             (if (eq? (stx-e #{csc-e dpuuv4a3mobea70icwo8nvdax-1427}) #t)
                 (let* ([current-ctx (current-expander-context)])
                   (let* ([current-phi (current-export-expander-phi)])
                     (let* ([phi-ctx (core-context-shift
                                       current-ctx
                                       current-phi)])
                       (let* ([phi-bind (hash->list
                                          (&expander-context-table
                                            phi-ctx))])
                         (let lp ([bind-rest phi-bind] [set (list)])
                           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1471} bind-rest])
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1471})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1472} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1471})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-1473} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1471})])
                                   (if (pair?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-1472})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1474} (car #{hd dpuuv4a3mobea70icwo8nvdax-1472})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-1475} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-1472})])
                                         (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1474}])
                                           (let ([bind #{tl dpuuv4a3mobea70icwo8nvdax-1475}])
                                             (let ([bind-rest #{tl dpuuv4a3mobea70icwo8nvdax-1473}])
                                               (begin
                                                 (if (or (import-binding?
                                                           bind)
                                                         (private-feature-binding?
                                                           bind))
                                                     (lp bind-rest set)
                                                     (lp bind-rest
                                                         (cons
                                                           (make-export
                                                             bind
                                                             current-phi
                                                             current-ctx)
                                                           set))))))))
                                       (begin
                                         (K rest
                                            (cons
                                              (make-export-set
                                                #f
                                                current-phi
                                                set)
                                              r)))))
                                 (begin
                                   (K rest
                                      (cons
                                        (make-export-set
                                          #f
                                          current-phi
                                          set)
                                        r))))))))))
                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1428})))))
       (define (export-imports src r)
         (define current-ctx (current-expander-context))
         (define current-phi (current-export-expander-phi))
         (define (import->export in)
           (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1476} in])
             (let ([out (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                          1)]
                   [key (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                          2)]
                   [phi (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                          3)])
               (make-module-export current-ctx key phi key #t))))
         (define (fold-e in r)
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1477} in])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1478} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-1479} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                   (let ([module-import #{hd dpuuv4a3mobea70icwo8nvdax-1478}])
                     (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1479})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1480} (car #{tl dpuuv4a3mobea70icwo8nvdax-1479})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-1481} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1479})])
                           (let ([out #{hd dpuuv4a3mobea70icwo8nvdax-1480}])
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-1481})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1482} (car #{tl dpuuv4a3mobea70icwo8nvdax-1481})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-1483} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1481})])
                                   (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1482}])
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-1483})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1484} (car #{tl dpuuv4a3mobea70icwo8nvdax-1483})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-1485} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1483})])
                                           (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1484}])
                                             (if (null?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-1485})
                                                 (begin
                                                   (if (and (fx= phi
                                                                 current-phi)
                                                            (eq? src
                                                                 (&module-export-context
                                                                   out)))
                                                       (cons
                                                         (import->export
                                                           in)
                                                         r)
                                                       r))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                                       (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                                               (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                                                 (if (pair?
                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                                       (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                                         (if (pair?
                                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                                               (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                                                 (if (null?
                                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                                     (begin
                                                                                       (if (and (fx= phi
                                                                                                     current-phi)
                                                                                                (eq? src
                                                                                                     ctx))
                                                                                           (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                                               r)
                                                                                                                                        (cons
                                                                                                                                          (import->export
                                                                                                                                            in)
                                                                                                                                          r))])
                                                                                             (fold-left
                                                                                               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                                        #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                                                 (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                                   #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                                   #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                                               r
                                                                                               imports))
                                                                                           r))
                                                                                     (begin
                                                                                       r))))
                                                                             (begin
                                                                               r))))
                                                                     (begin
                                                                       r))))
                                                             (begin r))))
                                                     (begin r)))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                               (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                                       (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                               (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                                 (if (pair?
                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                                       (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                                         (if (null?
                                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                             (begin
                                                                               (if (and (fx= phi
                                                                                             current-phi)
                                                                                        (eq? src
                                                                                             ctx))
                                                                                   (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                                       r)
                                                                                                                                (cons
                                                                                                                                  (import->export
                                                                                                                                    in)
                                                                                                                                  r))])
                                                                                     (fold-left
                                                                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                                #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                                         (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                           #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                           #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                                       r
                                                                                       imports))
                                                                                   r))
                                                                             (begin
                                                                               r))))
                                                                     (begin
                                                                       r))))
                                                             (begin r))))
                                                     (begin r))))
                                             (begin r)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                       (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                               (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                       (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                               (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                                 (if (null?
                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                     (begin
                                                                       (if (and (fx= phi
                                                                                     current-phi)
                                                                                (eq? src
                                                                                     ctx))
                                                                           (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                               r)
                                                                                                                        (cons
                                                                                                                          (import->export
                                                                                                                            in)
                                                                                                                          r))])
                                                                             (fold-left
                                                                               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                        #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                                 (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                   #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                   #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                               r
                                                                               imports))
                                                                           r))
                                                                     (begin
                                                                       r))))
                                                             (begin r))))
                                                     (begin r))))
                                             (begin r))))
                                     (begin r)))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                               (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                       (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                               (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                       (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                         (if (null?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                             (begin
                                                               (if (and (fx= phi
                                                                             current-phi)
                                                                        (eq? src
                                                                             ctx))
                                                                   (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                       r)
                                                                                                                (cons
                                                                                                                  (import->export
                                                                                                                    in)
                                                                                                                  r))])
                                                                     (fold-left
                                                                       (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                         (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                           #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                           #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                       r
                                                                       imports))
                                                                   r))
                                                             (begin r))))
                                                     (begin r))))
                                             (begin r))))
                                     (begin r))))
                             (begin r)))))
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                       (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                               (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                       (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                               (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                 (if (null?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                     (begin
                                                       (if (and (fx= phi
                                                                     current-phi)
                                                                (eq? src
                                                                     ctx))
                                                           (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                               r)
                                                                                                        (cons
                                                                                                          (import->export
                                                                                                            in)
                                                                                                          r))])
                                                             (fold-left
                                                               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                        #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                 (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                   #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                   #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                               r
                                                               imports))
                                                           r))
                                                     (begin r))))
                                             (begin r))))
                                     (begin r))))
                             (begin r))))
                     (begin r)))))
         (cons
           (make-export-set
             src
             current-phi
             (let ([#{f dpuuv4a3mobea70icwo8nvdax-1497} fold-e])
               (fold-left
                 (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1498}
                          #{e dpuuv4a3mobea70icwo8nvdax-1499})
                   (#{f dpuuv4a3mobea70icwo8nvdax-1497}
                     #{e dpuuv4a3mobea70icwo8nvdax-1499}
                     #{a dpuuv4a3mobea70icwo8nvdax-1498}))
                 (list)
                 (&module-context-import current-ctx))))
           r))
       (define (export! rbody)
         (define current-ctx (current-expander-context))
         (define (fold-e out r)
           (cond
             [(module-export? out) (cons out r)]
             [(export-set? out)
              (let ([#{f dpuuv4a3mobea70icwo8nvdax-1500} cons])
                (fold-left
                  (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1501}
                           #{e dpuuv4a3mobea70icwo8nvdax-1502})
                    (#{f dpuuv4a3mobea70icwo8nvdax-1500}
                      #{e dpuuv4a3mobea70icwo8nvdax-1502}
                      #{a dpuuv4a3mobea70icwo8nvdax-1501}))
                  r
                  (&export-set-exports out)))]
             [else r]))
         (let ([body (reverse rbody)])
           (&module-context-export-set!
             current-ctx
             (let ([#{f dpuuv4a3mobea70icwo8nvdax-1503} fold-e])
               (fold-left
                 (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1504}
                          #{e dpuuv4a3mobea70icwo8nvdax-1505})
                   (#{f dpuuv4a3mobea70icwo8nvdax-1503}
                     #{e dpuuv4a3mobea70icwo8nvdax-1505}
                     #{a dpuuv4a3mobea70icwo8nvdax-1504}))
                 (&module-context-export current-ctx)
                 body)))
           body))
       (define (expanded-export? e)
         (or (module-export? e) (export-set? e)))
       (cond
         [(or (module-context? (current-expander-context))
              internal-expand?)
          (let ([rbody (core-expand-import/export stx expanded-export? 'apply-export-expander
                         current-export-expander-phi expand1)])
            (if internal-expand?
                (reverse rbody)
                (core-quote-syntax
                  (core-cons '%\x23;export (export! rbody))
                  (stx-source stx))))]
         [(top-context? (current-expander-context))
          (core-quote-syntax
            (core-cons '%\x23;begin (list))
            (stx-source stx))]
         [else (raise-syntax-error #f "Illegal context" stx)]))]
    [(stx internal-expand?)
     (define make-export
       (case-lambda
         [(bind)
          (let* ([phi (current-export-expander-phi)]
                 [ctx (current-expander-context)]
                 [name #f])
            (let* ([key (&binding-key bind)])
              (let* ([export-key (if name
                                     (core-identifier-key name)
                                     key)])
                (make-module-export ctx key phi export-key
                  (or (extern-binding? bind) (import-binding? bind))))))]
         [(bind phi)
          (let* ([ctx (current-expander-context)] [name #f])
            (let* ([key (&binding-key bind)])
              (let* ([export-key (if name
                                     (core-identifier-key name)
                                     key)])
                (make-module-export ctx key phi export-key
                  (or (extern-binding? bind) (import-binding? bind))))))]
         [(bind phi ctx)
          (let* ([name #f])
            (let* ([key (&binding-key bind)])
              (let* ([export-key (if name
                                     (core-identifier-key name)
                                     key)])
                (make-module-export ctx key phi export-key
                  (or (extern-binding? bind) (import-binding? bind))))))]
         [(bind phi ctx name)
          (let* ([key (&binding-key bind)])
            (let* ([export-key (if name
                                   (core-identifier-key name)
                                   key)])
              (make-module-export ctx key phi export-key
                (or (extern-binding? bind) (import-binding? bind)))))]))
     (define (expand1 hd K rest r)
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1427} hd])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1428} (lambda ()
                                                          (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1429} (lambda ()
                                                                                                           (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1430} (lambda ()
                                                                                                                                                            (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1431} (lambda ()
                                                                                                                                                                                                             (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1432} (lambda ()
                                                                                                                                                                                                                                                              (raise-syntax-error
                                                                                                                                                                                                                                                                #f
                                                                                                                                                                                                                                                                "Bad syntax; illegal export"
                                                                                                                                                                                                                                                                stx
                                                                                                                                                                                                                                                                hd))])
                                                                                                                                                                                                               (if (stx-pair?
                                                                                                                                                                                                                     #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                                                                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1433} (syntax-e
                                                                                                                                                                                                                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                                                                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1434} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1433})]
                                                                                                                                                                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1435} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1433})])
                                                                                                                                                                                                                       (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1436} (stx-e
                                                                                                                                                                                                                                                                         #{csc-h dpuuv4a3mobea70icwo8nvdax-1434})])
                                                                                                                                                                                                                         (if (and (keyword?
                                                                                                                                                                                                                                    #{csc-kv dpuuv4a3mobea70icwo8nvdax-1436})
                                                                                                                                                                                                                                  (string=?
                                                                                                                                                                                                                                    (keyword->string
                                                                                                                                                                                                                                      #{csc-kv dpuuv4a3mobea70icwo8nvdax-1436})
                                                                                                                                                                                                                                    "import"))
                                                                                                                                                                                                                             (let ([in #{csc-t dpuuv4a3mobea70icwo8nvdax-1435}])
                                                                                                                                                                                                                               (if (stx-list?
                                                                                                                                                                                                                                     in)
                                                                                                                                                                                                                                   (let lp ([in-rest in]
                                                                                                                                                                                                                                            [r r])
                                                                                                                                                                                                                                     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1437} in-rest])
                                                                                                                                                                                                                                       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1438} (lambda ()
                                                                                                                                                                                                                                                                                        (K rest
                                                                                                                                                                                                                                                                                           r))])
                                                                                                                                                                                                                                         (if (stx-pair?
                                                                                                                                                                                                                                               #{csc-e dpuuv4a3mobea70icwo8nvdax-1437})
                                                                                                                                                                                                                                             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1439} (syntax-e
                                                                                                                                                                                                                                                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1437})])
                                                                                                                                                                                                                                               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1440} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1439})]
                                                                                                                                                                                                                                                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1441} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1439})])
                                                                                                                                                                                                                                                 (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1440}])
                                                                                                                                                                                                                                                   (let ([in-rest #{csc-t dpuuv4a3mobea70icwo8nvdax-1441}])
                                                                                                                                                                                                                                                     (let ([src (cond
                                                                                                                                                                                                                                                                  [(core-bound-module?
                                                                                                                                                                                                                                                                     hd)
                                                                                                                                                                                                                                                                   (syntax-local-e
                                                                                                                                                                                                                                                                     hd)]
                                                                                                                                                                                                                                                                  [(core-library-module-path?
                                                                                                                                                                                                                                                                     hd)
                                                                                                                                                                                                                                                                   (import-module
                                                                                                                                                                                                                                                                     (core-resolve-library-module-path
                                                                                                                                                                                                                                                                       hd))]
                                                                                                                                                                                                                                                                  [(core-library-relative-module-path?
                                                                                                                                                                                                                                                                     hd)
                                                                                                                                                                                                                                                                   (import-module
                                                                                                                                                                                                                                                                     (core-resolve-library-relative-module-path
                                                                                                                                                                                                                                                                       hd))]
                                                                                                                                                                                                                                                                  [(stx-string?
                                                                                                                                                                                                                                                                     hd)
                                                                                                                                                                                                                                                                   (import-module
                                                                                                                                                                                                                                                                     (core-resolve-module-path
                                                                                                                                                                                                                                                                       hd
                                                                                                                                                                                                                                                                       (stx-source
                                                                                                                                                                                                                                                                         stx)))]
                                                                                                                                                                                                                                                                  [else
                                                                                                                                                                                                                                                                   (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1442} hd])
                                                                                                                                                                                                                                                                     (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1443} (lambda ()
                                                                                                                                                                                                                                                                                                                      (raise-syntax-error
                                                                                                                                                                                                                                                                                                                        #f
                                                                                                                                                                                                                                                                                                                        "Bad syntax; illegal re-export"
                                                                                                                                                                                                                                                                                                                        stx
                                                                                                                                                                                                                                                                                                                        hd))])
                                                                                                                                                                                                                                                                       (if (stx-pair?
                                                                                                                                                                                                                                                                             #{csc-e dpuuv4a3mobea70icwo8nvdax-1442})
                                                                                                                                                                                                                                                                           (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1444} (syntax-e
                                                                                                                                                                                                                                                                                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1442})])
                                                                                                                                                                                                                                                                             (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1445} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1444})]
                                                                                                                                                                                                                                                                                   [#{csc-t dpuuv4a3mobea70icwo8nvdax-1446} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1444})])
                                                                                                                                                                                                                                                                               (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1447} (stx-e
                                                                                                                                                                                                                                                                                                                                 #{csc-h dpuuv4a3mobea70icwo8nvdax-1445})])
                                                                                                                                                                                                                                                                                 (if (and (keyword?
                                                                                                                                                                                                                                                                                            #{csc-kv dpuuv4a3mobea70icwo8nvdax-1447})
                                                                                                                                                                                                                                                                                          (string=?
                                                                                                                                                                                                                                                                                            (keyword->string
                                                                                                                                                                                                                                                                                              #{csc-kv dpuuv4a3mobea70icwo8nvdax-1447})
                                                                                                                                                                                                                                                                                            "in"))
                                                                                                                                                                                                                                                                                     (let ([spath #{csc-t dpuuv4a3mobea70icwo8nvdax-1446}])
                                                                                                                                                                                                                                                                                       (core-import-nested-module
                                                                                                                                                                                                                                                                                         spath
                                                                                                                                                                                                                                                                                         stx))
                                                                                                                                                                                                                                                                                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1443})))))
                                                                                                                                                                                                                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1443}))))])])
                                                                                                                                                                                                                                                       (lp in-rest
                                                                                                                                                                                                                                                           (export-imports
                                                                                                                                                                                                                                                             src
                                                                                                                                                                                                                                                             r)))))))
                                                                                                                                                                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1438})))))
                                                                                                                                                                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432})))
                                                                                                                                                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432})))))
                                                                                                                                                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1432}))))])
                                                                                                                                                              (if (stx-pair?
                                                                                                                                                                    #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                                                                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1448} (syntax-e
                                                                                                                                                                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                                                                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1449} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1448})]
                                                                                                                                                                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1450} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1448})])
                                                                                                                                                                      (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1451} (stx-e
                                                                                                                                                                                                                        #{csc-h dpuuv4a3mobea70icwo8nvdax-1449})])
                                                                                                                                                                        (if (and (keyword?
                                                                                                                                                                                   #{csc-kv dpuuv4a3mobea70icwo8nvdax-1451})
                                                                                                                                                                                 (string=?
                                                                                                                                                                                   (keyword->string
                                                                                                                                                                                     #{csc-kv dpuuv4a3mobea70icwo8nvdax-1451})
                                                                                                                                                                                   "rename"))
                                                                                                                                                                            (if (stx-pair?
                                                                                                                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1450})
                                                                                                                                                                                (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1452} (syntax-e
                                                                                                                                                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1450})])
                                                                                                                                                                                  (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1453} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1452})]
                                                                                                                                                                                        [#{csc-t dpuuv4a3mobea70icwo8nvdax-1454} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1452})])
                                                                                                                                                                                    (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1453}])
                                                                                                                                                                                      (if (stx-pair?
                                                                                                                                                                                            #{csc-t dpuuv4a3mobea70icwo8nvdax-1454})
                                                                                                                                                                                          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1455} (syntax-e
                                                                                                                                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1454})])
                                                                                                                                                                                            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1456} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1455})]
                                                                                                                                                                                                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1457} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1455})])
                                                                                                                                                                                              (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1456}])
                                                                                                                                                                                                (if (stx-null?
                                                                                                                                                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1457})
                                                                                                                                                                                                    (let ([phi (current-export-expander-phi)])
                                                                                                                                                                                                      (cond
                                                                                                                                                                                                        [(core-resolve-identifier
                                                                                                                                                                                                           id
                                                                                                                                                                                                           phi) =>
                                                                                                                                                                                                         (lambda (bind)
                                                                                                                                                                                                           (K rest
                                                                                                                                                                                                              (cons
                                                                                                                                                                                                                (make-export
                                                                                                                                                                                                                  bind
                                                                                                                                                                                                                  phi
                                                                                                                                                                                                                  (current-expander-context)
                                                                                                                                                                                                                  name)
                                                                                                                                                                                                                r)))]
                                                                                                                                                                                                        [else
                                                                                                                                                                                                         (raise-syntax-error
                                                                                                                                                                                                           #f
                                                                                                                                                                                                           "Reference to unbound identifier"
                                                                                                                                                                                                           stx
                                                                                                                                                                                                           hd
                                                                                                                                                                                                           id)]))
                                                                                                                                                                                                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431}))
                                                                                                                                                                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431})))))
                                                                                                                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1431}))))])
                                                                                                             (if (stx-pair?
                                                                                                                   #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})
                                                                                                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1458} (syntax-e
                                                                                                                                                                  #{csc-e dpuuv4a3mobea70icwo8nvdax-1427})])
                                                                                                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1459} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1458})]
                                                                                                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1460} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1458})])
                                                                                                                     (let ([#{csc-kv dpuuv4a3mobea70icwo8nvdax-1461} (stx-e
                                                                                                                                                                       #{csc-h dpuuv4a3mobea70icwo8nvdax-1459})])
                                                                                                                       (if (and (keyword?
                                                                                                                                  #{csc-kv dpuuv4a3mobea70icwo8nvdax-1461})
                                                                                                                                (string=?
                                                                                                                                  (keyword->string
                                                                                                                                    #{csc-kv dpuuv4a3mobea70icwo8nvdax-1461})
                                                                                                                                  "spec"))
                                                                                                                           (if (stx-pair?
                                                                                                                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1460})
                                                                                                                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1462} (syntax-e
                                                                                                                                                                                #{csc-t dpuuv4a3mobea70icwo8nvdax-1460})])
                                                                                                                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1463} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1462})]
                                                                                                                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1464} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1462})])
                                                                                                                                   (let ([phi #{csc-h dpuuv4a3mobea70icwo8nvdax-1463}])
                                                                                                                                     (if (stx-pair?
                                                                                                                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1464})
                                                                                                                                         (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1465} (syntax-e
                                                                                                                                                                                          #{csc-t dpuuv4a3mobea70icwo8nvdax-1464})])
                                                                                                                                           (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1466} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1465})]
                                                                                                                                                 [#{csc-t dpuuv4a3mobea70icwo8nvdax-1467} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1465})])
                                                                                                                                             (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1466}])
                                                                                                                                               (if (stx-pair?
                                                                                                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1467})
                                                                                                                                                   (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1468} (syntax-e
                                                                                                                                                                                                    #{csc-t dpuuv4a3mobea70icwo8nvdax-1467})])
                                                                                                                                                     (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1469} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1468})]
                                                                                                                                                           [#{csc-t dpuuv4a3mobea70icwo8nvdax-1470} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1468})])
                                                                                                                                                       (let ([name #{csc-h dpuuv4a3mobea70icwo8nvdax-1469}])
                                                                                                                                                         (if (stx-null?
                                                                                                                                                               #{csc-t dpuuv4a3mobea70icwo8nvdax-1470})
                                                                                                                                                             (if (and (stx-fixnum?
                                                                                                                                                                        phi)
                                                                                                                                                                      (identifier?
                                                                                                                                                                        id)
                                                                                                                                                                      (identifier?
                                                                                                                                                                        name))
                                                                                                                                                                 (let ([phi (stx-e
                                                                                                                                                                              phi)])
                                                                                                                                                                   (cond
                                                                                                                                                                     [(core-resolve-identifier
                                                                                                                                                                        id
                                                                                                                                                                        phi) =>
                                                                                                                                                                      (lambda (bind)
                                                                                                                                                                        (K rest
                                                                                                                                                                           (cons
                                                                                                                                                                             (make-export
                                                                                                                                                                               bind
                                                                                                                                                                               phi
                                                                                                                                                                               (current-expander-context)
                                                                                                                                                                               name)
                                                                                                                                                                             r)))]
                                                                                                                                                                     [else
                                                                                                                                                                      (raise-syntax-error
                                                                                                                                                                        #f
                                                                                                                                                                        "Reference to unbound identifier"
                                                                                                                                                                        stx
                                                                                                                                                                        hd
                                                                                                                                                                        id)]))
                                                                                                                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))
                                                                                                                                                             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                                                   (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))
                                                                                                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430})))))
                                                                                                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1430}))))])
                                                            (let ([id #{csc-e dpuuv4a3mobea70icwo8nvdax-1427}])
                                                              (if (identifier?
                                                                    id)
                                                                  (cond
                                                                    [(core-resolve-identifier
                                                                       id
                                                                       (current-export-expander-phi)) =>
                                                                     (lambda (bind)
                                                                       (K rest
                                                                          (cons
                                                                            (make-export
                                                                              bind)
                                                                            r)))]
                                                                    [else
                                                                     (raise-syntax-error
                                                                       #f
                                                                       "Reference to unbound identifier"
                                                                       stx
                                                                       hd)])
                                                                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1429})))))])
           (if (eq? (stx-e #{csc-e dpuuv4a3mobea70icwo8nvdax-1427}) #t)
               (let* ([current-ctx (current-expander-context)])
                 (let* ([current-phi (current-export-expander-phi)])
                   (let* ([phi-ctx (core-context-shift
                                     current-ctx
                                     current-phi)])
                     (let* ([phi-bind (hash->list
                                        (&expander-context-table
                                          phi-ctx))])
                       (let lp ([bind-rest phi-bind] [set (list)])
                         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1471} bind-rest])
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-1471})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1472} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1471})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-1473} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1471})])
                                 (if (pair?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-1472})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1474} (car #{hd dpuuv4a3mobea70icwo8nvdax-1472})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1475} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-1472})])
                                       (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1474}])
                                         (let ([bind #{tl dpuuv4a3mobea70icwo8nvdax-1475}])
                                           (let ([bind-rest #{tl dpuuv4a3mobea70icwo8nvdax-1473}])
                                             (begin
                                               (if (or (import-binding?
                                                         bind)
                                                       (private-feature-binding?
                                                         bind))
                                                   (lp bind-rest set)
                                                   (lp bind-rest
                                                       (cons
                                                         (make-export
                                                           bind
                                                           current-phi
                                                           current-ctx)
                                                         set))))))))
                                     (begin
                                       (K rest
                                          (cons
                                            (make-export-set
                                              #f
                                              current-phi
                                              set)
                                            r)))))
                               (begin
                                 (K rest
                                    (cons
                                      (make-export-set #f current-phi set)
                                      r))))))))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1428})))))
     (define (export-imports src r)
       (define current-ctx (current-expander-context))
       (define current-phi (current-export-expander-phi))
       (define (import->export in)
         (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1476} in])
           (let ([out (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                        1)]
                 [key (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                        2)]
                 [phi (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-1476}
                        3)])
             (make-module-export current-ctx key phi key #t))))
       (define (fold-e in r)
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1477} in])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1478} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-1479} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                 (let ([module-import #{hd dpuuv4a3mobea70icwo8nvdax-1478}])
                   (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1479})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1480} (car #{tl dpuuv4a3mobea70icwo8nvdax-1479})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-1481} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1479})])
                         (let ([out #{hd dpuuv4a3mobea70icwo8nvdax-1480}])
                           (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1481})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1482} (car #{tl dpuuv4a3mobea70icwo8nvdax-1481})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-1483} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1481})])
                                 (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1482}])
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-1483})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1484} (car #{tl dpuuv4a3mobea70icwo8nvdax-1483})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-1485} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1483})])
                                         (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1484}])
                                           (if (null?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-1485})
                                               (begin
                                                 (if (and (fx= phi
                                                               current-phi)
                                                          (eq? src
                                                               (&module-export-context
                                                                 out)))
                                                     (cons
                                                       (import->export in)
                                                       r)
                                                     r))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                                     (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                                       (if (pair?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                                             (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                                               (if (pair?
                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                                     (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                                       (if (pair?
                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                                             (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                                               (if (null?
                                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                                   (begin
                                                                                     (if (and (fx= phi
                                                                                                   current-phi)
                                                                                              (eq? src
                                                                                                   ctx))
                                                                                         (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                                             r)
                                                                                                                                      (cons
                                                                                                                                        (import->export
                                                                                                                                          in)
                                                                                                                                        r))])
                                                                                           (fold-left
                                                                                             (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                                      #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                                               (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                                 #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                                 #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                                             r
                                                                                             imports))
                                                                                         r))
                                                                                   (begin
                                                                                     r))))
                                                                           (begin
                                                                             r))))
                                                                   (begin
                                                                     r))))
                                                           (begin r))))
                                                   (begin r)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                             (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                                     (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                                       (if (pair?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                             (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                               (if (pair?
                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                                     (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                                       (if (null?
                                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                           (begin
                                                                             (if (and (fx= phi
                                                                                           current-phi)
                                                                                      (eq? src
                                                                                           ctx))
                                                                                 (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                                     r)
                                                                                                                              (cons
                                                                                                                                (import->export
                                                                                                                                  in)
                                                                                                                                r))])
                                                                                   (fold-left
                                                                                     (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                              #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                                       (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                         #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                         #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                                     r
                                                                                     imports))
                                                                                 r))
                                                                           (begin
                                                                             r))))
                                                                   (begin
                                                                     r))))
                                                           (begin r))))
                                                   (begin r))))
                                           (begin r)))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                                     (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                             (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                                     (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                                       (if (pair?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                             (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                               (if (null?
                                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                                   (begin
                                                                     (if (and (fx= phi
                                                                                   current-phi)
                                                                              (eq? src
                                                                                   ctx))
                                                                         (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                             r)
                                                                                                                      (cons
                                                                                                                        (import->export
                                                                                                                          in)
                                                                                                                        r))])
                                                                           (fold-left
                                                                             (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                                      #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                               (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                                 #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                                 #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                             r
                                                                             imports))
                                                                         r))
                                                                   (begin
                                                                     r))))
                                                           (begin r))))
                                                   (begin r))))
                                           (begin r))))
                                   (begin r)))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                             (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                                     (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                             (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                                     (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                                       (if (null?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                           (begin
                                                             (if (and (fx= phi
                                                                           current-phi)
                                                                      (eq? src
                                                                           ctx))
                                                                 (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                                     r)
                                                                                                              (cons
                                                                                                                (import->export
                                                                                                                  in)
                                                                                                                r))])
                                                                   (fold-left
                                                                     (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                              #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                                       (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                         #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                         #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                                     r
                                                                     imports))
                                                                 r))
                                                           (begin r))))
                                                   (begin r))))
                                           (begin r))))
                                   (begin r))))
                           (begin r)))))
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1477})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1486} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1477})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-1487} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1477})])
                     (let ([import-set #{hd dpuuv4a3mobea70icwo8nvdax-1486}])
                       (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1487})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1488} (car #{tl dpuuv4a3mobea70icwo8nvdax-1487})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1489} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1487})])
                             (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-1488}])
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-1489})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1490} (car #{tl dpuuv4a3mobea70icwo8nvdax-1489})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1491} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1489})])
                                     (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-1490}])
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1491})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1492} (car #{tl dpuuv4a3mobea70icwo8nvdax-1491})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1493} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1491})])
                                             (let ([imports #{hd dpuuv4a3mobea70icwo8nvdax-1492}])
                                               (if (null?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1493})
                                                   (begin
                                                     (if (and (fx= phi
                                                                   current-phi)
                                                              (eq? src
                                                                   ctx))
                                                         (let ([#{f dpuuv4a3mobea70icwo8nvdax-1494} (lambda (in
                                                                                                             r)
                                                                                                      (cons
                                                                                                        (import->export
                                                                                                          in)
                                                                                                        r))])
                                                           (fold-left
                                                             (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1495}
                                                                      #{e dpuuv4a3mobea70icwo8nvdax-1496})
                                                               (#{f dpuuv4a3mobea70icwo8nvdax-1494}
                                                                 #{e dpuuv4a3mobea70icwo8nvdax-1496}
                                                                 #{a dpuuv4a3mobea70icwo8nvdax-1495}))
                                                             r
                                                             imports))
                                                         r))
                                                   (begin r))))
                                           (begin r))))
                                   (begin r))))
                           (begin r))))
                   (begin r)))))
       (cons
         (make-export-set
           src
           current-phi
           (let ([#{f dpuuv4a3mobea70icwo8nvdax-1497} fold-e])
             (fold-left
               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1498}
                        #{e dpuuv4a3mobea70icwo8nvdax-1499})
                 (#{f dpuuv4a3mobea70icwo8nvdax-1497}
                   #{e dpuuv4a3mobea70icwo8nvdax-1499}
                   #{a dpuuv4a3mobea70icwo8nvdax-1498}))
               (list)
               (&module-context-import current-ctx))))
         r))
     (define (export! rbody)
       (define current-ctx (current-expander-context))
       (define (fold-e out r)
         (cond
           [(module-export? out) (cons out r)]
           [(export-set? out)
            (let ([#{f dpuuv4a3mobea70icwo8nvdax-1500} cons])
              (fold-left
                (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1501}
                         #{e dpuuv4a3mobea70icwo8nvdax-1502})
                  (#{f dpuuv4a3mobea70icwo8nvdax-1500}
                    #{e dpuuv4a3mobea70icwo8nvdax-1502}
                    #{a dpuuv4a3mobea70icwo8nvdax-1501}))
                r
                (&export-set-exports out)))]
           [else r]))
       (let ([body (reverse rbody)])
         (&module-context-export-set!
           current-ctx
           (let ([#{f dpuuv4a3mobea70icwo8nvdax-1503} fold-e])
             (fold-left
               (lambda (#{a dpuuv4a3mobea70icwo8nvdax-1504}
                        #{e dpuuv4a3mobea70icwo8nvdax-1505})
                 (#{f dpuuv4a3mobea70icwo8nvdax-1503}
                   #{e dpuuv4a3mobea70icwo8nvdax-1505}
                   #{a dpuuv4a3mobea70icwo8nvdax-1504}))
               (&module-context-export current-ctx)
               body)))
         body))
     (define (expanded-export? e)
       (or (module-export? e) (export-set? e)))
     (cond
       [(or (module-context? (current-expander-context))
            internal-expand?)
        (let ([rbody (core-expand-import/export stx expanded-export? 'apply-export-expander
                       current-export-expander-phi expand1)])
          (if internal-expand?
              (reverse rbody)
              (core-quote-syntax
                (core-cons '%\x23;export (export! rbody))
                (stx-source stx))))]
       [(top-context? (current-expander-context))
        (core-quote-syntax
          (core-cons '%\x23;begin (list))
          (stx-source stx))]
       [else (raise-syntax-error #f "Illegal context" stx)])]))

(define (core-expand-export-source hd)
  (core-expand-export% (list 'export-macro% hd) #t))

(define (core-expand-provide% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1506} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1507} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1506}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1506})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1508} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1506})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1509} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1508})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1510} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1508})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1510}])
                (if (identifier-list? body)
                    (begin
                      (stx-for-each core-bind-feature! body)
                      (core-quote-syntax
                        (core-cons
                          '%\x23;provide
                          (stx-map core-quote-syntax body))
                        (stx-source stx)))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1507})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1507})))))

(define core-bind-feature!
  (case-lambda
    [(id)
     (let* ([private? #f]
            [phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (core-bind-syntax! id
         ((if private?
              make-private-feature-expander
              make-feature-expander)
           (stx-e id))
         private? phi ctx))]
    [(id private?)
     (let* ([phi (current-expander-phi)]
            [ctx (current-expander-context)])
       (core-bind-syntax! id
         ((if private?
              make-private-feature-expander
              make-feature-expander)
           (stx-e id))
         private? phi ctx))]
    [(id private? phi)
     (let* ([ctx (current-expander-context)])
       (core-bind-syntax! id
         ((if private?
              make-private-feature-expander
              make-feature-expander)
           (stx-e id))
         private? phi ctx))]
    [(id private? phi ctx)
     (core-bind-syntax! id
       ((if private?
            make-private-feature-expander
            make-feature-expander)
         (stx-e id))
       private? phi ctx)]))

