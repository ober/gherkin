;; Test defstruct in script mode
(defstruct point (x y))
(def p (make-point 10 20))
(displayln (point-x p))
(displayln (point-y p))
(displayln (point? p))
