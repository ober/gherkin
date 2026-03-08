(define (spawn f . args) (spawn-actor f args (%%void) #f))

(define (spawn/name name f . args)
  (spawn-actor f args name #f))

(define (spawn/group name f . args)
  (let ([tgroup (make-thread-group name)])
    (spawn-actor f args name tgroup)))

(define (spawn-actor f args name tgroup)
  (define (thread-main thunk)
    (lambda ()
      (with-exception-handler
        (lambda (exn)
          (\x23;\x23;continuation-capture
            (lambda (cont)
              (when unhandled-actor-exception-hook
                (guard (__exn [#t (void __exn)])
                  ((lambda ()
                     (__unhandled-actor-exception-hook cont exn)))))
              (\x23;\x23;continuation-graft
                (\x23;\x23;continuation-last cont)
                \x23;\x23;primordial-exception-handler
                exn))))
        thunk)))
  (let* ([thunk (if (null? args)
                    f
                    (lambda () (apply f args)))])
    (let* ([thunk (lambda ()
                    (with-exception-stack-trace thunk))])
      (let* ([tgroup (or tgroup (current-thread-group))])
        (thread-start!
          (thread-init!
            (construct-actor-thread #f 0)
            (thread-main thunk)
            name
            tgroup))))))

(define spawn-thread
  (case-lambda
    [(thunk)
     (let* ([name absent-obj] [tgroup absent-obj])
       (thread-start! (make-thread thunk name tgroup)))]
    [(thunk name)
     (let* ([tgroup absent-obj])
       (thread-start! (make-thread thunk name tgroup)))]
    [(thunk name tgroup)
     (thread-start! (make-thread thunk name tgroup))]))

(define thread-local-ref
  (case-lambda
    [(key)
     (let* ([default absent-obj])
       (let ([tab (thread-local-table)])
         (hash-ref tab key default)))]
    [(key default)
     (let ([tab (thread-local-table)])
       (hash-ref tab key default))]))

(define (thread-local-get key) (thread-local-ref key #f))

(define (thread-local-set! key value)
  (let ([tab (thread-local-table)])
    (hash-put! tab key value)))

(define (thread-local-delete! key)
  (let ([tab (thread-local-table)]) (hash-remove! tab key)))

(define (thread-local-table)
  (let ([thr (current-thread)])
    (cond
      [(actor-thread? thr)
       (cond
         [(actor-thread-locals thr)]
         [else
          (let ([tab (make-hash-table-eq)])
            (actor-thread-locals-set! thr tab)
            tab)])]
      [(eq? thr \x23;\x23;primordial-thread)
       __primordial-thread-locals]
      [else
       (mutex-lock! __thread-locals-mutex)
       (cond
         [(hash-get __thread-locals thr) =>
          (lambda (tab) (mutex-unlock! __thread-locals-mutex) tab)]
         [else
          (let ([tab (make-hash-table-eq)])
            (hash-put! __thread-locals thr tab)
            (mutex-unlock! __thread-locals-mutex)
            tab)])])))

(define __primordial-thread-locals (make-hash-table-eq))

(define __thread-locals (make-hash-table-eq #t))

(define __thread-locals-mutex (make-mutex 'thread-locals))

(begin
  (define __unhandled-actor-exception-hook #f)
  (define (unhandled-actor-exception-hook)
    __unhandled-actor-exception-hook)
  (define (unhandled-actor-exception-hook-set! v)
    (set! __unhandled-actor-exception-hook v)))

(define (current-thread-group)
  (thread-thread-group (current-thread)))

(begin
  (define (with-lock mx proc)
    (let ([handler (current-exception-handler)])
      (with-exception-handler
        (lambda (e)
          (guard (__exn [#t (void __exn)])
            (mutex-unlock! mx)
            (handler e))
          (\x23;\x23;thread-end-with-uncaught-exception! e))
        (lambda ()
          (mutex-lock! mx)
          (let ([result (proc)]) (mutex-unlock! mx) result)))))
  (define __with-lock with-lock))

(begin
  (define (with-dynamic-lock mx proc)
    (dynamic-wind
      (lambda () (mutex-lock! mx))
      proc
      (lambda () (mutex-unlock! mx))))
  (define __with-dynamic-lock with-dynamic-lock))

(begin
  (define with-exception-stack-trace
    (case-lambda
      [(thunk)
       (let* ([error-port (current-error-port)])
         (with-exception-handler
           (let ([E (current-exception-handler)])
             (lambda (exn)
               (continuation-capture
                 (lambda (cont)
                   (when (dump-stack-trace?)
                     (dump-stack-trace! cont exn error-port))
                   (E exn)))))
           thunk))]
      [(thunk error-port)
       (with-exception-handler
         (let ([E (current-exception-handler)])
           (lambda (exn)
             (continuation-capture
               (lambda (cont)
                 (when (dump-stack-trace?)
                   (dump-stack-trace! cont exn error-port))
                 (E exn)))))
         thunk)]))
  (define __with-exception-stack-trace
    with-exception-stack-trace))

(define dump-stack-trace!
  (case-lambda
    [(cont exn)
     (let* ([error-port (current-error-port)])
       (let ([out (open-output-string)])
         (fix-port-width! out)
         (display "*** Unhandled exception in " out)
         (display (current-thread) out)
         (newline out)
         (display-exception exn out)
         (unless (StackTrace? exn)
           (display "Continuation backtrace: " out)
           (newline out)
           (display-continuation-backtrace cont out))
         (\x23;\x23;write-string
           (get-output-string out)
           error-port)))]
    [(cont exn error-port)
     (let ([out (open-output-string)])
       (fix-port-width! out)
       (display "*** Unhandled exception in " out)
       (display (current-thread) out)
       (newline out)
       (display-exception exn out)
       (unless (StackTrace? exn)
         (display "Continuation backtrace: " out)
         (newline out)
         (display-continuation-backtrace cont out))
       (\x23;\x23;write-string
         (get-output-string out)
         error-port))]))

(begin
  (define-type-of-thread actor-thread 'constructor: construct-actor-thread 'id:
    gerbil\x23;actor::t locals nonce))

