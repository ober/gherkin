#!chezscheme
;;; std-os-path.sls -- Compat shim for Gerbil's :std/os/path
;;; Path manipulation utilities.

(library (compat std-os-path)
  (export
    path-expand
    path-normalize
    path-extension
    path-strip-extension
    path-strip-trailing-directory-separator
    path-directory
    path-strip-directory)

  (import (except (chezscheme) path-extension))

  (define (path-expand path . rest)
    ;; Expand ~ and make relative paths absolute
    (let ((base (if (pair? rest) (car rest) (current-directory))))
      (cond
        ((and (> (string-length path) 0)
              (char=? (string-ref path 0) #\~))
         (string-append (getenv "HOME")
                        (substring path 1 (string-length path))))
        ((and (> (string-length path) 0)
              (char=? (string-ref path 0) #\/))
         path)
        (else
         (string-append base "/" path)))))

  (define (path-normalize path)
    ;; Simple normalization — just expand
    (path-expand path))

  (define (path-extension path)
    ;; Return the file extension including the dot, or #f
    (let ((dot (string-last-index-of path #\.))
          (slash (string-last-index-of path #\/)))
      (if (and dot (or (not slash) (> dot slash)))
        (substring path dot (string-length path))
        #f)))

  (define (path-strip-extension path)
    ;; Remove file extension
    (let ((dot (string-last-index-of path #\.))
          (slash (string-last-index-of path #\/)))
      (if (and dot (or (not slash) (> dot slash)))
        (substring path 0 dot)
        path)))

  (define (path-strip-trailing-directory-separator path)
    (if (and (> (string-length path) 1)
             (char=? (string-ref path (- (string-length path) 1)) #\/))
      (substring path 0 (- (string-length path) 1))
      path))

  (define (path-directory path)
    ;; Return directory part of path
    (let ((slash (string-last-index-of path #\/)))
      (if slash
        (if (= slash 0) "/" (substring path 0 slash))
        ".")))

  (define (path-strip-directory path)
    ;; Return filename part of path
    (let ((slash (string-last-index-of path #\/)))
      (if slash
        (substring path (+ slash 1) (string-length path))
        path)))

  ;; Helper: find last index of char in string
  (define (string-last-index-of str ch)
    (let lp ((i (- (string-length str) 1)))
      (cond
        ((< i 0) #f)
        ((char=? (string-ref str i) ch) i)
        (else (lp (- i 1))))))

  ) ;; end library
