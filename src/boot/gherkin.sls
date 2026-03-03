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
  ;; Creates a Chez Scheme program file and compiles it
  (define (gherkin-make-binary input-path output-path)
    ;; Step 1: Compile Gerbil → Chez
    (let* ((chez-path (string-append output-path ".ss"))
           (compiled-forms (gerbil-compile-file input-path)))
      ;; Step 2: Write Chez program
      (call-with-output-file chez-path
        (lambda (port)
          ;; Add #!chezscheme directive for gensym support
          (display "#!chezscheme\n" port)
          ;; Write import preamble
          (parameterize ([print-gensym #f])
          (pretty-print
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
            port)
          (newline port)
          ;; Write compiled forms
          (for-each
            (lambda (form)
              (pretty-print form port)
              (newline port))
            compiled-forms)))  ;; close parameterize
        'replace)
      ;; Step 3: Compile with Chez
      ;; The output .so file can be loaded or used as a program
      (chez:compile-file chez-path)
      (display (string-append "Compiled: " input-path " → " chez-path "\n"))
      chez-path))

  ) ;; end library
