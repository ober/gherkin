;;; demo.ss -- Gerbil program compiled by Gherkin on Chez Scheme
;;; Demonstrates: def, defstruct, match, higher-order functions

;; Simple struct
(defstruct point (x y))

;; Function with pattern matching
(def (point-distance p)
  (let ((x (point-x p))
        (y (point-y p)))
    (sqrt (+ (* x x) (* y y)))))

;; Recursive function
(def (factorial n)
  (if (<= n 1) 1
    (* n (factorial (- n 1)))))

;; Match-based list operations
(def (my-length lst)
  (match lst
    ([] 0)
    ([_ . rest] (+ 1 (my-length rest)))))

(def (my-reverse lst)
  (match lst
    ([] '())
    ([hd . rest] (append (my-reverse rest) (list hd)))))

(def (my-filter pred lst)
  (match lst
    ([] '())
    ([hd . rest]
     (if (pred hd)
       (cons hd (my-filter pred rest))
       (my-filter pred rest)))))

;; Struct with inheritance
(defstruct shape (color))
(defstruct (circle shape) (radius))
(defstruct (rectangle shape) (width height))

(def (shape-area s)
  (cond
    ((circle? s)
     (* 3.14159 (circle-radius s) (circle-radius s)))
    ((rectangle? s)
     (* (rectangle-width s) (rectangle-height s)))
    (else 0)))

;; Higher-order function
(def (compose f g)
  (lambda (x) (f (g x))))

;; def* (case-lambda)
(def* my-add
  ((x) x)
  ((x y) (+ x y))
  ((x y z) (+ x y z)))

;; --- Main program ---
(display "=== Gherkin Demo: Gerbil on Chez Scheme ===\n")
(newline)

;; Point operations
(def p (make-point 3.0 4.0))
(display "Point: (")
(display (point-x p))
(display ", ")
(display (point-y p))
(display ")\n")
(display "Distance from origin: ")
(display (point-distance p))
(newline)

;; Factorial
(display "\nFactorials:\n")
(def (show-factorial n)
  (display "  ")
  (display n)
  (display "! = ")
  (display (factorial n))
  (newline))
(show-factorial 5)
(show-factorial 10)
(show-factorial 20)

;; List operations
(display "\nList operations:\n")
(def nums '(1 2 3 4 5 6 7 8 9 10))
(display "  List: ")
(display nums)
(newline)
(display "  Length: ")
(display (my-length nums))
(newline)
(display "  Reversed: ")
(display (my-reverse nums))
(newline)
(display "  Evens: ")
(display (my-filter even? nums))
(newline)

;; Shapes
(display "\nShapes:\n")
(def c (make-circle 'red 5.0))
(def r (make-rectangle 'blue 3.0 4.0))
(display "  Circle (r=5): area = ")
(display (shape-area c))
(newline)
(display "  Rectangle (3x4): area = ")
(display (shape-area r))
(newline)

;; Higher-order
(display "\nHigher-order:\n")
(def double-then-add1 (compose (lambda (x) (+ x 1)) (lambda (x) (* x 2))))
(display "  double-then-add1(5) = ")
(display (double-then-add1 5))
(newline)

;; case-lambda
(display "\nCase-lambda:\n")
(display "  my-add(5) = ")
(display (my-add 5))
(newline)
(display "  my-add(3, 4) = ")
(display (my-add 3 4))
(newline)
(display "  my-add(1, 2, 3) = ")
(display (my-add 1 2 3))
(newline)

(display "\nDone!\n")
