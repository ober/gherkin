#!chezscheme
;;; test-defsyntax.ss -- Test defsyntax compilation with for-syntax imports
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime c3)
  (runtime control)
  (runtime mop)
  (runtime error)
  (runtime hash)
  (runtime syntax)
  (runtime eval)
  (compiler compile)
  (boot gherkin)
  (tests test-helpers))

(test-begin "Defsyntax & For-Syntax Imports")

;;; ============================================================
;;; Basic defsyntax compilation (regression)
;;; ============================================================

(let ((compiled (gerbil-compile-top
                  '(defsyntax (my-when stx)
                     (syntax-case stx ()
                       ((_ test body ...)
                        #'(if test (begin body ...))))))))
  (test-assert "basic defsyntax compiles to define-syntax"
    (and (pair? compiled)
         (eq? 'define-syntax (car compiled))
         (eq? 'my-when (cadr compiled)))))

;; defsyntax with expression form
(let ((compiled (gerbil-compile-top
                  '(defsyntax my-alias (identifier-syntax cons)))))
  (test-assert "defsyntax expr form compiles"
    (and (pair? compiled)
         (eq? 'define-syntax (car compiled))
         (eq? 'my-alias (cadr compiled)))))

;;; ============================================================
;;; for-syntax import handling in library compilation
;;; ============================================================

;; Test that for-syntax imports are detected and wrapped with (for ... expand)
(let ((lib (gerbil-compile-to-library
             "tests/fixtures/defsyntax-test.ss"
             '(test defsyntax-test))))
  ;; The library should exist and have the right structure
  (test-assert "library with for-syntax compiles"
    (and (pair? lib) (eq? 'library (car lib)))))

;;; ============================================================
;;; defsyntax using stx-identifier (integration)
;;; ============================================================

;; Test that a defsyntax using stx-identifier compiles correctly
(let ((compiled (gerbil-compile-top
                  '(defsyntax (make-getter stx)
                     (syntax-case stx ()
                       ((_ name field)
                        (let ((getter-name (stx-identifier #'name "get-" #'name "-" #'field)))
                          #`(define (#,getter-name obj)
                              (slot-ref obj '#,#'field)))))))))
  (test-assert "defsyntax with stx-identifier compiles"
    (and (pair? compiled)
         (eq? 'define-syntax (car compiled))
         (eq? 'make-getter (cadr compiled)))))

;;; ============================================================
;;; Auto-injection of syntax runtime for defsyntax
;;; ============================================================

;; When a library body contains defsyntax, (for (runtime syntax) expand)
;; should be auto-injected into imports
(let ((lib (gerbil-compile-to-library
             "tests/fixtures/defsyntax-auto.ss"
             '(test defsyntax-auto))))
  (test-assert "auto-inject: library compiles"
    (and (pair? lib) (eq? 'library (car lib))))
  ;; Check the import clause contains (for (runtime syntax) expand)
  (let ((import-clause (caddr (cdr lib))))  ;; (library name (export ...) (import ...))
    (test-assert "auto-inject: has (for (runtime syntax) expand)"
      (exists (lambda (imp)
                (and (pair? imp)
                     (eq? 'for (car imp))
                     (equal? '(runtime syntax) (cadr imp))
                     (eq? 'expand (caddr imp))))
              (cdr import-clause)))))

;;; ============================================================
;;; format-id via std-stxutil
;;; ============================================================

;; Test that format-id compiles through the stxutil compat module
(let ((compiled (gerbil-compile-top
                  '(defsyntax (define-accessor stx)
                     (syntax-case stx ()
                       ((_ type field)
                        (let ((getter (format-id #'type "~a-~a" #'type #'field)))
                          #`(define (#,getter obj)
                              (slot-ref obj '#,#'field)))))))))
  (test-assert "defsyntax with format-id compiles"
    (and (pair? compiled)
         (eq? 'define-syntax (car compiled))
         (eq? 'define-accessor (cadr compiled)))))

;;; ============================================================
;;; End-to-end: defsyntax macro that generates accessor names
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  ;; Import runtime into the eval environment
  (eval '(import
           (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
                   andmap ormap iota last-pair find
                   1+ 1- fx/ fx1+ fx1-
                   error error? raise with-exception-handler identifier?
                   hash-table? make-hash-table)
           (runtime syntax))
        env)

  ;; Define a macro using datum->syntax + string->symbol to generate identifiers
  ;; This is how Gerbil's stx-identifier works at R6RS phase 1:
  ;; datum->syntax creates a proper syntax object from the macro context
  (eval '(define-syntax define-pair
           (lambda (stx)
             (syntax-case stx ()
               ((_ name val1 val2)
                (let ((getter1 (datum->syntax #'name
                                 (string->symbol
                                   (string-append (symbol->string (syntax->datum #'name))
                                                  "-first"))))
                      (getter2 (datum->syntax #'name
                                 (string->symbol
                                   (string-append (symbol->string (syntax->datum #'name))
                                                  "-second")))))
                  #`(begin
                      (define #,getter1 val1)
                      (define #,getter2 val2)))))))
        env)

  ;; Use the macro
  (eval '(define-pair point 10 20) env)

  (test-equal "generated accessor point-first"
    10
    (eval 'point-first env))
  (test-equal "generated accessor point-second"
    20
    (eval 'point-second env)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
