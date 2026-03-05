#!chezscheme
;;; std-os-temporaries.sls -- Compat shim for Gerbil's :std/os/temporaries
;;; Temporary file creation.

(library (compat std-os-temporaries)
  (export
    make-temporary-file-name
    with-temporary-file)

  (import (chezscheme))

  (define *temp-counter* 0)

  (define (make-temporary-file-name . rest)
    (let ((prefix (if (pair? rest) (car rest) "gherkin"))
          (dir (or (getenv "TMPDIR") "/tmp")))
      (set! *temp-counter* (+ *temp-counter* 1))
      (format "~a/~a-~a-~a" dir prefix (current-process-id) *temp-counter*)))

  (define (current-process-id)
    ;; Chez doesn't expose getpid directly without FFI
    ;; Use a unique identifier instead
    (random 1000000))

  (define (with-temporary-file proc . rest)
    (let ((name (apply make-temporary-file-name rest)))
      (dynamic-wind
        (lambda () #f)
        (lambda () (proc name))
        (lambda ()
          (when (file-exists? name)
            (delete-file name))))))

  ) ;; end library
