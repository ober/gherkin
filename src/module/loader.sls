#!chezscheme
;;; module/loader.sls — Gerbil module resolution and loading for Chez Scheme
;;;
;;; Resolves Gerbil module paths (e.g., :std/sugar) to source files,
;;; parses import dependencies, and loads modules in topological order
;;; using the gherkin compiler.

(library (module loader)
  (export
    gerbil-module-init!
    gerbil-load-module
    gerbil-resolve-module-path
    gerbil-module-loaded?
    gerbil-loaded-modules
    gerbil-module-source-dir
    *enable-cache*)

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
    (only (runtime error) Error::t error-message error-irritants error-trace
          error? raise display-exception)
    (runtime syntax)
    (only (compiler compile) gerbil-compile-top gerbil-compile-expression
          strip-annotations sanitize-compiled *current-source-dir*)
    (only (reader reader) gerbil-read-file annotated-datum? annotated-datum-value))

  ;; ============================================================
  ;; State
  ;; ============================================================

  ;; Module registry: module-id -> #t (loaded) or 'loading (in progress)
  (define *module-registry* (make-hashtable string-hash string=?))

  ;; Gerbil source root directory
  (define *gerbil-src-dir* #f)

  ;; Output directory for compiled forms (also serves as cache)
  (define *output-dir* "/tmp/gherkin-modules/")

  ;; Verbose logging
  (define *verbose* #f)

  ;; Module caching: skip recompilation if cache is newer than source
  (define *enable-cache* #t)

  ;; ============================================================
  ;; Initialization
  ;; ============================================================

  (define (inject-runtime-bindings!)
    "Inject runtime library bindings into the interaction environment.
     Uses a list of (name . value) pairs to avoid wholesale library imports
     that would clobber the expander's bindings."
    (for-each
      (lambda (pair)
        (let ([name (car pair)]
              [val (cdr pair)])
          ;; Only inject if not already bound (don't clobber test harness injections)
          (unless (guard (exn [#t #f])
                   (top-level-value name)
                   #t)
            (define-top-level-value name val))))
      `(;; MOP core
        (make-class-type . ,make-class-type)
        (make-class-type-descriptor . ,make-class-type-descriptor)
        (make-class-predicate . ,make-class-predicate)
        (make-class-slot-accessor . ,make-class-slot-accessor)
        (make-class-slot-mutator . ,make-class-slot-mutator)
        (make-instance . ,make-instance)
        (make-class-instance . ,make-class-instance)
        (class-instance-init! . ,class-instance-init!)
        (struct-instance-init! . ,struct-instance-init!)
        (object::t . ,object::t)
        (t::t . ,t::t)
        (class-type? . ,class-type?)
        (struct-type? . ,struct-type?)
        (class-type-id . ,class-type-id)
        (class-type-name . ,class-type-name)
        (class-type-super . ,class-type-super)
        (class-type-precedence-list . ,class-type-precedence-list)
        (class-type-slot-vector . ,class-type-slot-vector)
        (class-type-slot-table . ,class-type-slot-table)
        (class-type-properties . ,class-type-properties)
        (class-type-constructor . ,class-type-constructor)
        (class-type-methods . ,class-type-methods)
        (class-type-field-count . ,class-type-field-count)
        (class-type-struct? . ,class-type-struct?)
        (slot-ref . ,slot-ref)
        (slot-set! . ,slot-set!)
        (unchecked-slot-ref . ,unchecked-slot-ref)
        (unchecked-slot-set! . ,unchecked-slot-set!)
        ;; Method dispatch
        (bind-method! . ,bind-method!)
        (method-ref . ,method-ref)
        (call-method . ,call-method)
        ;; Symbolic tables
        (make-symbolic-table . ,make-symbolic-table)
        (symbolic-table-ref . ,symbolic-table-ref)
        (symbolic-table-set! . ,symbolic-table-set!)
        ;; Gambit compat (used in compiled struct code)
        (|##structure| . ,|##structure|)
        (|##structure-ref| . ,|##structure-ref|)
        (|##structure-set!| . ,|##structure-set!|)
        (|##structure-type| . ,|##structure-type|)
        (|##structure-instance-of?| . ,|##structure-instance-of?|)
        (|##structure-direct-instance-of?| . ,|##structure-direct-instance-of?|)
        ;; Util
        (symbol->keyword . ,symbol->keyword)
        (keyword->symbol . ,keyword->symbol)
        (|##keyword?| . ,|##keyword?|)
        (|##keyword->string| . ,|##keyword->string|)
        (|##string->keyword| . ,|##string->keyword|)
        ;; Error types (from runtime/error)
        (Error::t . ,Error::t)
        (error-message . ,error-message)
        (error-irritants . ,error-irritants)
        (error-trace . ,error-trace)
        (error? . ,error?)
        ;; Hash (from runtime/hash)
        (make-hash-table . ,make-hash-table)
        (make-hash-table-eq . ,make-hash-table-eq)
        (make-hash-table-eqv . ,make-hash-table-eqv)
        (hash-ref . ,hash-ref)
        (hash-get . ,hash-get)
        (hash-put! . ,hash-put!)
        (hash-update! . ,hash-update!)
        (hash-remove! . ,hash-remove!)
        (hash-key? . ,hash-key?)
        (hash-for-each . ,hash-for-each)
        (hash-map . ,hash-map)
        (hash-fold . ,hash-fold)
        (hash-find . ,hash-find)
        (hash->list . ,hash->list)
        (hash->plist . ,hash->plist)
        (hash-keys . ,hash-keys)
        (hash-values . ,hash-values)
        (hash-length . ,hash-length)
        (hash-copy . ,hash-copy)
        (hash-clear! . ,hash-clear!)
        (hash-merge . ,hash-merge)
        (hash-merge! . ,hash-merge!)
        (hash-table? . ,hash-table?)
        (is-hash-table? . ,is-hash-table?)
        ;; Commonly used in compiled code
        (void . ,void)
        (void? . ,void?)
        (true . ,true)
        (true? . ,true?)
        (false . ,false)
        (identity . ,identity)
        (raise . ,raise)
        (display-exception . ,display-exception)
        (absent-value . ,absent-value)
        (absent-obj . ,absent-obj)
        ;; Util functions commonly used by compiled modules
        (string-empty? . ,string-empty?)
        (string-index . ,string-index)
        (string-rindex . ,string-rindex)
        (string-split . ,string-split)
        (string-join . ,string-join)
        (display* . ,display*)
        ;; Syntax objects (used in macros)
        (stx-e . ,stx-e)
        (stx-wrap-source . ,stx-wrap-source)
        (stx-source . ,stx-source)
        (stx-pair? . ,stx-pair?)
        (stx-null? . ,stx-null?)
        (stx-list? . ,stx-list?)
        (stx-car . ,stx-car)
        (stx-cdr . ,stx-cdr)
        (stx-map . ,stx-map)
        (stx-for-each . ,stx-for-each)
        (stx-foldl . ,stx-foldl)
        (stx-foldr . ,stx-foldr)
        (stx-identifier . ,stx-identifier)
        (identifier? . ,identifier?)
        (genident . ,genident)
        (gentemps . ,gentemps)
        )))

  (define (gerbil-module-init! gerbil-src-dir . opts)
    "Initialize the module loader with the Gerbil source directory.
     Options: verbose: #t for debug output"
    (set! *gerbil-src-dir* gerbil-src-dir)
    (unless (file-exists? *output-dir*)
      (mkdir *output-dir*))
    ;; Parse options
    (let loop ([rest opts])
      (when (and (pair? rest) (pair? (cdr rest)))
        (when (eq? (car rest) 'verbose:)
          (set! *verbose* (cadr rest)))
        (loop (cddr rest))))
    ;; Mark runtime/expander/core as pre-loaded
    ;; (they're loaded by the bootstrap harness)
    (for-each
      (lambda (mod-id)
        (hashtable-set! *module-registry* mod-id #t))
      '(;; Runtime
        "gerbil/runtime/util" "gerbil/runtime/c3"
        "gerbil/runtime/table" "gerbil/runtime/control"
        "gerbil/runtime/mop" "gerbil/runtime/mop-system-classes"
        "gerbil/runtime/error" "gerbil/runtime/interface"
        "gerbil/runtime/hash" "gerbil/runtime/syntax"
        "gerbil/runtime/thread" "gerbil/runtime/eval"
        "gerbil/runtime/loader" "gerbil/runtime/repl"
        ;; Expander
        "gerbil/expander/common" "gerbil/expander/stx"
        "gerbil/expander/core" "gerbil/expander/top"
        "gerbil/expander/module" "gerbil/expander/compile"
        "gerbil/expander/root" "gerbil/expander/stxcase"
        "gerbil/expander/init"
        ;; Core
        "gerbil/core/runtime" "gerbil/core/expander"
        "gerbil/core/sugar" "gerbil/core/mop"
        "gerbil/core/match" "gerbil/core/more-sugar"
        "gerbil/core/more-syntax-sugar" "gerbil/core/module-sugar"
        "gerbil/core/contract" "gerbil/core/macro-object"
        ;; Compiler
        "gerbil/compiler/base" "gerbil/compiler/compile"
        "gerbil/compiler/driver" "gerbil/compiler/method"
        "gerbil/compiler/optimize-base" "gerbil/compiler/optimize-xform"
        "gerbil/compiler/optimize-top" "gerbil/compiler/optimize-call"
        "gerbil/compiler/optimize-spec" "gerbil/compiler/optimize-ann"
        "gerbil/compiler/optimize" "gerbil/compiler/ssxi"
        ;; Special: gerbil/expander is a meta-module
        "gerbil/expander" "gerbil/runtime"
        "gerbil/core" "gerbil/compiler"))
    ;; Inject runtime bindings into the interaction environment so that
    ;; eval'd compiled forms can reference make-class-type, object::t, etc.
    ;; We use explicit define injections rather than (eval '(import ...))
    ;; to avoid clobbering expander bindings in the interaction environment.
    (inject-runtime-bindings!)
    ;; Restore Chez builtins that Gerbil's expander may have shadowed.
    ;; Without this, (define-syntax ... (syntax-rules ...)) in loaded modules
    ;; fails because Gerbil redefines syntax-rules with an incompatible version.
    (eval '(import (only (chezscheme)
             define-syntax syntax-rules syntax-case syntax with-syntax
             define lambda let let* letrec letrec* begin if cond case))))

  ;; ============================================================
  ;; Module path resolution
  ;; ============================================================

  (define (module-id->path mod-id)
    "Convert module ID (e.g., 'std/sugar') to source file path."
    (let ([ss-path (string-append *gerbil-src-dir* mod-id ".ss")])
      (if (file-exists? ss-path)
        ss-path
        ;; Try .scm (some Gerbil modules use .scm extension)
        (let ([scm-path (string-append *gerbil-src-dir* mod-id ".scm")])
          (if (file-exists? scm-path)
            scm-path
            #f)))))

  ;; Current module being loaded (for resolving relative imports)
  (define *current-module-id* #f)

  (define (gerbil-resolve-module-path mod-spec)
    "Resolve a module specifier to a (module-id . source-path) pair.
     Handles :std/sugar, :gerbil/runtime/hash, ./relative paths."
    (cond
      [(symbol? mod-spec)
       (let ([s (symbol->string mod-spec)])
         (cond
           ;; :std/sugar -> std/sugar
           [(and (> (string-length s) 0) (char=? (string-ref s 0) #\:))
            (let* ([mod-id (substring s 1 (string-length s))]
                   [path (module-id->path mod-id)])
              (if path (cons mod-id path) #f))]
           ;; ./relative -> resolve relative to current module
           [(and (> (string-length s) 1)
                 (char=? (string-ref s 0) #\.)
                 (char=? (string-ref s 1) #\/))
            (let* ([rel-name (substring s 2 (string-length s))]
                   [base-dir (if *current-module-id*
                               (let ([idx (string-rindex *current-module-id* #\/)])
                                 (if idx
                                   (substring *current-module-id* 0 (+ idx 1))
                                   ""))
                               "")]
                   [mod-id (string-append base-dir rel-name)]
                   [path (module-id->path mod-id)])
              (if path (cons mod-id path) #f))]
           ;; ../relative -> resolve up one level
           [(and (> (string-length s) 2)
                 (char=? (string-ref s 0) #\.)
                 (char=? (string-ref s 1) #\.)
                 (char=? (string-ref s 2) #\/))
            (let* ([rel-name (substring s 3 (string-length s))]
                   [base-dir (if *current-module-id*
                               (let* ([idx1 (string-rindex *current-module-id* #\/)]
                                      [parent (if idx1
                                                (substring *current-module-id* 0 idx1)
                                                "")]
                                      [idx2 (string-rindex parent #\/)])
                                 (if idx2
                                   (substring parent 0 (+ idx2 1))
                                   ""))
                               "")]
                   [mod-id (string-append base-dir rel-name)]
                   [path (module-id->path mod-id)])
              (if path (cons mod-id path) #f))]
           ;; Bare symbol, try as-is
           [else
            (let ([path (module-id->path s)])
              (if path (cons s path) #f))]))]
      [(string? mod-spec)
       ;; String path
       (let ([mod-id (path-strip-extension mod-spec)])
         (let ([path (module-id->path mod-id)])
           (if path (cons mod-id path) #f)))]
      [else #f]))

  ;; string-rindex is imported from (runtime util)

  (define (path-strip-extension path)
    (let ([len (string-length path)])
      (let loop ([i (- len 1)])
        (cond
          [(< i 0) path]
          [(char=? (string-ref path i) #\.) (substring path 0 i)]
          [(char=? (string-ref path i) #\/) path]
          [else (loop (- i 1))]))))

  ;; ============================================================
  ;; Import parsing
  ;; ============================================================

  (define (extract-imports source-path)
    "Read a Gerbil source file and extract its import module specifiers."
    (let ([forms (gerbil-read-file source-path)])
      (let loop ([forms forms] [imports '()])
        (if (null? forms)
          (reverse imports)
          (let ([form (let ([f (car forms)])
                        (if (annotated-datum? f)
                          (annotated-datum-value f)
                          f))])
            (if (and (pair? form)
                     (let ([head (if (annotated-datum? (car form))
                                   (annotated-datum-value (car form))
                                   (car form))])
                       (eq? head 'import)))
              ;; Parse import specs
              (let ([specs (extract-import-specs (cdr form))])
                (loop (cdr forms) (append (reverse specs) imports)))
              (loop (cdr forms) imports)))))))

  (define (extract-import-specs specs)
    "Extract plain module specifiers from import specs.
     Handles: :std/sugar, (only-in :std/sugar ...), (for-syntax ...), etc."
    (let loop ([specs specs] [result '()])
      (if (null? specs)
        result
        (let ([spec (let ([s (car specs)])
                      (if (annotated-datum? s)
                        (annotated-datum-value s)
                        s))])
          (cond
            ;; Plain module symbol: :std/sugar
            [(symbol? spec)
             (loop (cdr specs) (cons spec result))]
            ;; Filtered import: (only-in :mod ...), (except-in :mod ...), etc.
            [(and (pair? spec)
                  (let ([head (if (annotated-datum? (car spec))
                                (annotated-datum-value (car spec))
                                (car spec))])
                    (memq head '(only-in except-in rename-in prefix-in))))
             (let ([inner-specs (extract-import-specs (cdr spec))])
               (loop (cdr specs) (append inner-specs result)))]
            ;; for-syntax: (for-syntax :mod ...) — skip for now
            [(and (pair? spec)
                  (let ([head (if (annotated-datum? (car spec))
                                (annotated-datum-value (car spec))
                                (car spec))])
                    (eq? head 'for-syntax)))
             ;; Skip compile-time imports for now
             (loop (cdr specs) result)]
            ;; String path
            [(string? spec)
             (loop (cdr specs) (cons spec result))]
            ;; Other forms (group-in, etc.) — skip
            [else
             (loop (cdr specs) result)])))))

  ;; ============================================================
  ;; Module compilation and loading
  ;; ============================================================

  (define (gerbil-module-loaded? mod-id)
    "Check if a module has been loaded."
    (eq? (hashtable-ref *module-registry* mod-id #f) #t))

  (define (gerbil-loaded-modules)
    "Return list of loaded module IDs."
    (let-values ([(keys vals) (hashtable-entries *module-registry*)])
      (let loop ([i 0] [result '()])
        (if (>= i (vector-length keys))
          result
          (loop (+ i 1)
                (if (eq? (vector-ref vals i) #t)
                  (cons (vector-ref keys i) result)
                  result))))))

  (define (gerbil-module-source-dir)
    *gerbil-src-dir*)

  (define (read-gerbil-module source-path)
    "Read a Gerbil source file, strip annotations and preamble keywords."
    (let ([forms (gerbil-read-file source-path)])
      (let loop ([forms forms] [result '()])
        (if (null? forms)
          (reverse result)
          (let* ([form (car forms)]
                 [val (if (annotated-datum? form)
                        (annotated-datum-value form)
                        form)])
            (cond
              ;; Skip preamble keywords (prelude:, package:, namespace:)
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
               (loop (cdr forms) (cons form result))]))))))

  ;; ============================================================
  ;; Module caching
  ;; ============================================================

  (define (cache-path mod-id)
    "Return the cache file path for a module ID."
    (string-append *output-dir* (string-replace mod-id "/" "_") ".ss"))

  (define (file-mtime path)
    "Get file modification time, or #f if file doesn't exist."
    (guard (exn [#t #f])
      (file-change-time path)))

  (define (cache-valid? mod-id source-path)
    "Check if the cached compiled output is newer than the source file."
    (and *enable-cache*
         (let ([cached (cache-path mod-id)]
               [src-mtime (file-mtime source-path)])
           (and src-mtime
                (file-exists? cached)
                (let ([cache-mtime (file-mtime cached)])
                  (and cache-mtime
                       (time>? cache-mtime src-mtime)))))))

  (define (load-from-cache mod-id)
    "Load a module from its cached compiled output. Returns #t on success."
    (let ([cached (cache-path mod-id)]
          [error-count 0])
      (when *verbose*
        (printf "  Loading ~a from cache~n" mod-id))
      (guard (exn [#t
        (when *verbose*
          (printf "  Cache load failed for ~a: ~a~n" mod-id
            (if (message-condition? exn) (condition-message exn) exn)))
        #f])
        (let ([port (open-input-file cached)])
          (let eval-loop ()
            (let ([form (read port)])
              (unless (eof-object? form)
                (unless (and (pair? form) (memq (car form) '(import export)))
                  (guard (exn [#t
                    (set! error-count (+ error-count 1))])
                    (eval form)))
                (eval-loop))))
          (close-input-port port)
          (hashtable-set! *module-registry* mod-id #t)
          (when *verbose*
            (printf "  ~a: loaded from cache (~a eval errors)~n" mod-id error-count))
          #t))))

  ;; ============================================================
  ;; Module compilation and loading
  ;; ============================================================

  (define (compile-and-load-module mod-id source-path)
    "Compile a Gerbil source file and evaluate it.
     Follows the same pattern as the test harness: strip annotations,
     pre-register defrules/defrule, compile, write, eval.
     Uses cache if available and source hasn't changed."
    ;; Try cache first
    (if (cache-valid? mod-id source-path)
      (load-from-cache mod-id)
      (begin
        (when *verbose*
          (printf "  Compiling module: ~a~n" mod-id))

    ;; Extract source directory for include resolution
    (let* ([source-dir (let ([s source-path])
                         (let lp ([i (- (string-length s) 1)])
                           (cond
                             [(< i 0) ""]
                             [(char=? (string-ref s i) #\/)
                              (substring s 0 i)]
                             [else (lp (- i 1))])))]
           [forms (read-gerbil-module source-path)]
           [stripped (map (lambda (f)
                           (if (annotated-datum? f)
                             (strip-annotations (annotated-datum-value f))
                             (strip-annotations f)))
                         forms)]
           ;; Pre-pass: register defrules/defrule for compile-time expansion
           [_ (parameterize ([*current-source-dir* source-dir])
                (for-each
                  (lambda (form)
                    (when (and (pair? form) (memq (car form) '(defrules defrule)))
                      (guard (exn [#t (void)])
                        (gerbil-compile-top form))))
                  stripped))]
           ;; Compile, skipping import/export and empty begins
           [compiled
            (parameterize ([*current-source-dir* source-dir])
              (let loop ([forms stripped] [result '()])
                (if (null? forms)
                  (reverse result)
                  (let ([form (car forms)])
                    (guard (exn [#t
                      (loop (cdr forms) result)])
                      (let ([c (gerbil-compile-top form)])
                        (cond
                          [(and (pair? c) (memq (car c) '(import export)))
                           (loop (cdr forms) result)]
                          [(equal? c '(begin))
                           (loop (cdr forms) result)]
                          [else
                           (loop (cdr forms) (cons c result))])))))))]
           [error-count 0])

      ;; Write compiled output
      (let ([out-path (string-append *output-dir*
                        (string-replace mod-id "/" "_") ".ss")])
        (when (file-exists? out-path) (delete-file out-path))
        (call-with-output-file out-path
          (lambda (port)
            (for-each
              (lambda (form)
                (pretty-print (sanitize-compiled form) port)
                (newline port))
              compiled))
          'replace)

        ;; Evaluate form-by-form
        (let ([in-port (open-input-file out-path)])
          (let eval-loop ()
            (let ([form (read in-port)])
              (unless (eof-object? form)
                (if (and (pair? form) (memq (car form) '(import export)))
                  (eval-loop)
                  (begin
                    (guard (exn [#t
                      (set! error-count (+ error-count 1))
                      (when *verbose*
                        (printf "    eval error: ~a~n"
                                (if (message-condition? exn)
                                  (condition-message exn)
                                  exn)))])
                      (eval form))
                    (eval-loop))))))
          (close-input-port in-port)

          (when *verbose*
            (printf "  ~a: ~a forms compiled, ~a eval errors~n"
                    mod-id (length compiled) error-count))

          ;; Consider it loaded even with eval errors
          ;; (many are expected define-syntax failures)
          (hashtable-set! *module-registry* mod-id #t)
          ;; Force GC after compilation to keep memory under control
          (collect)
          (values (length compiled) error-count)))))))

  (define (string-replace str old new)
    (let ([slen (string-length str)]
          [olen (string-length old)])
      (let loop ([i 0] [result '()])
        (cond
          [(> (+ i olen) slen)
           (apply string-append
             (reverse (cons (substring str i slen) result)))]
          [(string=? (substring str i (+ i olen)) old)
           (loop (+ i olen) (cons new result))]
          [else
           (loop (+ i 1)
                 (cons (string (string-ref str i)) result))]))))

  ;; ============================================================
  ;; Main entry point: load module with dependency resolution
  ;; ============================================================

  (define (gerbil-load-module mod-spec)
    "Load a Gerbil module and its dependencies.
     mod-spec can be a symbol (:std/sugar) or string.
     Returns (values forms-compiled eval-errors) or #f if not found."
    (let ([resolved (gerbil-resolve-module-path mod-spec)])
      (if (not resolved)
        (begin
          (when *verbose*
            (printf "  WARNING: Cannot resolve module ~a~n" mod-spec))
          #f)
        (let ([mod-id (car resolved)]
              [source-path (cdr resolved)])
          (cond
            ;; Already loaded
            [(gerbil-module-loaded? mod-id)
             (when *verbose*
               (printf "  ~a already loaded~n" mod-id))
             (values 0 0)]
            ;; Currently loading (cyclic dependency)
            [(eq? (hashtable-ref *module-registry* mod-id #f) 'loading)
             (when *verbose*
               (printf "  ~a cyclic dependency, skipping~n" mod-id))
             (values 0 0)]
            ;; Need to load
            [else
             ;; Mark as loading to detect cycles
             (hashtable-set! *module-registry* mod-id 'loading)

             ;; Load dependencies first (set current module for relative paths)
             (let ([saved-mod *current-module-id*])
               (set! *current-module-id* mod-id)
               (guard (exn [#t
                 (when *verbose*
                   (printf "  Error parsing imports for ~a: ~a~n"
                           mod-id
                           (if (message-condition? exn)
                             (condition-message exn)
                             exn)))])
                 (let ([imports (extract-imports source-path)])
                   (for-each
                     (lambda (imp)
                       (guard (exn [#t
                         (when *verbose*
                           (printf "  Dependency ~a failed: ~a~n"
                                   imp
                                   (if (message-condition? exn)
                                     (condition-message exn)
                                     exn)))])
                         (gerbil-load-module imp)))
                     imports)))
               (set! *current-module-id* saved-mod))

             ;; Now compile and load this module
             (compile-and-load-module mod-id source-path)])))))

) ;; end library
