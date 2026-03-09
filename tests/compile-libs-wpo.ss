#!chezscheme
;;; compile-libs-wpo.ss -- Pre-compile Gherkin with WPO + optimization
;;; Run as: scheme -q --libdirs .:src --script tests/compile-libs-wpo.ss
(compile-imported-libraries #t)
(optimize-level 3)
(cp0-effort-limit 500)
(cp0-score-limit 50)
(generate-inspector-information #f)
(generate-wpo-files #t)
(load-program "tests/compile-libs.ss")
