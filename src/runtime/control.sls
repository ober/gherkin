#!chezscheme
;;; control.sls -- Control flow primitives for Chez Scheme
;;; Ported from src/gerbil/runtime/control.ss

(library (runtime control)
  (export
    make-promise make-atomic-promise
    call-with-parameters
    with-unwind-protect
    keyword-dispatch keyword-rest
    )

  (import
    (except (chezscheme) void box box? unbox set-box!
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-)
    (only (compat gambit-compat) |##keyword?|)
    (runtime util)
    (except (runtime table) string-hash))

  ;; --- Promises ---
  (define (make-promise thunk)
    (delay (thunk)))

  (define (make-atomic-promise thunk)
    (let ((mx (make-mutex))
          (inner (make-promise thunk)))
      (make-promise
        (lambda ()
          (dynamic-wind
            (lambda () (mutex-acquire mx))
            (lambda () (force inner))
            (lambda () (mutex-release mx)))))))

  ;; --- Parameters ---
  (define call-with-parameters
    (case-lambda
      ((thunk) (thunk))
      ((thunk param val)
       (parameterize ((param val)) (thunk)))
      ((thunk param val . rest)
       (parameterize ((param val))
         (apply call-with-parameters thunk rest)))))

  ;; --- Unwind protect ---
  (define (with-unwind-protect K fini)
    (let ((entered #f))
      (dynamic-wind
        (lambda ()
          (when entered
            (error "Cannot re-enter unwind protected block"))
          (set! entered #t))
        K fini)))

  ;; --- Keyword dispatch ---
  ;; kwt: #f or a vector used as perfect hash-table for expected keywords
  ;; K: the target procedure
  ;; all-args: mixed keyword/positional arguments
  ;; Result: calls K with (keys . positional-args) where keys is a symbolic-table
  (define (keyword-dispatch kwt K . all-args)
    (when kwt
      (unless (vector? kwt)
        (error "keyword-dispatch: expected vector" kwt)))
    (unless (procedure? K)
      (error "keyword-dispatch: expected procedure" K))
    (let ((keys (make-symbolic-table #f 0)))
      (let lp ((rest all-args) (args #f) (tail #f))
        (cond
          ((pair? rest)
           (let ((hd (car rest))
                 (hd-rest (cdr rest)))
             (cond
               ((|##keyword?| hd)
                (if (pair? hd-rest)
                  (let ((val (car hd-rest))
                        (rest2 (cdr hd-rest)))
                    (when kwt
                      (let ((pos (fxmod (symbolic-hash hd) (vector-length kwt))))
                        (unless (eq? hd (vector-ref kwt pos))
                          (error "Unexpected keyword argument" K hd))))
                    (unless (eq? (symbolic-table-ref keys hd absent-value)
                                 absent-value)
                      (error "Duplicate keyword argument" K hd))
                    (symbolic-table-set! keys hd val)
                    (lp rest2 args tail))
                  (error "keyword-dispatch: keyword without value" hd)))
               ((eq? hd dssl-key-obj)
                (if (pair? hd-rest)
                  (let ((val (car hd-rest))
                        (rest2 (cdr hd-rest)))
                    (if args
                      (begin (set-cdr! tail hd-rest) (lp rest2 args hd-rest))
                      (lp rest2 hd-rest hd-rest)))
                  (error "keyword-dispatch: #!key without value")))
               ((eq? hd dssl-rest-obj)
                (if args
                  (begin (set-cdr! tail hd-rest) (apply K (cons keys args)))
                  (apply K (cons keys hd-rest))))
               (else
                 (if args
                   (begin (set-cdr! tail rest) (lp hd-rest args rest))
                   (lp hd-rest rest rest))))))
          (else
            (if args
              (begin (set-cdr! tail '()) (apply K (cons keys args)))
              (K keys)))))))

  (define (keyword-rest kwt . drop)
    (let ((rest '()))
      (raw-table-for-each
        kwt
        (lambda (k v)
          (unless (memq k drop)
            (set! rest (cons k (cons v rest))))))
      rest))

  ) ;; end library
