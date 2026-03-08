(define (optimizer-info-init!)
  (unless (current-compile-optimizer-info)
    (current-compile-optimizer-info (make-optimizer-info))))

(define (optimize! ctx)
  (parameterize ([current-compile-mutators
                  (make-hash-table-eq)]
                 [current-compile-local-type (make-hash-table-eq)])
    (optimizer-load-builtin-ssxi ctx)
    (optimizer-load-ssxi-deps ctx)
    (hash-put!
      (optimizer-info-ssxi (current-compile-optimizer-info))
      (expander-context-id ctx)
      #t)
    (let ([code (optimize-source (module-context-code ctx))])
      (module-context-code-set! ctx code))))

(define (optimizer-load-builtin-ssxi ctx)
  (define (load-it! id)
    (unless (hash-get
              (optimizer-info-ssxi (current-compile-optimizer-info))
              id)
      (optimizer-import-ssxi-by-id id)
      (hash-put!
        (optimizer-info-ssxi (current-compile-optimizer-info))
        id
        #t)))
  (let* ([modid (expander-context-id ctx)])
    (let* ([modid-str (symbol->string modid)])
      (if (or (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-8537} "gerbil/runtime"]
                    [#{str dpuuv4a3mobea70icwo8nvdax-8538} modid-str])
                (let ([plen (string-length
                              #{pfx dpuuv4a3mobea70icwo8nvdax-8537})])
                  (and (<= plen
                           (string-length
                             #{str dpuuv4a3mobea70icwo8nvdax-8538}))
                       (string=?
                         #{pfx dpuuv4a3mobea70icwo8nvdax-8537}
                         (substring
                           #{str dpuuv4a3mobea70icwo8nvdax-8538}
                           0
                           plen)))))
              (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-8539} "gerbil/core"]
                    [#{str dpuuv4a3mobea70icwo8nvdax-8540} modid-str])
                (let ([plen (string-length
                              #{pfx dpuuv4a3mobea70icwo8nvdax-8539})])
                  (and (<= plen
                           (string-length
                             #{str dpuuv4a3mobea70icwo8nvdax-8540}))
                       (string=?
                         #{pfx dpuuv4a3mobea70icwo8nvdax-8539}
                         (substring
                           #{str dpuuv4a3mobea70icwo8nvdax-8540}
                           0
                           plen))))))
          (for-each
            load-it!
            '(gerbil/builtin gerbil/builtin-inline-rules))
          (for-each
            load-it!
            '(gerbil/builtin gerbil/builtin-inline-rules gerbil/runtime/gambit
               gerbil/runtime/util gerbil/runtime/table
               gerbil/runtime/control gerbil/runtime/system
               gerbil/runtime/c3 gerbil/runtime/mop
               gerbil/runtime/mop-system-classes gerbil/runtime/error
               gerbil/runtime/interface gerbil/runtime/hash
               gerbil/runtime/thread gerbil/runtime/syntax
               gerbil/runtime/eval gerbil/runtime/repl
               gerbil/runtime/loader gerbil/runtime/init
               gerbil/runtime))))))

(define (optimizer-load-ssxi-deps ctx)
  (define deps
    (let ([imports (module-context-import ctx)])
      (cond
        [(core-context-prelude ctx) =>
         (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-8541})
           (cons #{cut-arg dpuuv4a3mobea70icwo8nvdax-8541} imports))]
        [else imports])))
  (let lp ([rest deps])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-8542} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-8542})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-8543} (car #{match-val dpuuv4a3mobea70icwo8nvdax-8542})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-8544} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-8542})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-8543}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-8544}])
                (begin
                  (cond
                    [(module-context? hd)
                     (unless (hash-get
                               (optimizer-info-ssxi
                                 (current-compile-optimizer-info))
                               (expander-context-id hd))
                       (cond
                         [(core-context-prelude hd) =>
                          (lambda (pre)
                            (lp (cons pre (module-context-import hd))))]
                         [else (lp (module-context-import hd))])
                       (optimizer-load-ssxi hd))
                     (lp rest)]
                    [(prelude-context? hd)
                     (unless (hash-get
                               (optimizer-info-ssxi
                                 (current-compile-optimizer-info))
                               (expander-context-id hd))
                       (lp (prelude-context-import hd))
                       (optimizer-load-ssxi hd))
                     (lp rest)]
                    [(module-import? hd)
                     (lp (cons (module-import-source hd) rest))]
                    [(module-export? hd)
                     (lp (cons (module-export-context hd) rest))]
                    [(import-set? hd)
                     (lp (cons (import-set-source hd) rest))]
                    [else
                     (error 'gerbil "Unexpected module import" hd)])))))
          (begin (void))))))

(define (optimizer-load-ssxi ctx)
  (unless (and (module-context? ctx)
               (list? (module-context-path ctx)))
    (let* ([ht (optimizer-info-ssxi
                 (current-compile-optimizer-info))])
      (let* ([id (expander-context-id ctx)])
        (let* ([mod (hash-get ht id)])
          (or mod
              (let* ([mod (optimizer-import-ssxi ctx)])
                (let* ([val (or mod (%%void))])
                  (hash-put! ht id val)
                  val))))))))

(define (optimizer-import-ssxi ctx)
  (and (expander-context-id ctx)
       (optimizer-import-ssxi-by-id (expander-context-id ctx))))

(define (optimizer-import-ssxi-by-id id)
  (define (catch-e exn)
    (unless (equal?
              (error-message exn)
              "cannot find library module")
      (display-exception exn)
      (begin
        (display "*** WARNING Failed to load ssxi module for ")
        (display id)
        (newline)))
    #f)
  (define (import-e)
    (let* ([str-id (string-append
                     (module-id->path-string id)
                     ".ssxi")])
      (let* ([artefact-path (let ([odir (current-compile-output-dir)])
                              (and odir
                                   (begin
                                     (gambit-path-expand
                                       (string-append str-id ".ss")
                                       odir))))])
        (let* ([library-path (string->symbol
                               (string-append ":" str-id ".ss"))])
          (let* ([ssxi-path (if (and artefact-path
                                     (file-exists? artefact-path))
                                artefact-path
                                library-path)])
            (verbose "Loading ssxi module " ssxi-path)
            (import-module ssxi-path #t #t))))))
  (guard (__exn [#t (catch-e __exn)]) (import-e)))

(define (optimize-source stx)
  (apply-collect-mutators stx)
  (apply-collect-top-level-type-info stx)
  (let* ([stx (apply-generate-method-specializers stx)])
    (let* ([stx (apply-lift-top-lambdas stx)])
      (apply-collect-type-info stx)
      (apply-collect-mutable-type-info stx)
      (let fixpoint ([current (optimizer-current-types)])
        (apply-refine-type-info stx)
        (let ([refined (optimizer-current-types)])
          (unless (equal? current refined) (fixpoint refined))))
      (apply-check-return-type stx)
      (apply-collect-top-level-declarations stx)
      (let ([stx (apply-optimize-annotated stx)])
        (apply-optimize-call stx)))))

(defcompile-method (apply-generate-ssxi)
  (::generate-ssxi ::generate-runtime-empty) () 'final:
  (%\x23;begin generate-runtime-begin%)
  (%\x23;begin-syntax generate-ssxi-begin-syntax%)
  (%\x23;begin-annotation generate-ssxi-begin-annotation%)
  (%\x23;module generate-ssxi-module%)
  (%\x23;define-values generate-ssxi-define-values%)
  (%\x23;call generate-ssxi-call%))

(define (generate-ssxi-begin-syntax% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-8545} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8546} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-8545}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-8545})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8547} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8545})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8548} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8547})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-8549} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8547})])
            (let ([forms #{etl dpuuv4a3mobea70icwo8nvdax-8549}])
              (parameterize ([current-expander-phi
                              (fx1+ (current-expander-phi))])
                (generate-runtime-begin% self stx))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-8546})))))

(define (generate-ssxi-module% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-8550} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8551} (lambda ()
                                                    (__raise-syntax-error
                                                      #f
                                                      "Bad syntax; malformed ast clause"
                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-8550}))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-8550})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8552} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8550})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8553} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8552})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-8554} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8552})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-8554})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8555} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8554})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8556} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8555})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-8557} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8555})])
                  (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-8556}])
                    (let ([body #{etl dpuuv4a3mobea70icwo8nvdax-8557}])
                      (let* ([ctx (syntax-local-e #'id)])
                        (let* ([code (module-context-code ctx)])
                          (parameterize ([current-expander-context ctx])
                            (compile-e self code)))))))
                (#{fail dpuuv4a3mobea70icwo8nvdax-8551})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-8551})))))

(define (generate-ssxi-define-values% self stx)
  (define (generate-e id)
    (let ([sym (and (identifier? #'id) (identifier-symbol id))])
      (cond
        [(optimizer-lookup-class sym) =>
         (lambda (klass)
           (verbose "generate class decl" sym)
           (list
             'begin
             (list 'declare-class sym (slot-ref klass 'typedecl))
             (list
               'declare-type
               sym
               `(optimizer-resolve-class '(typedecl ,sym) 'class::t))))]
        [(optimizer-lookup-type sym) =>
         (lambda (type)
           (verbose "generate typedecl " sym " " type)
           (if (!class? type)
               (list
                 'declare-type
                 sym
                 `(optimizer-resolve-class
                    '(typedecl ,sym)
                    ',(optimizer-lookup-class-name type)))
               (list 'declare-type sym (slot-ref type 'typedecl))))]
        [else '(begin)])))
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-8558} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8559} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8560} (lambda ()
                                                                                                    (__raise-syntax-error
                                                                                                      #f
                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-8558}))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-8558})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8561} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8558})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8562} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8561})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8563} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8561})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8563})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8564} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8563})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8565} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8564})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8566} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8564})])
                                                                  (if (__AST-pair?
                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8565})
                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8567} (__AST-e
                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8565})]
                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8568} (\x23;\x23;car
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8567})]
                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-8569} (\x23;\x23;cdr
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8567})])
                                                                        (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-8568}])
                                                                          (if (__AST-pair?
                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-8569})
                                                                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8570} (__AST-e
                                                                                                                               #{etl dpuuv4a3mobea70icwo8nvdax-8569})]
                                                                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-8571} (\x23;\x23;car
                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8570})]
                                                                                     [#{etl dpuuv4a3mobea70icwo8nvdax-8572} (\x23;\x23;cdr
                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8570})])
                                                                                (let ([... #{ehd dpuuv4a3mobea70icwo8nvdax-8571}])
                                                                                  (if (null?
                                                                                        (__AST-e
                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8572}))
                                                                                      (if (__AST-pair?
                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-8566})
                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8573} (__AST-e
                                                                                                                                           #{etl dpuuv4a3mobea70icwo8nvdax-8566})]
                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8574} (\x23;\x23;car
                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8573})]
                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8575} (\x23;\x23;cdr
                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8573})])
                                                                                            (if (null?
                                                                                                  (__AST-e
                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-8575}))
                                                                                                (let ([types (map generate-e
                                                                                                                  #'(id ...))])
                                                                                                  (cons*
                                                                                                    'begin
                                                                                                    types))
                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8560})))
                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8560}))
                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-8560}))))
                                                                              (#{fail dpuuv4a3mobea70icwo8nvdax-8560}))))
                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-8560})))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8560})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8560}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-8558})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8576} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8558})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8577} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8576})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-8578} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8576})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-8578})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8579} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8578})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8580} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8579})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-8581} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8579})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-8580})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8582} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8580})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8583} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8582})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-8584} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8582})])
                        (let ([id #{ehd dpuuv4a3mobea70icwo8nvdax-8583}])
                          (if (null?
                                (__AST-e
                                  #{etl dpuuv4a3mobea70icwo8nvdax-8584}))
                              (if (__AST-pair?
                                    #{etl dpuuv4a3mobea70icwo8nvdax-8581})
                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8585} (__AST-e
                                                                                   #{etl dpuuv4a3mobea70icwo8nvdax-8581})]
                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-8586} (\x23;\x23;car
                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8585})]
                                         [#{etl dpuuv4a3mobea70icwo8nvdax-8587} (\x23;\x23;cdr
                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8585})])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-8587}))
                                        (generate-e #'id)
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8559})))
                                  (#{fail dpuuv4a3mobea70icwo8nvdax-8559}))
                              (#{fail dpuuv4a3mobea70icwo8nvdax-8559}))))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-8559})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-8559})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-8559})))))

(define (generate-ssxi-call% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-8588} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8589} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8590} (lambda ()
                                                                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8591} (lambda ()
                                                                                                                                                    (__raise-syntax-error
                                                                                                                                                      #f
                                                                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-8588}))])
                                                                                                      '(begin)))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-8588})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8592} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8588})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8593} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8592})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8594} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8592})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8594})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8595} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8594})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8596} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8595})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8597} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8595})])
                                                                  (if (__AST-pair?
                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8596})
                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8598} (__AST-e
                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8596})]
                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8599} (\x23;\x23;car
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8598})]
                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-8600} (\x23;\x23;cdr
                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8598})])
                                                                        (if (and (__AST-id?
                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8599})
                                                                                 (eq? (__AST-e
                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8599})
                                                                                      '%\x23;ref))
                                                                            (if (__AST-pair?
                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8600})
                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8601} (__AST-e
                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8600})]
                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8602} (\x23;\x23;car
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8601})]
                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8603} (\x23;\x23;cdr
                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8601})])
                                                                                  (let ([\x2D;bind-method! #{ehd dpuuv4a3mobea70icwo8nvdax-8602}])
                                                                                    (if (null?
                                                                                          (__AST-e
                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-8603}))
                                                                                        (if (__AST-pair?
                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-8597})
                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8604} (__AST-e
                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8597})]
                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8605} (\x23;\x23;car
                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8604})]
                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8606} (\x23;\x23;cdr
                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8604})])
                                                                                              (if (__AST-pair?
                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8605})
                                                                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8607} (__AST-e
                                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8605})]
                                                                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-8608} (\x23;\x23;car
                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8607})]
                                                                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-8609} (\x23;\x23;cdr
                                                                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8607})])
                                                                                                    (if (and (__AST-id?
                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-8608})
                                                                                                             (eq? (__AST-e
                                                                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8608})
                                                                                                                  '%\x23;ref))
                                                                                                        (if (__AST-pair?
                                                                                                              #{etl dpuuv4a3mobea70icwo8nvdax-8609})
                                                                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8610} (__AST-e
                                                                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8609})]
                                                                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8611} (\x23;\x23;car
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8610})]
                                                                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8612} (\x23;\x23;cdr
                                                                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8610})])
                                                                                                              (let ([type-t #{ehd dpuuv4a3mobea70icwo8nvdax-8611}])
                                                                                                                (if (null?
                                                                                                                      (__AST-e
                                                                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-8612}))
                                                                                                                    (if (__AST-pair?
                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8606})
                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8613} (__AST-e
                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-8606})]
                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-8614} (\x23;\x23;car
                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8613})]
                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-8615} (\x23;\x23;cdr
                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8613})])
                                                                                                                          (if (__AST-pair?
                                                                                                                                #{ehd dpuuv4a3mobea70icwo8nvdax-8614})
                                                                                                                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8616} (__AST-e
                                                                                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-8614})]
                                                                                                                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-8617} (\x23;\x23;car
                                                                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8616})]
                                                                                                                                     [#{etl dpuuv4a3mobea70icwo8nvdax-8618} (\x23;\x23;cdr
                                                                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8616})])
                                                                                                                                (if (and (__AST-id?
                                                                                                                                           #{ehd dpuuv4a3mobea70icwo8nvdax-8617})
                                                                                                                                         (eq? (__AST-e
                                                                                                                                                #{ehd dpuuv4a3mobea70icwo8nvdax-8617})
                                                                                                                                              '%\x23;quote))
                                                                                                                                    (if (__AST-pair?
                                                                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8618})
                                                                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8619} (__AST-e
                                                                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-8618})]
                                                                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-8620} (\x23;\x23;car
                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8619})]
                                                                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-8621} (\x23;\x23;cdr
                                                                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8619})])
                                                                                                                                          (let ([method #{ehd dpuuv4a3mobea70icwo8nvdax-8620}])
                                                                                                                                            (if (null?
                                                                                                                                                  (__AST-e
                                                                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-8621}))
                                                                                                                                                (if (__AST-pair?
                                                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-8615})
                                                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8622} (__AST-e
                                                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-8615})]
                                                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-8623} (\x23;\x23;car
                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8622})]
                                                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-8624} (\x23;\x23;cdr
                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8622})])
                                                                                                                                                      (if (__AST-pair?
                                                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-8623})
                                                                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8625} (__AST-e
                                                                                                                                                                                                           #{ehd dpuuv4a3mobea70icwo8nvdax-8623})]
                                                                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8626} (\x23;\x23;car
                                                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8625})]
                                                                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8627} (\x23;\x23;cdr
                                                                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8625})])
                                                                                                                                                            (if (and (__AST-id?
                                                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8626})
                                                                                                                                                                     (eq? (__AST-e
                                                                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-8626})
                                                                                                                                                                          '%\x23;ref))
                                                                                                                                                                (if (__AST-pair?
                                                                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-8627})
                                                                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8628} (__AST-e
                                                                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-8627})]
                                                                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-8629} (\x23;\x23;car
                                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8628})]
                                                                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-8630} (\x23;\x23;cdr
                                                                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8628})])
                                                                                                                                                                      (let ([impl #{ehd dpuuv4a3mobea70icwo8nvdax-8629}])
                                                                                                                                                                        (if (null?
                                                                                                                                                                              (__AST-e
                                                                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-8630}))
                                                                                                                                                                            (if (null?
                                                                                                                                                                                  (__AST-e
                                                                                                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-8624}))
                                                                                                                                                                                (if (runtime-identifier=?
                                                                                                                                                                                      #'\x2D;bind-method
                                                                                                                                                                                      'bind-method!)
                                                                                                                                                                                    (list
                                                                                                                                                                                      'declare-method
                                                                                                                                                                                      (identifier-symbol
                                                                                                                                                                                        #'type-t)
                                                                                                                                                                                      (stx-e
                                                                                                                                                                                        #'method)
                                                                                                                                                                                      (identifier-symbol
                                                                                                                                                                                        #'impl)
                                                                                                                                                                                      #f)
                                                                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))))
                                                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))))
                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                                                              (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))))
                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))))
                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))
                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8590})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8590}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-8588})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8631} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8588})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8632} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8631})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-8633} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8631})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-8633})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8634} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8633})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8635} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8634})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-8636} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8634})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-8635})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8637} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8635})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8638} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8637})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-8639} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8637})])
                        (if (and (__AST-id?
                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8638})
                                 (eq? (__AST-e
                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8638})
                                      '%\x23;ref))
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-8639})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8640} (__AST-e
                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8639})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8641} (\x23;\x23;car
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8640})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8642} (\x23;\x23;cdr
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8640})])
                                  (let ([\x2D;bind-method #{ehd dpuuv4a3mobea70icwo8nvdax-8641}])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-8642}))
                                        (if (__AST-pair?
                                              #{etl dpuuv4a3mobea70icwo8nvdax-8636})
                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8643} (__AST-e
                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8636})]
                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8644} (\x23;\x23;car
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8643})]
                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8645} (\x23;\x23;cdr
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8643})])
                                              (if (__AST-pair?
                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8644})
                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8646} (__AST-e
                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8644})]
                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-8647} (\x23;\x23;car
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8646})]
                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-8648} (\x23;\x23;cdr
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8646})])
                                                    (if (and (__AST-id?
                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-8647})
                                                             (eq? (__AST-e
                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8647})
                                                                  '%\x23;ref))
                                                        (if (__AST-pair?
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-8648})
                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8649} (__AST-e
                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8648})]
                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8650} (\x23;\x23;car
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8649})]
                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8651} (\x23;\x23;cdr
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8649})])
                                                              (let ([type-t #{ehd dpuuv4a3mobea70icwo8nvdax-8650}])
                                                                (if (null?
                                                                      (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-8651}))
                                                                    (if (__AST-pair?
                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8645})
                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8652} (__AST-e
                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-8645})]
                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-8653} (\x23;\x23;car
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8652})]
                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-8654} (\x23;\x23;cdr
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8652})])
                                                                          (if (__AST-pair?
                                                                                #{ehd dpuuv4a3mobea70icwo8nvdax-8653})
                                                                              (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8655} (__AST-e
                                                                                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-8653})]
                                                                                     [#{ehd dpuuv4a3mobea70icwo8nvdax-8656} (\x23;\x23;car
                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8655})]
                                                                                     [#{etl dpuuv4a3mobea70icwo8nvdax-8657} (\x23;\x23;cdr
                                                                                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-8655})])
                                                                                (if (and (__AST-id?
                                                                                           #{ehd dpuuv4a3mobea70icwo8nvdax-8656})
                                                                                         (eq? (__AST-e
                                                                                                #{ehd dpuuv4a3mobea70icwo8nvdax-8656})
                                                                                              '%\x23;quote))
                                                                                    (if (__AST-pair?
                                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8657})
                                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8658} (__AST-e
                                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-8657})]
                                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-8659} (\x23;\x23;car
                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8658})]
                                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-8660} (\x23;\x23;cdr
                                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8658})])
                                                                                          (let ([method #{ehd dpuuv4a3mobea70icwo8nvdax-8659}])
                                                                                            (if (null?
                                                                                                  (__AST-e
                                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-8660}))
                                                                                                (if (__AST-pair?
                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-8654})
                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8661} (__AST-e
                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-8654})]
                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-8662} (\x23;\x23;car
                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8661})]
                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-8663} (\x23;\x23;cdr
                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8661})])
                                                                                                      (if (__AST-pair?
                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-8662})
                                                                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8664} (__AST-e
                                                                                                                                                           #{ehd dpuuv4a3mobea70icwo8nvdax-8662})]
                                                                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8665} (\x23;\x23;car
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8664})]
                                                                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8666} (\x23;\x23;cdr
                                                                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8664})])
                                                                                                            (if (and (__AST-id?
                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8665})
                                                                                                                     (eq? (__AST-e
                                                                                                                            #{ehd dpuuv4a3mobea70icwo8nvdax-8665})
                                                                                                                          '%\x23;ref))
                                                                                                                (if (__AST-pair?
                                                                                                                      #{etl dpuuv4a3mobea70icwo8nvdax-8666})
                                                                                                                    (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8667} (__AST-e
                                                                                                                                                                     #{etl dpuuv4a3mobea70icwo8nvdax-8666})]
                                                                                                                           [#{ehd dpuuv4a3mobea70icwo8nvdax-8668} (\x23;\x23;car
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8667})]
                                                                                                                           [#{etl dpuuv4a3mobea70icwo8nvdax-8669} (\x23;\x23;cdr
                                                                                                                                                                    #{etgt dpuuv4a3mobea70icwo8nvdax-8667})])
                                                                                                                      (let ([impl #{ehd dpuuv4a3mobea70icwo8nvdax-8668}])
                                                                                                                        (if (null?
                                                                                                                              (__AST-e
                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-8669}))
                                                                                                                            (if (__AST-pair?
                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8663})
                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8670} (__AST-e
                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8663})]
                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8671} (\x23;\x23;car
                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8670})]
                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8672} (\x23;\x23;cdr
                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8670})])
                                                                                                                                  (if (__AST-pair?
                                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8671})
                                                                                                                                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8673} (__AST-e
                                                                                                                                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8671})]
                                                                                                                                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8674} (\x23;\x23;car
                                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8673})]
                                                                                                                                             [#{etl dpuuv4a3mobea70icwo8nvdax-8675} (\x23;\x23;cdr
                                                                                                                                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8673})])
                                                                                                                                        (if (and (__AST-id?
                                                                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8674})
                                                                                                                                                 (eq? (__AST-e
                                                                                                                                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8674})
                                                                                                                                                      '%\x23;quote))
                                                                                                                                            (if (__AST-pair?
                                                                                                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8675})
                                                                                                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8676} (__AST-e
                                                                                                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8675})]
                                                                                                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8677} (\x23;\x23;car
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8676})]
                                                                                                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8678} (\x23;\x23;cdr
                                                                                                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8676})])
                                                                                                                                                  (let ([rebind? #{ehd dpuuv4a3mobea70icwo8nvdax-8677}])
                                                                                                                                                    (if (null?
                                                                                                                                                          (__AST-e
                                                                                                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-8678}))
                                                                                                                                                        (if (null?
                                                                                                                                                              (__AST-e
                                                                                                                                                                #{etl dpuuv4a3mobea70icwo8nvdax-8672}))
                                                                                                                                                            (if (runtime-identifier=?
                                                                                                                                                                  #'\x2D;bind-method
                                                                                                                                                                  'bind-method!)
                                                                                                                                                                (list
                                                                                                                                                                  'declare-method
                                                                                                                                                                  (identifier-symbol
                                                                                                                                                                    #'type-t)
                                                                                                                                                                  (stx-e
                                                                                                                                                                    #'method)
                                                                                                                                                                  (identifier-symbol
                                                                                                                                                                    #'impl)
                                                                                                                                                                  (stx-e
                                                                                                                                                                    #'rebind?))
                                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))))
                                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                                                                                      (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))))
                                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))))
                                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                              (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-8589}))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-8589})))))

(define (generate-ssxi-begin-annotation% self stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-8679} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8680} (lambda ()
                                                    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-8681} (lambda ()
                                                                                                    (__raise-syntax-error
                                                                                                      #f
                                                                                                      "Bad syntax; malformed ast clause"
                                                                                                      #{ast-val dpuuv4a3mobea70icwo8nvdax-8679}))])
                                                      (if (__AST-pair?
                                                            #{ast-val dpuuv4a3mobea70icwo8nvdax-8679})
                                                          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8682} (__AST-e
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8679})]
                                                                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8683} (\x23;\x23;car
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8682})]
                                                                 [#{etl dpuuv4a3mobea70icwo8nvdax-8684} (\x23;\x23;cdr
                                                                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8682})])
                                                            (if (__AST-pair?
                                                                  #{etl dpuuv4a3mobea70icwo8nvdax-8684})
                                                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8685} (__AST-e
                                                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8684})]
                                                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8686} (\x23;\x23;car
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8685})]
                                                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8687} (\x23;\x23;cdr
                                                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8685})])
                                                                  (let ([ann #{ehd dpuuv4a3mobea70icwo8nvdax-8686}])
                                                                    (if (__AST-pair?
                                                                          #{etl dpuuv4a3mobea70icwo8nvdax-8687})
                                                                        (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8688} (__AST-e
                                                                                                                         #{etl dpuuv4a3mobea70icwo8nvdax-8687})]
                                                                               [#{ehd dpuuv4a3mobea70icwo8nvdax-8689} (\x23;\x23;car
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8688})]
                                                                               [#{etl dpuuv4a3mobea70icwo8nvdax-8690} (\x23;\x23;cdr
                                                                                                                        #{etgt dpuuv4a3mobea70icwo8nvdax-8688})])
                                                                          (let ([body #{ehd dpuuv4a3mobea70icwo8nvdax-8689}])
                                                                            (if (null?
                                                                                  (__AST-e
                                                                                    #{etl dpuuv4a3mobea70icwo8nvdax-8690}))
                                                                                '(begin)
                                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8681}))))
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8681}))))
                                                                (#{fail dpuuv4a3mobea70icwo8nvdax-8681})))
                                                          (#{fail dpuuv4a3mobea70icwo8nvdax-8681}))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-8679})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8691} (__AST-e
                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-8679})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-8692} (\x23;\x23;car
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8691})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-8693} (\x23;\x23;cdr
                                                          #{etgt dpuuv4a3mobea70icwo8nvdax-8691})])
            (if (__AST-pair? #{etl dpuuv4a3mobea70icwo8nvdax-8693})
                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8694} (__AST-e
                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8693})]
                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8695} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8694})]
                       [#{etl dpuuv4a3mobea70icwo8nvdax-8696} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8694})])
                  (if (__AST-pair? #{ehd dpuuv4a3mobea70icwo8nvdax-8695})
                      (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8697} (__AST-e
                                                                       #{ehd dpuuv4a3mobea70icwo8nvdax-8695})]
                             [#{ehd dpuuv4a3mobea70icwo8nvdax-8698} (\x23;\x23;car
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8697})]
                             [#{etl dpuuv4a3mobea70icwo8nvdax-8699} (\x23;\x23;cdr
                                                                      #{etgt dpuuv4a3mobea70icwo8nvdax-8697})])
                        (if (and (__AST-id?
                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8698})
                                 (eq? (__AST-e
                                        #{ehd dpuuv4a3mobea70icwo8nvdax-8698})
                                      '\x40;inline))
                            (if (__AST-pair?
                                  #{etl dpuuv4a3mobea70icwo8nvdax-8699})
                                (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8700} (__AST-e
                                                                                 #{etl dpuuv4a3mobea70icwo8nvdax-8699})]
                                       [#{ehd dpuuv4a3mobea70icwo8nvdax-8701} (\x23;\x23;car
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8700})]
                                       [#{etl dpuuv4a3mobea70icwo8nvdax-8702} (\x23;\x23;cdr
                                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-8700})])
                                  (let ([proc #{ehd dpuuv4a3mobea70icwo8nvdax-8701}])
                                    (if (null?
                                          (__AST-e
                                            #{etl dpuuv4a3mobea70icwo8nvdax-8702}))
                                        (if (__AST-pair?
                                              #{etl dpuuv4a3mobea70icwo8nvdax-8696})
                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8703} (__AST-e
                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8696})]
                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8704} (\x23;\x23;car
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8703})]
                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8705} (\x23;\x23;cdr
                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8703})])
                                              (if (__AST-pair?
                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8704})
                                                  (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8706} (__AST-e
                                                                                                   #{ehd dpuuv4a3mobea70icwo8nvdax-8704})]
                                                         [#{ehd dpuuv4a3mobea70icwo8nvdax-8707} (\x23;\x23;car
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8706})]
                                                         [#{etl dpuuv4a3mobea70icwo8nvdax-8708} (\x23;\x23;cdr
                                                                                                  #{etgt dpuuv4a3mobea70icwo8nvdax-8706})])
                                                    (if (and (__AST-id?
                                                               #{ehd dpuuv4a3mobea70icwo8nvdax-8707})
                                                             (eq? (__AST-e
                                                                    #{ehd dpuuv4a3mobea70icwo8nvdax-8707})
                                                                  '%\x23;quote))
                                                        (if (__AST-pair?
                                                              #{etl dpuuv4a3mobea70icwo8nvdax-8708})
                                                            (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-8709} (__AST-e
                                                                                                             #{etl dpuuv4a3mobea70icwo8nvdax-8708})]
                                                                   [#{ehd dpuuv4a3mobea70icwo8nvdax-8710} (\x23;\x23;car
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8709})]
                                                                   [#{etl dpuuv4a3mobea70icwo8nvdax-8711} (\x23;\x23;cdr
                                                                                                            #{etgt dpuuv4a3mobea70icwo8nvdax-8709})])
                                                              (let ([rules #{ehd dpuuv4a3mobea70icwo8nvdax-8710}])
                                                                (if (null?
                                                                      (__AST-e
                                                                        #{etl dpuuv4a3mobea70icwo8nvdax-8711}))
                                                                    (if (null?
                                                                          (__AST-e
                                                                            #{etl dpuuv4a3mobea70icwo8nvdax-8705}))
                                                                        (list
                                                                          'declare-inline-rule!
                                                                          (identifier-symbol
                                                                            #'proc)
                                                                          #'rules)
                                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))
                                                                    (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))))
                                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))
                                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))
                                                  (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))
                                            (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))
                                        (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))))
                                (#{fail dpuuv4a3mobea70icwo8nvdax-8680}))
                            (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))
                      (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))
                (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))
          (#{fail dpuuv4a3mobea70icwo8nvdax-8680})))))

(begin
  (define !alias::typedecl
    (lambda (self) (list '\x40;alias (slot-ref self 'id))))
  (bind-method! !alias::t 'typedecl !alias::typedecl))

(begin
  (define !class::typedecl
    (lambda (self)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-8712} self])
        (let ([id (\x23;\x23;structure-ref
                    #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                    1)]
              [super (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                       2)]
              [precendence-list (\x23;\x23;structure-ref
                                  #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                                  3)]
              [slots (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                       4)]
              [fields (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                        5)]
              [constructor (\x23;\x23;structure-ref
                             #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                             6)]
              [struct? (\x23;\x23;structure-ref
                         #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                         7)]
              [final? (\x23;\x23;structure-ref
                        #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                        8)]
              [system? (\x23;\x23;structure-ref
                         #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                         9)]
              [metaclass (\x23;\x23;structure-ref
                           #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                           10)]
              [methods (\x23;\x23;structure-ref
                         #{with-obj dpuuv4a3mobea70icwo8nvdax-8712}
                         11)])
          (list '\x40;class id super precendence-list slots fields
            constructor struct? final? system? metaclass
            (and methods (hash->list methods)))))))
  (bind-method! !class::t 'typedecl !class::typedecl))

(begin
  (define !predicate::typedecl
    (lambda (self) (list '\x40;predicate (slot-ref self 'id))))
  (bind-method! !predicate::t 'typedecl !predicate::typedecl))

(begin
  (define !constructor::typedecl
    (lambda (self)
      (list '\x40;constructor (slot-ref self 'id))))
  (bind-method!
    !constructor::t
    'typedecl
    !constructor::typedecl))

(begin
  (define !accessor::typedecl
    (lambda (self)
      (list
        '\x40;accessor
        (slot-ref self 'id)
        (slot-ref self 'slot)
        (slot-ref self 'checked?))))
  (bind-method! !accessor::t 'typedecl !accessor::typedecl))

(begin
  (define !mutator::typedecl
    (lambda (self)
      (list
        '\x40;mutator
        (slot-ref self 'id)
        (slot-ref self 'slot)
        (slot-ref self 'checked?))))
  (bind-method! !mutator::t 'typedecl !mutator::typedecl))

(begin
  (define !interface::typedecl
    (lambda (self)
      (list
        '\x40;interface
        (slot-ref self 'id)
        (slot-ref self 'methods))))
  (bind-method! !interface::t 'typedecl !interface::typedecl))

(begin
  (define !lambda::typedecl
    (lambda (self)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-8713} self])
        (let ([signature (\x23;\x23;structure-ref
                           #{with-obj dpuuv4a3mobea70icwo8nvdax-8713}
                           2)]
              [arity (\x23;\x23;structure-ref
                       #{with-obj dpuuv4a3mobea70icwo8nvdax-8713}
                       3)]
              [dispatch (\x23;\x23;structure-ref
                          #{with-obj dpuuv4a3mobea70icwo8nvdax-8713}
                          4)])
          (if signature
              (let ([signature signature])
                (list '\x40;lambda arity dispatch 'signature:
                  (list 'return: (slot-ref signature 'return) 'effect:
                    (slot-ref signature 'effect) 'arguments:
                    (slot-ref signature 'arguments) 'unchecked:
                    (slot-ref signature 'unchecked) 'origin:
                    (slot-ref signature 'origin))))
              (list '\x40;lambda arity dispatch))))))
  (bind-method! !lambda::t 'typedecl !lambda::typedecl))

(begin
  (define !case-lambda::typedecl
    (lambda (self)
      (define (clause-e clause) (cdr (slot-ref clause 'typedecl)))
      (cons*
        '\x40;case-lambda
        (map clause-e (slot-ref self 'clauses)))))
  (bind-method!
    !case-lambda::t
    'typedecl
    !case-lambda::typedecl))

(begin
  (define !kw-lambda::typedecl
    (lambda (self)
      (list
        '\x40;kw-lambda
        (slot-ref self 'table)
        (slot-ref self 'dispatch))))
  (bind-method! !kw-lambda::t 'typedecl !kw-lambda::typedecl))

(begin
  (define !kw-lambda-primary::typedecl
    (lambda (self)
      (list
        '\x40;kw-lambda-dispatch
        (slot-ref self 'keys)
        (slot-ref self 'main))))
  (bind-method!
    !kw-lambda-primary::t
    'typedecl
    !kw-lambda-primary::typedecl))

(begin
  (define !primitive-predicate::typedecl
    (lambda (self)
      (list '\x40;primitive-predicate (slot-ref self 'id))))
  (bind-method!
    !primitive-predicate::t
    'typedecl
    !primitive-predicate::typedecl))

