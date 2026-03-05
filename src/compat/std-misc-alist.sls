#!chezscheme
;;; std-misc-alist.sls -- Compat shim for Gerbil's :std/misc/alist
;;; Association list utilities.

(library (compat std-misc-alist)
  (export
    agetq agetv aget
    asetq! asetv! aset!
    pgetq pgetv pget
    alist-put
    alist-remove)

  (import (except (chezscheme) filter))

  (define (agetq key alist . rest)
    (let ((pair (assq key alist)))
      (if pair (cdr pair)
        (if (pair? rest) (car rest) #f))))

  (define (agetv key alist . rest)
    (let ((pair (assv key alist)))
      (if pair (cdr pair)
        (if (pair? rest) (car rest) #f))))

  (define (aget key alist . rest)
    (let ((pair (assoc key alist)))
      (if pair (cdr pair)
        (if (pair? rest) (car rest) #f))))

  (define (asetq! key val alist)
    (let ((pair (assq key alist)))
      (if pair (begin (set-cdr! pair val) alist)
        (cons (cons key val) alist))))

  (define (asetv! key val alist)
    (let ((pair (assv key alist)))
      (if pair (begin (set-cdr! pair val) alist)
        (cons (cons key val) alist))))

  (define (aset! key val alist)
    (let ((pair (assoc key alist)))
      (if pair (begin (set-cdr! pair val) alist)
        (cons (cons key val) alist))))

  (define (pgetq key plist . rest)
    (let lp ((plist plist))
      (cond
        ((null? plist) (if (pair? rest) (car rest) #f))
        ((eq? (car plist) key) (cadr plist))
        (else (lp (cddr plist))))))

  (define (pgetv key plist . rest)
    (let lp ((plist plist))
      (cond
        ((null? plist) (if (pair? rest) (car rest) #f))
        ((eqv? (car plist) key) (cadr plist))
        (else (lp (cddr plist))))))

  (define (pget key plist . rest)
    (let lp ((plist plist))
      (cond
        ((null? plist) (if (pair? rest) (car rest) #f))
        ((equal? (car plist) key) (cadr plist))
        (else (lp (cddr plist))))))

  (define (alist-put key val alist)
    (cons (cons key val)
          (filter (lambda (p) (not (equal? (car p) key))) alist)))

  (define (alist-remove key alist)
    (filter (lambda (p) (not (equal? (car p) key))) alist))

  (define (filter pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
      (else (filter pred (cdr lst)))))

  ) ;; end library
