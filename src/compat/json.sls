#!chezscheme
;;; json.sls -- Compat shim for Gerbil's :std/text/json
;;; JSON parsing and serialization using hash tables.

(library (compat json)
  (export
    read-json
    write-json
    string->json-object
    json-object->string
    trivial-class-to-repr
    trivial-class-from-repr)

  (import (chezscheme))

  ;; Forward references — these are provided by the runtime when
  ;; the compiler compiles a full program. For library-only use,
  ;; we provide minimal stubs.

  ;; This library is a stub — the actual JSON implementation is
  ;; typically compiled inline by the compiler or provided by
  ;; the full runtime. It exists so (compat json) can be imported.

  (define (read-json . rest)
    (let ((port (if (pair? rest) (car rest) (current-input-port))))
      (json-read port)))

  (define (write-json obj . rest)
    (let ((port (if (pair? rest) (car rest) (current-output-port))))
      (json-write obj port)))

  (define (string->json-object str)
    (let ((port (open-input-string str)))
      (json-read port)))

  (define (json-object->string obj)
    (let ((port (open-output-string)))
      (json-write obj port)
      (get-output-string port)))

  ;; Minimal JSON reader
  (define (json-read port)
    (skip-whitespace port)
    (let ((ch (peek-char port)))
      (cond
        ((eof-object? ch) ch)
        ((char=? ch #\{) (json-read-object port))
        ((char=? ch #\[) (json-read-array port))
        ((char=? ch #\") (json-read-string port))
        ((or (char=? ch #\-) (char-numeric? ch)) (json-read-number port))
        ((char=? ch #\t) (json-read-true port))
        ((char=? ch #\f) (json-read-false port))
        ((char=? ch #\n) (json-read-null port))
        (else (error 'read-json "unexpected character" ch)))))

  (define (skip-whitespace port)
    (let ((ch (peek-char port)))
      (when (and (not (eof-object? ch))
                 (memv ch '(#\space #\tab #\newline #\return)))
        (read-char port)
        (skip-whitespace port))))

  (define (json-read-object port)
    (read-char port) ;; consume {
    (skip-whitespace port)
    (let ((ht (make-hashtable string-hash string=?)))
      (unless (char=? (peek-char port) #\})
        (let lp ()
          (skip-whitespace port)
          (let ((key (json-read-string port)))
            (skip-whitespace port)
            (read-char port) ;; consume :
            (skip-whitespace port)
            (let ((val (json-read port)))
              (hashtable-set! ht key val)
              (skip-whitespace port)
              (when (char=? (peek-char port) #\,)
                (read-char port)
                (lp))))))
      (read-char port) ;; consume }
      ht))

  (define (json-read-array port)
    (read-char port) ;; consume [
    (skip-whitespace port)
    (if (char=? (peek-char port) #\])
      (begin (read-char port) '())
      (let lp ((result '()))
        (skip-whitespace port)
        (let ((val (json-read port)))
          (skip-whitespace port)
          (let ((ch (peek-char port)))
            (cond
              ((char=? ch #\,)
               (read-char port)
               (lp (cons val result)))
              (else
               (read-char port) ;; consume ]
               (reverse (cons val result)))))))))

  (define (json-read-string port)
    (read-char port) ;; consume opening "
    (let lp ((chars '()))
      (let ((ch (read-char port)))
        (cond
          ((char=? ch #\")
           (list->string (reverse chars)))
          ((char=? ch #\\)
           (let ((esc (read-char port)))
             (lp (cons (case esc
                         ((#\n) #\newline)
                         ((#\t) #\tab)
                         ((#\r) #\return)
                         ((#\") #\")
                         ((#\\) #\\)
                         ((#\/) #\/)
                         ((#\u) (json-read-unicode-escape port))
                         (else esc))
                       chars))))
          (else (lp (cons ch chars)))))))

  (define (json-read-unicode-escape port)
    (let* ((s (string (read-char port) (read-char port) (read-char port) (read-char port)))
           (n (string->number s 16)))
      (integer->char n)))

  (define (json-read-number port)
    (let lp ((chars '()))
      (let ((ch (peek-char port)))
        (if (and (not (eof-object? ch))
                 (or (char-numeric? ch) (memv ch '(#\. #\- #\+ #\e #\E))))
          (begin (read-char port) (lp (cons ch chars)))
          (let ((s (list->string (reverse chars))))
            (or (string->number s) 0))))))

  (define (json-read-true port)
    (read-char port) (read-char port) (read-char port) (read-char port)
    #t)

  (define (json-read-false port)
    (read-char port) (read-char port) (read-char port) (read-char port) (read-char port)
    #f)

  (define (json-read-null port)
    (read-char port) (read-char port) (read-char port) (read-char port)
    'null)

  ;; Minimal JSON writer
  (define (json-write obj port)
    (cond
      ((hashtable? obj)
       (display "{" port)
       (let ((keys (vector->list (hashtable-keys obj)))
             (first? #t))
         (for-each
           (lambda (key)
             (unless first? (display "," port))
             (set! first? #f)
             (json-write-string key port)
             (display ":" port)
             (json-write (hashtable-ref obj key #f) port))
           keys))
       (display "}" port))
      ((list? obj)
       (display "[" port)
       (let ((first? #t))
         (for-each
           (lambda (val)
             (unless first? (display "," port))
             (set! first? #f)
             (json-write val port))
           obj))
       (display "]" port))
      ((string? obj) (json-write-string obj port))
      ((number? obj) (display obj port))
      ((eq? obj #t) (display "true" port))
      ((eq? obj #f) (display "false" port))
      ((eq? obj 'null) (display "null" port))
      (else (json-write-string (format "~a" obj) port))))

  (define (json-write-string str port)
    (display "\"" port)
    (string-for-each
      (lambda (ch)
        (case ch
          ((#\") (display "\\\"" port))
          ((#\\) (display "\\\\" port))
          ((#\newline) (display "\\n" port))
          ((#\tab) (display "\\t" port))
          ((#\return) (display "\\r" port))
          (else
           (if (< (char->integer ch) 32)
             (fprintf port "\\u~4,'0x" (char->integer ch))
             (display ch port)))))
      str)
    (display "\"" port))

  ;; Stubs for class serialization
  (define (trivial-class-to-repr obj) obj)
  (define (trivial-class-from-repr repr) repr)

  ) ;; end library
