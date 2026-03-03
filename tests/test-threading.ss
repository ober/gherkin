#!chezscheme
;;; test-threading.ss -- Tests for threading.sls
(import (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name) (compat threading) (tests test-helpers))

(test-begin "Threading (Gambit API on Chez)")

;;;; Basic thread creation and execution
(let* ([result #f]
       [t (make-thread (lambda () (set! result 42)))])
  (test-assert "make-thread" (thread? t))
  (test-equal "thread-name default" 'anonymous (thread-name t))
  (thread-start! t)
  (thread-join! t)
  (test-equal "thread executed" 42 result))

;; Named thread
(let ([t (make-thread (lambda () 'ok) 'worker)])
  (test-equal "thread-name" 'worker (thread-name t)))

;; Thread return value via join
(let ([t (make-thread (lambda () (+ 1 2 3)))])
  (thread-start! t)
  (test-equal "thread-join! result" 6 (thread-join! t)))

;; Thread specific
(let ([t (make-thread (lambda () 'ok))])
  (thread-specific-set! t 'my-data)
  (test-equal "thread-specific" 'my-data (thread-specific t)))

;; current-thread
(test-assert "current-thread returns thread" (thread? (current-thread)))

;;;; Mutex operations
(let ([m (make-mutex-gambit 'test-mutex)])
  (test-assert "mutex?" (mutex? m))
  (test-equal "mutex-name" 'test-mutex (mutex-name m))
  (mutex-lock! m)
  (mutex-unlock! m)
  (test-assert "lock/unlock cycle" #t))

;; Mutex specific
(let ([m (make-mutex-gambit)])
  (mutex-specific-set! m 'data)
  (test-equal "mutex-specific" 'data (mutex-specific m)))

;; Mutex protects shared state
(let ([m (make-mutex-gambit)]
      [counter 0]
      [n 100])
  (let ([threads
         (map (lambda (i)
                (make-thread
                  (lambda ()
                    (do ([j 0 (+ j 1)])
                        ((= j n))
                      (mutex-lock! m)
                      (set! counter (+ counter 1))
                      (mutex-unlock! m)))))
              (iota 4))])
    (for-each thread-start! threads)
    (for-each thread-join! threads)
    (test-equal "mutex protects counter" (* 4 n) counter)))

;;;; Condition variables
(let ([cv (make-condition-variable 'test-cv)])
  (test-assert "condition-variable?" (condition-variable? cv))
  (condition-variable-specific-set! cv 'cv-data)
  (test-equal "condition-variable-specific" 'cv-data
              (condition-variable-specific cv)))

;; Producer/consumer with condition variable
(let ([m (make-mutex-gambit)]
      [cv (make-condition-variable)]
      [data #f]
      [ready #f])
  (let ([consumer (make-thread
                    (lambda ()
                      (mutex-lock! m)
                      (let loop ()
                        (unless ready
                          (mutex-unlock! m cv)
                          (mutex-lock! m)
                          (loop)))
                      (let ([result data])
                        (mutex-unlock! m)
                        result)))]
        [producer (make-thread
                    (lambda ()
                      (sleep (make-time 'time-duration 10000000 0)) ;; 10ms
                      (mutex-lock! m)
                      (set! data 'hello)
                      (set! ready #t)
                      (condition-variable-signal! cv)
                      (mutex-unlock! m)))])
    (thread-start! consumer)
    (thread-start! producer)
    (test-equal "producer/consumer" 'hello (thread-join! consumer))
    (thread-join! producer)))

;;;; Thread mailbox
(let ([t (current-thread)])
  ;; Send to self
  (thread-send t 'msg1)
  (thread-send t 'msg2)
  (test-equal "thread-receive 1" 'msg1 (thread-receive))
  (test-equal "thread-receive 2" 'msg2 (thread-receive)))

;; Cross-thread mailbox
(let* ([receiver (current-thread)]
       [sender (make-thread
                 (lambda ()
                   (thread-send receiver 'from-sender)))])
  (thread-start! sender)
  (thread-join! sender)
  (test-equal "cross-thread mailbox" 'from-sender (thread-receive)))

;;;; Thread exception propagation
(let ([t (make-thread (lambda () (error 'test "thread error")))])
  (thread-start! t)
  (test-error "thread exception via join" (thread-join! t)))

;;;; Thread yield (just verify it doesn't crash)
(test-assert "thread-yield!" (begin (thread-yield!) #t))

;;;; Thread sleep
(let ([start (current-time)])
  (thread-sleep! 0.01)  ;; 10ms
  (test-assert "thread-sleep!" #t))

(test-end)
(let-values ([(p f) (test-stats)])
  (exit (if (> f 0) 1 0)))
