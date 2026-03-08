(begin
  (define Exception::t
    (make-class-type 'gerbil\x23;Exception::t 'Exception
      (list object::t) '() '() '#f))
  (define (Exception . args) (apply make-Exception args))
  (define (Exception? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;Exception::t))
  (define (make-Exception . args)
    (apply make-instance Exception::t args)))

(begin
  (define StackTrace::t
    (make-class-type 'gerbil\x23;StackTrace::t 'StackTrace
      (list object::t) '(continuation) '() '#f))
  (define (StackTrace . args) (apply make-StackTrace args))
  (define (StackTrace? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;StackTrace::t))
  (define (make-StackTrace . args)
    (apply make-instance StackTrace::t args))
  (define (&StackTrace-continuation-set! obj val)
    (unchecked-slot-set! obj 'continuation val))
  (define (&StackTrace-continuation obj)
    (unchecked-slot-ref obj 'continuation))
  (define (StackTrace-continuation-set! obj val)
    (unchecked-slot-set! obj 'continuation val))
  (define (StackTrace-continuation obj)
    (unchecked-slot-ref obj 'continuation)))

(begin
  (define Error::t
    (make-class-type 'gerbil\x23;Error::t 'Error
      (list StackTrace::t Exception::t) '(message irritants where)
      '((constructor: . :init!) (transparent: . #t)) '#f))
  (define (Error . args) (apply make-Error args))
  (define (Error? obj)
    (\x23;\x23;structure-instance-of? obj 'gerbil\x23;Error::t))
  (define (make-Error . args)
    (apply make-instance Error::t args))
  (define (&Error-message-set! obj val)
    (unchecked-slot-set! obj 'message val))
  (define (&Error-message obj)
    (unchecked-slot-ref obj 'message))
  (define (Error-message-set! obj val)
    (unchecked-slot-set! obj 'message val))
  (define (Error-message obj)
    (unchecked-slot-ref obj 'message))
  (define (&Error-irritants-set! obj val)
    (unchecked-slot-set! obj 'irritants val))
  (define (&Error-irritants obj)
    (unchecked-slot-ref obj 'irritants))
  (define (Error-irritants-set! obj val)
    (unchecked-slot-set! obj 'irritants val))
  (define (Error-irritants obj)
    (unchecked-slot-ref obj 'irritants))
  (define (&Error-where-set! obj val)
    (unchecked-slot-set! obj 'where val))
  (define (&Error-where obj) (unchecked-slot-ref obj 'where))
  (define (Error-where-set! obj val)
    (unchecked-slot-set! obj 'where val))
  (define (Error-where obj) (unchecked-slot-ref obj 'where)))

(begin
  (define ContractViolation::t
    (make-class-type 'gerbil\x23;ContractViolation::t
      'ContractViolation (list Error::t) '() '() '#f))
  (define (ContractViolation . args)
    (apply make-ContractViolation args))
  (define (ContractViolation? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;ContractViolation::t))
  (define (make-ContractViolation . args)
    (apply make-instance ContractViolation::t args)))

(begin
  (define RuntimeException::t
    (make-class-type 'gerbil\x23;RuntimeException::t 'RuntimeException
      (list StackTrace::t Exception::t) '(exception)
      '((transparent: . #t)) '#f))
  (define (RuntimeException . args)
    (apply make-RuntimeException args))
  (define (RuntimeException? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;RuntimeException::t))
  (define (make-RuntimeException . args)
    (apply make-instance RuntimeException::t args))
  (define (&RuntimeException-exception-set! obj val)
    (unchecked-slot-set! obj 'exception val))
  (define (&RuntimeException-exception obj)
    (unchecked-slot-ref obj 'exception))
  (define (RuntimeException-exception-set! obj val)
    (unchecked-slot-set! obj 'exception val))
  (define (RuntimeException-exception obj)
    (unchecked-slot-ref obj 'exception)))

(define (gerbil-exception-handler-hook exn continue)
  (let ([exn (wrap-runtime-exception exn)])
    (\x23;\x23;repl-exception-handler-hook exn continue)))

(\x23;\x23;primordial-exception-handler-hook-set!
  gerbil-exception-handler-hook)

(define (raise exn)
  (when (StackTrace? exn)
    (unless (&StackTrace-continuation exn)
      (\x23;\x23;continuation-capture
        (lambda (cont)
          (unchecked-slot-set! exn 'continuation cont)))))
  (\x23;\x23;raise exn))

(define (error message . irritants)
  (raise (Error message 'irritants: irritants)))

(define __raise-contract-violation-error
  (case-lambda
    [(message)
     (let* ([ctx #f] [contract-expr #f] [value #f])
       (raise
         (ContractViolation message 'where: ctx 'irritants:
           (list 'contract: contract-expr 'value: value))))]
    [(message ctx)
     (let* ([contract-expr #f] [value #f])
       (raise
         (ContractViolation message 'where: ctx 'irritants:
           (list 'contract: contract-expr 'value: value))))]
    [(message ctx contract-expr)
     (let* ([value #f])
       (raise
         (ContractViolation message 'where: ctx 'irritants:
           (list 'contract: contract-expr 'value: value))))]
    [(message ctx contract-expr value)
     (raise
       (ContractViolation message 'where: ctx 'irritants:
         (list 'contract: contract-expr 'value: value)))]))

(set! raise-contract-violation-error
  __raise-contract-violation-error)

(define contract-violation-error? ContractViolation?)

(begin
  (define (with-exception-handler handler thunk)
    (\x23;\x23;with-exception-handler
      (lambda (exn)
        (let ([exn (wrap-runtime-exception exn)]) (handler exn)))
      thunk))
  (define __with-exception-handler with-exception-handler))

(begin
  (define (with-catch handler thunk)
    (\x23;\x23;continuation-capture
      (lambda (cont)
        (with-exception-handler
          (lambda (exn)
            (\x23;\x23;continuation-graft cont handler exn))
          thunk))))
  (define __with-catch with-catch))

(define with-exception-catcher with-catch)

(define (wrap-runtime-exception exn)
  (cond
    [(or (heap-overflow-exception? exn)
         (stack-overflow-exception? exn))
     exn]
    [(Exception? exn) exn]
    [(macro-exception? exn)
     (let ([rte (RuntimeException 'exception: exn)])
       (\x23;\x23;continuation-capture
         (lambda (cont)
           (unchecked-slot-set!
             rte
             'continuation
             (\x23;\x23;continuation-next cont))))
       rte)]
    [else exn]))

(define exception? Exception?)

(define error? Error?)

(define (error-object? obj)
  (or (Error? obj) (error-exception? obj)))

(define (error-message obj)
  (cond
    [(slot-ref obj 'message false)]
    [(error-exception? obj) (error-exception-message obj)]
    [else #f]))

(define (error-irritants obj)
  (cond
    [(Error? obj) (&Error-irritants obj)]
    [(error-exception? obj) (error-exception-parameters obj)]
    [else #f]))

(define (error-trace obj)
  (and (Error? obj) (&Error-where obj)))

(define display-exception
  (case-lambda
    [(e)
     (let* ([port (current-error-port)])
       (cond
         [(method-ref e 'display-exception) =>
          (lambda (f) (f e port))]
         [else (\x23;\x23;default-display-exception e port)]))]
    [(e port)
     (cond
       [(method-ref e 'display-exception) =>
        (lambda (f) (f e port))]
       [else (\x23;\x23;default-display-exception e port)])]))

(\x23;\x23;display-exception-hook-set! display-exception)

(begin
  (define Error:::init!
    (lambda (self message . rest)
      (let ([message (if (string? message)
                         message
                         (call-with-output-string
                           ""
                           (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-105})
                             (display
                               message
                               #{cut-arg dpuuv4a3mobea70icwo8nvdax-105}))))])
        (slot-set! self 'message message)
        (apply class-instance-init! self rest))))
  (bind-method! Error::t ':init! Error:::init!))

(begin
  (define ContractViolation:::init! Error:::init!)
  (bind-method!
    ContractViolation::t
    ':init!
    ContractViolation:::init!))

(define dump-stack-trace? (make-parameter #f))

(begin
  (define Error::display-exception
    (lambda (self port)
      (let ([tmp-port (open-output-string)]
            [display-error-newline (> (output-port-column port) 0)])
        (fix-port-width! tmp-port)
        (parameterize ([current-output-port tmp-port])
          (when display-error-newline (newline))
          (display "*** ERROR IN ")
          (cond
            [(slot-ref self 'where) => display]
            [else (display "?")])
          (display*
            " ["
            (\x23;\x23;type-name (object-type self))
            "]: ")
          (begin (display (slot-ref self 'message)) (newline))
          (let ([irritants (slot-ref self 'irritants)])
            (unless (null? irritants)
              (display "--- irritants: ")
              (for-each
                (lambda (obj)
                  (if (u8vector? obj)
                      (write (list '<u8vector> (u8vector-length obj)))
                      (write obj))
                  (write-char #\space))
                irritants)
              (newline)))
          (when (dump-stack-trace?)
            (let ([cont (slot-ref self 'continuation)])
              (and cont
                   (begin
                     (begin
                       (display "--- continuation backtrace:")
                       (newline))
                     (display-continuation-backtrace cont))))))
        (\x23;\x23;write-string
          (get-output-string tmp-port)
          port))))
  (bind-method!
    Error::t
    'display-exception
    Error::display-exception))

(begin
  (define RuntimeException::display-exception
    (lambda (self port)
      (let ([tmp-port (open-output-string)])
        (fix-port-width! tmp-port)
        (\x23;\x23;default-display-exception
          (slot-ref self 'exception)
          tmp-port)
        (when (dump-stack-trace?)
          (let ([cont (slot-ref self 'continuation)])
            (and cont
                 (begin
                   (display "--- continuation backtrace:" tmp-port)
                   (newline tmp-port)
                   (display-continuation-backtrace cont tmp-port)))))
        (\x23;\x23;write-string
          (get-output-string tmp-port)
          port))))
  (bind-method!
    RuntimeException::t
    'display-exception
    RuntimeException::display-exception))

(define (fix-port-width! port)
  (when (macro-character-port? port)
    (let ([old-width (macro-character-port-output-width port)])
      (macro-character-port-output-width-set!
        port
        (lambda (port) 256))
      old-width)))

(define (reset-port-width! port old-width)
  (when (macro-character-port? port)
    (macro-character-port-output-width-set! port old-width)))

(define (datum-parsing-exception-filepos e)
  (macro-readenv-filepos (datum-parsing-exception-readenv e)))

(define-syntax defruntime-exception
  (lambda (stx)
    (syntax-case stx ()
      [(_ (is? getf ...))
       (with-syntax ([macro-is? (stx-identifier
                                  #'is?
                                  "macro-"
                                  #'is?)]
                     [(macro-getf ...) (map (lambda (f)
                                              (stx-identifier
                                                f
                                                "macro-"
                                                f))
                                            #'(getf ...))])
         #'(begin
             (extern macro-is? macro-getf ...)
             (def (is? exn)
                  (if (RuntimeException? exn)
                      (let (e [&RuntimeException-exception exn])
                        (macro-is? e))
                      (macro-is? exn)))
             (def (getf exn)
                  (if (RuntimeException? exn)
                      (let (e [&RuntimeException-exception exn])
                        (if (macro-is? e)
                            (macro-getf e)
                            (error "not an instance"
                              'is?
                              (\x40;list 'getf e))))
                      (if (macro-is? exn)
                          (macro-getf exn)
                          (error "not an instance"
                            'is?
                            (\x40;list 'getf exn)))))
             ...))])))

(define-syntax defruntime-exceptions
  (syntax-rules ()
    [(_ defexn ...) (begin (defruntime-exception defexn) ...)]))

(begin
  (begin
    (define (abandoned-mutex-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-abandoned-mutex-exception? e))
          (macro-abandoned-mutex-exception? exn))))
  (begin
    (define (cfun-conversion-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-cfun-conversion-exception? e))
          (macro-cfun-conversion-exception? exn)))
    (define (cfun-conversion-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-cfun-conversion-exception? e)
                (macro-cfun-conversion-exception-arguments e)
                (error "not an instance"
                  'cfun-conversion-exception?
                  (list 'cfun-conversion-exception-arguments e))))
          (if (macro-cfun-conversion-exception? exn)
              (macro-cfun-conversion-exception-arguments exn)
              (error "not an instance"
                'cfun-conversion-exception?
                (list 'cfun-conversion-exception-arguments exn)))))
    (define (cfun-conversion-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-cfun-conversion-exception? e)
                (macro-cfun-conversion-exception-code e)
                (error "not an instance"
                  'cfun-conversion-exception?
                  (list 'cfun-conversion-exception-code e))))
          (if (macro-cfun-conversion-exception? exn)
              (macro-cfun-conversion-exception-code exn)
              (error "not an instance"
                'cfun-conversion-exception?
                (list 'cfun-conversion-exception-code exn)))))
    (define (cfun-conversion-exception-message exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-cfun-conversion-exception? e)
                (macro-cfun-conversion-exception-message e)
                (error "not an instance"
                  'cfun-conversion-exception?
                  (list 'cfun-conversion-exception-message e))))
          (if (macro-cfun-conversion-exception? exn)
              (macro-cfun-conversion-exception-message exn)
              (error "not an instance"
                'cfun-conversion-exception?
                (list 'cfun-conversion-exception-message exn)))))
    (define (cfun-conversion-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-cfun-conversion-exception? e)
                (macro-cfun-conversion-exception-procedure e)
                (error "not an instance"
                  'cfun-conversion-exception?
                  (list 'cfun-conversion-exception-procedure e))))
          (if (macro-cfun-conversion-exception? exn)
              (macro-cfun-conversion-exception-procedure exn)
              (error "not an instance"
                'cfun-conversion-exception?
                (list 'cfun-conversion-exception-procedure exn))))))
  (begin
    (define (datum-parsing-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-datum-parsing-exception? e))
          (macro-datum-parsing-exception? exn)))
    (define (datum-parsing-exception-kind exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-datum-parsing-exception? e)
                (macro-datum-parsing-exception-kind e)
                (error "not an instance"
                  'datum-parsing-exception?
                  (list 'datum-parsing-exception-kind e))))
          (if (macro-datum-parsing-exception? exn)
              (macro-datum-parsing-exception-kind exn)
              (error "not an instance"
                'datum-parsing-exception?
                (list 'datum-parsing-exception-kind exn)))))
    (define (datum-parsing-exception-parameters exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-datum-parsing-exception? e)
                (macro-datum-parsing-exception-parameters e)
                (error "not an instance"
                  'datum-parsing-exception?
                  (list 'datum-parsing-exception-parameters e))))
          (if (macro-datum-parsing-exception? exn)
              (macro-datum-parsing-exception-parameters exn)
              (error "not an instance"
                'datum-parsing-exception?
                (list 'datum-parsing-exception-parameters exn)))))
    (define (datum-parsing-exception-readenv exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-datum-parsing-exception? e)
                (macro-datum-parsing-exception-readenv e)
                (error "not an instance"
                  'datum-parsing-exception?
                  (list 'datum-parsing-exception-readenv e))))
          (if (macro-datum-parsing-exception? exn)
              (macro-datum-parsing-exception-readenv exn)
              (error "not an instance"
                'datum-parsing-exception?
                (list 'datum-parsing-exception-readenv exn))))))
  (begin
    (define (deadlock-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-deadlock-exception? e))
          (macro-deadlock-exception? exn))))
  (begin
    (define (divide-by-zero-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-divide-by-zero-exception? e))
          (macro-divide-by-zero-exception? exn)))
    (define (divide-by-zero-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-divide-by-zero-exception? e)
                (macro-divide-by-zero-exception-arguments e)
                (error "not an instance"
                  'divide-by-zero-exception?
                  (list 'divide-by-zero-exception-arguments e))))
          (if (macro-divide-by-zero-exception? exn)
              (macro-divide-by-zero-exception-arguments exn)
              (error "not an instance"
                'divide-by-zero-exception?
                (list 'divide-by-zero-exception-arguments exn)))))
    (define (divide-by-zero-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-divide-by-zero-exception? e)
                (macro-divide-by-zero-exception-procedure e)
                (error "not an instance"
                  'divide-by-zero-exception?
                  (list 'divide-by-zero-exception-procedure e))))
          (if (macro-divide-by-zero-exception? exn)
              (macro-divide-by-zero-exception-procedure exn)
              (error "not an instance"
                'divide-by-zero-exception?
                (list 'divide-by-zero-exception-procedure exn))))))
  (begin
    (define (error-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-error-exception? e))
          (macro-error-exception? exn)))
    (define (error-exception-message exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-error-exception? e)
                (macro-error-exception-message e)
                (error "not an instance"
                  'error-exception?
                  (list 'error-exception-message e))))
          (if (macro-error-exception? exn)
              (macro-error-exception-message exn)
              (error "not an instance"
                'error-exception?
                (list 'error-exception-message exn)))))
    (define (error-exception-parameters exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-error-exception? e)
                (macro-error-exception-parameters e)
                (error "not an instance"
                  'error-exception?
                  (list 'error-exception-parameters e))))
          (if (macro-error-exception? exn)
              (macro-error-exception-parameters exn)
              (error "not an instance"
                'error-exception?
                (list 'error-exception-parameters exn))))))
  (begin
    (define (expression-parsing-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-expression-parsing-exception? e))
          (macro-expression-parsing-exception? exn)))
    (define (expression-parsing-exception-kind exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-expression-parsing-exception? e)
                (macro-expression-parsing-exception-kind e)
                (error "not an instance"
                  'expression-parsing-exception?
                  (list 'expression-parsing-exception-kind e))))
          (if (macro-expression-parsing-exception? exn)
              (macro-expression-parsing-exception-kind exn)
              (error "not an instance"
                'expression-parsing-exception?
                (list 'expression-parsing-exception-kind exn)))))
    (define (expression-parsing-exception-parameters exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-expression-parsing-exception? e)
                (macro-expression-parsing-exception-parameters e)
                (error "not an instance"
                  'expression-parsing-exception?
                  (list 'expression-parsing-exception-parameters e))))
          (if (macro-expression-parsing-exception? exn)
              (macro-expression-parsing-exception-parameters exn)
              (error "not an instance"
                'expression-parsing-exception?
                (list 'expression-parsing-exception-parameters exn)))))
    (define (expression-parsing-exception-source exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-expression-parsing-exception? e)
                (macro-expression-parsing-exception-source e)
                (error "not an instance"
                  'expression-parsing-exception?
                  (list 'expression-parsing-exception-source e))))
          (if (macro-expression-parsing-exception? exn)
              (macro-expression-parsing-exception-source exn)
              (error "not an instance"
                'expression-parsing-exception?
                (list 'expression-parsing-exception-source exn))))))
  (begin
    (define (file-exists-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-file-exists-exception? e))
          (macro-file-exists-exception? exn)))
    (define (file-exists-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-file-exists-exception? e)
                (macro-file-exists-exception-arguments e)
                (error "not an instance"
                  'file-exists-exception?
                  (list 'file-exists-exception-arguments e))))
          (if (macro-file-exists-exception? exn)
              (macro-file-exists-exception-arguments exn)
              (error "not an instance"
                'file-exists-exception?
                (list 'file-exists-exception-arguments exn)))))
    (define (file-exists-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-file-exists-exception? e)
                (macro-file-exists-exception-procedure e)
                (error "not an instance"
                  'file-exists-exception?
                  (list 'file-exists-exception-procedure e))))
          (if (macro-file-exists-exception? exn)
              (macro-file-exists-exception-procedure exn)
              (error "not an instance"
                'file-exists-exception?
                (list 'file-exists-exception-procedure exn))))))
  (begin
    (define (fixnum-overflow-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-fixnum-overflow-exception? e))
          (macro-fixnum-overflow-exception? exn)))
    (define (fixnum-overflow-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-fixnum-overflow-exception? e)
                (macro-fixnum-overflow-exception-arguments e)
                (error "not an instance"
                  'fixnum-overflow-exception?
                  (list 'fixnum-overflow-exception-arguments e))))
          (if (macro-fixnum-overflow-exception? exn)
              (macro-fixnum-overflow-exception-arguments exn)
              (error "not an instance"
                'fixnum-overflow-exception?
                (list 'fixnum-overflow-exception-arguments exn)))))
    (define (fixnum-overflow-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-fixnum-overflow-exception? e)
                (macro-fixnum-overflow-exception-procedure e)
                (error "not an instance"
                  'fixnum-overflow-exception?
                  (list 'fixnum-overflow-exception-procedure e))))
          (if (macro-fixnum-overflow-exception? exn)
              (macro-fixnum-overflow-exception-procedure exn)
              (error "not an instance"
                'fixnum-overflow-exception?
                (list 'fixnum-overflow-exception-procedure exn))))))
  (begin
    (define (heap-overflow-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-heap-overflow-exception? e))
          (macro-heap-overflow-exception? exn))))
  (begin
    (define (inactive-thread-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-inactive-thread-exception? e))
          (macro-inactive-thread-exception? exn)))
    (define (inactive-thread-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-inactive-thread-exception? e)
                (macro-inactive-thread-exception-arguments e)
                (error "not an instance"
                  'inactive-thread-exception?
                  (list 'inactive-thread-exception-arguments e))))
          (if (macro-inactive-thread-exception? exn)
              (macro-inactive-thread-exception-arguments exn)
              (error "not an instance"
                'inactive-thread-exception?
                (list 'inactive-thread-exception-arguments exn)))))
    (define (inactive-thread-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-inactive-thread-exception? e)
                (macro-inactive-thread-exception-procedure e)
                (error "not an instance"
                  'inactive-thread-exception?
                  (list 'inactive-thread-exception-procedure e))))
          (if (macro-inactive-thread-exception? exn)
              (macro-inactive-thread-exception-procedure exn)
              (error "not an instance"
                'inactive-thread-exception?
                (list 'inactive-thread-exception-procedure exn))))))
  (begin
    (define (initialized-thread-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-initialized-thread-exception? e))
          (macro-initialized-thread-exception? exn)))
    (define (initialized-thread-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-initialized-thread-exception? e)
                (macro-initialized-thread-exception-arguments e)
                (error "not an instance"
                  'initialized-thread-exception?
                  (list 'initialized-thread-exception-arguments e))))
          (if (macro-initialized-thread-exception? exn)
              (macro-initialized-thread-exception-arguments exn)
              (error "not an instance"
                'initialized-thread-exception?
                (list 'initialized-thread-exception-arguments exn)))))
    (define (initialized-thread-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-initialized-thread-exception? e)
                (macro-initialized-thread-exception-procedure e)
                (error "not an instance"
                  'initialized-thread-exception?
                  (list 'initialized-thread-exception-procedure e))))
          (if (macro-initialized-thread-exception? exn)
              (macro-initialized-thread-exception-procedure exn)
              (error "not an instance"
                'initialized-thread-exception?
                (list 'initialized-thread-exception-procedure exn))))))
  (begin
    (define (invalid-hash-number-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-invalid-hash-number-exception? e))
          (macro-invalid-hash-number-exception? exn)))
    (define (invalid-hash-number-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-invalid-hash-number-exception? e)
                (macro-invalid-hash-number-exception-arguments e)
                (error "not an instance"
                  'invalid-hash-number-exception?
                  (list 'invalid-hash-number-exception-arguments e))))
          (if (macro-invalid-hash-number-exception? exn)
              (macro-invalid-hash-number-exception-arguments exn)
              (error "not an instance"
                'invalid-hash-number-exception?
                (list 'invalid-hash-number-exception-arguments exn)))))
    (define (invalid-hash-number-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-invalid-hash-number-exception? e)
                (macro-invalid-hash-number-exception-procedure e)
                (error "not an instance"
                  'invalid-hash-number-exception?
                  (list 'invalid-hash-number-exception-procedure e))))
          (if (macro-invalid-hash-number-exception? exn)
              (macro-invalid-hash-number-exception-procedure exn)
              (error "not an instance"
                'invalid-hash-number-exception?
                (list 'invalid-hash-number-exception-procedure exn))))))
  (begin
    (define (invalid-utf8-encoding-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-invalid-utf8-encoding-exception? e))
          (macro-invalid-utf8-encoding-exception? exn)))
    (define (invalid-utf8-encoding-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-invalid-utf8-encoding-exception? e)
                (macro-invalid-utf8-encoding-exception-arguments e)
                (error "not an instance"
                  'invalid-utf8-encoding-exception?
                  (list 'invalid-utf8-encoding-exception-arguments e))))
          (if (macro-invalid-utf8-encoding-exception? exn)
              (macro-invalid-utf8-encoding-exception-arguments exn)
              (error "not an instance"
                'invalid-utf8-encoding-exception?
                (list 'invalid-utf8-encoding-exception-arguments exn)))))
    (define (invalid-utf8-encoding-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-invalid-utf8-encoding-exception? e)
                (macro-invalid-utf8-encoding-exception-procedure e)
                (error "not an instance"
                  'invalid-utf8-encoding-exception?
                  (list 'invalid-utf8-encoding-exception-procedure e))))
          (if (macro-invalid-utf8-encoding-exception? exn)
              (macro-invalid-utf8-encoding-exception-procedure exn)
              (error "not an instance"
                'invalid-utf8-encoding-exception?
                (list 'invalid-utf8-encoding-exception-procedure exn))))))
  (begin
    (define (join-timeout-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-join-timeout-exception? e))
          (macro-join-timeout-exception? exn)))
    (define (join-timeout-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-join-timeout-exception? e)
                (macro-join-timeout-exception-arguments e)
                (error "not an instance"
                  'join-timeout-exception?
                  (list 'join-timeout-exception-arguments e))))
          (if (macro-join-timeout-exception? exn)
              (macro-join-timeout-exception-arguments exn)
              (error "not an instance"
                'join-timeout-exception?
                (list 'join-timeout-exception-arguments exn)))))
    (define (join-timeout-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-join-timeout-exception? e)
                (macro-join-timeout-exception-procedure e)
                (error "not an instance"
                  'join-timeout-exception?
                  (list 'join-timeout-exception-procedure e))))
          (if (macro-join-timeout-exception? exn)
              (macro-join-timeout-exception-procedure exn)
              (error "not an instance"
                'join-timeout-exception?
                (list 'join-timeout-exception-procedure exn))))))
  (begin
    (define (keyword-expected-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-keyword-expected-exception? e))
          (macro-keyword-expected-exception? exn)))
    (define (keyword-expected-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-keyword-expected-exception? e)
                (macro-keyword-expected-exception-arguments e)
                (error "not an instance"
                  'keyword-expected-exception?
                  (list 'keyword-expected-exception-arguments e))))
          (if (macro-keyword-expected-exception? exn)
              (macro-keyword-expected-exception-arguments exn)
              (error "not an instance"
                'keyword-expected-exception?
                (list 'keyword-expected-exception-arguments exn)))))
    (define (keyword-expected-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-keyword-expected-exception? e)
                (macro-keyword-expected-exception-procedure e)
                (error "not an instance"
                  'keyword-expected-exception?
                  (list 'keyword-expected-exception-procedure e))))
          (if (macro-keyword-expected-exception? exn)
              (macro-keyword-expected-exception-procedure exn)
              (error "not an instance"
                'keyword-expected-exception?
                (list 'keyword-expected-exception-procedure exn))))))
  (begin
    (define (length-mismatch-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-length-mismatch-exception? e))
          (macro-length-mismatch-exception? exn)))
    (define (length-mismatch-exception-arg-id exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-length-mismatch-exception? e)
                (macro-length-mismatch-exception-arg-id e)
                (error "not an instance"
                  'length-mismatch-exception?
                  (list 'length-mismatch-exception-arg-id e))))
          (if (macro-length-mismatch-exception? exn)
              (macro-length-mismatch-exception-arg-id exn)
              (error "not an instance"
                'length-mismatch-exception?
                (list 'length-mismatch-exception-arg-id exn)))))
    (define (length-mismatch-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-length-mismatch-exception? e)
                (macro-length-mismatch-exception-arguments e)
                (error "not an instance"
                  'length-mismatch-exception?
                  (list 'length-mismatch-exception-arguments e))))
          (if (macro-length-mismatch-exception? exn)
              (macro-length-mismatch-exception-arguments exn)
              (error "not an instance"
                'length-mismatch-exception?
                (list 'length-mismatch-exception-arguments exn)))))
    (define (length-mismatch-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-length-mismatch-exception? e)
                (macro-length-mismatch-exception-procedure e)
                (error "not an instance"
                  'length-mismatch-exception?
                  (list 'length-mismatch-exception-procedure e))))
          (if (macro-length-mismatch-exception? exn)
              (macro-length-mismatch-exception-procedure exn)
              (error "not an instance"
                'length-mismatch-exception?
                (list 'length-mismatch-exception-procedure exn))))))
  (begin
    (define (mailbox-receive-timeout-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-mailbox-receive-timeout-exception? e))
          (macro-mailbox-receive-timeout-exception? exn)))
    (define (mailbox-receive-timeout-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-mailbox-receive-timeout-exception? e)
                (macro-mailbox-receive-timeout-exception-arguments e)
                (error "not an instance"
                  'mailbox-receive-timeout-exception?
                  (list 'mailbox-receive-timeout-exception-arguments e))))
          (if (macro-mailbox-receive-timeout-exception? exn)
              (macro-mailbox-receive-timeout-exception-arguments exn)
              (error "not an instance"
                'mailbox-receive-timeout-exception?
                (list 'mailbox-receive-timeout-exception-arguments exn)))))
    (define (mailbox-receive-timeout-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-mailbox-receive-timeout-exception? e)
                (macro-mailbox-receive-timeout-exception-procedure e)
                (error "not an instance"
                  'mailbox-receive-timeout-exception?
                  (list 'mailbox-receive-timeout-exception-procedure e))))
          (if (macro-mailbox-receive-timeout-exception? exn)
              (macro-mailbox-receive-timeout-exception-procedure exn)
              (error "not an instance"
                'mailbox-receive-timeout-exception?
                (list
                  'mailbox-receive-timeout-exception-procedure
                  exn))))))
  (begin
    (define (module-not-found-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-module-not-found-exception? e))
          (macro-module-not-found-exception? exn)))
    (define (module-not-found-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-module-not-found-exception? e)
                (macro-module-not-found-exception-arguments e)
                (error "not an instance"
                  'module-not-found-exception?
                  (list 'module-not-found-exception-arguments e))))
          (if (macro-module-not-found-exception? exn)
              (macro-module-not-found-exception-arguments exn)
              (error "not an instance"
                'module-not-found-exception?
                (list 'module-not-found-exception-arguments exn)))))
    (define (module-not-found-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-module-not-found-exception? e)
                (macro-module-not-found-exception-procedure e)
                (error "not an instance"
                  'module-not-found-exception?
                  (list 'module-not-found-exception-procedure e))))
          (if (macro-module-not-found-exception? exn)
              (macro-module-not-found-exception-procedure exn)
              (error "not an instance"
                'module-not-found-exception?
                (list 'module-not-found-exception-procedure exn))))))
  (begin
    (define (multiple-c-return-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-multiple-c-return-exception? e))
          (macro-multiple-c-return-exception? exn))))
  (begin
    (define (no-such-file-or-directory-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-no-such-file-or-directory-exception? e))
          (macro-no-such-file-or-directory-exception? exn)))
    (define (no-such-file-or-directory-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-no-such-file-or-directory-exception? e)
                (macro-no-such-file-or-directory-exception-arguments e)
                (error "not an instance"
                  'no-such-file-or-directory-exception?
                  (list
                    'no-such-file-or-directory-exception-arguments
                    e))))
          (if (macro-no-such-file-or-directory-exception? exn)
              (macro-no-such-file-or-directory-exception-arguments exn)
              (error "not an instance"
                'no-such-file-or-directory-exception?
                (list
                  'no-such-file-or-directory-exception-arguments
                  exn)))))
    (define (no-such-file-or-directory-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-no-such-file-or-directory-exception? e)
                (macro-no-such-file-or-directory-exception-procedure e)
                (error "not an instance"
                  'no-such-file-or-directory-exception?
                  (list
                    'no-such-file-or-directory-exception-procedure
                    e))))
          (if (macro-no-such-file-or-directory-exception? exn)
              (macro-no-such-file-or-directory-exception-procedure exn)
              (error "not an instance"
                'no-such-file-or-directory-exception?
                (list
                  'no-such-file-or-directory-exception-procedure
                  exn))))))
  (begin
    (define (noncontinuable-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-noncontinuable-exception? e))
          (macro-noncontinuable-exception? exn)))
    (define (noncontinuable-exception-reason exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-noncontinuable-exception? e)
                (macro-noncontinuable-exception-reason e)
                (error "not an instance"
                  'noncontinuable-exception?
                  (list 'noncontinuable-exception-reason e))))
          (if (macro-noncontinuable-exception? exn)
              (macro-noncontinuable-exception-reason exn)
              (error "not an instance"
                'noncontinuable-exception?
                (list 'noncontinuable-exception-reason exn))))))
  (begin
    (define (nonempty-input-port-character-buffer-exception?
             exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-nonempty-input-port-character-buffer-exception? e))
          (macro-nonempty-input-port-character-buffer-exception?
            exn)))
    (define (nonempty-input-port-character-buffer-exception-arguments
             exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonempty-input-port-character-buffer-exception?
                  e)
                (macro-nonempty-input-port-character-buffer-exception-arguments
                  e)
                (error "not an instance"
                  'nonempty-input-port-character-buffer-exception?
                  (list
                    'nonempty-input-port-character-buffer-exception-arguments
                    e))))
          (if (macro-nonempty-input-port-character-buffer-exception?
                exn)
              (macro-nonempty-input-port-character-buffer-exception-arguments
                exn)
              (error "not an instance"
                'nonempty-input-port-character-buffer-exception?
                (list
                  'nonempty-input-port-character-buffer-exception-arguments
                  exn)))))
    (define (nonempty-input-port-character-buffer-exception-procedure
             exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonempty-input-port-character-buffer-exception?
                  e)
                (macro-nonempty-input-port-character-buffer-exception-procedure
                  e)
                (error "not an instance"
                  'nonempty-input-port-character-buffer-exception?
                  (list
                    'nonempty-input-port-character-buffer-exception-procedure
                    e))))
          (if (macro-nonempty-input-port-character-buffer-exception?
                exn)
              (macro-nonempty-input-port-character-buffer-exception-procedure
                exn)
              (error "not an instance"
                'nonempty-input-port-character-buffer-exception?
                (list
                  'nonempty-input-port-character-buffer-exception-procedure
                  exn))))))
  (begin
    (define (nonprocedure-operator-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-nonprocedure-operator-exception? e))
          (macro-nonprocedure-operator-exception? exn)))
    (define (nonprocedure-operator-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonprocedure-operator-exception? e)
                (macro-nonprocedure-operator-exception-arguments e)
                (error "not an instance"
                  'nonprocedure-operator-exception?
                  (list 'nonprocedure-operator-exception-arguments e))))
          (if (macro-nonprocedure-operator-exception? exn)
              (macro-nonprocedure-operator-exception-arguments exn)
              (error "not an instance"
                'nonprocedure-operator-exception?
                (list 'nonprocedure-operator-exception-arguments exn)))))
    (define (nonprocedure-operator-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonprocedure-operator-exception? e)
                (macro-nonprocedure-operator-exception-code e)
                (error "not an instance"
                  'nonprocedure-operator-exception?
                  (list 'nonprocedure-operator-exception-code e))))
          (if (macro-nonprocedure-operator-exception? exn)
              (macro-nonprocedure-operator-exception-code exn)
              (error "not an instance"
                'nonprocedure-operator-exception?
                (list 'nonprocedure-operator-exception-code exn)))))
    (define (nonprocedure-operator-exception-operator exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonprocedure-operator-exception? e)
                (macro-nonprocedure-operator-exception-operator e)
                (error "not an instance"
                  'nonprocedure-operator-exception?
                  (list 'nonprocedure-operator-exception-operator e))))
          (if (macro-nonprocedure-operator-exception? exn)
              (macro-nonprocedure-operator-exception-operator exn)
              (error "not an instance"
                'nonprocedure-operator-exception?
                (list 'nonprocedure-operator-exception-operator exn)))))
    (define (nonprocedure-operator-exception-rte exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-nonprocedure-operator-exception? e)
                (macro-nonprocedure-operator-exception-rte e)
                (error "not an instance"
                  'nonprocedure-operator-exception?
                  (list 'nonprocedure-operator-exception-rte e))))
          (if (macro-nonprocedure-operator-exception? exn)
              (macro-nonprocedure-operator-exception-rte exn)
              (error "not an instance"
                'nonprocedure-operator-exception?
                (list 'nonprocedure-operator-exception-rte exn))))))
  (begin
    (define (not-in-compilation-context-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-not-in-compilation-context-exception? e))
          (macro-not-in-compilation-context-exception? exn)))
    (define (not-in-compilation-context-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-not-in-compilation-context-exception? e)
                (macro-not-in-compilation-context-exception-arguments e)
                (error "not an instance"
                  'not-in-compilation-context-exception?
                  (list
                    'not-in-compilation-context-exception-arguments
                    e))))
          (if (macro-not-in-compilation-context-exception? exn)
              (macro-not-in-compilation-context-exception-arguments exn)
              (error "not an instance"
                'not-in-compilation-context-exception?
                (list
                  'not-in-compilation-context-exception-arguments
                  exn)))))
    (define (not-in-compilation-context-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-not-in-compilation-context-exception? e)
                (macro-not-in-compilation-context-exception-procedure e)
                (error "not an instance"
                  'not-in-compilation-context-exception?
                  (list
                    'not-in-compilation-context-exception-procedure
                    e))))
          (if (macro-not-in-compilation-context-exception? exn)
              (macro-not-in-compilation-context-exception-procedure exn)
              (error "not an instance"
                'not-in-compilation-context-exception?
                (list
                  'not-in-compilation-context-exception-procedure
                  exn))))))
  (begin
    (define (number-of-arguments-limit-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-number-of-arguments-limit-exception? e))
          (macro-number-of-arguments-limit-exception? exn)))
    (define (number-of-arguments-limit-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-number-of-arguments-limit-exception? e)
                (macro-number-of-arguments-limit-exception-arguments e)
                (error "not an instance"
                  'number-of-arguments-limit-exception?
                  (list
                    'number-of-arguments-limit-exception-arguments
                    e))))
          (if (macro-number-of-arguments-limit-exception? exn)
              (macro-number-of-arguments-limit-exception-arguments exn)
              (error "not an instance"
                'number-of-arguments-limit-exception?
                (list
                  'number-of-arguments-limit-exception-arguments
                  exn)))))
    (define (number-of-arguments-limit-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-number-of-arguments-limit-exception? e)
                (macro-number-of-arguments-limit-exception-procedure e)
                (error "not an instance"
                  'number-of-arguments-limit-exception?
                  (list
                    'number-of-arguments-limit-exception-procedure
                    e))))
          (if (macro-number-of-arguments-limit-exception? exn)
              (macro-number-of-arguments-limit-exception-procedure exn)
              (error "not an instance"
                'number-of-arguments-limit-exception?
                (list
                  'number-of-arguments-limit-exception-procedure
                  exn))))))
  (begin
    (define (os-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-os-exception? e))
          (macro-os-exception? exn)))
    (define (os-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-os-exception? e)
                (macro-os-exception-arguments e)
                (error "not an instance"
                  'os-exception?
                  (list 'os-exception-arguments e))))
          (if (macro-os-exception? exn)
              (macro-os-exception-arguments exn)
              (error "not an instance"
                'os-exception?
                (list 'os-exception-arguments exn)))))
    (define (os-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-os-exception? e)
                (macro-os-exception-code e)
                (error "not an instance"
                  'os-exception?
                  (list 'os-exception-code e))))
          (if (macro-os-exception? exn)
              (macro-os-exception-code exn)
              (error "not an instance"
                'os-exception?
                (list 'os-exception-code exn)))))
    (define (os-exception-message exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-os-exception? e)
                (macro-os-exception-message e)
                (error "not an instance"
                  'os-exception?
                  (list 'os-exception-message e))))
          (if (macro-os-exception? exn)
              (macro-os-exception-message exn)
              (error "not an instance"
                'os-exception?
                (list 'os-exception-message exn)))))
    (define (os-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-os-exception? e)
                (macro-os-exception-procedure e)
                (error "not an instance"
                  'os-exception?
                  (list 'os-exception-procedure e))))
          (if (macro-os-exception? exn)
              (macro-os-exception-procedure exn)
              (error "not an instance"
                'os-exception?
                (list 'os-exception-procedure exn))))))
  (begin
    (define (permission-denied-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-permission-denied-exception? e))
          (macro-permission-denied-exception? exn)))
    (define (permission-denied-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-permission-denied-exception? e)
                (macro-permission-denied-exception-arguments e)
                (error "not an instance"
                  'permission-denied-exception?
                  (list 'permission-denied-exception-arguments e))))
          (if (macro-permission-denied-exception? exn)
              (macro-permission-denied-exception-arguments exn)
              (error "not an instance"
                'permission-denied-exception?
                (list 'permission-denied-exception-arguments exn)))))
    (define (permission-denied-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-permission-denied-exception? e)
                (macro-permission-denied-exception-procedure e)
                (error "not an instance"
                  'permission-denied-exception?
                  (list 'permission-denied-exception-procedure e))))
          (if (macro-permission-denied-exception? exn)
              (macro-permission-denied-exception-procedure exn)
              (error "not an instance"
                'permission-denied-exception?
                (list 'permission-denied-exception-procedure exn))))))
  (begin
    (define (range-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-range-exception? e))
          (macro-range-exception? exn)))
    (define (range-exception-arg-id exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-range-exception? e)
                (macro-range-exception-arg-id e)
                (error "not an instance"
                  'range-exception?
                  (list 'range-exception-arg-id e))))
          (if (macro-range-exception? exn)
              (macro-range-exception-arg-id exn)
              (error "not an instance"
                'range-exception?
                (list 'range-exception-arg-id exn)))))
    (define (range-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-range-exception? e)
                (macro-range-exception-arguments e)
                (error "not an instance"
                  'range-exception?
                  (list 'range-exception-arguments e))))
          (if (macro-range-exception? exn)
              (macro-range-exception-arguments exn)
              (error "not an instance"
                'range-exception?
                (list 'range-exception-arguments exn)))))
    (define (range-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-range-exception? e)
                (macro-range-exception-procedure e)
                (error "not an instance"
                  'range-exception?
                  (list 'range-exception-procedure e))))
          (if (macro-range-exception? exn)
              (macro-range-exception-procedure exn)
              (error "not an instance"
                'range-exception?
                (list 'range-exception-procedure exn))))))
  (begin
    (define (rpc-remote-error-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-rpc-remote-error-exception? e))
          (macro-rpc-remote-error-exception? exn)))
    (define (rpc-remote-error-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-rpc-remote-error-exception? e)
                (macro-rpc-remote-error-exception-arguments e)
                (error "not an instance"
                  'rpc-remote-error-exception?
                  (list 'rpc-remote-error-exception-arguments e))))
          (if (macro-rpc-remote-error-exception? exn)
              (macro-rpc-remote-error-exception-arguments exn)
              (error "not an instance"
                'rpc-remote-error-exception?
                (list 'rpc-remote-error-exception-arguments exn)))))
    (define (rpc-remote-error-exception-message exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-rpc-remote-error-exception? e)
                (macro-rpc-remote-error-exception-message e)
                (error "not an instance"
                  'rpc-remote-error-exception?
                  (list 'rpc-remote-error-exception-message e))))
          (if (macro-rpc-remote-error-exception? exn)
              (macro-rpc-remote-error-exception-message exn)
              (error "not an instance"
                'rpc-remote-error-exception?
                (list 'rpc-remote-error-exception-message exn)))))
    (define (rpc-remote-error-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-rpc-remote-error-exception? e)
                (macro-rpc-remote-error-exception-procedure e)
                (error "not an instance"
                  'rpc-remote-error-exception?
                  (list 'rpc-remote-error-exception-procedure e))))
          (if (macro-rpc-remote-error-exception? exn)
              (macro-rpc-remote-error-exception-procedure exn)
              (error "not an instance"
                'rpc-remote-error-exception?
                (list 'rpc-remote-error-exception-procedure exn))))))
  (begin
    (define (scheduler-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-scheduler-exception? e))
          (macro-scheduler-exception? exn)))
    (define (scheduler-exception-reason exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-scheduler-exception? e)
                (macro-scheduler-exception-reason e)
                (error "not an instance"
                  'scheduler-exception?
                  (list 'scheduler-exception-reason e))))
          (if (macro-scheduler-exception? exn)
              (macro-scheduler-exception-reason exn)
              (error "not an instance"
                'scheduler-exception?
                (list 'scheduler-exception-reason exn))))))
  (begin
    (define (sfun-conversion-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-sfun-conversion-exception? e))
          (macro-sfun-conversion-exception? exn)))
    (define (sfun-conversion-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-sfun-conversion-exception? e)
                (macro-sfun-conversion-exception-arguments e)
                (error "not an instance"
                  'sfun-conversion-exception?
                  (list 'sfun-conversion-exception-arguments e))))
          (if (macro-sfun-conversion-exception? exn)
              (macro-sfun-conversion-exception-arguments exn)
              (error "not an instance"
                'sfun-conversion-exception?
                (list 'sfun-conversion-exception-arguments exn)))))
    (define (sfun-conversion-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-sfun-conversion-exception? e)
                (macro-sfun-conversion-exception-code e)
                (error "not an instance"
                  'sfun-conversion-exception?
                  (list 'sfun-conversion-exception-code e))))
          (if (macro-sfun-conversion-exception? exn)
              (macro-sfun-conversion-exception-code exn)
              (error "not an instance"
                'sfun-conversion-exception?
                (list 'sfun-conversion-exception-code exn)))))
    (define (sfun-conversion-exception-message exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-sfun-conversion-exception? e)
                (macro-sfun-conversion-exception-message e)
                (error "not an instance"
                  'sfun-conversion-exception?
                  (list 'sfun-conversion-exception-message e))))
          (if (macro-sfun-conversion-exception? exn)
              (macro-sfun-conversion-exception-message exn)
              (error "not an instance"
                'sfun-conversion-exception?
                (list 'sfun-conversion-exception-message exn)))))
    (define (sfun-conversion-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-sfun-conversion-exception? e)
                (macro-sfun-conversion-exception-procedure e)
                (error "not an instance"
                  'sfun-conversion-exception?
                  (list 'sfun-conversion-exception-procedure e))))
          (if (macro-sfun-conversion-exception? exn)
              (macro-sfun-conversion-exception-procedure exn)
              (error "not an instance"
                'sfun-conversion-exception?
                (list 'sfun-conversion-exception-procedure exn))))))
  (begin
    (define (stack-overflow-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-stack-overflow-exception? e))
          (macro-stack-overflow-exception? exn))))
  (begin
    (define (started-thread-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-started-thread-exception? e))
          (macro-started-thread-exception? exn)))
    (define (started-thread-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-started-thread-exception? e)
                (macro-started-thread-exception-arguments e)
                (error "not an instance"
                  'started-thread-exception?
                  (list 'started-thread-exception-arguments e))))
          (if (macro-started-thread-exception? exn)
              (macro-started-thread-exception-arguments exn)
              (error "not an instance"
                'started-thread-exception?
                (list 'started-thread-exception-arguments exn)))))
    (define (started-thread-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-started-thread-exception? e)
                (macro-started-thread-exception-procedure e)
                (error "not an instance"
                  'started-thread-exception?
                  (list 'started-thread-exception-procedure e))))
          (if (macro-started-thread-exception? exn)
              (macro-started-thread-exception-procedure exn)
              (error "not an instance"
                'started-thread-exception?
                (list 'started-thread-exception-procedure exn))))))
  (begin
    (define (terminated-thread-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-terminated-thread-exception? e))
          (macro-terminated-thread-exception? exn)))
    (define (terminated-thread-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-terminated-thread-exception? e)
                (macro-terminated-thread-exception-arguments e)
                (error "not an instance"
                  'terminated-thread-exception?
                  (list 'terminated-thread-exception-arguments e))))
          (if (macro-terminated-thread-exception? exn)
              (macro-terminated-thread-exception-arguments exn)
              (error "not an instance"
                'terminated-thread-exception?
                (list 'terminated-thread-exception-arguments exn)))))
    (define (terminated-thread-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-terminated-thread-exception? e)
                (macro-terminated-thread-exception-procedure e)
                (error "not an instance"
                  'terminated-thread-exception?
                  (list 'terminated-thread-exception-procedure e))))
          (if (macro-terminated-thread-exception? exn)
              (macro-terminated-thread-exception-procedure exn)
              (error "not an instance"
                'terminated-thread-exception?
                (list 'terminated-thread-exception-procedure exn))))))
  (begin
    (define (type-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-type-exception? e))
          (macro-type-exception? exn)))
    (define (type-exception-arg-id exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-type-exception? e)
                (macro-type-exception-arg-id e)
                (error "not an instance"
                  'type-exception?
                  (list 'type-exception-arg-id e))))
          (if (macro-type-exception? exn)
              (macro-type-exception-arg-id exn)
              (error "not an instance"
                'type-exception?
                (list 'type-exception-arg-id exn)))))
    (define (type-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-type-exception? e)
                (macro-type-exception-arguments e)
                (error "not an instance"
                  'type-exception?
                  (list 'type-exception-arguments e))))
          (if (macro-type-exception? exn)
              (macro-type-exception-arguments exn)
              (error "not an instance"
                'type-exception?
                (list 'type-exception-arguments exn)))))
    (define (type-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-type-exception? e)
                (macro-type-exception-procedure e)
                (error "not an instance"
                  'type-exception?
                  (list 'type-exception-procedure e))))
          (if (macro-type-exception? exn)
              (macro-type-exception-procedure exn)
              (error "not an instance"
                'type-exception?
                (list 'type-exception-procedure exn)))))
    (define (type-exception-type-id exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-type-exception? e)
                (macro-type-exception-type-id e)
                (error "not an instance"
                  'type-exception?
                  (list 'type-exception-type-id e))))
          (if (macro-type-exception? exn)
              (macro-type-exception-type-id exn)
              (error "not an instance"
                'type-exception?
                (list 'type-exception-type-id exn))))))
  (begin
    (define (unbound-global-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unbound-global-exception? e))
          (macro-unbound-global-exception? exn)))
    (define (unbound-global-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-global-exception? e)
                (macro-unbound-global-exception-code e)
                (error "not an instance"
                  'unbound-global-exception?
                  (list 'unbound-global-exception-code e))))
          (if (macro-unbound-global-exception? exn)
              (macro-unbound-global-exception-code exn)
              (error "not an instance"
                'unbound-global-exception?
                (list 'unbound-global-exception-code exn)))))
    (define (unbound-global-exception-rte exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-global-exception? e)
                (macro-unbound-global-exception-rte e)
                (error "not an instance"
                  'unbound-global-exception?
                  (list 'unbound-global-exception-rte e))))
          (if (macro-unbound-global-exception? exn)
              (macro-unbound-global-exception-rte exn)
              (error "not an instance"
                'unbound-global-exception?
                (list 'unbound-global-exception-rte exn)))))
    (define (unbound-global-exception-variable exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-global-exception? e)
                (macro-unbound-global-exception-variable e)
                (error "not an instance"
                  'unbound-global-exception?
                  (list 'unbound-global-exception-variable e))))
          (if (macro-unbound-global-exception? exn)
              (macro-unbound-global-exception-variable exn)
              (error "not an instance"
                'unbound-global-exception?
                (list 'unbound-global-exception-variable exn))))))
  (begin
    (define (unbound-key-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unbound-key-exception? e))
          (macro-unbound-key-exception? exn)))
    (define (unbound-key-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-key-exception? e)
                (macro-unbound-key-exception-arguments e)
                (error "not an instance"
                  'unbound-key-exception?
                  (list 'unbound-key-exception-arguments e))))
          (if (macro-unbound-key-exception? exn)
              (macro-unbound-key-exception-arguments exn)
              (error "not an instance"
                'unbound-key-exception?
                (list 'unbound-key-exception-arguments exn)))))
    (define (unbound-key-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-key-exception? e)
                (macro-unbound-key-exception-procedure e)
                (error "not an instance"
                  'unbound-key-exception?
                  (list 'unbound-key-exception-procedure e))))
          (if (macro-unbound-key-exception? exn)
              (macro-unbound-key-exception-procedure exn)
              (error "not an instance"
                'unbound-key-exception?
                (list 'unbound-key-exception-procedure exn))))))
  (begin
    (define (unbound-os-environment-variable-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unbound-os-environment-variable-exception? e))
          (macro-unbound-os-environment-variable-exception? exn)))
    (define (unbound-os-environment-variable-exception-arguments
             exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-os-environment-variable-exception? e)
                (macro-unbound-os-environment-variable-exception-arguments
                  e)
                (error "not an instance"
                  'unbound-os-environment-variable-exception?
                  (list
                    'unbound-os-environment-variable-exception-arguments
                    e))))
          (if (macro-unbound-os-environment-variable-exception? exn)
              (macro-unbound-os-environment-variable-exception-arguments
                exn)
              (error "not an instance"
                'unbound-os-environment-variable-exception?
                (list
                  'unbound-os-environment-variable-exception-arguments
                  exn)))))
    (define (unbound-os-environment-variable-exception-procedure
             exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-os-environment-variable-exception? e)
                (macro-unbound-os-environment-variable-exception-procedure
                  e)
                (error "not an instance"
                  'unbound-os-environment-variable-exception?
                  (list
                    'unbound-os-environment-variable-exception-procedure
                    e))))
          (if (macro-unbound-os-environment-variable-exception? exn)
              (macro-unbound-os-environment-variable-exception-procedure
                exn)
              (error "not an instance"
                'unbound-os-environment-variable-exception?
                (list
                  'unbound-os-environment-variable-exception-procedure
                  exn))))))
  (begin
    (define (unbound-serial-number-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unbound-serial-number-exception? e))
          (macro-unbound-serial-number-exception? exn)))
    (define (unbound-serial-number-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-serial-number-exception? e)
                (macro-unbound-serial-number-exception-arguments e)
                (error "not an instance"
                  'unbound-serial-number-exception?
                  (list 'unbound-serial-number-exception-arguments e))))
          (if (macro-unbound-serial-number-exception? exn)
              (macro-unbound-serial-number-exception-arguments exn)
              (error "not an instance"
                'unbound-serial-number-exception?
                (list 'unbound-serial-number-exception-arguments exn)))))
    (define (unbound-serial-number-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unbound-serial-number-exception? e)
                (macro-unbound-serial-number-exception-procedure e)
                (error "not an instance"
                  'unbound-serial-number-exception?
                  (list 'unbound-serial-number-exception-procedure e))))
          (if (macro-unbound-serial-number-exception? exn)
              (macro-unbound-serial-number-exception-procedure exn)
              (error "not an instance"
                'unbound-serial-number-exception?
                (list 'unbound-serial-number-exception-procedure exn))))))
  (begin
    (define (uncaught-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-uncaught-exception? e))
          (macro-uncaught-exception? exn)))
    (define (uncaught-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-uncaught-exception? e)
                (macro-uncaught-exception-arguments e)
                (error "not an instance"
                  'uncaught-exception?
                  (list 'uncaught-exception-arguments e))))
          (if (macro-uncaught-exception? exn)
              (macro-uncaught-exception-arguments exn)
              (error "not an instance"
                'uncaught-exception?
                (list 'uncaught-exception-arguments exn)))))
    (define (uncaught-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-uncaught-exception? e)
                (macro-uncaught-exception-procedure e)
                (error "not an instance"
                  'uncaught-exception?
                  (list 'uncaught-exception-procedure e))))
          (if (macro-uncaught-exception? exn)
              (macro-uncaught-exception-procedure exn)
              (error "not an instance"
                'uncaught-exception?
                (list 'uncaught-exception-procedure exn)))))
    (define (uncaught-exception-reason exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-uncaught-exception? e)
                (macro-uncaught-exception-reason e)
                (error "not an instance"
                  'uncaught-exception?
                  (list 'uncaught-exception-reason e))))
          (if (macro-uncaught-exception? exn)
              (macro-uncaught-exception-reason exn)
              (error "not an instance"
                'uncaught-exception?
                (list 'uncaught-exception-reason exn))))))
  (begin
    (define (uninitialized-thread-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-uninitialized-thread-exception? e))
          (macro-uninitialized-thread-exception? exn)))
    (define (uninitialized-thread-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-uninitialized-thread-exception? e)
                (macro-uninitialized-thread-exception-arguments e)
                (error "not an instance"
                  'uninitialized-thread-exception?
                  (list 'uninitialized-thread-exception-arguments e))))
          (if (macro-uninitialized-thread-exception? exn)
              (macro-uninitialized-thread-exception-arguments exn)
              (error "not an instance"
                'uninitialized-thread-exception?
                (list 'uninitialized-thread-exception-arguments exn)))))
    (define (uninitialized-thread-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-uninitialized-thread-exception? e)
                (macro-uninitialized-thread-exception-procedure e)
                (error "not an instance"
                  'uninitialized-thread-exception?
                  (list 'uninitialized-thread-exception-procedure e))))
          (if (macro-uninitialized-thread-exception? exn)
              (macro-uninitialized-thread-exception-procedure exn)
              (error "not an instance"
                'uninitialized-thread-exception?
                (list 'uninitialized-thread-exception-procedure exn))))))
  (begin
    (define (unknown-keyword-argument-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unknown-keyword-argument-exception? e))
          (macro-unknown-keyword-argument-exception? exn)))
    (define (unknown-keyword-argument-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unknown-keyword-argument-exception? e)
                (macro-unknown-keyword-argument-exception-arguments e)
                (error "not an instance"
                  'unknown-keyword-argument-exception?
                  (list 'unknown-keyword-argument-exception-arguments e))))
          (if (macro-unknown-keyword-argument-exception? exn)
              (macro-unknown-keyword-argument-exception-arguments exn)
              (error "not an instance"
                'unknown-keyword-argument-exception?
                (list
                  'unknown-keyword-argument-exception-arguments
                  exn)))))
    (define (unknown-keyword-argument-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unknown-keyword-argument-exception? e)
                (macro-unknown-keyword-argument-exception-procedure e)
                (error "not an instance"
                  'unknown-keyword-argument-exception?
                  (list 'unknown-keyword-argument-exception-procedure e))))
          (if (macro-unknown-keyword-argument-exception? exn)
              (macro-unknown-keyword-argument-exception-procedure exn)
              (error "not an instance"
                'unknown-keyword-argument-exception?
                (list
                  'unknown-keyword-argument-exception-procedure
                  exn))))))
  (begin
    (define (unterminated-process-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-unterminated-process-exception? e))
          (macro-unterminated-process-exception? exn)))
    (define (unterminated-process-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unterminated-process-exception? e)
                (macro-unterminated-process-exception-arguments e)
                (error "not an instance"
                  'unterminated-process-exception?
                  (list 'unterminated-process-exception-arguments e))))
          (if (macro-unterminated-process-exception? exn)
              (macro-unterminated-process-exception-arguments exn)
              (error "not an instance"
                'unterminated-process-exception?
                (list 'unterminated-process-exception-arguments exn)))))
    (define (unterminated-process-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-unterminated-process-exception? e)
                (macro-unterminated-process-exception-procedure e)
                (error "not an instance"
                  'unterminated-process-exception?
                  (list 'unterminated-process-exception-procedure e))))
          (if (macro-unterminated-process-exception? exn)
              (macro-unterminated-process-exception-procedure exn)
              (error "not an instance"
                'unterminated-process-exception?
                (list 'unterminated-process-exception-procedure exn))))))
  (begin
    (define (wrong-number-of-arguments-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-wrong-number-of-arguments-exception? e))
          (macro-wrong-number-of-arguments-exception? exn)))
    (define (wrong-number-of-arguments-exception-arguments exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-wrong-number-of-arguments-exception? e)
                (macro-wrong-number-of-arguments-exception-arguments e)
                (error "not an instance"
                  'wrong-number-of-arguments-exception?
                  (list
                    'wrong-number-of-arguments-exception-arguments
                    e))))
          (if (macro-wrong-number-of-arguments-exception? exn)
              (macro-wrong-number-of-arguments-exception-arguments exn)
              (error "not an instance"
                'wrong-number-of-arguments-exception?
                (list
                  'wrong-number-of-arguments-exception-arguments
                  exn)))))
    (define (wrong-number-of-arguments-exception-procedure exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-wrong-number-of-arguments-exception? e)
                (macro-wrong-number-of-arguments-exception-procedure e)
                (error "not an instance"
                  'wrong-number-of-arguments-exception?
                  (list
                    'wrong-number-of-arguments-exception-procedure
                    e))))
          (if (macro-wrong-number-of-arguments-exception? exn)
              (macro-wrong-number-of-arguments-exception-procedure exn)
              (error "not an instance"
                'wrong-number-of-arguments-exception?
                (list
                  'wrong-number-of-arguments-exception-procedure
                  exn))))))
  (begin
    (define (wrong-number-of-values-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-wrong-number-of-values-exception? e))
          (macro-wrong-number-of-values-exception? exn)))
    (define (wrong-number-of-values-exception-code exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-wrong-number-of-values-exception? e)
                (macro-wrong-number-of-values-exception-code e)
                (error "not an instance"
                  'wrong-number-of-values-exception?
                  (list 'wrong-number-of-values-exception-code e))))
          (if (macro-wrong-number-of-values-exception? exn)
              (macro-wrong-number-of-values-exception-code exn)
              (error "not an instance"
                'wrong-number-of-values-exception?
                (list 'wrong-number-of-values-exception-code exn)))))
    (define (wrong-number-of-values-exception-rte exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-wrong-number-of-values-exception? e)
                (macro-wrong-number-of-values-exception-rte e)
                (error "not an instance"
                  'wrong-number-of-values-exception?
                  (list 'wrong-number-of-values-exception-rte e))))
          (if (macro-wrong-number-of-values-exception? exn)
              (macro-wrong-number-of-values-exception-rte exn)
              (error "not an instance"
                'wrong-number-of-values-exception?
                (list 'wrong-number-of-values-exception-rte exn)))))
    (define (wrong-number-of-values-exception-vals exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (if (macro-wrong-number-of-values-exception? e)
                (macro-wrong-number-of-values-exception-vals e)
                (error "not an instance"
                  'wrong-number-of-values-exception?
                  (list 'wrong-number-of-values-exception-vals e))))
          (if (macro-wrong-number-of-values-exception? exn)
              (macro-wrong-number-of-values-exception-vals exn)
              (error "not an instance"
                'wrong-number-of-values-exception?
                (list 'wrong-number-of-values-exception-vals exn))))))
  (begin
    (define (wrong-processor-c-return-exception? exn)
      (if (RuntimeException? exn)
          (let ([e (&RuntimeException-exception exn)])
            (macro-wrong-processor-c-return-exception? e))
          (macro-wrong-processor-c-return-exception? exn)))))

