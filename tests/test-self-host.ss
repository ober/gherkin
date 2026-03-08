#!chezscheme
;;; test-self-host.ss -- Test compiling Gerbil's own source through gherkin
;;;
;;; This test suite attempts to compile actual Gerbil source files
;;; from ~/mine/gerbil/src/ using gherkin's compiler and run them.

(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (only (compat gambit-compat) void void? |##keyword?| |##keyword->string|)
  (only (compiler compile) gerbil-compile-top gerbil-compile-expression
        strip-annotations)
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

;;; ============================================================
;;; Phase 1: Parse Gerbil source headers
;;; ============================================================

(printf "~n=== Self-Hosting: Parse Gerbil Headers ===~n")

;; Parse prelude:/package:/namespace: headers from a Gerbil .ss file
(define (parse-gerbil-headers port)
  (let loop ([prelude #f] [package #f] [namespace #f])
    (let ([line (get-line port)])
      (cond
        [(eof-object? line) (values prelude package namespace)]
        [(and (>= (string-length line) 8)
              (string=? (substring line 0 8) "prelude:"))
         (loop (string-trim-whitespace (substring line 8 (string-length line)))
               package namespace)]
        [(and (>= (string-length line) 8)
              (string=? (substring line 0 8) "package:"))
         (loop prelude
               (string-trim-whitespace (substring line 8 (string-length line)))
               namespace)]
        [(and (>= (string-length line) 10)
              (string=? (substring line 0 10) "namespace:"))
         (loop prelude package
               (string-trim-whitespace (substring line 10 (string-length line))))]
        ;; Stop at first non-header, non-comment, non-blank line that starts with (
        [(and (> (string-length line) 0)
              (char=? (string-ref line 0) #\())
         (values prelude package namespace)]
        [else (loop prelude package namespace)]))))

(define (string-trim-whitespace s)
  (let* ([len (string-length s)]
         [start (let lp ([i 0])
                  (if (and (< i len) (char-whitespace? (string-ref s i)))
                    (lp (+ i 1)) i))]
         [end (let lp ([i len])
                (if (and (> i start) (char-whitespace? (string-ref s (- i 1))))
                  (lp (- i 1)) i))])
    ;; Strip surrounding quotes if present
    (let ([trimmed (substring s start end)])
      (if (and (>= (string-length trimmed) 2)
               (char=? (string-ref trimmed 0) #\")
               (char=? (string-ref trimmed (- (string-length trimmed) 1)) #\"))
        (substring trimmed 1 (- (string-length trimmed) 1))
        trimmed))))

;; Test header parsing
(let ([test-file (string-append gerbil-src-dir "c3.ss")])
  (when (file-exists? test-file)
    (let-values ([(prelude package namespace)
                  (call-with-input-file test-file parse-gerbil-headers)])
      (check "c3.ss prelude" (string=? prelude "../core"))
      (check "c3.ss package" (string=? package "gerbil/runtime"))
      (check "c3.ss namespace" (string=? namespace "#f")))))

;;; ============================================================
;;; Phase 2: Read and compile Gerbil source files
;;; ============================================================

(printf "~n=== Self-Hosting: Read Gerbil Source ===~n")

;; Read a Gerbil .ss file, skipping the prelude/package/namespace headers
(define (read-gerbil-file path)
  (let ([forms (gerbil-read-file path)])
    ;; Filter out the header pseudo-forms (they're symbols like prelude:)
    (let loop ([forms forms] [result '()])
      (if (null? forms)
        (reverse result)
        (let ([form (car forms)])
          (let ([val (if (annotated-datum? form)
                       (annotated-datum-value form)
                       form)])
            (cond
              ;; Skip keyword objects that look like headers
              ;; The reader returns prelude:, package:, namespace: as keyword objects
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
               ;; Skip this keyword and the next value (the header value)
               (if (null? (cdr forms))
                 (loop (cdr forms) result)
                 (loop (cddr forms) result))]
              [else
               (loop (cdr forms) (cons form result))])))))))

;; Test reading c3.ss
(let ([test-file (string-append gerbil-src-dir "c3.ss")])
  (when (file-exists? test-file)
    (let ([forms (read-gerbil-file test-file)])
      (check "c3.ss has forms" (> (length forms) 0))
      ;; Check we can find an export form (may be after header residue)
      (let ([has-export
             (let loop ([fs forms])
               (if (null? fs) #f
                 (let ([v (if (annotated-datum? (car fs))
                            (annotated-datum-value (car fs))
                            (car fs))])
                   (if (and (pair? v)
                            (let ([head (if (annotated-datum? (car v))
                                          (annotated-datum-value (car v))
                                          (car v))])
                              (eq? head 'export))) #t
                     (loop (cdr fs))))))])
        (check "c3.ss has export form" has-export)))))

;;; ============================================================
;;; Phase 3: Compile Gerbil source through gherkin compiler
;;; ============================================================

(printf "~n=== Self-Hosting: Compile Gerbil c3.ss ===~n")

;; Compile c3.ss with a custom import map for the gerbil runtime context
(let ([test-file (string-append gerbil-src-dir "c3.ss")])
  (when (file-exists? test-file)
    (let ([forms (read-gerbil-file test-file)])
      ;; Strip annotations
      (let ([stripped (map (lambda (f)
                            (if (annotated-datum? f)
                              (strip-annotations (annotated-datum-value f))
                              (strip-annotations f)))
                          forms)])
        ;; Try to compile each form
        (let ([compiled
               (guard (exn [#t (printf "  Compile error: ~a~n" exn) #f])
                 (map (lambda (form)
                        (cond
                          ;; Map relative imports to gherkin runtime
                          [(and (pair? form) (eq? (car form) 'import))
                           (let ([mapped-specs
                                  (map (lambda (spec)
                                         (cond
                                           [(string? spec)
                                            ;; "util" -> (runtime util)
                                            `(runtime ,(string->symbol spec))]
                                           [else spec]))
                                       (cdr form))])
                             `(import ,@mapped-specs))]
                          ;; Compile normally
                          [else (gerbil-compile-top form)]))
                      stripped))])
          (check "c3.ss compiles without error" (and compiled (list? compiled)))
          (when compiled
            ;; Check that the compiled output looks reasonable
            (let ([has-define #f])
              (for-each
                (lambda (form)
                  (when (and (pair? form)
                             (memq (car form) '(define define-values)))
                    (set! has-define #t)))
                compiled)
              (check "c3.ss produces define forms" has-define))

            ;; Try to actually evaluate the compiled forms
            ;; Wrap in a top-level-program context for proper define handling
            (let* ([body-forms (filter (lambda (form)
                                         (and (pair? form)
                                              (not (memq (car form) '(import export)))))
                                       compiled)]
                   [eval-ok
                    (guard (exn [#t
                      (printf "  Eval error: ~a~n"
                        (if (message-condition? exn)
                          (condition-message exn) exn))
                      (when (irritants-condition? exn)
                        (printf "  Irritants: ~a~n" (condition-irritants exn)))
                      #f])
                      ;; Debug: show first few compiled forms
                      (printf "  ~a body forms~n" (length body-forms))
                      (for-each
                        (lambda (form)
                          (printf "  compiled: ~a~n"
                            (let ([s (open-output-string)])
                              (write form s)
                              (let ([str (get-output-string s)])
                                (if (> (string-length str) 120)
                                  (string-append (substring str 0 120) "...")
                                  str)))))
                        (list-head body-forms (min 3 (length body-forms))))
                      ;; Write compiled form to temp file with needed imports
                      (let ([tmp "/tmp/gherkin-c3-compiled.ss"])
                        (call-with-output-file tmp
                          (lambda (port)
                            ;; Add import for runtime utilities
                            (pretty-print
                              '(import
                                 (except (chezscheme) void box box? unbox set-box!
                                         andmap ormap iota last-pair find
                                         1+ 1- fx/ fx1+ fx1-)
                                 (runtime util))
                              port)
                            (newline port)
                            (for-each
                              (lambda (form)
                                (pretty-print form port)
                                (newline port))
                              body-forms))
                          'replace)
                        (load tmp))
                      #t)])
              (check "c3.ss compiled code evaluates" eval-ok)

              ;; If eval succeeded, test that c4-linearize works
              (when eval-ok
                (let ([result
                       (guard (exn [#t
                         (printf "  Run error: ~a~n"
                           (if (message-condition? exn) (condition-message exn) exn))
                         (when (irritants-condition? exn)
                           (printf "  Irritants: ~a~n" (condition-irritants exn)))
                         #f])
                         ;; c4-linearize compiles keyword args as positional:
                         ;; (rhead supers get-precedence-list struct?)
                         ;; Returns 2 values: (precedence-list super-struct)
                         (eval '(let-values ([(pl ss)
                                              (c4-linearize '(a) '(b c)
                                                (lambda (x)
                                                  (case x
                                                    [(b) '(b d)]
                                                    [(c) '(c d)]
                                                    [else (list x)]))
                                                (lambda (x) #f))])
                                  pl)))])
                  (check "c3.ss c4-linearize runs" (and result (list? result)))
                  (when result
                    (check "c3.ss c4-linearize correct" (equal? result '(a b c d)))))))))))))

;;; ============================================================
;;; Phase 4: Compile all Gerbil runtime files
;;; ============================================================

(printf "~n=== Self-Hosting: Compile All Runtime Files ===~n")

(define (try-compile-runtime-file filename)
  (let ([path (string-append gerbil-src-dir filename)])
    (guard (exn [#t (values 0 0 1)])
      (let ([forms (read-gerbil-file path)])
        (let ([stripped (map (lambda (f)
                               (if (annotated-datum? f)
                                 (strip-annotations (annotated-datum-value f))
                                 (strip-annotations f)))
                             forms)])
          (let loop ([forms stripped] [ok 0] [fail 0])
            (if (null? forms)
              (values ok fail 0)
              (let ([form (car forms)])
                (guard (exn [#t (loop (cdr forms) ok (+ fail 1))])
                  (gerbil-compile-top form)
                  (loop (cdr forms) (+ ok 1) fail))))))))))

(define runtime-files
  '("c3.ss" "control.ss" "error.ss" "thread.ss" "interface.ss"
    "loader.ss" "syntax.ss" "eval.ss" "table.ss" "mop.ss"
    "hash.ss" "init.ss" "mop-system-classes.ss" "repl.ss"))

(let loop ([files runtime-files] [total-ok 0] [total-fail 0] [total-rerr 0])
  (if (null? files)
    (begin
      (check "runtime files readable (0 reader errors)" (= total-rerr 0))
      (check "runtime forms compile rate >= 98%"
             (>= (quotient (* 100 total-ok) (max 1 (+ total-ok total-fail))) 98))
      (printf "  Runtime: ~a/~a forms compiled (~a%)~n"
              total-ok (+ total-ok total-fail)
              (quotient (* 100 total-ok) (max 1 (+ total-ok total-fail)))))
    (let-values ([(ok fail rerr) (try-compile-runtime-file (car files))])
      (loop (cdr files)
            (+ total-ok ok)
            (+ total-fail fail)
            (+ total-rerr rerr)))))

;;; ============================================================
;;; Summary
;;; ============================================================

(printf "~n--- Self-Hosting Tests: ~a passed, ~a failed ---~n"
        pass-count fail-count)
