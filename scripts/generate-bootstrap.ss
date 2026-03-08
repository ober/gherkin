#!chezscheme
;;; Generate bootstrap artifacts from Gerbil source files
;;; Usage: scheme -q --libdirs .:src --program scripts/generate-bootstrap.ss
;;;
;;; Compiles all Gerbil runtime, expander, core, and compiler source files
;;; through gherkin and stores compiled Chez Scheme in bootstrap/

(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table compile-file)
  (except (compat gambit-compat) void? absent-obj)
  (compat types)
  (only (compiler compile) gerbil-compile-top gerbil-compile-expression
        strip-annotations sanitize-compiled *current-source-dir*)
  (only (reader reader) gerbil-read-file annotated-datum? annotated-datum-value annotated-datum-source))

(define gerbil-src-dir
  (let ([home (getenv "HOME")])
    (string-append home "/mine/gerbil/src/")))

(define output-dir "bootstrap/")

;; Create subdirectories
(unless (file-exists? "bootstrap/runtime") (mkdir "bootstrap/runtime"))
(unless (file-exists? "bootstrap/expander") (mkdir "bootstrap/expander"))
(unless (file-exists? "bootstrap/core") (mkdir "bootstrap/core"))
(unless (file-exists? "bootstrap/compiler") (mkdir "bootstrap/compiler"))

;;; File reading — strip prelude:/package:/namespace: directives

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

;;; Compilation

(define (compile-file-to-bootstrap src-path out-name)
  (printf "  ~a" out-name)
  (let ([out-path (string-append output-dir out-name)])
    (guard (exn [#t
      (printf " ERROR: ~a~n"
        (if (message-condition? exn) (condition-message exn) exn))
      #f])
      (let* ([forms (read-gerbil-file src-path)]
             [stripped (map (lambda (f)
                             (if (annotated-datum? f)
                               (strip-annotations (annotated-datum-value f))
                               (strip-annotations f)))
                           forms)]
             [src-dir (let loop ([i (- (string-length src-path) 1)])
                        (cond
                          [(< i 0) "./"]
                          [(char=? (string-ref src-path i) #\/)
                           (substring src-path 0 (+ i 1))]
                          [else (loop (- i 1))]))]
             [_ (parameterize ([*current-source-dir* src-dir])
                  (for-each
                    (lambda (form)
                      (when (and (pair? form) (memq (car form) '(defrules defrule)))
                        (guard (exn [#t (void)])
                          (gerbil-compile-top form))))
                    stripped))]
             [compiled
              (parameterize ([*current-source-dir* src-dir])
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
                             (loop (cdr forms) (cons c result))])))))))])
        (call-with-output-file out-path
          (lambda (port)
            (for-each
              (lambda (form)
                (pretty-print (sanitize-compiled form) port)
                (newline port))
              compiled))
          'replace)
        (printf " -> ~a forms~n" (length compiled))
        #t))))

;;; File lists

(define runtime-files
  '("system.ss" "c3.ss" "mop-system-classes.ss" "mop.ss" "table.ss"
    "hash.ss" "control.ss" "error.ss" "thread.ss" "syntax.ss" "eval.ss"
    "repl.ss" "loader.ss" "init.ss"))

(define expander-files
  '("common.ss" "stx.ss" "stxcase.ss" "core.ss" "top.ss"
    "module.ss" "compile.ss" "root.ss"))

(define core-files
  '("runtime.ss" "expander.ss" "sugar.ss" "mop.ss" "match.ss"
    "more-sugar.ss" "more-syntax-sugar.ss" "module-sugar.ss"
    "contract.ss" "macro-object.ss"))

(define compiler-files
  '("base.ss" "compile.ss" "driver.ss" "method.ss"
    "optimize-base.ss" "optimize-xform.ss" "optimize-top.ss"
    "optimize-call.ss" "optimize-spec.ss" "optimize-ann.ss"
    "optimize.ss" "ssxi.ss"))

;;; Main

(printf "=== Generating Bootstrap Artifacts ===~n")
(printf "  Source: ~a~n" gerbil-src-dir)
(printf "  Output: ~a~n~n" output-dir)

(let ([total 0] [success 0])

  (printf "--- Runtime (14 files) ---~n")
  (for-each
    (lambda (f)
      (set! total (+ total 1))
      (when (compile-file-to-bootstrap
              (string-append gerbil-src-dir "gerbil/runtime/" f)
              (string-append "runtime/" f))
        (set! success (+ success 1))))
    runtime-files)

  (printf "~n--- Expander (8 files) ---~n")
  (for-each
    (lambda (f)
      (set! total (+ total 1))
      (when (compile-file-to-bootstrap
              (string-append gerbil-src-dir "gerbil/expander/" f)
              (string-append "expander/" f))
        (set! success (+ success 1))))
    expander-files)

  (printf "~n--- Core Macros (10 files) ---~n")
  (for-each
    (lambda (f)
      (set! total (+ total 1))
      (when (compile-file-to-bootstrap
              (string-append gerbil-src-dir "gerbil/core/" f)
              (string-append "core/" f))
        (set! success (+ success 1))))
    core-files)

  (printf "~n--- Compiler (12 files) ---~n")
  (for-each
    (lambda (f)
      (set! total (+ total 1))
      (when (compile-file-to-bootstrap
              (string-append gerbil-src-dir "gerbil/compiler/" f)
              (string-append "compiler/" f))
        (set! success (+ success 1))))
    compiler-files)

  (printf "~n=== Bootstrap complete: ~a/~a files ===~n" success total))
