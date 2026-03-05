#!chezscheme
;;; format.sls -- Compat shim for Gerbil's :std/format
;;; Chez already has format; this re-exports it.

(library (compat format)
  (export format fprintf printf)
  (import (chezscheme))
  ;; format, fprintf, printf are all Chez builtins — just re-export
  ) ;; end library
