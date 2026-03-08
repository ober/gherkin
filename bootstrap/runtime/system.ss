(begin (define (gerbil-version-string) "546b167fb"))

(define gerbil-system-manifest
  (list
    (cons* "Gerbil" (gerbil-version-string))
    (cons* "Gambit" (system-version-string))))

(begin
  (define __build-manifest gerbil-system-manifest)
  (define (build-manifest) __build-manifest)
  (define (build-manifest-set! v) (set! __build-manifest v)))

(begin
  (define display-build-manifest
    (case-lambda
      [()
       (let* ([manifest __build-manifest]
              [port (current-output-port)])
         (let ([p (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-0})
                    (display #{cut-arg dpuuv4a3mobea70icwo8nvdax-0} port))]
               [l (length manifest)]
               [i 0])
           (for-each
             (lambda (layer)
               (cond
                 [(zero? i) (void)]
                 [(= i 1) (p " on ")]
                 [else (p ", ")])
               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1} layer])
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-2} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1})])
                       (let ([name #{hd dpuuv4a3mobea70icwo8nvdax-2}])
                         (let ([version #{tl dpuuv4a3mobea70icwo8nvdax-3}])
                           (begin (p name) (p " ") (p version)))))
                     (error 'match
                       "no matching clause"
                       #{match-val dpuuv4a3mobea70icwo8nvdax-1})))
               (set! i (+ i 1)))
             manifest)))]
      [(manifest)
       (let* ([port (current-output-port)])
         (let ([p (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-0})
                    (display #{cut-arg dpuuv4a3mobea70icwo8nvdax-0} port))]
               [l (length manifest)]
               [i 0])
           (for-each
             (lambda (layer)
               (cond
                 [(zero? i) (void)]
                 [(= i 1) (p " on ")]
                 [else (p ", ")])
               (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1} layer])
                 (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1})
                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-2} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1})]
                           [#{tl dpuuv4a3mobea70icwo8nvdax-3} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1})])
                       (let ([name #{hd dpuuv4a3mobea70icwo8nvdax-2}])
                         (let ([version #{tl dpuuv4a3mobea70icwo8nvdax-3}])
                           (begin (p name) (p " ") (p version)))))
                     (error 'match
                       "no matching clause"
                       #{match-val dpuuv4a3mobea70icwo8nvdax-1})))
               (set! i (+ i 1)))
             manifest)))]
      [(manifest port)
       (let ([p (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-0})
                  (display #{cut-arg dpuuv4a3mobea70icwo8nvdax-0} port))]
             [l (length manifest)]
             [i 0])
         (for-each
           (lambda (layer)
             (cond
               [(zero? i) (void)]
               [(= i 1) (p " on ")]
               [else (p ", ")])
             (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1} layer])
               (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1})
                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-2} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1})]
                         [#{tl dpuuv4a3mobea70icwo8nvdax-3} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1})])
                     (let ([name #{hd dpuuv4a3mobea70icwo8nvdax-2}])
                       (let ([version #{tl dpuuv4a3mobea70icwo8nvdax-3}])
                         (begin (p name) (p " ") (p version)))))
                   (error 'match
                     "no matching clause"
                     #{match-val dpuuv4a3mobea70icwo8nvdax-1})))
             (set! i (+ i 1)))
           manifest))]))
  (define __display-build-manifest display-build-manifest))

(define (build-manifest/layer layer)
  (let ([l (assoc layer __build-manifest)])
    (if l (list l) (list))))

(define (build-manifest/head) (list (car __build-manifest)))

(begin
  (define build-manifest-string
    (case-lambda
      [()
       (let* ([manifest __build-manifest])
         (call-with-output-string
           (list)
           (lambda (p) (display-build-manifest manifest p))))]
      [(manifest)
       (call-with-output-string
         (list)
         (lambda (p) (display-build-manifest manifest p)))]))
  (define __build-manifest-string build-manifest-string))

(define (gerbil-system-version-string)
  (build-manifest-string gerbil-system-manifest))

(begin
  (define __gerbil-greeting (gerbil-system-version-string))
  (define (gerbil-greeting) __gerbil-greeting)
  (define (gerbil-greeting-set! v)
    (set! __gerbil-greeting v)))

(define (gerbil-system) 'gerbil-gambit)

(define (gerbil-home)
  (or (getenv "GERBIL_HOME" #f) (gambit-path-expand "~~")))

(define (gerbil-path)
  (or (getenv "GERBIL_PATH" #f)
      (gambit-path-expand "~/.gerbil")))

(define __smp? (void))

(define (gerbil-runtime-smp?)
  (when (void? __smp?)
    (set! __smp?
      (and (member
             "--enable-smp"
             (let ([#{str dpuuv4a3mobea70icwo8nvdax-4} (configure-command-string)]
                   [#{sep dpuuv4a3mobea70icwo8nvdax-5} (if (char? #\')
                                                           #\'
                                                           (string-ref
                                                             #\'
                                                             0))])
               (let split-lp ([i 0] [start 0] [acc '()])
                 (cond
                   [(= i
                       (string-length #{str dpuuv4a3mobea70icwo8nvdax-4}))
                    (reverse
                      (cons
                        (substring
                          #{str dpuuv4a3mobea70icwo8nvdax-4}
                          start
                          i)
                        acc))]
                   [(char=?
                      (string-ref #{str dpuuv4a3mobea70icwo8nvdax-4} i)
                      #{sep dpuuv4a3mobea70icwo8nvdax-5})
                    (split-lp
                      (+ i 1)
                      (+ i 1)
                      (cons
                        (substring
                          #{str dpuuv4a3mobea70icwo8nvdax-4}
                          start
                          i)
                        acc))]
                   [else (split-lp (+ i 1) start acc)]))))
           #t)))
  __smp?)

