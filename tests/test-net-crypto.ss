#!chezscheme
;;; test-net-crypto.ss -- Test HTTP request and crypto digest compat modules
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

(test-begin "Net & Crypto")

;;; ============================================================
;;; :std/crypto/digest
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-crypto-digest)) env)

  ;; MD5 of empty string
  (test-equal "md5 empty"
    "d41d8cd98f00b204e9800998ecf8427e"
    (eval '(md5 "") env))

  ;; SHA256 of "hello"
  (test-equal "sha256 hello"
    "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824"
    (eval '(sha256 "hello") env))

  ;; SHA1 of "abc"
  (test-equal "sha1 abc"
    "a9993e364706816aba3e25717850c26c9cd0d89d"
    (eval '(sha1 "abc") env))

  ;; digest->hex-string is identity
  (test-equal "digest->hex-string"
    "abc123"
    (eval '(digest->hex-string "abc123") env))

  ;; digest->u8vector
  (test-equal "digest->u8vector"
    (bytevector #xab #xc1 #x23)
    (eval '(digest->u8vector "abc123") env)))

;;; ============================================================
;;; :std/net/request
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-net-request)) env)

  ;; Test that request objects work
  (test-assert "request record created"
    (eval '(request? (http-get "http://httpbin.org/get")) env))

  ;; Test request-status on a known endpoint
  (test-equal "http-get status 200"
    200
    (eval '(let ((req (http-get "http://httpbin.org/get")))
             (request-status req))
          env))

  ;; Test response text
  (test-assert "http-get response text"
    (eval '(let ((req (http-get "http://httpbin.org/get")))
             (let ((text (request-text req)))
               (and (string? text) (> (string-length text) 0))))
          env)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
