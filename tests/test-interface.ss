#!chezscheme
;;; test-interface.ss -- Test interface compilation
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
  (compiler compile)
  (boot gherkin)
  (tests test-helpers))

(test-begin "Interface Compilation")

;;; ============================================================
;;; Basic interface compilation
;;; ============================================================

;; Simple interface with one method
(let ((compiled (gerbil-compile-top
                  '(interface Drawable
                     (draw ctx)))))
  (test-assert "interface compiles to begin"
    (and (pair? compiled) (eq? 'begin (car compiled))))
  ;; Check it generates the predicate
  (test-assert "interface generates Drawable?"
    (let lp ((forms (cdr compiled)))
      (and (pair? forms)
           (or (and (pair? (car forms))
                    (eq? (car (car forms)) 'define)
                    (pair? (cadr (car forms)))
                    (eq? (caadr (car forms)) 'Drawable?))
               (lp (cdr forms))))))
  ;; Check it generates method dispatcher
  (test-assert "interface generates Drawable-draw"
    (let lp ((forms (cdr compiled)))
      (and (pair? forms)
           (or (and (pair? (car forms))
                    (eq? (car (car forms)) 'define)
                    (pair? (cadr (car forms)))
                    (eq? (caadr (car forms)) 'Drawable-draw))
               (lp (cdr forms)))))))

;; Interface with multiple methods
(let ((compiled (gerbil-compile-top
                  '(interface Renderable
                     (render buf area)
                     (measure)))))
  (test-assert "interface multiple methods"
    (and (pair? compiled) (eq? 'begin (car compiled))))
  ;; Should have Renderable-render and Renderable-measure
  (let ((names (map (lambda (f)
                      (if (and (pair? f) (eq? (car f) 'define) (pair? (cadr f)))
                        (caadr f)
                        #f))
                    (cdr compiled))))
    (test-assert "has Renderable-render"
      (memq 'Renderable-render names))
    (test-assert "has Renderable-measure"
      (memq 'Renderable-measure names))))

;; Interface with type annotations (should be stripped)
(let ((compiled (gerbil-compile-top
                  '(interface Mux
                     (put-handler! (host :? :string) (path : :string) (handler : :procedure))
                     (get-handler (host :? :string) (path : :string))
                     => :t))))
  (test-assert "interface with annotations compiles"
    (and (pair? compiled) (eq? 'begin (car compiled))))
  ;; Should strip type annotations from method args
  (let ((names (map (lambda (f)
                      (if (and (pair? f) (eq? (car f) 'define) (pair? (cadr f)))
                        (caadr f)
                        #f))
                    (cdr compiled))))
    (test-assert "has Mux-put-handler!"
      (memq 'Mux-put-handler! names))
    (test-assert "has Mux-get-handler"
      (memq 'Mux-get-handler names))))

;; Interface with inheritance
(let ((compiled (gerbil-compile-top
                  '(interface (Child Parent)
                     (child-method x)))))
  (test-assert "interface with parent compiles"
    (and (pair? compiled) (eq? 'begin (car compiled)))))

;;; ============================================================
;;; Integration test: interface + defmethod + call
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  ;; Set up the runtime environment
  (eval '(import
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
           (compiler compile)
           (boot gherkin))
        env)

  ;; Define a struct
  (for-each (lambda (form) (eval form env))
    (let ((compiled (gerbil-compile-top
                      '(defstruct Widget (name width height)))))
      (if (eq? (car compiled) 'begin) (cdr compiled) (list compiled))))

  ;; Define a method on Widget
  (eval (gerbil-compile-top
          '(defmethod (render (self Widget) ctx)
             (string-append "rendering " (Widget-name self))))
        env)

  ;; Compile interface
  (for-each (lambda (form) (eval form env))
    (let ((compiled (gerbil-compile-top '(interface Drawable (draw ctx)))))
      (if (eq? (car compiled) 'begin) (cdr compiled) (list compiled))))

  ;; Define draw method on Widget that delegates to render
  (eval (gerbil-compile-top
          '(defmethod (draw (self Widget) ctx)
             (string-append "drawing:" (Widget-name self))))
        env)

  ;; Create widget and test interface dispatch
  (eval '(define w (make-Widget "btn" 100 50)) env)

  ;; Test direct method call
  (test-equal "interface dispatch via call-method"
    "drawing:btn"
    (eval '(call-method w 'draw "canvas") env))

  ;; Test interface dispatcher function
  (test-equal "interface dispatcher function"
    "drawing:btn"
    (eval '(Drawable-draw w "canvas") env)))

;;; ============================================================
;;; interface-out in exports
;;; ============================================================

;; Test that interface-out expands to the right names
(let ((compiled (gerbil-compile-top
                  '(interface Sizable
                     (get-size)
                     (set-size! w h)))))
  ;; Collect all defined names
  (let ((all-names '()))
    (for-each (lambda (f)
                (when (and (pair? f) (eq? (car f) 'define) (pair? (cadr f)))
                  (set! all-names (cons (caadr f) all-names))))
              (if (eq? (car compiled) 'begin) (cdr compiled) (list compiled)))
    (test-assert "interface-out would export make-Sizable"
      (memq 'make-Sizable all-names))
    (test-assert "interface-out would export Sizable?"
      (memq 'Sizable? all-names))
    (test-assert "interface-out would export Sizable-get-size"
      (memq 'Sizable-get-size all-names))
    (test-assert "interface-out would export Sizable-set-size!"
      (memq 'Sizable-set-size! all-names))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
