#!chezscheme
;;; pkg.sls -- Gherkin Package Manager
;;; Equivalent of Gerbil's gxpkg for the Gherkin (Gerbil→Chez) toolchain.
;;; Handles: build, deps, install, link, clean, new, list

(library (tools pkg)
  (export
    ;; Main entry
    gxpkg-main

    ;; Script API
    pkg-root-dir
    pkg-build pkg-clean
    pkg-install pkg-uninstall pkg-update
    pkg-link pkg-unlink
    pkg-list pkg-retag
    pkg-deps-manage
    pkg-new
    pkg-plist

    ;; Build
    build-module build-exe
    read-build-spec)

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            error error? raise with-exception-handler identifier?
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise)
            (error chez:error) (raise chez:raise))
    (compiler compile))

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
        ((char=? (string-ref path i) #\/) (substring path (+ i 1) (string-length path)))
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

  (define (string-prefix? prefix str)
    (let ((plen (string-length prefix)))
      (and (<= plen (string-length str))
           (string=? prefix (substring str 0 plen)))))

  (define (string-suffix? suffix str)
    (let ((slen (string-length suffix))
          (len (string-length str)))
      (and (<= slen len)
           (string=? suffix (substring str (- len slen) len)))))

  (define (string-split-char str ch)
    (let ((len (string-length str)))
      (let lp ((i 0) (start 0) (result '()))
        (cond
          ((= i len)
           (reverse (cons (substring str start len) result)))
          ((char=? (string-ref str i) ch)
           (lp (+ i 1) (+ i 1) (cons (substring str start i) result)))
          (else (lp (+ i 1) start result))))))

  (define (string-join-char parts ch)
    (if (null? parts)
      ""
      (let lp ((rest (cdr parts)) (acc (car parts)))
        (if (null? rest)
          acc
          (lp (cdr rest)
              (string-append acc (string ch) (car rest)))))))

  ;; ========================================
  ;; gerbil.pkg parsing
  ;; ========================================

  (define (pkg-plist dir)
    (let ((pkg-file (path-expand "gerbil.pkg" dir)))
      (if (file-exists? pkg-file)
        ;; gerbil.pkg contains multiple s-expressions like:
        ;;   (package: gsh)
        ;;   (depend: ("github.com/foo" "github.com/bar"))
        ;; Merge them all into one flat plist
        (call-with-input-file pkg-file
          (lambda (port)
            (let lp ((result '()))
              (let ((form (read port)))
                (if (eof-object? form)
                  result
                  (lp (append result (if (list? form) form (list form)))))))))
        '())))

  (define (pgetq key plist)
    (let lp ((rest plist))
      (cond
        ((null? rest) #f)
        ((eq? (car rest) key) (and (pair? (cdr rest)) (cadr rest)))
        (else (lp (cdr rest))))))

  (define (pkg-package-prefix dir)
    (let* ((plist (pkg-plist dir))
           (pkg (pgetq 'package: plist)))
      (if (symbol? pkg) (symbol->string pkg) #f)))

  (define (pkg-dependencies dir)
    (let* ((plist (pkg-plist dir))
           (deps (pgetq 'depend: plist)))
      (if (list? deps) deps '())))

  ;; ========================================
  ;; Root directory management
  ;; ========================================

  (define (gherkin-home)
    (or (getenv "GHERKIN_PATH")
        (string-append (getenv "HOME") "/.gherkin")))

  (define (pkg-root-dir)
    (let ((root (string-append (gherkin-home) "/pkg")))
      (create-directory* root)
      (create-directory* (string-append (gherkin-home) "/lib"))
      (create-directory* (string-append (gherkin-home) "/bin"))
      root))

  ;; ========================================
  ;; Local package environment
  ;; ========================================

  ;; When in a project directory with gerbil.pkg, use .gherkin/ as GHERKIN_PATH
  (define (setup-local-env! dir)
    (let ((pkg-file (path-expand "gerbil.pkg" dir)))
      (when (file-exists? pkg-file)
        (let ((local-path (path-expand ".gherkin" dir)))
          (create-directory* local-path)
          (create-directory* (path-expand "lib" local-path))
          (create-directory* (path-expand "bin" local-path))
          (putenv "GHERKIN_PATH" local-path)))))

  ;; ========================================
  ;; Git operations
  ;; ========================================

  (define (git-clone-url pkg)
    (string-append "https://" pkg ".git"))

  (define (run-cmd cmd)
    (let ((status (system cmd)))
      (unless (zero? status)
        (chez:error 'run-cmd (format "command failed with status ~a: ~a" status cmd)))))

  (define (run-cmd/quiet cmd)
    (system (string-append cmd " >/dev/null 2>&1")))

  ;; ========================================
  ;; Package install/update/uninstall
  ;; ========================================

  (define (pkg-install pkg)
    (let* ((root (pkg-root-dir))
           (dest (path-expand pkg root)))
      (if (file-exists? dest)
        (begin
          (display (format "... already installed: ~a\n" pkg))
          #f)
        (begin
          (display (format "... cloning ~a\n" pkg))
          (create-directory* (path-directory dest))
          (run-cmd (format "git clone -q ~a ~a" (git-clone-url pkg) dest))
          ;; Install transitive deps
          (pkg-install-deps pkg)
          ;; Build
          (pkg-build-installed pkg)
          #t))))

  (define (pkg-install-deps pkg)
    (let* ((root (pkg-root-dir))
           (dest (path-expand pkg root))
           (deps (pkg-dependencies dest)))
      (for-each pkg-install deps)))

  (define (pkg-uninstall pkg . rest)
    (let* ((force? (and (pair? rest) (car rest)))
           (root (pkg-root-dir))
           (dest (path-expand pkg root)))
      (when (file-exists? dest)
        (display (format "... uninstalling ~a\n" pkg))
        (run-cmd (format "rm -rf ~a" dest))
        #t)))

  (define (pkg-update pkg)
    (cond
      ((string=? pkg "all")
       (for-each pkg-update (pkg-list)))
      (else
       (let* ((root (pkg-root-dir))
              (dest (path-expand pkg root)))
         (when (file-exists? dest)
           (display (format "... updating ~a\n" pkg))
           (run-cmd/quiet (format "cd ~a && git pull -q" dest))
           (pkg-build-installed pkg)
           #t)))))

  ;; ========================================
  ;; Package link/unlink
  ;; ========================================

  (define (pkg-link pkg src)
    (let* ((root (pkg-root-dir))
           (dest (path-expand pkg root)))
      (when (file-exists? dest)
        (chez:error 'pkg-link "destination already exists" pkg dest))
      (create-directory* (path-directory dest))
      ;; Chez doesn't have create-symbolic-link; use system
      (run-cmd (format "ln -s ~a ~a" src dest))
      (display (format "... linked ~a → ~a\n" pkg src))))

  (define (pkg-unlink pkg . rest)
    (let* ((force? (and (pair? rest) (car rest)))
           (root (pkg-root-dir))
           (dest (path-expand pkg root)))
      (when (file-exists? dest)
        (display (format "... unlinking ~a\n" pkg))
        (run-cmd (format "rm -f ~a" dest)))))

  ;; ========================================
  ;; Package listing
  ;; ========================================

  (define (pkg-list)
    (let ((root (pkg-root-dir)))
      (if (file-exists? root)
        (let walk ((dir root) (prefix ""))
          (let ((files (directory-list dir)))
            (let lp ((files files) (result '()))
              (if (null? files)
                result
                (let* ((file (car files))
                       (path (path-expand file dir))
                       (pkg-path (if (string=? prefix "")
                                   file
                                   (string-append prefix "/" file))))
                  (cond
                    ((file-exists? (path-expand "gerbil.pkg" path))
                     (lp (cdr files) (cons pkg-path result)))
                    ((file-directory? path)
                     (lp (cdr files) (append (walk path pkg-path) result)))
                    (else
                     (lp (cdr files) result))))))))
        '())))

  (define (pkg-retag)
    ;; No-op for now; Gerbil's retag runs gxtags
    (values))

  ;; ========================================
  ;; Build system
  ;; ========================================

  ;; Build an installed package
  ;; Note: many Gerbil packages use :std/build-script which requires the
  ;; Gerbil runtime. We try to build but gracefully skip on failure.
  (define (pkg-build-installed pkg)
    (let* ((root (pkg-root-dir))
           (dest (path-expand pkg root)))
      (when (file-exists? dest)
        (guard (e [#t (display (format "  NOTE: build skipped for ~a (use Gerbil's gxpkg to build native packages)\n" pkg))])
          (pkg-build dest)))))

  ;; Read build.ss and extract the build spec
  ;; build.ss contains (defbuild-script '("mod1" "mod2" (exe: "main" bin: "app")))
  ;; We parse this to get the list of build targets
  (define (read-build-spec dir)
    (let ((build-file (path-expand "build.ss" dir)))
      (if (file-exists? build-file)
        (let ((content (call-with-input-file build-file
                         (lambda (port)
                           ;; Skip shebang line if present
                           (let ((first-char (peek-char port)))
                             (when (and (char? first-char) (char=? first-char #\#))
                               (get-line port)))
                           (let lp ((forms '()))
                             (let ((form (read port)))
                               (if (eof-object? form)
                                 (reverse forms)
                                 (lp (cons form forms)))))))))
          ;; Find the defbuild-script form and extract the spec
          (let lp ((forms content))
            (cond
              ((null? forms) '())
              ((and (pair? (car forms))
                    (eq? (caar forms) 'defbuild-script))
               ;; (defbuild-script '("mod1" (exe: "mod2" ...)) keys...)
               ;; The first argument is a quoted list
               (let ((spec-arg (cadr (car forms))))
                 (cond
                   ((and (pair? spec-arg) (eq? (car spec-arg) 'quote))
                    (cadr spec-arg))
                   ((list? spec-arg) spec-arg)
                   (else '()))))
              (else (lp (cdr forms))))))
        '())))

  ;; Find the gherkin project root (where bin/gherkin lives)
  (define (gherkin-root)
    (or (getenv "GHERKIN_ROOT")
        ;; Try to find it from the script location
        (let ((home (getenv "HOME")))
          (let try ((dirs (list (string-append home "/mine/gherkin")
                                "/opt/gherkin")))
            (cond
              ((null? dirs) (chez:error 'gherkin-root "cannot find gherkin installation"))
              ((file-exists? (path-expand "bin/gxc" (car dirs))) (car dirs))
              (else (try (cdr dirs))))))))

  ;; Build a Gerbil project in the given directory
  ;; Uses gxc to transpile each module
  (define (pkg-build dir . rest)
    (let* ((deps? (and (pair? rest) (car rest)))
           (abs-dir (if (string=? dir ".")
                      (current-directory)
                      (if (char=? (string-ref dir 0) #\/)
                        dir
                        (string-append (current-directory) "/" dir))))
           (prefix (pkg-package-prefix abs-dir))
           (spec (read-build-spec abs-dir))
           (gherkin (gherkin-root)))

      (when (null? spec)
        (display (format "... no build spec found in ~a\n" abs-dir))
        (values))

      (unless (null? spec)
        (display (format "... building ~a (~a modules)\n"
                         (or prefix dir) (length spec)))

        ;; Build each target
        (for-each
          (lambda (target)
            (cond
              ;; String: compile a module
              ((string? target)
               (build-module abs-dir prefix target gherkin))
              ;; (exe: "module" bin: "name" ...) — build executable
              ((and (pair? target) (eq? (car target) 'exe:))
               (build-exe abs-dir prefix target gherkin))
              ;; Skip unknown specs
              (else
               (display (format "... skipping unknown target: ~a\n" target)))))
          spec))))

  ;; Build a single module: transpile .ss → .sls (R6RS library), let Chez compile
  (define (build-module dir prefix modname gherkin-root)
    (let* (;; Source file is at dir/modname.ss (e.g. dir/myapp/lib.ss)
           (src-file (path-expand (string-append modname ".ss") dir)))
      (if (file-exists? src-file)
        (begin
          (display (format "  compiling ~a\n" modname))
          ;; Compute library name to match what resolve-import produces.
          ;; For module "myapp/lib" with prefix "myuser":
          ;; - The compiler strips the package prefix subdir if it matches
          ;; - "myapp/lib" → (myuser lib) when package is "myuser"
          ;; For sub-paths: "common/io" → (myuser common-io)
          (let* ((mod-parts (string-split-char modname #\/))
                 ;; Drop the first component if it matches a project subdir
                 ;; (like the package name directory)
                 (mod-path (if (> (length mod-parts) 1)
                             ;; Multi-part: "myapp/lib" → "lib",
                             ;; "common/io" → "common-io"
                             (let ((rest (cdr mod-parts)))
                               (string-join-char rest #\-))
                             ;; Single: "common" → "common"
                             modname))
                 (mod-sym (string->symbol mod-path))
                 (lib-name (if prefix
                             (list (string->symbol prefix) mod-sym)
                             (list mod-sym)))
                 ;; Build import map with package prefix
                 (import-map (if prefix
                               `((*default-package* . ,(string->symbol prefix)))
                               '()))
                 ;; Transpile to R6RS library
                 (lib-form (gerbil-compile-to-library src-file lib-name import-map))
                 ;; Write the .sls file where Chez expects it:
                 ;; (myuser lib) → dir/myuser/lib.sls
                 (lib-dir (if prefix (path-expand prefix dir) dir))
                 (sls-file (string-append
                             lib-dir "/" mod-path ".sls")))
            (create-directory* (path-directory sls-file))
            (call-with-output-file sls-file
              (lambda (port)
                (display "#!chezscheme\n" port)
                (parameterize ([print-gensym #f])
                  (pretty-print lib-form port)))
              'replace)))
        (display (format "  WARNING: source not found: ~a\n" src-file)))))

  ;; Build an executable target
  (define (build-exe dir prefix target gherkin-root)
    (let* ((args (cdr target))
           (modname (car args))
           (bin-name (pgetq 'bin: args))
           (src-file (path-expand (string-append modname ".ss") dir))
           (out-dir (or (getenv "GHERKIN_PATH")
                        (path-expand ".gherkin" dir)))
           (bin-dir (path-expand "bin" out-dir))
           (out-name (or bin-name modname)))
      (create-directory* bin-dir)
      (if (file-exists? src-file)
        (begin
          (display (format "  linking ~a → ~a\n" modname out-name))
          ;; Pass project dir as library search path so Chez finds compiled .sls files
          (run-cmd (format "~a/bin/gxc ~a -o ~a/~a -L ~a"
                           gherkin-root src-file bin-dir out-name dir)))
        (display (format "  WARNING: source not found: ~a\n" src-file)))))

  ;; Clean build artifacts
  (define (pkg-clean dir)
    (let* ((abs-dir (if (string=? dir ".")
                      (current-directory)
                      dir))
           (prefix (pkg-package-prefix abs-dir))
           (gherkin-dir (path-expand ".gherkin" abs-dir)))
      (display (format "... cleaning ~a\n" abs-dir))
      ;; Remove .chez.ss, .chez.so, generated .sls and .so files
      (let clean-dir ((d abs-dir))
        (when (file-exists? d)
          (for-each
            (lambda (f)
              (let ((path (path-expand f d)))
                (cond
                  ((file-directory? path)
                   (unless (or (string=? f ".gherkin") (string=? f ".git"))
                     (clean-dir path)))
                  ((or (string-suffix? ".chez.ss" f)
                       (string-suffix? ".chez.so" f)
                       (string-suffix? ".sls" f)
                       (and (string-suffix? ".so" f)
                            ;; Only remove .so if a matching .sls exists
                            (file-exists? (string-append (path-strip-extension path) ".sls"))))
                   (delete-file path)
                   (display (format "  removed ~a\n" path))))))
            (directory-list d))))
      ;; Remove .gherkin/bin contents
      (let ((bin-dir (path-expand "bin" gherkin-dir)))
        (when (file-exists? bin-dir)
          (for-each
            (lambda (f)
              (let ((path (path-expand f bin-dir)))
                (unless (file-directory? path)
                  (delete-file path)
                  (display (format "  removed ~a\n" path)))))
            (directory-list bin-dir))))
      ;; Remove generated prefix directory if it exists and isn't the source dir
      (when (and prefix (not (string=? prefix ""))
                 (file-exists? (path-expand prefix abs-dir))
                 ;; Only remove if it's not the source directory
                 (not (file-exists? (path-expand (string-append prefix "/lib.ss")
                                                  abs-dir))))
        ;; Be safe: only remove .sls and .so files from the prefix dir
        (let clean-prefix ((d (path-expand prefix abs-dir)))
          (when (file-exists? d)
            (for-each
              (lambda (f)
                (let ((path (path-expand f d)))
                  (cond
                    ((file-directory? path) (clean-prefix path))
                    ((or (string-suffix? ".sls" f) (string-suffix? ".so" f))
                     (delete-file path)
                     (display (format "  removed ~a\n" path))))))
              (directory-list d)))))))

  ;; ========================================
  ;; Dependency management
  ;; ========================================

  (define (pkg-deps-manage deps add? install? update? remove?)
    (let* ((plist (pkg-plist (current-directory)))
           (current-deps (or (pgetq 'depend: plist) '())))
      (cond
        ;; No flags: display current deps
        ((not (or add? install? update? remove?))
         (if (null? current-deps)
           (display "No dependencies.\n")
           (for-each
             (lambda (dep) (display dep) (newline))
             current-deps)))
        ;; Install all deps
        ((and install? (null? deps))
         (display (format "... installing ~a dependencies\n" (length current-deps)))
         (for-each pkg-install current-deps))
        ;; Install specific deps
        (install?
         (for-each pkg-install deps))
        ;; Update
        (update?
         (for-each pkg-update (if (null? deps) current-deps deps)))
        ;; Add
        (add?
         (chez:error 'deps "add not yet implemented — edit gerbil.pkg manually"))
        ;; Remove
        (remove?
         (chez:error 'deps "remove not yet implemented — edit gerbil.pkg manually")))))

  ;; ========================================
  ;; Project scaffolding
  ;; ========================================

  (define (pkg-new package-prefix package-name)
    (let* ((prefix (or package-prefix (getenv "USER")))
           (name (or package-name (path-strip-directory (current-directory)))))

      ;; gerbil.pkg
      (call-with-output-file "gerbil.pkg"
        (lambda (port)
          (display (format "(package: ~a)\n" prefix) port))
        'replace)

      ;; build.ss
      (call-with-output-file "build.ss"
        (lambda (port)
          (display "#!/usr/bin/env gxi\n" port)
          (display "(import :std/build-script)\n\n" port)
          (display (format "(defbuild-script\n  '(\"~a/lib\"\n    (exe: \"~a/main\" bin: \"~a\")))\n"
                           name name name)
                   port))
        'replace)
      (chmod "build.ss" #o755)

      ;; Module directory
      (create-directory* name)

      ;; lib.ss
      (call-with-output-file (path-expand "lib.ss" name)
        (lambda (port)
          (display "(import :std/sugar)\n" port)
          (display "(export #t)\n\n" port)
          (display ";;; Library code\n" port))
        'replace)

      ;; main.ss
      (call-with-output-file (path-expand "main.ss" name)
        (lambda (port)
          (display "(import :std/sugar\n" port)
          (display "        :std/cli/getopt\n" port)
          (display "        ./lib)\n" port)
          (display "(export main)\n\n" port)
          (display "(def (main . args)\n" port)
          (display "  (displayln \"Hello from " port)
          (display name port)
          (display "!\"))\n\n" port)
          (display "(main)\n" port))
        'replace)

      ;; .gitignore
      (call-with-output-file ".gitignore"
        (lambda (port)
          (display "*~\n.gherkin\n*.chez.ss\n*.chez.so\n*.so\n" port))
        'replace)

      ;; Makefile
      (call-with-output-file "Makefile"
        (lambda (port)
          (display "build:\n" port)
          (display "\tgherkin build\n\n" port)
          (display "deps:\n" port)
          (display "\tgherkin deps -i\n\n" port)
          (display "clean:\n" port)
          (display "\tgherkin clean\n\n" port)
          (display (format "install:\n\tcp .gherkin/bin/~a /usr/local/bin/\n" name) port))
        'replace)

      (display (format "Created project ~a/~a\n" prefix name))
      (display "Files: gerbil.pkg build.ss Makefile .gitignore\n")
      (display (format "Modules: ~a/lib.ss ~a/main.ss\n" name name))))

  ;; ========================================
  ;; Main CLI dispatcher
  ;; ========================================

  (define (gxpkg-main args)
    (when (null? args)
      (gxpkg-usage)
      (exit 0))

    (let ((cmd (car args))
          (rest (cdr args)))
      (cond
        ((string=? cmd "help")
         (if (null? rest)
           (gxpkg-usage)
           (gxpkg-help (car rest)))
         (exit 0))

        ((string=? cmd "build")
         (setup-local-env! (current-directory))
         (pkg-build (if (null? rest) "." (car rest))))

        ((string=? cmd "clean")
         (setup-local-env! (current-directory))
         (pkg-clean (if (null? rest) "." (car rest))))

        ((string=? cmd "deps")
         (setup-local-env! (current-directory))
         (let-values (((flags deps) (parse-deps-args rest)))
           (pkg-deps-manage deps
             (memq 'add flags)
             (memq 'install flags)
             (memq 'update flags)
             (memq 'remove flags))))

        ((string=? cmd "install")
         (for-each pkg-install rest))

        ((string=? cmd "uninstall")
         (for-each pkg-uninstall rest))

        ((string=? cmd "update")
         (for-each pkg-update rest))

        ((string=? cmd "link")
         (unless (>= (length rest) 2)
           (chez:error 'gxpkg "link requires: <pkg> <src>"))
         (pkg-link (car rest) (cadr rest)))

        ((string=? cmd "unlink")
         (for-each pkg-unlink rest))

        ((string=? cmd "list")
         (for-each
           (lambda (pkg) (display pkg) (newline))
           (pkg-list)))

        ((string=? cmd "new")
         (let-values (((pkg name) (parse-new-args rest)))
           (pkg-new pkg name)))

        (else
         (display (format "Unknown command: ~a\n" cmd) (current-error-port))
         (gxpkg-usage)
         (exit 1)))))

  (define (parse-deps-args args)
    (let lp ((args args) (flags '()) (deps '()))
      (cond
        ((null? args) (values flags (reverse deps)))
        ((string=? (car args) "-i") (lp (cdr args) (cons 'install flags) deps))
        ((string=? (car args) "--install") (lp (cdr args) (cons 'install flags) deps))
        ((string=? (car args) "-a") (lp (cdr args) (cons 'add flags) deps))
        ((string=? (car args) "--add") (lp (cdr args) (cons 'add flags) deps))
        ((string=? (car args) "-u") (lp (cdr args) (cons 'update flags) deps))
        ((string=? (car args) "--update") (lp (cdr args) (cons 'update flags) deps))
        ((string=? (car args) "-r") (lp (cdr args) (cons 'remove flags) deps))
        ((string=? (car args) "--remove") (lp (cdr args) (cons 'remove flags) deps))
        (else (lp (cdr args) flags (cons (car args) deps))))))

  (define (parse-new-args args)
    (let lp ((args args) (pkg #f) (name #f))
      (cond
        ((null? args) (values pkg name))
        ((string=? (car args) "-p") (lp (cddr args) (cadr args) name))
        ((string=? (car args) "--package") (lp (cddr args) (cadr args) name))
        ((string=? (car args) "-n") (lp (cddr args) pkg (cadr args)))
        ((string=? (car args) "--name") (lp (cddr args) pkg (cadr args)))
        (else (lp (cdr args) pkg name)))))

  (define (gxpkg-usage)
    (display "gherkin pkg: The Gherkin Package Manager\n\n")
    (display "Usage: gherkin <command> [args...]\n\n")
    (display "Commands:\n")
    (display "  build [pkg]          build current project or named package\n")
    (display "  clean [pkg]          clean build artifacts\n")
    (display "  deps [-i|-u|-r]      manage project dependencies\n")
    (display "  install <pkg>        install a package (git clone + build)\n")
    (display "  uninstall <pkg>      uninstall a package\n")
    (display "  update <pkg|all>     update packages\n")
    (display "  link <pkg> <src>     link a local development package\n")
    (display "  unlink <pkg>         unlink a package\n")
    (display "  list                 list installed packages\n")
    (display "  new [-p pkg] [-n n]  create a new project template\n")
    (display "  help [cmd]           show help\n"))

  (define (gxpkg-help cmd)
    (cond
      ((string=? cmd "build")
       (display "Usage: gherkin build [pkg]\n")
       (display "  Build current project (if no arg) or a named package.\n")
       (display "  Reads build.ss for the build spec and gerbil.pkg for the package prefix.\n"))
      ((string=? cmd "deps")
       (display "Usage: gherkin deps [-i|-a|-u|-r] [deps...]\n")
       (display "  -i, --install    install dependencies from gerbil.pkg\n")
       (display "  -a, --add        add dependencies\n")
       (display "  -u, --update     update dependencies\n")
       (display "  -r, --remove     remove dependencies\n")
       (display "  (no flags)       display current dependencies\n"))
      ((string=? cmd "new")
       (display "Usage: gherkin new [-p package] [-n name]\n")
       (display "  Create a new project template in the current directory.\n")
       (display "  -p, --package    package prefix (default: $USER)\n")
       (display "  -n, --name       project name (default: directory name)\n"))
      (else
       (gxpkg-usage))))

  ) ;; end library
