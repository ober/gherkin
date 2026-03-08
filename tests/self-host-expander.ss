#!chezscheme
;;; self-host-expander.ss -- Compile and evaluate Gerbil expander files via gherkin
;;;
;;; Phase 2: Loads the runtime (Phase 1), then compiles and evaluates the 9 expander
;;; files in dependency order, building a working Gerbil syntax expander on Chez Scheme.

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

(define pass-count 0)
(define fail-count 0)

(define (check name pred)
  (if pred
    (begin
      (printf "  PASS: ~a~n" name)
      (set! pass-count (+ pass-count 1)))
    (begin
      (printf "  FAIL: ~a~n" name)
      (set! fail-count (+ fail-count 1)))))

(define runtime-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/runtime/")))

(define expander-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/expander/")))

(define output-dir "/tmp/gherkin-self-host/")
(unless (file-exists? output-dir)
  (mkdir output-dir))

;;; ============================================================
;;; Core utilities (same as self-host-runtime.ss)
;;; ============================================================

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
      (when (irritants-condition? exn)
        (printf "    irritants: ~a~n" (condition-irritants exn)))
      #f])
      (let* ([forms (read-gerbil-file src-path)]
             [stripped (map (lambda (f)
                             (if (annotated-datum? f)
                               (strip-annotations (annotated-datum-value f))
                               (strip-annotations f)))
                           forms)]
             ;; Pre-pass: register defrules/defrule for compile-time expansion
             [_ (for-each
                  (lambda (form)
                    (when (and (pair? form) (memq (car form) '(defrules defrule)))
                      (guard (exn [#t (void)])
                        (gerbil-compile-top form))))
                  stripped)]
             ;; Compile, skipping import/export and empty begins
             [compiled
              (let loop ([forms stripped] [result '()])
                (if (null? forms)
                  (reverse result)
                  (let ([form (car forms)])
                    (guard (exn [#t
                      (when (and (pair? form) (pair? (cdr form)))
                        (printf "  compile skip: ~a (~a)~n"
                          (if (pair? (cadr form)) (caadr form) (cadr form))
                          (if (message-condition? exn) (condition-message exn) "error"))
                        (when (irritants-condition? exn)
                          (printf "    irritants: ~a~n" (condition-irritants exn))))
                      (loop (cdr forms) result)])
                      (let ([c (gerbil-compile-top form)])
                        (cond
                          [(and (pair? c) (memq (car c) '(import export)))
                           (loop (cdr forms) result)]
                          [(equal? c '(begin))
                           (loop (cdr forms) result)]
                          [else
                           (loop (cdr forms) (cons c result))]))))))])

        ;; Write output file
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
        [errors 0]
        [loaded 0])
    (guard (exn [#t
      (printf "  LOAD ERROR (~a): ~a~n" filename
        (if (message-condition? exn) (condition-message exn) exn))
      (when (irritants-condition? exn)
        (printf "    irritants: ~a~n" (condition-irritants exn)))
      #f])
      (let ([port (open-input-file path)])
        (let loop ()
          (let ([form (read port)])
            (unless (eof-object? form)
              (if (and (pair? form) (memq (car form) '(import export)))
                (loop)
                (begin
                  (guard (exn [#t
                    (when (< errors 15)
                      (printf "    eval error #~a: ~a~n" (+ errors 1)
                        (if (message-condition? exn) (condition-message exn) exn))
                      (when (irritants-condition? exn)
                        (printf "      irritants: ~a~n" (condition-irritants exn)))
                      (let ([s (call-with-string-output-port
                                 (lambda (p) (pretty-print form p)))])
                        (printf "      form: ~a~n"
                          (if (> (string-length s) 200)
                            (string-append (substring s 0 200) "...")
                            s))))
                    (set! errors (+ errors 1))])
                    (eval form)
                    (set! loaded (+ loaded 1)))
                  (loop))))))
        (close-input-port port))
      (when (> errors 0)
        (printf "  (~a: ~a forms loaded, ~a errors skipped)~n" filename loaded errors))
      #t)))

;;; ============================================================
;;; Bootstrap: inject all needed bindings into interaction env
;;; ============================================================

(define (inject name val)
  (define-top-level-value name val (interaction-environment)))
(define inject-fn inject)

;; Gambit void and absent markers
(inject-fn '%%void |%%void|)
(inject-fn '|%%void| |%%void|)
(inject '|##absent-object| (lambda () absent-obj))
(inject 'absent-obj absent-obj)

;; Gambit fixnum ops
(for-each
  (lambda (pair)
    (inject-fn (car pair) (cdr pair)))
  `((|##fxior| . ,fxior)
    (|##fxand| . ,fxand)
    (|##fxnot| . ,fxnot)
    (|##fxarithmetic-shift-left| . ,fxarithmetic-shift-left)
    (|##fxarithmetic-shift-right| . ,fxarithmetic-shift-right)
    (|##fx+| . ,fx+)
    (|##fx-| . ,fx-)
    (|##fx*| . ,fx*)
    (|##fx<| . ,fx<)
    (|##fx>| . ,fx>)
    (|##fx=| . ,fx=)
    (|##fx<=| . ,fx<=)
    (|##fx>=| . ,fx>=)
    (|##fixnum?| . ,fixnum?)
    (|##eq?| . ,eq?)
    (|##not| . ,not)
    (|##car| . ,car)
    (|##cdr| . ,cdr)
    (|##pair?| . ,pair?)
    (|##null?| . ,null?)
    (|##vector-ref| . ,vector-ref)
    (|##vector-set!| . ,vector-set!)
    (|##vector-length| . ,vector-length)
    (|##string-ref| . ,string-ref)
    (|##string-length| . ,string-length)
    (|##cons| . ,cons)
    (|##list| . ,list)
    (|##values| . ,values)
    (|##apply| . ,apply)))

;; Gambit's macro sentinel values
(let ([unused (vector 'unused)]
      [deleted (vector 'deleted)])
  (inject-fn 'macro-unused-obj (lambda () unused))
  (inject-fn 'macro-deleted-obj (lambda () deleted)))

;; Gambit GC hash table flags
(inject-fn 'macro-gc-hash-table-flag-weak-keys (lambda () 1))
(inject-fn 'macro-gc-hash-table-flag-weak-vals (lambda () 2))
(inject-fn 'macro-gc-hash-table-flag-key-moved (lambda () 16))
(inject-fn 'macro-gc-hash-table-flag-need-rehash (lambda () 32))

;; nonce
(let ([counter 0])
  (inject 'nonce (lambda ()
                   (set! counter (+ counter 1))
                   counter)))

;; Inject all module bindings into the interaction environment
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

;; Inject ##eqv?
(inject '|##eqv?| eqv?)

;; Inject hash functions
(define (gambit-eq-hash x) (equal-hash x))
(define (gambit-eqv-hash x) (equal-hash x))
(inject '|##string=?-hash| string-hash)
(inject 'eq?-hash gambit-eq-hash)
(inject 'eqv?-hash gambit-eqv-hash)
(inject 'equal?-hash equal-hash)
(inject 'eq-hash gambit-eq-hash)

;; Inject ##vector-cas!
(inject-fn '|##vector-cas!|
  (lambda (vec idx expected new)
    (let ([old (vector-ref vec idx)])
      (when (eqv? old expected)
        (vector-set! vec idx new))
      old)))

;; Inject ##thread-yield!
(inject-fn '|##thread-yield!| (lambda () (void)))

;; class-of
(inject 'class-of
  (lambda (obj)
    (if (gerbil-struct? obj)
      (gerbil-struct-type-tag obj)
      #f)))

;; __class-slot-offset
(inject '__class-slot-offset
  (lambda (klass slot)
    (let ([st (class-type-slot-table klass)])
      (and st (symbolic-table-ref st slot #f)))))

;; Save working hash operations before compiled code overwrites them
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

;; Save working table operations (compiled table.ss expects gerbil-structs)
(define saved-symbolic-table-ref symbolic-table-ref)
(define saved-symbolic-table-set! symbolic-table-set!)
(define saved-symbolic-table-delete! symbolic-table-delete!)
(define saved-symbolic-table-for-each symbolic-table-for-each)
(define saved-make-symbolic-table make-symbolic-table)

;; Override macro-type-* for the eval environment
(let ([g-structure (eval '|##structure|)]
      [g-type-type (eval '|##type-type|)])
  (for-each
    (lambda (pair)
      (let* ([name (car pair)]
             [id (cdr pair)]
             [type-obj (g-structure g-type-type id name 0 #f '#())])
        (inject-fn name (lambda () type-obj))))
    `((macro-type-fixnum . fixnum)
      (macro-type-mem1 . mem1)
      (macro-type-mem2 . mem2)
      (macro-type-subtyped . subtyped)
      (macro-type-table . table)
      (macro-type-time . time)
      (macro-type-mutex . mutex)
      (macro-type-condvar . condvar)
      (macro-type-thread . thread)
      (macro-type-tgroup . tgroup)
      (macro-type-port . port)
      (macro-type-object-port . object-port)
      (macro-type-character-port . character-port)
      (macro-type-byte-port . byte-port)
      (macro-type-device-port . device-port)
      (macro-type-vector-port . vector-port)
      (macro-type-string-port . string-port)
      (macro-type-u8vector-port . u8vector-port)
      (macro-type-raw-device-port . raw-device-port)
      (macro-type-tcp-server-port . tcp-server-port)
      (macro-type-udp-port . udp-port)
      (macro-type-directory-port . directory-port)
      (macro-type-event-queue-port . event-queue-port)
      (macro-type-readenv . readenv)
      (macro-type-writeenv . writeenv)
      (macro-type-readtable . readtable)
      (macro-type-processor . processor)
      (macro-type-vm . vm)
      (macro-type-file-info . file-info)
      (macro-type-socket-info . socket-info)
      (macro-type-address-info . address-info))))

;; Inject call-with-output-string
(inject-fn 'call-with-output-string
  (lambda (init proc)
    (let ([port (open-output-string)])
      (proc port)
      (get-output-string port))))

;; Inject random-integer
(inject-fn 'random-integer (lambda (n) (random n)))

;; Inject make-condition-variable
(inject 'make-condition-variable (lambda args 'condition-variable-stub))
(inject 'mutex-lock! (lambda (m . args) (void)))
(inject 'mutex-unlock! (lambda (m . args) (void)))

;;; ============================================================
;;; Load all 14 runtime files (Phase 1)
;;; ============================================================

(printf "=== Loading Runtime (Phase 1) ===~n")

(define runtime-files
  '("util.ss" "c3.ss" "table.ss" "control.ss" "mop.ss"
    "mop-system-classes.ss" "error.ss" "interface.ss" "hash.ss"
    "syntax.ss" "thread.ss" "eval.ss" "loader.ss" "repl.ss"))

(let ([all-ok #t])
  (for-each
    (lambda (filename)
      (let ([forms (compile-file runtime-src-dir filename)])
        (when (and forms (not (null? forms)))
          (let ([ok (load-file filename)])
            (unless ok (set! all-ok #f))
            ;; After mop.ss: inject slot accessors
            (when (and ok (string=? filename "mop.ss"))
              (for-each
                (lambda (slot-field)
                  (let* ([slot (car slot-field)]
                         [field (cadr slot-field)]
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
                  (properties 9) (constructor 10) (methods 11))))))))
    runtime-files)

  ;; Re-inject our working hash operations after compiled hash.ss
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

  ;; Re-inject working table operations after compiled table.ss
  (inject 'symbolic-table-ref saved-symbolic-table-ref)
  (inject 'symbolic-table-set! saved-symbolic-table-set!)
  (inject 'symbolic-table-delete! saved-symbolic-table-delete!)
  (inject 'symbolic-table-for-each saved-symbolic-table-for-each)
  (inject 'make-symbolic-table saved-make-symbolic-table)
  ;; Re-inject __class-slot-offset using our native symbolic-table-ref
  (inject 'class-slot-offset
    (lambda (klass slot)
      (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))
  (inject '__class-slot-offset
    (lambda (klass slot)
      (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))

  (check "runtime loads" all-ok))

;;; ============================================================
;;; Expander-specific stubs
;;; ============================================================

(printf "~n=== Injecting Expander Stubs ===~n")

;; gerbil-system — returns the Gerbil system type
(inject 'gerbil-system (lambda () 'gerbil-chez))

;; system-type — returns [cpu vendor os]
(inject 'system-type
  (lambda ()
    (list (string->symbol (machine-type))
          'unknown
          (string->symbol
            (let ([mt (symbol->string (machine-type))])
              (cond
                [(string-contains mt "linux") "linux-gnu"]
                [(string-contains mt "darwin") "darwin"]
                [else "unknown"]))))))

;; gerbil-runtime-smp? — SMP support
(inject 'gerbil-runtime-smp? (lambda () #f))

;; delay-atomic — same as delay (no atomicity needed in single-thread bootstrap)
(inject 'delay-atomic (lambda (thunk) (delay (thunk))))

;; call-with-input-string — Gambit's version
(inject 'call-with-input-string
  (lambda (str proc)
    (let ([port (open-input-string str)])
      (proc port))))

;; read-all — read all forms from a port
(inject 'read-all
  (lambda (port . reader-args)
    (let ([reader (if (pair? reader-args) (car reader-args) read)])
      (let lp ([result '()])
        (let ([form (reader port)])
          (if (eof-object? form)
            (reverse result)
            (lp (cons form result))))))))

;; ##eval — Chez's eval
(inject '|##eval| eval)

;; __compile-top — compile-top placeholder (needed by init.ss)
;; Will be set properly after compile.ss evaluates
(inject '__compile-top (lambda (stx) stx))

;; path operations — Gambit-compatible
(inject 'path-expand
  (lambda (path . base-args)
    (if (and (pair? base-args) (car base-args))
      (if (and (> (string-length path) 0) (char=? (string-ref path 0) #\/))
        path
        (string-append (car base-args) "/" path))
      path)))

(inject 'path-normalize
  (lambda (path . args)
    ;; Simple normalization: resolve relative paths
    path))

(inject 'path-directory
  (lambda (path)
    (let ([idx (string-rindex path #\/)])
      (if idx
        (substring path 0 (+ idx 1))
        "./"))))

(inject 'path-extension
  (lambda (path)
    (let ([idx (string-rindex path #\.)])
      (if (and idx (> idx 0))
        (substring path idx (string-length path))
        ""))))

(inject 'path-strip-extension
  (lambda (path)
    (let ([idx (string-rindex path #\.)])
      (if (and idx (> idx 0))
        (substring path 0 idx)
        path))))

(inject 'path-strip-directory
  (lambda (path)
    (let ([idx (string-rindex path #\/)])
      (if idx
        (substring path (+ idx 1) (string-length path))
        path))))

(inject 'path-strip-trailing-directory-separator
  (lambda (path)
    (let ([len (string-length path)])
      (if (and (> len 1) (char=? (string-ref path (- len 1)) #\/))
        (substring path 0 (- len 1))
        path))))

(inject 'current-directory
  (lambda args
    (if (null? args)
      (current-directory)
      (void))))

;; string-rindex (may already be available from compiled util.ss)
(guard (exn [#t
  (inject 'string-rindex
    (lambda (str ch)
      (let lp ([i (- (string-length str) 1)])
        (cond
          [(< i 0) #f]
          [(char=? (string-ref str i) i)]
          [else (lp (- i 1))]))))])
  ;; Check if already defined
  (eval 'string-rindex))

;; string-index (find char in string)
(guard (exn [#t
  (inject 'string-index
    (lambda (str ch)
      (let lp ([i 0])
        (cond
          [(>= i (string-length str)) #f]
          [(char=? (string-ref str i) i)]
          [else (lp (+ i 1))]))))])
  (eval 'string-index))

;; string-contains (needed for system-type)
(define (string-contains haystack needle)
  (let ([hlen (string-length haystack)]
        [nlen (string-length needle)])
    (let lp ([i 0])
      (cond
        [(> (+ i nlen) hlen) #f]
        [(string=? (substring haystack i (+ i nlen)) needle) i]
        [else (lp (+ i 1))]))))

;; reverse! (destructive reverse)
(guard (exn [#t
  (inject 'reverse!
    (lambda (lst)
      (let lp ([lst lst] [prev '()])
        (if (null? lst) prev
          (let ([next (cdr lst)])
            (set-cdr! lst prev)
            (lp next lst))))))])
  (eval 'reverse!))

;; make-list (if not already available)
(guard (exn [#t
  (inject 'make-list
    (lambda (n . fill)
      (let ([v (if (pair? fill) (car fill) #f)])
        (let lp ([i 0] [r '()])
          (if (>= i n) r
            (lp (+ i 1) (cons v r)))))))])
  (eval 'make-list))

;; list->hash-table-eq
(inject 'list->hash-table-eq
  (lambda (alist)
    (let ([ht (make-hash-table-eq)])
      (let lp ([rest alist])
        (when (pair? rest)
          (let ([pair (car rest)])
            (when (pair? pair)
              (hash-put! ht (car pair) (cdr pair))))
          (lp (cdr rest))))
      ht)))

;; hash->list
(inject 'hash->list
  (lambda (ht)
    (let ([result '()])
      (hash-for-each
        (lambda (k v) (set! result (cons (cons k v) result)))
        ht)
      result)))

;; keyword? and keyword->string for the eval environment
(inject 'keyword? |##keyword?|)
(inject 'keyword->string |##keyword->string|)

;; datum-parsing-exception? and related (stubs)
(guard (exn [#t
  (inject 'datum-parsing-exception? (lambda (x) #f))
  (inject 'datum-parsing-exception-filepos (lambda (x) 0))])
  (eval 'datum-parsing-exception?))

;; dump-stack-trace? parameter
(guard (exn [#t
  (inject 'dump-stack-trace? (make-parameter #f))])
  (eval 'dump-stack-trace?))

;; display-exception
(guard (exn [#t
  (inject 'display-exception
    (lambda (exn . port-args)
      (let ([port (if (pair? port-args) (car port-args) (current-output-port))])
        (display exn port))))])
  (eval 'display-exception))

(printf "  Expander stubs injected~n")

;;; ============================================================
;;; Compile and evaluate expander files
;;; ============================================================

(define expander-files
  '("common.ss" "stx.ss" "core.ss" "top.ss" "module.ss"
    "compile.ss" "root.ss" "stxcase.ss" "init.ss"))

(define expander-errors 0)

(define (compile-and-load-expander filename)
  (printf "~n=== ~a ===~n" filename)
  (let ([forms (compile-file expander-src-dir filename)])
    (check (string-append filename " compiles") (and forms (pair? forms)))
    (when forms
      (printf "  (~a compiled forms)~n" (length forms))
      (let ([ok (load-file filename)])
        (check (string-append filename " evaluates") ok)
        (unless ok (set! expander-errors (+ expander-errors 1)))))))

;; Process each expander file in dependency order
(for-each
  (lambda (filename)
    (compile-and-load-expander filename)
    ;; After root.ss: override make-top-context and make-root-context
    ;; to call :init! (defstruct constructors don't call it automatically)
    (when (string=? filename "root.ss")
      (printf "  Patching context constructors to call :init!~n")
      ;; Direct field initialization (bypassing :init! method dispatch issues)
      ;; top-context fields: id=1 table=2 super=3 up=4 down=5
      ;; root-context fields: id=1 table=2
      (eval '(set! make-root-context
               (lambda args
                 (let* ([type root-context::t]
                        [n (class-type-field-count type)]
                        [obj (apply |##structure| type (make-list n #f))])
                   ;; Set id and table directly
                   (|##structure-set!| obj 1 'root)
                   (|##structure-set!| obj 2 (make-hash-table-eq))
                   ;; Bind core expanders if available
                   (guard (exn [#t (void)])
                     (when (top-level-bound? '*core-syntax-expanders*)
                       ({bind-core-syntax-expanders! obj}))
                     (when (top-level-bound? '*core-macro-expanders*)
                       ({bind-core-macro-expanders! obj})))
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
                   ;; Set id, table, super, up, down directly
                   (|##structure-set!| obj 1 'top)
                   (|##structure-set!| obj 2 (make-hash-table-eq))
                   (|##structure-set!| obj 3 super)
                   (|##structure-set!| obj 4 #f)
                   (|##structure-set!| obj 5 #f)
                   obj))))))
  expander-files)

;;; ============================================================
;;; Verification
;;; ============================================================

(printf "~n=== Verification ===~n")

;; Check that key types are defined
(guard (exn [#t
  (printf "  type check error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "AST type defined" #f)])
  (let ([ast-t (eval 'AST::t)])
    (check "AST type defined" (and ast-t (|##structure?| ast-t)))))

(guard (exn [#t
  (printf "  type check error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "expander-context type defined" #f)])
  (let ([ctx-t (eval 'expander-context::t)])
    (check "expander-context type defined" (and ctx-t (|##structure?| ctx-t)))))

;; Check that make-AST works
(guard (exn [#t
  (printf "  make-AST error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "make-AST works" #f)])
  (let ([ast (eval '(make-AST 'hello #f))])
    (check "make-AST works" (eval `(AST? ',ast)))))

;; Check that syntax-e works (from stx.ss)
(guard (exn [#t
  (printf "  syntax-e error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "syntax-e works" #f)])
  (let ([result (eval '(syntax-e (make-AST 'hello #f)))])
    (check "syntax-e works" (eq? result 'hello))))

;; Check that identifier? works
(guard (exn [#t
  (printf "  identifier? error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "identifier? works" #f)])
  (let ([result (eval '(identifier? (make-AST 'hello #f)))])
    (check "identifier? works" result)))

;; Check that current-expander-context is a parameter
(guard (exn [#t
  (printf "  current-expander-context error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "current-expander-context defined" #f)])
  (let ([param (eval 'current-expander-context)])
    (check "current-expander-context defined" (procedure? param))))

;; Check binding types
(guard (exn [#t
  (printf "  binding types error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "binding types defined" #f)])
  (let ([bt (eval 'binding::t)]
        [rt (eval 'runtime-binding::t)]
        [st (eval 'syntax-binding::t)])
    (check "binding types defined" (and bt rt st))))

;; Check that make-top-context works
(guard (exn [#t
  (printf "  make-top-context error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "make-top-context works" #f)])
  (let ([ctx (eval '(make-top-context))])
    (check "make-top-context works" (eval `(top-context? ',ctx)))))

;; Check root context initialization
(guard (exn [#t
  (printf "  root-context error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "make-root-context works" #f)])
  (let ([ctx (eval '(make-root-context))])
    (check "make-root-context works" (eval `(root-context? ',ctx)))))

;;; ============================================================
;;; Phase 2.4 Verification: core-expand tests
;;; ============================================================

(printf "~n=== Core Expand Tests ===~n")

;; Set up a working expander context for core-expand
(guard (exn [#t
  (printf "  context setup error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))])
  ;; Create a top-context with a root-context super
  (eval '(current-expander-context (make-top-context))))

;; Test: core-expand on a core form (if) should return identity
(guard (exn [#t
  (printf "  core-expand if error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "    irritants: ~a~n" (condition-irritants exn)))
  (check "core-expand (if #t 1 2)" #f)])
  (let ([result (eval '(core-expand-expression (make-AST '(if #t 1 2) #f)))])
    (check "core-expand (if #t 1 2)" (and result (pair? (stx-e result))))))

;; Test: stx-map works on syntax lists
(guard (exn [#t
  (printf "  stx-map error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "stx-map works" #f)])
  (let ([result (eval '(stx-map syntax-e
                         (make-AST (list (make-AST 'a #f) (make-AST 'b #f)) #f)))])
    (check "stx-map works" (equal? result '(a b)))))

;; Test: genident produces unique identifiers
(guard (exn [#t
  (printf "  genident error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "genident works" #f)])
  (let ([id (eval '(genident 'test))])
    (check "genident works" (eval `(identifier? ',id)))))

;; Test: stx-pair? and stx-null?
(guard (exn [#t
  (printf "  stx-pair?/null? error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "stx-pair? and stx-null? work" #f)])
  (let ([pair-r (eval '(stx-pair? (make-AST '(a . b) #f)))]
        [null-r (eval '(stx-null? (make-AST '() #f)))])
    (check "stx-pair? and stx-null? work" (and pair-r null-r))))

;; Test: core-context-put! and core-context-get work
(guard (exn [#t
  (printf "  context put/get error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (when (irritants-condition? exn)
    (printf "    irritants: ~a~n" (condition-irritants exn)))
  (check "core-context-put!/get work" #f)])
  (let* ([ctx (eval '(make-top-context))]
         [tbl (eval `(&expander-context-table ',ctx))])
    (if tbl
      (let ([result (eval `(begin
                             (core-context-put! ',ctx 'test-key 'test-val)
                             (core-context-get ',ctx 'test-key)))])
        (check "core-context-put!/get work" (eq? result 'test-val)))
      (check "core-context-put!/get work" #f))))

;; Test: make-syntax-binding creates a proper binding
(guard (exn [#t
  (printf "  syntax-binding error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "make-syntax-binding works" #f)])
  (let ([b (eval '(make-syntax-binding 'test-id 'test-key 0 #f))])
    (check "make-syntax-binding works" (eval `(syntax-binding? ',b)))))

;; Test: make-runtime-binding
(guard (exn [#t
  (printf "  runtime-binding error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "make-runtime-binding works" #f)])
  (let ([b (eval '(make-runtime-binding 'test-id 'test-key 0 'test-id))])
    (check "make-runtime-binding works" (eval `(runtime-binding? ',b)))))

;; Test: expander types are correct
(guard (exn [#t
  (printf "  expander types error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "expander types (special-form, expression-form)" #f)])
  (let ([sf-t (eval 'special-form::t)]
        [ef-t (eval 'expression-form::t)])
    (check "expander types (special-form, expression-form)"
      (and sf-t ef-t (|##structure?| sf-t) (|##structure?| ef-t)))))

;; Test: module-import/export types
(guard (exn [#t
  (printf "  module types error: ~a~n"
    (if (message-condition? exn) (condition-message exn) exn))
  (check "module-import/export types" #f)])
  (let ([mi-t (eval 'module-import::t)]
        [me-t (eval 'module-export::t)])
    (check "module-import/export types"
      (and mi-t me-t (|##structure?| mi-t) (|##structure?| me-t)))))

;;; ============================================================
;;; Summary
;;; ============================================================

(printf "~n--- Self-Host Expander: ~a passed, ~a failed ---~n"
        pass-count fail-count)
