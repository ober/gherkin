;;; extended-demo.ss -- Full Gherkin demo: Gerbil on Chez Scheme
;;; Demonstrates: hash tables, for loops, try/catch/finally,
;;;   while/until, pattern matching, structs, methods, and more.

;; === Hash Tables ===
(defstruct person (name age city))

(def registry (make-hash-table))

(def (register! p)
  (hash-put! registry (person-name p) p))

(def (lookup name)
  (hash-get registry name))

;; Register some people
(register! (make-person "Alice" 30 "NYC"))
(register! (make-person "Bob" 25 "SF"))
(register! (make-person "Charlie" 35 "LA"))

(displayln "=== Gherkin Extended Demo ===")
(displayln)

;; Hash table operations
(displayln "--- Hash Tables ---")
(def alice (lookup "Alice"))
(display "  Alice's age: ")
(display (person-age alice))
(newline)

(display "  Registry has ")
(display (hash-length registry))
(display " entries")
(newline)

(display "  People: ")
(def names (hash-keys registry))
(display names)
(newline)

;; === For Loops ===
(displayln)
(displayln "--- For Iteration ---")

;; for/collect with in-range
(def squares (for/collect (i (in-range 1 11)) (* i i)))
(display "  Squares 1..10: ")
(display squares)
(newline)

;; for/fold: sum of squares
(def sum-sq (for/fold ((sum 0)) (x squares) (+ sum x)))
(display "  Sum of squares: ")
(display sum-sq)
(newline)

;; for/or: find first even > 20
(def found (for/or (x squares) (and (> x 20) (even? x) x)))
(display "  First even square > 20: ")
(display found)
(newline)

;; for/and: all positive?
(def all-pos (for/and (x squares) (> x 0)))
(display "  All positive? ")
(display all-pos)
(newline)

;; === While / Until ===
(displayln)
(displayln "--- While / Until ---")

;; Collatz sequence
(def (collatz n)
  (def steps 0)
  (def current n)
  (while (> current 1)
    (if (even? current)
      (set! current (/ current 2))
      (set! current (+ (* 3 current) 1)))
    (set! steps (+ steps 1)))
  steps)

(display "  Collatz(27) steps: ")
(display (collatz 27))
(newline)

;; Fibonacci with until
(def (fib-until limit)
  (def a 0)
  (def b 1)
  (def result '())
  (until (>= a limit)
    (set! result (cons a result))
    (let ((next (+ a b)))
      (set! a b)
      (set! b next)))
  (reverse result))

(display "  Fibs < 100: ")
(display (fib-until 100))
(newline)

;; === Try / Catch / Finally ===
(displayln)
(displayln "--- Exception Handling ---")

(def (safe-divide a b)
  (try
    (if (= b 0)
      (error 'divide "division by zero")
      (/ a b))
    (catch (e) 'error)))

(display "  10/3 = ")
(display (safe-divide 10 3))
(newline)
(display "  10/0 = ")
(display (safe-divide 10 0))
(newline)

;; Try with finally
(def cleanup-log '())
(def (risky-op name succeed?)
  (try
    (if succeed?
      (string-append name " succeeded")
      (error 'risky (string-append name " failed")))
    (catch (e) "recovered")
    (finally
      (set! cleanup-log (cons name cleanup-log)))))

(risky-op "op1" #t)
(risky-op "op2" #f)
(risky-op "op3" #t)
(display "  Cleanup log: ")
(display (reverse cleanup-log))
(newline)

;; === Pattern Matching ===
(displayln)
(displayln "--- Pattern Matching ---")

(def (describe-list lst)
  (match lst
    ([] "empty")
    ([x] (string-append "singleton: " (number->string x)))
    ([x y] (string-append "pair: " (number->string x) "," (number->string y)))
    ([x y . rest] (string-append "long list starting with "
                                 (number->string x) ","
                                 (number->string y)))))

(display "  () → ")
(display (describe-list '()))
(newline)
(display "  (1) → ")
(display (describe-list '(1)))
(newline)
(display "  (1 2) → ")
(display (describe-list '(1 2)))
(newline)
(display "  (1 2 3 4) → ")
(display (describe-list '(1 2 3 4)))
(newline)

;; === Struct Inheritance ===
(displayln)
(displayln "--- Struct Inheritance ---")

(defstruct shape (color))
(defstruct (circle shape) (radius))
(defstruct (rectangle shape) (width height))

(def (shape-area s)
  (cond
    ((circle? s) (* 3.14159 (circle-radius s) (circle-radius s)))
    ((rectangle? s) (* (rectangle-width s) (rectangle-height s)))
    (else 0)))

(def (shape-describe s)
  (cond
    ((circle? s)
     (string-append "circle(r=" (number->string (circle-radius s))
                    ", area=" (number->string (shape-area s)) ")"))
    ((rectangle? s)
     (string-append "rect(" (number->string (rectangle-width s))
                    "x" (number->string (rectangle-height s))
                    ", area=" (number->string (shape-area s)) ")"))
    (else "unknown")))

(def shapes (list (make-circle 'red 5.0)
                  (make-rectangle 'blue 3.0 4.0)
                  (make-circle 'green 2.5)))

(for (s shapes)
  (display "  ")
  (display (shape-color s))
  (display " ")
  (display (shape-describe s))
  (newline))

;; Total area using for/fold
(def total-area (for/fold ((total 0.0)) (s shapes) (+ total (shape-area s))))
(display "  Total area: ")
(display total-area)
(newline)

;; === Higher Order + Composition ===
(displayln)
(displayln "--- Higher Order ---")

(def (compose f g) (lambda (x) (f (g x))))
(def (pipe . fns)
  (foldl (lambda (f g) (lambda (x) (f (g x)))) (lambda (x) x) fns))

(def inc (lambda (x) (+ x 1)))
(def double (lambda (x) (* x 2)))
(def negate (lambda (x) (- x)))

(def transform (compose negate (compose double inc)))
(display "  compose(negate, double, inc)(5) = ")
(display (transform 5))
(newline)

;; === Case-Lambda ===
(displayln)
(displayln "--- Case-Lambda ---")

(def* range
  ((n) (range 0 n 1))
  ((start end) (range start end 1))
  ((start end step)
   (let lp ((i start) (acc '()))
     (if (>= i end) (reverse acc)
       (lp (+ i step) (cons i acc))))))

(display "  range(5) = ")
(display (range 5))
(newline)
(display "  range(2,8) = ")
(display (range 2 8))
(newline)
(display "  range(0,20,3) = ")
(display (range 0 20 3))
(newline)

;; === String Operations ===
(displayln)
(displayln "--- String Operations ---")

(def words '("Gerbil" "on" "Chez" "Scheme"))
(display "  join: ")
(display (string-join words " "))
(newline)

(def csv "alice,30,NYC")
(display "  split: ")
(display (string-split csv #\,))
(newline)

;; === Hash as Frequency Counter ===
(displayln)
(displayln "--- Frequency Counter ---")

(def (word-freq words)
  (def ht (make-hash-table))
  (for (w words)
    (hash-update! ht w (lambda (v) (+ v 1)) 0))
  ht)

(def freq (word-freq '(the cat sat on the mat the cat)))
(hash-for-each
  (lambda (k v)
    (display "  ")
    (display k)
    (display ": ")
    (display v)
    (newline))
  freq)

(displayln)
(displayln "=== Done! ===")
