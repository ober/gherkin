(define __modules (make-hash-table))

(define __load-mx (make-mutex 'loader))

(define __load-cv (make-condition-variable 'loader))

(define __load-path (list))

(define __load-order (make-hash-table))

(define __load-order-next 1)

(define (load-path) __load-path)

(define (add-load-path! . paths)
  (unless (andmap string? paths)
    (error 'gerbil
      "bad load path; expected list of paths"
      paths))
  (for-each
    (lambda (p) (set! __load-path (cons p __load-path)))
    (reverse! paths)))

(begin
  (define (set-load-path! paths)
    (unless (andmap string? paths)
      (error 'gerbil
        "bad load path; expected list of paths"
        paths))
    (set! __load-path paths))
  (define __set-load-path! set-load-path!))

(begin
  (define (load-module modpath)
    (mutex-lock! __load-mx)
    (cond
      [(hash-get __modules modpath) =>
       (lambda (state)
         (cond
           [(or (eq? 'builtin state) (string? state))
            (mutex-unlock! __load-mx)
            state]
           [(eq? 'loading state)
            (mutex-unlock! __load-mx __load-cv)
            (load-module modpath)]
           [(and (pair? state) (eq? (car state) 'error))
            (mutex-unlock! __load-mx)
            (raise (cadr state))]
           [else
            (mutex-unlock! __load-mx)
            (error 'gerbil
              "inernal error; unexpected loading state"
              state)]))]
      [(__find-library-module modpath) =>
       (lambda (path)
         (hash-put! __modules modpath 'loading)
         (mutex-unlock! __load-mx)
         (guard (__exn
                  [#t
                   ((lambda (exn)
                      (mutex-lock! __load-mx)
                      (hash-put! __modules modpath `(error ,exn))
                      (condition-variable-broadcast! __load-cv)
                      (mutex-unlock! __load-mx)
                      (raise exn))
                     __exn)])
           (let ([loaded-path (load path)])
             (mutex-lock! __load-mx)
             (hash-put! __modules modpath loaded-path)
             (unless (hash-get __load-order modpath)
               (hash-put! __load-order modpath __load-order-next)
               (set! __load-order-next (\x31;+ __load-order-next)))
             (condition-variable-broadcast! __load-cv)
             (mutex-unlock! __load-mx)
             loaded-path)))]
      [else
       (mutex-unlock! __load-mx)
       (error 'gerbil "module not found" modpath)]))
  (define __load-module load-module))

(begin
  (define (reload-module! modpath)
    (mutex-lock! __load-mx)
    (cond
      [(hash-get __modules modpath) =>
       (lambda (state)
         (cond
           [(eq? state 'builtin)
            (mutex-unlock! __load-mx)
            (error 'gerbil "cannot reload builtin module" modpath)]
           [(eq? 'loading state)
            (mutex-unlock! __load-mx __load-cv)
            (error 'gerbil "module is still loading")]
           [(string? state)
            (let ([latest-path (__find-library-module modpath)])
              (if (or (equal? (path-extension state) ".scm")
                      (not (equal? state latest-path)))
                  (begin
                    (hash-remove! __modules modpath)
                    (mutex-unlock! __load-mx)
                    (load-module modpath))
                  (mutex-unlock! __load-mx)))]
           [(and (pair? state) (eq? (car state) 'error))
            (hash-remove! __modules modpath)
            (mutex-unlock! __load-mx)
            (load-module modpath)]
           [else
            (mutex-unlock! __load-mx)
            (error 'gerbil
              "inernal error; unexpected loading state"
              state)]))]
      [else (mutex-unlock! __load-mx) (load-module modpath)]))
  (define __reload-module! reload-module!))

(define (__find-library-module modpath)
  (define (find-compiled-file npath)
    (let ([basepath (\x23;\x23;string-append npath ".o")])
      (let lp ([current #f] [n 1])
        (let ([next (\x23;\x23;string-append
                      basepath
                      (number->string n))])
          (if (\x23;\x23;file-exists? next)
              (lp next (\x23;\x23;fx+ n 1))
              current)))))
  (define (find-source-file npath)
    (let ([spath (\x23;\x23;string-append npath ".scm")])
      (and (\x23;\x23;file-exists? spath) spath)))
  (let lp ([rest (load-path)])
    (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-416} rest])
      (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-416})
          (let ([#{hd dpuuv4a3mobea70icwo8nvdax-417} (car #{match-val dpuuv4a3mobea70icwo8nvdax-416})]
                [#{tl dpuuv4a3mobea70icwo8nvdax-418} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-416})])
            (let ([dir #{hd dpuuv4a3mobea70icwo8nvdax-417}])
              (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-418}])
                (begin
                  (let ([npath (gambit-path-expand
                                 modpath
                                 (gambit-path-expand dir))])
                    (cond
                      [(find-compiled-file npath) => path-normalize]
                      [(find-source-file npath) => path-normalize]
                      [else (lp rest)]))))))
          (begin #f)))))

(define (list-modules)
  (mutex-lock! __load-mx)
  (let ([result (hash->list __modules)])
    (mutex-unlock! __load-mx)
    result))

(begin
  (define (module-load-order modpath)
    (mutex-lock! __load-mx)
    (let ([ord (cond
                 [(eq? (hash-get __modules modpath) 'builtin) 0]
                 [(hash-get __load-order modpath)]
                 [else #f])])
      (mutex-unlock! __load-mx)
      (if (exact-integer? ord)
          ord
          (abort!
            (error 'gerbil
              "unknown module load order"
              'module:
              modpath)))))
  (define __module-load-order module-load-order))

