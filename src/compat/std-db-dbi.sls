#!chezscheme
;;; std-db-dbi.sls -- Compat shim for Gerbil's :std/db/dbi
;;; Generic database interface (SQLite via sqlite3 CLI)

(library (compat std-db-dbi)
  (export
    sql-connect sql-close
    sql-exec sql-eval
    sql-query sql-eval-query
    sql-prepare sql-bind sql-finalize
    sql-txn-begin sql-txn-commit sql-txn-abort
    sql-error? raise-sql-error)

  (import (chezscheme))

  ;; --- Connection record ---
  (define-record-type sql-connection
    (fields db-path (mutable closed?))
    (protocol
      (lambda (new)
        (lambda (path)
          (new path #f)))))

  ;; --- Statement record ---
  (define-record-type sql-statement
    (fields conn sql (mutable params))
    (protocol
      (lambda (new)
        (lambda (conn sql)
          (new conn sql '())))))

  ;; --- Error type ---
  (define-condition-type &sql-error &error
    make-sql-error sql-error?)

  ;; --- Connection management ---

  (define (sql-connect driver . args)
    ;; For SQLite: (sql-connect sqlite-connect "/path/to/db")
    ;; For generic: just use the first string arg as path
    (let lp ((rest args) (path #f))
      (cond
        ((null? rest)
         (if path
           (make-sql-connection path)
           (error 'sql-connect "no database path provided")))
        ((string? (car rest))
         (lp (cdr rest) (car rest)))
        ;; Skip keyword args
        ((and (symbol? (car rest)) (pair? (cdr rest)))
         (lp (cddr rest) path))
        (else (lp (cdr rest) path)))))

  (define (sql-close conn)
    (sql-connection-closed?-set! conn #t))

  ;; --- Statement operations ---

  (define (sql-prepare conn sql)
    (make-sql-statement conn sql))

  (define (sql-bind stmt . args)
    (sql-statement-params-set! stmt args))

  (define (sql-finalize stmt)
    (sql-statement-params-set! stmt '()))

  ;; --- Execution ---

  (define (execute-sqlite conn sql params)
    (let* ((db-path (sql-connection-db-path conn))
           (formatted-sql (apply-params sql params)))
      ;; Use open-process-ports to avoid shell escaping issues
      (let-values (((to-stdin from-stdout from-stderr pid)
                    (open-process-ports
                      (string-append "sqlite3 -json "
                                     (shell-escape db-path))
                      (buffer-mode block)
                      (native-transcoder))))
        (display formatted-sql to-stdin)
        (newline to-stdin)
        (close-port to-stdin)
        (let ((output (get-string-all from-stdout)))
          (close-port from-stdout)
          (close-port from-stderr)
          (if (eof-object? output) "" output)))))

  (define (apply-params sql params)
    ;; Simple parameter substitution: $1, $2, etc.
    (if (null? params) sql
      (let lp ((i 1) (ps params) (result sql))
        (if (null? ps) result
          (lp (+ i 1) (cdr ps)
              (string-replace result
                (format "$~a" i)
                (sql-escape-value (car ps))))))))

  (define (sql-escape-value val)
    (cond
      ((string? val)
       (string-append "'" (string-replace val "'" "''") "'"))
      ((number? val) (format "~a" val))
      ((not val) "NULL")
      ((boolean? val) (if val "1" "0"))
      (else (format "'~a'" val))))

  (define (string-replace str old new)
    (let ((olen (string-length old))
          (slen (string-length str)))
      (let lp ((i 0) (result '()))
        (cond
          ((> (+ i olen) slen)
           (apply string-append
             (reverse (cons (substring str i slen) result))))
          ((string=? old (substring str i (+ i olen)))
           (lp (+ i olen) (cons new result)))
          (else
           (lp (+ i 1)
               (if (null? result)
                 (list (string (string-ref str i)))
                 (let ((last (car result)))
                   (cons (string-append last (string (string-ref str i)))
                         (cdr result))))))))))

  (define (shell-escape str)
    (string-append "'"
      (let lp ((i 0) (result '()))
        (if (>= i (string-length str))
          (list->string (reverse result))
          (let ((c (string-ref str i)))
            (if (char=? c #\')
              (lp (+ i 1) (append '(#\' #\\ #\' #\') result))
              (lp (+ i 1) (cons c result))))))
      "'"))

  (define (sql-exec stmt)
    (execute-sqlite (sql-statement-conn stmt)
                    (sql-statement-sql stmt)
                    (sql-statement-params stmt))
    (void))

  (define (sql-eval conn sql . args)
    (execute-sqlite conn sql args)
    (void))

  (define (sql-query stmt)
    ;; Returns raw output as string (JSON from sqlite3 -json)
    (let ((output (execute-sqlite
                    (sql-statement-conn stmt)
                    (sql-statement-sql stmt)
                    (sql-statement-params stmt))))
      (if (string=? output "") '()
        output)))  ;; Caller parses JSON

  (define (sql-eval-query conn sql . args)
    (let ((output (execute-sqlite conn sql args)))
      (if (string=? output "") '()
        output)))

  ;; --- Transactions ---

  (define (sql-txn-begin conn)
    (execute-sqlite conn "BEGIN TRANSACTION" '()))

  (define (sql-txn-commit conn)
    (execute-sqlite conn "COMMIT" '()))

  (define (sql-txn-abort conn)
    (execute-sqlite conn "ROLLBACK" '()))

  (define (raise-sql-error where what . irritants)
    (raise (condition
             (make-sql-error)
             (make-who-condition where)
             (make-message-condition what)
             (make-irritants-condition irritants))))

  ) ;; end library
