#!chezscheme
;;; sugar.sls -- Bootstrap Gerbil sugar macros for Chez Scheme
;;; Provides: cut, with-syntax*, match, check-procedure

(library (boot sugar)
  (export cut match with-syntax* check-procedure underscore?)

  (import (chezscheme))

  ;; --- cut (SRFI-26 style, simplified) ---
  ;; Supports <> as placeholder for arguments
  (define-syntax cut
    (lambda (stx)
      (syntax-case stx (<>)
        ((_ proc <> arg* ...)
         (with-syntax ((tmp (datum->syntax #'proc (gensym "cut"))))
           #'(lambda (tmp) (proc tmp arg* ...))))
        ((_ proc arg1 <>)
         (with-syntax ((tmp (datum->syntax #'proc (gensym "cut"))))
           #'(lambda (tmp) (proc arg1 tmp))))
        ((_ proc arg1 arg2 <>)
         (with-syntax ((tmp (datum->syntax #'proc (gensym "cut"))))
           #'(lambda (tmp) (proc arg1 arg2 tmp))))
        ((_ proc arg* ...)
         #'(lambda () (proc arg* ...))))))

  ;; --- with-syntax* (sequential with-syntax) ---
  (define-syntax with-syntax*
    (syntax-rules ()
      ((_ () body ...) (begin body ...))
      ((_ (binding rest ...) body ...)
       (with-syntax (binding)
         (with-syntax* (rest ...) body ...)))))

  ;; --- check-procedure ---
  (define-syntax check-procedure
    (syntax-rules ()
      ((_ proc)
       (unless (procedure? proc)
         (error 'check-procedure "expected procedure" proc)))))

  ;; --- underscore? ---
  (define (underscore? stx)
    ;; In expander context, underscore is the _ identifier
    #f)  ;; placeholder

  ;; --- match (simple pattern matching) ---
  ;; Supports:
  ;;   [hd . rest]    → pair destructuring
  ;;   []             → null check
  ;;   (? pred)       → predicate check (returns result or fails)
  ;;   (? pred var)   → predicate with binding
  ;;   _              → wildcard
  ;;   else           → default clause
  ;;   literal        → equality check
  (define-syntax match
    (lambda (stx)
      (define (generate-match-clause target-id clause k-fail)
        (syntax-case clause (else)
          ;; (pattern body ...) or (pattern (=> fail) body ...)
          ((pat body0 body* ...)
           (generate-pattern target-id #'pat #'(begin body0 body* ...) k-fail))))

      (define (generate-pattern target pat body fail)
        (syntax-case pat (_ ? else)
          ;; wildcard
          (_ body)
          ;; predicate: (? pred)
          ((? pred)
           #`(if (pred #,target) #,body #,fail))
          ;; predicate with negative: (? (not pred))
          ((? (not pred))
           #`(if (not (pred #,target)) #,body #,fail))
          ;; [hd . rest] → pair destructuring
          ((hd . rest)
           (with-syntax ((tmp-hd (datum->syntax #'hd (gensym "hd")))
                         (tmp-tl (datum->syntax #'hd (gensym "tl"))))
             #`(if (pair? #,target)
                 (let ((tmp-hd (car #,target))
                       (tmp-tl (cdr #,target)))
                   #,(generate-pattern #'tmp-hd #'hd
                       (generate-pattern #'tmp-tl #'rest body fail)
                       fail))
                 #,fail)))
          ;; [] → null check
          (() #`(if (null? #,target) #,body #,fail))
          ;; identifier → bind it
          (id (identifier? #'id)
           #`(let ((id #,target)) #,body))
          ;; literal (number, string, etc.)
          (lit
           #`(if (equal? #,target 'lit) #,body #,fail))))

      (syntax-case stx ()
        ((_ expr clause0 clause* ...)
         (with-syntax ((val (datum->syntax #'expr (gensym "match-val"))))
           (let loop ((clauses #'(clause0 clause* ...)))
             (syntax-case clauses (else)
               (((else body0 body* ...))
                #'(begin body0 body* ...))
               (((pat body0 body* ...) rest ...)
                (with-syntax ((fail-body (loop #'(rest ...)))
                              (success #'(begin body0 body* ...)))
                  (generate-pattern #'val #'pat #'success #'fail-body)))
               (()
                #'(error 'match "no matching clause" val))))))))))

  ) ;; end library
