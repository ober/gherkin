#!chezscheme
;;; std-net-httpd.sls -- Compat shim for Gerbil's :std/net/httpd
;;; Delegates to chez-httpd (native threaded HTTP server) when available,
;;; falls back to minimal stub implementation.

(library (compat std-net-httpd)
  (export
    start-http-server! stop-http-server!
    http-register-handler
    http-request-method http-request-url http-request-path
    http-request-params http-request-headers http-request-body
    http-response-write)

  (import (chezscheme))

  ;; Try to load chez-httpd at init time
  (define *use-chez-httpd* #f)
  (define chez-httpd-start #f)
  (define chez-httpd-stop #f)
  (define chez-httpd-route #f)
  (define chez-http-respond #f)
  (define chez-http-req-method #f)
  (define chez-http-req-path #f)
  (define chez-http-req-headers #f)
  (define chez-http-req-body #f)

  (define dummy-init
    (guard (e [#t #f])
      (eval '(import (chez-httpd)))
      (set! *use-chez-httpd* #t)
      (set! chez-httpd-start (eval 'httpd-start))
      (set! chez-httpd-stop (eval 'httpd-stop))
      (set! chez-httpd-route (eval 'httpd-route))
      (set! chez-http-respond (eval 'http-respond))
      (set! chez-http-req-method (eval 'http-req-method))
      (set! chez-http-req-path (eval 'http-req-path))
      (set! chez-http-req-headers (eval 'http-req-headers))
      (set! chez-http-req-body (eval 'http-req-body))
      #t))

  ;; --- Request record (fallback) ---
  (define-record-type http-request
    (fields method url path params headers (mutable body-data))
    (protocol
      (lambda (new)
        (lambda (method url path params headers)
          (new method url path params headers #f)))))

  (define (http-request-body req)
    (if *use-chez-httpd*
      (chez-http-req-body req)
      (http-request-body-data req)))

  ;; --- Response record (fallback) ---
  (define-record-type http-response
    (fields port)
    (protocol
      (lambda (new) (lambda (port) (new port)))))

  ;; --- Server state (fallback) ---
  (define *server-handlers* '())
  (define *server-running* #f)
  (define *server-handle* #f)
  (define *server-port* 8080)

  (define (http-register-handler server path handler . rest)
    (if *use-chez-httpd*
      ;; Register with chez-httpd router, wrapping handler to bridge APIs
      (chez-httpd-route path
        (lambda (req writer)
          (let ((wrapped-req req)
                (wrapped-res writer))
            (handler wrapped-req wrapped-res))))
      (set! *server-handlers*
        (cons (cons path handler) *server-handlers*))))

  ;; --- HTTP parsing (fallback) ---

  (define (parse-request port)
    (let ((line (get-line port)))
      (if (eof-object? line) #f
        (let* ((parts (string-split-space (string-trim-right line)))
               (method (if (pair? parts) (string->symbol (car parts)) 'GET))
               (url (if (> (length parts) 1) (cadr parts) "/"))
               (path-params (split-path-params url))
               (path (car path-params))
               (params (cdr path-params))
               (headers (read-headers port)))
          (make-http-request method url path params headers)))))

  (define (split-path-params url)
    (let ((qpos (string-index url #\?)))
      (if qpos
        (cons (substring url 0 qpos)
              (substring url (+ qpos 1) (string-length url)))
        (cons url #f))))

  (define (read-headers port)
    (let lp ((headers '()))
      (let ((line (get-line port)))
        (if (or (eof-object? line)
                (string=? (string-trim-right line) ""))
          (reverse headers)
          (let ((colon (string-index line #\:)))
            (if colon
              (lp (cons (cons (substring line 0 colon)
                              (string-trim
                                (substring line (+ colon 1)
                                           (string-length
                                             (string-trim-right line)))))
                        headers))
              (lp headers)))))))

  ;; --- Response writing ---

  (define (http-response-write res status headers body)
    (if *use-chez-httpd*
      ;; Delegate to chez-httpd writer
      (chez-http-respond res status
        (if headers
          (map (lambda (h) (cons (car h) (cdr h))) headers)
          '())
        body)
      ;; Fallback: write to port
      (let ((port (http-response-port res)))
        (format port "HTTP/1.1 ~a ~a\r\n" status (status-text status))
        (when headers
          (for-each (lambda (h)
                      (format port "~a: ~a\r\n" (car h) (cdr h)))
                    headers))
        (let ((body-bytes (cond
                            ((string? body) (string->utf8 body))
                            ((bytevector? body) body)
                            (else (bytevector)))))
          (format port "Content-Length: ~a\r\n" (bytevector-length body-bytes))
          (format port "\r\n")
          (flush-output-port port)
          (let ((bp (transcoded-port-binary-port port)))
            (put-bytevector bp body-bytes)
            (flush-output-port bp))))))

  (define (transcoded-port-binary-port tp)
    tp)

  (define (status-text code)
    (case code
      ((200) "OK")
      ((201) "Created")
      ((204) "No Content")
      ((301) "Moved Permanently")
      ((302) "Found")
      ((400) "Bad Request")
      ((401) "Unauthorized")
      ((403) "Forbidden")
      ((404) "Not Found")
      ((405) "Method Not Allowed")
      ((500) "Internal Server Error")
      (else "Unknown")))

  ;; --- Server ---

  (define (start-http-server! . args)
    (let ((port 8080))
      (let lp ((rest args))
        (cond
          ((null? rest) #f)
          ((string? (car rest))
           (let ((colon (string-index (car rest) #\:)))
             (when colon
               (set! port (or (string->number
                                (substring (car rest) (+ colon 1)
                                           (string-length (car rest))))
                              port))))
           (lp (cdr rest)))
          ((number? (car rest))
           (set! port (car rest))
           (lp (cdr rest)))
          ((and (symbol? (car rest)) (pair? (cdr rest)))
           (lp (cddr rest)))
          (else (lp (cdr rest)))))
      (set! *server-running* #t)
      (set! *server-port* port)
      (if *use-chez-httpd*
        (begin
          (set! *server-handle* (chez-httpd-start port))
          *server-handle*)
        (list 'http-server port))))

  (define (find-handler path)
    (let lp ((handlers *server-handlers*))
      (cond
        ((null? handlers) #f)
        ((string=? (caar handlers) path) (cdar handlers))
        ((and (> (string-length (caar handlers)) 0)
              (char=? (string-ref (caar handlers)
                                  (- (string-length (caar handlers)) 1))
                      #\*)
              (string-prefix? (substring (caar handlers) 0
                                          (- (string-length (caar handlers)) 1))
                              path))
         (cdar handlers))
        (else (lp (cdr handlers))))))

  (define (string-prefix? prefix str)
    (and (<= (string-length prefix) (string-length str))
         (string=? prefix (substring str 0 (string-length prefix)))))

  (define (stop-http-server! . args)
    (set! *server-running* #f)
    (when (and *use-chez-httpd* *server-handle*)
      (chez-httpd-stop *server-handle*)
      (set! *server-handle* #f)))

  ;; --- Helpers ---

  (define (string-split-space str)
    (let lp ((i 0) (start 0) (result '()))
      (cond
        ((>= i (string-length str))
         (reverse (if (> i start)
                    (cons (substring str start i) result)
                    result)))
        ((char=? (string-ref str i) #\space)
         (lp (+ i 1) (+ i 1)
             (if (> i start) (cons (substring str start i) result) result)))
        (else (lp (+ i 1) start result)))))

  (define (string-index str ch)
    (let lp ((i 0))
      (cond
        ((>= i (string-length str)) #f)
        ((char=? (string-ref str i) ch) i)
        (else (lp (+ i 1))))))

  (define (string-trim str)
    (let* ((len (string-length str))
           (start (let lp ((i 0))
                    (if (or (>= i len) (not (char-whitespace? (string-ref str i))))
                      i (lp (+ i 1))))))
      (substring str start len)))

  (define (string-trim-right str)
    (let* ((len (string-length str))
           (end (let lp ((i (- len 1)))
                  (if (or (< i 0) (not (char-whitespace? (string-ref str i))))
                    (+ i 1) (lp (- i 1))))))
      (substring str 0 end)))

  ) ;; end library
