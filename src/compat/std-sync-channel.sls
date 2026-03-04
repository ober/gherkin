#!chezscheme
;;; std-sync-channel.sls -- Compat shim for Gerbil's :std/misc/channel
;;; Buffered message channels using Chez mutex + condition variable

(library (compat std-sync-channel)
  (export
    make-channel channel?
    channel-put channel-try-put
    channel-get channel-try-get
    channel-close channel-closed?)

  (import (chezscheme))

  ;; Simple queue using two lists
  (define-record-type queue
    (fields (mutable front) (mutable back) (mutable length))
    (protocol
      (lambda (new) (lambda () (new '() '() 0)))))

  (define (queue-empty? q)
    (= (queue-length q) 0))

  (define (queue-enqueue! q val)
    (queue-back-set! q (cons val (queue-back q)))
    (queue-length-set! q (+ (queue-length q) 1)))

  (define (queue-dequeue! q)
    (when (null? (queue-front q))
      (queue-front-set! q (reverse (queue-back q)))
      (queue-back-set! q '()))
    (let ((val (car (queue-front q))))
      (queue-front-set! q (cdr (queue-front q)))
      (queue-length-set! q (- (queue-length q) 1))
      val))

  (define-record-type channel
    (fields (immutable q)
            (immutable mx)
            (immutable cv)
            (immutable limit)
            (mutable closed?))
    (protocol
      (lambda (new)
        (case-lambda
          (() (new (make-queue) (make-mutex) (make-condition) #f #f))
          ((limit) (new (make-queue) (make-mutex) (make-condition) limit #f))))))

  (define (channel-put ch val)
    (mutex-acquire (channel-mx ch))
    (when (channel-closed? ch)
      (mutex-release (channel-mx ch))
      (error 'channel-put "channel is closed"))
    ;; Wait for space if bounded
    (let lp ()
      (when (and (channel-limit ch)
                 (>= (queue-length (channel-q ch)) (channel-limit ch)))
        (condition-wait (channel-cv ch) (channel-mx ch))
        (when (channel-closed? ch)
          (mutex-release (channel-mx ch))
          (error 'channel-put "channel is closed"))
        (lp)))
    (queue-enqueue! (channel-q ch) val)
    (condition-broadcast (channel-cv ch))
    (mutex-release (channel-mx ch))
    #t)

  (define (channel-try-put ch val)
    (mutex-acquire (channel-mx ch))
    (cond
      ((channel-closed? ch)
       (mutex-release (channel-mx ch))
       (error 'channel-try-put "channel is closed"))
      ((and (channel-limit ch)
            (>= (queue-length (channel-q ch)) (channel-limit ch)))
       (mutex-release (channel-mx ch))
       #f)
      (else
       (queue-enqueue! (channel-q ch) val)
       (condition-broadcast (channel-cv ch))
       (mutex-release (channel-mx ch))
       #t)))

  (define (channel-get ch . args)
    (let ((default (if (pair? args) (car args) #f)))
      (mutex-acquire (channel-mx ch))
      (let lp ()
        (cond
          ((not (queue-empty? (channel-q ch)))
           (let ((val (queue-dequeue! (channel-q ch))))
             (condition-broadcast (channel-cv ch))
             (mutex-release (channel-mx ch))
             val))
          ((channel-closed? ch)
           (mutex-release (channel-mx ch))
           (eof-object))
          (else
           (condition-wait (channel-cv ch) (channel-mx ch))
           (lp))))))

  (define (channel-try-get ch . args)
    (let ((default (if (pair? args) (car args) #f)))
      (mutex-acquire (channel-mx ch))
      (cond
        ((not (queue-empty? (channel-q ch)))
         (let ((val (queue-dequeue! (channel-q ch))))
           (condition-broadcast (channel-cv ch))
           (mutex-release (channel-mx ch))
           val))
        ((channel-closed? ch)
         (mutex-release (channel-mx ch))
         (eof-object))
        (else
         (mutex-release (channel-mx ch))
         default))))

  (define (channel-close ch)
    (with-mutex (channel-mx ch)
      (channel-closed?-set! ch #t)
      (condition-broadcast (channel-cv ch))))

  ) ;; end library
