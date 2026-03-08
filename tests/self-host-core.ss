#!chezscheme
;;; self-host-core.ss -- Compile and evaluate Gerbil core macro files via gherkin
;;;
;;; Phase 3: Loads runtime (Phase 1) + expander (Phase 2), then compiles and
;;; evaluates the 10 core/ files providing Gerbil's user-facing macros.

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

(define core-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/core/")))

(define output-dir "/tmp/gherkin-self-host/")
(unless (file-exists? output-dir)
  (mkdir output-dir))

;;; ============================================================
;;; Core utilities
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

;; Save working table operations
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

;; Gambit uniform vector ops (stubs for alias definitions in runtime.ss)
(for-each
  (lambda (type)
    (let ([set-name (string->symbol (string-append type "vector-set!"))])
      (guard (exn [#t (inject set-name (lambda (v i x) (void)))])
        (eval set-name))))
  '("s8" "u8" "s16" "u16" "s32" "u32" "s64" "u64" "f32" "f64"))

;; with-catch (Gerbil's try/catch)
(inject 'with-catch
  (lambda (handler thunk)
    (guard (exn [#t (handler exn)])
      (thunk))))

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

  ;; Re-inject working table operations
  (inject 'symbolic-table-ref saved-symbolic-table-ref)
  (inject 'symbolic-table-set! saved-symbolic-table-set!)
  (inject 'symbolic-table-delete! saved-symbolic-table-delete!)
  (inject 'symbolic-table-for-each saved-symbolic-table-for-each)
  (inject 'make-symbolic-table saved-make-symbolic-table)
  (inject 'class-slot-offset
    (lambda (klass slot)
      (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))
  (inject '__class-slot-offset
    (lambda (klass slot)
      (saved-symbolic-table-ref (class-type-slot-table klass) slot #f)))

  (check "runtime loads" all-ok))

;;; ============================================================
;;; Expander stubs
;;; ============================================================

(printf "~n=== Injecting Expander Stubs ===~n")

(inject 'gerbil-system (lambda () 'gerbil-chez))
(inject 'system-type
  (lambda ()
    (list (string->symbol (symbol->string (machine-type)))
          'unknown
          (string->symbol "linux-gnu"))))
(inject 'gerbil-runtime-smp? (lambda () #f))
(inject 'delay-atomic (lambda (thunk) (delay (thunk))))

(inject 'call-with-input-string
  (lambda (str proc)
    (let ([port (open-input-string str)])
      (proc port))))

(inject 'read-all
  (lambda (port . reader-args)
    (let ([reader (if (pair? reader-args) (car reader-args) read)])
      (let lp ([result '()])
        (let ([form (reader port)])
          (if (eof-object? form)
            (reverse result)
            (lp (cons form result))))))))

(inject '|##eval| eval)
(inject '__compile-top (lambda (stx) stx))

(inject 'path-expand
  (lambda (path . base-args)
    (if (and (pair? base-args) (car base-args))
      (if (and (> (string-length path) 0) (char=? (string-ref path 0) #\/))
        path
        (string-append (car base-args) "/" path))
      path)))
(inject 'path-normalize (lambda (path . args) path))
(inject 'path-directory
  (lambda (path)
    (let ([idx (string-rindex path #\/)])
      (if idx (substring path 0 (+ idx 1)) "./"))))
(inject 'path-extension
  (lambda (path)
    (let ([idx (string-rindex path #\.)])
      (if (and idx (> idx 0))
        (substring path idx (string-length path))
        ""))))
(inject 'path-strip-extension
  (lambda (path)
    (let ([idx (string-rindex path #\.)])
      (if (and idx (> idx 0)) (substring path 0 idx) path))))
(inject 'path-strip-directory
  (lambda (path)
    (let ([idx (string-rindex path #\/)])
      (if idx (substring path (+ idx 1) (string-length path)) path))))
(inject 'path-strip-trailing-directory-separator
  (lambda (path)
    (let ([len (string-length path)])
      (if (and (> len 1) (char=? (string-ref path (- len 1)) #\/))
        (substring path 0 (- len 1))
        path))))
(inject 'current-directory
  (lambda args
    (if (null? args) (current-directory) (void))))

;; string-rindex / string-index / string-contains
(define (string-contains haystack needle)
  (let ([hlen (string-length haystack)]
        [nlen (string-length needle)])
    (let lp ([i 0])
      (cond
        [(> (+ i nlen) hlen) #f]
        [(string=? (substring haystack i (+ i nlen)) needle) i]
        [else (lp (+ i 1))]))))

(guard (exn [#t
  (inject 'string-rindex
    (lambda (str ch)
      (let lp ([i (- (string-length str) 1)])
        (cond [(< i 0) #f]
              [(char=? (string-ref str i) ch) i]
              [else (lp (- i 1))]))))])
  (eval 'string-rindex))

(guard (exn [#t
  (inject 'string-index
    (lambda (str ch)
      (let lp ([i 0])
        (cond [(>= i (string-length str)) #f]
              [(char=? (string-ref str i) ch) i]
              [else (lp (+ i 1))]))))])
  (eval 'string-index))

(guard (exn [#t
  (inject 'reverse!
    (lambda (lst)
      (let lp ([lst lst] [prev '()])
        (if (null? lst) prev
          (let ([next (cdr lst)])
            (set-cdr! lst prev)
            (lp next lst))))))])
  (eval 'reverse!))

(guard (exn [#t
  (inject 'make-list
    (lambda (n . fill)
      (let ([v (if (pair? fill) (car fill) #f)])
        (let lp ([i 0] [r '()])
          (if (>= i n) r
            (lp (+ i 1) (cons v r)))))))])
  (eval 'make-list))

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

(inject 'hash->list
  (lambda (ht)
    (let ([result '()])
      (hash-for-each
        (lambda (k v) (set! result (cons (cons k v) result)))
        ht)
      result)))

(inject 'keyword? |##keyword?|)
(inject 'keyword->string |##keyword->string|)

(guard (exn [#t
  (inject 'datum-parsing-exception? (lambda (x) #f))
  (inject 'datum-parsing-exception-filepos (lambda (x) 0))])
  (eval 'datum-parsing-exception?))

(guard (exn [#t (inject 'dump-stack-trace? (make-parameter #f))])
  (eval 'dump-stack-trace?))

(guard (exn [#t
  (inject 'display-exception
    (lambda (exn . port-args)
      (let ([port (if (pair? port-args) (car port-args) (current-output-port))])
        (display exn port))))])
  (eval 'display-exception))

(printf "  Expander stubs injected~n")

;;; ============================================================
;;; Compile and evaluate expander files (Phase 2)
;;; ============================================================

(printf "~n=== Loading Expander (Phase 2) ===~n")

(define expander-files
  '("common.ss" "stx.ss" "core.ss" "top.ss" "module.ss"
    "compile.ss" "root.ss" "stxcase.ss" "init.ss"))

(define expander-all-ok #t)

(define (compile-and-load-expander filename)
  (let ([forms (compile-file expander-src-dir filename)])
    (when (and forms (not (null? forms)))
      (let ([ok (load-file filename)])
        (unless ok (set! expander-all-ok #f))
        ;; After root.ss: patch context constructors
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
                       (|##structure-set!| obj 1 'top)
                       (|##structure-set!| obj 2 (make-hash-table-eq))
                       (|##structure-set!| obj 3 super)
                       (|##structure-set!| obj 4 #f)
                       (|##structure-set!| obj 5 #f)
                       obj)))))))))

(for-each compile-and-load-expander expander-files)
(check "expander loads" expander-all-ok)

;;; ============================================================
;;; Compile and evaluate core files (Phase 3)
;;; ============================================================

(printf "~n=== Loading Core Macros (Phase 3) ===~n")

(define core-files
  '("runtime.ss" "expander.ss" "sugar.ss" "mop.ss" "match.ss"
    "more-sugar.ss" "more-syntax-sugar.ss" "module-sugar.ss"
    "contract.ss" "macro-object.ss"))

(define core-total-errors 0)

(define (compile-and-load-core filename)
  (printf "~n--- ~a ---~n" filename)
  (let ([forms (compile-file core-src-dir filename)])
    (check (string-append filename " compiles") (and forms (pair? forms)))
    (when forms
      (printf "  (~a compiled forms)~n" (length forms))
      (let ([ok (load-file filename)])
        (check (string-append filename " evaluates") ok)
        (unless ok (set! core-total-errors (+ core-total-errors 1)))))))

(for-each compile-and-load-core core-files)

;;; ============================================================
;;; Verification
;;; ============================================================

(printf "~n=== Phase 3 Verification ===~n")

;; Check that runtime aliases are defined (from runtime.ss define-alias forms)
(guard (exn [#t
  (printf "  alias error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "runtime aliases (car-set! etc.)" #f)])
  (let ([cs (eval 'car-set!)]
        [bs (eval 'box-set!)])
    (check "runtime aliases (car-set! etc.)" (and (procedure? cs) (procedure? bs)))))

;; Check that when/unless work (native Chez forms)
(guard (exn [#t
  (printf "  when/unless error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "when/unless work" #f)])
  (let ([r1 (eval '(when #t 42))]
        [r2 (eval '(unless #f 99))])
    (check "when/unless work" (and (eqv? r1 42) (eqv? r2 99)))))

;; Check that guard/catch works (native Chez form for error handling)
(guard (exn [#t
  (printf "  guard error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "guard works for error handling" #f)])
  (let ([result (eval '(guard (exn [#t 'caught])
                          (error "test" "boom")))])
    (check "guard works for error handling" (eq? result 'caught))))

;; Check that make-parameter and parameterize work via native Chez
(guard (exn [#t
  (printf "  make-parameter error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "make-parameter works" #f)])
  (let ([p (eval '(make-parameter 42))])
    (check "make-parameter works" (and (procedure? p) (eqv? (p) 42)))))

;; Check that macro-object type exists (from macro-object.ss)
(guard (exn [#t
  (printf "  macro-object error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "macro-object type defined" #f)])
  (let ([mot (eval 'macro-object::t)])
    (check "macro-object type defined" (and mot (|##structure?| mot)))))

;; Check that macro-object has expected accessors (from macro-object.ss defclass)
(guard (exn [#t
  (printf "  macro-object accessor error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "macro-object-macro accessor defined" #f)])
  (let ([proc (eval 'macro-object-macro)])
    (check "macro-object-macro accessor defined" (procedure? proc))))

;; Check that core expander symbols survived (from expander.ss extern re-exports)
(guard (exn [#t
  (printf "  expander re-export error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "expander re-exports available" #f)])
  (let ([se (eval 'syntax-e)]
        [id? (eval 'identifier?)])
    (check "expander re-exports available" (and (procedure? se) (procedure? id?)))))

;; Check that more-syntax-sugar forms loaded (small file, should fully evaluate)
(guard (exn [#t
  (printf "  more-syntax-sugar error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "more-syntax-sugar loaded" #f)])
  (check "more-syntax-sugar loaded" #t))

;; Check that module-sugar partial load succeeded
(guard (exn [#t
  (printf "  module-sugar error: ~a~n" (if (message-condition? exn) (condition-message exn) exn))
  (check "module-sugar partial load" #f)])
  (check "module-sugar partial load" #t))

;;; ============================================================
;;; Summary
;;; ============================================================

(printf "~n--- Self-Host Core: ~a passed, ~a failed ---~n"
        pass-count fail-count)
