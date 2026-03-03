#!chezscheme
;;; test-types.ss -- Tests for types.sls (Gerbil type system on Chez)
(import (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name) (compat types) (compat gambit-compat) (tests test-helpers))

(test-begin "Gerbil Type System on Chez Records")

;;;; Basic structure creation
(let ([s (|##structure| #f 'a 'b 'c)])
  (test-assert "|##structure?|" (|##structure?| s))
  (test-assert "not structure for non-struct" (not (|##structure?| 42)))
  (test-assert "not structure for vector" (not (|##structure?| '#(1 2 3))))
  (test-equal "|##structure-ref| idx 1" 'a (|##structure-ref| s 1 #f 'f0))
  (test-equal "|##structure-ref| idx 2" 'b (|##structure-ref| s 2 #f 'f1))
  (test-equal "|##structure-ref| idx 3" 'c (|##structure-ref| s 3 #f 'f2))
  (test-equal "|##structure-length|" 4 (|##structure-length| s)))

;;;; Structure mutation
(let ([s (|##structure| #f 'x 'y)])
  (|##structure-set!| s 'new-x 1 #f 'f0)
  (test-equal "|##structure-set!|" 'new-x (|##structure-ref| s 1 #f 'f0)))

;;;; Structure type tag
(let ([s (|##structure| 'my-type 'a 'b)])
  (test-equal "|##structure-type|" 'my-type (|##structure-type| s))
  (|##structure-type-set!| s 'new-type)
  (test-equal "|##structure-type-set!|" 'new-type (|##structure-type| s)))

;;;; Unchecked access
(let ([s (|##structure| #f 10 20 30)])
  (test-equal "unchecked-ref" 20 (|##unchecked-structure-ref| s 2 #f 'f1))
  (|##unchecked-structure-set!| s 99 2 #f 'f1)
  (test-equal "unchecked-set!" 99 (|##unchecked-structure-ref| s 2 #f 'f1)))

;;;; Type descriptor creation
(let ([td (make-type-descriptor
            #f          ;; type (metaclass)
            'point      ;; id
            'point      ;; name
            (fxlogior type-flag-extensible type-flag-concrete)  ;; flags
            #f          ;; super
            '#()        ;; fields
            '()         ;; precedence-list
            '#(#f)      ;; slot-vector
            #f          ;; slot-table
            '()         ;; properties
            #f          ;; constructor
            #f)])       ;; methods
  (test-assert "type-descriptor?" (type-descriptor? td))
  (test-equal "type-descriptor-id" 'point (type-descriptor-id td))
  (test-equal "type-descriptor-name" 'point (type-descriptor-name td))
  (test-equal "type-descriptor-flags"
    (fxlogior type-flag-extensible type-flag-concrete)
    (type-descriptor-flags td))
  (test-assert "type-descriptor-super is #f" (not (type-descriptor-super td)))
  (test-equal "|##type-id|" 'point (|##type-id| td))
  (test-equal "|##type-name|" 'point (|##type-name| td)))

;;;; MOP Bootstrap simulation
;;;; This simulates Gerbil's t::t / class::t / object::t bootstrap

;; Step 1: Create t::t with #f type (will be set to class::t later)
(define t::t
  (make-type-descriptor
    #f                   ;; type: UNSET
    't                   ;; id
    't                   ;; name
    (fxlogior type-flag-extensible type-flag-id class-type-flag-system)
    #f                   ;; super: none
    '#()                 ;; fields: none
    '()                  ;; precedence-list: empty
    '#(#f)               ;; slot-vector
    #f                   ;; slot-table: none
    '((direct-slots:) (system: . #t))
    #f                   ;; constructor
    #f))                 ;; methods

(test-assert "t::t created" (type-descriptor? t::t))
(test-equal "t::t id" 't (type-descriptor-id t::t))
(test-assert "t::t has no metaclass yet" (not (|##structure-type| t::t)))

;; Step 2: Create class::t
(define class::t
  (make-type-descriptor
    #f                   ;; type: UNSET (will be self)
    'class               ;; id
    'class               ;; name
    (fxlogior type-flag-extensible type-flag-concrete type-flag-id
              class-type-flag-struct)
    #f                   ;; super (would be |##type-type| in real Gerbil)
    '#()                 ;; fields
    (list t::t)          ;; precedence-list
    '#(#f id name flags super fields
       precedence-list slot-vector slot-table
       properties constructor methods)
    #f                   ;; slot-table
    '((struct: . #t))
    #f                   ;; constructor
    #f))                 ;; methods

;; Self-reference: class::t's metaclass is itself
(|##structure-type-set!| class::t class::t)
(test-equal "class::t self-reference" class::t (|##structure-type| class::t))

;; Step 3: Wire up t::t
(|##structure-type-set!| t::t class::t)
(test-equal "t::t metaclass is class::t" class::t (|##structure-type| t::t))

;; Step 4: Create object::t
(define object::t
  (make-type-descriptor
    class::t             ;; type: class::t
    'object              ;; id
    'object              ;; name
    (fxlogior type-flag-extensible type-flag-id class-type-flag-system)
    #f                   ;; super
    '#()                 ;; fields
    (list t::t)          ;; precedence-list
    '#(#f)               ;; slot-vector
    #f                   ;; slot-table
    '((direct-slots:) (system: . #t))
    #f                   ;; constructor
    #f))                 ;; methods

(test-equal "object::t metaclass" class::t (|##structure-type| object::t))
(test-equal "object::t id" 'object (type-descriptor-id object::t))

;;;; Instance-of checks
;; Create a "point" type with parent object::t
(define point::t
  (make-type-descriptor
    class::t
    'point
    'point
    (fxlogior type-flag-extensible type-flag-concrete)
    object::t            ;; super is object::t
    '#()
    (list object::t t::t)
    '#(#f x y)
    #f
    '()
    #f
    #f))

;; Create an instance of point
(define p (|##structure| point::t 10 20))

(test-assert "instance is structure" (|##structure?| p))
(test-equal "instance type" point::t (|##structure-type| p))
(test-assert "instance-of? point" (|##structure-instance-of?| p 'point))
(test-assert "instance-of? object (parent)" (|##structure-instance-of?| p 'object))
(test-assert "not instance-of? class" (not (|##structure-instance-of?| p 'class)))
(test-assert "direct-instance-of? point" (|##structure-direct-instance-of?| p 'point))
(test-assert "not direct-instance-of? object" (not (|##structure-direct-instance-of?| p 'object)))

;; Access point fields
(test-equal "point x" 10 (|##structure-ref| p 1 point::t 'x))
(test-equal "point y" 20 (|##structure-ref| p 2 point::t 'y))
(|##structure-set!| p 30 1 point::t 'x)
(test-equal "point x after set" 30 (|##structure-ref| p 1 point::t 'x))

;;;; Type descriptor mutation
(set-type-descriptor-constructor! point::t 'make-point)
(test-equal "set constructor" 'make-point (type-descriptor-constructor point::t))

(set-type-descriptor-properties! point::t '((transparent: . #t)))
(test-equal "set properties" '((transparent: . #t)) (type-descriptor-properties point::t))

;;;; Structure copy
(let* ([orig (|##structure| point::t 100 200)]
       [copy (|##structure-copy| orig)])
  (test-assert "copy is structure" (|##structure?| copy))
  (test-equal "copy field 1" 100 (|##structure-ref| copy 1 point::t 'x))
  (test-equal "copy field 2" 200 (|##structure-ref| copy 2 point::t 'y))
  (|##structure-set!| copy 999 1 point::t 'x)
  (test-equal "copy is independent" 100 (|##structure-ref| orig 1 point::t 'x)))

;;;; Flag constants
(test-equal "type-flag-opaque" 1 type-flag-opaque)
(test-equal "type-flag-extensible" 2 type-flag-extensible)
(test-equal "type-flag-concrete" 8 type-flag-concrete)
(test-equal "class-type-flag-struct" 1024 class-type-flag-struct)
(test-equal "class-type-flag-system" 8192 class-type-flag-system)

(test-end)
(let-values ([(p f) (test-stats)])
  (exit (if (> f 0) 1 0)))
