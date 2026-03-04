#!chezscheme
;;; std-net-request.sls -- Compat shim for Gerbil's :std/net/request
;;; HTTP client using curl subprocess

(library (compat std-net-request)
  (export
    http-get http-post http-put http-delete http-head http-options
    request? request-url request-status request-status-text
    request-headers request-content request-text request-json
    request-close request-encoding request-encoding-set!
    request-response-bytes)

  (import (chezscheme))

  (define-record-type request
    (fields url
            (mutable status)
            (mutable status-text)
            (mutable headers)
            (mutable body)       ;; bytevector
            (mutable encoding)
            (mutable closed?))
    (protocol
      (lambda (new)
        (lambda (url)
          (new url 0 "" '() (bytevector) 'utf-8 #f)))))

  (define (request-content req)
    (request-body req))

  (define (request-text req)
    (utf8->string (request-body req)))

  (define (request-json req)
    ;; Return the text; caller should parse JSON
    (utf8->string (request-body req)))

  (define (request-close req)
    (request-closed?-set! req #t))

  (define (request-response-bytes req)
    (unless (= (request-status req) 200)
      (error 'request-response-bytes
             "HTTP error" (request-status req) (request-status-text req)))
    (request-close req)
    (request-body req))

  ;; --- URL encoding ---

  (define (url-encode-pair key val)
    (string-append (url-encode (if (symbol? key) (symbol->string key)
                                 (if (string? key) key (format "~a" key))))
                   "="
                   (url-encode (if (string? val) val (format "~a" val)))))

  (define (url-encode str)
    (let ((port (open-output-string)))
      (string-for-each
        (lambda (c)
          (cond
            ((or (char-alphabetic? c) (char-numeric? c)
                 (memv c '(#\- #\_ #\. #\~)))
             (display c port))
            (else
             (let ((bv (string->utf8 (string c))))
               (do ((i 0 (+ i 1)))
                   ((= i (bytevector-length bv)))
                 (format port "%~2,'0x" (bytevector-u8-ref bv i)))))))
        str)
      (get-output-string port)))

  ;; --- Build curl command ---

  (define (build-url url params)
    (if (and params (pair? params))
      (string-append url
        (if (string-contains url "?") "&" "?")
        (let lp ((ps params) (first? #t))
          (if (null? ps) ""
            (string-append
              (if first? "" "&")
              (url-encode-pair (caar ps) (cdar ps))
              (lp (cdr ps) #f)))))
      url))

  (define (string-contains str sub)
    (let ((slen (string-length str))
          (sublen (string-length sub)))
      (let lp ((i 0))
        (cond
          ((> (+ i sublen) slen) #f)
          ((string=? sub (substring str i (+ i sublen))) i)
          (else (lp (+ i 1)))))))

  (define (build-curl-args method url headers data header-file)
    (let ((args (list "curl" "-s" "-S"
                      "-X" (symbol->string method)
                      "-D" header-file  ;; dump headers to file
                      url)))
      ;; Add headers
      (when (and headers (pair? headers))
        (for-each (lambda (h)
                    (set! args (append args
                      (list "-H" (string-append (car h) ": " (cdr h))))))
                  headers))
      ;; Add data
      (when data
        (set! args (append args
          (list "--data-binary" (if (bytevector? data)
                                  (utf8->string data)
                                  data)))))
      args))

  ;; --- Execute HTTP request via curl ---

  (define (http-request method url . kwargs)
    ;; Parse keyword args
    (let ((headers #f)
          (params #f)
          (data #f)
          (redirect #f)
          (cookies #f)
          (auth #f))
      (let lp ((kw kwargs))
        (unless (null? kw)
          (when (pair? (cdr kw))
            (case (car kw)
              ((headers:) (set! headers (cadr kw)))
              ((params:) (set! params (cadr kw)))
              ((data:) (set! data (cadr kw)))
              ((redirect:) (set! redirect (cadr kw)))
              ((cookies:) (set! cookies (cadr kw)))
              ((auth:) (set! auth (cadr kw)))
              ((ssl-context: timeout:) #f))  ;; ignored
            (lp (cddr kw)))))

      (let* ((full-url (build-url url params))
             (req (make-request full-url))
             (header-file (format "/tmp/gherkin-curl-hdr-~a" (random 10000000)))
             (curl-args (build-curl-args method full-url headers data header-file))
             ;; Add redirect flag
             (curl-args (if redirect
                          (append curl-args '("-L"))
                          curl-args))
             ;; Add cookies
             (curl-args (if (and cookies (pair? cookies))
                          (append curl-args
                            (list "-H"
                              (string-append "Cookie: "
                                (let lp ((cs cookies) (first? #t))
                                  (if (null? cs) ""
                                    (string-append
                                      (if first? "" "; ")
                                      (caar cs) "=" (cdar cs)
                                      (lp (cdr cs) #f)))))))
                          curl-args))
             ;; Add auth
             (curl-args (if auth
                          (append curl-args (list "-u" (format "~a:~a"
                                                        (cadr auth) (caddr auth))))
                          curl-args)))

        ;; Execute curl: body to stdout file, headers to separate file
        (let* ((tmp-body (format "/tmp/gherkin-curl-body-~a" (random 10000000)))
               (cmd (string-append (string-join curl-args " ")
                                   " > " (shell-escape tmp-body) " 2>/dev/null")))
          (system cmd)
          ;; Read headers
          (let ((header-text (if (file-exists? header-file)
                               (let ((p (open-input-file header-file)))
                                 (let ((t (get-string-all p)))
                                   (close-port p)
                                   (delete-file header-file)
                                   t))
                               ""))
                (body-text (if (file-exists? tmp-body)
                             (let ((p (open-input-file tmp-body)))
                               (let ((t (get-string-all p)))
                                 (close-port p)
                                 (delete-file tmp-body)
                                 t))
                             "")))
            ;; Parse headers and set body
            (parse-curl-headers req header-text)
            (request-body-set! req (string->utf8 body-text))
            req)))))

  (define (string-join lst sep)
    (if (null? lst) ""
      (let lp ((rest (cdr lst)) (result (shell-escape (car lst))))
        (if (null? rest) result
          (lp (cdr rest)
              (string-append result sep (shell-escape (car rest))))))))

  (define (shell-escape str)
    (string-append "'" (let lp ((i 0) (result '()))
      (if (>= i (string-length str))
        (list->string (reverse result))
        (let ((c (string-ref str i)))
          (if (char=? c #\')
            (lp (+ i 1) (append '(#\' #\\ #\' #\') result))
            (lp (+ i 1) (cons c result)))))) "'"))

  ;; Parse curl header file output
  (define (parse-curl-headers req header-text)
    (let* ((lines (string-split-lines header-text))
           (headers '())
           (status 0)
           (status-text ""))
      (for-each
        (lambda (line)
          (cond
            ((and (> (string-length line) 4)
                  (string=? "HTTP" (substring line 0 4)))
             ;; Status line: HTTP/1.1 200 OK
             (let ((parts (string-split-space line)))
               (when (>= (length parts) 2)
                 (set! status (or (string->number (cadr parts)) 0))
                 (set! status-text
                   (if (>= (length parts) 3)
                     (let lp ((ps (cddr parts)) (r ""))
                       (if (null? ps) r
                         (lp (cdr ps)
                             (if (string=? r "")
                               (car ps)
                               (string-append r " " (car ps))))))
                     "")))))
            ((> (string-length line) 0)
             ;; Header line: Key: Value
             (let ((colon-pos (string-index line #\:)))
               (when colon-pos
                 (set! headers
                   (cons (cons (substring line 0 colon-pos)
                               (string-trim (substring line (+ colon-pos 1)
                                                       (string-length line))))
                         headers)))))
            (else #f)))
        lines)
      (request-status-set! req status)
      (request-status-text-set! req status-text)
      (request-headers-set! req (reverse headers))))

  ;; Helper functions
  (define (string-split-lines str)
    (let lp ((i 0) (start 0) (result '()))
      (cond
        ((>= i (string-length str))
         (reverse (if (> i start)
                    (cons (substring str start i) result)
                    result)))
        ((char=? (string-ref str i) #\newline)
         (let ((end (if (and (> i 0) (char=? (string-ref str (- i 1)) #\return))
                      (- i 1) i)))
           (lp (+ i 1) (+ i 1)
               (cons (substring str start end) result))))
        (else (lp (+ i 1) start result)))))

  (define (string-split-space str)
    (let lp ((i 0) (start 0) (result '()))
      (cond
        ((>= i (string-length str))
         (reverse (if (> i start)
                    (cons (substring str start i) result)
                    result)))
        ((char=? (string-ref str i) #\space)
         (lp (+ i 1) (+ i 1)
             (if (> i start)
               (cons (substring str start i) result)
               result)))
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
                    (if (or (>= i len)
                            (not (char-whitespace? (string-ref str i))))
                      i (lp (+ i 1)))))
           (end (let lp ((i (- len 1)))
                  (if (or (< i start)
                          (not (char-whitespace? (string-ref str i))))
                    (+ i 1) (lp (- i 1))))))
      (substring str start end)))

  ;; --- Public API ---

  (define (http-get url . kwargs)
    (apply http-request 'GET url kwargs))

  (define (http-post url . kwargs)
    (apply http-request 'POST url kwargs))

  (define (http-put url . kwargs)
    (apply http-request 'PUT url kwargs))

  (define (http-delete url . kwargs)
    (apply http-request 'DELETE url kwargs))

  (define (http-head url . kwargs)
    (apply http-request 'HEAD url kwargs))

  (define (http-options url . kwargs)
    (apply http-request 'OPTIONS url kwargs))

  ) ;; end library
