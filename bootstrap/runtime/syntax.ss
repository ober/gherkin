(define-syntax core-ast-case
  (syntax-rules ()
    [(_ expr body ...)
     (let ($e expr) (core-ast-case% $e body ...))]))

(define-syntax core-ast-case%
  (lambda (stx)
    (define (generate1 hd tgt K E kws)
      (with-syntax ([tgt tgt])
        (syntax-case hd ()
          [(hd . rest)
           (with-syntax*
             (($tgt (genident '$tgt))
               ($hd (genident '$hd))
               ($tl (genident '$tl))
               (body
                 (generate1 #'hd #'$hd (generate1 #'rest #'$tl K E kws) E
                   kws))
               (E E))
             #'(if (__AST-pair? tgt)
                   (let* ([$tgt (__AST-e tgt)]
                          [$hd (\x23;\x23;car $tgt)]
                          [$tl (\x23;\x23;cdr $tgt)])
                     body)
                   E))]
          [id
           (identifier? #'id)
           (cond
             [(underscore? #'id) K]
             [(find (cut bound-identifier=? <> #'id) (syntax->list kws))
              (with-syntax ([K K] [E E])
                #'(if (and (__AST-id? tgt) (eq? (__AST-e tgt) 'id)) K E))]
             [else (with-syntax ([K K]) #'(let ([id tgt]) K))])]
          [hd
           (with-syntax ([K K] [E E])
             #'(if (equal? (__AST-e tgt) 'hd) K E))])))
    (syntax-case stx ()
      [(_ tgt kws clause ...)
       (let recur ([rest #'(clause ...)])
         (match rest
           [(\x40;list hd . rest)
            (with-syntax*
              (($E (genident '$E))
                (E #'($E))
                (continue (recur rest))
                (body
                  (syntax-case hd (else)
                    [(else expr ...) #'(begin expr ...)]
                    [(pat expr) (generate1 #'pat #'tgt #'expr #'E #'kws)]
                    [(pat fender expr)
                     (generate1 #'pat #'tgt #'(if fender expr E) #'E
                       #'kws)])))
              #'(let ($E [lambda () continue]) body))]
           [(\x40;list)
            #'(__raise-syntax-error
                #f
                "Bad syntax; malformed ast clause"
                tgt)]))])))

(begin
  (define SyntaxError::t
    (make-class-type 'gerbil\x23;SyntaxError::t 'SyntaxError
      (list Exception::t StackTrace::t)
      '(message irritants where context phi marks)
      '((final: . #t)) '#f))
  (define (SyntaxError . args) (apply make-SyntaxError args))
  (define (SyntaxError? obj)
    (\x23;\x23;structure-instance-of?
      obj
      'gerbil\x23;SyntaxError::t))
  (define (make-SyntaxError . args)
    (apply make-instance SyntaxError::t args))
  (define (&SyntaxError-message-set! obj val)
    (unchecked-slot-set! obj 'message val))
  (define (&SyntaxError-message obj)
    (unchecked-slot-ref obj 'message))
  (define (SyntaxError-message-set! obj val)
    (unchecked-slot-set! obj 'message val))
  (define (SyntaxError-message obj)
    (unchecked-slot-ref obj 'message))
  (define (&SyntaxError-irritants-set! obj val)
    (unchecked-slot-set! obj 'irritants val))
  (define (&SyntaxError-irritants obj)
    (unchecked-slot-ref obj 'irritants))
  (define (SyntaxError-irritants-set! obj val)
    (unchecked-slot-set! obj 'irritants val))
  (define (SyntaxError-irritants obj)
    (unchecked-slot-ref obj 'irritants))
  (define (&SyntaxError-where-set! obj val)
    (unchecked-slot-set! obj 'where val))
  (define (&SyntaxError-where obj)
    (unchecked-slot-ref obj 'where))
  (define (SyntaxError-where-set! obj val)
    (unchecked-slot-set! obj 'where val))
  (define (SyntaxError-where obj)
    (unchecked-slot-ref obj 'where))
  (define (&SyntaxError-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (&SyntaxError-context obj)
    (unchecked-slot-ref obj 'context))
  (define (SyntaxError-context-set! obj val)
    (unchecked-slot-set! obj 'context val))
  (define (SyntaxError-context obj)
    (unchecked-slot-ref obj 'context))
  (define (&SyntaxError-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (&SyntaxError-phi obj)
    (unchecked-slot-ref obj 'phi))
  (define (SyntaxError-phi-set! obj val)
    (unchecked-slot-set! obj 'phi val))
  (define (SyntaxError-phi obj) (unchecked-slot-ref obj 'phi))
  (define (&SyntaxError-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val))
  (define (&SyntaxError-marks obj)
    (unchecked-slot-ref obj 'marks))
  (define (SyntaxError-marks-set! obj val)
    (unchecked-slot-set! obj 'marks val))
  (define (SyntaxError-marks obj)
    (unchecked-slot-ref obj 'marks)))

(begin
  (define SyntaxError::display-exception
    (lambda (self port)
      (define (location)
        (define (from-irritants)
          (let lp ([rest (slot-ref self 'irritants)])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-106} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-106})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-107} (car #{match-val dpuuv4a3mobea70icwo8nvdax-106})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-108} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-106})])
                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-107}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-108}])
                        (begin (or (__AST-source hd) (lp rest))))))
                  (begin #f)))))
        (define (from-context)
          (let lp ([rest (slot-ref self 'where)])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-109} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-109})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-110} (car #{match-val dpuuv4a3mobea70icwo8nvdax-109})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-111} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-109})])
                    (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-110}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-111}])
                        (begin
                          (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-112} hd])
                            (if (pair?
                                  #{match-val dpuuv4a3mobea70icwo8nvdax-112})
                                (let ([#{hd dpuuv4a3mobea70icwo8nvdax-113} (car #{match-val dpuuv4a3mobea70icwo8nvdax-112})]
                                      [#{tl dpuuv4a3mobea70icwo8nvdax-114} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-112})])
                                  (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-113}
                                           '\x40;)
                                      (if (pair?
                                            #{tl dpuuv4a3mobea70icwo8nvdax-114})
                                          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-115} (car #{tl dpuuv4a3mobea70icwo8nvdax-114})]
                                                [#{tl dpuuv4a3mobea70icwo8nvdax-116} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-114})])
                                            (let ([loc #{hd dpuuv4a3mobea70icwo8nvdax-115}])
                                              (if (null?
                                                    #{tl dpuuv4a3mobea70icwo8nvdax-116})
                                                  (begin
                                                    (or (__AST-source loc)
                                                        (lp rest)))
                                                  (begin (lp rest)))))
                                          (begin (lp rest)))
                                      (begin (lp rest))))
                                (begin (lp rest))))))))
                  (begin #f)))))
        (or (from-irritants) (from-context)))
      (parameterize ([current-output-port port])
        (newline)
        (display "*** ERROR IN ")
        (cond
          [(location) =>
           (lambda (loc) (\x23;\x23;display-locat loc #t port))]
          [else (display "?")])
        (newline)
        (begin
          (display "--- Syntax Error: ")
          (display (slot-ref self 'message))
          (newline))
        (cond
          [(slot-ref self 'where) =>
           (lambda (where)
             (begin (display "--- Context: ") (newline))
             (let lp ([rest where])
               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-117} rest])
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-117})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-118} (car #{match-val dpuuv4a3mobea70icwo8nvdax-117})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-119} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-117})])
                       (let ([hd #{hd dpuuv4a3mobea70icwo8nvdax-118}])
                         (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-119}])
                           (begin
                             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-120} hd])
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-120})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-121} (car #{match-val dpuuv4a3mobea70icwo8nvdax-120})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-122} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-120})])
                                     (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-121}
                                              '\x40;)
                                         (if (pair?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-122})
                                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-123} (car #{tl dpuuv4a3mobea70icwo8nvdax-122})]
                                                   [#{tl dpuuv4a3mobea70icwo8nvdax-124} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-122})])
                                               (let ([ctx #{hd dpuuv4a3mobea70icwo8nvdax-123}])
                                                 (if (null?
                                                       #{tl dpuuv4a3mobea70icwo8nvdax-124})
                                                     (begin
                                                       (cond
                                                         [(__AST-source
                                                            ctx) =>
                                                          (lambda (loc)
                                                            (display
                                                              " at ")
                                                            (\x23;\x23;display-locat
                                                              loc
                                                              #t
                                                              port)
                                                            (newline)
                                                            (lp rest))]
                                                         [(AST? ctx)
                                                          (display " at ")
                                                          (__pp-syntax ctx)
                                                          (lp rest)]
                                                         [else (lp rest)]))
                                                     (begin
                                                       (begin
                                                         (display " at ")
                                                         (display hd)
                                                         (newline))
                                                       (lp rest)))))
                                             (begin
                                               (begin
                                                 (display " at ")
                                                 (display hd)
                                                 (newline))
                                               (lp rest)))
                                         (begin
                                           (begin
                                             (display " at ")
                                             (display hd)
                                             (newline))
                                           (lp rest))))
                                   (begin
                                     (begin
                                       (display " at ")
                                       (display hd)
                                       (newline))
                                     (lp rest))))))))
                     (begin (void))))))])
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-125} (slot-ref
                                                            self
                                                            'irritants)])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-125})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-126} (car #{match-val dpuuv4a3mobea70icwo8nvdax-125})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-127} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-125})])
                (let ([stx #{hd dpuuv4a3mobea70icwo8nvdax-126}])
                  (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-127}])
                    (begin
                      (display "... form:   ")
                      (__pp-syntax stx)
                      (for-each
                        (lambda (detail)
                          (display "... detail: ")
                          (write (__AST->datum detail))
                          (cond
                            [(__AST-source detail) =>
                             (lambda (loc)
                               (display " at ")
                               (\x23;\x23;display-locat loc #t port))])
                          (newline))
                        rest)))))
              (begin (void))))
        (when (getenv "GERBIL_DEBUG" #f)
          (let ([cont (slot-ref self 'continuation)])
            (and cont
                 (begin
                   (display "--- continuation backtrace:")
                   (newline)
                   (display-continuation-backtrace cont))))))))
  (bind-method!
    SyntaxError::t
    'display-exception
    SyntaxError::display-exception))

(seal-class! SyntaxError::t)

(define (make-syntax-error message irritants where context
         marks phi)
  (SyntaxError 'message: message 'irritants: irritants 'where:
    where 'context: context 'marks: marks 'phi: phi))

(define syntax-error? SyntaxError?)

(define (__raise-syntax-error where message stx . details)
  (raise
    (make-syntax-error message (cons stx details) where #f #f
      #f)))

(begin
  (define AST::t
    (make-class-type 'gerbil\x23;AST::t 'AST (list object::t) '(e source)
      '((struct: . #t) (id: . gerbil\x23;AST::t) (name: . syntax))
      '#f))
  (define (make-AST . args)
    (let* ([type AST::t]
           [n (class-type-field-count type)]
           [obj (apply \x23;\x23;structure type (make-list n #f))])
      (let lp ([rest args] [i 1])
        (when (and (pair? rest) (<= i n))
          (\x23;\x23;structure-set! obj i (car rest))
          (lp (cdr rest) (+ i 1))))
      obj))
  (define (AST? obj)
    (\x23;\x23;structure-instance-of? obj 'gerbil\x23;AST::t))
  (define (AST-e obj) (unchecked-slot-ref obj 'e))
  (define (AST-source obj) (unchecked-slot-ref obj 'source))
  (define (AST-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (AST-source-set! obj val)
    (unchecked-slot-set! obj 'source val))
  (define (&AST-e obj) (unchecked-slot-ref obj 'e))
  (define (&AST-source obj) (unchecked-slot-ref obj 'source))
  (define (&AST-e-set! obj val)
    (unchecked-slot-set! obj 'e val))
  (define (&AST-source-set! obj val)
    (unchecked-slot-set! obj 'source val)))

(define (__AST-e stx) (if (AST? stx) (&AST-e stx) stx))

(define (__AST-source stx)
  (let lp ([src stx])
    (cond
      [(AST? src) (lp (&AST-source src))]
      [(\x23;\x23;locat? src) src]
      [else #f])))

(define (__AST e src-stx)
  (let ([src (__AST-source src-stx)])
    (if (or (AST? e) (not src)) e (AST e src))))

(define (__AST-eq? stx obj) (eq? (__AST-e stx) obj))

(define (__AST-pair? stx) (pair? (__AST-e stx)))

(define (__AST-null? stx) (null? (__AST-e stx)))

(define (__AST-datum? stx)
  (let ([e (__AST-e stx)])
    (or (number? e)
        (string? e)
        (char? e)
        (keyword? e)
        (boolean? e)
        (eq? e (%%void)))))

(define (__AST-id? stx) (symbol? (__AST-e stx)))

(define __AST-id-list?
  (case-lambda
    [(stx)
     (let* ([tail? __AST-null?])
       (let lp ([rest stx])
         (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-128} rest])
           (let ([#{fail dpuuv4a3mobea70icwo8nvdax-129} (lambda ()
                                                          (let ([#{fail dpuuv4a3mobea70icwo8nvdax-130} (lambda ()
                                                                                                         (__raise-syntax-error
                                                                                                           #f
                                                                                                           "Bad syntax; malformed ast clause"
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-128}))])
                                                            (let ([rest #{ast-val dpuuv4a3mobea70icwo8nvdax-128}])
                                                              (tail?
                                                                rest))))])
             (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-128})
                 (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-131} (__AST-e
                                                                 #{ast-val dpuuv4a3mobea70icwo8nvdax-128})]
                        [#{ehd dpuuv4a3mobea70icwo8nvdax-132} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-131})]
                        [#{etl dpuuv4a3mobea70icwo8nvdax-133} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-131})])
                   (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-132}])
                     (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-133}])
                       (and (__AST-id? hd) (lp rest)))))
                 (#{fail dpuuv4a3mobea70icwo8nvdax-129}))))))]
    [(stx tail?)
     (let lp ([rest stx])
       (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-128} rest])
         (let ([#{fail dpuuv4a3mobea70icwo8nvdax-129} (lambda ()
                                                        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-130} (lambda ()
                                                                                                       (__raise-syntax-error
                                                                                                         #f
                                                                                                         "Bad syntax; malformed ast clause"
                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-128}))])
                                                          (let ([rest #{ast-val dpuuv4a3mobea70icwo8nvdax-128}])
                                                            (tail?
                                                              rest))))])
           (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-128})
               (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-131} (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-128})]
                      [#{ehd dpuuv4a3mobea70icwo8nvdax-132} (\x23;\x23;car
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-131})]
                      [#{etl dpuuv4a3mobea70icwo8nvdax-133} (\x23;\x23;cdr
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-131})])
                 (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-132}])
                   (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-133}])
                     (and (__AST-id? hd) (lp rest)))))
               (#{fail dpuuv4a3mobea70icwo8nvdax-129})))))]))

(define (__AST-bind-list? stx)
  (__AST-id-list?
    stx
    (lambda (e) (or (__AST-null? e) (__AST-id? e)))))

(define __AST-list?
  (case-lambda
    [(stx)
     (let* ([tail? __AST-null?])
       (let lp ([rest stx])
         (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-134} rest])
           (let ([#{fail dpuuv4a3mobea70icwo8nvdax-135} (lambda ()
                                                          (let ([#{fail dpuuv4a3mobea70icwo8nvdax-136} (lambda ()
                                                                                                         (__raise-syntax-error
                                                                                                           #f
                                                                                                           "Bad syntax; malformed ast clause"
                                                                                                           #{ast-val dpuuv4a3mobea70icwo8nvdax-134}))])
                                                            (let ([rest #{ast-val dpuuv4a3mobea70icwo8nvdax-134}])
                                                              (tail?
                                                                rest))))])
             (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-134})
                 (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-137} (__AST-e
                                                                 #{ast-val dpuuv4a3mobea70icwo8nvdax-134})]
                        [#{ehd dpuuv4a3mobea70icwo8nvdax-138} (\x23;\x23;car
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-137})]
                        [#{etl dpuuv4a3mobea70icwo8nvdax-139} (\x23;\x23;cdr
                                                                #{etgt dpuuv4a3mobea70icwo8nvdax-137})])
                   (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-139}])
                     (lp rest)))
                 (#{fail dpuuv4a3mobea70icwo8nvdax-135}))))))]
    [(stx tail?)
     (let lp ([rest stx])
       (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-134} rest])
         (let ([#{fail dpuuv4a3mobea70icwo8nvdax-135} (lambda ()
                                                        (let ([#{fail dpuuv4a3mobea70icwo8nvdax-136} (lambda ()
                                                                                                       (__raise-syntax-error
                                                                                                         #f
                                                                                                         "Bad syntax; malformed ast clause"
                                                                                                         #{ast-val dpuuv4a3mobea70icwo8nvdax-134}))])
                                                          (let ([rest #{ast-val dpuuv4a3mobea70icwo8nvdax-134}])
                                                            (tail?
                                                              rest))))])
           (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-134})
               (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-137} (__AST-e
                                                               #{ast-val dpuuv4a3mobea70icwo8nvdax-134})]
                      [#{ehd dpuuv4a3mobea70icwo8nvdax-138} (\x23;\x23;car
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-137})]
                      [#{etl dpuuv4a3mobea70icwo8nvdax-139} (\x23;\x23;cdr
                                                              #{etgt dpuuv4a3mobea70icwo8nvdax-137})])
                 (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-139}])
                   (lp rest)))
               (#{fail dpuuv4a3mobea70icwo8nvdax-135})))))]))

(define (__AST->list stx)
  (let ([#{ast-val dpuuv4a3mobea70icwo8nvdax-140} stx])
    (let ([#{fail dpuuv4a3mobea70icwo8nvdax-141} (lambda ()
                                                   (let ([#{fail dpuuv4a3mobea70icwo8nvdax-142} (lambda ()
                                                                                                  (__raise-syntax-error
                                                                                                    #f
                                                                                                    "Bad syntax; malformed ast clause"
                                                                                                    #{ast-val dpuuv4a3mobea70icwo8nvdax-140}))])
                                                     (let ([rest #{ast-val dpuuv4a3mobea70icwo8nvdax-140}])
                                                       (__AST-e rest))))])
      (if (__AST-pair? #{ast-val dpuuv4a3mobea70icwo8nvdax-140})
          (let* ([#{etgt dpuuv4a3mobea70icwo8nvdax-143} (__AST-e
                                                          #{ast-val dpuuv4a3mobea70icwo8nvdax-140})]
                 [#{ehd dpuuv4a3mobea70icwo8nvdax-144} (\x23;\x23;car
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-143})]
                 [#{etl dpuuv4a3mobea70icwo8nvdax-145} (\x23;\x23;cdr
                                                         #{etgt dpuuv4a3mobea70icwo8nvdax-143})])
            (let ([hd #{ehd dpuuv4a3mobea70icwo8nvdax-144}])
              (let ([rest #{etl dpuuv4a3mobea70icwo8nvdax-145}])
                (cons hd (__AST->list rest)))))
          (#{fail dpuuv4a3mobea70icwo8nvdax-141})))))

(define (__AST->datum stx)
  (cond
    [(AST? stx) (__AST->datum (__AST-e stx))]
    [(pair? stx)
     (cons (__AST->datum (car stx)) (__AST->datum (cdr stx)))]
    [(vector? stx) (vector-map __AST->datum stx)]
    [(box? stx) (box (__AST->datum (unbox stx)))]
    [else stx]))

(define (get-readenv port)
  (\x23;\x23;make-readenv port (current-readtable)
    __wrap-syntax __unwrap-syntax #f '() #f))

(define read-syntax
  (case-lambda
    [()
     (let* ([in (current-input-port)])
       (let ([e (\x23;\x23;read-datum-or-eof (get-readenv in))])
         (if (eof-object? (__AST-e e)) (__AST-e e) e)))]
    [(in)
     (let ([e (\x23;\x23;read-datum-or-eof (get-readenv in))])
       (if (eof-object? (__AST-e e)) (__AST-e e) e))]))

(define (read-syntax-from-file path)
  (let ([r (\x23;\x23;read-all-as-a-begin-expr-from-path
             (gambit-path-normalize path)
             (current-readtable)
             __wrap-syntax
             __unwrap-syntax)])
    (if (vector? r)
        (cdr (__AST-e (vector-ref r 1)))
        (error 'gerbil (err-code->string r) path))))

(define (__wrap-syntax re e)
  (if (eof-object? e)
      e
      (make-AST e (\x23;\x23;readenv->locat re))))

(define (__unwrap-syntax re e) (__AST-e e))

(define (__pp-syntax stx) (pretty-print (__AST->datum stx)))

(define (__make-readtable)
  (let ([rt (\x23;\x23;make-standard-readtable)])
    (macro-readtable-write-extended-read-macros?-set! rt #t)
    (__readtable-bracket-keyword-set! rt '\x40;list)
    (__readtable-brace-keyword-set! rt '\x40;method)
    (\x23;\x23;readtable-char-sharp-handler-set!
      rt
      #\!
      __read-sharp-bang)
    rt))

(define (__readtable-bracket-keyword-set! rt kw)
  (macro-readtable-bracket-handler-set! rt kw))

(define (__readtable-brace-keyword-set! rt kw)
  (macro-readtable-brace-handler-set! rt kw))

(define (__read-sharp-bang re next start-pos)
  (if (eq? start-pos 0)
      (let* ([line (\x23;\x23;read-line
                     (macro-readenv-port re)
                     #\newline
                     #f
                     \x23;\x23;max-fixnum)])
        (let* ([script-line (substring
                              line
                              1
                              (string-length line))])
          (macro-readenv-script-line-set! re script-line)
          (\x23;\x23;script-marker)))
      (\x23;\x23;read-sharp-bang re next start-pos)))

(set! \x23;\x23;readtable-setup-for-language! void)

(define __*readtable* (__make-readtable))

(define source-location? \x23;\x23;locat?)

(define (source-location-path? obj)
  (and (source-location? obj)
       (string? (\x23;\x23;locat-container obj))))

(define (source-location-path obj)
  (and (\x23;\x23;locat? obj)
       (\x23;\x23;container->path
         (\x23;\x23;locat-container obj))))

