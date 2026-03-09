#!chezscheme
;;; compile-libs-opt3.ss -- Pre-compile Gherkin with optimization tuning
;;; Run as: scheme -q --libdirs .:src --script tests/compile-libs-opt3.ss
(compile-imported-libraries #t)
(optimize-level 3)
(cp0-effort-limit 500)
(cp0-score-limit 50)
(generate-inspector-information #f)
(load-program "tests/compile-libs.ss")
