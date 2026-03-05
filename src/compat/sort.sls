#!chezscheme
;;; sort.sls -- Compat shim for Gerbil's :std/sort
;;; Chez already has sort and sort!; this adds stable-sort.

(library (compat sort)
  (export sort sort! stable-sort)
  (import (chezscheme))

  (define (stable-sort lst pred)
    ;; Merge sort for stability
    (define (merge a b)
      (cond
        ((null? a) b)
        ((null? b) a)
        ((pred (car a) (car b))
         (cons (car a) (merge (cdr a) b)))
        (else
         (cons (car b) (merge a (cdr b))))))
    (define (msort lst n)
      (if (<= n 1)
        (if (= n 0) '() (list (car lst)))
        (let ((half (quotient n 2)))
          (merge (msort lst half)
                 (msort (list-tail lst half) (- n half))))))
    (msort lst (length lst)))

  ) ;; end library
