#!chezscheme
;;; gxc.ss — Gherkin compiler CLI
;;; Compiles Gerbil source files to Chez Scheme output.
;;;
;;; Usage:
;;;   scheme -q --libdirs .:src --program src/tools/gxc.ss [options] file.ss ...
;;;
;;; Options:
;;;   -o DIR      Output directory (default: ./build/)
;;;   -v          Verbose output
;;;   --check     Syntax check only (no output)
;;;   --expand    Show expanded forms (no output file)
;;;   --deps      Show import dependencies

(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table compile-file)
  (rename (only (chezscheme) error) (error chez:error))
  (except (compat gambit-compat) void? absent-obj)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime hash)
  (runtime mop)
  (runtime syntax)
  (only (compiler compile) gerbil-compile-top gerbil-compile-expression
        strip-annotations sanitize-compiled *current-source-dir*)
  (only (reader reader)
        gerbil-read-file annotated-datum? annotated-datum-value annotated-datum-source)
  (module loader))

;; ============================================================
;; Command-line parsing
;; ============================================================

(define *output-dir* "build/")
(define *verbose* #f)
(define *mode* 'compile)  ; 'compile, 'check, 'expand, 'deps
(define *files* '())

(define (parse-args args)
  (let loop ([args args])
    (cond
      [(null? args) (void)]
      [(string=? (car args) "-o")
       (when (pair? (cdr args))
         (set! *output-dir*
           (let ([d (cadr args)])
             (if (and (> (string-length d) 0)
                      (not (char=? (string-ref d (- (string-length d) 1)) #\/)))
               (string-append d "/")
               d)))
         (loop (cddr args)))]
      [(string=? (car args) "--")
       (loop (cdr args))]
      [(string=? (car args) "-v")
       (set! *verbose* #t)
       (loop (cdr args))]
      [(string=? (car args) "--check")
       (set! *mode* 'check)
       (loop (cdr args))]
      [(string=? (car args) "--expand")
       (set! *mode* 'expand)
       (loop (cdr args))]
      [(string=? (car args) "--deps")
       (set! *mode* 'deps)
       (loop (cdr args))]
      [else
       (set! *files* (append *files* (list (car args))))
       (loop (cdr args))])))

;; ============================================================
;; File reading — strip preamble directives
;; ============================================================

(define (read-gerbil-file-stripped path)
  (let ([forms (gerbil-read-file path)])
    (let loop ([forms forms] [result '()])
      (if (null? forms)
        (reverse result)
        (let* ([form (car forms)]
               [val (if (annotated-datum? form)
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
             (loop (cdr forms) (cons form result))]))))))

;; ============================================================
;; Source directory extraction
;; ============================================================

(define (path-directory path)
  (let loop ([i (- (string-length path) 1)])
    (cond
      [(< i 0) "./"]
      [(char=? (string-ref path i) #\/)
       (substring path 0 (+ i 1))]
      [else (loop (- i 1))])))

(define (path-basename path)
  (let loop ([i (- (string-length path) 1)])
    (cond
      [(< i 0) path]
      [(char=? (string-ref path i) #\/)
       (substring path (+ i 1) (string-length path))]
      [else (loop (- i 1))])))

(define (path-strip-ext path)
  (let ([len (string-length path)])
    (let loop ([i (- len 1)])
      (cond
        [(< i 0) path]
        [(char=? (string-ref path i) #\.) (substring path 0 i)]
        [(char=? (string-ref path i) #\/) path]
        [else (loop (- i 1))]))))

;; ============================================================
;; Extract import specs from forms
;; ============================================================

(define (extract-imports forms)
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
          (let ([specs (cdr form)])
            (loop (cdr forms)
                  (append (reverse (map (lambda (s)
                                          (if (annotated-datum? s)
                                            (annotated-datum-value s)
                                            s))
                                        (if (list? specs) specs '())))
                          imports)))
          (loop (cdr forms) imports))))))

;; ============================================================
;; Compilation
;; ============================================================

(define (compile-file path)
  (when *verbose*
    (printf "Compiling ~a...~n" path))
  (let ([src-dir (path-directory path)])
    (guard (exn [#t
      (printf "ERROR: ~a: ~a~n" path
        (if (message-condition? exn) (condition-message exn) exn))
      #f])
      (let* ([forms (read-gerbil-file-stripped path)]
             [stripped (map (lambda (f)
                             (if (annotated-datum? f)
                               (strip-annotations (annotated-datum-value f))
                               (strip-annotations f)))
                           forms)]
             ;; Pre-pass: register defrules/defrule
             [_ (parameterize ([*current-source-dir* src-dir])
                  (for-each
                    (lambda (form)
                      (when (and (pair? form) (memq (car form) '(defrules defrule)))
                        (guard (exn [#t (void)])
                          (gerbil-compile-top form))))
                    stripped))]
             ;; Compile — returns (compiled-forms . error-count)
             [result
              (parameterize ([*current-source-dir* src-dir])
                (let loop ([forms stripped] [acc '()] [errors 0])
                  (if (null? forms)
                    (cons (reverse acc) errors)
                    (let ([form (car forms)])
                      (guard (exn [#t
                        (when *verbose*
                          (printf "  compile error: ~a for ~a~n"
                            (if (message-condition? exn) (condition-message exn) "?")
                            (if (pair? form) (car form) form)))
                        (loop (cdr forms) acc (+ errors 1))])
                        (let ([c (gerbil-compile-top form)])
                          (cond
                            [(and (pair? c) (memq (car c) '(import export)))
                             (loop (cdr forms) acc errors)]
                            [(equal? c '(begin))
                             (loop (cdr forms) acc errors)]
                            [else
                             (loop (cdr forms) (cons c acc) errors)])))))))]
             [compiled-forms (car result)]
             [error-count (cdr result)])
        (case *mode*
          [(check)
           (printf "~a: ~a forms, ~a errors~n" path (length compiled-forms) error-count)
           (zero? error-count)]
          [(expand)
           (printf ";;; ~a — ~a forms~n" path (length compiled-forms))
           (for-each
             (lambda (form)
               (pretty-print (sanitize-compiled form))
               (newline))
             compiled-forms)
           #t]
          [(compile)
           ;; Write output
           (unless (file-exists? *output-dir*)
             (mkdir *output-dir*))
           (let ([out-path (string-append *output-dir*
                             (path-strip-ext (path-basename path)) ".scm")])
             (call-with-output-file out-path
               (lambda (port)
                 (for-each
                   (lambda (form)
                     (pretty-print (sanitize-compiled form) port)
                     (newline port))
                   compiled-forms))
               'replace)
             (printf "~a → ~a (~a forms, ~a errors)~n"
               path out-path (length compiled-forms) error-count)
             #t)]
          [else #t])))))

(define (show-deps path)
  (guard (exn [#t
    (printf "ERROR reading ~a: ~a~n" path
      (if (message-condition? exn) (condition-message exn) exn))])
    (let* ([forms (read-gerbil-file-stripped path)]
           [imports (extract-imports forms)])
      (printf "~a:~n" path)
      (for-each
        (lambda (imp)
          (printf "  ~a~n" imp))
        imports))))

;; ============================================================
;; Main
;; ============================================================

(parse-args (cdr (command-line)))

(when (null? *files*)
  (printf "Usage: gxc [options] file.ss ...~n")
  (printf "Options:~n")
  (printf "  -o DIR      Output directory (default: build/)~n")
  (printf "  -v          Verbose~n")
  (printf "  --check     Syntax check only~n")
  (printf "  --expand    Show expanded forms~n")
  (printf "  --deps      Show dependencies~n")
  (exit 0))

(let ([success 0] [total (length *files*)])
  (for-each
    (lambda (path)
      (case *mode*
        [(deps)
         (show-deps path)
         (set! success (+ success 1))]
        [else
         (when (compile-file path)
           (set! success (+ success 1)))]))
    *files*)
  (when (and (> total 1) (not (eq? *mode* 'deps)))
    (printf "~n~a/~a files compiled successfully~n" success total))
  (unless (= success total)
    (exit 1)))
