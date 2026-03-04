;;; defsyntax-test.ss -- Test fixture for for-syntax import handling
(import
  (for-syntax :std/stxutil))

(export make-getter)

(defsyntax (make-getter stx)
  (syntax-case stx ()
    ((_ name field)
     (let ((getter-name (stx-identifier #'name (syntax->datum #'name) "-" (syntax->datum #'field))))
       #`(define (#,getter-name obj)
           (slot-ref obj '#,#'field))))))
