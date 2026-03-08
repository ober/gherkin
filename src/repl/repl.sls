#!chezscheme
;;; repl.sls -- Gerbil REPL for Gherkin
;;; Provides an interactive read-eval-print loop with Gerbil syntax support.

(library (repl repl)
  (export gxi-start gxi-eval-file)

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise eval void)
            (error chez:error) (raise chez:raise)
            (eval chez:eval) (void chez:void))
    (only (compat gambit-compat) |##keyword?| void)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax)
    (runtime eval)
    (only (reader reader)
          gerbil-read gerbil-read-file
          annotated-datum? annotated-datum-value)
    (compiler compile)
    (boot init)
    (compat std-disasm)
    (module loader))

  ;; --- Import resolution for script/REPL mode ---
  ;; Resolve Gerbil-style imports (:std/sugar etc.) to Chez library names
  ;; and evaluate them in the REPL environment.
  ;; Falls back to module loader for imports not in the compat map.
  (define (eval-import-form form)
    (let ((specs (cdr form)))  ;; strip 'import head
      (for-each
        (lambda (spec)
          (let ((r (resolve-import spec *default-import-map*)))
            (cond
              ;; Compat map has a mapping
              (r (guard (exn (#t (void)))
                   (chez:eval `(import ,r) repl-env)))
              ;; Try module loader for :std/foo style imports
              ((and (symbol? spec)
                    (let ([s (symbol->string spec)])
                      (and (> (string-length s) 0)
                           (char=? (string-ref s 0) #\:))))
               (guard (exn (#t
                 (printf "import: ~a~n"
                   (if (message-condition? exn)
                     (condition-message exn)
                     exn))))
                 (gerbil-load-module spec)))
              ;; Otherwise skip (compiler handles natively)
              (else (void)))))
        specs)))

  (define repl-env (interaction-environment))

  ;; Source registry: maps symbol → original source form for ,dis of defined names
  (define *source-registry* (make-hashtable symbol-hash eq?))

  ;; Extract the defined name from a def/define form, or #f
  (define (defined-name form)
    (and (pair? form)
         (memq (car form) '(def define def*))
         (pair? (cdr form))
         (let ((name-part (cadr form)))
           (cond
             ((symbol? name-part) name-part)
             ((and (pair? name-part) (symbol? (car name-part)))
              (car name-part))
             (else #f)))))

  ;; Initialize module loader for Gerbil source imports
  (define (init-module-loader!)
    (let ([gerbil-home (or (getenv "GERBIL_HOME")
                           (let ([home (getenv "HOME")])
                             (and home (string-append home "/mine/gerbil"))))])
      (when gerbil-home
        (let ([src-dir (string-append gerbil-home "/src/")])
          (when (file-exists? src-dir)
            (gerbil-module-init! src-dir))))))

  (define (init-repl-env!)
    ;; Load runtime bindings into the interaction environment so that
    ;; compiled forms (defstruct, defclass, etc.) can reference them.
    (chez:eval
      '(import
         (except (chezscheme) void box box? unbox set-box!
                 andmap ormap iota last-pair find
                 1+ 1- fx/ fx1+ fx1-
                 identifier?
                 hash-table? make-hash-table)
         (compat types)
         (runtime util)
         (except (runtime table) string-hash)
         (runtime mop)
         (runtime hash)
         (runtime syntax))
      repl-env)
    ;; Install stubs for common Gambit ## primitives so scripts that
    ;; use them don't crash.  These are no-ops or sensible defaults.
    (chez:eval
      '(begin
         (define (|##set-parallelism-level!| n) (void))
         (define (|##startup-parallelism!|) (void))
         (define *repl-cpu-count*
           (guard (exn [#t 1])
             (let ([p (open-input-file "/proc/cpuinfo")])
               (let loop ([count 0])
                 (let ([line (get-line p)])
                   (if (eof-object? line)
                     (begin (close-input-port p) (max 1 count))
                     (loop (if (and (>= (string-length line) 9)
                                    (string=? (substring line 0 9) "processor"))
                            (+ count 1) count))))))))
         (define (|##current-vm-processor-count|) *repl-cpu-count*)
         (define (|##process-statistics|)
           ;; Return f64vector matching Gambit layout:
           ;; 0=user-time 1=sys-time 2=real-time 3=gc-user 4=gc-real 5=gc-count
           (let ((secs (/ (cpu-time) 1000.0))
                 (real (/ (real-time) 1000.0)))
             (let ((v (make-f64vector 6 0.0)))
               (f64vector-set! v 0 secs)
               (f64vector-set! v 2 real)
               v)))
         ;; SRFI-18 threading stubs (Gambit built-ins not available on Chez)
         (define (thread-sleep! seconds)
           (sleep (make-time 'time-duration
                   (mod (inexact->exact (round (* seconds 1000000000))) 1000000000)
                   (inexact->exact (floor seconds)))))
         (define (make-thread thunk . name)
           ;; Return the thunk; thread-start! will actually fork it
           thunk)
         (define (thread-start! thunk)
           (fork-thread thunk))
         (define thread-join! thread-join)
         ;; Gambit I/O compat
         (define force-output flush-output-port)
         ;; Gambit f64vector compat (Chez uses flvector)
         (define make-f64vector make-flvector)
         (define f64vector-ref flvector-ref)
         (define f64vector-set! flvector-set!))
      repl-env)
    ;; Make disassemble available in the REPL
    (chez:eval
      '(import (compat std-disasm))
      repl-env))

  (define (gxi-start args)
    (init-repl-env!)
    (init-module-loader!)
    (cond
      ((pair? args)
       ;; Script mode: compile and eval the file
       (gxi-eval-file (car args)))
      (else
       ;; Interactive REPL
       (print-banner)
       (repl-loop))))

  (define (print-banner)
    (printf "Gherkin ~a — Gerbil on ~a~n"
            gherkin-version
            (scheme-version))
    (printf "Type ,h for help, ,q to quit.~n"))

  (define quit-tag (list 'quit))

  (define (repl-loop)
    (let loop ()
      (display "> ")
      (flush-output-port (current-output-port))
      (let ((form (guard (exn
                          (#t
                           (display-error "read error" exn)
                           (consume-line (current-input-port))
                           (loop)))
                    (gerbil-read (current-input-port)))))
        (cond
          ((eof-object? form)
           (newline)
           (void))
          (else
           (let ((result (handle-form form)))
             (unless (eq? result quit-tag)
               (loop))))))))

  (define (consume-line port)
    ;; Drain remaining chars on the current line after a read error
    (let lp ()
      (let ((ch (read-char port)))
        (unless (or (eof-object? ch) (char=? ch #\newline))
          (lp)))))

  (define (handle-form form)
    (let ((datum (strip-annotations form)))
      (cond
        ;; Comma commands: reader turns ,foo into (unquote foo)
        ((and (pair? datum) (eq? (car datum) 'unquote))
         (handle-comma-command (cdr datum)))
        ;; Silently ignore export forms (no module context)
        ((and (pair? datum) (eq? (car datum) 'export))
         (void))
        ;; Resolve Gerbil-style imports
        ((and (pair? datum) (eq? (car datum) 'import))
         (guard (exn (#t (display-error "import error" exn)))
           (eval-import-form datum)))
        (else
         (eval-and-print datum)))))

  (define (handle-comma-command args)
    ;; Reader turns ,foo into (unquote foo), so args = (foo)
    ;; For ,load and ,expand, we need to read the next form from stdin
    (let ((cmd (if (pair? args) (car args) args)))
      (cond
        ((memq cmd '(q quit))
         (printf "Bye.~n")
         quit-tag)
        ((memq cmd '(h help))
         (print-help))
        ((eq? cmd 'load)
         (let ((next (gerbil-read (current-input-port))))
           (if (eof-object? next)
             (printf "Usage: ,load <filename>~n")
             (let* ((datum (strip-annotations next))
                    (path (if (string? datum)
                            datum
                            (symbol->string datum))))
               (guard (exn (#t (display-error "load error" exn)))
                 (gxi-eval-file path)
                 (printf "Loaded ~a~n" path))))))
        ((eq? cmd 'expand)
         (let ((next (gerbil-read (current-input-port))))
           (if (eof-object? next)
             (printf "Usage: ,expand <form>~n")
             (let ((datum (strip-annotations next)))
               (guard (exn (#t (display-error "expand error" exn)))
                 (let ((compiled (gerbil-compile-top datum)))
                   (pretty-print compiled)
                   (newline)))))))
        ((memq cmd '(dis disassemble))
         (let ((next (gerbil-read (current-input-port))))
           (if (eof-object? next)
             (printf "Usage: ,dis <form>  or  ,dis <name>~n")
             (let* ((datum (strip-annotations next))
                    ;; If datum is a symbol, look up its source definition.
                    ;; Also handle (quote sym) from ,dis 'name
                    (target
                      (cond
                        ((and (symbol? datum)
                              (hashtable-ref *source-registry* datum #f))
                         => (lambda (src) src))
                        ((and (pair? datum) (eq? (car datum) 'quote)
                              (pair? (cdr datum)) (symbol? (cadr datum))
                              (hashtable-ref *source-registry* (cadr datum) #f))
                         => (lambda (src) src))
                        (else datum))))
               (when (and (symbol? datum) (eq? target datum))
                 (printf "Note: ~a not found in source registry; disassembling as expression.~n"
                         datum)
                 (printf "Define it in this REPL session first, then ,dis ~a will show its assembly.~n~n"
                         datum))
               (guard (exn (#t (display-error "dis error" exn)))
                 (let* ((compiled (gerbil-compile-top target))
                        (optimized
                          (parameterize ([print-gensym #f])
                            (expand/optimize compiled repl-env))))
                   (printf "--- Gerbil → Chez ---~n")
                   (parameterize ([print-gensym #f])
                     (pretty-print compiled))
                   (printf "~n--- Chez optimized ---~n")
                   (parameterize ([print-gensym #f])
                     (pretty-print optimized))
                   (printf "~n--- Assembly ---~n")
                   (disassemble compiled)
                   (newline)))))))
        (else
         (printf "Unknown command: ,~a~n" cmd)
         (print-help)))))

  (define (print-help)
    (printf "REPL commands:~n")
    (printf "  ,q ,quit     Exit the REPL~n")
    (printf "  ,h ,help     Show this help~n")
    (printf "  ,load <file> Load and eval a Gerbil file~n")
    (printf "  ,expand <form> Show compiled output~n")
    (printf "  ,dis <form>   Show compiled + optimized + assembly output~n")
    (printf "  ,dis <name>   Disassemble a previously defined function~n"))

  (define (eval-and-print form)
    (guard (exn (#t (display-error "error" exn)))
      ;; Store source for defined names so ,dis can find them later
      (let ((name (defined-name form)))
        (when name
          (hashtable-set! *source-registry* name form)))
      (let ((compiled (gerbil-compile-top form)))
        (call-with-values
          (lambda () (chez:eval compiled repl-env))
          (lambda results
            (for-each
              (lambda (v)
                (unless (or (eq? v the-void) (eq? v the-chez-void))
                  (pretty-print v)
                  (newline)))
              results))))))

  (define the-void (void))
  (define the-chez-void (chez:void))

  (define (display-error label exn)
    (printf "~a: " label)
    (cond
      ((message-condition? exn)
       (display (condition-message exn))
       (when (irritants-condition? exn)
         (for-each (lambda (irr) (display " ") (write irr))
                   (condition-irritants exn)))
       (newline))
      (else
       (display exn)
       (newline))))

  (define (gxi-eval-file path)
    (let* ((forms (gerbil-read-file path))
           (stripped (map strip-annotations forms)))
      (for-each
        (lambda (form)
          (cond
            ((and (pair? form) (eq? (car form) 'export))
             (void))  ;; skip exports in script mode
            ((and (pair? form) (eq? (car form) 'import))
             (eval-import-form form))
            (else
             (let ((name (defined-name form)))
               (when name
                 (hashtable-set! *source-registry* name form)))
             (guard (exn
                      (#t (display-error "warning" exn)))
               (let ((compiled (gerbil-compile-top form)))
                 (chez:eval compiled repl-env))))))
        stripped)))

  ) ;; end library
