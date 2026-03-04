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
    (boot init))

  (define repl-env (interaction-environment))

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
      repl-env))

  (define (gxi-start args)
    (init-repl-env!)
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
             (printf "Usage: ,dis <form>~n")
             (let ((datum (strip-annotations next)))
               (guard (exn (#t (display-error "dis error" exn)))
                 (let* ((compiled (gerbil-compile-top datum))
                        (optimized
                          (parameterize ([print-gensym #f])
                            (expand/optimize compiled repl-env))))
                   (printf "--- Gerbil → Chez ---~n")
                   (parameterize ([print-gensym #f])
                     (pretty-print compiled))
                   (printf "~n--- Chez optimized ---~n")
                   (parameterize ([print-gensym #f])
                     (pretty-print optimized))
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
    (printf "  ,dis <form>   Show compiled + optimized output~n"))

  (define (eval-and-print form)
    (guard (exn (#t (display-error "error" exn)))
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
          (let ((compiled (gerbil-compile-top form)))
            (chez:eval compiled repl-env)))
        stripped)))

  ) ;; end library
