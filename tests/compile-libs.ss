#!chezscheme
;;; compile-libs.ss -- Pre-compile all Gherkin libraries
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
    andmap ormap iota last-pair find
    1+ 1- fx/ fx1+ fx1-
    error error? raise with-exception-handler identifier?
    hash-table? make-hash-table)
  (except (compat gambit-compat)
    make-thread thread-start! thread-join! thread-sleep! thread-yield!
    make-condition-variable condition-variable-signal! condition-variable-broadcast!)
  (compat types)
  (compat threading)
  (reader reader)
  (boot init)
  (only (boot gherkin) gherkin-compile-file gherkin-compile-string))
(printf "All libraries compiled successfully.~n")
