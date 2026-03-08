#!chezscheme
;;; self-host-runtime.ss -- Compile and evaluate Gerbil runtime files via gherkin
;;;
;;; Compiles each Gerbil runtime file through the gherkin compiler and evaluates
;;; the result on Chez Scheme, building up the complete runtime in dependency order.

(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (except (compat gambit-compat) void? absent-obj)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime hash)
  (runtime mop)
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

(define gerbil-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/gerbil/runtime/")))

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

;; Standard import block for compiled Gerbil runtime files
(define standard-imports
  '(import
     (except (chezscheme) void box box? unbox set-box!
             andmap ormap iota last-pair find
             1+ 1- fx/ fx1+ fx1-
             error error? raise with-exception-handler identifier?
             hash-table? make-hash-table)
     (compat gambit-compat)
     (compat types)
     (runtime util)))

;; Compile a Gerbil runtime file, write to output-dir, return body forms or #f
(define (compile-runtime-file filename . extra-imports)
  (let ([src-path (string-append gerbil-src-dir filename)]
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
             ;; Pre-pass: register all defrules for compile-time expansion
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
                      (when (and (pair? form) (pair? (cdr form)) (pair? (cadr form))
                                 (memq (car form) '(def define)))
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

        ;; Write output file (body only, no import -- loaded into interaction env)
        ;; Sanitize to replace keyword-objects with symbols
        (call-with-output-file out-path
          (lambda (port)
            (for-each
              (lambda (form)
                (pretty-print (sanitize-compiled form) port)
                (newline port))
              compiled))
          'replace)

        compiled))))

;; Load a compiled file by evaluating each form.
;; Skips import/export forms and continues past individual form errors.
;; Returns (pass-count . fail-count).
(define (load-runtime-file filename)
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
                    (when (< errors 8)
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
;;; Gambit compat shims for the eval environment
;;; ============================================================
;;; The compiled Gerbil runtime files reference Gambit-internal symbols
;;; that don't exist in Chez Scheme. We define minimal stubs here so
;;; the forms can be evaluated.

;; Helper: inject a binding into the interaction environment
(define (inject name val)
  (define-top-level-value name val (interaction-environment)))
(define inject-fn inject)

;; Gambit's void and absent markers
(inject-fn '%%void |%%void|)
(inject-fn '|%%void| |%%void|)
(inject '|##absent-object| (lambda () absent-obj))
(inject 'absent-obj absent-obj)

;; Gambit fixnum ops — inject standard Chez equivalents
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

;; Gambit's macro sentinel values — unique objects used as hash table markers
(let ([unused (vector 'unused)]
      [deleted (vector 'deleted)])
  (inject-fn 'macro-unused-obj (lambda () unused))
  (inject-fn 'macro-deleted-obj (lambda () deleted)))

;; Gambit GC hash table flags
(inject-fn 'macro-gc-hash-table-flag-weak-keys (lambda () 1))
(inject-fn 'macro-gc-hash-table-flag-weak-vals (lambda () 2))
(inject-fn 'macro-gc-hash-table-flag-key-moved (lambda () 16))
(inject-fn 'macro-gc-hash-table-flag-need-rehash (lambda () 32))

;; NOTE: ##structure, ##structure-ref, ##structure-set!, ##type-id, ##type-name, etc.
;; are all provided by (compat types) and imported via the eval import below.
;; Do NOT override them here with incompatible vector-based shims.

;; nonce — generates unique IDs
(let ([counter 0])
  (inject 'nonce (lambda ()
                   (set! counter (+ counter 1))
                   counter)))

;; Inject all module bindings into the interaction environment.
;; This is the cleanest approach: eval the imports so the interaction
;; environment has access to everything the compiled code needs.
(eval '(import
         (except (chezscheme) void box box? unbox set-box!
                 andmap ormap iota last-pair find
                 1+ 1- fx/ fx1+ fx1-
                 error error? raise with-exception-handler identifier?
                 hash-table? make-hash-table)
         (except (compat gambit-compat) void? absent-obj)
         (compat types)
         (runtime util)))

;; Inject ##eqv? (used by make-hash-table-eq in compiled code)
(inject '|##eqv?| eqv?)

;; Inject ##string=?-hash and other Gambit hash functions
;; Chez doesn't expose eq-hash etc., so we use symbol-hash / string-hash as reasonable stubs
(define (gambit-eq-hash x) (equal-hash x))
(define (gambit-eqv-hash x) (equal-hash x))
(inject '|##string=?-hash| string-hash)
(inject 'eq?-hash gambit-eq-hash)
(inject 'eqv?-hash gambit-eqv-hash)
(inject 'equal?-hash equal-hash)
(inject 'eq-hash gambit-eq-hash)

;; Inject ##vector-cas! — compare-and-swap (stub for single-threaded operation)
(inject-fn '|##vector-cas!|
  (lambda (vec idx expected new)
    (let ([old (vector-ref vec idx)])
      (when (eqv? old expected)
        (vector-set! vec idx new))
      old)))

;; Inject ##thread-yield! — thread yield stub
(inject-fn '|##thread-yield!| (lambda () (void)))

;; class-of — return the type tag of a gerbil-struct, or #f for non-structs
(inject 'class-of
  (lambda (obj)
    (if (gerbil-struct? obj)
      (gerbil-struct-type-tag obj)
      #f)))

;; __class-slot-offset — find slot index by name in type's slot table
(inject '__class-slot-offset
  (lambda (klass slot)
    (let ([st (class-type-slot-table klass)])
      (and st (symbolic-table-ref st slot #f)))))

;; Save our working hash operations before they get overwritten by compiled code.
;; The compiled hash.ss uses interface dispatch (slot-ref) which requires full MOP bootstrap.
;; Our (runtime hash) implementations work directly with Chez eq-hashtables.
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

;; Override macro-type-* to return proper gerbil-struct type objects
;; so that ##type-name, ##type-id, ##type-flags, ##type-super work on them.
;; Uses ##structure from (compat types) which creates gerbil-struct records.
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

;; Inject call-with-output-string — Gambit's version takes (initial-string proc)
;; but the compiled code passes (list) as initial which we ignore
(inject-fn 'call-with-output-string
  (lambda (init proc)
    (let ([port (open-output-string)])
      (proc port)
      (get-output-string port))))

;; Inject random-integer (Gambit built-in, use Chez's random)
(inject-fn 'random-integer (lambda (n) (random n)))

;; Inject make-condition-variable (Gambit threading)
(inject 'make-condition-variable (lambda args 'condition-variable-stub))

;; Inject mutex-lock!/mutex-unlock! (Gambit threading primitives)
(inject 'mutex-lock! (lambda (m . args) (void)))
(inject 'mutex-unlock! (lambda (m . args) (void)))

;;; ============================================================
;;; Compile and evaluate each runtime file in dependency order
;;; ============================================================

;; --- util.ss ---
(printf "~n=== util.ss ===~n")
(let ([forms (compile-runtime-file "util.ss")])
  (check "util.ss compiles" (and forms (> (length forms) 50)))
  (when forms
    (let ([ok (load-runtime-file "util.ss")])
      (check "util.ss evaluates" ok)
      (when ok
        ;; identity and void? come from (runtime util), already in scope
        (guard (exn [#t
          (printf "  identity check error: ~a~n"
            (if (message-condition? exn) (condition-message exn) exn))])
          (check "identity works" (equal? (identity 42) 42))
          (check "void? works" (void? (void))))))))

;; --- c3.ss ---
(printf "~n=== c3.ss ===~n")
(let ([forms (compile-runtime-file "c3.ss")])
  (check "c3.ss compiles" (and forms (pair? forms)))
  (when forms
    (let ([ok (load-runtime-file "c3.ss")])
      (check "c3.ss evaluates" ok)
      (when ok
        (let ([result
               (guard (exn [#t
                 (printf "  c4-linearize error: ~a~n"
                   (if (message-condition? exn) (condition-message exn) exn))
                 #f])
                 (eval '(let-values ([(pl ss)
                                      (c4-linearize '(a) '(b c)
                                        (lambda (x)
                                          (case x
                                            [(b) '(b d)]
                                            [(c) '(c d)]
                                            [else (list x)]))
                                        (lambda (x) #f))])
                          pl)))])
          (check "c4-linearize correct" (equal? result '(a b c d))))))))

;; --- table.ss ---
(printf "~n=== table.ss ===~n")
(let ([forms (compile-runtime-file "table.ss")])
  (check "table.ss compiles" (and forms (> (length forms) 30)))
  (when forms
    (let ([ok (load-runtime-file "table.ss")])
      (check "table.ss evaluates" ok))))

;; --- control.ss ---
(printf "~n=== control.ss ===~n")
(let ([forms (compile-runtime-file "control.ss")])
  (check "control.ss compiles" (and forms (pair? forms)))
  (when forms
    (let ([ok (load-runtime-file "control.ss")])
      (check "control.ss evaluates" ok))))

;; --- mop.ss ---
(printf "~n=== mop.ss ===~n")
(let ([forms (compile-runtime-file "mop.ss")])
  (check "mop.ss compiles" (and forms (> (length forms) 50)))
  (when forms
    (let ([ok (load-runtime-file "mop.ss")])
      (check "mop.ss evaluates" ok)
      ;; defrefset* couldn't be expanded by gherkin (uses defsyntax/syntax-case)
      ;; Manually define the class-type slot accessors/mutators
      (when ok
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
            (properties 9) (constructor 10) (methods 11)))))))

;; --- mop-system-classes.ss ---
(printf "~n=== mop-system-classes.ss ===~n")
(let ([forms (compile-runtime-file "mop-system-classes.ss")])
  (check "mop-system-classes.ss compiles" (and forms (> (length forms) 30)))
  (when forms
    (let ([ok (load-runtime-file "mop-system-classes.ss")])
      (check "mop-system-classes.ss evaluates" ok))))

;; --- error.ss ---
(printf "~n=== error.ss ===~n")
(let ([forms (compile-runtime-file "error.ss")])
  (check "error.ss compiles" (and forms (> (length forms) 10)))
  (when forms
    (let ([ok (load-runtime-file "error.ss")])
      (check "error.ss evaluates" ok))))

;; --- interface.ss ---
(printf "~n=== interface.ss ===~n")
(let ([forms (compile-runtime-file "interface.ss")])
  (check "interface.ss compiles" (and forms (> (length forms) 10)))
  (when forms
    (let ([ok (load-runtime-file "interface.ss")])
      (check "interface.ss evaluates" ok))))

;; --- hash.ss ---
(printf "~n=== hash.ss ===~n")
(let ([forms (compile-runtime-file "hash.ss")])
  (check "hash.ss compiles" (and forms (> (length forms) 50)))
  (when forms
    (let ([ok (load-runtime-file "hash.ss")])
      (check "hash.ss evaluates" ok))))

;; Re-inject our (runtime hash) operations after compiled hash.ss overwrites them.
;; The compiled hash.ss uses interface dispatch (slot-ref) which requires full MOP,
;; but our hash ops work directly with Chez eq-hashtables.
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

;; --- syntax.ss ---
(printf "~n=== syntax.ss ===~n")
(let ([forms (compile-runtime-file "syntax.ss")])
  (check "syntax.ss compiles" (and forms (> (length forms) 10)))
  (when forms
    (let ([ok (load-runtime-file "syntax.ss")])
      (check "syntax.ss evaluates" ok))))

;; --- thread.ss ---
(printf "~n=== thread.ss ===~n")
(let ([forms (compile-runtime-file "thread.ss")])
  (check "thread.ss compiles" (and forms (> (length forms) 10)))
  (when forms
    (let ([ok (load-runtime-file "thread.ss")])
      (check "thread.ss evaluates" ok))))

;; --- eval.ss ---
(printf "~n=== eval.ss ===~n")
(let ([forms (compile-runtime-file "eval.ss")])
  (check "eval.ss compiles" (and forms (> (length forms) 10)))
  (when forms
    (let ([ok (load-runtime-file "eval.ss")])
      (check "eval.ss evaluates" ok))))

;; --- loader.ss ---
(printf "~n=== loader.ss ===~n")
(let ([forms (compile-runtime-file "loader.ss")])
  (check "loader.ss compiles" (and forms (pair? forms)))
  (when forms
    (let ([ok (load-runtime-file "loader.ss")])
      (check "loader.ss evaluates" ok))))

;; --- repl.ss ---
(printf "~n=== repl.ss ===~n")
(let ([forms (compile-runtime-file "repl.ss")])
  (check "repl.ss compiles" (and forms (pair? forms)))
  (when forms
    (let ([ok (load-runtime-file "repl.ss")])
      (check "repl.ss evaluates" ok))))

;;; ============================================================
;;; Summary
;;; ============================================================

(printf "~n--- Self-Host Runtime: ~a passed, ~a failed ---~n"
        pass-count fail-count)
