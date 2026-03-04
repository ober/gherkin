;; Test that export forms are silently skipped in script mode
(export my-fn)
(def (my-fn x) (* x 2))
(displayln (my-fn 21))
