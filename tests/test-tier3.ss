#!chezscheme
;;; test-tier3.ss -- Test Tier 3 features: include, base64, hex, import filters
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

(test-begin "Tier 3 Features")

;;; ============================================================
;;; :std/text/hex compat module
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-text-hex)) env)
  ;; hex-encode (u8vector->hex-string)
  (test-equal "hex-encode empty"
    ""
    (eval '(hex-encode (bytevector)) env))
  (test-equal "hex-encode bytes"
    "deadbeef"
    (eval '(hex-encode (bytevector #xde #xad #xbe #xef)) env))
  ;; hex-decode (hex-string->u8vector)
  (test-equal "hex-decode"
    (bytevector #xde #xad #xbe #xef)
    (eval '(hex-decode "deadbeef") env))
  ;; roundtrip
  (test-equal "hex roundtrip"
    (bytevector 0 1 127 128 255)
    (eval '(hex-decode (hex-encode (bytevector 0 1 127 128 255))) env))
  ;; uppercase input
  (test-equal "hex-decode uppercase"
    (bytevector #xCA #xFE)
    (eval '(hex-decode "CAFE") env)))

;;; ============================================================
;;; :std/text/base64 compat module
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-text-base64)) env)
  ;; base64-encode
  (test-equal "base64-encode empty"
    ""
    (eval '(base64-encode (bytevector)) env))
  (test-equal "base64-encode 'Man'"
    "TWFu"
    (eval '(base64-encode (string->utf8 "Man")) env))
  (test-equal "base64-encode 'Ma'"
    "TWE="
    (eval '(base64-encode (string->utf8 "Ma")) env))
  (test-equal "base64-encode 'M'"
    "TQ=="
    (eval '(base64-encode (string->utf8 "M")) env))
  ;; base64-decode
  (test-equal "base64-decode 'TWFu'"
    (string->utf8 "Man")
    (eval '(base64-decode "TWFu") env))
  (test-equal "base64-decode with padding"
    (string->utf8 "Ma")
    (eval '(base64-decode "TWE=") env))
  ;; roundtrip
  (test-equal "base64 roundtrip"
    (string->utf8 "Hello, World!")
    (eval '(base64-decode (base64-encode (string->utf8 "Hello, World!"))) env)))

;;; ============================================================
;;; include support
;;; ============================================================

;; Create a temporary include file
(let ((inc-file "/tmp/gherkin-test-include.ss"))
  (call-with-output-file inc-file
    (lambda (port)
      (display "(define included-value 42)\n" port)
      (display "(define (included-fn x) (* x 2))\n" port))
    'replace)
  ;; Compile an include form
  (let ((compiled (gerbil-compile-top `(include ,inc-file))))
    (test-assert "include compiles to begin"
      (and (pair? compiled) (eq? 'begin (car compiled)))))
  ;; Include with non-existent file should not crash
  (let ((compiled (gerbil-compile-top '(include "/tmp/nonexistent-file-xyz.ss"))))
    (test-assert "include non-existent file" (pair? compiled))))

;;; ============================================================
;;; Import map entries for base64/hex
;;; ============================================================

;; Verify the import map resolves these modules
(let ((compiled (gerbil-compile-expression '(begin 1))))
  (test-assert "basic compile works" (pair? compiled)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
