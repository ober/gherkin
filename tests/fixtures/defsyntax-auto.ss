;;; defsyntax-auto.ss -- Test fixture for auto-injection of syntax runtime
(export my-define-pair)

(defsyntax (my-define-pair stx)
  (syntax-case stx ()
    ((_ name v1 v2)
     (let ((g1 (stx-identifier #'name (syntax->datum #'name) "-first"))
           (g2 (stx-identifier #'name (syntax->datum #'name) "-second")))
       #`(begin
           (define #,g1 v1)
           (define #,g2 v2))))))
