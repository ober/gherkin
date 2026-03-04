#!chezscheme
;;; gxi.ss -- Gherkin REPL entry point
(import
  (except (chezscheme) void box box? unbox set-box!
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (repl repl))

(gxi-start (cdr (command-line)))
