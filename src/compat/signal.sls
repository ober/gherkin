#!chezscheme
;;; signal.sls -- Compat shim for Gerbil's :std/os/signal
;;; Signal constants and utilities.

(library (compat signal)
  (export
    SIGHUP SIGINT SIGQUIT SIGTERM SIGUSR1 SIGUSR2
    SIGPIPE SIGALRM SIGCHLD
    signal-names)

  (import (chezscheme))

  ;; Standard POSIX signal numbers
  (define SIGHUP  1)
  (define SIGINT  2)
  (define SIGQUIT 3)
  (define SIGTERM 15)
  (define SIGUSR1 10)
  (define SIGUSR2 12)
  (define SIGPIPE 13)
  (define SIGALRM 14)
  (define SIGCHLD 17)

  (define signal-names
    '((1 . "SIGHUP") (2 . "SIGINT") (3 . "SIGQUIT")
      (9 . "SIGKILL") (10 . "SIGUSR1") (12 . "SIGUSR2")
      (13 . "SIGPIPE") (14 . "SIGALRM") (15 . "SIGTERM")
      (17 . "SIGCHLD")))

  ) ;; end library
