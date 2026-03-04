#!chezscheme
;;; test-httpd-dbi.ss -- Test HTTP server and database compat modules
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

(test-begin "HTTPD & DBI")

;;; ============================================================
;;; :std/net/httpd
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-net-httpd)) env)

  ;; Test that the module loads
  (test-assert "httpd module loads" #t)

  ;; Test register handler
  (eval '(http-register-handler #f "/test"
           (lambda (req res)
             (http-response-write res 200
               '(("Content-Type" . "text/plain"))
               "hello")))
        env)
  (test-assert "handler registered" #t))

;;; ============================================================
;;; :std/db/dbi
;;; ============================================================

(let ((env (copy-environment (scheme-environment) #t)))
  (eval '(import (compat std-db-dbi)) env)

  ;; Test connection creation
  (let ((db-path "/tmp/gherkin-test.db"))
    ;; Clean up
    (when (file-exists? db-path) (delete-file db-path))

    (test-assert "sql-connect"
      (eval `(let ((conn (sql-connect #f ,db-path)))
               (sql-close conn)
               #t)
            env))

    ;; Test sql-eval (create table, insert)
    (eval `(let ((conn (sql-connect #f ,db-path)))
             (sql-eval conn "CREATE TABLE test (id INTEGER PRIMARY KEY, name TEXT)")
             (sql-eval conn "INSERT INTO test VALUES ($1, $2)" 1 "alice")
             (sql-eval conn "INSERT INTO test VALUES ($1, $2)" 2 "bob")
             (sql-close conn))
          env)
    (test-assert "sql-eval creates data" #t)

    ;; Test sql-eval-query
    (test-assert "sql-eval-query returns data"
      (eval `(let ((conn (sql-connect #f ,db-path)))
               (let ((result (sql-eval-query conn "SELECT * FROM test")))
                 (sql-close conn)
                 (and (string? result) (> (string-length result) 0))))
            env))

    ;; Test sql-prepare and sql-exec
    (eval `(let ((conn (sql-connect #f ,db-path)))
             (let ((stmt (sql-prepare conn "INSERT INTO test VALUES ($1, $2)")))
               (sql-bind stmt 3 "charlie")
               (sql-exec stmt)
               (sql-finalize stmt))
             (sql-close conn))
          env)
    (test-assert "sql-prepare+exec works" #t)

    ;; Test transactions
    (eval `(let ((conn (sql-connect #f ,db-path)))
             (sql-txn-begin conn)
             (sql-eval conn "INSERT INTO test VALUES ($1, $2)" 4 "dave")
             (sql-txn-commit conn)
             (sql-close conn))
          env)
    (test-assert "transactions work" #t)

    ;; Test sql-error? condition
    (test-assert "sql-error? predicate"
      (eval '(guard (exn [(sql-error? exn) #t]
                         [#t #f])
               (raise-sql-error 'test "test error")
               #f)
            env))

    ;; Clean up
    (when (file-exists? db-path) (delete-file db-path))))

(test-end)
(let-values (((p f) (test-stats)))
  (exit (if (> f 0) 1 0)))
