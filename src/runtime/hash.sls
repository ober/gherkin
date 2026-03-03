#!chezscheme
;;; hash.sls -- High-level Gerbil hash table API on Chez Scheme
;;; Wraps the low-level table module with Gerbil-compatible interface.

(library (runtime hash)
  (export
    ;; types
    hash-table::t
    ;; construction
    make-hash-table make-hash-table-eq make-hash-table-eqv
    make-hash-table-symbolic make-hash-table-string make-hash-table-immediate
    list->hash-table list->hash-table-eq plist->hash-table plist->hash-table-eq
    ;; operations
    hash-length hash-ref hash-get hash-put! hash-update! hash-remove!
    hash-key? hash->list hash->plist
    hash-for-each hash-map hash-fold hash-find
    hash-keys hash-values
    hash-copy hash-clear! hash-merge hash-merge!
    ;; predicates
    hash-table? is-hash-table?
    ;; errors
    raise-unbound-key-error unbound-key-error?
    )

  (import
    (except (chezscheme) void error error? raise with-exception-handler
            andmap ormap iota last-pair find
            1+ 1- fx/ fx1+ fx1-
            hash-table? make-hash-table)
    (rename (only (chezscheme) error raise)
            (error chez:error) (raise chez:raise))
    ;; gambit-compat not needed: structure ops come from (compat types)
    (compat types)
    (runtime util)
    (except (runtime table) string-hash)
    (runtime mop)
    (runtime error))

  ;; --- Hash table type ---
  ;; We use a simple wrapper: a gerbil-struct with fields (table-impl kind)
  ;; where table-impl is a raw-table or gc-table from table.sls

  (define hash-table::t
    (make-class-type
      (string->symbol "gerbil#HashTable::t")
      'HashTable
      (list object::t)
      '(table kind)
      '((struct: . #t))
      #f))

  (define (hash-table? obj)
    (|##structure-instance-of?| obj (string->symbol "gerbil#HashTable::t")))

  (define is-hash-table? hash-table?)

  ;; --- Unbound key error ---
  (define (raise-unbound-key-error where key . args)
    (chez:raise
      (condition
        (make-message-condition (format "unbound key: ~a" key))
        (make-irritants-condition (list key))
        (make-who-condition where))))

  (define (unbound-key-error? e)
    (and (who-condition? e)
         (message-condition? e)
         (string-prefix? "unbound key" (condition-message e))))

  (define (string-prefix? prefix str)
    (and (fx<= (string-length prefix) (string-length str))
         (string=? prefix (substring str 0 (string-length prefix)))))

  ;; --- Internal: make hash-table wrapper ---
  (define (wrap-hash-table impl kind)
    (let ((ht (make-class-instance hash-table::t)))
      (|##structure-set!| ht 1 impl)
      (|##structure-set!| ht 2 kind)
      ht))

  (define (ht-impl ht) (|##structure-ref| ht 1))
  (define (ht-kind ht) (|##structure-ref| ht 2))

  ;; --- Constructors ---
  ;; Default make-hash-table uses equal? comparison (works with strings, numbers, etc.)
  (define make-hash-table
    (case-lambda
      (() (wrap-hash-table (make-hashtable equal-hash equal?) 'equal))
      ((size-hint) (wrap-hash-table (make-hashtable equal-hash equal?
                                      (if (fixnum? size-hint) size-hint 16))
                                    'equal))))

  ;; make-hash-table-eq uses eq? comparison (fast for symbols)
  (define make-hash-table-eq
    (case-lambda
      (() (wrap-hash-table (make-gc-table) 'gc))
      ((size-hint) (wrap-hash-table (make-gc-table size-hint) 'gc))))

  (define make-hash-table-eqv
    (case-lambda
      (() (wrap-hash-table (make-eqv-table) 'eqv))
      ((size-hint) (wrap-hash-table (make-eqv-table size-hint) 'eqv))))

  (define make-hash-table-symbolic
    (case-lambda
      (() (wrap-hash-table (make-symbolic-table #f 0) 'symbolic))
      ((size-hint) (wrap-hash-table (make-symbolic-table size-hint 0) 'symbolic))))

  (define make-hash-table-string
    (case-lambda
      (() (wrap-hash-table (make-string-table) 'string))
      ((size-hint) (wrap-hash-table (make-string-table size-hint) 'string))))

  (define make-hash-table-immediate
    (case-lambda
      (() (wrap-hash-table (make-immediate-table) 'immediate))
      ((size-hint) (wrap-hash-table (make-immediate-table size-hint) 'immediate))))

  ;; --- Dispatch based on kind ---
  (define (ht-ref ht key default)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-ref impl key default))
        ((symbolic) (symbolic-table-ref impl key default))
        ((eq) (eq-table-ref impl key default))
        ((eqv) (eqv-table-ref impl key default))
        ((string) (string-table-ref impl key default))
        ((immediate) (immediate-table-ref impl key default))
        (else (gc-table-ref impl key default)))))

  (define (ht-set! ht key value)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-set! impl key value))
        ((symbolic) (symbolic-table-set! impl key value))
        ((eq) (eq-table-set! impl key value))
        ((eqv) (eqv-table-set! impl key value))
        ((string) (string-table-set! impl key value))
        ((immediate) (immediate-table-set! impl key value))
        (else (gc-table-set! impl key value)))))

  (define (ht-update! ht key update default)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-update! impl key update default))
        ((symbolic) (symbolic-table-update! impl key update default))
        ((eq) (eq-table-update! impl key update default))
        ((eqv) (eqv-table-update! impl key update default))
        ((string) (string-table-update! impl key update default))
        ((immediate) (immediate-table-update! impl key update default))
        (else (gc-table-update! impl key update default)))))

  (define (ht-delete! ht key)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-delete! impl key))
        ((symbolic) (symbolic-table-delete! impl key))
        ((eq) (eq-table-delete! impl key))
        ((eqv) (eqv-table-delete! impl key))
        ((string) (string-table-delete! impl key))
        ((immediate) (immediate-table-delete! impl key))
        (else (gc-table-delete! impl key)))))

  (define (ht-for-each ht proc)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-for-each impl proc))
        ((symbolic eq eqv string immediate)
         (raw-table-for-each impl proc))
        (else (gc-table-for-each impl proc)))))

  (define (ht-length ht)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc equal) (gc-table-length impl))
        ((symbolic eq eqv string immediate) (&raw-table-count impl))
        (else (gc-table-length impl)))))

  ;; --- Public API ---
  (define (hash-length ht) (ht-length ht))

  (define *not-found* (gensym "hash-not-found"))

  (define hash-ref
    (case-lambda
      ((ht key) (hash-ref ht key #f))
      ((ht key default)
       (let ((v (ht-ref ht key *not-found*)))
         (if (eq? v *not-found*)
           (if (procedure? default) (default) default)
           v)))))

  (define (hash-get ht key)
    (ht-ref ht key #f))

  (define (hash-put! ht key value)
    (ht-set! ht key value))

  (define hash-update!
    (case-lambda
      ((ht key update) (hash-update! ht key update #f))
      ((ht key update default)
       (ht-update! ht key update default))))

  (define (hash-remove! ht key)
    (ht-delete! ht key))

  (define (hash-key? ht key)
    (not (eq? (ht-ref ht key *not-found*) *not-found*)))

  (define (hash->list ht)
    (let ((result '()))
      (ht-for-each ht (lambda (k v) (set! result (cons (cons k v) result))))
      result))

  (define (hash->plist ht)
    (let ((result '()))
      (ht-for-each ht (lambda (k v) (set! result (cons k (cons v result)))))
      result))

  (define (hash-for-each proc ht)
    (ht-for-each ht proc))

  (define (hash-map proc ht)
    (let ((result '()))
      (ht-for-each ht (lambda (k v) (set! result (cons (proc k v) result))))
      result))

  (define (hash-fold proc init ht)
    (let ((acc init))
      (ht-for-each ht (lambda (k v) (set! acc (proc k v acc))))
      acc))

  (define (hash-find proc ht)
    (call/cc
      (lambda (return)
        (ht-for-each ht (lambda (k v) (when (proc k v) (return (cons k v)))))
        #f)))

  (define (hash-keys ht)
    (let ((result '()))
      (ht-for-each ht (lambda (k v) (set! result (cons k result))))
      result))

  (define (hash-values ht)
    (let ((result '()))
      (ht-for-each ht (lambda (k v) (set! result (cons v result))))
      result))

  (define (hash-copy ht)
    (let ((new-ht (case (ht-kind ht)
                    ((gc) (make-hash-table))
                    ((symbolic) (make-hash-table-symbolic))
                    ((eq) (make-hash-table-eq))
                    ((eqv) (make-hash-table-eqv))
                    ((string) (make-hash-table-string))
                    ((immediate) (make-hash-table-immediate))
                    (else (make-hash-table)))))
      (ht-for-each ht (lambda (k v) (ht-set! new-ht k v)))
      new-ht))

  (define (hash-clear! ht)
    (let ((kind (ht-kind ht))
          (impl (ht-impl ht)))
      (case kind
        ((gc) (gc-table-clear! impl))
        ((symbolic eq eqv string immediate) (raw-table-clear! impl))
        (else (gc-table-clear! impl)))))

  (define (hash-merge ht1 ht2)
    (let ((new-ht (hash-copy ht1)))
      (ht-for-each ht2 (lambda (k v) (ht-set! new-ht k v)))
      new-ht))

  (define (hash-merge! ht1 ht2)
    (ht-for-each ht2 (lambda (k v) (ht-set! ht1 k v)))
    ht1)

  ;; --- List/plist converters ---
  (define list->hash-table
    (case-lambda
      ((lst) (list->hash-table-eq lst))
      ((lst size-hint) (list->hash-table-eq lst))))

  (define (list->hash-table-eq lst)
    (let ((ht (make-hash-table)))
      (for-each (lambda (p) (ht-set! ht (car p) (cdr p))) lst)
      ht))

  (define plist->hash-table
    (case-lambda
      ((lst) (plist->hash-table-eq lst))
      ((lst size-hint) (plist->hash-table-eq lst))))

  (define (plist->hash-table-eq lst)
    (let ((ht (make-hash-table)))
      (let lp ((rest lst))
        (when (and (pair? rest) (pair? (cdr rest)))
          (ht-set! ht (car rest) (cadr rest))
          (lp (cddr rest))))
      ht))

  ) ;; end library
