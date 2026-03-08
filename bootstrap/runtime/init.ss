(define __scheme-source (make-parameter #f))

(define (__load-gxi)
  (letrec* ([\x2B;readtable+ __*readtable*])
    (__current-compiler __compile-top)
    (__current-expander gx\x23;core-expand)
    (set! __eval-module gx\x23;core-eval-module)
    (let* ([core (gx\x23;import-module ':gerbil/core)])
      (let* ([pre (gx\x23;make-prelude-context core)])
        (gx\x23;current-expander-module-prelude pre)
        (gx\x23;core-bind-root-syntax! ':<core> pre #t)
        (gx\x23;eval-syntax '(import :gerbil/core))))
    (gx\x23;current-expander-compile __compile-top-source)
    (\x23;\x23;expand-source-set! __expand-source)
    (\x23;\x23;macro-descr-set! __macro-descr)
    (\x23;\x23;main-readtable-set! __*readtable*)
    (for-each
      (lambda (port)
        (input-port-readtable-set! port \x2B;readtable+))
      (list \x23;\x23;stdin-port \x23;\x23;console-port))
    (for-each
      (lambda (port)
        (output-port-readtable-set!
          port
          (readtable-sharing-allowed?-set
            (output-port-readtable port)
            #t)))
      (list \x23;\x23;stdout-port \x23;\x23;console-port))))

(define (__gxi-init-interactive! cmdline) (void))

(define (load-scheme path)
  (parameterize ([__scheme-source path])
    (\x23;\x23;load path (lambda args #f) #t #t #f)))

(define (__expand-source src)
  (define (expand src)
    (__compile-top (gx\x23;core-expand (__source->syntax src))))
  (define (no-expand src)
    (cond
      [(__scheme-source) src]
      [(\x23;\x23;source? src)
       (let ([code (\x23;\x23;source-code src)])
         (and (pair? code)
              (eq? '__noexpand: (\x23;\x23;car code))
              (\x23;\x23;cdr code)))]
      [else #f]))
  (cond [(no-expand src)] [else (expand src)]))

(define (__macro-descr src def-syntax?)
  (define (fail!)
    (\x23;\x23;raise-expression-parsing-exception
      'ill-formed-macro-transformer
      src))
  (define (make-descr size)
    (let ([expander (parameterize ([__scheme-source 'macro])
                      (\x23;\x23;eval-top src \x23;\x23;interaction-cte))])
      (if (procedure? expander)
          (\x23;\x23;make-macro-descr def-syntax? size expander src)
          (fail!))))
  (if def-syntax?
      (make-descr -1)
      (let ([code (\x23;\x23;source-code src)])
        (if (and (\x23;\x23;pair? code)
                 (\x23;\x23;memq
                   (\x23;\x23;source-code
                     (\x23;\x23;sourcify (\x23;\x23;car code) src))
                   '(\x23;\x23;lambda lambda)))
            (begin
              (\x23;\x23;shape src src -3)
              (make-descr
                (\x23;\x23;form-size
                  (\x23;\x23;sourcify (\x23;\x23;cadr code) src))))
            (fail!)))))

(define (__source->syntax src)
  (let recur ([e src])
    (cond
      [(\x23;\x23;source? e)
       (make-AST
         (recur (\x23;\x23;source-code e))
         (\x23;\x23;source-locat e))]
      [(pair? e)
       (cons (recur (\x23;\x23;car e)) (recur (\x23;\x23;cdr e)))]
      [(vector? e) (vector-map recur e)]
      [(box? e) (box (recur (unbox e)))]
      [else e])))

(define (__compile-top-source stx)
  (cons '__noexpand: (__compile-top stx)))

(define (__compile-top stx)
  (__compile (gx\x23;core-compile-top-syntax stx)))

(define __modstate (make-hash-table-eq))

(define __modstate-mx (make-mutex 'import))

(define __modstate-cv (make-condition-variable 'import))

(define (__eval-import in)
  (define (import1 in phi)
    (cond
      [(gx\x23;module-import? in)
       (let ([iphi (fx+ phi (gx\x23;module-import-phi in))])
         (when (fxzero? iphi)
           (eval1
             (gx\x23;module-export-context
               (gx\x23;module-import-source in)))))]
      [(gx\x23;module-context? in)
       (when (fxzero? phi) (eval1 in))]
      [(gx\x23;import-set? in)
       (let ([iphi (fx+ phi (gx\x23;import-set-phi in))])
         (cond
           [(fxzero? iphi) (eval1 (gx\x23;import-set-source in))]
           [(fxpositive? iphi)
            (for-each
              (lambda (in) (import1 in iphi))
              (gx\x23;module-context-import
                (gx\x23;import-set-source in)))]))]
      [else (error 'gerbil "Unexpected import" in)]))
  (define (eval1 ctx)
    (mutex-lock! __modstate-mx)
    (cond
      [(hash-get __modstate ctx) =>
       (lambda (state)
         (case (car state)
           [(forcing)
            (mutex-unlock! __modstate-mx __modstate-cv)
            (eval1 ctx)]
           [(ready) (mutex-unlock! __modstate-mx) (cadr state)]
           [(error) (mutex-unlock! __modstate-mx) (raise (cadr state))]
           [else
            (mutex-unlock! __modstate-mx)
            (error 'gerbil
              "internal error; unexpected module state"
              state)]))]
      [else
       (hash-put! __modstate ctx '(forcing))
       (mutex-unlock! __modstate-mx)
       (guard (__exn
                [#t
                 ((lambda (exn)
                    (mutex-lock! __modstate-mx)
                    (hash-put! __modstate ctx `(error ,exn))
                    (condition-variable-broadcast! __modstate-cv)
                    (mutex-unlock! __modstate-mx)
                    (raise exn))
                   __exn)])
         (let ([result (__eval-module ctx)])
           (mutex-lock! __modstate-mx)
           (hash-put! __modstate ctx `(ready ,result))
           (condition-variable-broadcast! __modstate-cv)
           (mutex-unlock! __modstate-mx)
           result))]))
  (if (pair? in)
      (for-each (lambda (in) (import1 in 0)) in)
      (import1 in 0)))

(define (__eval-module obj) (gx\x23;core-eval-module obj))

(define (__interrupt-handler)
  (when (getenv "GERBIL_DEBUG" #f)
    (newline (current-error-port))
    (display "--- continuation backtrace:" (current-error-port))
    (newline (current-error-port))
    (let ([stack-trace-head (or (string->number
                                  (getenv "GERBIL_DEBUG_STACKTRACE" "10"))
                                10)])
      (continuation-capture
        (lambda (cont)
          (display-continuation-backtrace cont (current-error-port) 1
            1 0 stack-trace-head)))))
  (\x23;\x23;default-user-interrupt-handler))

(define (gerbil-runtime-init! builtin-modules)
  (unless __runtime-initialized
    (dump-stack-trace? #t)
    (let* ([home (gerbil-home)])
      (let* ([libdir (gambit-path-expand "lib" home)])
        (let* ([userpath (gambit-path-expand "lib" (gerbil-path))])
          (let* ([loadpath (if (getenv "GERBIL_BUILD_PREFIX" #f)
                               (list libdir)
                               (list userpath libdir))])
            (let* ([loadpath (cond
                               [(getenv "GERBIL_LOADPATH" #f) =>
                                (lambda (envvar)
                                  (append
                                    (filter
                                      (lambda (x) (not (string-empty? x)))
                                      (let ([#{str dpuuv4a3mobea70icwo8nvdax-419} envvar]
                                            [#{sep dpuuv4a3mobea70icwo8nvdax-420} (if (char?
                                                                                        #\:)
                                                                                      #\:
                                                                                      (string-ref
                                                                                        #\:
                                                                                        0))])
                                        (let split-lp ([i 0]
                                                       [start 0]
                                                       [acc '()])
                                          (cond
                                            [(= i
                                                (string-length
                                                  #{str dpuuv4a3mobea70icwo8nvdax-419}))
                                             (reverse
                                               (cons
                                                 (substring
                                                   #{str dpuuv4a3mobea70icwo8nvdax-419}
                                                   start
                                                   i)
                                                 acc))]
                                            [(char=?
                                               (string-ref
                                                 #{str dpuuv4a3mobea70icwo8nvdax-419}
                                                 i)
                                               #{sep dpuuv4a3mobea70icwo8nvdax-420})
                                             (split-lp
                                               (+ i 1)
                                               (+ i 1)
                                               (cons
                                                 (substring
                                                   #{str dpuuv4a3mobea70icwo8nvdax-419}
                                                   start
                                                   i)
                                                 acc))]
                                            [else
                                             (split-lp
                                               (+ i 1)
                                               start
                                               acc)]))))
                                    loadpath))]
                               [else loadpath])])
              (set-load-path! loadpath))))))
    (for-each
      (lambda (mod)
        (hash-put! __modules mod 'builtin)
        (hash-put! __modules (string-append mod "~0") 'builtin))
      builtin-modules)
    (current-user-interrupt-handler __interrupt-handler)
    (current-readtable __*readtable*)
    (random-source-randomize! default-random-source)
    (set! __runtime-initialized #t)))

(define __expander-loaded #f)

(define __runtime-initialized #f)

(define (gerbil-load-expander!)
  (unless __runtime-initialized
    (error 'gerbil "runtime has not been initialized"))
  (unless __expander-loaded
    (__load-gxi)
    (set! __expander-loaded #t)))

