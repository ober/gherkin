(begin
  (define macro-object::t
    (make-class-type 'gerbil\x23;macro-object::t 'macro-object (list object::t)
      '(macro) '((id: . gerbil.core\x23;macro-object::t)) '#f))
  (define (macro-object . args)
    (apply make-macro-object args))
  (define (macro-object? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;macro-object::t))
  (define (make-macro-object . args)
    (apply make-instance macro-object::t args))
  (define (&macro-object-macro-set! obj val)
    (unchecked-slot-set! obj 'macro val))
  (define (&macro-object-macro obj)
    (unchecked-slot-ref obj 'macro))
  (define (macro-object-macro-set! obj val)
    (unchecked-slot-set! obj 'macro val))
  (define (macro-object-macro obj)
    (unchecked-slot-ref obj 'macro)))

(begin
  (define macro-object::apply-macro-expander
    (lambda (self stx)
      (core-apply-expander (macro-object-macro self) stx)))
  (bind-method!
    macro-object::t
    'apply-macro-expander
    macro-object::apply-macro-expander))

