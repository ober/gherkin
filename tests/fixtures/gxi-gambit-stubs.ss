;; Test Gambit compatibility stubs
(def stats (##process-statistics))
(displayln "stats-ok")
(def v (make-f64vector 3 1.5))
(displayln (f64vector-ref v 0))
(force-output (current-output-port))
(displayln "stubs-done")
