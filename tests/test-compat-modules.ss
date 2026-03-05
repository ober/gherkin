#!chezscheme
;;; test-compat-modules.ss -- Test Tier 2 compat modules
(import
  (except (chezscheme) filter iota remove partition fold-right
          path-extension errorf last-pair)
  (compat std-getopt)
  (compat std-logger)
  (compat std-os-path)
  (compat std-os-env)
  (compat std-srfi-13)
  (compat std-srfi-19)
  (compat std-misc-repr)
  (compat std-misc-bytes)
  (compat std-text-csv)
  (compat std-text-utf8)
  (except (compat misc) string-prefix? string-suffix? string-contains
          path-expand path-normalize path-extension path-strip-extension
          path-directory path-strip-directory)
  (compat sort)
  (compat json)
  (tests test-helpers))

(test-begin "Compat Modules")

;;; ============================================================
;;; :std/getopt
;;; ============================================================

(let* ((gopt (getopt
               (flag "verbose" "-v" "--verbose")
               (option "output" "-o" "--output")
               (argument "input"))))
  (test-assert "getopt creates object" (getopt? gopt))

  (let-values (((opts rest) (getopt-parse gopt '("-v" "--output" "foo.txt" "bar.txt"))))
    (test-equal "getopt parses flag" #t (cdr (assoc "verbose" opts)))
    (test-equal "getopt parses option" "foo.txt" (cdr (assoc "output" opts)))
    (test-equal "getopt parses argument" "bar.txt" (cdr (assoc "input" opts)))))

;;; ============================================================
;;; :std/logger
;;; ============================================================

(test-assert "logger starts" (begin (start-logger!) (current-logger)))

(let ((port (open-output-string)))
  (parameterize ((current-logger-options (make-logger-options 4 port)))
    (infof "test ~a" "msg")
    (test-assert "infof writes to port"
      (> (string-length (get-output-string port)) 0))))

;;; ============================================================
;;; :std/os/path
;;; ============================================================

(test-equal "path-directory" "/foo/bar" (path-directory "/foo/bar/baz.txt"))
(test-equal "path-strip-directory" "baz.txt" (path-strip-directory "/foo/bar/baz.txt"))
(test-equal "path-strip-extension" "/foo/bar/baz" (path-strip-extension "/foo/bar/baz.txt"))

;;; ============================================================
;;; :std/os/env
;;; ============================================================

(setenv "GHERKIN_TEST_VAR" "hello")
(test-equal "setenv/getenv" "hello" (getenv "GHERKIN_TEST_VAR"))

;;; ============================================================
;;; :std/srfi/13
;;; ============================================================

(test-equal "string-index" 2 (string-index "hello" #\l))
(test-assert "string-prefix?" (string-prefix? "he" "hello"))
(test-assert "string-suffix?" (string-suffix? "lo" "hello"))
(test-equal "string-contains" 2 (string-contains "hello" "ll"))
(test-equal "string-trim" "hello" (string-trim "  hello"))
(test-equal "string-trim-both" "hello" (string-trim-both "  hello  "))
(test-equal "string-join" "a-b-c" (string-join '("a" "b" "c") "-"))
(test-equal "string-pad" "  hi" (string-pad "hi" 4))
(test-equal "string-take" "hel" (string-take "hello" 3))
(test-equal "string-drop" "lo" (string-drop "hello" 3))
(test-equal "string-count" 2 (string-count "hello" #\l))
(test-equal "string-reverse" "olleh" (string-reverse "hello"))
(test-assert "string-null?" (string-null? ""))
(test-assert "string-every" (string-every char-alphabetic? "hello"))
(test-assert "string-any" (string-any #\l "hello"))
(test-equal "string-tokenize" '("hello" "world") (string-tokenize "  hello  world  "))

;;; ============================================================
;;; :std/srfi/19
;;; ============================================================

(let ((d (current-date)))
  (test-assert "current-date" (date? d))
  (test-assert "date-year > 2020" (> (date-year d) 2020)))

(test-assert "time->seconds" (> (time->seconds (current-time)) 0))

;;; ============================================================
;;; :std/misc/repr
;;; ============================================================

(test-equal "repr number" "42" (repr 42))
(test-equal "repr string" "\"hello\"" (repr "hello"))

;;; ============================================================
;;; :std/misc/bytes
;;; ============================================================

(let ((bv1 #vu8(#xff #x00 #xaa))
      (bv2 #vu8(#x0f #xf0 #x55)))
  (test-equal "u8vector-xor" #vu8(#xf0 #xf0 #xff) (u8vector-xor bv1 bv2)))

(test-equal "u8vector->uint" 256 (u8vector->uint #vu8(1 0)))
(test-equal "uint->u8vector" #vu8(1 0) (uint->u8vector 256 2))

;;; ============================================================
;;; :std/text/csv
;;; ============================================================

(let* ((port (open-input-string "a,b,c\n1,2,3\n"))
       (records (read-csv port)))
  (test-equal "csv records count" 2 (length records))
  (test-equal "csv first record" '("a" "b" "c") (car records))
  (test-equal "csv second record" '("1" "2" "3") (cadr records)))

;;; ============================================================
;;; :std/text/utf8
;;; ============================================================

(test-equal "utf8-encode" #vu8(104 101 108 108 111) (utf8-encode "hello"))
(test-equal "utf8-decode" "hello" (utf8-decode #vu8(104 101 108 108 111)))
(test-equal "utf8-length" 5 (utf8-length "hello"))

;;; ============================================================
;;; (compat misc) — SRFI-1, misc/list, misc/path, misc/string
;;; ============================================================

(test-assert "any" (any odd? '(2 4 3 6)))
(test-assert "every" (every even? '(2 4 6)))
(test-equal "filter" '(2 4) (filter even? '(1 2 3 4)))
(test-equal "fold" 10 (fold + 0 '(1 2 3 4)))
(test-equal "iota" '(0 1 2 3 4) (iota 5))
(test-equal "take" '(1 2 3) (take '(1 2 3 4 5) 3))
(test-equal "drop" '(4 5) (drop '(1 2 3 4 5) 3))
(test-equal "flatten" '(1 2 3 4) (flatten '(1 (2 (3)) 4)))
(test-equal "butlast" '(1 2 3) (butlast '(1 2 3 4)))
(test-assert "string-empty?" (string-empty? ""))

;;; ============================================================
;;; (compat sort)
;;; ============================================================

(test-equal "stable-sort" '(1 1 3 4 5)
  (stable-sort '(3 1 4 1 5) <))

;;; ============================================================
;;; (compat json)
;;; ============================================================

(let ((obj (string->json-object "{\"name\":\"test\",\"value\":42}")))
  (test-assert "json parse object" (hashtable? obj))
  (test-equal "json field" "test" (hashtable-ref obj "name" #f))
  (test-equal "json number" 42 (hashtable-ref obj "value" #f)))

(test-equal "json array" '(1 2 3)
  (string->json-object "[1,2,3]"))

(test-equal "json roundtrip string" "\"hello\""
  (json-object->string "hello"))

(test-end)
