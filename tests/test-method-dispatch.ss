#!chezscheme
;;; test-method-dispatch.ss — Diagnose method dispatch on expander structs
;;;
;;; This test loads the runtime and expander, then traces the exact
;;; method dispatch chain to find where it breaks.

(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table compile-file)
  (except (compat gambit-compat) void? absent-obj)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime hash)
  (runtime mop)
  (runtime syntax)
  (only (compiler compile) gerbil-compile-top gerbil-compile-expression
        strip-annotations sanitize-compiled)
  (only (reader reader) gerbil-read-file annotated-datum? annotated-datum-value))

;;; ============================================================
;;; Reuse bootstrap infrastructure from self-host-core.ss
;;; (minimal version — just enough to load runtime + expander)
;;; ============================================================

(define output-dir "/tmp/gherkin-method-test/")
(unless (file-exists? output-dir) (mkdir output-dir))

(define runtime-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/runtime/")))

(define expander-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/expander/")))

(define core-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/core/")))

;;; --- Utility functions (same as self-host-core.ss) ---

(define (read-gerbil-file path)
  (let ([forms (gerbil-read-file path)])
    (let loop ([forms forms] [result '()])
      (if (null? forms)
        (reverse result)
        (let ([form (car forms)])
          (let ([val (if (annotated-datum? form)
                       (annotated-datum-value form)
                       form)])
            (cond
              [(or (and (symbol? val)
                        (let ([s (symbol->string val)])
                          (or (string=? s "prelude:")
                              (string=? s "package:")
                              (string=? s "namespace:"))))
                   (and (|##keyword?| val)
                        (let ([s (|##keyword->string| val)])
                          (or (string=? s "prelude")
                              (string=? s "package")
                              (string=? s "namespace")))))
               (if (null? (cdr forms))
                 (loop (cdr forms) result)
                 (loop (cddr forms) result))]
              [else
               (loop (cdr forms) (cons form result))])))))))

(define (compile-file src-dir filename)
  (let ([src-path (string-append src-dir filename)]
        [out-path (string-append output-dir filename)])
    (guard (exn [#t
      (printf "  COMPILE ERROR (~a): ~a~n" filename
        (if (message-condition? exn) (condition-message exn) exn))
      #f])
      (let* ([forms (read-gerbil-file src-path)]
             [stripped (map (lambda (f)
                             (if (annotated-datum? f)
                               (strip-annotations (annotated-datum-value f))
                               (strip-annotations f)))
                           forms)]
             [_ (for-each
                  (lambda (form)
                    (when (and (pair? form) (memq (car form) '(defrules defrule)))
                      (guard (exn [#t (void)])
                        (gerbil-compile-top form))))
                  stripped)]
             [compiled
              (let loop ([forms stripped] [result '()])
                (if (null? forms)
                  (reverse result)
                  (let ([form (car forms)])
                    (guard (exn [#t (loop (cdr forms) result)])
                      (let ([c (gerbil-compile-top form)])
                        (cond
                          [(and (pair? c) (memq (car c) '(import export)))
                           (loop (cdr forms) result)]
                          [(equal? c '(begin))
                           (loop (cdr forms) result)]
                          [else
                           (loop (cdr forms) (cons c result))]))))))])
        (call-with-output-file out-path
          (lambda (port)
            (for-each
              (lambda (form)
                (pretty-print (sanitize-compiled form) port)
                (newline port))
              compiled))
          'replace)
        compiled))))

(define (load-file filename)
  (let ([path (string-append output-dir filename)]
        [errors 0] [loaded 0])
    (guard (exn [#t
      (printf "  LOAD ERROR (~a): ~a~n" filename
        (if (message-condition? exn) (condition-message exn) exn))
      #f])
      (let ([port (open-input-file path)])
        (let loop ()
          (let ([form (read port)])
            (unless (eof-object? form)
              (if (and (pair? form) (memq (car form) '(import export)))
                (loop)
                (begin
                  (guard (exn [#t
                    (set! errors (+ errors 1))])
                    (eval form)
                    (set! loaded (+ loaded 1)))
                  (loop))))))
        (close-input-port port))
      #t)))

;;; --- Inject bindings (same as self-host-core.ss) ---

(define (inject name val)
  (define-top-level-value name val (interaction-environment)))

;; Basic Gambit stubs
(inject '%%void |%%void|)
(inject '|%%void| |%%void|)
(inject '|##absent-object| (lambda () absent-obj))
(inject 'absent-obj absent-obj)

(for-each
  (lambda (pair) (inject (car pair) (cdr pair)))
  `((|##fxior| . ,fxior) (|##fxand| . ,fxand) (|##fxnot| . ,fxnot)
    (|##fxarithmetic-shift-left| . ,fxarithmetic-shift-left)
    (|##fxarithmetic-shift-right| . ,fxarithmetic-shift-right)
    (|##fx+| . ,fx+) (|##fx-| . ,fx-) (|##fx*| . ,fx*)
    (|##fx<| . ,fx<) (|##fx>| . ,fx>) (|##fx=| . ,fx=)
    (|##fx<=| . ,fx<=) (|##fx>=| . ,fx>=)
    (|##fixnum?| . ,fixnum?) (|##eq?| . ,eq?) (|##eqv?| . ,eqv?)
    (|##not| . ,not) (|##car| . ,car) (|##cdr| . ,cdr)
    (|##pair?| . ,pair?) (|##null?| . ,null?)
    (|##vector-ref| . ,vector-ref) (|##vector-set!| . ,vector-set!)
    (|##vector-length| . ,vector-length)
    (|##string-ref| . ,string-ref) (|##string-length| . ,string-length)
    (|##cons| . ,cons) (|##list| . ,list)
    (|##values| . ,values) (|##apply| . ,apply)))

;; ##type — Gambit type tag. Returns fixnum tag for type discrimination.
;; Bit 0 = 0 for immediates (fixnum, char, bool), 1 for non-immediates.
(inject '|##type|
  (lambda (obj)
    (cond
      [(fixnum? obj) 0]        ;; fixnum tag = 0 (even → immediate)
      [(char? obj) 2]          ;; char tag = 2 (even → immediate)
      [(eq? obj #t) 0]         ;; boolean → immediate
      [(eq? obj #f) 0]         ;; boolean → immediate
      [(null? obj) 0]          ;; null → immediate
      [(pair? obj) 3]          ;; pair → non-immediate (odd)
      [(symbol? obj) 1]        ;; symbol → non-immediate (odd) + symbolic
      [(string? obj) 31]       ;; string → non-immediate
      [(vector? obj) 5]        ;; vector → non-immediate
      [(gerbil-struct? obj) 5] ;; structure → non-immediate
      [else 1])))              ;; default non-immediate

;; ##closure? — check if obj is a closure (interpreted procedure)
(inject '|##closure?| procedure?)

(let ([unused (vector 'unused)] [deleted (vector 'deleted)])
  (inject 'macro-unused-obj (lambda () unused))
  (inject 'macro-deleted-obj (lambda () deleted)))
(inject 'macro-gc-hash-table-flag-weak-keys (lambda () 1))
(inject 'macro-gc-hash-table-flag-weak-vals (lambda () 2))
(inject 'macro-gc-hash-table-flag-key-moved (lambda () 16))
(inject 'macro-gc-hash-table-flag-need-rehash (lambda () 32))

(let ([counter 0])
  (inject 'nonce (lambda () (set! counter (+ counter 1)) counter)))

(eval '(import
         (except (chezscheme) void box box? unbox set-box!
                 andmap ormap iota last-pair find
                 1+ 1- fx/ fx1+ fx1-
                 error error? raise with-exception-handler identifier?
                 hash-table? make-hash-table)
         (except (compat gambit-compat) void? absent-obj)
         (compat types)
         (runtime util)
         (runtime syntax)))

(inject '|##string=?-hash| string-hash)
(inject 'eq?-hash equal-hash) (inject 'eqv?-hash equal-hash)
(inject 'equal?-hash equal-hash) (inject 'eq-hash equal-hash)
(inject '|##vector-cas!|
  (lambda (vec idx expected new)
    (let ([old (vector-ref vec idx)])
      (when (eqv? old expected) (vector-set! vec idx new)) old)))
(inject '|##thread-yield!| (lambda () (void)))
(inject 'class-of
  (lambda (obj) (if (gerbil-struct? obj) (gerbil-struct-type-tag obj) #f)))
(inject '__class-slot-offset
  (lambda (klass slot) (symbolic-table-ref (class-type-slot-table klass) slot #f)))

(inject 'call-with-output-string
  (lambda (init proc) (let ([p (open-output-string)]) (proc p) (get-output-string p))))
(inject 'random-integer (lambda (n) (random n)))
(inject 'make-condition-variable (lambda args 'cv-stub))
(inject 'mutex-lock! (lambda (m . args) (void)))
(inject 'mutex-unlock! (lambda (m . args) (void)))
(for-each
  (lambda (type)
    (let ([set-name (string->symbol (string-append type "vector-set!"))])
      (guard (exn [#t (inject set-name (lambda (v i x) (void)))])
        (eval set-name))))
  '("s8" "u8" "s16" "u16" "s32" "u32" "s64" "u64" "f32" "f64"))
(inject 'with-catch
  (lambda (handler thunk) (guard (exn [#t (handler exn)]) (thunk))))

;; Save working hash/table operations
(define saved-hash-put! hash-put!)
(define saved-hash-get hash-get)
(define saved-hash-ref hash-ref)
(define saved-hash-remove! hash-remove!)
(define saved-hash-key? hash-key?)
(define saved-hash-length hash-length)
(define saved-hash-for-each hash-for-each)
(define saved-hash-map hash-map)
(define saved-hash-keys hash-keys)
(define saved-hash-values hash-values)
(define saved-make-hash-table-eq make-hash-table-eq)
(define saved-make-hash-table make-hash-table)
(define saved-symbolic-table-ref symbolic-table-ref)
(define saved-symbolic-table-set! symbolic-table-set!)
(define saved-symbolic-table-delete! symbolic-table-delete!)
(define saved-symbolic-table-for-each symbolic-table-for-each)
(define saved-make-symbolic-table make-symbolic-table)

;;; ============================================================
;;; Load runtime
;;; ============================================================

(printf "=== Loading Runtime ===~n")

(define runtime-files
  '("util.ss" "c3.ss" "table.ss" "control.ss" "mop.ss"
    "mop-system-classes.ss" "error.ss" "interface.ss" "hash.ss"
    "syntax.ss" "thread.ss" "eval.ss" "loader.ss" "repl.ss"))

(for-each
  (lambda (filename)
    (let ([forms (compile-file runtime-src-dir filename)])
      (when (and forms (not (null? forms)))
        (load-file filename)
        (when (string=? filename "mop.ss")
          (for-each
            (lambda (slot-field)
              (let* ([slot (car slot-field)] [field (cadr slot-field)]
                     [slot-s (symbol->string slot)]
                     [ref-name (string->symbol (string-append "class-type-" slot-s))]
                     [&ref-name (string->symbol (string-append "&class-type-" slot-s))]
                     [set-name (string->symbol (string-append "class-type-" slot-s "-set!"))]
                     [&set-name (string->symbol (string-append "&class-type-" slot-s "-set!"))])
                (eval `(define (,ref-name klass)
                         (|##structure-ref| klass ,field class::t ',slot)))
                (eval `(define (,&ref-name klass)
                         (|##unchecked-structure-ref| klass ,field class::t ',slot)))
                (eval `(define (,set-name klass val)
                         (|##structure-set!| klass val ,field class::t ',slot)))
                (eval `(define (,&set-name klass val)
                         (|##unchecked-structure-set!| klass val ,field class::t ',slot)))))
            '((id 1) (name 2) (flags 3) (super 4) (fields 5)
              (precedence-list 6) (slot-vector 7) (slot-table 8)
              (properties 9) (constructor 10) (methods 11)))))))
  runtime-files)

;; Restore hash/table operations
(inject 'hash-put! saved-hash-put!)
(inject 'hash-get saved-hash-get)
(inject 'hash-ref saved-hash-ref)
(inject 'hash-remove! saved-hash-remove!)
(inject 'hash-key? saved-hash-key?)
(inject 'hash-length saved-hash-length)
(inject 'hash-for-each saved-hash-for-each)
(inject 'hash-map saved-hash-map)
(inject 'hash-keys saved-hash-keys)
(inject 'hash-values saved-hash-values)
(inject 'make-hash-table-eq saved-make-hash-table-eq)
(inject 'make-hash-table saved-make-hash-table)
(inject 'symbolic-table-ref saved-symbolic-table-ref)
(inject 'symbolic-table-set! saved-symbolic-table-set!)
(inject 'symbolic-table-delete! saved-symbolic-table-delete!)
(inject 'symbolic-table-for-each saved-symbolic-table-for-each)
(inject 'make-symbolic-table saved-make-symbolic-table)
(inject 'class-slot-offset
  (lambda (klass slot) (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))
(inject '__class-slot-offset
  (lambda (klass slot) (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))

(printf "  Runtime loaded~n")

;;; ============================================================
;;; Expander stubs
;;; ============================================================

(inject 'gerbil-system (lambda () 'gerbil-chez))
(inject 'system-type (lambda () '(x86_64 unknown linux-gnu)))
(inject 'gerbil-runtime-smp? (lambda () #f))
(inject 'delay-atomic (lambda (thunk) (delay (thunk))))
(inject 'call-with-input-string
  (lambda (str proc) (let ([p (open-input-string str)]) (proc p))))
(inject 'read-all
  (lambda (port . args)
    (let ([reader (if (pair? args) (car args) read)])
      (let lp ([result '()])
        (let ([form (reader port)])
          (if (eof-object? form) (reverse result) (lp (cons form result))))))))
(inject '|##eval| eval)
(inject '__compile-top (lambda (stx) stx))
(inject 'path-expand (lambda (p . b) (if (and (pair? b) (car b))
  (if (and (> (string-length p) 0) (char=? (string-ref p 0) #\/)) p
      (string-append (car b) "/" p)) p)))
(inject 'path-normalize (lambda (p . a) p))
(inject 'path-directory
  (lambda (p) (let ([i (string-rindex p #\/)]) (if i (substring p 0 (+ i 1)) "./"))))
(inject 'path-extension
  (lambda (p) (let ([i (string-rindex p #\.)]) (if (and i (> i 0)) (substring p i (string-length p)) ""))))
(inject 'path-strip-extension
  (lambda (p) (let ([i (string-rindex p #\.)]) (if (and i (> i 0)) (substring p 0 i) p))))
(inject 'path-strip-directory
  (lambda (p) (let ([i (string-rindex p #\/)]) (if i (substring p (+ i 1) (string-length p)) p))))
(inject 'path-strip-trailing-directory-separator
  (lambda (p) (let ([len (string-length p)]) (if (and (> len 1) (char=? (string-ref p (- len 1)) #\/))
    (substring p 0 (- len 1)) p))))
(inject 'current-directory (lambda args (if (null? args) (current-directory) (void))))

(define (string-contains h n)
  (let ([hl (string-length h)] [nl (string-length n)])
    (let lp ([i 0])
      (cond [(> (+ i nl) hl) #f]
            [(string=? (substring h i (+ i nl)) n) i]
            [else (lp (+ i 1))]))))

(guard (exn [#t
  (inject 'string-rindex (lambda (str ch)
    (let lp ([i (- (string-length str) 1)])
      (cond [(< i 0) #f] [(char=? (string-ref str i) ch) i] [else (lp (- i 1))]))))])
  (eval 'string-rindex))
(guard (exn [#t
  (inject 'string-index (lambda (str ch)
    (let lp ([i 0])
      (cond [(>= i (string-length str)) #f] [(char=? (string-ref str i) ch) i] [else (lp (+ i 1))]))))])
  (eval 'string-index))
(guard (exn [#t
  (inject 'reverse! (lambda (lst) (let lp ([l lst] [p '()])
    (if (null? l) p (let ([n (cdr l)]) (set-cdr! l p) (lp n l))))))])
  (eval 'reverse!))
(guard (exn [#t
  (inject 'make-list (lambda (n . fill)
    (let ([v (if (pair? fill) (car fill) #f)])
      (let lp ([i 0] [r '()]) (if (>= i n) r (lp (+ i 1) (cons v r)))))))])
  (eval 'make-list))

(inject 'list->hash-table-eq
  (lambda (alist)
    (let ([ht (make-hash-table-eq)])
      (let lp ([r alist])
        (when (pair? r)
          (when (pair? (car r)) (hash-put! ht (caar r) (cdar r)))
          (lp (cdr r)))) ht)))
(inject 'hash->list
  (lambda (ht)
    (let ([result '()])
      (hash-for-each (lambda (k v) (set! result (cons (cons k v) result))) ht)
      result)))
(inject 'keyword? |##keyword?|)
(inject 'keyword->string |##keyword->string|)
(guard (exn [#t (inject 'datum-parsing-exception? (lambda (x) #f))
                (inject 'datum-parsing-exception-filepos (lambda (x) 0))])
  (eval 'datum-parsing-exception?))
(guard (exn [#t (inject 'dump-stack-trace? (make-parameter #f))]) (eval 'dump-stack-trace?))
(guard (exn [#t (inject 'display-exception
  (lambda (exn . args) (let ([p (if (pair? args) (car args) (current-output-port))]) (display exn p))))])
  (eval 'display-exception))

;;; ============================================================
;;; Load expander
;;; ============================================================

(printf "~n=== Loading Expander ===~n")

(define expander-files
  '("common.ss" "stx.ss" "core.ss" "top.ss" "module.ss"
    "compile.ss" "root.ss" "stxcase.ss" "init.ss"))

(for-each
  (lambda (filename)
    (let ([forms (compile-file expander-src-dir filename)])
      (when (and forms (not (null? forms)))
        (let ([ok (load-file filename)])
          (when (and ok (string=? filename "root.ss"))
            (eval '(set! make-root-context
                     (lambda args
                       (let* ([type root-context::t]
                              [n (class-type-field-count type)]
                              [obj (apply |##structure| type (make-list n #f))])
                         (|##structure-set!| obj 1 'root)
                         (|##structure-set!| obj 2 (make-hash-table-eq))
                         (guard (exn [#t (void)])
                           (when (top-level-bound? '*core-syntax-expanders*)
                             (call-method obj 'bind-core-syntax-expanders!))
                           (when (top-level-bound? '*core-macro-expanders*)
                             (call-method obj 'bind-core-macro-expanders!)))
                         obj))))
            (eval '(set! make-top-context
                     (lambda args
                       (let* ([type top-context::t]
                              [n (class-type-field-count type)]
                              [obj (apply |##structure| type (make-list n #f))]
                              [super (if (pair? args) (car args) #f)]
                              [super (or super
                                         (guard (exn [#t #f]) (core-context-root))
                                         (make-root-context))])
                         (|##structure-set!| obj 1 'top)
                         (|##structure-set!| obj 2 (make-hash-table-eq))
                         (|##structure-set!| obj 3 super)
                         (|##structure-set!| obj 4 #f)
                         (|##structure-set!| obj 5 #f)
                         obj)))))))))
  expander-files)

(printf "  Expander loaded~n")

;;; ============================================================
;;; DIAGNOSTIC: Trace method dispatch
;;; ============================================================

(printf "~n=== Method Dispatch Diagnostics ===~n")

;; 1. Check if expander types exist
(printf "~n--- 1. Expander type existence ---~n")
(for-each
  (lambda (name)
    (guard (exn [#t (printf "  MISSING: ~a~n" name)])
      (let ([val (eval name)])
        (printf "  ~a = ~a (struct? ~a)~n" name
          (if (|##structure?| val) "gerbil-struct" (if (procedure? val) "procedure" val))
          (|##structure?| val)))))
  '(expander::t core-expander::t expression-form::t special-form::t
    definition-form::t top-special-form::t module-special-form::t
    macro-expander::t user-expander::t))

;; 2. Check class hierarchy (precedence lists)
(printf "~n--- 2. Precedence lists ---~n")
(for-each
  (lambda (name)
    (guard (exn [#t (printf "  ~a: ERROR ~a~n" name
      (if (message-condition? exn) (condition-message exn) exn))])
      (let ([type (eval name)])
        (when (|##structure?| type)
          (let ([plist (class-type-precedence-list type)])
            (printf "  ~a precedence: ~a~n" name
              (if (and plist (pair? plist))
                (map (lambda (t) (class-type-name t)) plist)
                plist)))))))
  '(expression-form::t core-expander::t expander::t special-form::t))

;; 3. Check methods tables
(printf "~n--- 3. Methods tables ---~n")
(for-each
  (lambda (name)
    (guard (exn [#t (printf "  ~a: ERROR ~a~n" name
      (if (message-condition? exn) (condition-message exn) exn))])
      (let ([type (eval name)])
        (when (|##structure?| type)
          (let ([methods (class-type-methods type)])
            (printf "  ~a methods: ~a~n" name
              (cond
                [(not methods) "#f (no methods table)"]
                [(procedure? methods) (format "procedure (~a)" methods)]
                [else
                 ;; Try to enumerate methods
                 (let ([result '()])
                   (guard (exn [#t (format "~a (can't enumerate)" methods)])
                     (saved-symbolic-table-for-each
                       (lambda (k v)
                         (set! result (cons (cons k (if (procedure? v) 'proc v)) result)))
                       methods)
                     (format "~a" result)))])))))))
  '(expander::t core-expander::t expression-form::t special-form::t
    macro-expander::t user-expander::t))

;; 4. Check if bind-method! was called (look for apply-macro-expander method)
(printf "~n--- 4. apply-macro-expander method lookup ---~n")
(for-each
  (lambda (name)
    (guard (exn [#t (printf "  ~a: ERROR ~a~n" name
      (if (message-condition? exn) (condition-message exn) exn))])
      (let ([type (eval name)])
        (when (|##structure?| type)
          (let ([methods (class-type-methods type)])
            (when methods
              (let ([m (saved-symbolic-table-ref methods 'apply-macro-expander #f)])
                (printf "  ~a: apply-macro-expander = ~a~n" name
                  (cond
                    [(not m) "#f (not found)"]
                    [(procedure? m) (format "procedure")]
                    [else (format "~a" m)])))))))))
  '(expander::t core-expander::t expression-form::t special-form::t
    macro-expander::t user-expander::t))

;; 5. Try direct method-ref
(printf "~n--- 5. method-ref on expression-form instance ---~n")
(guard (exn [#t
  (printf "  ERROR: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "  irritants: ~a~n" (condition-irritants exn)))])
  ;; Create an expression-form instance
  (let ([ef-type (eval 'expression-form::t)])
    (printf "  expression-form::t = ~a~n" ef-type)
    (printf "  is gerbil-struct? ~a~n" (|##structure?| ef-type))
    ;; Create an instance — expression-form extends core-expander extends expander
    ;; expander has 1 field (e), core-expander adds 2 (id, compile-top)
    (let ([instance (eval '(make-expression-form (lambda (stx) stx) 'test-id #f))])
      (printf "  instance = ~a~n" instance)
      (printf "  instance is gerbil-struct? ~a~n" (|##structure?| instance))
      (printf "  class-of instance = ~a~n" (eval `(class-of ',instance)))

      ;; Try method-ref
      (printf "  method-ref result: ~a~n"
        (eval `(method-ref ',instance 'apply-macro-expander)))

      ;; Try bound-method-ref
      (printf "  bound-method-ref result: ~a~n"
        (eval `(bound-method-ref ',instance 'apply-macro-expander))))))

;; 6. Trace core-expand-expression step by step
(printf "~n--- 6. Tracing core-expand-expression ---~n")

;; 6a. Check that core-expand-expression exists
(guard (exn [#t (printf "  core-expand-expression: MISSING (~a)~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([f (eval 'core-expand-expression)])
    (printf "  core-expand-expression = ~a (procedure? ~a)~n" f (procedure? f))))

;; 6b. Check core-syntax-case (used internally)
(guard (exn [#t (printf "  core-syntax-case: MISSING (~a)~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (printf "  core-syntax-case macro? ~a~n"
    (eval '(and (top-level-bound? 'core-syntax-case) "bound"))))

;; 6c. Check resolve-identifier and binding lookup for 'if
(printf "~n  Checking 'if binding resolution:~n")
(guard (exn [#t (printf "  resolve-identifier ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([stx (eval '(make-AST 'if #f))])
    (printf "  stx for 'if = ~a~n" stx)
    (let ([bind (eval `(resolve-identifier ',stx))])
      (printf "  resolve-identifier result = ~a~n" bind)
      (when bind
        (printf "  binding? ~a~n" (eval `(binding? ',bind)))
        (printf "  core-expander-binding? ~a~n"
          (eval `(core-expander-binding? ',bind)))
        (printf "  syntax-binding? ~a~n"
          (eval `(syntax-binding? ',bind)))
        (printf "  runtime-binding? ~a~n"
          (eval `(runtime-binding? ',bind)))
        ;; Get the expander stored in the binding
        (guard (exn [#t (printf "  &syntax-binding-e ERROR: ~a~n"
          (if (message-condition? exn) (condition-message exn) exn))])
          (let ([e (eval `(&syntax-binding-e ',bind))])
            (printf "  &syntax-binding-e = ~a~n" e)
            (printf "  is procedure? ~a~n" (procedure? e))
            (printf "  is gerbil-struct? ~a~n" (|##structure?| e))
            (when (|##structure?| e)
              (printf "  class-of = ~a~n" (eval `(class-of ',e)))
              (printf "  class name = ~a~n"
                (eval `(class-type-name (class-of ',e)))))))))))

;; 6d. Check core-apply-expander directly
(printf "~n  Testing core-apply-expander:~n")
(guard (exn [#t (printf "  core-apply-expander ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "  irritants: ~a~n" (condition-irritants exn)))])
  (let ([stx (eval '(make-AST '(if #t 1 2) #f))])
    (let ([bind (eval `(resolve-identifier (make-AST 'if #f)))])
      (when bind
        (let ([K (eval `(&syntax-binding-e ',bind))])
          (printf "  K = ~a~n" K)
          (printf "  calling core-apply-expander...~n")
          (let ([result (eval `(core-apply-expander ',K ',stx))])
            (printf "  core-apply-expander result = ~a~n" result)))))))

;; 6e. Check root context and core bindings
(printf "~n  Checking root context and core bindings:~n")
(guard (exn [#t (printf "  ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([root (eval '(core-context-root))])
    (printf "  core-context-root = ~a~n" root)
    (printf "  is gerbil-struct? ~a~n" (|##structure?| root))
    (when (|##structure?| root)
      (printf "  class-of = ~a~n" (eval `(class-type-name (class-of ',root))))
      ;; Check the table field (field 2 for root-context)
      (let ([tbl (|##structure-ref| root 2)])
        (printf "  context table = ~a~n" tbl)
        (printf "  table type = ~a~n" (if (hashtable? tbl) "chez-hashtable"
                                          (if (|##structure?| tbl) "gerbil-struct" tbl)))
        ;; Try to look up 'if in the context table
        (guard (exn [#t (printf "  lookup 'if ERROR: ~a~n"
          (if (message-condition? exn) (condition-message exn) exn))])
          (printf "  lookup 'if in table = ~a~n"
            (if (hashtable? tbl)
              (hashtable-ref tbl 'if #f)
              "not a chez hashtable")))))))

;; 6f. Check current-expander-context
(printf "~n  Checking current-expander-context:~n")
(guard (exn [#t (printf "  ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (printf "  current-expander-context = ~a~n"
    (eval '(current-expander-context)))
  (let ([ctx (eval '(current-expander-context))])
    (when (|##structure?| ctx)
      (printf "  class = ~a~n" (eval `(class-type-name (class-of ',ctx))))
      ;; Check table
      (let ([tbl (|##structure-ref| ctx 2)])
        (printf "  context table = ~a~n" tbl)
        (when (hashtable? tbl)
          (let ([keys (vector->list (hashtable-keys tbl))])
            (printf "  table has ~a entries~n" (length keys))
            (printf "  first 10 keys: ~a~n" (list-head keys (min 10 (length keys))))))))))

;; 6f2. Check if bindings were registered in root context
(printf "~n  Checking root context bindings:~n")
(guard (exn [#t (printf "  ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([root (eval '(core-context-root))])
    (let ([tbl (eval `(&expander-context-table ',root))])
      (printf "  &expander-context-table = ~a~n" tbl)
      ;; Try hash-get on this table for 'if
      (let ([if-bind (eval `(hash-get ',tbl 'if))])
        (printf "  hash-get tbl 'if = ~a~n" if-bind))
      ;; Try hash-get for |%#if|
      (let ([if-bind (eval `(hash-get ',tbl '|%#if|))])
        (printf "  hash-get tbl '%%#if = ~a~n" if-bind))
      ;; Try to get the hash count
      (let ([cnt (eval `(hash-length ',tbl))])
        (printf "  hash-length = ~a~n" cnt))
      ;; Manually try bind-core-syntax-expanders! and check error
      (printf "~n  Manually calling {bind-core-syntax-expanders!}:~n")
      (guard (exn [#t (printf "  bind-core-syntax-expanders! ERROR: ~a~n"
        (if (message-condition? exn) (condition-message exn) exn))
        (when (irritants-condition? exn)
          (printf "  irritants: ~a~n" (condition-irritants exn)))])
        (eval `({bind-core-syntax-expanders! ',root}))
        (printf "  bind-core-syntax-expanders! SUCCESS~n")
        ;; Now check again
        (let ([if-bind (eval `(hash-get ',tbl 'if))])
          (printf "  hash-get tbl 'if after bind = ~a~n" if-bind))
        (let ([cnt (eval `(hash-length ',tbl))])
          (printf "  hash-length after bind = ~a~n" cnt))))))

;; 6g. Check *core-syntax-expanders* and *core-macro-expanders*
(printf "~n  Checking core expander tables:~n")
(guard (exn [#t (printf "  *core-syntax-expanders* ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([tbl (eval '*core-syntax-expanders*)])
    (printf "  *core-syntax-expanders* = ~a (length ~a)~n"
      (if (pair? tbl) "list" tbl)
      (if (pair? tbl) (length tbl) "N/A"))
    (when (pair? tbl)
      (printf "  first 5: ~a~n" (map car (list-head tbl (min 5 (length tbl))))))))
(guard (exn [#t (printf "  *core-macro-expanders* ERROR: ~a~n"
  (if (message-condition? exn) (condition-message exn) exn))])
  (let ([tbl (eval '*core-macro-expanders*)])
    (printf "  *core-macro-expanders* = ~a (length ~a)~n"
      (if (pair? tbl) "list" tbl)
      (if (pair? tbl) (length tbl) "N/A"))
    (when (pair? tbl)
      (printf "  first 5: ~a~n" (map car (list-head tbl (min 5 (length tbl))))))))

;; 6h. Try the full core-expand-expression step by step
(printf "~n  Testing core-expand-expression:~n")

;; First try core-expand1 which is simpler
(printf "  Testing core-expand1:~n")
(guard (exn [#t
  (printf "  core-expand1 ERROR: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "  irritants: ~a~n" (condition-irritants exn)))])
  (let ([result (eval '(core-expand1 (make-AST '(if #t 1 2) #f)))])
    (printf "  core-expand1 result = ~a~n" result)))

;; Try expanding a simple literal (no head to resolve)
(printf "  Testing core-expand-expression on literal:~n")
(guard (exn [#t
  (printf "  literal ERROR: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "  irritants: ~a~n" (condition-irritants exn)))])
  (let ([result (eval '(core-expand-expression (make-AST '42 #f)))])
    (printf "  literal expand = ~a~n" result)))

;; Try the if form
(printf "  Testing core-expand-expression on (if #t 1 2):~n")
(guard (exn [#t
  (printf "  core-expand-expression ERROR: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "  irritants: ~a~n" (condition-irritants exn)))
  (when (condition? exn)
    (printf "  full condition: ~a~n" exn))])
  (let ([result (eval '(core-expand-expression (make-AST '(if #t 1 2) #f)))])
    (printf "  SUCCESS: ~a~n" result)))

(printf "~n=== Done ===~n")
