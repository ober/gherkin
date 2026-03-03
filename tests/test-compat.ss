#!chezscheme
;;; test-compat.ss -- Tests for gambit-compat.sls
(import (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name) (compat gambit-compat) (tests test-helpers))

(test-begin "Gambit Compatibility Layer")

;;;; Special values
(test-assert "void returns void-obj" (void? (void)))
(test-assert "void is unique" (not (void? 42)))
(test-assert "absent-obj" (absent-obj? (absent-obj)))
(test-assert "unbound-obj" (unbound-obj? (unbound-obj)))
(test-assert "deleted-obj" (deleted-obj? (deleted-obj)))
(test-assert "unused-obj" (unused-obj? (unused-obj)))
(test-assert "special values distinct" (not (eq? (void) (absent-obj))))

;;;; Fixnum operations
(test-equal "|##fx+|" 7 (|##fx+| 3 4))
(test-equal "|##fx-|" 1 (|##fx-| 4 3))
(test-equal "|##fx*|" 12 (|##fx*| 3 4))
(test-equal "|##fx/|" 3 (|##fx/| 7 2))
(test-equal "|##fxmodulo|" 1 (|##fxmodulo| 7 3))
(test-assert "|##fx<|" (|##fx<| 1 2))
(test-assert "|##fx>|" (|##fx>| 2 1))
(test-assert "|##fx=|" (|##fx=| 3 3))
(test-assert "|##fx>=|" (|##fx>=| 3 3))
(test-assert "|##fx<=|" (|##fx<=| 3 3))
(test-equal "|##fxand|" 3 (|##fxand| 7 3))
(test-equal "|##fxior|" 7 (|##fxior| 5 3))
(test-equal "|##fxxor|" 6 (|##fxxor| 5 3))
(test-equal "|##fxarithmetic-shift-left|" 8 (|##fxarithmetic-shift-left| 1 3))
(test-equal "|##fxarithmetic-shift-right|" 2 (|##fxarithmetic-shift-right| 8 2))
(test-assert "|##fixnum?|" (|##fixnum?| 42))
(test-assert "|##max-fixnum| > 0" (> (|##max-fixnum|) 0))
(test-equal "|##fx+?| normal" 7 (|##fx+?| 3 4))
(test-assert "|##fx+?| no overflow on small" (fixnum? (|##fx+?| 1 1)))
(test-equal "|##fxabs| positive" 5 (|##fxabs| 5))
(test-equal "|##fxabs| negative" 5 (|##fxabs| -5))
(test-equal "|##fxmin|" 2 (|##fxmin| 2 3))
(test-equal "|##fxmax|" 3 (|##fxmax| 2 3))

;;;; Flonum operations
(test-assert "|##flonum?|" (|##flonum?| 3.14))
(test-assert "|##fl+|" (fl= (|##fl+| 1.0 2.0) 3.0))
(test-assert "|##fl*|" (fl= (|##fl*| 2.0 3.0) 6.0))
(test-assert "|##fl<|" (|##fl<| 1.0 2.0))
(test-equal "|##fixnum->flonum|" 42.0 (|##fixnum->flonum| 42))

;;;; Pair/list operations
(test-equal "|##car|" 1 (|##car| '(1 2 3)))
(test-equal "|##cdr|" '(2 3) (|##cdr| '(1 2 3)))
(test-equal "|##cons|" '(1 . 2) (|##cons| 1 2))
(test-assert "|##pair?|" (|##pair?| '(1)))
(test-assert "|##null?|" (|##null?| '()))
(test-assert "|##null?| false" (not (|##null?| '(1))))
(let ([p (cons 1 2)])
  (|##set-car!| p 10)
  (test-equal "|##set-car!|" 10 (car p))
  (|##set-cdr!| p 20)
  (test-equal "|##set-cdr!|" 20 (cdr p)))
(test-equal "|##length|" 3 (|##length| '(1 2 3)))
(test-equal "|##append|" '(1 2 3 4) (|##append| '(1 2) '(3 4)))
(test-equal "|##reverse|" '(3 2 1) (|##reverse| '(1 2 3)))

;;;; Vector operations
(let ([v (|##make-vector| 3 0)])
  (|##vector-set!| v 0 'a)
  (|##vector-set!| v 1 'b)
  (|##vector-set!| v 2 'c)
  (test-equal "|##vector-ref|" 'a (|##vector-ref| v 0))
  (test-equal "|##vector-length|" 3 (|##vector-length| v))
  (test-assert "|##vector?|" (|##vector?| v)))

;; vector-cas!
(let ([v (vector 'old)])
  (test-assert "|##vector-cas!| success" (|##vector-cas!| v 0 'old 'new))
  (test-equal "|##vector-cas!| result" 'new (vector-ref v 0))
  (test-assert "|##vector-cas!| fail" (not (|##vector-cas!| v 0 'old 'newer))))

(test-equal "|##vector-copy|" '#(1 2 3) (|##vector-copy| '#(1 2 3)))
(test-equal "|##subvector|" '#(2 3) (|##subvector| '#(1 2 3 4) 1 3))

;;;; String operations
(test-equal "|##string-length|" 5 (|##string-length| "hello"))
(test-equal "|##string-ref|" #\h (|##string-ref| "hello" 0))
(test-equal "|##string-append|" "foobar" (|##string-append| "foo" "bar"))
(test-equal "|##substring|" "ell" (|##substring| "hello" 1 4))
(test-assert "|##string=?|" (|##string=?| "abc" "abc"))
(test-assert "|##string<?|" (|##string<?| "abc" "abd"))
(test-equal "|##string->symbol|" 'hello (|##string->symbol| "hello"))
(test-equal "|##symbol->string|" "hello" (|##symbol->string| 'hello))

;;;; Keywords
(let ([kw (|##string->keyword| "name")])
  (test-assert "|##keyword?|" (|##keyword?| kw))
  (test-equal "|##keyword->string|" "name" (|##keyword->string| kw))
  ;; Same keyword interned
  (test-assert "keyword identity" (eq? kw (|##string->keyword| "name"))))

;;;; Byte vectors
(let ([bv (u8vector 1 2 3)])
  (test-assert "u8vector?" (u8vector? bv))
  (test-equal "u8vector-ref" 2 (u8vector-ref bv 1))
  (test-equal "u8vector-length" 3 (u8vector-length bv)))
(test-equal "u8vector->list" '(1 2 3) (u8vector->list (u8vector 1 2 3)))
(test-equal "list->u8vector" 3 (u8vector-length (list->u8vector '(1 2 3))))
(let ([bv (u8vector-append (u8vector 1 2) (u8vector 3 4))])
  (test-equal "u8vector-append len" 4 (u8vector-length bv))
  (test-equal "u8vector-append val" 3 (u8vector-ref bv 2)))

;;;; Box
(let ([b (box 42)])
  (test-assert "box?" (box? b))
  (test-equal "unbox" 42 (unbox b))
  (set-box! b 99)
  (test-equal "set-box!" 99 (unbox b)))

;;;; Hash tables
(let ([t (make-table)])
  (test-assert "table?" (table? t))
  (table-set! t 'a 1)
  (table-set! t 'b 2)
  (test-equal "table-ref" 1 (table-ref t 'a))
  (test-equal "table-ref default" 'none (table-ref t 'c 'none))
  (test-equal "table-length" 2 (table-length t))
  (table-delete! t 'a)
  (test-equal "table-delete!" 1 (table-length t))
  (test-equal "table-ref after delete" 'none (table-ref t 'a 'none)))

;; table->list
(let ([t (make-table)])
  (table-set! t 'x 10)
  (table-set! t 'y 20)
  (let ([lst (table->list t)])
    (test-equal "table->list length" 2 (length lst))
    (test-assert "table->list pairs" (for-all pair? lst))))

;; table-copy
(let ([t (make-table)])
  (table-set! t 'a 1)
  (let ([t2 (table-copy t)])
    (table-set! t2 'a 2)
    (test-equal "table-copy independent" 1 (table-ref t 'a))
    (test-equal "table-copy modified" 2 (table-ref t2 'a))))

;;;; Continuations
(test-equal "|##continuation-capture|"
  42
  (|##continuation-capture| (lambda (k) (|##continuation-return| k 42))))

;;;; Exception handling
(test-equal "|##with-exception-catcher|"
  'caught
  (|##with-exception-catcher|
    (lambda (exn) 'caught)
    (lambda () (error 'test "boom"))))

;;;; Serial numbers
(let ([n1 (|##object->serial-number| 'a)]
      [n2 (|##object->serial-number| 'b)]
      [n3 (|##object->serial-number| 'a)])
  (test-assert "serial number positive" (> n1 0))
  (test-assert "serial number unique" (not (= n1 n2)))
  (test-equal "serial number stable" n1 n3))

;;;; Property lists
(|##putprop| 'test-sym 'color 'red)
(test-equal "|##getprop|" 'red (|##getprop| 'test-sym 'color))
(|##remprop| 'test-sym 'color)
(test-assert "|##remprop|" (not (|##getprop| 'test-sym 'color)))

;;;; GC
(test-assert "|##gc| runs" (begin (|##gc|) #t))

;;;; Timing
(test-assert "|##cpu-time|" (>= (|##cpu-time|) 0))
(test-assert "|##real-time|" (>= (|##real-time|) 0))

(test-end)
(let-values ([(p f) (test-stats)])
  (exit (if (> f 0) 1 0)))
