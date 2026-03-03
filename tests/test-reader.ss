#!chezscheme
;;; test-reader.ss -- Tests for reader.sls
(import (except (chezscheme) void box box? unbox set-box! thread? make-mutex mutex? mutex-name) (reader reader) (compat gambit-compat) (tests test-helpers))

(test-begin "Gerbil Reader")

;; Helper: read a single datum from string
(define (read1 s)
  (let ([port (open-input-string s)])
    (gerbil-read port)))

;; Helper: read all datums from string
(define (read* s)
  (gerbil-read-string s))

;;;; Basic atoms
(test-equal "read integer" 42 (read1 "42"))
(test-equal "read negative" -7 (read1 "-7"))
(test-equal "read float" 3.14 (read1 "3.14"))
(test-equal "read symbol" 'hello (read1 "hello"))
(test-equal "read string" "hello world" (read1 "\"hello world\""))
(test-equal "read #t" #t (read1 "#t"))
(test-equal "read #f" #f (read1 "#f"))
(test-equal "read #true" #t (read1 "#true"))
(test-equal "read #false" #f (read1 "#false"))
(test-equal "read char space" #\space (read1 "#\\space"))
(test-equal "read char newline" #\newline (read1 "#\\newline"))
(test-equal "read char literal" #\a (read1 "#\\a"))
(test-equal "read char tab" #\tab (read1 "#\\tab"))
(test-equal "read char hex" #\x41 (read1 "#\\x41"))

;;;; Special symbols
(test-equal "read +" '+ (read1 "+"))
(test-equal "read -" '- (read1 "-"))
(test-equal "read ..." '... (read1 "..."))

;;;; Lists
(test-equal "read list" '(1 2 3) (read1 "(1 2 3)"))
(test-equal "read nested" '(a (b c) d) (read1 "(a (b c) d)"))
(test-equal "read dotted" '(1 . 2) (read1 "(1 . 2)"))
(test-equal "read empty" '() (read1 "()"))

;;;; Square brackets → @list
(let ([result (read1 "[1 2 3]")])
  (test-assert "square bracket is list" (pair? result))
  (test-equal "square bracket head" @list (car result))
  (test-equal "square bracket body" '(1 2 3) (cdr result)))

(let ([result (read1 "[]")])
  (test-assert "empty square bracket" (pair? result))
  (test-equal "empty square bracket head" @list (car result)))

;;;; Curly braces → @method
(let ([result (read1 "{method obj arg}")])
  (test-assert "curly brace is list" (pair? result))
  (test-equal "curly brace head" @method (car result))
  (test-equal "curly brace body" '(method obj arg) (cdr result)))

;;;; Keywords (trailing colon)
(let ([result (read1 "name:")])
  (test-assert "keyword" (|##keyword?| result))
  (test-equal "keyword name" "name" (|##keyword->string| result)))

(let ([result (read1 "foo-bar:")])
  (test-assert "keyword with dash" (|##keyword?| result))
  (test-equal "keyword name with dash" "foo-bar" (|##keyword->string| result)))

;; Single colon is a symbol, not a keyword
(test-equal "bare colon is symbol" ': (read1 ":"))

;;;; Hash-bang values
(test-assert "read #!void" (void? (read1 "#!void")))
(test-assert "read #!eof" (eof-object? (read1 "#!eof")))
(test-assert "read #!unbound" (unbound-obj? (read1 "#!unbound")))

;;;; Quoting
(test-equal "read quote" '(quote hello) (read1 "'hello"))
(test-equal "read quasiquote" '(quasiquote (a b)) (read1 "`(a b)"))
(test-equal "read unquote" '(unquote x) (read1 ",x"))
(test-equal "read unquote-splicing" '(unquote-splicing xs) (read1 ",@xs"))

;;;; Vectors
(test-equal "read vector" '#(1 2 3) (read1 "#(1 2 3)"))
(test-equal "read empty vector" '#() (read1 "#()"))

;;;; Bytevectors
(let ([result (read1 "#u8(1 2 3)")])
  (test-assert "read bytevector" (u8vector? result))
  (test-equal "bytevector length" 3 (u8vector-length result))
  (test-equal "bytevector ref" 2 (u8vector-ref result 1)))

;;;; Box
(let ([result (read1 "#&42")])
  (test-assert "read box" (box? result))
  (test-equal "box value" 42 (unbox result)))

;;;; Syntax sugar
(test-equal "read #'" '(syntax foo) (read1 "#'foo"))
(test-equal "read #`" '(quasisyntax (a b)) (read1 "#`(a b)"))
(test-equal "read #," '(unsyntax x) (read1 "#,x"))
(test-equal "read #,@" '(unsyntax-splicing xs) (read1 "#,@xs"))

;;;; String escapes
(test-equal "string \\n" "\n" (read1 "\"\\n\""))
(test-equal "string \\t" "\t" (read1 "\"\\t\""))
(test-equal "string \\\\" "\\" (read1 "\"\\\\\""))
(test-equal "string \\\"" "\"" (read1 "\"\\\"\""))
(test-equal "string \\x41" "A" (read1 "\"\\x41\""))
(test-equal "string \\x41;" "A" (read1 "\"\\x41;\""))

;;;; Comments
(test-equal "line comment" 42 (read1 "; ignored\n42"))
(test-equal "datum comment" 42 (read1 "#;(ignored) 42"))
(test-equal "block comment" 42 (read1 "#| block comment |# 42"))
(test-equal "nested block" 42 (read1 "#| #| nested |# outer |# 42"))

;;;; Multiple datums
(test-equal "read-all" '(1 2 3) (read* "1 2 3"))
(test-equal "read-all with comments" '(a b) (read* "a ; comment\nb"))
(test-equal "read-all empty" '() (read* ""))

;;;; Pipe symbols
(test-equal "pipe symbol" 'hello\ world (read1 "|hello world|"))
(test-equal "pipe with special" (string->symbol "a b") (read1 "|a b|"))

;;;; Source locations (with path)
(let* ([port (open-input-string "(foo bar)")]
       [datum (gerbil-read port "test.ss")])
  (test-assert "annotated datum" (annotated-datum? datum))
  (let ([loc (annotated-datum-source datum)])
    (test-assert "source-location?" (source-location? loc))
    (test-equal "source path" "test.ss" (source-location-path loc))
    (test-equal "source line" 1 (source-location-line loc))
    (test-equal "source column" 0 (source-location-column loc))))

;; Without path, no annotations
(let ([datum (read1 "(foo bar)")])
  (test-assert "no annotation without path" (not (annotated-datum? datum))))

;;;; Edge cases
(test-assert "EOF" (eof-object? (read1 "")))
(test-assert "whitespace only" (eof-object? (read1 "   ")))
(test-error "unmatched paren" (read1 ")"))
(test-error "unterminated list" (read1 "(1 2"))
(test-error "unterminated string" (read1 "\"hello"))

;;;; Complex expressions (Gerbil-style)
(let ([result (read* "(def (greet name:) (display [\"Hello\" name]))")])
  (test-equal "complex expression count" 1 (length result))
  (test-assert "complex expression is list" (pair? (car result))))

(test-end)
(let-values ([(p f) (test-stats)])
  (exit (if (> f 0) 1 0)))
