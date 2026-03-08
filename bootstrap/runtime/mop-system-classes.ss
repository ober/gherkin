(defsystem-class immediate::t immediate ())

(defsystem-class char::t char (immediate::t))

(defsystem-class boolean::t boolean (immediate::t))

(defsystem-class atom::t atom (immediate::t))

(defsystem-class void::t void (atom::t))

(defsystem-class eof::t eof (atom::t))

(defsystem-class true::t true (boolean::t atom::t))

(defsystem-class false::t false (boolean::t atom::t))

(defsystem-class special::t special (atom::t))

(defsystem-class number::t number ())

(defsystem-class real::t real (number::t))

(defsystem-class integer::t integer (real::t))

(defsystem-class fixnum::t fixnum (integer::t immediate::t))

(defsystem-class bignum::t bignum (integer::t))

(defsystem-class ratnum::t ratnum (real::t))

(defsystem-class flonum::t flonum (real::t))

(defsystem-class cpxnum::t cpxnum (number::t))

(defsystem-class symbolic::t symbolic ())

(defsystem-class symbol::t symbol (symbolic::t))

(defsystem-class keyword::t keyword (symbolic::t))

(defsystem-class list::t list ())

(defsystem-class pair::t pair (list::t))

(defsystem-class null::t null (list::t atom::t))

(defsystem-class sequence::t sequence ())

(defsystem-class vector::t vector (sequence::t))

(defsystem-class string::t string (sequence::t))

(defsystem-class hvector::t hvector (sequence::t))

(defsystem-class u8vector::t u8vector (hvector::t))

(defsystem-class s8vector::t s8vector (hvector::t))

(defsystem-class u16vector::t u16vector (hvector::t))

(defsystem-class s16vector::t s16vector (hvector::t))

(defsystem-class u32vector::t u32vector (hvector::t))

(defsystem-class s32vector::t s32vector (hvector::t))

(defsystem-class u64vector::t u64vector (hvector::t))

(defsystem-class s64vector::t s64vector (hvector::t))

(defsystem-class f32vector::t f32vector (hvector::t))

(defsystem-class f64vector::t f64vector (hvector::t))

(defsystem-class values::t values ())

(defsystem-class box::t box ())

(defsystem-class frame::t frame ())

(defsystem-class continuation::t continuation ())

(defsystem-class promise::t promise ())

(defsystem-class weak::t weak ())

(defsystem-class foreign::t foreign ())

(defsystem-class procedure::t procedure ())

(defsystem-class return::t return ())

(defshadow-class time::t () (macro-type-time))

(defshadow-class thread::t () (macro-type-thread))

(defshadow-class thread-group::t () (macro-type-tgroup))

(defshadow-class mutex::t () (macro-type-mutex))

(defshadow-class condvar::t () (macro-type-condvar))

(defshadow-class port::t () (macro-type-port))

(defshadow-class
  object-port::t
  (port::t)
  (macro-type-object-port))

(defshadow-class
  character-port::t
  (object-port::t)
  (macro-type-character-port))

(defshadow-class
  byte-port::t
  (character-port::t)
  (macro-type-byte-port))

(defshadow-class
  device-port::t
  (byte-port::t)
  (macro-type-device-port))

(defshadow-class
  vector-port::t
  (object-port::t)
  (macro-type-vector-port))

(defshadow-class
  string-port::t
  (character-port::t)
  (macro-type-string-port))

(defshadow-class
  u8vector-port::t
  (byte-port::t)
  (macro-type-u8vector-port))

(defshadow-class
  raw-device-port::t
  (port::t)
  (macro-type-raw-device-port))

(defshadow-class
  tcp-server-port::t
  (object-port::t)
  (macro-type-tcp-server-port))

(defshadow-class
  udp-port::t
  (object-port::t)
  (macro-type-udp-port))

(defshadow-class
  directory-port::t
  (object-port::t)
  (macro-type-directory-port))

(defshadow-class
  event-queue-port::t
  (object-port::t)
  (macro-type-event-queue-port))

(defshadow-class table::t () (macro-type-table))

(defshadow-class readenv::t () (macro-type-readenv))

(defshadow-class writeenv::t () (macro-type-writeenv))

(defshadow-class readtable::t () (macro-type-readtable))

(defshadow-class processor::t () (macro-type-processor))

(defshadow-class vm::t () (macro-type-vm))

(defshadow-class file-info::t () (macro-type-file-info))

(defshadow-class socket-info::t () (macro-type-socket-info))

(defshadow-class
  address-info::t
  ()
  (macro-type-address-info))

(define-syntax defpred
  (lambda (stx)
    (syntax-case stx (:-)
      [(_ (id obj) :- type body ...)
       (with-syntax ([klass::t (resolve-type->type-descriptor
                                 stx
                                 #'type)])
         #'(def id
                (begin-annotation
                  (\x40;predicate klass::t)
                  (lambda (obj) body ...))))])))

(define (atom? obj)
  (and (immediate? obj)
       (not (char? obj))
       (not (fixnum? obj))))

(define (special? obj)
  (and (fx= (\x23;\x23;type obj) 2)
       (not (char? obj))
       (not (null? obj))
       (not (boolean? obj))
       (not (void? obj))
       (not (eof-object? obj))))

(define (sequence? obj)
  (or (vector? obj) (string? obj) (hvector? obj)))

(define (hvector? obj)
  (or (u8vector? obj)
      (s8vector? obj)
      (u16vector? obj)
      (s16vector? obj)
      (u32vector? obj)
      (s32vector? obj)
      (u64vector? obj)
      (s64vector? obj)
      (f32vector? obj)
      (f64vector? obj)))

(define (weak? obj)
  (and (\x23;\x23;subtyped? obj)
       (eq? (\x23;\x23;subtype obj) (macro-subtype-weak))))

(define (object-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-object-port))))

(define (character-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-character-port))))

(define (device-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-device-port))))

(define (vector-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-vector-port))))

(define (string-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-string-port))))

(define (u8vector-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-u8vector-port))))

(define (raw-device-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-raw-device-port))))

(define (tcp-server-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-tcp-server-port))))

(define (udp-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-udp-port))))

(define (directory-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-directory-port))))

(define (event-queue-port? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-event-queue-port))))

(define (readenv? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-readenv))))

(define (writeenv? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-writeenv))))

(define (vm? obj)
  (\x23;\x23;structure-instance-of?
    obj
    (\x23;\x23;type-id (macro-type-vm))))

