(define-syntax ast-case
  (lambda (stx)
    (macro-expand-syntax-case stx 'stx-eq? 'stx-e 'quote)))

(define-syntax ast-rules
  (lambda (stx)
    (syntax-case stx ()
      [(_ ids clause ...)
       (identifier-list? #'ids)
       (with-syntax ([(clause ...) (stx-map
                                     (lambda (clause)
                                       (syntax-case clause ()
                                         [(hd body) #'(hd #'body)]
                                         [(hd fender body)
                                          #'(hd fender #'body)]))
                                     #'(clause ...))])
         #'(lambda ($stx) (ast-case $stx ids clause ...)))])))

(define current-compile-symbol-table (make-parameter #f))

(define current-compile-runtime-sections
  (make-parameter #f))

(define current-compile-runtime-names (make-parameter #f))

(define current-compile-output-dir (make-parameter #f))

(define current-compile-invoke-gsc (make-parameter #f))

(define current-compile-gsc-options (make-parameter #f))

(define current-compile-keep-scm (make-parameter #f))

(define current-compile-verbose
  (make-parameter
    (let ([verbosity (getenv "GERBIL_BUILD_VERBOSE" #f)])
      (and verbosity
           (begin (or (string->number verbosity) verbosity))))))

(define current-compile-optimize (make-parameter #f))

(define current-compile-debug (make-parameter #f))

(define current-compile-generate-ssxi (make-parameter #f))

(define current-compile-static (make-parameter #f))

(define current-compile-timestamp (make-parameter #f))

(define current-compile-decls (make-parameter #f))

(define current-compile-context (make-parameter #f))

(define current-compile-parallel (make-parameter #f))

(define current-compile-local-env (make-parameter (list)))

(begin
  (define symbol-table::t
    (make-class-type 'gerbil\x23;symbol-table::t 'symbol-table (list object::t)
      '(gensyms bindings)
      '((struct: . #t)
         (id: . gxc\x23;symbol-table::t)
         (constructor: . :init!))
      '#f))
  (define (make-symbol-table . args)
    (let* ([type symbol-table::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (symbol-table? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;symbol-table::t))
  (define (symbol-table-gensyms obj)
    (unchecked-slot-ref obj 'gensyms))
  (define (symbol-table-bindings obj)
    (unchecked-slot-ref obj 'bindings))
  (define (symbol-table-gensyms-set! obj val)
    (unchecked-slot-set! obj 'gensyms val))
  (define (symbol-table-bindings-set! obj val)
    (unchecked-slot-set! obj 'bindings val))
  (define (&symbol-table-gensyms obj)
    (unchecked-slot-ref obj 'gensyms))
  (define (&symbol-table-bindings obj)
    (unchecked-slot-ref obj 'bindings))
  (define (&symbol-table-gensyms-set! obj val)
    (unchecked-slot-set! obj 'gensyms val))
  (define (&symbol-table-bindings-set! obj val)
    (unchecked-slot-set! obj 'bindings val)))

(begin
  (define symbol-table:::init!
    (lambda (self)
      (struct-instance-init!
        self
        (make-hash-table-eq)
        (make-hash-table-eq))))
  (bind-method! symbol-table::t ':init! symbol-table:::init!))

(define (raise-compile-error message stx . details)
  (let ([ctx (or (current-compile-context) '(compile))])
    (apply raise-syntax-error ctx message stx details)))

(define (verbose . args)
  (when (current-compile-verbose)
    (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-1833} __verbose-mutex])
      (dynamic-wind
        (lambda ()
          (mutex-lock! #{mtx dpuuv4a3mobea70icwo8nvdax-1833}))
        (lambda () (apply displayln args))
        (lambda ()
          (mutex-unlock! #{mtx dpuuv4a3mobea70icwo8nvdax-1833}))))))

(define __verbose-mutex (make-mutex 'compiler/driver))

(define-syntax with-verbose-mutex
  (syntax-rules ()
    [(_ expr) (with-lock __verbose-mutex (lambda () expr))]))

(define module-path-reserved-chars ":#<>&!?*;()[]{}|'`\"\\")

(define (module-id->path-string id)
  (let* ([str (if (symbol? id) (symbol->string id) id)])
    (let* ([len (string-length str)])
      (let* ([res (make-string len)])
        (let lp ([i 0])
          (if (fx< i len)
              (let* ([char (string-ref str i)])
                (let* ([xchar (if (string-index
                                    module-path-reserved-chars
                                    char)
                                  #\_
                                  char)])
                  (string-set! res i xchar)
                  (lp (fx1+ i))))
              res))))))

(define (map* proc maybe-improper-list)
  (let recur ([rest maybe-improper-list])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1834} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1834})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1835} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1834})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-1836} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1834})])
            (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-1835}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1836}])
                (begin (cons (proc hd) (recur rest))))))
          (if (null? #{match-val dpuuv4a3mobea70icwo8nvdax-1834})
              (begin (list))
              (let ([tail #{match-val dpuuv4a3mobea70icwo8nvdax-1834}])
                (proc tail)))))))

(define (symbol-in-local-scope? sym)
  (or (not (gensym-reference? sym))
      (memq sym (current-compile-local-env))))

(define (gensym-reference? sym)
  (let ([str (symbol->string sym)])
    (and (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-1837} "_%"]
               [#{str dpuuv4a3mobea70icwo8nvdax-1838} str])
           (let ([plen (string-length
                         #{pfx dpuuv4a3mobea70icwo8nvdax-1837})])
             (and (<= plen
                      (string-length
                        #{str dpuuv4a3mobea70icwo8nvdax-1838}))
                  (string=?
                    #{pfx dpuuv4a3mobea70icwo8nvdax-1837}
                    (substring
                      #{str dpuuv4a3mobea70icwo8nvdax-1838}
                      0
                      plen)))))
         (let ([#{sfx dpuuv4a3mobea70icwo8nvdax-1839} "%_"]
               [#{str dpuuv4a3mobea70icwo8nvdax-1840} str])
           (let ([slen (string-length
                         #{sfx dpuuv4a3mobea70icwo8nvdax-1839})]
                 [len (string-length
                        #{str dpuuv4a3mobea70icwo8nvdax-1840})])
             (and (<= slen len)
                  (string=?
                    #{sfx dpuuv4a3mobea70icwo8nvdax-1839}
                    (substring
                      #{str dpuuv4a3mobea70icwo8nvdax-1840}
                      (- len slen)
                      len))))))))

(define (generate-runtime-binding-id id)
  (cond
    [(and (syntax-quote? id) (resolve-identifier id)) =>
     (lambda (bind)
       (let ([eid (binding-id bind)]
             [ht (symbol-table-bindings (current-compile-symbol-table))])
         (cond
           [(interned-symbol? eid) eid]
           [(hash-get ht eid)]
           [(local-binding? bind)
            (let ([gid (generate-runtime-gensym-reference eid)])
              (hash-put! ht eid gid)
              gid)]
           [(module-binding? bind)
            (let ([gid (cond
                         [(module-context-ns (module-binding-context bind)) =>
                          (lambda (ns) (make-symbol ns "#" eid))]
                         [else (generate-runtime-gensym-reference eid)])])
              (hash-put! ht eid gid)
              gid)]
           [else
            (raise-compile-error
              "Cannot compile reference to uninterned binding"
              id
              eid
              bind)])))]
    [(interned-symbol? (stx-e id)) (stx-e id)]
    [else
     (raise-compile-error
       "Cannot compile reference to uninterned identifier"
       id)]))

(define (generate-runtime-binding-id* id)
  (if (identifier? id)
      (generate-runtime-binding-id id)
      (generate-runtime-temporary)))

(define generate-runtime-temporary
  (case-lambda
    [()
     (let* ([top #f])
       (if top
           (let ([ns (module-context-ns
                       (core-context-top (current-expander-context)))]
                 [phi (current-expander-phi)])
             (if ns
                 (if (fxpositive? phi)
                     (make-symbol ns "[" (number->string phi) "]#_"
                       (gensym) "_")
                     (make-symbol ns "#_" (gensym) "_"))
                 (if (fxpositive? phi)
                     (make-symbol "[" (number->string phi) "]#_" (gensym)
                       "_")
                     (make-symbol "_" (gensym) "_"))))
           (make-symbol "_" (gensym) "_")))]
    [(top)
     (if top
         (let ([ns (module-context-ns
                     (core-context-top (current-expander-context)))]
               [phi (current-expander-phi)])
           (if ns
               (if (fxpositive? phi)
                   (make-symbol ns "[" (number->string phi) "]#_" (gensym)
                     "_")
                   (make-symbol ns "#_" (gensym) "_"))
               (if (fxpositive? phi)
                   (make-symbol "[" (number->string phi) "]#_" (gensym)
                     "_")
                   (make-symbol "_" (gensym) "_"))))
         (make-symbol "_" (gensym) "_"))]))

(define generate-runtime-gensym-reference
  (case-lambda
    [(sym)
     (let* ([quote? #f])
       (let ([ht (symbol-table-gensyms
                   (current-compile-symbol-table))])
         (cond
           [(hash-get ht sym)]
           [else
            (let ([g (if quote?
                         (make-symbol
                           "__"
                           sym
                           "__"
                           (current-compile-timestamp))
                         (make-symbol "_%" sym "%_"))])
              (hash-put! ht sym g)
              g)])))]
    [(sym quote?)
     (let ([ht (symbol-table-gensyms
                 (current-compile-symbol-table))])
       (cond
         [(hash-get ht sym)]
         [else
          (let ([g (if quote?
                       (make-symbol
                         "__"
                         sym
                         "__"
                         (current-compile-timestamp))
                       (make-symbol "_%" sym "%_"))])
            (hash-put! ht sym g)
            g)]))]))

(define (runtime-identifier=? id1 id2)
  (define (symbol-e id)
    (if (symbol? id) id (generate-runtime-binding-id id)))
  (eq? (symbol-e id1) (symbol-e id2)))

(define (identifier-symbol stx)
  (if (syntax-quote? stx)
      (generate-runtime-binding-id stx)
      (stx-e stx)))

(define __compile-jobs (list))

(define __available-cores
  (string->number (getenv "GERBIL_BUILD_CORES" "1")))

(define __jobs-mx (make-mutex))

(define __jobs-cv (make-condition-variable))

(define add-compile-job!
  (case-lambda
    [(thunk)
     (let* ([name (current-compile-context)])
       (mutex-lock! __jobs-mx)
       (let ([job (make-compile-job thunk name)])
         (set! __compile-jobs (cons job __compile-jobs)))
       (mutex-unlock! __jobs-mx))]
    [(thunk name)
     (mutex-lock! __jobs-mx)
     (let ([job (make-compile-job thunk name)])
       (set! __compile-jobs (cons job __compile-jobs)))
     (mutex-unlock! __jobs-mx)]))

(define (pending-compile-jobs)
  (mutex-lock! __jobs-mx)
  (let ([result (reverse! __compile-jobs)])
    (set! __compile-jobs (list))
    (mutex-unlock! __jobs-mx)
    result))

(define (execute-pending-compile-jobs!)
  (let loop ()
    (let ([pending (pending-compile-jobs)])
      (unless (null? pending)
        (for-each thread-start! pending)
        (for-each join! pending)))))

(define (make-compile-job thunk name)
  (make-thread
    (lambda ()
      (let loop ()
        (mutex-lock! __jobs-mx)
        (if (> __available-cores 0)
            (begin
              (set! __available-cores (\x31;- __available-cores))
              (mutex-unlock! __jobs-mx)
              (let ([#{mtx dpuuv4a3mobea70icwo8nvdax-1841} __verbose-mutex])
                (dynamic-wind
                  (lambda ()
                    (mutex-lock! #{mtx dpuuv4a3mobea70icwo8nvdax-1841}))
                  (lambda ()
                    (begin
                      (display "... execute compile job ")
                      (display name)
                      (newline)))
                  (lambda ()
                    (mutex-unlock!
                      #{mtx dpuuv4a3mobea70icwo8nvdax-1841}))))
              (dynamic-wind
                (lambda () (void))
                (lambda () (thunk))
                (lambda ()
                  (mutex-lock! __jobs-mx)
                  (set! __available-cores (fx1+ __available-cores))
                  (condition-variable-signal! __jobs-cv)
                  (mutex-unlock! __jobs-mx))))
            (begin (mutex-unlock! __jobs-mx __jobs-cv) (loop)))))
    name))

(define-syntax go!
  (syntax-rules () [(_ expr) (spawn (lambda () expr))]))

(define (join! thread)
  (guard (__exn
           [#t
            ((lambda (exn)
               (if (uncaught-exception? exn)
                   (raise (uncaught-exception-reason exn))
                   (raise exn)))
              __exn)])
    ((lambda () (thread-join! thread)))))

