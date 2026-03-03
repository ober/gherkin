#!chezscheme
;;; init.sls -- Gherkin bootstrap initialization
;;;
;;; Imports all compatibility layers and provides a unified entry point.
;;; This is the library that ported Gerbil code will import.

(library (boot init)
  (export
    ;; Re-export everything from compat layers
    ;; (eventually this will be the single import for ported Gerbil code)
    gherkin-version
    gherkin-init!
    )

  (import
    (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name)
    (compat gambit-compat)
    (compat types)
    (compat threading)
    (reader reader))

  (define gherkin-version "0.1.0-dev")

  (define (gherkin-init!)
    (printf "Gherkin ~a on Chez Scheme ~a~n"
            gherkin-version
            (scheme-version))
    (printf "Threading: ~a~n" (threaded?)))

  ) ;; end library
