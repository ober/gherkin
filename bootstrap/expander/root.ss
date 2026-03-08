(define *core-syntax-expanders*
  `((%\x23;begin
      top:
      ,core-expand-begin%
      ,core-compile-top-begin%)
    (%\x23;begin-syntax
      top:
      ,core-expand-begin-syntax%
      ,core-compile-top-begin-syntax%)
    (%\x23;begin-foreign
      top:
      ,core-expand-begin-foreign%
      ,core-compile-top-begin-foreign%)
    (%\x23;begin-module top: ,core-expand-begin-module% #f)
    (%\x23;extern
      top:
      ,core-expand-extern%
      ,core-compile-top-extern%)
    (%\x23;import
      top:
      ,core-expand-import%
      ,core-compile-top-import%)
    (%\x23;module
      top:
      ,core-expand-module%
      ,core-compile-top-module%)
    (%\x23;export
      top:
      ,core-expand-export%
      ,core-compile-top-export%)
    (%\x23;provide
      module:
      ,core-expand-provide%
      ,core-compile-top-provide%)
    (%\x23;declare
      module:
      ,core-expand-declare%
      ,core-compile-top-declare%)
    (%\x23;cond-expand special: ,core-expand-cond-expand% #f)
    (%\x23;include special: ,core-expand-include% #f)
    (%\x23;define-values
      define:
      ,core-expand-define-values%
      ,core-compile-top-define-values%)
    (%\x23;define-syntax
      define:
      ,core-expand-define-syntax%
      ,core-compile-top-define-syntax%)
    (%\x23;define-alias
      define:
      ,core-expand-define-alias%
      ,core-compile-top-define-alias%)
    (%\x23;define-runtime
      define:
      ,core-expand-define-runtime%
      ,core-compile-top-define-runtime%)
    (%\x23;begin-annotation
      expr:
      ,core-expand-begin-annotation%
      ,core-compile-top-begin-annotation%)
    (%\x23;lambda
      expr:
      ,core-expand-lambda%
      ,core-compile-top-lambda%)
    (%\x23;case-lambda
      expr:
      ,core-expand-case-lambda%
      ,core-compile-top-case-lambda%)
    (%\x23;let-values
      expr:
      ,core-expand-let-values%
      ,core-compile-top-let-values%)
    (%\x23;letrec-values
      expr:
      ,core-expand-letrec-values%
      ,core-compile-top-letrec-values%)
    (%\x23;letrec*-values
      expr:
      ,core-expand-letrec*-values%
      ,core-compile-top-letrec*-values%)
    (%\x23;let-syntax expr: ,core-expand-let-syntax% #f)
    (%\x23;letrec-syntax expr: ,core-expand-letrec-syntax% #f)
    (%\x23;quote
      expr:
      ,core-expand-quote%
      ,core-compile-top-quote%)
    (%\x23;quote-syntax
      expr:
      ,core-expand-quote-syntax%
      ,core-compile-top-quote-syntax%)
    (%\x23;call
      expr:
      ,core-expand-call%
      ,core-compile-top-call%)
    (%\x23;if expr: ,core-expand-if% ,core-compile-top-if%)
    (%\x23;ref expr: ,core-expand-ref% ,core-compile-top-ref%)
    (%\x23;set!
      expr:
      ,core-expand-setq%
      ,core-compile-top-setq%)
    (%\x23;expression expr: ,core-expand-expression% #f)))

(define *core-macro-expanders*
  `((begin => %\x23;begin) (begin-syntax => %\x23;begin-syntax)
    (begin-foreign => %\x23;begin-foreign)
    (begin-annotation => %\x23;begin-annotation)
    (import => %\x23;import) (module => %\x23;module)
    (export => %\x23;export) (provide => %\x23;provide)
    (declare => %\x23;declare) (include => %\x23;include)
    (cond-expand => %\x23;cond-expand) (quote => %\x23;quote)
    (quote-syntax => %\x23;quote-syntax)
    (let-syntax => %\x23;let-syntax)
    (letrec-syntax => %\x23;letrec-syntax)
    (extern ,macro-expand-extern)
    (define-values (unquote macro-expand-define-values))
    (define-syntax (unquote macro-expand-define-syntax))
    (define-alias ,macro-expand-define-alias)
    (lambda% ,macro-expand-lambda%)
    (case-lambda [unquote macro-expand-case-lambda])
    (let-values (unquote macro-expand-let-values))
    (letrec-values ,macro-expand-letrec-values)
    (letrec*-values ,macro-expand-letrec*-values)
    (if ,macro-expand-if) (%%app => %\x23;call)
    (%%ref => %\x23;ref) (%%begin-module => %\x23;begin-module)
    (_) (...) (else) (=>) (unquote) (unquote-splicing)
    (unsyntax) (unsyntax-splicing)))

(begin
  (define root-context:::init!
    (case-lambda
      [(self)
       (let* ([bind? #t])
         (struct-instance-init! self 'root (make-hash-table-eq))
         (when bind?
           (call-method self 'bind-core-syntax-expanders!)
           (call-method self 'bind-core-macro-expanders!)
           (call-method self 'bind-core-features!)))]
      [(self bind?)
       (struct-instance-init! self 'root (make-hash-table-eq))
       (when bind?
         (call-method self 'bind-core-syntax-expanders!)
         (call-method self 'bind-core-macro-expanders!)
         (call-method self 'bind-core-features!))]))
  (bind-method! root-context::t ':init! root-context:::init!))

(begin
  (define top-context:::init!
    (case-lambda
      [(self)
       (let* ([super #f])
         (let ([super (or super
                          (core-context-root)
                          (make-root-context))])
           (struct-instance-init! self 'top (make-hash-table-eq) super
             #f #f)))]
      [(self super)
       (let ([super (or super
                        (core-context-root)
                        (make-root-context))])
         (struct-instance-init! self 'top (make-hash-table-eq) super
           #f #f))]))
  (bind-method! top-context::t ':init! top-context:::init!))

(begin
  (define expander-context::bind-core-syntax-expanders!
    (case-lambda
      [(self)
       (let* ([bindings *core-syntax-expanders*])
         (for-each
           (lambda (bind)
             (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1695} bind])
               (let ([id (car #{tmp dpuuv4a3mobea70icwo8nvdax-1695})]
                     [rest (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1695})])
                 (core-context-put!
                   self
                   id
                   (make-syntax-binding
                     id
                     id
                     #f
                     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1696} rest])
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-1696})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1697} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1696})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1698} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1696})])
                             (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1697}])
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-1698})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1699} (car #{tl dpuuv4a3mobea70icwo8nvdax-1698})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1700} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1698})])
                                     (let ([expander #{hd dpuuv4a3mobea70icwo8nvdax-1699}])
                                       (if (pair?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1700})
                                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1701} (car #{tl dpuuv4a3mobea70icwo8nvdax-1700})]
                                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1702} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1700})])
                                             (let ([compiler #{hd dpuuv4a3mobea70icwo8nvdax-1701}])
                                               (if (null?
                                                     #{tl dpuuv4a3mobea70icwo8nvdax-1702})
                                                   (begin
                                                     ((let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1703} key])
                                                        (if (equal?
                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                              'top:)
                                                            (begin
                                                              make-top-special-form)
                                                            (if (equal?
                                                                  #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                  'module:)
                                                                (begin
                                                                  make-module-special-form)
                                                                (if (equal?
                                                                      #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                      'define:)
                                                                    (begin
                                                                      make-definition-form)
                                                                    (if (equal?
                                                                          #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                          'special:)
                                                                        (begin
                                                                          make-special-form)
                                                                        (if (equal?
                                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                              'expr:)
                                                                            (begin
                                                                              make-expression-form)
                                                                            (error 'match
                                                                              "no matching clause"
                                                                              #{match-val dpuuv4a3mobea70icwo8nvdax-1703})))))))
                                                       expander
                                                       id
                                                       (or compiler
                                                           core-compile-top-error)))
                                                   (error 'match
                                                     "no matching clause"
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                                           (error 'match
                                             "no matching clause"
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                                   (error 'match
                                     "no matching clause"
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                           (error 'match
                             "no matching clause"
                             #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))))))
           bindings))]
      [(self bindings)
       (for-each
         (lambda (bind)
           (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1695} bind])
             (let ([id (car #{tmp dpuuv4a3mobea70icwo8nvdax-1695})]
                   [rest (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1695})])
               (core-context-put!
                 self
                 id
                 (make-syntax-binding
                   id
                   id
                   #f
                   (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1696} rest])
                     (if (pair?
                           #{match-val dpuuv4a3mobea70icwo8nvdax-1696})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1697} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1696})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-1698} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1696})])
                           (let ([key #{hd dpuuv4a3mobea70icwo8nvdax-1697}])
                             (if (pair?
                                   #{tl dpuuv4a3mobea70icwo8nvdax-1698})
                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1699} (car #{tl dpuuv4a3mobea70icwo8nvdax-1698})]
                                       [#{tl dpuuv4a3mobea70icwo8nvdax-1700} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1698})])
                                   (let ([expander #{hd dpuuv4a3mobea70icwo8nvdax-1699}])
                                     (if (pair?
                                           #{tl dpuuv4a3mobea70icwo8nvdax-1700})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1701} (car #{tl dpuuv4a3mobea70icwo8nvdax-1700})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-1702} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1700})])
                                           (let ([compiler #{hd dpuuv4a3mobea70icwo8nvdax-1701}])
                                             (if (null?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-1702})
                                                 (begin
                                                   ((let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1703} key])
                                                      (if (equal?
                                                            #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                            'top:)
                                                          (begin
                                                            make-top-special-form)
                                                          (if (equal?
                                                                #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                'module:)
                                                              (begin
                                                                make-module-special-form)
                                                              (if (equal?
                                                                    #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                    'define:)
                                                                  (begin
                                                                    make-definition-form)
                                                                  (if (equal?
                                                                        #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                        'special:)
                                                                      (begin
                                                                        make-special-form)
                                                                      (if (equal?
                                                                            #{match-val dpuuv4a3mobea70icwo8nvdax-1703}
                                                                            'expr:)
                                                                          (begin
                                                                            make-expression-form)
                                                                          (error 'match
                                                                            "no matching clause"
                                                                            #{match-val dpuuv4a3mobea70icwo8nvdax-1703})))))))
                                                     expander
                                                     id
                                                     (or compiler
                                                         core-compile-top-error)))
                                                 (error 'match
                                                   "no matching clause"
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                                         (error 'match
                                           "no matching clause"
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                                 (error 'match
                                   "no matching clause"
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))
                         (error 'match
                           "no matching clause"
                           #{match-val dpuuv4a3mobea70icwo8nvdax-1696}))))))))
         bindings)]))
  (bind-method!
    expander-context::t
    'bind-core-syntax-expanders!
    expander-context::bind-core-syntax-expanders!))

(begin
  (define expander-context::bind-core-macro-expanders!
    (case-lambda
      [(self)
       (let* ([bindings *core-macro-expanders*])
         (for-each
           (lambda (bind)
             (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1704} bind])
               (let ([id (car #{tmp dpuuv4a3mobea70icwo8nvdax-1704})]
                     [rest (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1704})])
                 (core-context-put!
                   self
                   id
                   (make-syntax-binding
                     id
                     id
                     #f
                     (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1705} rest])
                       (if (pair?
                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                           (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1706} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                 [#{tl dpuuv4a3mobea70icwo8nvdax-1707} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                             (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-1706}
                                      '=>)
                                 (if (pair?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-1707})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1708} (car #{tl dpuuv4a3mobea70icwo8nvdax-1707})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1709} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1707})])
                                       (let ([core-id #{hd dpuuv4a3mobea70icwo8nvdax-1708}])
                                         (if (null?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-1709})
                                             (begin
                                               (make-rename-macro-expander
                                                 core-id))
                                             (if (pair?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                 (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                                       [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                                   (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                                     (if (null?
                                                           #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                                         (begin
                                                           (make-macro-expander
                                                             proc))
                                                         (if (null?
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                             (begin
                                                               (make-reserved-expander
                                                                 id))
                                                             (error 'match
                                                               "no matching clause"
                                                               #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                                 (if (null?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                     (begin
                                                       (make-reserved-expander
                                                         id))
                                                     (error 'match
                                                       "no matching clause"
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))))
                                     (if (pair?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                               [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                           (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                             (if (null?
                                                   #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                                 (begin
                                                   (make-macro-expander
                                                     proc))
                                                 (if (null?
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                     (begin
                                                       (make-reserved-expander
                                                         id))
                                                     (error 'match
                                                       "no matching clause"
                                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                         (if (null?
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                             (begin
                                               (make-reserved-expander id))
                                             (error 'match
                                               "no matching clause"
                                               #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))
                                 (if (pair?
                                       #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                     (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                           [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                       (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                         (if (null?
                                               #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                             (begin
                                               (make-macro-expander proc))
                                             (if (null?
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                 (begin
                                                   (make-reserved-expander
                                                     id))
                                                 (error 'match
                                                   "no matching clause"
                                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                     (if (null?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                         (begin
                                           (make-reserved-expander id))
                                         (error 'match
                                           "no matching clause"
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                           (if (pair?
                                 #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                     [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                 (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                   (if (null?
                                         #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                       (begin (make-macro-expander proc))
                                       (if (null?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                           (begin
                                             (make-reserved-expander id))
                                           (error 'match
                                             "no matching clause"
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                               (if (null?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                   (begin (make-reserved-expander id))
                                   (error 'match
                                     "no matching clause"
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))))))))
           bindings))]
      [(self bindings)
       (for-each
         (lambda (bind)
           (let ([#{tmp dpuuv4a3mobea70icwo8nvdax-1704} bind])
             (let ([id (car #{tmp dpuuv4a3mobea70icwo8nvdax-1704})]
                   [rest (cdr #{tmp dpuuv4a3mobea70icwo8nvdax-1704})])
               (core-context-put!
                 self
                 id
                 (make-syntax-binding
                   id
                   id
                   #f
                   (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1705} rest])
                     (if (pair?
                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                         (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1706} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                               [#{tl dpuuv4a3mobea70icwo8nvdax-1707} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                           (if (eq? #{hd dpuuv4a3mobea70icwo8nvdax-1706}
                                    '=>)
                               (if (pair?
                                     #{tl dpuuv4a3mobea70icwo8nvdax-1707})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1708} (car #{tl dpuuv4a3mobea70icwo8nvdax-1707})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1709} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1707})])
                                     (let ([core-id #{hd dpuuv4a3mobea70icwo8nvdax-1708}])
                                       (if (null?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1709})
                                           (begin
                                             (make-rename-macro-expander
                                               core-id))
                                           (if (pair?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                               (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                                     [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                                 (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                                   (if (null?
                                                         #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                                       (begin
                                                         (make-macro-expander
                                                           proc))
                                                       (if (null?
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                           (begin
                                                             (make-reserved-expander
                                                               id))
                                                           (error 'match
                                                             "no matching clause"
                                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                               (if (null?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                   (begin
                                                     (make-reserved-expander
                                                       id))
                                                   (error 'match
                                                     "no matching clause"
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))))
                                   (if (pair?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                       (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                             [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                         (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                           (if (null?
                                                 #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                               (begin
                                                 (make-macro-expander
                                                   proc))
                                               (if (null?
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                                   (begin
                                                     (make-reserved-expander
                                                       id))
                                                   (error 'match
                                                     "no matching clause"
                                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                       (if (null?
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                           (begin
                                             (make-reserved-expander id))
                                           (error 'match
                                             "no matching clause"
                                             #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))
                               (if (pair?
                                     #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                   (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                         [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                                     (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                       (if (null?
                                             #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                           (begin
                                             (make-macro-expander proc))
                                           (if (null?
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                               (begin
                                                 (make-reserved-expander
                                                   id))
                                               (error 'match
                                                 "no matching clause"
                                                 #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                                   (if (null?
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                       (begin (make-reserved-expander id))
                                       (error 'match
                                         "no matching clause"
                                         #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                         (if (pair?
                               #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                             (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1710} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1705})]
                                   [#{tl dpuuv4a3mobea70icwo8nvdax-1711} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1705})])
                               (let ([proc #{hd dpuuv4a3mobea70icwo8nvdax-1710}])
                                 (if (null?
                                       #{tl dpuuv4a3mobea70icwo8nvdax-1711})
                                     (begin (make-macro-expander proc))
                                     (if (null?
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                         (begin
                                           (make-reserved-expander id))
                                         (error 'match
                                           "no matching clause"
                                           #{match-val dpuuv4a3mobea70icwo8nvdax-1705})))))
                             (if (null?
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1705})
                                 (begin (make-reserved-expander id))
                                 (error 'match
                                   "no matching clause"
                                   #{match-val dpuuv4a3mobea70icwo8nvdax-1705}))))))))))
         bindings)]))
  (bind-method!
    expander-context::t
    'bind-core-macro-expanders!
    expander-context::bind-core-macro-expanders!))

(begin
  (define expander-context::bind-core-features!
    (lambda (self)
      (define (linux-variant? sys-type)
        (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1712} (let ([#{str dpuuv4a3mobea70icwo8nvdax-1713} (symbol->string
                                                                                                          sys-type)]
                                                                 [#{sep dpuuv4a3mobea70icwo8nvdax-1714} (if (char?
                                                                                                              #\-)
                                                                                                            #\-
                                                                                                            (string-ref
                                                                                                              #\-
                                                                                                              0))])
                                                             (let split-lp ([i 0]
                                                                            [start 0]
                                                                            [acc '()])
                                                               (cond
                                                                 [(= i
                                                                     (string-length
                                                                       #{str dpuuv4a3mobea70icwo8nvdax-1713}))
                                                                  (reverse
                                                                    (cons
                                                                      (substring
                                                                        #{str dpuuv4a3mobea70icwo8nvdax-1713}
                                                                        start
                                                                        i)
                                                                      acc))]
                                                                 [(char=?
                                                                    (string-ref
                                                                      #{str dpuuv4a3mobea70icwo8nvdax-1713}
                                                                      i)
                                                                    #{sep dpuuv4a3mobea70icwo8nvdax-1714})
                                                                  (split-lp
                                                                    (+ i 1)
                                                                    (+ i 1)
                                                                    (cons
                                                                      (substring
                                                                        #{str dpuuv4a3mobea70icwo8nvdax-1713}
                                                                        start
                                                                        i)
                                                                      acc))]
                                                                 [else
                                                                  (split-lp
                                                                    (+ i 1)
                                                                    start
                                                                    acc)])))])
          (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1712})
              (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1715} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1712})]
                    [#{tl dpuuv4a3mobea70icwo8nvdax-1716} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1712})])
                (if (equal? #{hd dpuuv4a3mobea70icwo8nvdax-1715} '"linux")
                    (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1716}])
                      (begin (not (null? rest))))
                    (begin #f)))
              (begin #f))))
      (define (bsd-variant sys-type)
        (let ([sys-type-str (symbol->string sys-type)])
          (let lp ([rest '("openbsd" "netbsd" "freebsd" "darwin")])
            (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1717} rest])
              (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1717})
                  (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1718} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1717})]
                        [#{tl dpuuv4a3mobea70icwo8nvdax-1719} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1717})])
                    (let ([sys #{hd dpuuv4a3mobea70icwo8nvdax-1718}])
                      (let ([rest #{tl dpuuv4a3mobea70icwo8nvdax-1719}])
                        (begin
                          (if (let ([#{pfx dpuuv4a3mobea70icwo8nvdax-1720} sys]
                                    [#{str dpuuv4a3mobea70icwo8nvdax-1721} sys-type-str])
                                (let ([plen (string-length
                                              #{pfx dpuuv4a3mobea70icwo8nvdax-1720})])
                                  (and (<= plen
                                           (string-length
                                             #{str dpuuv4a3mobea70icwo8nvdax-1721}))
                                       (string=?
                                         #{pfx dpuuv4a3mobea70icwo8nvdax-1720}
                                         (substring
                                           #{str dpuuv4a3mobea70icwo8nvdax-1721}
                                           0
                                           plen)))))
                              sys
                              (lp rest))))))
                  (begin #f))))))
      (core-bind-feature! 'gerbil #f 0 self)
      (core-bind-feature! (gerbil-system) #f 0 self)
      (let ([#{match-val dpuuv4a3mobea70icwo8nvdax-1722} (system-type)])
        (if (pair? #{match-val dpuuv4a3mobea70icwo8nvdax-1722})
            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1723} (car #{match-val dpuuv4a3mobea70icwo8nvdax-1722})]
                  [#{tl dpuuv4a3mobea70icwo8nvdax-1724} (cdr #{match-val dpuuv4a3mobea70icwo8nvdax-1722})])
              (let ([sys-cpu #{hd dpuuv4a3mobea70icwo8nvdax-1723}])
                (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1724})
                    (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1725} (car #{tl dpuuv4a3mobea70icwo8nvdax-1724})]
                          [#{tl dpuuv4a3mobea70icwo8nvdax-1726} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1724})])
                      (let ([sys-vendor #{hd dpuuv4a3mobea70icwo8nvdax-1725}])
                        (if (pair? #{tl dpuuv4a3mobea70icwo8nvdax-1726})
                            (let ([#{hd dpuuv4a3mobea70icwo8nvdax-1727} (car #{tl dpuuv4a3mobea70icwo8nvdax-1726})]
                                  [#{tl dpuuv4a3mobea70icwo8nvdax-1728} (cdr #{tl dpuuv4a3mobea70icwo8nvdax-1726})])
                              (let ([sys-type #{hd dpuuv4a3mobea70icwo8nvdax-1727}])
                                (if (null?
                                      #{tl dpuuv4a3mobea70icwo8nvdax-1728})
                                    (begin
                                      (core-bind-feature!
                                        sys-cpu
                                        #f
                                        0
                                        self)
                                      (core-bind-feature!
                                        sys-type
                                        #f
                                        0
                                        self)
                                      (cond
                                        [(linux-variant? sys-type)
                                         (core-bind-feature!
                                           (string->symbol "linux")
                                           #f
                                           0
                                           self)]
                                        [(bsd-variant sys-type) =>
                                         (lambda (sys-prefix)
                                           (core-bind-feature!
                                             (string->symbol "bsd")
                                             #f
                                             0
                                             self)
                                           (core-bind-feature!
                                             (string->symbol sys-prefix)
                                             #f
                                             0
                                             self))]))
                                    (begin (void)))))
                            (begin (void)))))
                    (begin (void)))))
            (begin (void))))
      (when (gerbil-runtime-smp?)
        (core-bind-feature! 'gerbil-smp #f 0 self))))
  (bind-method!
    expander-context::t
    'bind-core-features!
    expander-context::bind-core-features!))

