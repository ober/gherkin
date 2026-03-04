#!chezscheme
;;; test-sync.ss -- Test sync primitives: completion and channel
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

(test-begin "Sync Primitives")

;;; ============================================================
;;; Completion
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-sync-completion)) env)
  ;; Basic creation
  (test-assert "completion created"
    (eval '(completion? (make-completion)) env))
  ;; Not ready initially
  (test-assert "completion not ready"
    (not (eval '(completion-ready? (make-completion)) env)))
  ;; Post and wait
  (test-equal "completion post+wait"
    42
    (eval '(let ((c (make-completion)))
             (completion-post! c 42)
             (completion-wait! c))
          env))
  ;; Error posting
  (test-assert "completion error+wait catches"
    (eval '(guard (exn [#t #t])
             (let ((c (make-completion)))
               (completion-error! c (make-message-condition "boom"))
               (completion-wait! c)
               #f))
          env))
  ;; Double post raises error
  (test-assert "completion double-post error"
    (eval '(guard (exn [#t #t])
             (let ((c (make-completion)))
               (completion-post! c 1)
               (completion-post! c 2)
               #f))
          env))
  ;; Cross-thread completion
  (test-equal "completion cross-thread"
    99
    (eval '(let ((c (make-completion)))
             (fork-thread (lambda () (completion-post! c 99)))
             (completion-wait! c))
          env)))

;;; ============================================================
;;; Channel
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-sync-channel)) env)
  ;; Basic creation
  (test-assert "channel created"
    (eval '(channel? (make-channel)) env))
  ;; Put and get
  (test-equal "channel put+get"
    42
    (eval '(let ((ch (make-channel)))
             (channel-put ch 42)
             (channel-get ch))
          env))
  ;; FIFO ordering
  (test-equal "channel FIFO order"
    '(1 2 3)
    (eval '(let ((ch (make-channel)))
             (channel-put ch 1)
             (channel-put ch 2)
             (channel-put ch 3)
             (list (channel-get ch) (channel-get ch) (channel-get ch)))
          env))
  ;; Try-put and try-get
  (test-equal "channel try-get empty"
    #f
    (eval '(let ((ch (make-channel)))
             (channel-try-get ch))
          env))
  (test-equal "channel try-get with value"
    10
    (eval '(let ((ch (make-channel)))
             (channel-put ch 10)
             (channel-try-get ch))
          env))
  ;; Bounded channel - try-put when full
  (test-assert "channel bounded try-put full"
    (not (eval '(let ((ch (make-channel 2)))
                  (channel-put ch 1)
                  (channel-put ch 2)
                  (channel-try-put ch 3))  ;; should return #f (full)
               env)))
  ;; Close channel
  (test-assert "channel close"
    (eval '(let ((ch (make-channel)))
             (channel-close ch)
             (channel-closed? ch))
          env))
  ;; Get from closed empty channel returns eof
  (test-assert "channel closed get eof"
    (eval '(let ((ch (make-channel)))
             (channel-close ch)
             (eof-object? (channel-get ch)))
          env))
  ;; Cross-thread channel
  (test-equal "channel cross-thread"
    "hello"
    (eval '(let ((ch (make-channel)))
             (fork-thread (lambda () (channel-put ch "hello")))
             (channel-get ch))
          env)))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
