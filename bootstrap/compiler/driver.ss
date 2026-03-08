(define default-gerbil-gsc
  (gambit-path-expand
    "gsc"
    (gambit-path-expand "bin" (gambit-path-expand "~~"))))

(define default-gerbil-gcc "gcc")

(define default-gerbil-ar "ar")

(define \x2B;driver-mutex+ (make-mutex 'compiler/driver))

(define-syntax with-driver-mutex
  (syntax-rules ()
    [(_ expr)
     (if (eq? (mutex-state \x2B;driver-mutex+) (current-thread))
         expr
         (with-lock \x2B;driver-mutex+ (lambda () expr)))]))

(define (compile-timestamp)
  (inexact->exact
    (floor
      (let ([t (current-time)])
        (if (time? t)
            (+ (time-second t) (/ (time-nanosecond t) 1000000000.0))
            t)))))

(define (compile-timestamp-nanos)
  (let ([t (current-time)])
    (if (time? t)
        (+ (time-second t) (/ (time-nanosecond t) 1000000000.0))
        t)))

(define scheme-file-settings
  (cons
    'permissions:
    (cons
      '420
      (cons
        'char-encoding:
        (cons 'UTF-8 (cons 'eol-encoding: '(lf)))))))

(define (with-output-to-scheme-file path fun)
  (with-output-to-file
    (cons* 'path: path scheme-file-settings)
    fun))

(define \x2B;gerbil-gsc+ #f)

(define (gerbil-gsc)
  (unless \x2B;gerbil-gsc+
    (set! \x2B;gerbil-gsc+
      (getenv "GERBIL_GSC" default-gerbil-gsc)))
  \x2B;gerbil-gsc+)

(define \x2B;gerbil-gcc+ #f)

(define (gerbil-gcc)
  (unless \x2B;gerbil-gcc+
    (set! \x2B;gerbil-gcc+
      (getenv "GERBIL_GCC" default-gerbil-gcc)))
  \x2B;gerbil-gcc+)

(define \x2B;gerbil-ar+ #f)

(define (gerbil-ar)
  (unless \x2B;gerbil-ar+
    (set! \x2B;gerbil-ar+
      (getenv "GERBIL_AR" default-gerbil-ar)))
  \x2B;gerbil-ar+)

(define (gerbil-rpath gerbil-libdir)
  (string-append (begin "-Wl,-rpath=") gerbil-libdir))

(define compiler-obj-suffix (begin ".o"))

(define (include-source path)
  (string-append "(include " (object->string path) ")"))

(define gerbil-runtime-modules
  '("gerbil/runtime/gambit" "gerbil/runtime/util" "gerbil/runtime/table"
     "gerbil/runtime/control" "gerbil/runtime/system"
     "gerbil/runtime/c3" "gerbil/runtime/mop"
     "gerbil/runtime/mop-system-classes" "gerbil/runtime/error"
     "gerbil/runtime/interface" "gerbil/runtime/hash"
     "gerbil/runtime/thread" "gerbil/runtime/syntax"
     "gerbil/runtime/eval" "gerbil/runtime/repl"
     "gerbil/runtime/loader" "gerbil/runtime/init"
     "gerbil/runtime"))

(define (delete-directory* dir)
  (delete-file-or-directory dir #t))

(define compile-module
  (case-lambda
    [(srcpath)
     (let* ([opts (list)])
       (unless (string? srcpath)
         (raise-compile-error "Invalid module source path" srcpath))
       (let* ([outdir (pgetq 'output-dir: opts)])
         (let* ([invoke-gsc? (pgetq 'invoke-gsc: opts)])
           (let* ([target (or (pgetq 'target: opts) 'C)])
             (let* ([gsc-options (append
                                   (list "-target" (symbol->string target))
                                   (or (pgetq 'gsc-options: opts)
                                       (list)))])
               (let* ([keep-scm? (pgetq 'keep-scm: opts)])
                 (let* ([verbosity (pgetq 'verbose: opts)])
                   (let* ([optimize (pgetq 'optimize: opts)])
                     (let* ([debug (pgetq 'debug: opts)])
                       (let* ([gen-ssxi (pgetq 'generate-ssxi: opts)])
                         (let* ([parallel? (pgetq 'parallel: opts)])
                           (when outdir
                             (if (eq? (mutex-state \x2B;driver-mutex+)
                                      (current-thread))
                                 (create-directory* outdir)
                                 (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3125} \x2B;driver-mutex+])
                                   (dynamic-wind
                                     (lambda ()
                                       (mutex-lock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3125}))
                                     (lambda () (create-directory* outdir))
                                     (lambda ()
                                       (mutex-unlock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3125}))))))
                           (when optimize
                             (if (eq? (mutex-state \x2B;driver-mutex+)
                                      (current-thread))
                                 (optimizer-info-init!)
                                 (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3126} \x2B;driver-mutex+])
                                   (dynamic-wind
                                     (lambda ()
                                       (mutex-lock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3126}))
                                     (lambda () (optimizer-info-init!))
                                     (lambda ()
                                       (mutex-unlock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3126}))))))
                           (parameterize ([current-compile-output-dir
                                           outdir]
                                          [current-compilation-target
                                           target]
                                          [current-compile-invoke-gsc
                                           invoke-gsc?]
                                          [current-compile-gsc-options
                                           gsc-options]
                                          [current-compile-keep-scm
                                           keep-scm?]
                                          [current-compile-verbose
                                           verbosity]
                                          [current-compile-optimize
                                           optimize]
                                          [current-compile-debug debug]
                                          [current-compile-generate-ssxi
                                           gen-ssxi]
                                          [current-compile-timestamp
                                           (compile-timestamp)]
                                          [current-compile-context
                                           `((compile-module ,srcpath))]
                                          [current-compile-parallel
                                           parallel?]
                                          [current-expander-compiling? #t])
                             (verbose "compile " srcpath)
                             (compile-top-module
                               (if (eq? (mutex-state \x2B;driver-mutex+)
                                        (current-thread))
                                   (import-module srcpath)
                                   (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3127} \x2B;driver-mutex+])
                                     (dynamic-wind
                                       (lambda ()
                                         (mutex-lock!
                                           #{mtx dpuuv4a3mobea70icwo8nvdax-3127}))
                                       (lambda () (import-module srcpath))
                                       (lambda ()
                                         (mutex-unlock!
                                           #{mtx dpuuv4a3mobea70icwo8nvdax-3127}))))))))))))))))))]
    [(srcpath opts)
     (unless (string? srcpath)
       (raise-compile-error "Invalid module source path" srcpath))
     (let* ([outdir (pgetq 'output-dir: opts)])
       (let* ([invoke-gsc? (pgetq 'invoke-gsc: opts)])
         (let* ([target (or (pgetq 'target: opts) 'C)])
           (let* ([gsc-options (append
                                 (list "-target" (symbol->string target))
                                 (or (pgetq 'gsc-options: opts) (list)))])
             (let* ([keep-scm? (pgetq 'keep-scm: opts)])
               (let* ([verbosity (pgetq 'verbose: opts)])
                 (let* ([optimize (pgetq 'optimize: opts)])
                   (let* ([debug (pgetq 'debug: opts)])
                     (let* ([gen-ssxi (pgetq 'generate-ssxi: opts)])
                       (let* ([parallel? (pgetq 'parallel: opts)])
                         (when outdir
                           (if (eq? (mutex-state \x2B;driver-mutex+)
                                    (current-thread))
                               (create-directory* outdir)
                               (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3125} \x2B;driver-mutex+])
                                 (dynamic-wind
                                   (lambda ()
                                     (mutex-lock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3125}))
                                   (lambda () (create-directory* outdir))
                                   (lambda ()
                                     (mutex-unlock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3125}))))))
                         (when optimize
                           (if (eq? (mutex-state \x2B;driver-mutex+)
                                    (current-thread))
                               (optimizer-info-init!)
                               (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3126} \x2B;driver-mutex+])
                                 (dynamic-wind
                                   (lambda ()
                                     (mutex-lock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3126}))
                                   (lambda () (optimizer-info-init!))
                                   (lambda ()
                                     (mutex-unlock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3126}))))))
                         (parameterize ([current-compile-output-dir outdir]
                                        [current-compilation-target target]
                                        [current-compile-invoke-gsc
                                         invoke-gsc?]
                                        [current-compile-gsc-options
                                         gsc-options]
                                        [current-compile-keep-scm
                                         keep-scm?]
                                        [current-compile-verbose verbosity]
                                        [current-compile-optimize optimize]
                                        [current-compile-debug debug]
                                        [current-compile-generate-ssxi
                                         gen-ssxi]
                                        [current-compile-timestamp
                                         (compile-timestamp)]
                                        [current-compile-context
                                         `((compile-module ,srcpath))]
                                        [current-compile-parallel
                                         parallel?]
                                        [current-expander-compiling? #t])
                           (verbose "compile " srcpath)
                           (compile-top-module
                             (if (eq? (mutex-state \x2B;driver-mutex+)
                                      (current-thread))
                                 (import-module srcpath)
                                 (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3127} \x2B;driver-mutex+])
                                   (dynamic-wind
                                     (lambda ()
                                       (mutex-lock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3127}))
                                     (lambda () (import-module srcpath))
                                     (lambda ()
                                       (mutex-unlock!
                                         #{mtx dpuuv4a3mobea70icwo8nvdax-3127})))))))))))))))))]))

(define compile-exe
  (case-lambda
    [(srcpath)
     (let* ([opts (list)])
       (unless (string? srcpath)
         (raise-compile-error "Invalid module source path" srcpath))
       (let* ([outdir (pgetq 'output-dir: opts)])
         (let* ([invoke-gsc? (pgetq 'invoke-gsc: opts)])
           (let* ([target (or (pgetq 'target: opts) 'C)])
             (let* ([gsc-options (append
                                   (list "-target" (symbol->string target))
                                   (or (pgetq 'gsc-options: opts)
                                       (list)))])
               (let* ([keep-scm? (pgetq 'keep-scm: opts)])
                 (let* ([verbosity (pgetq 'verbose: opts)])
                   (let* ([debug (pgetq 'debug: opts)])
                     (let* ([parallel? (pgetq 'parallel: opts)])
                       (when outdir
                         (if (eq? (mutex-state \x2B;driver-mutex+)
                                  (current-thread))
                             (create-directory* outdir)
                             (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3128} \x2B;driver-mutex+])
                               (dynamic-wind
                                 (lambda ()
                                   (mutex-lock!
                                     #{mtx dpuuv4a3mobea70icwo8nvdax-3128}))
                                 (lambda () (create-directory* outdir))
                                 (lambda ()
                                   (mutex-unlock!
                                     #{mtx dpuuv4a3mobea70icwo8nvdax-3128}))))))
                       (parameterize ([current-compile-output-dir outdir]
                                      [current-compile-invoke-gsc
                                       invoke-gsc?]
                                      [current-compilation-target target]
                                      [current-compile-gsc-options
                                       gsc-options]
                                      [current-compile-keep-scm keep-scm?]
                                      [current-compile-verbose verbosity]
                                      [current-compile-debug debug]
                                      [current-compile-timestamp
                                       (compile-timestamp)]
                                      [current-compile-context
                                       `((compile-exe ,srcpath))]
                                      [current-compile-parallel parallel?]
                                      [current-expander-compiling? #t])
                         (verbose "compile exe " srcpath)
                         (compile-executable-module
                           (if (eq? (mutex-state \x2B;driver-mutex+)
                                    (current-thread))
                               (import-module srcpath)
                               (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3129} \x2B;driver-mutex+])
                                 (dynamic-wind
                                   (lambda ()
                                     (mutex-lock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3129}))
                                   (lambda () (import-module srcpath))
                                   (lambda ()
                                     (mutex-unlock!
                                       #{mtx dpuuv4a3mobea70icwo8nvdax-3129})))))
                           opts)))))))))))]
    [(srcpath opts)
     (unless (string? srcpath)
       (raise-compile-error "Invalid module source path" srcpath))
     (let* ([outdir (pgetq 'output-dir: opts)])
       (let* ([invoke-gsc? (pgetq 'invoke-gsc: opts)])
         (let* ([target (or (pgetq 'target: opts) 'C)])
           (let* ([gsc-options (append
                                 (list "-target" (symbol->string target))
                                 (or (pgetq 'gsc-options: opts) (list)))])
             (let* ([keep-scm? (pgetq 'keep-scm: opts)])
               (let* ([verbosity (pgetq 'verbose: opts)])
                 (let* ([debug (pgetq 'debug: opts)])
                   (let* ([parallel? (pgetq 'parallel: opts)])
                     (when outdir
                       (if (eq? (mutex-state \x2B;driver-mutex+)
                                (current-thread))
                           (create-directory* outdir)
                           (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3128} \x2B;driver-mutex+])
                             (dynamic-wind
                               (lambda ()
                                 (mutex-lock!
                                   #{mtx dpuuv4a3mobea70icwo8nvdax-3128}))
                               (lambda () (create-directory* outdir))
                               (lambda ()
                                 (mutex-unlock!
                                   #{mtx dpuuv4a3mobea70icwo8nvdax-3128}))))))
                     (parameterize ([current-compile-output-dir outdir]
                                    [current-compile-invoke-gsc
                                     invoke-gsc?]
                                    [current-compilation-target target]
                                    [current-compile-gsc-options
                                     gsc-options]
                                    [current-compile-keep-scm keep-scm?]
                                    [current-compile-verbose verbosity]
                                    [current-compile-debug debug]
                                    [current-compile-timestamp
                                     (compile-timestamp)]
                                    [current-compile-context
                                     `((compile-exe ,srcpath))]
                                    [current-compile-parallel parallel?]
                                    [current-expander-compiling? #t])
                       (verbose "compile exe " srcpath)
                       (compile-executable-module
                         (if (eq? (mutex-state \x2B;driver-mutex+)
                                  (current-thread))
                             (import-module srcpath)
                             (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3129} \x2B;driver-mutex+])
                               (dynamic-wind
                                 (lambda ()
                                   (mutex-lock!
                                     #{mtx dpuuv4a3mobea70icwo8nvdax-3129}))
                                 (lambda () (import-module srcpath))
                                 (lambda ()
                                   (mutex-unlock!
                                     #{mtx dpuuv4a3mobea70icwo8nvdax-3129})))))
                         opts))))))))))]))

(define (compile-executable-module ctx opts)
  (if (pgetq 'full-program-optimization: opts)
      (compile-executable-module/full-program-optimization
        ctx
        opts)
      (compile-executable-module/separate ctx opts)))

(define (compile-executable-module/separate ctx opts)
  (define (generate-stub builtin-modules)
    (let ([mod-main (find-runtime-symbol ctx 'main)])
      (write `(define builtin-modules ',builtin-modules))
      (write
        `(define (gerbil-main)
           (with-unwind-protect
             (lambda ()
               (gerbil-runtime-init! builtin-modules)
               (apply ,mod-main (cdr (command-line))))
             (lambda ()
               (with-catch
                 void
                 (lambda () (force-output (current-output-port))))
               (with-catch
                 void
                 (lambda () (force-output (current-error-port))))))))
      (write '(gerbil-main))
      (newline)))
  (define (get-libgerbil-ld-opts gerbil-libdir)
    (call-with-input-file
      (gambit-path-expand "libgerbil.ldd" gerbil-libdir)
      read))
  (define (replace-extension path ext)
    (string-append (path-strip-extension path) ext))
  (define (replace-extension-with-c path)
    (replace-extension path ".c"))
  (define (replace-extension-with-object path)
    (replace-extension path compiler-obj-suffix))
  (define (userlib-module? ctx)
    (and (not (exclude-module? ctx))
         (not (libgerbil-module? ctx))))
  (define (libgerbil-module? ctx)
    (let ([id-str (symbol->string (expander-context-id ctx))])
      (and (not (exclude-module? id-str))
           (or (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-3130} "gerbil/"]
                     [#{str dpuuv4a3mobea70icwo8nvdax-3131} id-str])
                 (let ([plen (string-length
                               #{pfx dpuuv4a3mobea70icwo8nvdax-3130})])
                   (and (<= plen
                            (string-length
                              #{str dpuuv4a3mobea70icwo8nvdax-3131}))
                        (string=?
                          #{pfx dpuuv4a3mobea70icwo8nvdax-3130}
                          (substring
                            #{str dpuuv4a3mobea70icwo8nvdax-3131}
                            0
                            plen)))))
               (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-3132} "std/"]
                     [#{str dpuuv4a3mobea70icwo8nvdax-3133} id-str])
                 (let ([plen (string-length
                               #{pfx dpuuv4a3mobea70icwo8nvdax-3132})])
                   (and (<= plen
                            (string-length
                              #{str dpuuv4a3mobea70icwo8nvdax-3133}))
                        (string=?
                          #{pfx dpuuv4a3mobea70icwo8nvdax-3132}
                          (substring
                            #{str dpuuv4a3mobea70icwo8nvdax-3133}
                            0
                            plen)))))))))
  (define (exclude-module? ctx-or-str)
    (let ([str (if (string? ctx-or-str)
                   ctx-or-str
                   (symbol->string (expander-context-id ctx-or-str)))])
      (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-3134} "gerbil/core"]
            [#{str dpuuv4a3mobea70icwo8nvdax-3135} str])
        (let ([plen (string-length
                      #{pfx dpuuv4a3mobea70icwo8nvdax-3134})])
          (and (<= plen
                   (string-length #{str dpuuv4a3mobea70icwo8nvdax-3135}))
               (string=?
                 #{pfx dpuuv4a3mobea70icwo8nvdax-3134}
                 (substring
                   #{str dpuuv4a3mobea70icwo8nvdax-3135}
                   0
                   plen)))))))
  (define (not-file-empty? path) (not (file-empty? path)))
  (define (fold-libgerbil-runtime-scm gerbil-staticdir
           libgerbil-scm)
    (let ([gerbil-runtime-scm (map (lambda (rtm)
                                     (gambit-path-expand
                                       (string-append
                                         (let ([#{strs dpuuv4a3mobea70icwo8nvdax-3136} (let ([#{str dpuuv4a3mobea70icwo8nvdax-3137} rtm]
                                                                                             [#{sep dpuuv4a3mobea70icwo8nvdax-3138} (if (char?
                                                                                                                                          #\/)
                                                                                                                                        #\/
                                                                                                                                        (string-ref
                                                                                                                                          #\/
                                                                                                                                          0))])
                                                                                         (let split-lp ([i 0]
                                                                                                        [start 0]
                                                                                                        [acc '()])
                                                                                           (cond
                                                                                             [(= i
                                                                                                 (string-length
                                                                                                   #{str dpuuv4a3mobea70icwo8nvdax-3137}))
                                                                                              (reverse
                                                                                                (cons
                                                                                                  (substring
                                                                                                    #{str dpuuv4a3mobea70icwo8nvdax-3137}
                                                                                                    start
                                                                                                    i)
                                                                                                  acc))]
                                                                                             [(char=?
                                                                                                (string-ref
                                                                                                  #{str dpuuv4a3mobea70icwo8nvdax-3137}
                                                                                                  i)
                                                                                                #{sep dpuuv4a3mobea70icwo8nvdax-3138})
                                                                                              (split-lp
                                                                                                (+ i
                                                                                                   1)
                                                                                                (+ i
                                                                                                   1)
                                                                                                (cons
                                                                                                  (substring
                                                                                                    #{str dpuuv4a3mobea70icwo8nvdax-3137}
                                                                                                    start
                                                                                                    i)
                                                                                                  acc))]
                                                                                             [else
                                                                                              (split-lp
                                                                                                (+ i
                                                                                                   1)
                                                                                                start
                                                                                                acc)])))]
                                               [#{sep dpuuv4a3mobea70icwo8nvdax-3139} "__"])
                                           (if (null?
                                                 #{strs dpuuv4a3mobea70icwo8nvdax-3136})
                                               ""
                                               (let lp ([#{result dpuuv4a3mobea70icwo8nvdax-3140} (car #{strs dpuuv4a3mobea70icwo8nvdax-3136})]
                                                        [rest (cdr #{strs dpuuv4a3mobea70icwo8nvdax-3136})])
                                                 (if (null? rest)
                                                     #{result dpuuv4a3mobea70icwo8nvdax-3140}
                                                     (lp (string-append
                                                           #{result dpuuv4a3mobea70icwo8nvdax-3140}
                                                           #{sep dpuuv4a3mobea70icwo8nvdax-3139}
                                                           (car rest))
                                                         (cdr rest))))))
                                         ".scm")
                                       gerbil-staticdir))
                                   gerbil-runtime-modules)])
      (remove-duplicates
        (append gerbil-runtime-scm libgerbil-scm))))
  (define (remove-duplicates strlst)
    (let loop ([rest strlst] [result (list)])
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3141} rest])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3141})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3142} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3141})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-3143} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3141})])
              (let ([path #{hd dpuuv4a3mobea70icwo8nvdax-3142}])
                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3143}])
                  (begin
                    (if (member path result)
                        (loop rest result)
                        (loop rest (cons path result)))))))
            (begin (reverse! result))))))
  (define (compile-stub output-scm output-bin)
    (let* ([gerbil-home (getenv
                          "GERBIL_BUILD_PREFIX"
                          (gerbil-home))])
      (let* ([gerbil-libdir (gambit-path-expand
                              "lib"
                              gerbil-home)])
        (let* ([gerbil-staticdir (gambit-path-expand
                                   "static"
                                   gerbil-libdir)])
          (let* ([deps (find-runtime-module-deps ctx)])
            (let* ([libgerbil-deps (filter libgerbil-module? deps)])
              (let* ([libgerbil-scm (map find-static-module-file
                                         libgerbil-deps)])
                (let* ([libgerbil-scm (fold-libgerbil-runtime-scm
                                        gerbil-staticdir
                                        libgerbil-scm)])
                  (let* ([libgerbil-c (map replace-extension-with-c
                                           libgerbil-scm)])
                    (let* ([libgerbil-o (map replace-extension-with-object
                                             libgerbil-scm)])
                      (let* ([src-deps (filter userlib-module? deps)])
                        (let* ([src-deps-scm (map find-static-module-file
                                                  src-deps)])
                          (let* ([src-deps-scm (filter
                                                 not-file-empty?
                                                 src-deps-scm)])
                            (let* ([src-deps-scm (map path-expand
                                                      src-deps-scm)])
                              (let* ([src-deps-c (map replace-extension-with-c
                                                      src-deps-scm)])
                                (let* ([src-deps-o (map replace-extension-with-object
                                                        src-deps-scm)])
                                  (let* ([src-bin-scm (find-static-module-file
                                                        ctx)])
                                    (let* ([src-bin-scm (gambit-path-expand
                                                          src-bin-scm)])
                                      (let* ([src-bin-c (replace-extension-with-c
                                                          src-bin-scm)])
                                        (let* ([src-bin-o (replace-extension-with-object
                                                            src-bin-scm)])
                                          (let* ([output-bin (gambit-path-expand
                                                               output-bin)])
                                            (let* ([output-scm (gambit-path-expand
                                                                 output-scm)])
                                              (let* ([output-c (replace-extension-with-c
                                                                 output-scm)])
                                                (let* ([output-o (replace-extension-with-object
                                                                   output-scm)])
                                                  (let* ([output_-c (replace-extension
                                                                      output-scm
                                                                      "_.c")])
                                                    (let* ([output_-o (replace-extension
                                                                        output-scm
                                                                        (string-append
                                                                          "_"
                                                                          compiler-obj-suffix))])
                                                      (let* ([gsc-link-opts (gsc-link-options)])
                                                        (let* ([gsc-cc-opts (gsc-cc-options
                                                                              'static:
                                                                              #t)])
                                                          (let* ([gsc-static-opts (gsc-static-include-options
                                                                                    gerbil-staticdir)])
                                                            (let* ([output-ld-opts (gcc-ld-options)])
                                                              (let* ([libgerbil-ld-opts (get-libgerbil-ld-opts
                                                                                          gerbil-libdir)])
                                                                (let* ([rpath (gerbil-rpath
                                                                                gerbil-libdir)])
                                                                  (let* ([builtin-modules (remove-duplicates
                                                                                            (append
                                                                                              gerbil-runtime-modules
                                                                                              (map (lambda (mod)
                                                                                                     (symbol->string
                                                                                                       (expander-context-id
                                                                                                         mod)))
                                                                                                   (cons
                                                                                                     ctx
                                                                                                     deps))))])
                                                                    (define (compile-obj
                                                                             scm-path
                                                                             c-path)
                                                                      (let ([o-path (replace-extension
                                                                                      c-path
                                                                                      compiler-obj-suffix)])
                                                                        (let* ([lock (string-append
                                                                                       o-path
                                                                                       ".lock")])
                                                                          (let* ([locked #f])
                                                                            (let* ([unlock (lambda ()
                                                                                             (close-port
                                                                                               locked)
                                                                                             (delete-file
                                                                                               lock))])
                                                                              (let retry ()
                                                                                (if (file-exists?
                                                                                      lock)
                                                                                    (begin
                                                                                      (thread-sleep!
                                                                                        \x2E;01)
                                                                                      (retry))
                                                                                    (begin
                                                                                      (set! locked
                                                                                        (guard (__exn
                                                                                                 [#t
                                                                                                  (false
                                                                                                    __exn)])
                                                                                          ((lambda ()
                                                                                             (open-file
                                                                                               (list
                                                                                                 'path:
                                                                                                 lock
                                                                                                 'create:
                                                                                                 #t))))))
                                                                                      (unless locked
                                                                                        (retry)))))
                                                                              (dynamic-wind
                                                                                (lambda ()
                                                                                  (void))
                                                                                (lambda ()
                                                                                  (when (or (not (file-exists?
                                                                                                   o-path))
                                                                                            (not scm-path)
                                                                                            (file-newer?
                                                                                              scm-path
                                                                                              o-path))
                                                                                    (let ([gsc-cc-opts (gsc-cc-options
                                                                                                         'static:
                                                                                                         #f)])
                                                                                      (invoke
                                                                                        (gerbil-gsc)
                                                                                        (list
                                                                                          "-obj"
                                                                                          gsc-cc-opts
                                                                                          ...
                                                                                          gsc-static-opts
                                                                                          ...
                                                                                          c-path)))))
                                                                                (lambda ()
                                                                                  (unlock))))))))
                                                                    (if (eq? (mutex-state
                                                                               \x2B;driver-mutex+)
                                                                             (current-thread))
                                                                        (create-directory*
                                                                          (path-directory
                                                                            output-bin))
                                                                        (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3144} \x2B;driver-mutex+])
                                                                          (dynamic-wind
                                                                            (lambda ()
                                                                              (mutex-lock!
                                                                                #{mtx dpuuv4a3mobea70icwo8nvdax-3144}))
                                                                            (lambda ()
                                                                              (create-directory*
                                                                                (path-directory
                                                                                  output-bin)))
                                                                            (lambda ()
                                                                              (mutex-unlock!
                                                                                #{mtx dpuuv4a3mobea70icwo8nvdax-3144})))))
                                                                    (with-output-to-scheme-file
                                                                      output-scm
                                                                      (lambda ()
                                                                        (generate-stub
                                                                          builtin-modules)))
                                                                    (when (current-compile-invoke-gsc)
                                                                      (let ([compile-it (lambda ()
                                                                                          (invoke
                                                                                            (gerbil-gsc)
                                                                                            (list
                                                                                              "-link"
                                                                                              gsc-link-opts
                                                                                              ...
                                                                                              libgerbil-c
                                                                                              ...
                                                                                              src-deps-scm
                                                                                              ...
                                                                                              src-bin-scm
                                                                                              output-scm))
                                                                                          (for-each
                                                                                            compile-obj
                                                                                            (list
                                                                                              src-deps-scm
                                                                                              ...
                                                                                              src-bin-scm
                                                                                              output-scm
                                                                                              #f)
                                                                                            (list
                                                                                              src-deps-c
                                                                                              ...
                                                                                              src-bin-c
                                                                                              output-c
                                                                                              output_-c))
                                                                                          (invoke
                                                                                            (gerbil-gcc)
                                                                                            (cons*
                                                                                              "-w"
                                                                                              "-o"
                                                                                              output-bin
                                                                                              src-deps-o
                                                                                              ...
                                                                                              src-bin-o
                                                                                              output-o
                                                                                              output_-o
                                                                                              libgerbil-o
                                                                                              ...
                                                                                              output-ld-opts
                                                                                              ...
                                                                                              (if (gerbil-enable-shared?)
                                                                                                  (list
                                                                                                    rpath)
                                                                                                  (list))
                                                                                              ...
                                                                                              "-L"
                                                                                              gerbil-libdir
                                                                                              "-lgambit"
                                                                                              libgerbil-ld-opts))
                                                                                          (for-each
                                                                                            delete-file
                                                                                            (list
                                                                                              output-c
                                                                                              output_-c
                                                                                              output-o
                                                                                              output_-o)))])
                                                                        (if (current-compile-parallel)
                                                                            (add-compile-job!
                                                                              compile-it)
                                                                            (compile-it)))))))))))))))))))))))))))))))))))))
  (let* ([output-bin (compile-exe-output-file ctx opts)])
    (let* ([output-scm (string-append output-bin "__exe.scm")])
      (compile-stub output-scm output-bin))))

(define (compile-executable-module/full-program-optimization
         ctx opts)
  (define (reset-declare)
    '(declare (gambit-scheme) (block) (core) (inline) (inline-primitives)
       (inlining-limit 350) (constant-fold) (lambda-lift)
       (standard-bindings) (extended-bindings) (run-time-bindings)
       (safe) (interrupts-enabled) (proper-tail-calls)
       (not generative-lambda) (optimize-dead-local-variables)
       (optimize-dead-definitions) (generic)
       (mostly-fixnum-flonum)))
  (define (generate-stub deps)
    (let ([mod-main (find-runtime-symbol ctx 'main)]
          [reset-decl (reset-declare)]
          [user-decl (user-declare)])
      (for-each
        (lambda (dep)
          (write '(\x23;\x23;namespace ("")))
          (newline)
          (write reset-decl)
          (newline)
          (when user-decl (write user-decl) (newline))
          (write `(include ,dep))
          (newline))
        deps)
      (write
        `(define (gerbil-main)
           (gerbil-runtime-init! '())
           (apply ,mod-main (cdr (command-line)))))
      (write '(gerbil-main))
      (newline)))
  (define (user-declare)
    (let* ([gsc-opts (pgetq 'gsc-options: opts)])
      (let* ([gsc-prelude (and gsc-opts
                               (member "-prelude" gsc-opts))])
        (let* ([gsc-prelude (and gsc-prelude
                                 (read
                                   (open-input-string
                                     (cadr gsc-prelude))))])
          (let lp ([rest (list gsc-prelude)] [user-decls (list)])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3145} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3145})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3146} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3145})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-3147} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3145})])
                    (let ([expr #{hd dpuuv4a3mobea70icwo8nvdax-3146}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3147}])
                        (begin
                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3148} expr])
                            (if (pair?
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-3148})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3149} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3148})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-3150} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3148})])
                                  (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-3149}
                                           'declare)
                                      (let ([decls #{tl dpuuv4a3mobea70icwo8nvdax-3150}])
                                        (begin
                                          (lp rest
                                              (let ([#{f dpuuv4a3mobea70icwo8nvdax-3151} cons])
                                                (fold-left
                                                  (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3152}
                                                           #{e dpuuv4a3mobea70icwo8nvdax-3153})
                                                    (#{f dpuuv4a3mobea70icwo8nvdax-3151}
                                                      #{e dpuuv4a3mobea70icwo8nvdax-3153}
                                                      #{a dpuuv4a3mobea70icwo8nvdax-3152}))
                                                  user-decls
                                                  decls)))))
                                      (if (pair?
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-3148})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3154} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3148})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-3155} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3148})])
                                            (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-3154}
                                                     'begin)
                                                (let ([exprs #{tl dpuuv4a3mobea70icwo8nvdax-3155}])
                                                  (begin
                                                    (lp (append exprs rest)
                                                        user-decls)))
                                                (begin
                                                  (lp rest user-decls))))
                                          (begin (lp rest user-decls)))))
                                (if (pair?
                                      #{match-val dpuuv4a3mobea70icwo8nvdax-3148})
                                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3154} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3148})]
                                          [#{tl dpuuv4a3mobea70icwo8nvdax-3155} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3148})])
                                      (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-3154}
                                               'begin)
                                          (let ([exprs #{tl dpuuv4a3mobea70icwo8nvdax-3155}])
                                            (begin
                                              (lp (append exprs rest)
                                                  user-decls)))
                                          (begin (lp rest user-decls))))
                                    (begin (lp rest user-decls)))))))))
                  (begin
                    (if (null? user-decls)
                        #f
                        (cons 'declare (reverse user-decls)))))))))))
  (define (compile-stub output-scm output-bin)
    (let* ([gerbil-home (getenv
                          "GERBIL_BUILD_PREFIX"
                          (gerbil-home))])
      (let* ([gerbil-libdir (gambit-path-expand
                              "lib"
                              gerbil-home)])
        (let* ([runtime (map find-static-module-file
                             gerbil-runtime-modules)])
          (let* ([gambit-sharp (gambit-path-expand
                                 "lib/_gambit#.scm"
                                 gerbil-home)])
            (let* ([include-gambit-sharp (include-source gambit-sharp)])
              (let* ([bin-scm (find-static-module-file ctx)])
                (let* ([deps (find-runtime-module-deps ctx)])
                  (let* ([deps (map find-static-module-file deps)])
                    (let* ([deps (filter
                                   (lambda (#{$obj dpuuv4a3mobea70icwo8nvdax-3156})
                                     (not (file-empty?
                                            #{$obj dpuuv4a3mobea70icwo8nvdax-3156})))
                                   deps)])
                      (let* ([deps (filter
                                     (lambda (f) (not (member f runtime)))
                                     deps)])
                        (let* ([output-base (string-append
                                              (path-strip-extension
                                                output-scm))])
                          (let* ([output-c (string-append
                                             output-base
                                             ".c")])
                            (let* ([output-o (string-append
                                               output-base
                                               compiler-obj-suffix)])
                              (let* ([output-c_ (string-append
                                                  output-base
                                                  "_.c")])
                                (let* ([output-o_ (string-append
                                                    output-base
                                                    (string-append
                                                      "_"
                                                      compiler-obj-suffix))])
                                  (let* ([gsc-link-opts (gsc-link-options)])
                                    (let* ([gsc-cc-opts (gsc-cc-options
                                                          'static:
                                                          #t)])
                                      (let* ([gsc-static-opts (gsc-static-include-options
                                                                (gambit-path-expand
                                                                  "static"
                                                                  gerbil-libdir))])
                                        (let* ([output-ld-opts (gcc-ld-options)])
                                          (let* ([gsc-gx-macros (if (gerbil-runtime-smp?)
                                                                    (list
                                                                      "-e"
                                                                      "(define-cond-expand-feature|enable-smp|)"
                                                                      "-e"
                                                                      include-gambit-sharp)
                                                                    (list
                                                                      "-e"
                                                                      include-gambit-sharp))])
                                            (let* ([gsc-link-opts (append
                                                                    gsc-link-opts
                                                                    gsc-gx-macros)])
                                              (let* ([rpath (gerbil-rpath
                                                              gerbil-libdir)])
                                                (let* ([default-ld-options (begin
                                                                             "-ldl")])
                                                  (if (eq? (mutex-state
                                                             \x2B;driver-mutex+)
                                                           (current-thread))
                                                      (create-directory*
                                                        (path-directory
                                                          output-bin))
                                                      (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3157} \x2B;driver-mutex+])
                                                        (dynamic-wind
                                                          (lambda ()
                                                            (mutex-lock!
                                                              #{mtx dpuuv4a3mobea70icwo8nvdax-3157}))
                                                          (lambda ()
                                                            (create-directory*
                                                              (path-directory
                                                                output-bin)))
                                                          (lambda ()
                                                            (mutex-unlock!
                                                              #{mtx dpuuv4a3mobea70icwo8nvdax-3157})))))
                                                  (with-output-to-scheme-file
                                                    output-scm
                                                    (lambda ()
                                                      (generate-stub
                                                        (list runtime ...
                                                          deps ...
                                                          bin-scm))))
                                                  (when (current-compile-invoke-gsc)
                                                    (let ([compile-it (lambda ()
                                                                        (invoke
                                                                          (gerbil-gsc)
                                                                          (list
                                                                            "-link"
                                                                            "-o"
                                                                            output-c_
                                                                            gsc-link-opts
                                                                            ...
                                                                            output-scm))
                                                                        (invoke
                                                                          (gerbil-gsc)
                                                                          (list
                                                                            "-obj"
                                                                            gsc-cc-opts
                                                                            ...
                                                                            gsc-static-opts
                                                                            ...
                                                                            output-c
                                                                            output-c_))
                                                                        (invoke
                                                                          (gerbil-gcc)
                                                                          (cons*
                                                                            "-w"
                                                                            "-o"
                                                                            output-bin
                                                                            output-o
                                                                            output-o_
                                                                            output-ld-opts
                                                                            ...
                                                                            (if (gerbil-enable-shared?)
                                                                                (list
                                                                                  rpath)
                                                                                (list))
                                                                            ...
                                                                            "-L"
                                                                            gerbil-libdir
                                                                            "-lgambit"
                                                                            default-ld-options)))])
                                                      (if (current-compile-parallel)
                                                          (add-compile-job!
                                                            compile-it)
                                                          (compile-it))))))))))))))))))))))))))))
  (let* ([output-bin (compile-exe-output-file ctx opts)])
    (let* ([output-scm (string-append output-bin "__exe.scm")])
      (compile-stub output-scm output-bin))))

(define (find-export-binding ctx id)
  (cond
    [(find
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3158} <>])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3158})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3159} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3158})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-3160} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3158})])
               (let ([module-export #{hd dpuuv4a3mobea70icwo8nvdax-3159}])
                 (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3160})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3161} (car #{tl dpuuv4a3mobea70icwo8nvdax-3160})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3162} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3160})])
                       (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3162})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3163} (car #{tl dpuuv4a3mobea70icwo8nvdax-3162})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3164} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3162})])
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3164})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3165} (car #{tl dpuuv4a3mobea70icwo8nvdax-3164})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3166} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3164})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3165}
                                         '0)
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3166})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3167} (car #{tl dpuuv4a3mobea70icwo8nvdax-3166})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3168} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3166})])
                                             (if (pair?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3167})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3169} (car #{hd dpuuv4a3mobea70icwo8nvdax-3167})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3170} (cdr #{hd dpuuv4a3mobea70icwo8nvdax-3167})])
                                                   (let ([eq? #{hd dpuuv4a3mobea70icwo8nvdax-3169}])
                                                     (if (pair?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-3170})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3171} (car #{tl dpuuv4a3mobea70icwo8nvdax-3170})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3172} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3170})])
                                                           (let ([id #{hd dpuuv4a3mobea70icwo8nvdax-3171}])
                                                             (if (null?
                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3172})
                                                                 (if (null?
                                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3168})
                                                                     (begin
                                                                       #t)
                                                                     (begin
                                                                       #f))
                                                                 (begin
                                                                   #f))))
                                                         (begin #f))))
                                                 (begin #f)))
                                           (begin #f))
                                       (begin #f)))
                                 (begin #f)))
                           (begin #f)))
                     (begin #f))))
             (begin #f)))
       (module-context-export ctx)) =>
     core-resolve-module-export]
    [else #f]))

(define (find-runtime-symbol ctx id)
  (cond
    [(find-export-binding ctx id) =>
     (lambda (bind)
       (unless (runtime-binding? bind)
         (raise-compile-error "export is not a runtime binding" id))
       (binding-id bind))]
    [else
     (raise-compile-error
       "module does not export symbol"
       (expander-context-id ctx)
       id)]))

(define (find-runtime-module-deps ctx)
  (define ht (make-hash-table-eq))
  (define (import-set-template in phi)
    (let ([iphi (fx+ phi (import-set-phi in))]
          [imports (module-context-import (import-set-source in))])
      (let lp ([rest imports] [r (list)])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3173} rest])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3173})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3174} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3173})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-3175} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3173})])
                (let ([in #{hd dpuuv4a3mobea70icwo8nvdax-3174}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3175}])
                    (begin
                      (cond
                        [(module-context? in)
                         (if (fxzero? iphi)
                             (lp rest (cons in r))
                             (lp rest r))]
                        [(module-import? in)
                         (let ([iphi (fx+ phi (module-import-phi in))])
                           (if (fxzero? iphi)
                               (lp rest
                                   (cons
                                     (module-export-context
                                       (module-import-source in))
                                     r))
                               (lp rest r)))]
                        [(import-set? in)
                         (let ([xphi (fx+ iphi (import-set-phi in))])
                           (cond
                             [(fxzero? xphi)
                              (lp rest (cons (import-set-source in) r))]
                             [(fxpositive? xphi)
                              (lp rest
                                  (let ([#{f dpuuv4a3mobea70icwo8nvdax-3176} cons])
                                    (fold-left
                                      (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3177}
                                               #{e dpuuv4a3mobea70icwo8nvdax-3178})
                                        (#{f dpuuv4a3mobea70icwo8nvdax-3176}
                                          #{e dpuuv4a3mobea70icwo8nvdax-3178}
                                          #{a dpuuv4a3mobea70icwo8nvdax-3177}))
                                      r
                                      (import-set-template in iphi))))]
                             [else (lp rest r)]))]
                        [else (lp rest r)])))))
              (begin r))))))
  (define (find-deps rest deps)
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3179} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3179})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3180} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3179})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-3181} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3179})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-3180}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3181}])
                (begin
                  (cond
                    [(module-context? hd)
                     (let ([id (expander-context-id hd)]
                           [imports (module-context-import hd)])
                       (cond
                         [(hash-get ht id) (find-deps rest deps)]
                         [(core-context-prelude hd) =>
                          (lambda (pre)
                            (let ([xdeps (find-deps
                                           (cons pre imports)
                                           deps)])
                              (hash-put! ht id hd)
                              (find-deps rest (cons hd xdeps))))]
                         [else
                          (let ([xdeps (find-deps imports deps)])
                            (hash-put! ht id hd)
                            (find-deps rest (cons hd xdeps)))]))]
                    [(prelude-context? hd)
                     (let ([id (expander-context-id hd)])
                       (cond
                         [(hash-get ht id) (find-deps rest deps)]
                         [else
                          (let ([xdeps (find-deps
                                         (prelude-context-import hd)
                                         deps)])
                            (if (hash-get ht id)
                                (find-deps rest xdeps)
                                (begin
                                  (hash-put! ht id hd)
                                  (find-deps rest (cons hd xdeps)))))]))]
                    [(module-import? hd)
                     (if (fxzero? (module-import-phi hd))
                         (find-deps
                           (cons (module-import-source hd) rest)
                           deps)
                         (find-deps rest deps))]
                    [(module-export? hd)
                     (find-deps
                       (cons (module-export-context hd) rest)
                       deps)]
                    [(import-set? hd)
                     (cond
                       [(fxzero? (import-set-phi hd))
                        (find-deps
                          (cons (import-set-source hd) rest)
                          deps)]
                       [(fxpositive? (import-set-phi hd))
                        (let ([xdeps (import-set-template hd 0)])
                          (find-deps
                            (let ([#{f dpuuv4a3mobea70icwo8nvdax-3182} cons])
                              (fold-left
                                (lambda (#{a dpuuv4a3mobea70icwo8nvdax-3183}
                                         #{e dpuuv4a3mobea70icwo8nvdax-3184})
                                  (#{f dpuuv4a3mobea70icwo8nvdax-3182}
                                    #{e dpuuv4a3mobea70icwo8nvdax-3184}
                                    #{a dpuuv4a3mobea70icwo8nvdax-3183}))
                                rest
                                xdeps))
                            deps))]
                       [else (find-deps rest deps)])]
                    [else
                     (error 'gerbil "Unexpected module import" hd)])))))
          (begin deps))))
  (reverse
    (filter
      expander-context-id
      (find-deps
        (cond
          [(core-context-prelude ctx) =>
           (lambda (pre) (cons pre (module-context-import ctx)))]
          [else (module-context-import ctx)])
        (list)))))

(define (find-static-module-file ctx)
  (let* ([context-id (if (module-context? ctx)
                         (expander-context-id ctx)
                         (string->symbol ctx))])
    (let* ([scm (string-append
                  (static-module-name context-id)
                  ".scm")])
      (let* ([dirs (load-path)])
        (let* ([dirs (let ([user-libpath (getenv "GERBIL_PATH" #f)])
                       (if user-libpath
                           (let ([user-libpath (gambit-path-expand
                                                 "lib"
                                                 user-libpath)])
                             (if (member user-libpath dirs)
                                 dirs
                                 (cons user-libpath dirs)))
                           dirs))])
          (let* ([dirs (cond
                         [(current-compile-output-dir) =>
                          (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3185})
                            (cons
                              #{cut-arg dpuuv4a3mobea70icwo8nvdax-3185}
                              dirs))]
                         [else dirs])])
            (let* ([dirs (map (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3186})
                                (gambit-path-expand
                                  "static"
                                  #{cut-arg dpuuv4a3mobea70icwo8nvdax-3186}))
                              dirs)])
              (let lp ([rest dirs])
                (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3187} rest])
                  (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3187})
                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3188} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3187})]
                            [#{tl dpuuv4a3mobea70icwo8nvdax-3189} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3187})])
                        (let ([dir #{hd dpuuv4a3mobea70icwo8nvdax-3188}])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3189}])
                            (begin
                              (let ([path (gambit-path-expand scm dir)])
                                (if (file-exists? path)
                                    path
                                    (lp rest)))))))
                      (begin
                        (raise-compile-error
                          "cannot find static module"
                          (expander-context-id ctx)
                          scm))))))))))))

(define (file-empty? path)
  (zero? (file-info-size (gambit-file-info path #t))))

(define (compile-top-module ctx)
  (if (eq? (mutex-state \x2B;driver-mutex+) (current-thread))
      (parameterize ([current-expander-context ctx]
                     [current-expander-phi 0]
                     [current-expander-marks (list)]
                     [current-compile-symbol-table (make-symbol-table)]
                     [current-compile-runtime-sections
                      (make-hash-table-eq)]
                     [current-compile-runtime-names (make-hash-table)])
        (verbose "compile " (expander-context-id ctx))
        (when (current-compile-optimize) (optimize! ctx))
        (collect-bindings ctx)
        (compile-runtime-code ctx)
        (compile-meta-code ctx)
        (when (and (current-compile-optimize)
                   (current-compile-generate-ssxi))
          (compile-ssxi-code ctx)))
      (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3190} \x2B;driver-mutex+])
        (dynamic-wind
          (lambda ()
            (mutex-lock! #{mtx dpuuv4a3mobea70icwo8nvdax-3190}))
          (lambda ()
            (parameterize ([current-expander-context ctx]
                           [current-expander-phi 0]
                           [current-expander-marks (list)]
                           [current-compile-symbol-table
                            (make-symbol-table)]
                           [current-compile-runtime-sections
                            (make-hash-table-eq)]
                           [current-compile-runtime-names
                            (make-hash-table)])
              (verbose "compile " (expander-context-id ctx))
              (when (current-compile-optimize) (optimize! ctx))
              (collect-bindings ctx)
              (compile-runtime-code ctx)
              (compile-meta-code ctx)
              (when (and (current-compile-optimize)
                         (current-compile-generate-ssxi))
                (compile-ssxi-code ctx))))
          (lambda ()
            (mutex-unlock! #{mtx dpuuv4a3mobea70icwo8nvdax-3190}))))))

(define (collect-bindings ctx)
  (apply-collect-bindings (module-context-code ctx)))

(define (compile-runtime-code ctx)
  (define (compile1 ctx)
    (let* ([code (module-context-code ctx)])
      (let* ([rtm (let ([idstr (module-id->path-string
                                 (expander-context-id ctx))])
                    (string-append idstr "~0"))])
        (let* ([rtc? (apply-find-runtime-code code)])
          (when rtc?
            (hash-put! (current-compile-runtime-sections) ctx rtm))
          (generate-runtime-code ctx code (and rtc? rtm))))))
  (define (context-timestamp ctx)
    (string->symbol
      (string-append
        (symbol->string (expander-context-id ctx))
        "::timestamp")))
  (define (generate-runtime-code ctx code rtm)
    (let* ([runtime-code? (and rtm #t)])
      (let* ([lifts (box (list))])
        (let* ([runtime-code (and runtime-code?
                                  (parameterize ([current-expander-context
                                                  ctx]
                                                 [current-expander-phi 0]
                                                 [current-compile-lift
                                                  lifts]
                                                 [current-compile-marks
                                                  (make-hash-table-eq)]
                                                 [current-compile-identifiers
                                                  (make-bound-identifier-table)])
                                    (apply-generate-runtime code)))])
          (let* ([runtime-code (and runtime-code?
                                    (if (null? (unbox lifts))
                                        runtime-code
                                        (list
                                          'begin
                                          (reverse (unbox lifts))
                                          ...
                                          runtime-code)))])
            (let* ([runtime-code (and runtime-code?
                                      (list
                                        'begin
                                        `(define (unquote
                                                  (context-timestamp ctx))
                                           ,(current-compile-timestamp))
                                        runtime-code))])
              (let* ([loader-code (parameterize ([current-expander-context
                                                  ctx])
                                    (apply-generate-loader code))])
                (let* ([loader-code (list
                                      'begin
                                      loader-code
                                      (if runtime-code?
                                          (list 'load-module rtm)
                                          '(begin)))])
                  (let* ([scm0 (compile-output-file ctx 0 ".scm")])
                    (let* ([scmrt (compile-output-file ctx #f ".scm")])
                      (let* ([scms (compile-static-output-file ctx)])
                        (when runtime-code?
                          (compile-scm-file scm0 runtime-code))
                        (parameterize ([current-compile-gsc-options #f])
                          (compile-scm-file scmrt loader-code))
                        (when (file-exists? scms) (delete-file scms))
                        (if runtime-code?
                            (copy-file scm0 scms)
                            (call-with-output-file scms void)))))))))))))
  (let ([all-modules (cons ctx (lift-nested-modules ctx))])
    (for-each
      (lambda (ctx)
        (parameterize ([current-compile-decls (list)])
          (compile1 ctx)))
      all-modules)))

(define (compile-meta-code ctx)
  (define (compile-ssi code)
    (let* ([path (compile-output-file ctx #f ".ssi")])
      (let* ([prelude (let ([super (phi-context-super ctx)])
                        (cond
                          [(expander-context-id super) =>
                           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-3191})
                             (make-symbol
                               ":"
                               #{cut-arg dpuuv4a3mobea70icwo8nvdax-3191}))]
                          [else ':<root>]))])
        (let* ([ns (module-context-ns ctx)])
          (let* ([idstr (symbol->string (expander-context-id ctx))])
            (let* ([pkg (cond
                          [(string-rindex idstr #\/) =>
                           (lambda (x)
                             (string->symbol (substring idstr 0 x)))]
                          [else #f])])
              (let* ([rt (hash-get
                           (current-compile-runtime-sections)
                           ctx)])
                (verbose "compile " path)
                (with-output-to-scheme-file
                  path
                  (lambda ()
                    (begin
                      (display "prelude:")
                      (display " ")
                      (display prelude)
                      (newline))
                    (when pkg
                      (begin
                        (display "package:")
                        (display " ")
                        (display pkg)
                        (newline)))
                    (begin
                      (display "namespace:")
                      (display " ")
                      (display ns)
                      (newline))
                    (newline)
                    (pretty-print code)
                    (when rt
                      (pretty-print
                        (list
                          '%\x23;call
                          (list '%\x23;ref 'load-module)
                          (list '%\x23;quote rt)))))))))))))
  (define (compile-phi part)
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3192} part])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3192})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3193} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3192})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-3194} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3192})])
            (let ([phi-ctx #{hd dpuuv4a3mobea70icwo8nvdax-3193}])
              (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3194})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3195} (car #{tl dpuuv4a3mobea70icwo8nvdax-3194})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-3196} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3194})])
                    (let ([phi #{hd dpuuv4a3mobea70icwo8nvdax-3195}])
                      (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3196})
                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3197} (car #{tl dpuuv4a3mobea70icwo8nvdax-3196})]
                                [#{tl dpuuv4a3mobea70icwo8nvdax-3198} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3196})])
                            (let ([n #{hd dpuuv4a3mobea70icwo8nvdax-3197}])
                              (if (pair?
                                    #{tl dpuuv4a3mobea70icwo8nvdax-3198})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3199} (car #{tl dpuuv4a3mobea70icwo8nvdax-3198})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-3200} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3198})])
                                    (let ([code #{hd dpuuv4a3mobea70icwo8nvdax-3199}])
                                      (if (null?
                                            #{tl dpuuv4a3mobea70icwo8nvdax-3200})
                                          (begin
                                            (let ([code (parameterize ([current-expander-context
                                                                        phi-ctx]
                                                                       [current-expander-phi
                                                                        phi])
                                                          (generate-runtime-phi
                                                            code))])
                                              (compile-scm-file
                                                (compile-output-file
                                                  ctx
                                                  n
                                                  ".scm")
                                                code
                                                #t)))
                                          (error 'match
                                            "no matching clause"
                                            #{match-val dpuuv4a3mobea70icwo8nvdax-3192}))))
                                  (error 'match
                                    "no matching clause"
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-3192}))))
                          (error 'match
                            "no matching clause"
                            #{match-val dpuuv4a3mobea70icwo8nvdax-3192}))))
                  (error 'match
                    "no matching clause"
                    #{match-val dpuuv4a3mobea70icwo8nvdax-3192}))))
          (error 'match
            "no matching clause"
            #{match-val dpuuv4a3mobea70icwo8nvdax-3192}))))
  (let ([values ssi-code] [generate-meta-code ctx])
    (compile-ssi ssi-code)
    (for-each compile-phi phi-code)))

(define (compile-ssxi-code ctx)
  (let* ([path (compile-output-file ctx #f ".ssxi.ss")])
    (let* ([code (apply-generate-ssxi
                   (module-context-code ctx))])
      (let* ([idstr (symbol->string (expander-context-id ctx))])
        (let* ([pkg (cond
                      [(string-rindex idstr #\/) =>
                       (lambda (x) (string->symbol (substring idstr 0 x)))]
                      [else #f])])
          (verbose "compile " path)
          (with-output-to-scheme-file
            path
            (lambda ()
              (begin (display "prelude: :gerbil/compiler/ssxi") (newline))
              (when pkg
                (begin (display "package: ") (display pkg) (newline)))
              (newline)
              (pretty-print code))))))))

(define (generate-meta-code ctx)
  (let* ([state (make-meta-state ctx)])
    (let* ([ssi-code (apply-generate-meta
                       (module-context-code ctx)
                       'state:
                       state)])
      (values ssi-code (meta-state-end! state)))))

(define (generate-runtime-phi stx)
  (let ([lifts (box (list))])
    (parameterize ([current-compile-lift lifts]
                   [current-compile-marks (make-hash-table-eq)]
                   [current-compile-identifiers
                    (make-bound-identifier-table)])
      (let ([code (apply-generate-runtime-phi stx)])
        (if (null? (unbox lifts))
            code
            (list 'begin (reverse (unbox lifts)) ... code))))))

(define (lift-nested-modules ctx)
  (let ([modules (box (list))])
    (apply-lift-modules
      (module-context-code ctx)
      'modules:
      modules)
    (reverse (unbox modules))))

(define compile-scm-file
  (case-lambda
    [(path code)
     (let* ([phi? #f])
       (verbose "compile " path)
       (with-output-to-scheme-file
         path
         (lambda ()
           (pretty-print
             `(declare
                (block)
                (standard-bindings)
                (extended-bindings)
                ,@(if phi? '((inlining-limit 200)) '())))
           (pretty-print code)))
       (when (current-compile-invoke-gsc)
         (let ([compile-it (lambda () (gsc-compile-file path phi?))])
           (if (current-compile-parallel)
               (add-compile-job! compile-it `(compile-file ,path))
               (compile-it)))))]
    [(path code phi?)
     (verbose "compile " path)
     (with-output-to-scheme-file
       path
       (lambda ()
         (pretty-print
           `(declare
              (block)
              (standard-bindings)
              (extended-bindings)
              ,@(if phi? '((inlining-limit 200)) '())))
         (pretty-print code)))
     (when (current-compile-invoke-gsc)
       (let ([compile-it (lambda () (gsc-compile-file path phi?))])
         (if (current-compile-parallel)
             (add-compile-job! compile-it `(compile-file ,path))
             (compile-it))))]))

(define gsc-link-options
  (case-lambda
    [()
     (let* ([phi? #f])
       (let lp ([rest (current-compile-gsc-options)] [opts (list)])
         (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3201} rest])
           (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3202} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                     [#{tl dpuuv4a3mobea70icwo8nvdax-3203} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                 (if (equal?
                       #{hd dpuuv4a3mobea70icwo8nvdax-3202}
                       '"-cc-options")
                     (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3203})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3204} (car #{tl dpuuv4a3mobea70icwo8nvdax-3203})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-3205} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3203})])
                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3205}])
                             (begin (lp rest opts))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                                     '"-ld-options")
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                                           (begin (lp rest opts))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                                 (begin
                                                   (lp rest
                                                       (cons opt opts))))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-debug-source"
                                                   "-track-scheme"
                                                   (reverse opts))
                                                 (reverse opts)))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                             (begin
                                               (lp rest
                                                   (cons opt opts))))))
                                       (begin
                                         (if (current-compile-debug)
                                             (cons*
                                               "-debug-source"
                                               "-track-scheme"
                                               (reverse opts))
                                             (reverse opts))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                       (begin (lp rest (cons opt opts))))))
                                 (begin
                                   (if (current-compile-debug)
                                       (cons*
                                         "-debug-source"
                                         "-track-scheme"
                                         (reverse opts))
                                       (reverse opts))))))
                     (if (pair?
                           #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                           (if (equal?
                                 #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                                 '"-ld-options")
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                                       (begin (lp rest opts))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                             (begin
                                               (lp rest
                                                   (cons opt opts))))))
                                       (begin
                                         (if (current-compile-debug)
                                             (cons*
                                               "-debug-source"
                                               "-track-scheme"
                                               (reverse opts))
                                             (reverse opts)))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                     (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                         (begin
                                           (lp rest (cons opt opts))))))
                                   (begin
                                     (if (current-compile-debug)
                                         (cons*
                                           "-debug-source"
                                           "-track-scheme"
                                           (reverse opts))
                                         (reverse opts))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                   (begin (lp rest (cons opt opts))))))
                             (begin
                               (if (current-compile-debug)
                                   (cons*
                                     "-debug-source"
                                     "-track-scheme"
                                     (reverse opts))
                                   (reverse opts)))))))
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                     (if (equal?
                           #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                           '"-ld-options")
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                                 (begin (lp rest opts))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                       (begin (lp rest (cons opt opts))))))
                                 (begin
                                   (if (current-compile-debug)
                                       (cons*
                                         "-debug-source"
                                         "-track-scheme"
                                         (reverse opts))
                                       (reverse opts)))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                   (begin (lp rest (cons opt opts))))))
                             (begin
                               (if (current-compile-debug)
                                   (cons*
                                     "-debug-source"
                                     "-track-scheme"
                                     (reverse opts))
                                   (reverse opts))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                             (begin (lp rest (cons opt opts))))))
                       (begin
                         (if (current-compile-debug)
                             (cons*
                               "-debug-source"
                               "-track-scheme"
                               (reverse opts))
                             (reverse opts)))))))))]
    [(phi?)
     (let lp ([rest (current-compile-gsc-options)] [opts (list)])
       (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3201} rest])
         (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3202} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                   [#{tl dpuuv4a3mobea70icwo8nvdax-3203} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
               (if (equal?
                     #{hd dpuuv4a3mobea70icwo8nvdax-3202}
                     '"-cc-options")
                   (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3203})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3204} (car #{tl dpuuv4a3mobea70icwo8nvdax-3203})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3205} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3203})])
                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3205}])
                           (begin (lp rest opts))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                                   '"-ld-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                                         (begin (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                           (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                               (begin
                                                 (lp rest
                                                     (cons opt opts))))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-debug-source"
                                                 "-track-scheme"
                                                 (reverse opts))
                                               (reverse opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                       (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                           (begin
                                             (lp rest (cons opt opts))))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-debug-source"
                                             "-track-scheme"
                                             (reverse opts))
                                           (reverse opts))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                 (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                     (begin (lp rest (cons opt opts))))))
                               (begin
                                 (if (current-compile-debug)
                                     (cons*
                                       "-debug-source"
                                       "-track-scheme"
                                       (reverse opts))
                                     (reverse opts))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                         (if (equal?
                               #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                               '"-ld-options")
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                                     (begin (lp rest opts))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                       (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                           (begin
                                             (lp rest (cons opt opts))))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-debug-source"
                                             "-track-scheme"
                                             (reverse opts))
                                           (reverse opts)))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                       (begin (lp rest (cons opt opts))))))
                                 (begin
                                   (if (current-compile-debug)
                                       (cons*
                                         "-debug-source"
                                         "-track-scheme"
                                         (reverse opts))
                                       (reverse opts))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                 (begin (lp rest (cons opt opts))))))
                           (begin
                             (if (current-compile-debug)
                                 (cons*
                                   "-debug-source"
                                   "-track-scheme"
                                   (reverse opts))
                                 (reverse opts)))))))
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3206} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-3207} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                   (if (equal?
                         #{hd dpuuv4a3mobea70icwo8nvdax-3206}
                         '"-ld-options")
                       (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3207})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3208} (car #{tl dpuuv4a3mobea70icwo8nvdax-3207})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3209} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3207})])
                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3209}])
                               (begin (lp rest opts))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                                 (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                     (begin (lp rest (cons opt opts))))))
                               (begin
                                 (if (current-compile-debug)
                                     (cons*
                                       "-debug-source"
                                       "-track-scheme"
                                       (reverse opts))
                                     (reverse opts)))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                                 (begin (lp rest (cons opt opts))))))
                           (begin
                             (if (current-compile-debug)
                                 (cons*
                                   "-debug-source"
                                   "-track-scheme"
                                   (reverse opts))
                                 (reverse opts))))))
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3201})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3210} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3201})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3211} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3201})])
                       (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3210}])
                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3211}])
                           (begin (lp rest (cons opt opts))))))
                     (begin
                       (if (current-compile-debug)
                           (cons*
                             "-debug-source"
                             "-track-scheme"
                             (reverse opts))
                           (reverse opts))))))))]))

(define gsc-cc-options
  (case-lambda
    [()
     (let* ([phi? #f] [static? #f])
       (if phi?
           (if (current-compile-debug)
               (list "-cc-options" "-g")
               (list))
           (let lp ([rest (current-compile-gsc-options)] [opts (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3212} rest])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3213} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3214} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                     (if (equal?
                           #{hd dpuuv4a3mobea70icwo8nvdax-3213}
                           '"-cc-options")
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3214})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3215} (car #{tl dpuuv4a3mobea70icwo8nvdax-3214})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3216} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3214})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3215}])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3215}
                                       '"-Bstatic")
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3216}])
                                       (begin
                                         (if static?
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-cc-options"
                                                   opts))
                                             (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                                 '"-cc-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                                     (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                                         (begin
                                                           (lp rest
                                                               (cons*
                                                                 opt
                                                                 "-cc-options"
                                                                 opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (if (equal?
                                                               #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                               '"-ld-options")
                                                             (if (pair?
                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (if (pair?
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                         (begin
                                                                           (lp rest
                                                                               opts))))
                                                                     (begin
                                                                       (if (current-compile-debug)
                                                                           (cons*
                                                                             "-cc-options"
                                                                             "-g"
                                                                             (reverse!
                                                                               opts))
                                                                           (reverse!
                                                                             opts)))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (if (current-compile-debug)
                                                                       (cons*
                                                                         "-cc-options"
                                                                         "-g"
                                                                         (reverse!
                                                                           opts))
                                                                       (reverse!
                                                                         opts))))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts))))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (if (equal?
                                                           #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                           '"-ld-options")
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (if (current-compile-debug)
                                                                       (cons*
                                                                         "-cc-options"
                                                                         "-g"
                                                                         (reverse!
                                                                           opts))
                                                                       (reverse!
                                                                         opts)))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (if (current-compile-debug)
                                                                   (cons*
                                                                     "-cc-options"
                                                                     "-g"
                                                                     (reverse!
                                                                       opts))
                                                                   (reverse!
                                                                     opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts)))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                     '"-ld-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts)))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts))))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse!
                                                         opts)))))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                                 (begin
                                                   (lp rest
                                                       (cons*
                                                         opt
                                                         "-cc-options"
                                                         opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (if (equal?
                                                       #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                       '"-ld-options")
                                                     (if (pair?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (if (current-compile-debug)
                                                                   (cons*
                                                                     "-cc-options"
                                                                     "-g"
                                                                     (reverse!
                                                                       opts))
                                                                   (reverse!
                                                                     opts)))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts))))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                   '"-ld-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                             '"-ld-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts)))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                     '"-cc-options")
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                             (begin
                                               (lp rest
                                                   (cons*
                                                     opt
                                                     "-cc-options"
                                                     opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                   '"-ld-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                               '"-ld-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse! opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts)))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts))))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                         (if (equal?
                               #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                               '"-cc-options")
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                       (begin
                                         (lp rest
                                             (cons*
                                               opt
                                               "-cc-options"
                                               opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                             '"-ld-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts)))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                   '"-ld-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                         (begin (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                   (begin (lp rest opts))))
                               (begin
                                 (if (current-compile-debug)
                                     (cons*
                                       "-cc-options"
                                       "-g"
                                       (reverse! opts))
                                     (reverse! opts)))))))))))]
    [(phi?)
     (let* ([static? #f])
       (if phi?
           (if (current-compile-debug)
               (list "-cc-options" "-g")
               (list))
           (let lp ([rest (current-compile-gsc-options)] [opts (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3212} rest])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3213} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3214} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                     (if (equal?
                           #{hd dpuuv4a3mobea70icwo8nvdax-3213}
                           '"-cc-options")
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3214})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3215} (car #{tl dpuuv4a3mobea70icwo8nvdax-3214})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3216} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3214})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3215}])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3215}
                                       '"-Bstatic")
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3216}])
                                       (begin
                                         (if static?
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-cc-options"
                                                   opts))
                                             (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                                 '"-cc-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                                     (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                                         (begin
                                                           (lp rest
                                                               (cons*
                                                                 opt
                                                                 "-cc-options"
                                                                 opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (if (equal?
                                                               #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                               '"-ld-options")
                                                             (if (pair?
                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (if (pair?
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                         (begin
                                                                           (lp rest
                                                                               opts))))
                                                                     (begin
                                                                       (if (current-compile-debug)
                                                                           (cons*
                                                                             "-cc-options"
                                                                             "-g"
                                                                             (reverse!
                                                                               opts))
                                                                           (reverse!
                                                                             opts)))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (if (current-compile-debug)
                                                                       (cons*
                                                                         "-cc-options"
                                                                         "-g"
                                                                         (reverse!
                                                                           opts))
                                                                       (reverse!
                                                                         opts))))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts))))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (if (equal?
                                                           #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                           '"-ld-options")
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (if (current-compile-debug)
                                                                       (cons*
                                                                         "-cc-options"
                                                                         "-g"
                                                                         (reverse!
                                                                           opts))
                                                                       (reverse!
                                                                         opts)))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (if (current-compile-debug)
                                                                   (cons*
                                                                     "-cc-options"
                                                                     "-g"
                                                                     (reverse!
                                                                       opts))
                                                                   (reverse!
                                                                     opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts)))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                     '"-ld-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts)))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts))))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse!
                                                         opts)))))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                                 (begin
                                                   (lp rest
                                                       (cons*
                                                         opt
                                                         "-cc-options"
                                                         opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (if (equal?
                                                       #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                       '"-ld-options")
                                                     (if (pair?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (if (current-compile-debug)
                                                                   (cons*
                                                                     "-cc-options"
                                                                     "-g"
                                                                     (reverse!
                                                                       opts))
                                                                   (reverse!
                                                                     opts)))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts))))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                   '"-ld-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                             '"-ld-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts)))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                     '"-cc-options")
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                             (begin
                                               (lp rest
                                                   (cons*
                                                     opt
                                                     "-cc-options"
                                                     opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                   '"-ld-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                               '"-ld-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse! opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts)))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts))))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                         (if (equal?
                               #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                               '"-cc-options")
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                       (begin
                                         (lp rest
                                             (cons*
                                               opt
                                               "-cc-options"
                                               opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                             '"-ld-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                               (begin (lp rest opts))))
                                           (begin
                                             (if (current-compile-debug)
                                                 (cons*
                                                   "-cc-options"
                                                   "-g"
                                                   (reverse! opts))
                                                 (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts)))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                   '"-ld-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                         (begin (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                         (begin (lp rest opts))))
                                     (begin
                                       (if (current-compile-debug)
                                           (cons*
                                             "-cc-options"
                                             "-g"
                                             (reverse! opts))
                                           (reverse! opts))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                   (begin (lp rest opts))))
                               (begin
                                 (if (current-compile-debug)
                                     (cons*
                                       "-cc-options"
                                       "-g"
                                       (reverse! opts))
                                     (reverse! opts)))))))))))]
    [(phi? static?)
     (if phi?
         (if (current-compile-debug)
             (list "-cc-options" "-g")
             (list))
         (let lp ([rest (current-compile-gsc-options)] [opts (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3212} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3213} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-3214} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                   (if (equal?
                         #{hd dpuuv4a3mobea70icwo8nvdax-3213}
                         '"-cc-options")
                       (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3214})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3215} (car #{tl dpuuv4a3mobea70icwo8nvdax-3214})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3216} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3214})])
                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3215}])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3215}
                                     '"-Bstatic")
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3216}])
                                     (begin
                                       (if static?
                                           (lp rest
                                               (cons*
                                                 opt
                                                 "-cc-options"
                                                 opts))
                                           (lp rest opts))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                               '"-cc-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                                       (begin
                                                         (lp rest
                                                             (cons*
                                                               opt
                                                               "-cc-options"
                                                               opts))))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (if (equal?
                                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                             '"-ld-options")
                                                           (if (pair?
                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (if (pair?
                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                       (begin
                                                                         (lp rest
                                                                             opts))))
                                                                   (begin
                                                                     (if (current-compile-debug)
                                                                         (cons*
                                                                           "-cc-options"
                                                                           "-g"
                                                                           (reverse!
                                                                             opts))
                                                                         (reverse!
                                                                           opts)))))
                                                           (if (pair?
                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (begin
                                                                 (if (current-compile-debug)
                                                                     (cons*
                                                                       "-cc-options"
                                                                       "-g"
                                                                       (reverse!
                                                                         opts))
                                                                     (reverse!
                                                                       opts))))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts))))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (if (equal?
                                                         #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                         '"-ld-options")
                                                       (if (pair?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (if (pair?
                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (begin
                                                                 (if (current-compile-debug)
                                                                     (cons*
                                                                       "-cc-options"
                                                                       "-g"
                                                                       (reverse!
                                                                         opts))
                                                                     (reverse!
                                                                       opts)))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts))))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts)))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                   '"-ld-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (if (current-compile-debug)
                                                               (cons*
                                                                 "-cc-options"
                                                                 "-g"
                                                                 (reverse!
                                                                   opts))
                                                               (reverse!
                                                                 opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (if (current-compile-debug)
                                                           (cons*
                                                             "-cc-options"
                                                             "-g"
                                                             (reverse!
                                                               opts))
                                                           (reverse!
                                                             opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse!
                                                       opts)))))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                       '"-cc-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                           (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                               (begin
                                                 (lp rest
                                                     (cons*
                                                       opt
                                                       "-cc-options"
                                                       opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                     '"-ld-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (if (current-compile-debug)
                                                                 (cons*
                                                                   "-cc-options"
                                                                   "-g"
                                                                   (reverse!
                                                                     opts))
                                                                 (reverse!
                                                                   opts)))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts))))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                 '"-ld-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts)))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                     (if (equal?
                                           #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                           '"-ld-options")
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                 (begin (lp rest opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse! opts)))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts))))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                           (begin (lp rest opts))))
                                       (begin
                                         (if (current-compile-debug)
                                             (cons*
                                               "-cc-options"
                                               "-g"
                                               (reverse! opts))
                                             (reverse! opts)))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                                   '"-cc-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                       (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                           (begin
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-cc-options"
                                                   opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                                 '"-ld-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (if (current-compile-debug)
                                                             (cons*
                                                               "-cc-options"
                                                               "-g"
                                                               (reverse!
                                                                 opts))
                                                             (reverse!
                                                               opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                             '"-ld-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (if (current-compile-debug)
                                                         (cons*
                                                           "-cc-options"
                                                           "-g"
                                                           (reverse! opts))
                                                         (reverse!
                                                           opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (if (current-compile-debug)
                                                     (cons*
                                                       "-cc-options"
                                                       "-g"
                                                       (reverse! opts))
                                                     (reverse! opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts)))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                       '"-ld-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                             (begin (lp rest opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                       (begin (lp rest opts))))
                                   (begin
                                     (if (current-compile-debug)
                                         (cons*
                                           "-cc-options"
                                           "-g"
                                           (reverse! opts))
                                         (reverse! opts))))))))
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3217} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3218} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                       (if (equal?
                             #{hd dpuuv4a3mobea70icwo8nvdax-3217}
                             '"-cc-options")
                           (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3218})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3219} (car #{tl dpuuv4a3mobea70icwo8nvdax-3218})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3220} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3218})])
                                 (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3219}])
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3220}])
                                     (begin
                                       (lp rest
                                           (cons*
                                             opt
                                             "-cc-options"
                                             opts))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                     (if (equal?
                                           #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                           '"-ld-options")
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                                 (begin (lp rest opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (if (current-compile-debug)
                                                       (cons*
                                                         "-cc-options"
                                                         "-g"
                                                         (reverse! opts))
                                                       (reverse! opts)))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts))))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                           (begin (lp rest opts))))
                                       (begin
                                         (if (current-compile-debug)
                                             (cons*
                                               "-cc-options"
                                               "-g"
                                               (reverse! opts))
                                             (reverse! opts))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                       '"-ld-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                             (begin (lp rest opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                                 (begin (lp rest opts))))
                                             (begin
                                               (if (current-compile-debug)
                                                   (cons*
                                                     "-cc-options"
                                                     "-g"
                                                     (reverse! opts))
                                                   (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                             (begin (lp rest opts))))
                                         (begin
                                           (if (current-compile-debug)
                                               (cons*
                                                 "-cc-options"
                                                 "-g"
                                                 (reverse! opts))
                                               (reverse! opts))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                       (begin (lp rest opts))))
                                   (begin
                                     (if (current-compile-debug)
                                         (cons*
                                           "-cc-options"
                                           "-g"
                                           (reverse! opts))
                                         (reverse! opts)))))))
                     (if (pair?
                           #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3221} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-3222} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                           (if (equal?
                                 #{hd dpuuv4a3mobea70icwo8nvdax-3221}
                                 '"-ld-options")
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-3222})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3223} (car #{tl dpuuv4a3mobea70icwo8nvdax-3222})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3224} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3222})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3224}])
                                       (begin (lp rest opts))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                           (begin (lp rest opts))))
                                       (begin
                                         (if (current-compile-debug)
                                             (cons*
                                               "-cc-options"
                                               "-g"
                                               (reverse! opts))
                                             (reverse! opts)))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                       (begin (lp rest opts))))
                                   (begin
                                     (if (current-compile-debug)
                                         (cons*
                                           "-cc-options"
                                           "-g"
                                           (reverse! opts))
                                         (reverse! opts))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3212})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3225} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3212})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3226} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3212})])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3226}])
                                 (begin (lp rest opts))))
                             (begin
                               (if (current-compile-debug)
                                   (cons*
                                     "-cc-options"
                                     "-g"
                                     (reverse! opts))
                                   (reverse! opts))))))))))]))

(define gsc-ld-options
  (case-lambda
    [()
     (let* ([phi? #f] [static? #f])
       (if phi?
           (list)
           (let lp ([rest (current-compile-gsc-options)] [opts (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3227} rest])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3228} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3229} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                     (if (equal?
                           #{hd dpuuv4a3mobea70icwo8nvdax-3228}
                           '"-ld-options")
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3229})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3230} (car #{tl dpuuv4a3mobea70icwo8nvdax-3229})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3231} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3229})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3230}])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3230}
                                       '"-static")
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3231}])
                                       (begin
                                         (if static?
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-ld-options"
                                                   opts))
                                             (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                                 '"-ld-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                                     (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                                         (begin
                                                           (lp rest
                                                               (cons*
                                                                 opt
                                                                 "-ld-options"
                                                                 opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (if (equal?
                                                               #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                               '"-cc-options")
                                                             (if (pair?
                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (if (pair?
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                         (begin
                                                                           (lp rest
                                                                               opts))))
                                                                     (begin
                                                                       (reverse!
                                                                         opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (reverse!
                                                                     opts)))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (if (equal?
                                                           #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                           '"-cc-options")
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (reverse!
                                                                     opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (reverse!
                                                                 opts)))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse!
                                                           opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                     '"-cc-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse!
                                                           opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (reverse! opts))))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                                 (begin
                                                   (lp rest
                                                       (cons*
                                                         opt
                                                         "-ld-options"
                                                         opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (if (equal?
                                                       #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                       '"-cc-options")
                                                     (if (pair?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (reverse!
                                                                 opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                   '"-cc-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                             '"-cc-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                     '"-ld-options")
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                             (begin
                                               (lp rest
                                                   (cons*
                                                     opt
                                                     "-ld-options"
                                                     opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                   '"-cc-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                               '"-cc-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts)))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                         (if (equal?
                               #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                               '"-ld-options")
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                       (begin
                                         (lp rest
                                             (cons*
                                               opt
                                               "-ld-options"
                                               opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                             '"-cc-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts)))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                   '"-cc-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                         (begin (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts)))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                   (begin (lp rest opts))))
                               (begin (reverse! opts))))))))))]
    [(phi?)
     (let* ([static? #f])
       (if phi?
           (list)
           (let lp ([rest (current-compile-gsc-options)] [opts (list)])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3227} rest])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3228} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3229} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                     (if (equal?
                           #{hd dpuuv4a3mobea70icwo8nvdax-3228}
                           '"-ld-options")
                         (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3229})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3230} (car #{tl dpuuv4a3mobea70icwo8nvdax-3229})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3231} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3229})])
                               (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3230}])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3230}
                                       '"-static")
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3231}])
                                       (begin
                                         (if static?
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-ld-options"
                                                   opts))
                                             (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                                 '"-ld-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                                     (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                                         (begin
                                                           (lp rest
                                                               (cons*
                                                                 opt
                                                                 "-ld-options"
                                                                 opts))))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (if (equal?
                                                               #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                               '"-cc-options")
                                                             (if (pair?
                                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (if (pair?
                                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                         (begin
                                                                           (lp rest
                                                                               opts))))
                                                                     (begin
                                                                       (reverse!
                                                                         opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (reverse!
                                                                     opts)))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (if (equal?
                                                           #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                           '"-cc-options")
                                                         (if (pair?
                                                               #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (if (pair?
                                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                     (begin
                                                                       (lp rest
                                                                           opts))))
                                                                 (begin
                                                                   (reverse!
                                                                     opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (reverse!
                                                                 opts)))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse!
                                                           opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                     '"-cc-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse!
                                                           opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin
                                                   (reverse! opts))))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                         '"-ld-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                                 (begin
                                                   (lp rest
                                                       (cons*
                                                         opt
                                                         "-ld-options"
                                                         opts))))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (if (equal?
                                                       #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                       '"-cc-options")
                                                     (if (pair?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (if (pair?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                 (begin
                                                                   (lp rest
                                                                       opts))))
                                                             (begin
                                                               (reverse!
                                                                 opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts)))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                   '"-cc-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                             '"-cc-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts))))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                     '"-ld-options")
                                   (if (pair?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                         (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                             (begin
                                               (lp rest
                                                   (cons*
                                                     opt
                                                     "-ld-options"
                                                     opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                   '"-cc-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                               '"-cc-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin (reverse! opts)))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts))))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts)))))))
                   (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                             [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                         (if (equal?
                               #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                               '"-ld-options")
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                       (begin
                                         (lp rest
                                             (cons*
                                               opt
                                               "-ld-options"
                                               opts))))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                             '"-cc-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts)))))
                             (if (pair?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                   (if (equal?
                                         #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                         '"-cc-options")
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                               (begin (lp rest opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                               (begin (lp rest opts))))
                                           (begin (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                   '"-cc-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                         (begin (lp rest opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                         (begin (lp rest opts))))
                                     (begin (reverse! opts)))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                   (begin (lp rest opts))))
                               (begin (reverse! opts))))))))))]
    [(phi? static?)
     (if phi?
         (list)
         (let lp ([rest (current-compile-gsc-options)] [opts (list)])
           (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3227} rest])
             (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3228} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                       [#{tl dpuuv4a3mobea70icwo8nvdax-3229} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                   (if (equal?
                         #{hd dpuuv4a3mobea70icwo8nvdax-3228}
                         '"-ld-options")
                       (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3229})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3230} (car #{tl dpuuv4a3mobea70icwo8nvdax-3229})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3231} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3229})])
                             (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3230}])
                               (if (equal?
                                     #{hd dpuuv4a3mobea70icwo8nvdax-3230}
                                     '"-static")
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3231}])
                                     (begin
                                       (if static?
                                           (lp rest
                                               (cons*
                                                 opt
                                                 "-ld-options"
                                                 opts))
                                           (lp rest opts))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (if (equal?
                                               #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                               '"-ld-options")
                                             (if (pair?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                                   (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                                       (begin
                                                         (lp rest
                                                             (cons*
                                                               opt
                                                               "-ld-options"
                                                               opts))))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (if (equal?
                                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                             '"-cc-options")
                                                           (if (pair?
                                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (if (pair?
                                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                       (begin
                                                                         (lp rest
                                                                             opts))))
                                                                   (begin
                                                                     (reverse!
                                                                       opts))))
                                                           (if (pair?
                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (begin
                                                                 (reverse!
                                                                   opts)))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (if (equal?
                                                         #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                         '"-cc-options")
                                                       (if (pair?
                                                             #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (if (pair?
                                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                                   (begin
                                                                     (lp rest
                                                                         opts))))
                                                               (begin
                                                                 (reverse!
                                                                   opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts)))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts))))))
                                       (if (pair?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                             (if (equal?
                                                   #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                   '"-cc-options")
                                                 (if (pair?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (if (pair?
                                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                             (begin
                                                               (lp rest
                                                                   opts))))
                                                         (begin
                                                           (reverse!
                                                             opts))))
                                                 (if (pair?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                       (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                         (begin
                                                           (lp rest
                                                               opts))))
                                                     (begin
                                                       (reverse! opts)))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin
                                                 (reverse! opts))))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                       '"-ld-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                           (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                               (begin
                                                 (lp rest
                                                     (cons*
                                                       opt
                                                       "-ld-options"
                                                       opts))))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (if (equal?
                                                     #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                     '"-cc-options")
                                                   (if (pair?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (if (pair?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                             (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                               (begin
                                                                 (lp rest
                                                                     opts))))
                                                           (begin
                                                             (reverse!
                                                               opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse!
                                                           opts)))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                 '"-cc-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse! opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts)))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                     (if (equal?
                                           #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                           '"-cc-options")
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                 (begin (lp rest opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin (reverse! opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts)))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                           (begin (lp rest opts))))
                                       (begin (reverse! opts))))))
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                             (if (equal?
                                   #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                                   '"-ld-options")
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                       (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                           (begin
                                             (lp rest
                                                 (cons*
                                                   opt
                                                   "-ld-options"
                                                   opts))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (if (equal?
                                                 #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                                 '"-cc-options")
                                               (if (pair?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (if (pair?
                                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                           (begin
                                                             (lp rest
                                                                 opts))))
                                                       (begin
                                                         (reverse! opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts)))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts)))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                       (if (equal?
                                             #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                             '"-cc-options")
                                           (if (pair?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                   (begin (lp rest opts))))
                                               (if (pair?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                       (begin
                                                         (lp rest opts))))
                                                   (begin
                                                     (reverse! opts))))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                 (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                   (begin (lp rest opts))))
                                               (begin (reverse! opts)))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts))))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                       '"-cc-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                             (begin (lp rest opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts)))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                       (begin (lp rest opts))))
                                   (begin (reverse! opts)))))))
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3232} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3233} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                       (if (equal?
                             #{hd dpuuv4a3mobea70icwo8nvdax-3232}
                             '"-ld-options")
                           (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3233})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3234} (car #{tl dpuuv4a3mobea70icwo8nvdax-3233})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3235} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3233})])
                                 (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3234}])
                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3235}])
                                     (begin
                                       (lp rest
                                           (cons*
                                             opt
                                             "-ld-options"
                                             opts))))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                     (if (equal?
                                           #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                           '"-cc-options")
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                                 (begin (lp rest opts))))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                                   (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                     (begin
                                                       (lp rest opts))))
                                                 (begin (reverse! opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts)))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                           (begin (lp rest opts))))
                                       (begin (reverse! opts)))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                 (if (equal?
                                       #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                       '"-cc-options")
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                             (begin (lp rest opts))))
                                         (if (pair?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                                 (begin (lp rest opts))))
                                             (begin (reverse! opts))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                           (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                             (begin (lp rest opts))))
                                         (begin (reverse! opts)))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                       (begin (lp rest opts))))
                                   (begin (reverse! opts))))))
                     (if (pair?
                           #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3236} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-3237} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                           (if (equal?
                                 #{hd dpuuv4a3mobea70icwo8nvdax-3236}
                                 '"-cc-options")
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-3237})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3238} (car #{tl dpuuv4a3mobea70icwo8nvdax-3237})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3239} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3237})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3239}])
                                       (begin (lp rest opts))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                           (begin (lp rest opts))))
                                       (begin (reverse! opts))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                                     (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                       (begin (lp rest opts))))
                                   (begin (reverse! opts)))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-3227})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3240} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3227})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-3241} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3227})])
                               (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3241}])
                                 (begin (lp rest opts))))
                             (begin (reverse! opts)))))))))]))

(define (gsc-static-include-options staticdir)
  (let ([user-staticdir (gambit-path-expand
                          (gambit-path-expand
                            "lib/static"
                            (gerbil-path)))])
    (list
      "-cc-options"
      (string-append "-I " staticdir " -I " user-staticdir))))

(define (gcc-ld-options)
  (let lp ([rest (current-compile-gsc-options)] [opts (list)])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-3242} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3243} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-3244} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
            (if (equal?
                  #{hd dpuuv4a3mobea70icwo8nvdax-3243}
                  '"-cc-options")
                (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3244})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3245} (car #{tl dpuuv4a3mobea70icwo8nvdax-3244})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-3246} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3244})])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3246}])
                        (begin (lp rest opts))))
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3247} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-3248} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                          (if (equal?
                                #{hd dpuuv4a3mobea70icwo8nvdax-3247}
                                '"-ld-options")
                              (if (pair?
                                    #{tl dpuuv4a3mobea70icwo8nvdax-3248})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3249} (car #{tl dpuuv4a3mobea70icwo8nvdax-3248})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-3250} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3248})])
                                    (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3249}])
                                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3250}])
                                        (begin
                                          (lp rest
                                              (append
                                                opts
                                                (filter
                                                  not-string-empty?
                                                  (let ([#{str dpuuv4a3mobea70icwo8nvdax-3251} opt]
                                                        [#{sep dpuuv4a3mobea70icwo8nvdax-3252} (if (char?
                                                                                                     #\space)
                                                                                                   #\space
                                                                                                   (string-ref
                                                                                                     #\space
                                                                                                     0))])
                                                    (let split-lp ([i 0]
                                                                   [start 0]
                                                                   [acc '()])
                                                      (cond
                                                        [(= i
                                                            (string-length
                                                              #{str dpuuv4a3mobea70icwo8nvdax-3251}))
                                                         (reverse
                                                           (cons
                                                             (substring
                                                               #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                               start
                                                               i)
                                                             acc))]
                                                        [(char=?
                                                           (string-ref
                                                             #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                             i)
                                                           #{sep dpuuv4a3mobea70icwo8nvdax-3252})
                                                         (split-lp
                                                           (+ i 1)
                                                           (+ i 1)
                                                           (cons
                                                             (substring
                                                               #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                               start
                                                               i)
                                                             acc))]
                                                        [else
                                                         (split-lp
                                                           (+ i 1)
                                                           start
                                                           acc)]))))))))))
                                  (if (pair?
                                        #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                                      (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                            [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                                        (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                          (begin (lp rest opts))))
                                      (begin opts)))
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                      (begin (lp rest opts))))
                                  (begin opts))))
                        (if (pair?
                              #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                (begin (lp rest opts))))
                            (begin opts))))
                (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3247} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-3248} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                      (if (equal?
                            #{hd dpuuv4a3mobea70icwo8nvdax-3247}
                            '"-ld-options")
                          (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3248})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3249} (car #{tl dpuuv4a3mobea70icwo8nvdax-3248})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-3250} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3248})])
                                (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3249}])
                                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3250}])
                                    (begin
                                      (lp rest
                                          (append
                                            opts
                                            (filter
                                              not-string-empty?
                                              (let ([#{str dpuuv4a3mobea70icwo8nvdax-3251} opt]
                                                    [#{sep dpuuv4a3mobea70icwo8nvdax-3252} (if (char?
                                                                                                 #\space)
                                                                                               #\space
                                                                                               (string-ref
                                                                                                 #\space
                                                                                                 0))])
                                                (let split-lp ([i 0]
                                                               [start 0]
                                                               [acc '()])
                                                  (cond
                                                    [(= i
                                                        (string-length
                                                          #{str dpuuv4a3mobea70icwo8nvdax-3251}))
                                                     (reverse
                                                       (cons
                                                         (substring
                                                           #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                           start
                                                           i)
                                                         acc))]
                                                    [(char=?
                                                       (string-ref
                                                         #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                         i)
                                                       #{sep dpuuv4a3mobea70icwo8nvdax-3252})
                                                     (split-lp
                                                       (+ i 1)
                                                       (+ i 1)
                                                       (cons
                                                         (substring
                                                           #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                           start
                                                           i)
                                                         acc))]
                                                    [else
                                                     (split-lp
                                                       (+ i 1)
                                                       start
                                                       acc)]))))))))))
                              (if (pair?
                                    #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                        [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                      (begin (lp rest opts))))
                                  (begin opts)))
                          (if (pair?
                                #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                    [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                                (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                  (begin (lp rest opts))))
                              (begin opts))))
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                            (begin (lp rest opts))))
                        (begin opts)))))
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3247} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-3248} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                (if (equal?
                      #{hd dpuuv4a3mobea70icwo8nvdax-3247}
                      '"-ld-options")
                    (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-3248})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3249} (car #{tl dpuuv4a3mobea70icwo8nvdax-3248})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-3250} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-3248})])
                          (let ([opt #{hd dpuuv4a3mobea70icwo8nvdax-3249}])
                            (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3250}])
                              (begin
                                (lp rest
                                    (append
                                      opts
                                      (filter
                                        not-string-empty?
                                        (let ([#{str dpuuv4a3mobea70icwo8nvdax-3251} opt]
                                              [#{sep dpuuv4a3mobea70icwo8nvdax-3252} (if (char?
                                                                                           #\space)
                                                                                         #\space
                                                                                         (string-ref
                                                                                           #\space
                                                                                           0))])
                                          (let split-lp ([i 0]
                                                         [start 0]
                                                         [acc '()])
                                            (cond
                                              [(= i
                                                  (string-length
                                                    #{str dpuuv4a3mobea70icwo8nvdax-3251}))
                                               (reverse
                                                 (cons
                                                   (substring
                                                     #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                     start
                                                     i)
                                                   acc))]
                                              [(char=?
                                                 (string-ref
                                                   #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                   i)
                                                 #{sep dpuuv4a3mobea70icwo8nvdax-3252})
                                               (split-lp
                                                 (+ i 1)
                                                 (+ i 1)
                                                 (cons
                                                   (substring
                                                     #{str dpuuv4a3mobea70icwo8nvdax-3251}
                                                     start
                                                     i)
                                                   acc))]
                                              [else
                                               (split-lp
                                                 (+ i 1)
                                                 start
                                                 acc)]))))))))))
                        (if (pair?
                              #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                                (begin (lp rest opts))))
                            (begin opts)))
                    (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                        (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                              [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                          (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                            (begin (lp rest opts))))
                        (begin opts))))
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-3242})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-3253} (car #{match-val dpuuv4a3mobea70icwo8nvdax-3242})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-3254} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-3242})])
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-3254}])
                      (begin (lp rest opts))))
                  (begin opts)))))))

(define (not-string-empty? str) (not (string-empty? str)))

(define (gsc-compile-file path phi?)
  (let ([gsc-link-opts (gsc-link-options phi?)]
        [gsc-cc-opts (gsc-cc-options phi?)]
        [gsc-ld-opts (gsc-ld-options phi?)])
    (invoke
      (gerbil-gsc)
      (list gsc-cc-opts ... gsc-ld-opts ... gsc-link-opts ...
        path))))

(define (compile-output-file ctx n ext)
  (define (module-relative-path ctx)
    (path-strip-directory
      (module-id->path-string (expander-context-id ctx))))
  (define (module-source-directory ctx)
    (path-directory
      (let ([mpath (module-context-path ctx)])
        (if (string? mpath) mpath (last mpath)))))
  (define (section-string n)
    (cond
      [(number? n) (number->string n)]
      [(symbol? n) (symbol->string n)]
      [(string? n) n]
      [else (raise-compile-error "Unexpected section" n)]))
  (define (file-name path)
    (if n
        (string-append path "~" (section-string n) ext)
        (string-append path ext)))
  (define (file-path)
    (cond
      [(current-compile-output-dir) =>
       (lambda (outdir)
         (gambit-path-expand
           (file-name
             (module-id->path-string (expander-context-id ctx)))
           outdir))]
      [else
       (gambit-path-expand
         (file-name (module-relative-path ctx))
         (module-source-directory ctx))]))
  (let ([path (file-path)])
    (if (eq? (mutex-state \x2B;driver-mutex+) (current-thread))
        (create-directory* (path-directory path))
        (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3255} \x2B;driver-mutex+])
          (dynamic-wind
            (lambda ()
              (mutex-lock! #{mtx dpuuv4a3mobea70icwo8nvdax-3255}))
            (lambda () (create-directory* (path-directory path)))
            (lambda ()
              (mutex-unlock! #{mtx dpuuv4a3mobea70icwo8nvdax-3255})))))
    path))

(define (compile-static-output-file ctx)
  (define (file-name id)
    (string-append (static-module-name id) ".scm"))
  (define (file-path)
    (let ([file (file-name (expander-context-id ctx))])
      (cond
        [(current-compile-output-dir) =>
         (lambda (outdir)
           (gambit-path-expand
             file
             (gambit-path-expand "static" outdir)))]
        [else (gambit-path-expand file "static")])))
  (let ([path (file-path)])
    (if (eq? (mutex-state \x2B;driver-mutex+) (current-thread))
        (create-directory* (path-directory path))
        (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-3256} \x2B;driver-mutex+])
          (dynamic-wind
            (lambda ()
              (mutex-lock! #{mtx dpuuv4a3mobea70icwo8nvdax-3256}))
            (lambda () (create-directory* (path-directory path)))
            (lambda ()
              (mutex-unlock! #{mtx dpuuv4a3mobea70icwo8nvdax-3256})))))
    path))

(define (compile-exe-output-file ctx opts)
  (cond
    [(pgetq 'output-file: opts)]
    [else
     (path-strip-directory
       (symbol->string (expander-context-id ctx)))]))

(define (static-module-name idstr)
  (cond
    [(string? idstr)
     (let* ([str (module-id->path-string idstr)])
       (let* ([strs (let ([#{str dpuuv4a3mobea70icwo8nvdax-3257} str]
                          [#{sep dpuuv4a3mobea70icwo8nvdax-3258} (if (char?
                                                                       #\/)
                                                                     #\/
                                                                     (string-ref
                                                                       #\/
                                                                       0))])
                      (let split-lp ([i 0] [start 0] [acc '()])
                        (cond
                          [(= i
                              (string-length
                                #{str dpuuv4a3mobea70icwo8nvdax-3257}))
                           (reverse
                             (cons
                               (substring
                                 #{str dpuuv4a3mobea70icwo8nvdax-3257}
                                 start
                                 i)
                               acc))]
                          [(char=?
                             (string-ref
                               #{str dpuuv4a3mobea70icwo8nvdax-3257}
                               i)
                             #{sep dpuuv4a3mobea70icwo8nvdax-3258})
                           (split-lp
                             (+ i 1)
                             (+ i 1)
                             (cons
                               (substring
                                 #{str dpuuv4a3mobea70icwo8nvdax-3257}
                                 start
                                 i)
                               acc))]
                          [else (split-lp (+ i 1) start acc)])))])
         (let ([#{strs dpuuv4a3mobea70icwo8nvdax-3259} strs]
               [#{sep dpuuv4a3mobea70icwo8nvdax-3260} "__"])
           (if (null? #{strs dpuuv4a3mobea70icwo8nvdax-3259})
               ""
               (let lp ([#{result dpuuv4a3mobea70icwo8nvdax-3261} (car #{strs dpuuv4a3mobea70icwo8nvdax-3259})]
                        [rest (cdr #{strs dpuuv4a3mobea70icwo8nvdax-3259})])
                 (if (null? rest)
                     #{result dpuuv4a3mobea70icwo8nvdax-3261}
                     (lp (string-append
                           #{result dpuuv4a3mobea70icwo8nvdax-3261}
                           #{sep dpuuv4a3mobea70icwo8nvdax-3260}
                           (car rest))
                         (cdr rest))))))))]
    [(symbol? idstr)
     (static-module-name (symbol->string idstr))]
    [else (error 'gerbil "Bad module id" idstr)]))

(define (gerbil-enable-shared?)
  (member
    "--enable-shared"
    (let ([#{str dpuuv4a3mobea70icwo8nvdax-3262} (configure-command-string)]
          [#{sep dpuuv4a3mobea70icwo8nvdax-3263} (if (char? #\')
                                                     #\'
                                                     (string-ref #\' 0))])
      (let split-lp ([i 0] [start 0] [acc '()])
        (cond
          [(= i (string-length #{str dpuuv4a3mobea70icwo8nvdax-3262}))
           (reverse
             (cons
               (substring #{str dpuuv4a3mobea70icwo8nvdax-3262} start i)
               acc))]
          [(char=?
             (string-ref #{str dpuuv4a3mobea70icwo8nvdax-3262} i)
             #{sep dpuuv4a3mobea70icwo8nvdax-3263})
           (split-lp
             (+ i 1)
             (+ i 1)
             (cons
               (substring #{str dpuuv4a3mobea70icwo8nvdax-3262} start i)
               acc))]
          [else (split-lp (+ i 1) start acc)])))))

(define invoke
  (case-lambda
    [(program args)
     (let* ([stdout-redirection #f] [stderr-redirection #f])
       (verbose "invoke " (cons* program args))
       (let* ([proc (open-process
                      (list 'path: program 'arguments: args
                        'stdout-redirection: stdout-redirection
                        'stderr-redirection: stderr-redirection))])
         (let* ([output (and (or stdout-redirection
                                 stderr-redirection)
                             (get-line proc))])
           (let ([status (process-status proc)])
             (close-port proc)
             (unless (zero? status)
               (display output)
               (raise-compile-error
                 "Compilation error; process exit with nonzero status"
                 (cons* program args)
                 status))))))]
    [(program args stdout-redirection)
     (let* ([stderr-redirection #f])
       (verbose "invoke " (cons* program args))
       (let* ([proc (open-process
                      (list 'path: program 'arguments: args
                        'stdout-redirection: stdout-redirection
                        'stderr-redirection: stderr-redirection))])
         (let* ([output (and (or stdout-redirection
                                 stderr-redirection)
                             (get-line proc))])
           (let ([status (process-status proc)])
             (close-port proc)
             (unless (zero? status)
               (display output)
               (raise-compile-error
                 "Compilation error; process exit with nonzero status"
                 (cons* program args)
                 status))))))]
    [(program args stdout-redirection stderr-redirection)
     (verbose "invoke " (cons* program args))
     (let* ([proc (open-process
                    (list 'path: program 'arguments: args 'stdout-redirection:
                      stdout-redirection 'stderr-redirection:
                      stderr-redirection))])
       (let* ([output (and (or stdout-redirection
                               stderr-redirection)
                           (get-line proc))])
         (let ([status (process-status proc)])
           (close-port proc)
           (unless (zero? status)
             (display output)
             (raise-compile-error
               "Compilation error; process exit with nonzero status"
               (cons* program args)
               status)))))]))

