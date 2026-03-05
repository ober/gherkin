#!chezscheme
;;; fdio.sls -- Compat shim for Gerbil's :std/os/fdio
;;; File descriptor I/O operations.

(library (compat fdio)
  (export
    fdopen-input-port
    fdopen-output-port
    fdclose
    fdread
    fdwrite)

  (import (chezscheme))

  ;; Chez doesn't expose raw fd operations directly.
  ;; Provide basic implementations using Chez port operations.

  (define (fdopen-input-port fd . rest)
    ;; Open an input port from a file descriptor
    ;; Chez can do this via open-fd-input-port
    (open-fd-input-port fd
      (buffer-mode block)
      (if (pair? rest) (car rest) (native-transcoder))))

  (define (fdopen-output-port fd . rest)
    (open-fd-output-port fd
      (buffer-mode block)
      (if (pair? rest) (car rest) (native-transcoder))))

  (define (fdclose fd)
    ;; Close a file descriptor — no direct Chez equivalent without FFI
    ;; Rely on port close instead
    (void))

  (define (fdread fd buf count)
    ;; Read from fd into bytevector — stub
    0)

  (define (fdwrite fd buf count)
    ;; Write to fd from bytevector — stub
    0)

  ) ;; end library
