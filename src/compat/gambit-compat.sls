#!chezscheme
;;; gambit-compat.sls -- Gambit → Chez Scheme compatibility layer
;;;
;;; Maps Gambit's ## primitives to Chez equivalents.
;;; This is the foundation that all ported Gerbil code builds on.

(library (compat gambit-compat)
  (export
    ;; Special values
    void void?
    absent-obj absent-obj?
    unbound-obj unbound-obj?
    deleted-obj deleted-obj?
    unused-obj unused-obj?

    ;; Fixnum operations (## → Chez fx)
    |##fx+| |##fx-| |##fx*| |##fx/| |##fxmodulo| |##fxremainder|
    |##fx<| |##fx>| |##fx=| |##fx>=| |##fx<=|
    |##fxand| |##fxior| |##fxxor| |##fxnot|
    |##fxarithmetic-shift| |##fxarithmetic-shift-left| |##fxarithmetic-shift-right|
    |##fxbit-count| |##fxlength| |##fxbit-set?| |##fxfirst-bit-set|
    |##fxabs| |##fxmin| |##fxmax|
    |##fixnum?| |##max-fixnum| |##min-fixnum| |##fx+?| |##fx-?|

    ;; Flonum operations
    |##flonum?| |##fl+| |##fl-| |##fl*| |##fl/| |##fl<| |##fl>| |##fl=| |##fl>=| |##fl<=|
    |##flabs| |##flfloor| |##flceiling| |##flround| |##fltruncate|
    |##flsqrt| |##flexpt| |##fllog| |##flexp| |##flsin| |##flcos| |##fltan|
    |##flasin| |##flacos| |##flatan|
    |##fixnum->flonum| |##flonum->fixnum|

    ;; Pair/list operations
    |##car| |##cdr| |##set-car!| |##set-cdr!| |##cons|
    |##pair?| |##null?|
    |##list| |##length| |##append| |##reverse|

    ;; Vector operations
    |##vector-ref| |##vector-set!| |##vector-length|
    |##vector-cas!|
    |##make-vector| |##vector?| |##vector-copy| |##vector->list| |##list->vector|
    |##subvector|

    ;; String operations
    |##string-ref| |##string-set!| |##string-length|
    |##make-string| |##string?| |##string-copy| |##string-append|
    |##string->list| |##list->string| |##substring|
    |##string=?| |##string<?| |##string-ci=?|
    |##string->number| |##number->string|
    |##string->symbol| |##symbol->string|
    |##string->keyword| |##keyword->string|

    ;; Char operations
    |##char?| |##char=?| |##char<?| |##char->integer| |##integer->char|
    |##char-alphabetic?| |##char-numeric?| |##char-whitespace?|
    |##char-upcase| |##char-downcase|

    ;; Symbol/keyword operations
    |##symbol?| |##keyword?|
    |##gensym| |##uninterned-symbol?| |##make-uninterned-symbol|

    ;; Boolean / type predicates
    |##boolean?| |##not| |##eq?| |##eqv?| |##equal?|
    |##number?| |##complex?| |##real?| |##rational?| |##integer?|
    |##exact?| |##inexact?|
    |##procedure?| |##port?| |##eof-object?| |##char?|

    ;; Arithmetic (generic)
    |##+| |##-| |##*| |##/| |##<| |##>| |##=| |##>=| |##<=|
    |##quotient| |##remainder| |##modulo|
    |##abs| |##min| |##max| |##gcd| |##lcm|
    |##expt| |##sqrt| |##floor| |##ceiling| |##round| |##truncate|
    |##exact->inexact| |##inexact->exact|
    |##zero?| |##positive?| |##negative?| |##odd?| |##even?|
    |##bitwise-and| |##bitwise-ior| |##bitwise-xor| |##bitwise-not|
    |##arithmetic-shift| |##bit-count| |##integer-length| |##bit-set?|

    ;; I/O
    |##read-char| |##write-char| |##peek-char|
    |##read-u8| |##write-u8|
    |##newline| |##display| |##write| |##pretty-print|
    |##open-input-file| |##open-output-file|
    |##close-input-port| |##close-output-port|
    |##input-port?| |##output-port?|
    |##current-input-port| |##current-output-port| |##current-error-port|
    |##port-name| |##read-line|
    |##open-input-string| |##open-output-string| |##get-output-string|
    |##eof-object|

    ;; Byte vectors (u8vector → bytevector)
    |##u8vector?| |##make-u8vector| |##u8vector-ref| |##u8vector-set!|
    |##u8vector-length| |##u8vector->list| |##list->u8vector|
    |##u8vector-copy| |##u8vector-copy!|
    u8vector? make-u8vector u8vector-ref u8vector-set!
    u8vector-length u8vector u8vector-append
    u8vector->list list->u8vector
    u8vector-copy u8vector-copy!
    u8vector-shrink! subu8vector

    ;; Box
    |##box| |##unbox| |##set-box!|
    |##box?| make-box box box? unbox set-box!

    ;; Will (weak references)
    |##make-will| |##will?| |##will-testator| |##will-execute!|

    ;; Hash tables (Gambit table → Chez hashtable)
    make-table table? table-ref table-set! table-delete!
    table->list table-for-each table-length table-copy
    table-merge table-merge!

    ;; Evaluation
    |##eval| |##apply|

    ;; Misc
    |##values| |##call-with-values|
    |##void|
    |##raise| |##with-exception-catcher| |##with-exception-handler|
    |##current-exception-handler|
    |##make-parameter| |##parameterize|
    |##dynamic-wind|
    |##error| |##error-object?| |##error-object-message| |##error-object-irritants|
    |##continuation?| |##continuation-capture| |##continuation-graft|
    |##continuation-return|
    |##object->serial-number|
    |##identity|
    |##time| |##cpu-time| |##real-time|

    ;; Gambit GC
    |##gc|

    ;; Property lists
    |##putprop| |##getprop| |##remprop|

    ;; Gambit threading API → Chez threading
    thread-sleep! make-thread thread-start! thread-join!
    thread-yield!

    ;; SMP stubs (Chez doesn't have Gambit's SMP model)
    |##set-parallelism-level!| |##startup-parallelism!|
    |##current-vm-processor-count|

    ;; Process statistics
    |##process-statistics|

    ;; f64vector (Gambit's native float64 vectors)
    f64vector-ref f64vector-set! make-f64vector f64vector-length
    )

  (import (except (chezscheme)
            void                       ;; we define our own void
            box box? unbox set-box!    ;; we define our own box type
            ))

  ;;;; Special values
  ;;;; Gambit uses unique objects for void, absent, etc.
  ;;;; We use Chez records for identity-based uniqueness.

  (define-record-type special-value
    (fields name)
    (sealed #t)
    (opaque #t))

  (define void-obj (make-special-value 'void))
  (define absent (make-special-value 'absent))
  (define unbound (make-special-value 'unbound))
  (define deleted (make-special-value 'deleted))
  (define unused (make-special-value 'unused))

  (define (void) void-obj)
  (define (void? x) (eq? x void-obj))
  (define (absent-obj) absent)
  (define (absent-obj? x) (eq? x absent))
  (define (unbound-obj) unbound)
  (define (unbound-obj? x) (eq? x unbound))
  (define (deleted-obj) deleted)
  (define (deleted-obj? x) (eq? x deleted))
  (define (unused-obj) unused)
  (define (unused-obj? x) (eq? x unused))

  ;;;; Fixnum operations

  (define |##fx+| fx+)
  (define |##fx-| fx-)
  (define |##fx*| fx*)
  (define (|##fx/| a b) (fxdiv a b))
  (define |##fxmodulo| fxmod)
  (define |##fxremainder| fxremainder)
  (define |##fx<| fx<)
  (define |##fx>| fx>)
  (define |##fx=| fx=)
  (define |##fx>=| fx>=)
  (define |##fx<=| fx<=)
  (define |##fxand| fxlogand)
  (define |##fxior| fxlogior)
  (define |##fxxor| fxlogxor)
  (define |##fxnot| fxlognot)
  (define |##fxarithmetic-shift| fxarithmetic-shift)
  (define |##fxarithmetic-shift-left| fxarithmetic-shift-left)
  (define |##fxarithmetic-shift-right| fxarithmetic-shift-right)
  (define |##fxbit-count| fxbit-count)
  (define |##fxlength| fxlength)
  (define |##fxbit-set?| fxbit-set?)
  (define |##fxfirst-bit-set| fxfirst-bit-set)
  (define (|##fxabs| x) (if (fx< x 0) (fx- 0 x) x))
  (define |##fxmin| fxmin)
  (define |##fxmax| fxmax)
  (define |##fixnum?| fixnum?)
  (define (|##max-fixnum|) (greatest-fixnum))
  (define (|##min-fixnum|) (least-fixnum))

  ;; |##fx+?| and |##fx-?| return #f on overflow instead of raising an error
  (define (|##fx+?| a b)
    (let ([r (+ a b)])
      (if (fixnum? r) r #f)))
  (define (|##fx-?| a b)
    (let ([r (- a b)])
      (if (fixnum? r) r #f)))

  ;;;; Flonum operations

  (define |##flonum?| flonum?)
  (define |##fl+| fl+)
  (define |##fl-| fl-)
  (define |##fl*| fl*)
  (define |##fl/| fl/)
  (define |##fl<| fl<)
  (define |##fl>| fl>)
  (define |##fl=| fl=)
  (define |##fl>=| fl>=)
  (define |##fl<=| fl<=)
  (define |##flabs| flabs)
  (define |##flfloor| flfloor)
  (define |##flceiling| flceiling)
  (define |##flround| flround)
  (define |##fltruncate| fltruncate)
  (define |##flsqrt| flsqrt)
  (define (|##flexpt| a b) (flexpt a b))
  (define |##fllog| fllog)
  (define |##flexp| flexp)
  (define |##flsin| flsin)
  (define |##flcos| flcos)
  (define |##fltan| fltan)
  (define |##flasin| flasin)
  (define |##flacos| flacos)
  (define |##flatan| flatan)
  (define |##fixnum->flonum| fixnum->flonum)
  (define |##flonum->fixnum| flonum->fixnum)

  ;;;; Pair/list operations

  (define |##car| car)
  (define |##cdr| cdr)
  (define |##set-car!| set-car!)
  (define |##set-cdr!| set-cdr!)
  (define |##cons| cons)
  (define |##pair?| pair?)
  (define |##null?| null?)
  (define |##list| list)
  (define |##length| length)
  (define |##append| append)
  (define |##reverse| reverse)

  ;;;; Vector operations

  (define |##vector-ref| vector-ref)
  (define |##vector-set!| vector-set!)
  (define |##vector-length| vector-length)
  (define |##vector-cas!| vector-cas!)
  (define |##make-vector| make-vector)
  (define |##vector?| vector?)
  (define (|##vector-copy| v)
    (let* ([n (vector-length v)]
           [new (make-vector n)])
      (do ([i 0 (fx+ i 1)])
          ((fx= i n) new)
        (vector-set! new i (vector-ref v i)))))
  (define |##vector->list| vector->list)
  (define |##list->vector| list->vector)
  (define (|##subvector| v start end)
    (let* ([len (fx- end start)]
           [new (make-vector len)])
      (do ([i 0 (fx+ i 1)])
          ((fx= i len) new)
        (vector-set! new i (vector-ref v (fx+ start i))))))

  ;;;; String operations

  (define |##string-ref| string-ref)
  (define |##string-set!| string-set!)
  (define |##string-length| string-length)
  (define |##make-string| make-string)
  (define |##string?| string?)
  (define |##string-copy| string-copy)
  (define |##string-append| string-append)
  (define |##string->list| string->list)
  (define |##list->string| list->string)
  (define |##substring| substring)
  (define |##string=?| string=?)
  (define |##string<?| string<?)
  (define |##string-ci=?| string-ci=?)
  (define |##string->number| string->number)
  (define |##number->string| number->string)
  (define |##string->symbol| string->symbol)
  (define |##symbol->string| symbol->string)

  ;; Keywords: Gambit uses keyword objects; Chez doesn't have them natively.
  ;; We represent keywords as symbols with a trailing colon convention,
  ;; stored in a hashtable for identity.
  ;; This matches Gerbil's keyword representation.
  (define keyword-table (make-hashtable string-hash string=?))
  (define keyword-lock (make-mutex))

  (define-record-type keyword-object
    (fields name)
    (sealed #t))

  (define (|##keyword?| x)
    (keyword-object? x))

  (define (|##string->keyword| s)
    (mutex-acquire keyword-lock)
    (let ([existing (hashtable-ref keyword-table s #f)])
      (cond
        [existing
         (mutex-release keyword-lock)
         existing]
        [else
         (let ([kw (make-keyword-object s)])
           (hashtable-set! keyword-table s kw)
           (mutex-release keyword-lock)
           kw)])))

  (define (|##keyword->string| kw)
    (unless (keyword-object? kw)
      (error '|##keyword->string| "not a keyword" kw))
    (keyword-object-name kw))

  ;;;; Char operations

  (define |##char?| char?)
  (define |##char=?| char=?)
  (define |##char<?| char<?)
  (define |##char->integer| char->integer)
  (define |##integer->char| integer->char)
  (define |##char-alphabetic?| char-alphabetic?)
  (define |##char-numeric?| char-numeric?)
  (define |##char-whitespace?| char-whitespace?)
  (define |##char-upcase| char-upcase)
  (define |##char-downcase| char-downcase)

  ;;;; Symbol operations

  (define |##symbol?| symbol?)
  (define |##gensym| gensym)
  (define (|##uninterned-symbol?| s)
    (and (symbol? s) (gensym? s)))
  (define (|##make-uninterned-symbol| name)
    (gensym (if (symbol? name) (symbol->string name) name)))

  ;;;; Boolean / type predicates

  (define |##boolean?| boolean?)
  (define |##not| not)
  (define |##eq?| eq?)
  (define |##eqv?| eqv?)
  (define |##equal?| equal?)
  (define |##number?| number?)
  (define |##complex?| complex?)
  (define |##real?| real?)
  (define |##rational?| rational?)
  (define |##integer?| integer?)
  (define |##exact?| exact?)
  (define |##inexact?| inexact?)
  (define |##procedure?| procedure?)
  (define |##port?| port?)
  (define |##eof-object?| eof-object?)

  ;;;; Generic arithmetic

  (define |##+| +)
  (define |##-| -)
  (define |##*| *)
  (define |##/| /)
  (define |##<| <)
  (define |##>| >)
  (define |##=| =)
  (define |##>=| >=)
  (define |##<=| <=)
  (define |##quotient| quotient)
  (define |##remainder| remainder)
  (define |##modulo| modulo)
  (define |##abs| abs)
  (define |##min| min)
  (define |##max| max)
  (define |##gcd| gcd)
  (define |##lcm| lcm)
  (define |##expt| expt)
  (define |##sqrt| sqrt)
  (define |##floor| floor)
  (define |##ceiling| ceiling)
  (define |##round| round)
  (define |##truncate| truncate)
  (define |##exact->inexact| exact->inexact)
  (define |##inexact->exact| inexact->exact)
  (define |##zero?| zero?)
  (define |##positive?| positive?)
  (define |##negative?| negative?)
  (define |##odd?| odd?)
  (define |##even?| even?)
  (define |##bitwise-and| logand)
  (define |##bitwise-ior| logior)
  (define |##bitwise-xor| logxor)
  (define |##bitwise-not| lognot)
  (define |##arithmetic-shift| ash)
  (define |##bit-count| fxbit-count)
  (define |##integer-length| integer-length)
  (define |##bit-set?| fxbit-set?)

  ;;;; I/O

  (define |##read-char| read-char)
  (define |##write-char| write-char)
  (define |##peek-char| peek-char)
  (define |##read-u8| get-u8)
  (define |##write-u8| put-u8)
  (define |##newline| newline)
  (define |##display| display)
  (define |##write| write)
  (define |##pretty-print| pretty-print)
  (define |##open-input-file| open-input-file)
  (define |##open-output-file| open-output-file)
  (define |##close-input-port| close-input-port)
  (define |##close-output-port| close-output-port)
  (define |##input-port?| input-port?)
  (define |##output-port?| output-port?)
  (define |##current-input-port| current-input-port)
  (define |##current-output-port| current-output-port)
  (define |##current-error-port| current-error-port)
  (define (|##port-name| p)
    (cond
      [(input-port? p) (port-name p)]
      [(output-port? p) (port-name p)]
      [else "<unknown>"]))
  (define |##read-line|
    (case-lambda
      [() (get-line (current-input-port))]
      [(p) (get-line p)]))
  (define |##open-input-string| open-input-string)
  (define |##open-output-string| open-output-string)
  (define |##get-output-string| get-output-string)
  (define (|##eof-object|) (eof-object))

  ;;;; Byte vectors (u8vector → bytevector)
  ;;;; Gambit's u8vector is Chez's bytevector

  (define u8vector? bytevector?)
  (define |##u8vector?| bytevector?)
  (define make-u8vector make-bytevector)
  (define |##make-u8vector| make-bytevector)
  (define u8vector-ref bytevector-u8-ref)
  (define |##u8vector-ref| bytevector-u8-ref)
  (define u8vector-set! bytevector-u8-set!)
  (define |##u8vector-set!| bytevector-u8-set!)
  (define u8vector-length bytevector-length)
  (define |##u8vector-length| bytevector-length)

  (define (u8vector . args)
    (let ([bv (make-bytevector (length args))])
      (let loop ([i 0] [args args])
        (if (null? args) bv
            (begin
              (bytevector-u8-set! bv i (car args))
              (loop (fx+ i 1) (cdr args)))))))

  (define (u8vector-append . bvs)
    (let* ([total (apply + (map bytevector-length bvs))]
           [result (make-bytevector total)])
      (let loop ([bvs bvs] [offset 0])
        (if (null? bvs) result
            (let ([bv (car bvs)]
                  [len (bytevector-length (car bvs))])
              (bytevector-copy! bv 0 result offset len)
              (loop (cdr bvs) (+ offset len)))))))

  (define (u8vector->list bv)
    (let loop ([i (fx- (bytevector-length bv) 1)] [acc '()])
      (if (fx< i 0) acc
          (loop (fx- i 1) (cons (bytevector-u8-ref bv i) acc)))))
  (define |##u8vector->list| u8vector->list)

  (define (list->u8vector lst)
    (let ([bv (make-bytevector (length lst))])
      (let loop ([i 0] [lst lst])
        (if (null? lst) bv
            (begin
              (bytevector-u8-set! bv i (car lst))
              (loop (fx+ i 1) (cdr lst)))))))
  (define |##list->u8vector| list->u8vector)

  (define (u8vector-copy bv . args)
    (if (null? args)
        (bytevector-copy bv)
        (let ([start (car args)]
              [end (if (null? (cdr args))
                       (bytevector-length bv)
                       (cadr args))])
          (let ([result (make-bytevector (- end start))])
            (bytevector-copy! bv start result 0 (- end start))
            result))))
  (define |##u8vector-copy| u8vector-copy)

  (define (u8vector-copy! src src-start dst dst-start count)
    (bytevector-copy! src src-start dst dst-start count))
  (define |##u8vector-copy!| u8vector-copy!)

  (define (u8vector-shrink! bv len)
    ;; Chez doesn't support in-place shrink; return a copy
    (let ([result (make-bytevector len)])
      (bytevector-copy! bv 0 result 0 len)
      result))

  (define (subu8vector bv start end)
    (let ([result (make-bytevector (- end start))])
      (bytevector-copy! bv start result 0 (- end start))
      result))

  ;;;; Box

  (define-record-type box-type
    (fields (mutable value))
    (sealed #t))

  (define (make-box val) (make-box-type val))
  (define (box val) (make-box-type val))
  (define |##box| box)
  (define (box? x) (box-type? x))
  (define |##box?| box?)
  (define (unbox b) (box-type-value b))
  (define |##unbox| unbox)
  (define (set-box! b v) (box-type-value-set! b v))
  (define |##set-box!| set-box!)

  ;;;; Will (weak references / guardians)

  (define (|##make-will| obj action)
    (let ([g (make-guardian)])
      (g obj)
      (cons g action)))

  (define (|##will?| x)
    (and (pair? x) (guardian? (car x))))

  (define (|##will-testator| w)
    ;; Try to get the object from the guardian
    (let ([obj ((car w))])
      (if obj obj
          (error '|##will-testator| "will already executed"))))

  (define (|##will-execute!| w)
    (let ([obj ((car w))])
      (when obj
        ((cdr w) obj))))

  ;;;; Hash tables (Gambit table → Chez hashtable)

  ;; Gambit's make-table uses keyword arguments. We support the common cases.
  (define make-table
    (case-lambda
      [() (make-hashtable equal-hash equal?)]
      [(args)
       ;; Support keyword-style arguments passed as a list
       (make-hashtable equal-hash equal?)]))

  (define (table? x) (hashtable? x))

  (define table-ref
    (case-lambda
      [(t k) (hashtable-ref t k (void))]
      [(t k default) (hashtable-ref t k default)]))

  (define (table-set! t k v) (hashtable-set! t k v))
  (define (table-delete! t k) (hashtable-delete! t k))

  (define (table->list t)
    (let-values ([(keys vals) (hashtable-entries t)])
      (let loop ([i (fx- (vector-length keys) 1)] [acc '()])
        (if (fx< i 0) acc
            (loop (fx- i 1)
                  (cons (cons (vector-ref keys i) (vector-ref vals i)) acc))))))

  (define (table-for-each proc t)
    (let-values ([(keys vals) (hashtable-entries t)])
      (do ([i 0 (fx+ i 1)])
          ((fx= i (vector-length keys)))
        (proc (vector-ref keys i) (vector-ref vals i)))))

  (define (table-length t) (hashtable-size t))

  (define (table-copy t)
    (hashtable-copy t #t))

  (define (table-merge t1 t2)
    (let ([result (hashtable-copy t1 #t)])
      (table-for-each (lambda (k v) (hashtable-set! result k v)) t2)
      result))

  (define (table-merge! t1 t2)
    (table-for-each (lambda (k v) (hashtable-set! t1 k v)) t2)
    t1)

  ;;;; Evaluation

  (define |##eval| eval)
  (define |##apply| apply)

  ;;;; Misc

  (define |##values| values)
  (define |##call-with-values| call-with-values)
  (define (|##void|) void-obj)

  (define |##raise| raise)

  (define (|##with-exception-catcher| handler thunk)
    (guard (exn [#t (handler exn)])
      (thunk)))

  (define |##with-exception-handler| with-exception-handler)

  (define |##current-exception-handler|
    (make-parameter
      (lambda (exn)
        (display "unhandled exception: " (current-error-port))
        (display exn (current-error-port))
        (newline (current-error-port)))))

  (define |##make-parameter| make-parameter)

  (define-syntax |##parameterize|
    (syntax-rules ()
      [(_ ((p v) ...) body ...)
       (parameterize ((p v) ...) body ...)]))

  (define |##dynamic-wind| dynamic-wind)

  (define |##error| error)

  (define (|##error-object?| x)
    (or (condition? x)
        (error? x)
        (message-condition? x)))

  (define (|##error-object-message| x)
    (if (message-condition? x)
        (condition-message x)
        (format "~a" x)))

  (define (|##error-object-irritants| x)
    (if (irritants-condition? x)
        (condition-irritants x)
        '()))

  ;;;; Continuations

  (define (|##continuation?| x)
    (procedure? x))

  (define (|##continuation-capture| proc)
    (call/cc (lambda (k) (proc k))))

  (define (|##continuation-graft| k thunk)
    ;; Chez doesn't have graft directly; we abort to k with thunk's result
    (k (thunk)))

  (define (|##continuation-return| k . vals)
    (apply k vals))

  ;; ##structure-copy is provided by (compat types)
  ;; Re-exported here for convenience but not defined.

  ;;;; Serial numbers (Chez doesn't have this; use eq-hashtable)
  (define serial-number-table (make-eq-hashtable))
  (define serial-number-counter 0)
  (define serial-number-lock (make-mutex))

  (define (|##object->serial-number| obj)
    (let ([existing (hashtable-ref serial-number-table obj #f)])
      (or existing
          (begin
            (mutex-acquire serial-number-lock)
            (let ([existing (hashtable-ref serial-number-table obj #f)])
              (cond
                [existing
                 (mutex-release serial-number-lock)
                 existing]
                [else
                 (set! serial-number-counter (+ serial-number-counter 1))
                 (let ([n serial-number-counter])
                   (hashtable-set! serial-number-table obj n)
                   (mutex-release serial-number-lock)
                   n)]))))))

  ;;;; Identity
  (define (|##identity| x) x)

  ;;;; Timing
  (define (|##time| thunk)
    (time (thunk)))

  (define (|##cpu-time|)
    (let ([t (current-time 'time-thread)])
      (+ (* (time-second t) 1000)
         (quotient (time-nanosecond t) 1000000))))

  (define (|##real-time|)
    (let ([t (current-time 'time-monotonic)])
      (+ (* (time-second t) 1000)
         (quotient (time-nanosecond t) 1000000))))

  ;;;; GC
  (define (|##gc|) (collect))

  ;;;; Property lists
  (define |##putprop| putprop)
  (define |##getprop| getprop)
  (define |##remprop| remprop)

  ;;;; Gambit threading API → Chez threading
  ;;;; Gambit uses SRFI-18 style: make-thread, thread-start!, thread-join!
  ;;;; Chez uses: fork-thread, mutex, condition
  ;;;; We bridge the gap with a simple thread record.

  (define-record-type gambit-thread
    (fields thunk (mutable result) (mutable done?) mutex condvar)
    (protocol
      (lambda (new)
        (lambda (thunk)
          (new thunk (void) #f (make-mutex) (make-condition))))))

  (define (make-thread thunk . name)
    (make-gambit-thread thunk))

  (define (thread-start! t)
    (fork-thread
      (lambda ()
        (let ((result (guard (e [#t e])
                        ((gambit-thread-thunk t)))))
          (gambit-thread-result-set! t result)
          (mutex-acquire (gambit-thread-mutex t))
          (gambit-thread-done?-set! t #t)
          (condition-broadcast (gambit-thread-condvar t))
          (mutex-release (gambit-thread-mutex t)))))
    t)

  (define (thread-join! t)
    (mutex-acquire (gambit-thread-mutex t))
    (let lp ()
      (unless (gambit-thread-done? t)
        (condition-wait (gambit-thread-condvar t) (gambit-thread-mutex t))
        (lp)))
    (mutex-release (gambit-thread-mutex t))
    (gambit-thread-result t))

  (define (thread-sleep! seconds)
    ;; Chez's sleep takes a time duration
    (let ((ns (inexact->exact (round (* seconds 1000000000)))))
      (sleep (make-time 'time-duration ns 0))))

  (define (thread-yield!)
    ;; No direct equivalent; sleep briefly
    (sleep (make-time 'time-duration 0 0)))

  ;;;; SMP stubs
  ;;;; Chez Scheme doesn't have Gambit's SMP threading model.
  ;;;; These are no-ops so that Gambit SMP code compiles and runs single-threaded.
  (define (|##set-parallelism-level!| n) (void))
  (define (|##startup-parallelism!|) (void))
  (define (|##current-vm-processor-count|) 1)

  ;;;; Process statistics
  ;;;; Gambit's ##process-statistics returns an f64vector:
  ;;;;   [0] = user time, [1] = system time, [2] = real/wall time,
  ;;;;   [3] = gc user time, [4] = gc system time, [5] = gc real time,
  ;;;;   [6] = nb GCs, [7] = bytes allocated, ...
  ;;;; We approximate using Chez's (current-time).
  (define (|##process-statistics|)
    (let* ((wall (current-time 'time-monotonic))
           (cpu  (current-time 'time-thread))
           (wall-secs (+ (time-second wall)
                         (/ (time-nanosecond wall) 1000000000.0)))
           (cpu-secs  (+ (time-second cpu)
                         (/ (time-nanosecond cpu) 1000000000.0))))
      ;; Return as a regular vector; f64vector-ref works on it via our stubs
      (let ((v (make-f64vector 8 0.0)))
        (f64vector-set! v 0 cpu-secs)     ;; user time
        (f64vector-set! v 1 0.0)          ;; system time
        (f64vector-set! v 2 wall-secs)    ;; wall time
        v)))

  ;;;; f64vector (Gambit's native float64 vectors)
  ;;;; Implemented on top of Chez bytevectors with IEEE double precision.
  (define (make-f64vector n . rest)
    (let ((bv (make-bytevector (* n 8) 0)))
      (when (pair? rest)
        (let ((fill (car rest)))
          (do ((i 0 (fx+ i 1)))
              ((fx= i n))
            (bytevector-ieee-double-native-set! bv (* i 8) (inexact fill)))))
      bv))

  (define (f64vector-ref bv i)
    (bytevector-ieee-double-native-ref bv (* i 8)))

  (define (f64vector-set! bv i val)
    (bytevector-ieee-double-native-set! bv (* i 8) (inexact val)))

  (define (f64vector-length bv)
    (fx/ (bytevector-length bv) 8))

  ) ;; end library
