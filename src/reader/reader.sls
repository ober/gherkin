#!chezscheme
;;; reader.sls -- Custom Gerbil-compatible reader for Chez Scheme
;;;
;;; Handles: [...] → (@list ...), {...} → (@method ...),
;;; #!void/#!eof/#!unbound, keyword: syntax, source locations,
;;; #; datum comments, #| block comments |#, #u8(...), #&box

(library (reader reader)
  (export
    gerbil-read
    gerbil-read-all
    gerbil-read-file
    gerbil-read-string
    @list @method
    source-location source-location?
    source-location-path source-location-line source-location-column
    make-source-location
    annotated-datum annotated-datum?
    annotated-datum-value annotated-datum-source
    make-annotated-datum)

  (import (except (chezscheme) void box box? unbox set-box!)
          (compat gambit-compat))

  ;;;; Marker symbols
  (define @list (string->symbol "@list"))
  (define @method (string->symbol "@method"))

  ;;;; Source locations
  (define-record-type source-location
    (fields path line column)
    (sealed #t))

  (define-record-type annotated-datum
    (fields value source)
    (sealed #t))

  ;;;; Reader state
  (define-record-type reader-state
    (fields
      port
      (mutable line)
      (mutable column)
      (mutable path)
      (mutable peeked))
    (sealed #t))

  (define (make-reader port . path)
    (make-reader-state port 1 0 (if (null? path) #f (car path)) #f))

  ;;;; Character I/O with tracking

  (define (reader-peek rs)
    (or (reader-state-peeked rs)
        (let ((ch (read-char (reader-state-port rs))))
          (reader-state-peeked-set! rs ch)
          ch)))

  (define (reader-next! rs)
    (let ((ch (or (reader-state-peeked rs)
                  (read-char (reader-state-port rs)))))
      (reader-state-peeked-set! rs #f)
      (when (char? ch)
        (if (char=? ch #\newline)
            (begin
              (reader-state-line-set! rs (fx+ (reader-state-line rs) 1))
              (reader-state-column-set! rs 0))
            (reader-state-column-set! rs (fx+ (reader-state-column rs) 1))))
      ch))

  (define (reader-location rs)
    (make-source-location
      (reader-state-path rs)
      (reader-state-line rs)
      (reader-state-column rs)))

  (define (annotate rs value loc)
    (if (reader-state-path rs)
        (make-annotated-datum value loc)
        value))

  ;;;; Character classification

  (define (delimiter? ch)
    (or (eof-object? ch)
        (char-whitespace? ch)
        (memv ch '(#\( #\) #\[ #\] #\{ #\} #\" #\; #\,))))

  (define (initial-ident? ch)
    (and (char? ch)
         (or (char-alphabetic? ch)
             (memv ch '(#\! #\$ #\% #\& #\* #\/ #\: #\< #\= #\> #\? #\^ #\_ #\~
                        #\+ #\- #\. #\@)))))

  (define (subsequent-ident? ch)
    (and (char? ch)
         (or (char-alphabetic? ch)
             (char-numeric? ch)
             (memv ch '(#\! #\$ #\% #\& #\* #\/ #\: #\< #\= #\> #\? #\^ #\_ #\~
                        #\+ #\- #\. #\@ #\#)))))

  ;;;; Comment skipping

  (define (skip-whitespace! rs)
    (let loop ()
      (let ((ch (reader-peek rs)))
        (cond
          ((eof-object? ch) (void))
          ((char-whitespace? ch)
           (reader-next! rs)
           (loop))
          ((char=? ch #\;)
           (skip-line-comment! rs)
           (loop))
          (else (void))))))

  (define (skip-line-comment! rs)
    (let loop ()
      (let ((ch (reader-next! rs)))
        (unless (or (eof-object? ch) (char=? ch #\newline))
          (loop)))))

  (define (skip-block-comment! rs depth)
    (let loop ((depth depth))
      (when (fx> depth 0)
        (let ((ch (reader-next! rs)))
          (cond
            ((eof-object? ch)
             (error 'gerbil-read "unterminated block comment"))
            ((char=? ch #\#)
             (let ((ch2 (reader-peek rs)))
               (if (and (char? ch2) (char=? ch2 #\|))
                   (begin (reader-next! rs) (loop (fx+ depth 1)))
                   (loop depth))))
            ((char=? ch #\|)
             (let ((ch2 (reader-peek rs)))
               (if (and (char? ch2) (char=? ch2 #\#))
                   (begin (reader-next! rs) (loop (fx- depth 1)))
                   (loop depth))))
            (else (loop depth)))))))

  ;;;; Main reader dispatch

  (define (read-datum rs)
    (skip-whitespace! rs)
    (let ((loc (reader-location rs))
          (ch (reader-peek rs)))
      (cond
        ((eof-object? ch) (eof-object))

        ;; Lists
        ((char=? ch #\()
         (reader-next! rs)
         (annotate rs (read-list rs #\)) loc))

        ;; Square brackets → @list
        ((char=? ch #\[)
         (reader-next! rs)
         (let ((items (read-list rs #\])))
           (annotate rs (cons @list items) loc)))

        ;; Curly braces → @method
        ((char=? ch #\{)
         (reader-next! rs)
         (let ((items (read-list rs #\})))
           (annotate rs (cons @method items) loc)))

        ;; Closing delimiters
        ((or (char=? ch #\)) (char=? ch #\]) (char=? ch #\}))
         (error 'gerbil-read "unexpected closing delimiter" ch
                (reader-state-line rs) (reader-state-column rs)))

        ;; String
        ((char=? ch #\")
         (reader-next! rs)
         (annotate rs (read-string-literal rs) loc))

        ;; Quote
        ((char=? ch #\')
         (reader-next! rs)
         (annotate rs (list 'quote (read-datum rs)) loc))

        ;; Quasiquote
        ((char=? ch #\`)
         (reader-next! rs)
         (annotate rs (list 'quasiquote (read-datum rs)) loc))

        ;; Unquote / unquote-splicing
        ((char=? ch #\,)
         (reader-next! rs)
         (let ((ch2 (reader-peek rs)))
           (if (and (char? ch2) (char=? ch2 #\@))
               (begin
                 (reader-next! rs)
                 (annotate rs (list 'unquote-splicing (read-datum rs)) loc))
               (annotate rs (list 'unquote (read-datum rs)) loc))))

        ;; Hash dispatch
        ((char=? ch #\#)
         (reader-next! rs)
         (read-hash rs loc))

        ;; Number or symbol starting with + or -
        ((or (char=? ch #\+) (char=? ch #\-))
         (read-number-or-symbol rs loc))

        ;; Number
        ((char-numeric? ch)
         (annotate rs (read-number rs) loc))

        ;; Symbol or keyword
        ((or (initial-ident? ch) (char=? ch #\|))
         (read-symbol-or-keyword rs loc))

        (else
         (reader-next! rs)
         (error 'gerbil-read "unexpected character" ch)))))

  ;;;; List reader

  (define (read-list rs close-char)
    (let loop ((acc '()))
      (skip-whitespace! rs)
      ;; Handle # comments inside lists; may return a datum for non-comment # tokens
      (let ((hash-datum (handle-hash-comments! rs)))
        (if hash-datum
          (loop (cons hash-datum acc))
      (let ((ch (reader-peek rs)))
        (cond
          ((eof-object? ch)
           (error 'gerbil-read "unterminated list"))
          ((char=? ch close-char)
           (reader-next! rs)
           (reverse acc))
          ;; Dot for dotted pairs
          ((char=? ch #\.)
           (reader-next! rs)
           (let ((ch2 (reader-peek rs)))
             (cond
               ((delimiter? ch2)
                ;; Dotted pair
                (skip-whitespace! rs)
                (let ((tail (read-datum rs)))
                  (skip-whitespace! rs)
                  (let ((ch3 (reader-next! rs)))
                    (unless (and (char? ch3) (char=? ch3 close-char))
                      (error 'gerbil-read "expected closing delimiter after dot")))
                  ;; Build improper list from acc (already reversed)
                  (let build ((items acc) (result tail))
                    (if (null? items) result
                        (build (cdr items) (cons (car items) result))))))
               (else
                ;; Symbol starting with .
                (reader-state-peeked-set! rs ch2)
                (let ((loc (reader-location rs)))
                  (let ((sym (read-symbol-chars rs #\.)))
                    (loop (cons (annotate rs sym loc) acc))))))))
          (else
           (let ((datum (read-datum rs)))
             (if (eof-object? datum)
                 (error 'gerbil-read "unterminated list")
                 (loop (cons datum acc)))))))))))

  ;; Handle #| and #; comments that appear inside lists
  ;; Handle #| and #; comments inside lists.
  ;; Returns #f if no hash was consumed, or a datum if a non-comment hash
  ;; expression was read (e.g. #t, #f, #\x, #(...), #u8(...)).
  (define (handle-hash-comments! rs)
    (let ((ch (reader-peek rs)))
      (if (and (char? ch) (char=? ch #\#))
        (let ((loc (reader-location rs)))
          (reader-next! rs)  ;; consume #
          (let ((ch2 (reader-peek rs)))
            (cond
              ;; #| block comment
              ((and (char? ch2) (char=? ch2 #\|))
               (reader-next! rs)
               (skip-block-comment! rs 1)
               (skip-whitespace! rs)
               (handle-hash-comments! rs))
              ;; #; datum comment
              ((and (char? ch2) (char=? ch2 #\;))
               (reader-next! rs)
               (skip-whitespace! rs)
               (read-datum rs) ;; discard
               (skip-whitespace! rs)
               (handle-hash-comments! rs))
              ;; Not a comment — # was consumed, so call read-hash
              ;; to process #\, #t, #f, #(, #u8(, #!, etc.
              (else
               (read-hash rs loc)))))
        #f)))

  ;;;; Hash dispatch (#)

  (define (read-hash rs loc)
    (let ((ch (reader-peek rs)))
      (cond
        ((eof-object? ch) (error 'gerbil-read "unexpected EOF after #"))

        ;; #t, #f, #true, #false
        ((or (char=? ch #\t) (char=? ch #\T))
         (reader-next! rs)
         (let ((ch2 (reader-peek rs)))
           (cond
             ((or (eof-object? ch2) (delimiter? ch2))
              (annotate rs #t loc))
             ((char-alphabetic? ch2)
              (let ((rest (read-symbol-chars rs #\t)))
                (if (memq rest '(true True TRUE))
                    (annotate rs #t loc)
                    (error 'gerbil-read "invalid # syntax" rest))))
             (else (annotate rs #t loc)))))

        ((or (char=? ch #\f) (char=? ch #\F))
         (reader-next! rs)
         (let ((ch2 (reader-peek rs)))
           (cond
             ((or (eof-object? ch2) (delimiter? ch2))
              (annotate rs #f loc))
             ((char-alphabetic? ch2)
              (let ((rest (read-symbol-chars rs #\f)))
                (if (memq rest '(false False FALSE))
                    (annotate rs #f loc)
                    (error 'gerbil-read "invalid # syntax" rest))))
             (else (annotate rs #f loc)))))

        ;; #( vector
        ((char=? ch #\()
         (reader-next! rs)
         (let ((items (read-list rs #\))))
           (annotate rs (list->vector items) loc)))

        ;; #u8( bytevector
        ((char=? ch #\u)
         (reader-next! rs)
         (let ((ch2 (reader-next! rs)))
           (unless (and (char? ch2) (char=? ch2 #\8))
             (error 'gerbil-read "expected #u8("))
           (let ((ch3 (reader-next! rs)))
             (unless (and (char? ch3) (char=? ch3 #\())
               (error 'gerbil-read "expected #u8("))
             (let ((items (read-list rs #\))))
               (annotate rs (apply u8vector items) loc)))))

        ;; #\ character
        ((char=? ch #\\)
         (reader-next! rs)
         (annotate rs (read-character rs) loc))

        ;; #! hash-bang
        ((char=? ch #\!)
         (reader-next! rs)
         (read-hash-bang rs loc))

        ;; #| block comment
        ((char=? ch #\|)
         (reader-next! rs)
         (skip-block-comment! rs 1)
         (read-datum rs))

        ;; #; datum comment
        ((char=? ch #\;)
         (reader-next! rs)
         (skip-whitespace! rs)
         (read-datum rs) ;; discard
         (read-datum rs)) ;; read real

        ;; #& box
        ((char=? ch #\&)
         (reader-next! rs)
         (annotate rs (box (read-datum rs)) loc))

        ;; #' syntax quote
        ((char=? ch #\')
         (reader-next! rs)
         (annotate rs (list 'syntax (read-datum rs)) loc))

        ;; #` syntax quasiquote
        ((char=? ch #\`)
         (reader-next! rs)
         (annotate rs (list 'quasisyntax (read-datum rs)) loc))

        ;; #, syntax unquote
        ((char=? ch #\,)
         (reader-next! rs)
         (let ((ch2 (reader-peek rs)))
           (if (and (char? ch2) (char=? ch2 #\@))
               (begin
                 (reader-next! rs)
                 (annotate rs (list 'unsyntax-splicing (read-datum rs)) loc))
               (annotate rs (list 'unsyntax (read-datum rs)) loc))))

        ;; #x hex, #o octal, #b binary, #d decimal number
        ((or (char=? ch #\x) (char=? ch #\X))
         (reader-next! rs)
         (let ((str (read-number-chars rs)))
           (annotate rs (string->number (string-append "#x" str)) loc)))

        ((or (char=? ch #\o) (char=? ch #\O))
         (reader-next! rs)
         (let ((str (read-number-chars rs)))
           (annotate rs (string->number (string-append "#o" str)) loc)))

        ((or (char=? ch #\b) (char=? ch #\B))
         (reader-next! rs)
         (let ((str (read-number-chars rs)))
           (annotate rs (string->number (string-append "#b" str)) loc)))

        ((or (char=? ch #\d) (char=? ch #\D))
         (reader-next! rs)
         (let ((str (read-number-chars rs)))
           (annotate rs (string->number (string-append "#d" str)) loc)))

        ;; ## double-hash (Gambit primitives)
        ((char=? ch #\#)
         (reader-next! rs)
         (let ((name (read-symbol-chars rs #f)))
           (let ((sym (string->symbol (string-append "##" (symbol->string name)))))
             (annotate rs sym loc))))

        ;; #% core forms (Gerbil expander primitives)
        ((char=? ch #\%)
         (reader-next! rs)
         (let ((name (read-symbol-chars rs #f)))
           (let ((sym (string->symbol (string-append "#%" (symbol->string name)))))
             (annotate rs sym loc))))

        ;; #< heredoc string (#<<DELIM ... DELIM)
        ((char=? ch #\<)
         (reader-next! rs)
         (let ((ch2 (reader-peek rs)))
           (if (and (char? ch2) (char=? ch2 #\<))
             (begin
               (reader-next! rs)
               ;; Read delimiter word
               (let ((delim (let dloop ((chars '()))
                              (let ((c (reader-peek rs)))
                                (cond
                                  ((or (eof-object? c) (char=? c #\newline) (char=? c #\return))
                                   (when (and (char? c) (or (char=? c #\newline) (char=? c #\return)))
                                     (reader-next! rs)
                                     ;; consume \r\n pair
                                     (when (char=? c #\return)
                                       (let ((c2 (reader-peek rs)))
                                         (when (and (char? c2) (char=? c2 #\newline))
                                           (reader-next! rs)))))
                                   (list->string (reverse chars)))
                                  (else
                                   (reader-next! rs)
                                   (dloop (cons c chars))))))))
                 ;; Read lines until we find the delimiter alone on a line
                 (let hloop ((lines '()))
                   (let lloop ((chars '()))
                     (let ((c (reader-next! rs)))
                       (cond
                         ((eof-object? c)
                          (error 'gerbil-read "unterminated heredoc"))
                         ((or (char=? c #\newline) (char=? c #\return))
                          ;; consume \r\n pair
                          (when (char=? c #\return)
                            (let ((c2 (reader-peek rs)))
                              (when (and (char? c2) (char=? c2 #\newline))
                                (reader-next! rs))))
                          (let ((line (list->string (reverse chars))))
                            (if (string=? line delim)
                              (annotate rs
                                (let ((all (reverse lines)))
                                  (if (null? all) ""
                                    (let lp ((strs all) (acc (car all)))
                                      (if (null? (cdr strs)) acc
                                        (lp (cdr strs)
                                            (string-append acc "\n" (cadr strs)))))))
                                loc)
                              (hloop (cons line lines)))))
                         (else
                          (lloop (cons c chars)))))))))
             (error 'gerbil-read "invalid # dispatch" ch))))

        (else
         (error 'gerbil-read "invalid # dispatch" ch)))))

  ;; Read chars that could be part of a number literal
  (define (read-number-chars rs)
    (let loop ((acc '()))
      (let ((ch (reader-peek rs)))
        (if (and (char? ch)
                 (or (char-numeric? ch)
                     (and (char>=? ch #\a) (char<=? ch #\f))
                     (and (char>=? ch #\A) (char<=? ch #\F))
                     (char=? ch #\+) (char=? ch #\-)))
          (begin (reader-next! rs) (loop (cons ch acc)))
          (list->string (reverse acc))))))

  ;;;; Hash-bang reader

  (define (read-hash-bang rs loc)
    (let ((ch (reader-peek rs)))
      (cond
        ((or (eof-object? ch) (delimiter? ch))
         (error 'gerbil-read "incomplete #!"))
        (else
         (let ((name (read-hash-bang-name rs)))
           (case name
             ((void)     (annotate rs (void) loc))
             ((eof)      (annotate rs (|##eof-object|) loc))
             ((unbound)  (annotate rs (unbound-obj) loc))
             ((optional) (annotate rs (absent-obj) loc))
             ((rest)     (annotate rs (|##string->keyword| "rest") loc))
             ((key)      (annotate rs (|##string->keyword| "key") loc))
             (else
              (annotate rs (list (string->symbol "#!") name) loc))))))))

  (define (read-hash-bang-name rs)
    (let loop ((chars '()))
      (let ((ch (reader-peek rs)))
        (cond
          ((or (eof-object? ch) (delimiter? ch))
           (string->symbol (list->string (reverse chars))))
          (else
           (reader-next! rs)
           (loop (cons ch chars)))))))

  ;;;; Character reader

  (define (read-character rs)
    (let ((ch (reader-next! rs)))
      (cond
        ((eof-object? ch) (error 'gerbil-read "unexpected EOF in character"))
        ((or (eof-object? (reader-peek rs)) (delimiter? (reader-peek rs)))
         ch)
        (else
         (let loop ((chars (list ch)))
           (let ((ch2 (reader-peek rs)))
             (cond
               ((or (eof-object? ch2) (delimiter? ch2))
                (let ((name (string-downcase (list->string (reverse chars)))))
                  (cond
                    ((string=? name "space")     #\space)
                    ((string=? name "newline")   #\newline)
                    ((string=? name "tab")       #\tab)
                    ((string=? name "return")    #\return)
                    ((string=? name "nul")       #\nul)
                    ((string=? name "null")      #\nul)
                    ((string=? name "backspace") #\backspace)
                    ((string=? name "delete")    #\delete)
                    ((string=? name "escape")    #\x1B)
                    ((string=? name "alarm")     #\alarm)
                    ((string=? name "linefeed")  #\newline)
                    ((and (fx= (string-length name) 1))
                     (string-ref name 0))
                    ((and (fx>= (string-length name) 2)
                          (char=? (string-ref name 0) #\x))
                     (let ((n (string->number (substring name 1 (string-length name)) 16)))
                       (if n (integer->char n)
                           (error 'gerbil-read "invalid character name" name))))
                    (else
                     (error 'gerbil-read "unknown character name" name)))))
               (else
                (reader-next! rs)
                (loop (cons ch2 chars))))))))))

  ;;;; String reader

  (define (read-string-literal rs)
    (let loop ((chars '()))
      (let ((ch (reader-next! rs)))
        (cond
          ((eof-object? ch) (error 'gerbil-read "unterminated string"))
          ((char=? ch #\") (list->string (reverse chars)))
          ((char=? ch #\\)
           (let ((esc (reader-next! rs)))
             (cond
               ((eof-object? esc) (error 'gerbil-read "unterminated string escape"))
               ((char=? esc #\n) (loop (cons #\newline chars)))
               ((char=? esc #\t) (loop (cons #\tab chars)))
               ((char=? esc #\r) (loop (cons #\return chars)))
               ((char=? esc #\\) (loop (cons #\\ chars)))
               ((char=? esc #\") (loop (cons #\" chars)))
               ((char=? esc #\a) (loop (cons #\alarm chars)))
               ((char=? esc #\b) (loop (cons #\backspace chars)))
               ((char=? esc #\0) (loop (cons #\nul chars)))
               ((char=? esc #\x)
                (let hex-loop ((hex-chars '()))
                  (let ((hch (reader-peek rs)))
                    (cond
                      ((and (char? hch) (char=? hch #\;))
                       (reader-next! rs)
                       (let ((n (string->number (list->string (reverse hex-chars)) 16)))
                         (if n (loop (cons (integer->char n) chars))
                             (error 'gerbil-read "invalid hex escape"))))
                      ((and (char? hch)
                            (or (char-numeric? hch)
                                (memv (char-downcase hch) '(#\a #\b #\c #\d #\e #\f))))
                       (reader-next! rs)
                       (hex-loop (cons hch hex-chars)))
                      (else
                       (if (null? hex-chars)
                           (error 'gerbil-read "empty hex escape")
                           (let ((n (string->number (list->string (reverse hex-chars)) 16)))
                             (if n (loop (cons (integer->char n) chars))
                                 (error 'gerbil-read "invalid hex escape")))))))))
               (else (loop (cons esc chars))))))
          (else (loop (cons ch chars)))))))

  ;;;; Number reader

  (define (read-number rs)
    (let loop ((chars '()))
      (let ((ch (reader-peek rs)))
        (cond
          ((or (eof-object? ch) (delimiter? ch))
           (let ((s (list->string (reverse chars))))
             (or (string->number s)
                 ;; Fall back to symbol for identifiers like 1+ 1-
                 (string->symbol s))))
          (else
           (reader-next! rs)
           (loop (cons ch chars)))))))

  ;;;; Number-or-symbol

  (define (read-number-or-symbol rs loc)
    (let ((ch (reader-next! rs)))
      (let ((ch2 (reader-peek rs)))
        (cond
          ((or (eof-object? ch2) (delimiter? ch2))
           (annotate rs (string->symbol (string ch)) loc))
          ((char-numeric? ch2)
           (let loop ((chars (list ch)))
             (let ((c (reader-peek rs)))
               (cond
                 ((or (eof-object? c) (delimiter? c))
                  (let ((s (list->string (reverse chars))))
                    (annotate rs (or (string->number s) (string->symbol s)) loc)))
                 (else
                  (reader-next! rs)
                  (loop (cons c chars)))))))
          (else
           (let ((sym (read-symbol-chars rs ch)))
             (let ((s (symbol->string sym)))
               (cond
                 ((string->number s) => (lambda (n) (annotate rs n loc)))
                 (else (annotate rs sym loc))))))))))

  ;;;; Symbol/keyword reader

  (define (read-symbol-or-keyword rs loc)
    (let ((ch (reader-peek rs)))
      (cond
        ((and (char? ch) (char=? ch #\|))
         (reader-next! rs)
         (annotate rs (read-pipe-symbol rs) loc))
        (else
         (let ((sym (read-symbol-chars rs #f)))
           (let ((s (symbol->string sym)))
             (cond
               ((and (fx> (string-length s) 1)
                     (char=? (string-ref s (fx- (string-length s) 1)) #\:))
                (let ((kw-name (substring s 0 (fx- (string-length s) 1))))
                  (annotate rs (|##string->keyword| kw-name) loc)))
               (else
                (annotate rs sym loc)))))))))

  (define (read-symbol-chars rs prefix-char)
    (let loop ((chars (if prefix-char (list prefix-char) '())))
      (let ((ch (reader-peek rs)))
        (cond
          ((or (eof-object? ch) (delimiter? ch))
           (string->symbol (list->string (reverse chars))))
          ((subsequent-ident? ch)
           (reader-next! rs)
           (loop (cons ch chars)))
          (else
           (string->symbol (list->string (reverse chars))))))))

  (define (read-pipe-symbol rs)
    (let loop ((chars '()))
      (let ((ch (reader-next! rs)))
        (cond
          ((eof-object? ch) (error 'gerbil-read "unterminated pipe symbol"))
          ((char=? ch #\|) (string->symbol (list->string (reverse chars))))
          ((char=? ch #\\)
           (let ((esc (reader-next! rs)))
             (cond
               ((eof-object? esc) (error 'gerbil-read "unterminated pipe symbol escape"))
               (else (loop (cons esc chars))))))
          (else (loop (cons ch chars)))))))

  ;;;; Public API

  (define gerbil-read
    (case-lambda
      (() (gerbil-read (current-input-port)))
      ((port) (gerbil-read port #f))
      ((port path)
       (let ((rs (make-reader port path)))
         (read-datum rs)))))

  (define (gerbil-read-all port . path)
    (let ((rs (make-reader port (if (null? path) #f (car path)))))
      (let loop ((acc '()))
        (let ((datum (read-datum rs)))
          (if (eof-object? datum)
              (reverse acc)
              (loop (cons datum acc)))))))

  (define (gerbil-read-file filename)
    (call-with-input-file filename
      (lambda (port)
        (gerbil-read-all port filename))))

  (define (gerbil-read-string str . path)
    (let ((port (open-input-string str)))
      (gerbil-read-all port (if (null? path) #f (car path)))))

  ) ;; end library
