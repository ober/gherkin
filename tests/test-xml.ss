#!chezscheme
;;; test-xml.ss -- Test XML/SXML compat module
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

(test-begin "XML/SXML")

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-xml)) env)

  ;; SXML accessors
  (test-equal "sxml-e"
    'div
    (eval '(sxml-e '(div (@ (class "foo")) "hello")) env))

  (test-equal "sxml-attributes"
    '((class "foo") (id "bar"))
    (eval '(sxml-attributes '(div (@ (class "foo") (id "bar")) "hi")) env))

  (test-equal "sxml-attribute-e"
    "foo"
    (eval '(sxml-attribute-e '(div (@ (class "foo")) "hi") 'class) env))

  (test-equal "sxml-attribute-e missing"
    #f
    (eval '(sxml-attribute-e '(div (@ (class "foo"))) 'id) env))

  (test-equal "sxml-children"
    '("hello" (span "world"))
    (eval '(sxml-children '(div (@ (class "x")) "hello" (span "world"))) env))

  (test-equal "sxml-children no attrs"
    '("hello")
    (eval '(sxml-children '(div "hello")) env))

  ;; write-xml basic element
  (test-equal "write-xml simple"
    "<div>hello</div>"
    (eval '(let ((p (open-output-string)))
             (write-xml '(div "hello") p)
             (get-output-string p))
          env))

  ;; write-xml with attributes
  (test-equal "write-xml with attrs"
    "<div class=\"foo\">text</div>"
    (eval '(let ((p (open-output-string)))
             (write-xml '(div (@ (class "foo")) "text") p)
             (get-output-string p))
          env))

  ;; write-xml nested
  (test-equal "write-xml nested"
    "<ul><li>a</li><li>b</li></ul>"
    (eval '(let ((p (open-output-string)))
             (write-xml '(ul (li "a") (li "b")) p)
             (get-output-string p))
          env))

  ;; write-xml escaping
  (test-equal "write-xml escaping"
    "<p>a &lt; b &amp; c &gt; d</p>"
    (eval '(let ((p (open-output-string)))
             (write-xml '(p "a < b & c > d") p)
             (get-output-string p))
          env))

  ;; write-xml attribute escaping
  (test-equal "write-xml attr escaping"
    "<a href=\"x&amp;y\">link</a>"
    (eval '(let ((p (open-output-string)))
             (write-xml '(a (@ (href "x&y")) "link") p)
             (get-output-string p))
          env))

  ;; write-xml void tag
  (test-equal "write-xml void tag"
    "<br />"
    (eval '(let ((p (open-output-string)))
             (write-xml '(br) p)
             (get-output-string p))
          env))

  ;; write-xml comment
  (test-equal "write-xml comment"
    "<!-- hello -->"
    (eval '(let ((p (open-output-string)))
             (write-xml '(*comment* "hello") p)
             (get-output-string p))
          env))

  ;; SVG-like structure (the main use case)
  (test-assert "write-xml SVG-like"
    (eval '(let ((p (open-output-string)))
             (write-xml
               '(svg (@ (xmlns "http://www.w3.org/2000/svg")
                        (width "100") (height "100"))
                  (circle (@ (cx "50") (cy "50") (r "40")
                             (fill "red"))))
               p)
             (let ((result (get-output-string p)))
               (and (string? result)
                    (> (string-length result) 0)
                    ;; Check it starts and ends correctly
                    (char=? (string-ref result 0) #\<))))
          env)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
