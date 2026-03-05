#!chezscheme
;;; convert.sls -- Convert a Gerbil project into a standalone Gherkin project
;;;
;;; Takes a GitHub URL (e.g. https://github.com/ober/gerbil-shell) and:
;;; 1. Creates a gherkin-<name> directory
;;; 2. Adds the gerbil repo as a git submodule
;;; 3. Analyzes build.ss and gerbil.pkg for modules/package info
;;; 4. Scans .ss files for :std/* imports to determine needed compat modules
;;; 5. Generates all build infrastructure files

(library (tools convert)
  (export gherkin-convert)

  (import (chezscheme))

  ;; ========================================
  ;; String utilities
  ;; ========================================

  (define (string-prefix? prefix str)
    (let ((plen (string-length prefix)))
      (and (<= plen (string-length str))
           (string=? prefix (substring str 0 plen)))))

  (define (string-suffix? suffix str)
    (let ((slen (string-length suffix))
          (len (string-length str)))
      (and (<= slen len)
           (string=? suffix (substring str (- len slen) len)))))

  (define (string-contains str sub)
    (let ((slen (string-length str))
          (sublen (string-length sub)))
      (let lp ((i 0))
        (cond
          ((> (+ i sublen) slen) #f)
          ((string=? sub (substring str i (+ i sublen))) i)
          (else (lp (+ i 1)))))))

  (define (string-split-char str ch)
    (let ((len (string-length str)))
      (let lp ((i 0) (start 0) (result '()))
        (cond
          ((= i len)
           (reverse (cons (substring str start len) result)))
          ((char=? (string-ref str i) ch)
           (lp (+ i 1) (+ i 1) (cons (substring str start i) result)))
          (else (lp (+ i 1) start result))))))

  (define (string-join parts sep)
    (if (null? parts)
      ""
      (let lp ((rest (cdr parts)) (acc (car parts)))
        (if (null? rest) acc
          (lp (cdr rest) (string-append acc sep (car rest)))))))

  (define (string-trim str)
    (let* ((len (string-length str))
           (start (let lp ((i 0))
                    (if (and (< i len) (char-whitespace? (string-ref str i)))
                      (lp (+ i 1)) i)))
           (end (let lp ((i len))
                  (if (and (> i start) (char-whitespace? (string-ref str (- i 1))))
                    (lp (- i 1)) i))))
      (substring str start end)))

  ;; ========================================
  ;; Path utilities
  ;; ========================================

  (define (path-expand file dir)
    (if (or (string=? file "") (char=? (string-ref file 0) #\/))
      file
      (string-append dir "/" file)))

  (define (path-directory path)
    (let lp ((i (- (string-length path) 1)))
      (cond
        ((< i 0) ".")
        ((char=? (string-ref path i) #\/) (substring path 0 i))
        (else (lp (- i 1))))))

  (define (path-strip-directory path)
    (let lp ((i (- (string-length path) 1)))
      (cond
        ((< i 0) path)
        ((char=? (string-ref path i) #\/)
         (substring path (+ i 1) (string-length path)))
        (else (lp (- i 1))))))

  (define (path-strip-extension path)
    (let lp ((i (- (string-length path) 1)))
      (cond
        ((< i 0) path)
        ((char=? (string-ref path i) #\.) (substring path 0 i))
        ((char=? (string-ref path i) #\/) path)
        (else (lp (- i 1))))))

  (define (create-directory* path)
    (unless (or (string=? path "") (string=? path "/") (string=? path "."))
      (let ((parent (path-directory path)))
        (unless (file-exists? parent)
          (create-directory* parent)))
      (unless (file-exists? path)
        (mkdir path))))

  ;; ========================================
  ;; Shell commands
  ;; ========================================

  (define (run-cmd cmd)
    (let ((status (system cmd)))
      (unless (zero? status)
        (error 'run-cmd (format "command failed (~a): ~a" status cmd)))))

  ;; ========================================
  ;; URL parsing
  ;; ========================================

  ;; Parse https://github.com/ober/gerbil-shell → (values "gerbil-shell" "https://github.com/ober/gerbil-shell.git")
  (define (parse-repo-url url)
    (let* ((clean (if (string-suffix? ".git" url)
                    (substring url 0 (- (string-length url) 4))
                    url))
           (clean (if (string-suffix? "/" clean)
                    (substring clean 0 (- (string-length clean) 1))
                    clean))
           (repo-name (path-strip-directory clean))
           (git-url (if (string-suffix? ".git" url)
                      url
                      (string-append url ".git"))))
      (values repo-name git-url)))

  ;; gerbil-shell → shell, gerbil-lsp → lsp
  (define (strip-gerbil-prefix name)
    (if (string-prefix? "gerbil-" name)
      (substring name 7 (string-length name))
      name))

  ;; ========================================
  ;; build.ss parsing
  ;; ========================================

  ;; Read forms from a file, skipping shebang and tolerating Gambit-isms
  (define (read-forms-from-file path)
    (guard (e (#t '()))  ;; If the whole file can't be read, return empty
      (call-with-input-file path
        (lambda (port)
          (let ((first-char (peek-char port)))
            (when (and (char? first-char) (char=? first-char #\#))
              (get-line port)))
          (let lp ((forms '()))
            (let ((form (guard (e (#t
                                   ;; Skip past the problematic form
                                   ;; Try to recover by reading until we find a valid form
                                   (let skip ()
                                     (let ((ch (read-char port)))
                                       (cond
                                         ((eof-object? ch) (eof-object))
                                         ;; Found start of new form
                                         ((char=? ch #\()
                                          (unread-char ch port)
                                          (guard (e (#t (skip)))
                                            (read port)))
                                         (else (skip)))))))
                          (read port))))
              (if (eof-object? form)
                (reverse forms)
                (lp (cons form forms)))))))))

  ;; Extract module list from build.ss
  ;; Returns (values modules exe-spec) where:
  ;;   modules = list of strings
  ;;   exe-spec = (exe: "main" bin: "name" ...) or #f
  (define (parse-build-ss path)
    (if (not (file-exists? path))
      (values '() #f)
      (let ((forms (read-forms-from-file path)))
        ;; Find defbuild-script form
        (let lp ((forms forms))
          (cond
            ((null? forms) (values '() #f))
            ((and (pair? (car forms))
                  (eq? (caar forms) 'defbuild-script))
             ;; First arg is the module list (quoted or direct)
             (let* ((args (cdr (car forms)))
                    (spec-form (car args))
                    (spec (cond
                            ;; (defbuild-script '("a" "b" ...))
                            ((and (pair? spec-form) (eq? (car spec-form) 'quote))
                             (cadr spec-form))
                            ;; (defbuild-script all-modules) — need to evaluate
                            ;; Fall back to scanning for define of the symbol
                            ((symbol? spec-form)
                             (find-symbol-value spec-form forms))
                            ((list? spec-form) spec-form)
                            (else '()))))
               (let split ((items (if (list? spec) spec '()))
                           (mods '()) (exe #f))
                 (cond
                   ((null? items) (values (reverse mods) exe))
                   ((string? (car items))
                    (split (cdr items) (cons (car items) mods) exe))
                   ((and (pair? (car items))
                         (eq? (caar items) 'exe:))
                    (split (cdr items) mods (car items)))
                   (else (split (cdr items) mods exe))))))
            (else (lp (cdr forms))))))))

  ;; Try to resolve a symbol's value from the forms (simple cases only)
  (define (find-symbol-value sym forms)
    (let lp ((forms forms))
      (cond
        ((null? forms) '())
        ((and (pair? (car forms))
              (eq? (caar forms) 'def)
              (pair? (cdar forms))
              (eq? (cadar forms) sym)
              (pair? (cddar forms)))
         (let ((val-form (caddar forms)))
           (cond
             ((and (pair? val-form) (eq? (car val-form) 'quote))
              (cadr val-form))
             ((list? val-form) val-form)
             (else '()))))
        ;; Handle (def sym (append expr1 expr2 ...))
        ;; This is complex; just return empty for now
        (else (lp (cdr forms))))))

  ;; Fallback: scan a directory for .ss files to use as module list
  ;; Excludes build.ss, test files, and other non-module files
  (define (scan-ss-files dir)
    (let ((excluded '("build.ss" "build-deps.ss" "gerbil.pkg")))
      (let walk ((d dir) (prefix ""))
        (if (not (file-exists? d))
          '()
          (let ((entries
                  (filter
                    (lambda (f) (not (string-prefix? "." f)))
                    (directory-list d))))
            (apply append
              (map (lambda (f)
                     (let ((path (path-expand f d)))
                       (cond
                         ;; Recurse into subdirectories (but not _vendor, .git, etc.)
                         ((and (file-directory? path)
                               (not (string-prefix? "_" f)))
                          (walk path (if (string=? prefix "")
                                       (string-append f "/")
                                       (string-append prefix f "/"))))
                         ;; Include .ss files that aren't excluded or test files
                         ((and (string-suffix? ".ss" f)
                               (not (member f excluded))
                               (not (string-suffix? "-test.ss" f))
                               (not (string-suffix? "-bench.ss" f)))
                          (let ((mod-path (string-append prefix
                                            (path-strip-extension f))))
                            (list mod-path)))
                         (else '()))))
                   entries)))))))

  ;; Try to detect the exe target from build.ss text even when parsing fails
  ;; Looks for patterns like: exe: "main" or bin: "gsh"
  (define (detect-exe-from-text path)
    (if (not (file-exists? path))
      (values #f #f)
      (let ((text (call-with-input-file path get-string-all)))
        (let ((exe-mod (find-pattern-value text "exe:"))
              (exe-bin (find-pattern-value text "bin:")))
          (values exe-mod exe-bin)))))

  (define (find-pattern-value text key)
    (let ((pos (string-contains text key)))
      (if (not pos)
        #f
        ;; Skip the key and whitespace, read the next quoted string
        (let* ((start (+ pos (string-length key)))
               (len (string-length text)))
          (let skip-ws ((i start))
            (cond
              ((>= i len) #f)
              ((char-whitespace? (string-ref text i))
               (skip-ws (+ i 1)))
              ((char=? (string-ref text i) #\")
               ;; Read until closing quote
               (let read-str ((j (+ i 1)) (chars '()))
                 (cond
                   ((>= j len) #f)
                   ((char=? (string-ref text j) #\")
                    (list->string (reverse chars)))
                   (else (read-str (+ j 1)
                                   (cons (string-ref text j) chars))))))
              (else #f)))))))

  ;; ========================================
  ;; gerbil.pkg parsing
  ;; ========================================

  (define (parse-gerbil-pkg path)
    (if (not (file-exists? path))
      '()
      (call-with-input-file path
        (lambda (port)
          (let lp ((result '()))
            (let ((form (read port)))
              (if (eof-object? form)
                result
                (lp (append result (if (list? form) form (list form)))))))))))

  (define (pgetq key plist)
    (let lp ((rest plist))
      (cond
        ((null? rest) #f)
        ((eq? (car rest) key) (and (pair? (cdr rest)) (cadr rest)))
        (else (lp (cdr rest))))))

  ;; ========================================
  ;; Import scanning
  ;; ========================================

  ;; Scan all .ss files in a directory tree for (import ...) forms
  ;; Returns a deduplicated list of :std/* imports as symbols
  (define (scan-imports dir)
    (let ((imports (make-hashtable equal-hash equal?)))
      (let walk ((d dir))
        (when (file-exists? d)
          (for-each
            (lambda (f)
              (let ((path (path-expand f d)))
                (cond
                  ((and (not (string-prefix? "." f))
                        (file-directory? path))
                   (walk path))
                  ((string-suffix? ".ss" f)
                   (guard (e (#t #f))
                     (let ((forms (read-forms-from-file path)))
                       (for-each
                         (lambda (form)
                           (when (and (pair? form) (eq? (car form) 'import))
                             (for-each
                               (lambda (imp)
                                 (when (symbol? imp)
                                   (let ((s (symbol->string imp)))
                                     (when (string-prefix? ":std/" s)
                                       (hashtable-set! imports imp #t))
                                     (when (string-prefix? ":gerbil/" s)
                                       (hashtable-set! imports imp #t)))))
                               (cdr form))))
                         forms)))))))
            (directory-list d))))
      (vector->list (hashtable-keys imports))))

  ;; ========================================
  ;; Determine needed compat modules from imports
  ;; ========================================

  ;; Map :std/* imports to compat module needs
  (define (determine-compat-needs imports)
    ;; Always needed
    (let ((needs (make-hashtable equal-hash equal?)))
      ;; Always need these base compat modules
      (hashtable-set! needs 'gambit #t)
      (hashtable-set! needs 'misc #t)
      (hashtable-set! needs 'sort #t)
      (hashtable-set! needs 'sugar #t)
      (hashtable-set! needs 'format #t)
      (hashtable-set! needs 'types #t)   ;; gherkin runtime
      ;; Scan imports for additional needs
      (for-each
        (lambda (imp)
          (let ((s (symbol->string imp)))
            (cond
              ((string-prefix? ":std/pregexp" s) (hashtable-set! needs 'pregexp #t))
              ((string-prefix? ":std/os/signal-handler" s) (hashtable-set! needs 'signal-handler #t))
              ((string-prefix? ":std/os/signal" s) (hashtable-set! needs 'signal #t))
              ((string-prefix? ":std/os/fdio" s) (hashtable-set! needs 'fdio #t))
              ((string-prefix? ":std/text/json" s) (hashtable-set! needs 'json #t))
              ((string-prefix? ":std/cli/getopt" s) (hashtable-set! needs 'getopt #t))
              ((string-prefix? ":std/misc/process" s) (hashtable-set! needs 'process #t)))))
        (if (list? imports) imports (vector->list imports)))
      (vector->list (hashtable-keys needs))))

  ;; ========================================
  ;; Import map generation
  ;; ========================================

  ;; Generate the import map entries based on detected imports
  (define (generate-import-map imports pkg-name)
    (let ((entries '()))
      ;; Standard library mappings — always include the basics
      (set! entries (append entries
        '((:std/sugar        . (compat sugar))
          (:std/format       . (compat format))
          (:std/sort         . (compat sort))
          (:std/misc/string  . (compat misc))
          (:std/misc/list    . (compat misc))
          (:std/misc/path    . (compat misc))
          (:std/misc/hash    . (compat misc))
          (:std/iter         . #f)
          (:std/error        . (runtime error))
          (:std/srfi/1       . (compat misc))
          (:std/foreign      . #f)
          (:std/build-script . #f)
          (:std/test         . #f)
          ;; Gerbil runtime — always strip
          (:gerbil/core      . #f)
          (:gerbil/runtime   . #f)
          (:gerbil/runtime/init . #f)
          (:gerbil/runtime/loader . #f)
          (:gerbil/expander   . #f)
          (:gerbil/compiler   . #f))))
      ;; Conditional imports based on what the project actually uses
      (for-each
        (lambda (imp)
          (let ((s (if (symbol? imp) (symbol->string imp) "")))
            (cond
              ((string=? s ":std/pregexp")
               (set! entries (cons '(:std/pregexp . (compat pregexp)) entries)))
              ((string=? s ":std/os/signal")
               (set! entries (cons '(:std/os/signal . (compat signal)) entries)))
              ((string=? s ":std/os/signal-handler")
               (set! entries (cons '(:std/os/signal-handler . (compat signal-handler)) entries)))
              ((string=? s ":std/os/fdio")
               (set! entries (cons '(:std/os/fdio . (compat fdio)) entries)))
              ((string=? s ":std/text/json")
               (set! entries (cons '(:std/text/json . (compat json)) entries)))
              ((string=? s ":std/cli/getopt")
               (set! entries (cons '(:std/cli/getopt . (compat getopt)) entries)))
              ((string=? s ":std/misc/process")
               (set! entries (cons '(:std/misc/process . (compat process)) entries)))
              ((string=? s ":std/misc/ports")
               (set! entries (cons `(:std/misc/ports . (,pkg-name compat)) entries))))))
        imports)
      (reverse entries)))

  ;; ========================================
  ;; File generation
  ;; ========================================

  (define (write-file path content)
    (create-directory* (path-directory path))
    (call-with-output-file path
      (lambda (port) (display content port))
      'replace))

  ;; Generate .gitignore
  (define (gen-gitignore project-dir binary-name modules pkg-sym)
    (let ((p (open-output-string)))
      (display "# Build artifacts\n*.so\n*.wpo\n*.o\n*.boot\n" p)
      (fprintf p "~a~n" binary-name)
      (fprintf p "~a_program.h~n" (string-replace-char binary-name #\- #\_))
      (fprintf p "~a-all.so~n" binary-name)
      (display "\n# Auto-generated .sls files\n" p)
      (for-each
        (lambda (mod)
          (fprintf p "src/~a/~a.sls~n" pkg-sym mod))
        modules)
      (display "\n# Cache\n.gerbil-lsp-cache/\n" p)
      (get-output-string p)))

  (define (string-replace-char str old new)
    (let* ((len (string-length str))
           (result (make-string len)))
      (let lp ((i 0))
        (when (< i len)
          (string-set! result i
            (if (char=? (string-ref str i) old) new (string-ref str i)))
          (lp (+ i 1))))
      result))

  ;; Generate build-all.ss
  (define (gen-build-all modules pkg-sym)
    (let ((p (open-output-string)))
      (display "#!chezscheme\n;; Build driver: imports all modules to trigger Chez compilation\n(import\n" p)
      (for-each
        (lambda (mod)
          (fprintf p "  (~a ~a)" pkg-sym (string->symbol mod))
          (newline p))
        modules)
      (display ")\n" p)
      (get-output-string p)))

  ;; Generate entry point .ss file
  (define (gen-entry-ss pkg-sym main-mod arg-prefix binary-name)
    (let ((p (open-output-string)))
      (display "#!chezscheme\n" p)
      (fprintf p ";; Entry point for gherkin-~a~n" pkg-sym)
      (fprintf p "(import (chezscheme)~n        (~a ~a))~n~n" pkg-sym main-mod)
      (fprintf p ";; Get args from ~a_ARGC/~a_ARGn env vars (set by ~a-main.c)~n"
               arg-prefix arg-prefix binary-name)
      (display ";; or fall back to (command-line) for interpreted mode.\n" p)
      (display "(define (get-real-args)\n" p)
      (fprintf p "  (let ((argc-str (getenv \"~a_ARGC\")))~n" arg-prefix)
      (display "    (if argc-str\n" p)
      (display "      (let ((argc (string->number argc-str)))\n" p)
      (display "        (let loop ((i 0) (acc '()))\n" p)
      (display "          (if (>= i argc)\n" p)
      (display "            (reverse acc)\n" p)
      (fprintf p "            (let ((val (getenv (format \"~a_ARG~~a\" i))))~n" arg-prefix)
      (display "              (loop (+ i 1) (cons (or val \"\") acc))))))\n" p)
      (display "      (let ((cmdline (command-line)))\n" p)
      (display "        (if (pair? cmdline) (cdr cmdline) '())))))\n\n" p)
      (display "(apply main (get-real-args))\n" p)
      (get-output-string p)))

  ;; Generate C main file
  (define (gen-c-main binary-name arg-prefix)
    (let ((p (open-output-string))
          (c-prefix (string-replace-char binary-name #\- #\_)))
      (fprintf p "/*~n * ~a-main.c — Custom entry point for ~a.~n *~n" binary-name binary-name)
      (display " * Boot files (petite.boot, scheme.boot, app.boot) are embedded as C byte\n" p)
      (display " * arrays and registered via Sregister_boot_file_bytes.\n *\n" p)
      (display " * Threading workaround: Programs in boot files cannot create threads\n" p)
      (display " * (Chez bug). The program is loaded separately via Sscheme_script on a memfd.\n */\n\n" p)
      (display "#define _GNU_SOURCE\n" p)
      (display "#include <stdlib.h>\n#include <string.h>\n#include <stdio.h>\n" p)
      (display "#include <unistd.h>\n#include <sys/mman.h>\n" p)
      (display "#include \"scheme.h\"\n" p)
      (fprintf p "#include \"~a_program.h\"~n" c-prefix)
      (fprintf p "#include \"~a_petite_boot.h\"~n" c-prefix)
      (fprintf p "#include \"~a_scheme_boot.h\"~n" c-prefix)
      (fprintf p "#include \"~a_app_boot.h\"~n~n" c-prefix)
      (display "int main(int argc, char *argv[]) {\n" p)
      (fprintf p "    char countbuf[32];~n")
      (fprintf p "    snprintf(countbuf, sizeof(countbuf), \"%d\", argc - 1);~n")
      (fprintf p "    setenv(\"~a_ARGC\", countbuf, 1);~n~n" arg-prefix)
      (display "    for (int i = 1; i < argc; i++) {\n" p)
      (display "        char name[32];\n" p)
      (fprintf p "        snprintf(name, sizeof(name), \"~a_ARG%d\", i - 1);~n" arg-prefix)
      (display "        setenv(name, argv[i], 1);\n    }\n\n" p)
      (fprintf p "    int fd = memfd_create(\"~a-program\", MFD_CLOEXEC);~n" binary-name)
      (display "    if (fd < 0) { perror(\"memfd_create\"); return 1; }\n" p)
      (fprintf p "    if (write(fd, ~a_program_data, ~a_program_size) != (ssize_t)~a_program_size) {~n"
               c-prefix c-prefix c-prefix)
      (display "        perror(\"write memfd\"); close(fd); return 1;\n    }\n" p)
      (display "    char prog_path[64];\n" p)
      (display "    snprintf(prog_path, sizeof(prog_path), \"/proc/self/fd/%d\", fd);\n\n" p)
      (display "    Sscheme_init(NULL);\n" p)
      (display "    Sregister_boot_file_bytes(\"petite\", (void*)petite_boot_data, petite_boot_size);\n" p)
      (display "    Sregister_boot_file_bytes(\"scheme\", (void*)scheme_boot_data, scheme_boot_size);\n" p)
      (fprintf p "    Sregister_boot_file_bytes(\"app\", (void*)~a_app_boot_data, ~a_app_boot_size);~n~n"
               c-prefix c-prefix)
      (display "    Sbuild_heap(NULL, NULL);\n" p)
      (display "    const char *script_args[] = { argv[0] };\n" p)
      (display "    int status = Sscheme_script(prog_path, 1, script_args);\n\n" p)
      (display "    close(fd);\n    Sscheme_deinit();\n    return status;\n}\n" p)
      (get-output-string p)))

  ;; Generate build-binary.ss
  (define (gen-build-binary entry-ss binary-name modules compat-modules pkg-sym)
    (let ((p (open-output-string))
          (c-prefix (string-replace-char binary-name #\- #\_)))
      (display "#!chezscheme\n" p)
      (fprintf p ";; Build a native ~a binary.~n" binary-name)
      (fprintf p ";;~n;; Usage: cd gherkin-~a && make binary~n~n" (strip-gerbil-prefix binary-name))
      (display "(import (chezscheme))\n\n" p)

      ;; file->c-header helper
      (display ";; --- Helper: generate C header from binary file ---\n" p)
      (display "(define (file->c-header input-path output-path array-name size-name)\n" p)
      (display "  (let* ((port (open-file-input-port input-path))\n" p)
      (display "         (data (get-bytevector-all port))\n" p)
      (display "         (size (bytevector-length data)))\n" p)
      (display "    (close-port port)\n" p)
      (display "    (call-with-output-file output-path\n" p)
      (display "      (lambda (out)\n" p)
      (display "        (fprintf out \"/* Auto-generated */~n\")\n" p)
      (display "        (fprintf out \"static const unsigned char ~a[] = {~n\" array-name)\n" p)
      (display "        (let loop ((i 0))\n" p)
      (display "          (when (< i size)\n" p)
      (display "            (when (= 0 (modulo i 16)) (fprintf out \"  \"))\n" p)
      (display "            (fprintf out \"0x~2,'0x\" (bytevector-u8-ref data i))\n" p)
      (display "            (when (< (+ i 1) size) (fprintf out \",\"))\n" p)
      (display "            (when (= 15 (modulo i 16)) (fprintf out \"~n\"))\n" p)
      (display "            (loop (+ i 1))))\n" p)
      (display "        (fprintf out \"~n};~n\")\n" p)
      (display "        (fprintf out \"static const unsigned int ~a = ~a;~n\" size-name size))\n" p)
      (display "      'replace)\n" p)
      (display "    (printf \"  ~a: ~a bytes~n\" output-path size)))\n\n" p)

      ;; Chez dir detection
      (display ";; --- Locate Chez install directory ---\n" p)
      (display "(define chez-dir\n" p)
      (display "  (or (getenv \"CHEZ_DIR\")\n" p)
      (display "      (let* ((mt (symbol->string (machine-type)))\n" p)
      (display "             (home (getenv \"HOME\"))\n" p)
      (display "             (lib-dir (format \"~a/.local/lib\" home))\n" p)
      (display "             (csv-dir\n" p)
      (display "               (let lp ((dirs (guard (e (#t '())) (directory-list lib-dir))))\n" p)
      (display "                 (cond\n" p)
      (display "                   ((null? dirs) #f)\n" p)
      (display "                   ((and (> (string-length (car dirs)) 3)\n" p)
      (display "                         (string=? \"csv\" (substring (car dirs) 0 3)))\n" p)
      (display "                    (format \"~a/~a/~a\" lib-dir (car dirs) mt))\n" p)
      (display "                   (else (lp (cdr dirs)))))))\n" p)
      (display "        (and csv-dir\n" p)
      (display "             (file-exists? (format \"~a/main.o\" csv-dir))\n" p)
      (display "             csv-dir))))\n\n" p)
      (display "(unless chez-dir\n  (display \"Error: Cannot find Chez install dir. Set CHEZ_DIR.\\n\")\n  (exit 1))\n\n" p)

      ;; Gherkin dir detection
      (display ";; --- Locate gherkin runtime ---\n" p)
      (display "(define gherkin-dir\n  (or (getenv \"GHERKIN_DIR\")\n" p)
      (display "      (let ((home (getenv \"HOME\")))\n" p)
      (display "        (format \"~a/mine/gherkin/src\" home))))\n\n" p)
      (display "(unless (file-exists? (format \"~a/compat/types.so\" gherkin-dir))\n" p)
      (display "  (printf \"Error: Cannot find gherkin runtime at ~a~n\" gherkin-dir)\n  (exit 1))\n\n" p)
      (display "(printf \"Chez dir:    ~a~n\" chez-dir)\n" p)
      (display "(printf \"Gherkin dir: ~a~n\" gherkin-dir)\n\n" p)

      ;; Step 1: Compile
      (fprintf p "(printf \"~n[1/6] Compiling all modules...~n\")~n")
      (display "(parameterize ([compile-imported-libraries #t])\n" p)
      (fprintf p "  (compile-program \"~a\"))~n~n" entry-ss)

      ;; Step 2: Bundle
      (fprintf p "(printf \"[2/6] Using compiled program...~n\")~n")
      (let ((base (path-strip-extension entry-ss)))
        (fprintf p "(system \"cp ~a.so ~a-all.so\")~n~n" base binary-name))

      ;; Step 3: Boot file
      (fprintf p "(printf \"[3/6] Creating libs-only boot file...~n\")~n")
      (fprintf p "(apply make-boot-file \"~a.boot\" '(\"scheme\" \"petite\")~n" binary-name)
      (display "  (append\n" p)
      ;; Gherkin runtime
      (display "    (list\n" p)
      (for-each
        (lambda (mod)
          (fprintf p "      (format \"~~a/~a.so\" gherkin-dir)~n" mod))
        '("compat/types" "compat/gambit-compat"
          "runtime/util" "runtime/table" "runtime/c3" "runtime/mop"
          "runtime/error" "runtime/hash"
          "runtime/syntax" "runtime/eval"
          "reader/reader" "compiler/compile" "boot/gherkin"))
      (display "    )\n" p)
      ;; Compat layer
      (display "    (map (lambda (m) (format \"src/compat/~a.so\" m))\n" p)
      (fprintf p "      '(~a))~n"
               (string-join (map symbol->string compat-modules) " "))
      ;; App modules
      (fprintf p "    (map (lambda (m) (format \"src/~a/~~a.so\" m))~n" pkg-sym)
      (fprintf p "      '(~a))))~n~n"
               (string-join modules " "))

      ;; Step 4: Embed
      (fprintf p "(printf \"[4/6] Embedding boot files + program as C headers...~n\")~n")
      (fprintf p "(file->c-header \"~a-all.so\" \"~a_program.h\"~n" binary-name c-prefix)
      (fprintf p "                \"~a_program_data\" \"~a_program_size\")~n" c-prefix c-prefix)
      (fprintf p "(file->c-header (format \"~~a/petite.boot\" chez-dir) \"~a_petite_boot.h\"~n" c-prefix)
      (display "                \"petite_boot_data\" \"petite_boot_size\")\n" p)
      (fprintf p "(file->c-header (format \"~~a/scheme.boot\" chez-dir) \"~a_scheme_boot.h\"~n" c-prefix)
      (display "                \"scheme_boot_data\" \"scheme_boot_size\")\n" p)
      (fprintf p "(file->c-header \"~a.boot\" \"~a_app_boot.h\"~n" binary-name c-prefix)
      (fprintf p "                \"~a_app_boot_data\" \"~a_app_boot_size\")~n~n" c-prefix c-prefix)

      ;; Step 5: Compile + link
      (fprintf p "(printf \"[5/6] Compiling and linking...~n\")~n")
      (fprintf p "(let ((cmd (format \"gcc -c -O2 -o ~a-main.o ~a-main.c -I~~a -I. -Wall 2>&1\" chez-dir)))~n"
               binary-name binary-name)
      (display "  (unless (= 0 (system cmd))\n    (display \"Error: C compilation failed\\n\")\n    (exit 1)))\n" p)
      (fprintf p "(let ((cmd (format \"gcc -rdynamic -o ~a ~a-main.o -L~~a -lkernel -llz4 -lz -lm -ldl -lpthread -luuid -lncurses -Wl,-rpath,~~a\"~n"
               binary-name binary-name)
      (display "             chez-dir chez-dir)))\n" p)
      (display "  (printf \"  ~a~n\" cmd)\n" p)
      (display "  (unless (= 0 (system cmd))\n    (display \"Error: Link failed\\n\")\n    (exit 1)))\n\n" p)

      ;; Step 6: Cleanup
      (fprintf p "(printf \"[6/6] Cleaning up...~n\")~n")
      (display "(for-each (lambda (f)\n            (when (file-exists? f) (delete-file f)))\n" p)
      (fprintf p "  '(\"~a-main.o\" \"~a_program.h\"~n" binary-name c-prefix)
      (fprintf p "    \"~a_petite_boot.h\" \"~a_scheme_boot.h\" \"~a_app_boot.h\"~n"
               c-prefix c-prefix c-prefix)
      (let ((base (path-strip-extension entry-ss)))
        (fprintf p "    \"~a-all.so\" \"~a.so\" \"~a.wpo\" \"~a.boot\"))~n~n" binary-name base base binary-name))

      (fprintf p "(printf \"~n========================================~n\")~n")
      (fprintf p "(printf \"Build complete!~n~n\")~n")
      (fprintf p "(printf \"  Binary: ./~a  (~~a KB)~n\"~n" binary-name)
      (fprintf p "  (quotient (file-length (open-file-input-port \"~a\")) 1024))~n" binary-name)
      (get-output-string p)))

  ;; Generate build-gherkin.ss
  (define (gen-build-gherkin submodule-name pkg-sym modules import-map-entries compat-modules)
    (let ((p (open-output-string)))
      (display "#!chezscheme\n" p)
      (fprintf p ";;; build-gherkin.ss — Compile ~a .ss modules to .sls via Gherkin compiler~n" submodule-name)
      (display ";;; Usage: scheme -q --libdirs src:<gherkin-path> --compile-imported-libraries < build-gherkin.ss\n\n" p)

      ;; Imports
      (display "(import\n  (except (chezscheme) void box box? unbox set-box!\n" p)
      (display "          andmap ormap iota last-pair find\n" p)
      (display "          1+ 1- fx/ fx1+ fx1-\n" p)
      (display "          error error? raise with-exception-handler identifier?\n" p)
      (display "          hash-table? make-hash-table)\n  (compiler compile))\n\n" p)

      ;; Config
      (fprintf p "(define submodule-dir \"~a\")~n" submodule-name)
      (fprintf p "(define output-dir \"src/~a\")~n~n" pkg-sym)

      ;; find-source
      (display "(define (find-source path)\n" p)
      (display "  (let ((local (string-append \"./\" path))\n" p)
      (display "        (sub   (string-append submodule-dir \"/\" path)))\n" p)
      (display "    (cond\n      ((file-exists? local) local)\n      ((file-exists? sub)   sub)\n" p)
      (display "      (else (error 'find-source \"source file not found\" path)))))\n\n" p)

      ;; Import map
      (fprintf p "(define ~a-import-map~n  '(" pkg-sym)
      (fprintf p "(*default-package* . ~a)~n" pkg-sym)
      (for-each
        (lambda (entry)
          (fprintf p "    (~a . ~a)~n" (car entry) (cdr entry)))
        import-map-entries)
      (display "    ))\n\n" p)

      ;; Base imports
      (fprintf p "(define ~a-base-imports~n" pkg-sym)
      (display "  '((except (chezscheme) box box? unbox set-box!\n" p)
      (display "            andmap ormap iota last-pair find\n" p)
      (display "            1+ 1- fx/ fx1+ fx1-\n" p)
      (display "            error error? raise with-exception-handler identifier?\n" p)
      (display "            hash-table? make-hash-table\n" p)
      (display "            sort sort! path-extension\n" p)
      (display "            printf fprintf\n" p)
      (display "            file-directory? file-exists? getenv close-port\n" p)
      (display "            void\n" p)
      (display "            open-output-file open-input-file)\n" p)
      (display "    (compat types)\n" p)
      (display "    (except (runtime util)\n" p)
      (display "            string->bytes bytes->string\n" p)
      (display "            string-split string-join find string-index\n" p)
      (display "            pgetq pgetv pget)\n" p)
      (display "    (except (runtime table) string-hash)\n" p)
      (display "    (runtime mop)\n" p)
      (display "    (except (runtime error) with-catch with-exception-catcher)\n" p)
      (display "    (runtime hash)\n" p)
      (display "    (except (compat gambit) number->string make-mutex\n" p)
      (display "            with-output-to-string)\n" p)
      (display "    (compat misc)))\n\n" p)

      ;; Import conflict resolution (standard boilerplate)
      (display ";; --- Import conflict resolution ---\n" p)
      (display "(define (fix-import-conflicts lib-form)\n" p)
      (display "  (let* ((lib-name (cadr lib-form))\n" p)
      (display "         (export-clause (caddr lib-form))\n" p)
      (display "         (import-clause (cadddr lib-form))\n" p)
      (display "         (body (cddddr lib-form))\n" p)
      (display "         (imports (cdr import-clause))\n" p)
      (display "         (local-defs\n" p)
      (display "           (let lp ((forms body) (names '()))\n" p)
      (display "             (if (null? forms) names\n" p)
      (display "               (lp (cdr forms) (append (extract-def-names (car forms)) names)))))\n" p)
      (display "         (all-earlier-names\n" p)
      (display "           (let lp ((imps imports) (seen '()) (result '()))\n" p)
      (display "             (if (null? imps) (reverse result)\n" p)
      (display "               (let* ((imp (car imps))\n" p)
      (display "                      (lib (get-import-lib-name imp))\n" p)
      (display "                      (exports (if lib\n" p)
      (display "                                 (or (begin (ensure-library-loaded lib)\n" p)
      (display "                                       (guard (e (#t #f)) (library-exports lib)))\n" p)
      (display "                                     (read-sls-exports lib) '()) '()))\n" p)
      (display "                      (provided (cond\n" p)
      (display "                                  ((and (pair? imp) (eq? (car imp) 'except))\n" p)
      (display "                                   (filter (lambda (s) (not (memq s (cddr imp)))) exports))\n" p)
      (display "                                  ((and (pair? imp) (eq? (car imp) 'only)) (cddr imp))\n" p)
      (display "                                  (else exports))))\n" p)
      (display "                 (lp (cdr imps) (append provided seen) (cons seen result)))))))\n" p)
      (display "    (let ((fixed-imports\n" p)
      (display "            (map (lambda (imp earlier-names)\n" p)
      (display "                   (fix-one-import imp (append local-defs earlier-names)))\n" p)
      (display "                 imports all-earlier-names)))\n" p)
      (display "      (let ((fixed-body (fix-assigned-exports (cdr export-clause)\n" p)
      (display "                          (list (cons 'import fixed-imports)) body)))\n" p)
      (display "        `(library ,lib-name ,export-clause\n" p)
      (display "          (import ,@fixed-imports) ,@fixed-body)))))\n\n" p)

      ;; fix-assigned-exports
      (display "(define (fix-assigned-exports exports import-forms body)\n" p)
      (display "  (let ((assigned-names\n" p)
      (display "          (let lp ((tree body) (names '()))\n" p)
      (display "            (cond ((not (pair? tree)) names)\n" p)
      (display "              ((and (eq? (car tree) 'set!) (pair? (cdr tree))\n" p)
      (display "                    (symbol? (cadr tree)) (memq (cadr tree) exports)\n" p)
      (display "                    (not (memq (cadr tree) names)))\n" p)
      (display "               (cons (cadr tree) names))\n" p)
      (display "              (else (lp (cdr tree) (lp (car tree) names)))))))\n" p)
      (display "    (if (null? assigned-names) body\n" p)
      (display "      (let ((new-body\n" p)
      (display "              (let lp ((forms body) (result '()))\n" p)
      (display "                (if (null? forms) (reverse result)\n" p)
      (display "                  (let ((form (car forms)))\n" p)
      (display "                    (cond\n" p)
      (display "                      ((and (pair? form) (eq? (car form) 'define)\n" p)
      (display "                            (let ((def-name (if (pair? (cadr form)) (caadr form) (cadr form))))\n" p)
      (display "                              (and (symbol? def-name) (memq def-name assigned-names))))\n" p)
      (display "                       (let* ((def-name (if (pair? (cadr form)) (caadr form) (cadr form)))\n" p)
      (display "                              (init (if (pair? (cadr form))\n" p)
      (display "                                      `(lambda ,(cdadr form) ,@(cddr form))\n" p)
      (display "                                      (if (pair? (cddr form)) (caddr form) '(void))))\n" p)
      (display "                              (cell-name (string->symbol\n" p)
      (display "                                           (string-append (symbol->string def-name) \"-cell\"))))\n" p)
      (display "                         (lp (cdr forms)\n" p)
      (display "                             (append (list\n" p)
      (display "                                       `(define-syntax ,def-name\n" p)
      (display "                                          (identifier-syntax\n" p)
      (display "                                            (id (vector-ref ,cell-name 0))\n" p)
      (display "                                            ((set! id v) (vector-set! ,cell-name 0 v))))\n" p)
      (display "                                       `(define ,cell-name (vector ,init)))\n" p)
      (display "                                     result))))\n" p)
      (display "                      (else (lp (cdr forms) (cons form result)))))))))\n" p)
      (display "        new-body))))\n\n" p)

      ;; extract-def-names, ensure-library-loaded, etc.
      (display "(define (extract-def-names form)\n" p)
      (display "  (cond ((not (pair? form)) '())\n" p)
      (display "    ((eq? (car form) 'define)\n" p)
      (display "     (cond ((symbol? (cadr form)) (list (cadr form)))\n" p)
      (display "       ((pair? (cadr form)) (list (caadr form))) (else '())))\n" p)
      (display "    ((eq? (car form) 'define-syntax)\n" p)
      (display "     (if (symbol? (cadr form)) (list (cadr form)) '()))\n" p)
      (display "    ((eq? (car form) 'begin)\n" p)
      (display "     (let lp ((forms (cdr form)) (names '()))\n" p)
      (display "       (if (null? forms) names\n" p)
      (display "         (lp (cdr forms) (append (extract-def-names (car forms)) names)))))\n" p)
      (display "    (else '())))\n\n" p)

      (display "(define (ensure-library-loaded lib-name)\n" p)
      (display "  (guard (e (#t #f)) (eval `(import ,lib-name) (interaction-environment)) #t))\n\n" p)

      (display "(define (read-sls-exports lib-name)\n" p)
      (display "  (let ((path (lib-name->sls-path lib-name)))\n" p)
      (display "    (if (and path (file-exists? path))\n" p)
      (display "      (guard (e (#t #f))\n" p)
      (display "        (call-with-input-file path\n" p)
      (display "          (lambda (port)\n" p)
      (display "            (let ((first (read port)))\n" p)
      (display "              (let ((lib-form (if (and (pair? first) (eq? (car first) 'library))\n" p)
      (display "                                first (read port))))\n" p)
      (display "                (if (and (pair? lib-form) (eq? (car lib-form) 'library))\n" p)
      (display "                  (let ((export-clause (caddr lib-form)))\n" p)
      (display "                    (if (and (pair? export-clause) (eq? (car export-clause) 'export))\n" p)
      (display "                      (cdr export-clause) #f)) #f))))))\n" p)
      (display "      #f)))\n\n" p)

      (display "(define (lib-name->sls-path lib-name)\n" p)
      (display "  (cond\n" p)
      (fprintf p "    ((and (pair? lib-name) (= (length lib-name) 2) (eq? (car lib-name) '~a))~n" pkg-sym)
      (fprintf p "     (string-append output-dir \"/\" (symbol->string (cadr lib-name)) \".sls\"))~n")
      (display "    ((and (pair? lib-name) (= (length lib-name) 2) (eq? (car lib-name) 'compat))\n" p)
      (display "     (string-append \"src/compat/\" (symbol->string (cadr lib-name)) \".sls\"))\n" p)
      (display "    (else #f)))\n\n" p)

      (display "(define (fix-one-import imp local-defs)\n" p)
      (display "  (let ((lib-name (get-import-lib-name imp)))\n" p)
      (display "    (if (not lib-name) imp\n" p)
      (display "      (let* ((_load (ensure-library-loaded lib-name))\n" p)
      (display "             (lib-exports (or (guard (e (#t #f)) (library-exports lib-name))\n" p)
      (display "                              (read-sls-exports lib-name) '()))\n" p)
      (display "             (conflicts (filter (lambda (d) (memq d lib-exports)) local-defs)))\n" p)
      (display "        (if (null? conflicts) imp\n" p)
      (display "          (cond\n" p)
      (display "            ((and (pair? imp) (eq? (car imp) 'except))\n" p)
      (display "             (let ((existing (cddr imp)))\n" p)
      (display "               `(except ,(cadr imp) ,@existing\n" p)
      (display "                  ,@(filter (lambda (d) (not (memq d existing))) conflicts))))\n" p)
      (display "            ((and (pair? imp) (eq? (car imp) 'only))\n" p)
      (display "             `(only ,(cadr imp) ,@(filter (lambda (s) (not (memq s conflicts))) (cddr imp))))\n" p)
      (display "            ((pair? imp) `(except ,imp ,@conflicts))\n" p)
      (display "            (else imp)))))))\n\n" p)

      (display "(define (get-import-lib-name spec)\n" p)
      (display "  (cond\n    ((and (pair? spec) (memq (car spec) '(except only rename prefix)))\n" p)
      (display "     (get-import-lib-name (cadr spec)))\n" p)
      (display "    ((and (pair? spec) (symbol? (car spec))) spec)\n    (else #f)))\n\n" p)

      ;; compile-module
      (display ";; --- Module compilation ---\n" p)
      (display "(define (compile-module source-path flat-name)\n" p)
      (display "  (let* ((input-path (find-source source-path))\n" p)
      (fprintf p "         (output-path (string-append output-dir \"/\" flat-name \".sls\"))~n")
      (fprintf p "         (lib-name `(~a ,(string->symbol flat-name))))~n" pkg-sym)
      (display "    (display (string-append \"  Compiling: \" input-path \" → \" flat-name \".sls\\n\"))\n" p)
      (display "    (guard (exn\n" p)
      (display "             (#t (display (string-append \"  ERROR: \" input-path \" failed: \"))\n" p)
      (display "                 (display (condition-message exn))\n" p)
      (display "                 (when (irritants-condition? exn)\n" p)
      (display "                   (display \" — \") (display (condition-irritants exn)))\n" p)
      (display "                 (newline) #f))\n" p)
      (display "      (let* ((lib-form (gerbil-compile-to-library\n" p)
      (fprintf p "                         input-path lib-name ~a-import-map ~a-base-imports))~n" pkg-sym pkg-sym)
      (display "             (lib-form (fix-import-conflicts lib-form)))\n" p)
      (display "        (call-with-output-file output-path\n" p)
      (display "          (lambda (port)\n" p)
      (display "            (display \"#!chezscheme\\n\" port)\n" p)
      (display "            (parameterize ([print-gensym #f])\n" p)
      (display "              (pretty-print lib-form port)))\n          'replace)\n" p)
      (display "        (display (string-append \"  OK: \" output-path \"\\n\")) #t))))\n\n" p)

      ;; Main build sequence
      (fprintf p "(display \"=== Gherkin ~a Builder ===\\n\\n\")~n~n" (string-upcase (symbol->string pkg-sym)))
      ;; Simple tiered build — just compile all modules in order
      (display "(display \"--- Compiling modules ---\\n\")\n" p)
      (for-each
        (lambda (mod)
          ;; Figure out the source path and flat name
          ;; If the module has a / in it, it's nested like "lsp/handlers/sync"
          ;; Otherwise it's just "ast"
          (let* ((parts (string-split-char mod #\/))
                 ;; Flat name: join with - (e.g. "lsp/handlers/sync" → "handlers-sync")
                 ;; But for single-part modules it's just the name
                 (flat-name (if (= (length parts) 1)
                              mod
                              (string-join (cdr parts) "-")))
                 (source-path (string-append mod ".ss")))
            (fprintf p "(compile-module \"~a\" \"~a\")~n" source-path flat-name)))
        modules)
      (display "\n(display \"\\n=== Build complete ===\\n\")\n" p)
      (get-output-string p)))

  ;; Generate Makefile
  (define (gen-makefile entry-ss binary-name has-ffi?)
    (let ((p (open-output-string)))
      (display "SCHEME = $(HOME)/.local/bin/scheme\n" p)
      (display "GHERKIN = $(or $(GHERKIN_DIR),$(HOME)/mine/gherkin/src)\n" p)
      (display "LIBDIRS = src:$(GHERKIN)\n" p)
      (display "COMPILE = $(SCHEME) -q --libdirs $(LIBDIRS) --compile-imported-libraries\n\n" p)

      (if has-ffi?
        (begin
          (display ".PHONY: all compile gherkin ffi binary clean help run\n\n" p)
          (display "all: ffi gherkin compile\n\n" p)
          (display "# Step 1: Compile C FFI shim\n" p)
          (fprintf p "ffi: lib~a-ffi.so~n" binary-name)
          (fprintf p "lib~a-ffi.so: ffi-shim.c~n" binary-name)
          (display "\tgcc -shared -fPIC -o $@ $< -Wall -Wextra -O2\n\n" p)
          (display "# Step 2: Translate .ss → .sls via gherkin compiler\n" p)
          (display "gherkin: ffi\n" p))
        (begin
          (display ".PHONY: all compile gherkin binary clean help run\n\n" p)
          (display "all: gherkin compile\n\n" p)
          (display "# Step 1: Translate .ss → .sls via gherkin compiler\n" p)
          (display "gherkin:\n" p)))
      (display "\t$(COMPILE) < build-gherkin.ss\n\n" p)

      (display "# Step 2: Compile .sls → .so via Chez\n" p)
      (display "compile: gherkin\n\t$(COMPILE) < build-all.ss\n\n" p)

      (display "# Build = full pipeline\nbuild: binary\n\n" p)
      (display "# Native binary\n" p)
      (if has-ffi?
        (display "binary: clean ffi gherkin\n" p)
        (display "binary: clean gherkin\n" p))
      (display "\t$(SCHEME) -q --libdirs $(LIBDIRS) --program build-binary.ss\n\n" p)

      (display "# Run interpreted\nrun: all\n" p)
      (fprintf p "\t$(SCHEME) -q --libdirs $(LIBDIRS) --program ~a~n~n" entry-ss)

      (display "clean:\n" p)
      (fprintf p "\trm -f ~a-main.o ~a_program.h~n" binary-name
               (string-replace-char binary-name #\- #\_))
      (fprintf p "\trm -f ~a.boot ~a-all.so ~a.so ~a.wpo~n"
               binary-name binary-name
               (path-strip-extension entry-ss) (path-strip-extension entry-ss))
      (display "\trm -f petite.boot scheme.boot\n" p)
      (display "\tfind src -name '*.so' -o -name '*.wpo' | xargs rm -f 2>/dev/null || true\n\n" p)

      (display "help:\n" p)
      (display "\t@echo \"Targets:\"\n" p)
      (display "\t@echo \"  all       - Translate .ss→.sls + compile .sls→.so\"\n" p)
      (fprintf p "\t@echo \"  build     - Build standalone binary (./~a)\"~n" binary-name)
      (display "\t@echo \"  binary    - Same as build\"\n" p)
      (display "\t@echo \"  run       - Run interpreted\"\n" p)
      (display "\t@echo \"  gherkin   - Translate .ss → .sls only\"\n" p)
      (display "\t@echo \"  compile   - Compile .sls → .so only\"\n" p)
      (display "\t@echo \"  clean     - Remove all build artifacts\"\n" p)
      (display "\t@echo \"  help      - Show this help\"\n" p)
      (get-output-string p)))

  ;; ========================================
  ;; Copy compat modules from gherkin-shell as templates
  ;; ========================================

  ;; Generate a placeholder compat module
  (define (gen-compat-placeholder name)
    (format "#!chezscheme\n;;; ~a.sls -- Compat placeholder (populate from gherkin-shell or gherkin-lsp)\n;;; TODO: Copy the appropriate compat module from an existing gherkin-* project\n;;; and customize for this project's needs.\n\n(library (compat ~a)\n  (export)\n  (import (chezscheme))\n  ;; TODO: Add compat shims\n  )\n" name name))

  ;; ========================================
  ;; Main convert function
  ;; ========================================

  (define (gherkin-convert url output-dir-override)
    (let-values (((repo-name git-url) (parse-repo-url url)))
      (let* ((short-name (strip-gerbil-prefix repo-name))
             (project-name (string-append "gherkin-" short-name))
             (project-dir (or output-dir-override
                              (path-expand project-name (current-directory)))))

        (printf "Converting ~a → ~a~n" repo-name project-name)
        (printf "  URL: ~a~n" git-url)
        (printf "  Dir: ~a~n~n" project-dir)

        ;; Step 1: Create project directory and git init
        (if (file-exists? project-dir)
          (printf "  Directory already exists, using it.~n")
          (begin
            (create-directory* project-dir)
            (run-cmd (format "cd ~a && git init -q" project-dir))))

        ;; Step 2: Add submodule
        (let ((submodule-path (path-expand repo-name project-dir)))
          (if (file-exists? submodule-path)
            (printf "  Submodule ~a already exists, skipping clone.~n" repo-name)
            (begin
              (printf "  Adding git submodule ~a...~n" repo-name)
              (run-cmd (format "cd ~a && git submodule add ~a ~a"
                               project-dir git-url repo-name)))))

        ;; Step 3: Parse the submodule's build.ss and gerbil.pkg
        (let* ((submod-dir (path-expand repo-name project-dir))
               (build-ss (path-expand "build.ss" submod-dir))
               (gerbil-pkg (path-expand "gerbil.pkg" submod-dir)))

          (let-values (((parsed-modules exe-spec) (parse-build-ss build-ss)))
            ;; Fallback: if parse-build-ss found no modules, scan .ss files
            (let* ((modules (if (null? parsed-modules)
                              (begin
                                (printf "  (build.ss parse returned 0 modules, scanning .ss files...)~n")
                                (scan-ss-files submod-dir))
                              parsed-modules))
                   (pkg-plist (parse-gerbil-pkg gerbil-pkg))
                   (pkg-name (pgetq 'package: pkg-plist))
                   (pkg-sym (if (symbol? pkg-name)
                              pkg-name
                              (string->symbol short-name)))
                   (pkg-str (symbol->string pkg-sym))
                   ;; Extract exe info — try parse-build-ss result first, then text scan
                   (exe-module (if exe-spec
                                 (let ((args (cdr exe-spec)))
                                   (car args))
                                 #f))
                   (exe-bin (if exe-spec
                              (pgetq 'bin: (cdr exe-spec))
                              #f)))
              ;; If structured parsing failed, try text-based detection
              (let-values (((text-exe-mod text-exe-bin)
                            (if (and (not exe-module) (not exe-bin))
                              (detect-exe-from-text build-ss)
                              (values exe-module exe-bin))))
                (let* ((exe-module (or exe-module text-exe-mod))
                       (exe-bin (or exe-bin text-exe-bin))
                   (binary-name (or exe-bin
                                    (string-append "gherkin-" short-name)))
                   ;; Determine the main module for the entry point
                   (main-mod (if exe-module
                               (let ((parts (string-split-char exe-module #\/)))
                                 (if (= (length parts) 1)
                                   (string->symbol exe-module)
                                   (string->symbol (string-join (cdr parts) "-"))))
                               'main))
                   ;; Scan imports
                   (imports (scan-imports submod-dir))
                   (compat-needs (determine-compat-needs imports))
                   (import-map (generate-import-map imports pkg-sym))
                   ;; Entry point filename
                   (entry-ss (string-append short-name ".ss"))
                   ;; Arg prefix for C main (uppercase, underscores)
                   (arg-prefix (string-upcase
                                 (string-replace-char short-name #\- #\_)))
                   ;; Check if project uses FFI
                   (has-ffi? (file-exists? (path-expand "ffi-shim.c" submod-dir)))
                   ;; Filter compat modules (exclude 'types' — that's a gherkin runtime module)
                   (compat-modules (filter (lambda (s) (not (eq? s 'types))) compat-needs)))

              (printf "~n  Package: ~a~n" pkg-str)
              (printf "  Modules: ~a~n" (length modules))
              (printf "  Exe target: ~a~n" (or exe-bin "(none)"))
              (printf "  Detected imports: ~a~n" (length imports))
              (printf "  Compat modules needed: ~a~n~n"
                      (string-join (map symbol->string compat-modules) ", "))

              ;; Step 4: Create directory structure
              (create-directory* (path-expand (format "src/~a" pkg-str) project-dir))
              (create-directory* (path-expand "src/compat" project-dir))

              ;; Step 5: Generate files
              (printf "  Generating files...~n")

              ;; .gitignore
              (write-file (path-expand ".gitignore" project-dir)
                (gen-gitignore project-dir binary-name
                  (map (lambda (mod)
                         (let ((parts (string-split-char mod #\/)))
                           (if (= (length parts) 1) mod
                             (string-join (cdr parts) "-"))))
                       modules)
                  pkg-str))
              (printf "    .gitignore~n")

              ;; build-gherkin.ss
              (write-file (path-expand "build-gherkin.ss" project-dir)
                (gen-build-gherkin repo-name pkg-sym modules import-map compat-modules))
              (printf "    build-gherkin.ss~n")

              ;; build-all.ss
              (write-file (path-expand "build-all.ss" project-dir)
                (gen-build-all
                  (map (lambda (mod)
                         (let ((parts (string-split-char mod #\/)))
                           (if (= (length parts) 1) mod
                             (string-join (cdr parts) "-"))))
                       modules)
                  pkg-sym))
              (printf "    build-all.ss~n")

              ;; Entry point .ss
              (write-file (path-expand entry-ss project-dir)
                (gen-entry-ss pkg-sym main-mod arg-prefix binary-name))
              (printf "    ~a~n" entry-ss)

              ;; C main
              (write-file (path-expand (format "~a-main.c" binary-name) project-dir)
                (gen-c-main binary-name arg-prefix))
              (printf "    ~a-main.c~n" binary-name)

              ;; build-binary.ss
              (write-file (path-expand "build-binary.ss" project-dir)
                (gen-build-binary entry-ss binary-name
                  (map (lambda (mod)
                         (let ((parts (string-split-char mod #\/)))
                           (if (= (length parts) 1) mod
                             (string-join (cdr parts) "-"))))
                       modules)
                  compat-modules pkg-str))
              (printf "    build-binary.ss~n")

              ;; Makefile
              (write-file (path-expand "Makefile" project-dir)
                (gen-makefile entry-ss binary-name has-ffi?))
              (printf "    Makefile~n")

              ;; Compat module placeholders
              (for-each
                (lambda (mod)
                  (let ((path (path-expand
                                (format "src/compat/~a.sls" mod)
                                project-dir)))
                    (unless (file-exists? path)
                      (write-file path (gen-compat-placeholder (symbol->string mod)))
                      (printf "    src/compat/~a.sls (placeholder)~n" mod))))
                compat-modules)

              ;; Copy pregexp-impl.scm if needed
              (when (memq 'pregexp compat-modules)
                (let ((src (path-expand "src/compat/pregexp-impl.scm"
                             (path-directory project-dir)))
                      (dst (path-expand "src/compat/pregexp-impl.scm" project-dir)))
                  (when (and (not (file-exists? dst))
                             (file-exists? src))
                    (run-cmd (format "cp ~a ~a" src dst))
                    (printf "    src/compat/pregexp-impl.scm (copied)~n"))))

              (printf "~n========================================~n")
              (printf "Conversion complete!~n~n")
              (printf "Project: ~a~n" project-dir)
              (printf "Submodule: ~a (at ~a)~n~n" repo-name git-url)
              (printf "Next steps:~n")
              (printf "  1. cd ~a~n" project-dir)
              (printf "  2. Populate src/compat/*.sls with Gambit/Gerbil compat shims~n")
              (printf "     (copy from gherkin-shell or gherkin-lsp and customize)~n")
              (printf "  3. Review build-gherkin.ss import maps and adjust as needed~n")
              (printf "  4. make all           # translate + compile~n")
              (printf "  5. make build         # build standalone binary~n")))))))))

  ) ;; end library
