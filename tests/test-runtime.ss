#!chezscheme
;;; test-runtime.ss -- Test the Phase 2 runtime modules
(import
  (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name
          andmap ormap iota last-pair find
          1+ 1- fx/ fx1+ fx1-
          error error? raise with-exception-handler identifier?
          hash-table? make-hash-table)
  (compat types)
  (runtime util)
  (except (runtime table) string-hash)
  (runtime c3)
  (runtime control)
  (runtime mop)
  (runtime error)
  (runtime hash)
  (runtime syntax)
  (runtime eval)
  (tests test-helpers))

(test-begin "Phase 2: Runtime")

;;; Test util
(test-equal "displayln" "hello\n"
  (let-values (((port get) (open-string-output-port)))
    (parameterize ((current-output-port port))
      (displayln "hello"))
    (get)))

(test-equal "foldl1" 10 (foldl1 + 0 '(1 2 3 4)))
(test-equal "foldr1" '(1 2 3 4) (foldr1 cons '() '(1 2 3 4)))
(test-assert "andmap1 true" (andmap1 number? '(1 2 3)))
(test-assert "andmap1 false" (not (andmap1 number? '(1 "x" 3))))
(test-assert "ormap1 true" (ormap1 string? '(1 "x" 3)))
(test-equal "filter-map1" '(2 4 6)
  (filter-map1 (lambda (x) (and (even? x) x)) '(1 2 3 4 5 6)))
(test-equal "agetq" 2 (agetq 'b '((a . 1) (b . 2) (c . 3))))
(test-equal "agetq default" 'none (agetq 'z '((a . 1)) 'none))
(test-equal "pgetq" 42 (pgetq 'x '(a 1 x 42 b 2)))
(test-equal "find" 4 (find even? '(1 3 4 5)))
(test-assert "memf" (pair? (memf even? '(1 3 4 5))))
(test-equal "remove1" '(1 3) (remove1 2 '(1 2 3)))
(test-equal "string-split" '("a" "b" "c") (string-split "a/b/c" #\/))
(test-equal "string-join" "a-b-c" (string-join '("a" "b" "c") "-"))
(test-assert "string-empty?" (string-empty? ""))
(test-equal "string-index" 2 (string-index "hello" #\l))
(test-equal "iota" '(0 1 2 3 4) (iota 5))
(test-equal "iota with start" '(1 2 3) (iota 3 1))
(test-equal "make-symbol" 'hello (make-symbol "hello"))
(test-equal "fx1+" 6 (fx1+ 5))

;;; Test table
(let ((t (make-symbolic-table #f 0)))
  (symbolic-table-set! t 'a 1)
  (symbolic-table-set! t 'b 2)
  (test-equal "symbolic-table-ref" 1 (symbolic-table-ref t 'a 'none))
  (test-equal "symbolic-table-ref default" 'none (symbolic-table-ref t 'z 'none))
  (symbolic-table-delete! t 'a)
  (test-equal "symbolic-table after delete" 'none (symbolic-table-ref t 'a 'none)))

(let ((t (make-eq-table)))
  (eq-table-set! t 'x 10)
  (eq-table-set! t 'y 20)
  (test-equal "eq-table-ref" 10 (eq-table-ref t 'x #f))
  (eq-table-update! t 'x (lambda (v) (+ v 5)) 0)
  (test-equal "eq-table-update!" 15 (eq-table-ref t 'x #f)))

;;; Test gc-table (Chez hashtable wrapper)
(let ((t (make-gc-table 16)))
  (gc-table-set! t 'a 100)
  (gc-table-set! t 'b 200)
  (test-equal "gc-table-ref" 100 (gc-table-ref t 'a #f))
  (test-equal "gc-table-length" 2 (gc-table-length t)))

;;; Test MOP
(test-assert "t::t exists" (|##structure?| t::t))
(test-assert "class::t exists" (|##structure?| class::t))
(test-assert "object::t exists" (|##structure?| object::t))
(test-assert "class-type? class::t" (class-type? class::t))
(test-assert "class-type? t::t" (class-type? t::t))
(test-equal "class-type-id t::t" 't (class-type-id t::t))
(test-equal "class-type-name class::t" 'class (class-type-name class::t))

;; Create a simple struct
(let ((point::t (make-class-type 'point 'point (list object::t) '(x y)
                   '((struct: . #t)) #f)))
  (test-assert "point is class-type" (class-type? point::t))
  (test-assert "point is struct" (struct-type? point::t))
  (test-equal "point field-count" 2 (class-type-field-count point::t))

  ;; Create instance
  (let ((p (make-class-instance point::t 'x: 10 'y: 20)))
    (test-assert "instance check" (class-instance? point::t p))
    (test-equal "slot-ref x" 10 (slot-ref p 'x))
    (test-equal "slot-ref y" 20 (slot-ref p 'y))
    (slot-set! p 'x 30)
    (test-equal "slot-set! x" 30 (slot-ref p 'x))))

;; Test inheritance
(let* ((shape::t (make-class-type 'shape 'shape (list object::t) '(color)
                    '((struct: . #t)) #f))
       (rect::t (make-class-type 'rect 'rect (list shape::t) '(width height)
                   '((struct: . #t)) #f)))
  (test-assert "rect is class-type" (class-type? rect::t))
  (test-equal "rect field-count" 3 (class-type-field-count rect::t))

  (let ((r (make-class-instance rect::t 'color: 'red 'width: 10 'height: 20)))
    (test-assert "rect instance" (class-instance? rect::t r))
    (test-assert "rect is shape" (class-instance? shape::t r))
    (test-equal "rect color" 'red (slot-ref r 'color))
    (test-equal "rect width" 10 (slot-ref r 'width))
    (test-equal "rect height" 20 (slot-ref r 'height))))

;;; Test hash (high-level API)
(let ((ht (make-hash-table)))
  (hash-put! ht 'a 1)
  (hash-put! ht 'b 2)
  (test-equal "hash-get" 1 (hash-get ht 'a))
  (test-assert "hash-key?" (hash-key? ht 'a))
  (test-assert "hash-key? false" (not (hash-key? ht 'z)))
  (test-equal "hash-length" 2 (hash-length ht))
  (hash-remove! ht 'a)
  (test-assert "hash-remove!" (not (hash-key? ht 'a))))

;;; Test syntax
(let ((ast (make-AST '(+ 1 2) '("test.ss" 1 0))))
  (test-assert "AST?" (AST? ast))
  (test-equal "AST-e" '(+ 1 2) (AST-e ast))
  (test-assert "stx-pair?" (stx-pair? ast))
  (test-assert "stx-list?" (stx-list? ast)))

(test-assert "identifier?" (identifier? 'foo))
(test-assert "identifier? AST" (identifier? (make-AST 'foo #f)))
(test-assert "stx-datum?" (stx-datum? 42))

;;; Test eval types
(test-assert "__syntax" (__syntax? (__syntax (lambda (x) x) 'test-macro)))
(test-assert "__core-form" (__core-form? (__core-form (string->symbol "%#begin") (lambda (stx) stx))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
