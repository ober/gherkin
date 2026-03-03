#!chezscheme
;;; compile-libs.ss -- Pre-compile all Gherkin libraries
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name)
  (compat gambit-compat)
  (compat types)
  (compat threading)
  (reader reader)
  (boot init))
(printf "All libraries compiled successfully.~n")
