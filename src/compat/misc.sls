#!chezscheme
;;; misc.sls -- Compat shim for Gerbil's misc modules
;;; Provides functions from :std/misc/string, :std/misc/list, :std/misc/path,
;;; :std/misc/hash, and :std/srfi/1 that are not compiled inline by the compiler.
;;; Many common functions (string-join, string-split, etc.) are compiled inline,
;;; but this library provides the remaining ones.

(library (compat misc)
  (export
    ;; :std/misc/string
    string-empty?
    string-prefix?
    string-suffix?
    string-contains
    string-trim-eol

    ;; :std/misc/list
    flatten
    plist->alist
    alist->plist
    length=?
    length>?
    snoc
    butlast

    ;; :std/misc/path
    path-expand
    path-normalize
    path-extension
    path-strip-extension
    path-directory
    path-strip-directory

    ;; :std/srfi/1
    any
    every
    filter
    remove
    partition
    fold
    fold-right
    unfold
    iota
    zip
    take
    drop
    take-while
    drop-while
    append-map
    concatenate
    delete
    delete-duplicates
    alist-cons
    alist-delete
    first second third fourth fifth
    last
    last-pair
    count)

  (import
    (except (chezscheme) iota last-pair filter remove partition
            fold-right path-extension))

  ;; --- :std/misc/string ---

  (define (string-empty? s) (= (string-length s) 0))

  (define (string-prefix? prefix str)
    (let ((plen (string-length prefix))
          (slen (string-length str)))
      (and (<= plen slen)
           (string=? prefix (substring str 0 plen)))))

  (define (string-suffix? suffix str)
    (let ((suflen (string-length suffix))
          (slen (string-length str)))
      (and (<= suflen slen)
           (string=? suffix (substring str (- slen suflen) slen)))))

  (define (string-contains haystack needle)
    (let ((hlen (string-length haystack))
          (nlen (string-length needle)))
      (if (= nlen 0) 0
        (let lp ((i 0))
          (cond
            ((> (+ i nlen) hlen) #f)
            ((string=? needle (substring haystack i (+ i nlen))) i)
            (else (lp (+ i 1))))))))

  (define (string-trim-eol str)
    (let lp ((i (- (string-length str) 1)))
      (cond
        ((< i 0) "")
        ((memv (string-ref str i) '(#\newline #\return))
         (lp (- i 1)))
        (else (substring str 0 (+ i 1))))))

  ;; --- :std/misc/list ---

  (define (flatten lst)
    (cond
      ((null? lst) '())
      ((pair? (car lst))
       (append (flatten (car lst)) (flatten (cdr lst))))
      (else (cons (car lst) (flatten (cdr lst))))))

  (define (plist->alist plist)
    (let lp ((plist plist) (result '()))
      (if (or (null? plist) (null? (cdr plist)))
        (reverse result)
        (lp (cddr plist) (cons (cons (car plist) (cadr plist)) result)))))

  (define (alist->plist alist)
    (let lp ((alist alist) (result '()))
      (if (null? alist)
        (reverse result)
        (lp (cdr alist) (cons (cdar alist) (cons (caar alist) result))))))

  (define (length=? lst n) (= (length lst) n))
  (define (length>? lst n) (> (length lst) n))

  (define (snoc lst x) (append lst (list x)))

  (define (butlast lst)
    (if (or (null? lst) (null? (cdr lst))) '()
      (cons (car lst) (butlast (cdr lst)))))

  ;; --- :std/misc/path ---

  (define (path-expand path . rest)
    (let ((base (if (pair? rest) (car rest) (current-directory))))
      (cond
        ((and (> (string-length path) 0)
              (char=? (string-ref path 0) #\~))
         (string-append (getenv "HOME")
                        (substring path 1 (string-length path))))
        ((and (> (string-length path) 0)
              (char=? (string-ref path 0) #\/))
         path)
        (else (string-append base "/" path)))))

  (define (path-normalize path) (path-expand path))

  (define (path-extension path)
    (let ((dot (string-last-index-of path #\.))
          (slash (string-last-index-of path #\/)))
      (if (and dot (or (not slash) (> dot slash)))
        (substring path dot (string-length path))
        #f)))

  (define (path-strip-extension path)
    (let ((dot (string-last-index-of path #\.))
          (slash (string-last-index-of path #\/)))
      (if (and dot (or (not slash) (> dot slash)))
        (substring path 0 dot)
        path)))

  (define (path-directory path)
    (let ((slash (string-last-index-of path #\/)))
      (if slash
        (if (= slash 0) "/" (substring path 0 slash))
        ".")))

  (define (path-strip-directory path)
    (let ((slash (string-last-index-of path #\/)))
      (if slash
        (substring path (+ slash 1) (string-length path))
        path)))

  (define (string-last-index-of str ch)
    (let lp ((i (- (string-length str) 1)))
      (cond
        ((< i 0) #f)
        ((char=? (string-ref str i) ch) i)
        (else (lp (- i 1))))))

  ;; --- :std/srfi/1 ---

  (define (any pred lst)
    (cond
      ((null? lst) #f)
      ((pred (car lst)) #t)
      (else (any pred (cdr lst)))))

  (define (every pred lst)
    (cond
      ((null? lst) #t)
      ((pred (car lst)) (every pred (cdr lst)))
      (else #f)))

  (define (filter pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst)) (cons (car lst) (filter pred (cdr lst))))
      (else (filter pred (cdr lst)))))

  (define (remove pred lst)
    (filter (lambda (x) (not (pred x))) lst))

  (define (partition pred lst)
    (let lp ((lst lst) (yes '()) (no '()))
      (cond
        ((null? lst) (values (reverse yes) (reverse no)))
        ((pred (car lst)) (lp (cdr lst) (cons (car lst) yes) no))
        (else (lp (cdr lst) yes (cons (car lst) no))))))

  (define (fold kons knil lst)
    (if (null? lst) knil
      (fold kons (kons (car lst) knil) (cdr lst))))

  (define (fold-right kons knil lst)
    (if (null? lst) knil
      (kons (car lst) (fold-right kons knil (cdr lst)))))

  (define (unfold pred f g seed . rest)
    (let ((tail-gen (if (pair? rest) (car rest) (lambda (x) '()))))
      (let lp ((seed seed))
        (if (pred seed)
          (tail-gen seed)
          (cons (f seed) (lp (g seed)))))))

  (define (iota count . rest)
    (let ((start (if (pair? rest) (car rest) 0))
          (step (if (and (pair? rest) (pair? (cdr rest))) (cadr rest) 1)))
      (let lp ((i 0) (result '()))
        (if (>= i count)
          (reverse result)
          (lp (+ i 1) (cons (+ start (* i step)) result))))))

  (define (zip . lsts)
    (apply map list lsts))

  (define (take lst n)
    (if (or (= n 0) (null? lst)) '()
      (cons (car lst) (take (cdr lst) (- n 1)))))

  (define (drop lst n)
    (if (or (= n 0) (null? lst)) lst
      (drop (cdr lst) (- n 1))))

  (define (take-while pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst)) (cons (car lst) (take-while pred (cdr lst))))
      (else '())))

  (define (drop-while pred lst)
    (cond
      ((null? lst) '())
      ((pred (car lst)) (drop-while pred (cdr lst)))
      (else lst)))

  (define (append-map f lst)
    (apply append (map f lst)))

  (define (concatenate lsts)
    (apply append lsts))

  (define (delete x lst . rest)
    (let ((pred (if (pair? rest) (car rest) equal?)))
      (filter (lambda (y) (not (pred x y))) lst)))

  (define (delete-duplicates lst . rest)
    (let ((pred (if (pair? rest) (car rest) equal?)))
      (let lp ((lst lst) (result '()))
        (cond
          ((null? lst) (reverse result))
          ((exists (lambda (y) (pred (car lst) y)) result)
           (lp (cdr lst) result))
          (else (lp (cdr lst) (cons (car lst) result)))))))

  (define (alist-cons key val alist)
    (cons (cons key val) alist))

  (define (alist-delete key alist . rest)
    (let ((pred (if (pair? rest) (car rest) equal?)))
      (filter (lambda (pair) (not (pred key (car pair)))) alist)))

  (define (first lst) (car lst))
  (define (second lst) (cadr lst))
  (define (third lst) (caddr lst))
  (define (fourth lst) (cadddr lst))
  (define (fifth lst) (car (cddddr lst)))

  (define (last lst)
    (if (null? (cdr lst)) (car lst) (last (cdr lst))))

  (define (last-pair lst)
    (if (null? (cdr lst)) lst (last-pair (cdr lst))))

  (define (count pred lst)
    (let lp ((lst lst) (n 0))
      (if (null? lst) n
        (lp (cdr lst) (if (pred (car lst)) (+ n 1) n)))))

  ) ;; end library
