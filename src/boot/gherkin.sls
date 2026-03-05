#!chezscheme
;;; gherkin.sls -- Main Gherkin entry point
;;; Provides the top-level compile and run interface.

(library (boot gherkin)
  (export
    gherkin-compile-file
    gherkin-compile-and-eval
    gherkin-compile-string
    gherkin-compile-form
    gherkin-eval-file
    gherkin-make-binary
    )

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise eval compile-file)
            (error chez:error) (raise chez:raise)
            (eval chez:eval) (compile-file chez:compile-file))
    (only (compat gambit-compat) |##keyword?|)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error)
    (runtime hash)
    (runtime syntax)
    (runtime eval)
    (compiler compile))

  ;; --- Compile a Gerbil source file to Chez Scheme ---
  (define (gherkin-compile-file input-path output-path)
    (let ((compiled-forms (gerbil-compile-file input-path)))
      (call-with-output-file output-path
        (lambda (port)
          (for-each
            (lambda (form)
              (pretty-print form port)
              (newline port))
            compiled-forms))
        'replace)))

  ;; --- Compile a string of Gerbil code ---
  (define (gherkin-compile-string code)
    (let ((forms (read-string-forms code)))
      (map gerbil-compile-top forms)))

  (define (read-string-forms str)
    (let ((port (open-input-string str)))
      (let lp ((forms '()))
        (let ((datum (read port)))
          (if (eof-object? datum)
            (reverse forms)
            (lp (cons datum forms)))))))

  ;; --- Compile a single form ---
  (define (gherkin-compile-form form)
    (gerbil-compile-top form))

  ;; --- Compile and evaluate a Gerbil file ---
  (define (gherkin-compile-and-eval input-path)
    (let ((compiled-forms (gerbil-compile-file input-path)))
      (let ((env (interaction-environment)))
        (for-each
          (lambda (form)
            (chez:eval form env))
          compiled-forms))))

  ;; --- Evaluate a Gerbil file directly ---
  (define (gherkin-eval-file input-path)
    (gherkin-compile-and-eval input-path))

  ;; --- Compile to native binary ---
  ;; Creates a Chez Scheme program file and compiles it.
  ;; Uses gerbil-compile-to-program to properly resolve Gerbil imports.
  (define (gherkin-make-binary input-path output-path)
    (let* ((chez-path (string-append output-path ".ss"))
           (program-forms (gerbil-compile-to-program input-path)))
      ;; Write Chez program
      (call-with-output-file chez-path
        (lambda (port)
          (display "#!chezscheme\n" port)
          (parameterize ([print-gensym #f])
            (for-each
              (lambda (form)
                (pretty-print form port)
                (newline port))
              program-forms)))
        'replace)
      ;; Compile with Chez
      (chez:compile-file chez-path)
      (display (string-append "Compiled: " input-path " → " chez-path "\n"))
      chez-path))

  ) ;; end library
