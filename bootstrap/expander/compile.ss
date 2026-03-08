(define (core-compile-top-syntax stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1511} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1512} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1511}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1511})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1513} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1511})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1514} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1513})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1515} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1513})])
              (let ([form #{csc-h dpuuv4a3mobea70icwo8nvdax-1514}])
                (call-method
                  (syntax-local-e form)
                  'compile-top-syntax
                  stx))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1512})))))

(begin
  (define core-expander::compile-top-syntax
    (lambda (self stx)
      (let ([#{with-obj dpuuv4a3mobea70icwo8nvdax-1516} self])
        (let ([K (\x23;\x23;structure-ref
                   #{with-obj dpuuv4a3mobea70icwo8nvdax-1516}
                   3)])
          (cond
            [(stx-source stx) =>
             (lambda (#{cut-arg dpuuv4a3mobea70icwo8nvdax-1517})
               (stx-wrap-source
                 (K stx)
                 #{cut-arg dpuuv4a3mobea70icwo8nvdax-1517}))]
            [else (K stx)])))))
  (bind-method!
    core-expander::t
    'compile-top-syntax
    core-expander::compile-top-syntax))

(define (core-compile-top-error stx)
  (raise-syntax-error 'compile "Cannot compile form" stx))

(define (core-compile-top-begin% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1518} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1519} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1518}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1518})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1520} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1518})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1521} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1520})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1522} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1520})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1522}])
                (cons
                  '%\x23;begin
                  (stx-map core-compile-top-syntax body)))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1519})))))

(define (core-compile-top-begin-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1523} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1524} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1523}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1523})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1525} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1523})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1526} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1525})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1527} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1525})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1527}])
                (cons
                  '%\x23;begin-syntax
                  (parameterize ([current-expander-phi
                                  (fx1+ (current-expander-phi))])
                    (stx-map core-compile-top-syntax body))))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1524})))))

(define (core-compile-top-begin-foreign% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1528} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1529} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1528}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1528})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1530} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1528})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1531} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1530})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1532} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1530})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1532}])
                (cons '%\x23;begin-foreign body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1529})))))

(define (core-compile-top-begin-annotation% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1533} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1534} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1533}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1533})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1535} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1533})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1536} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1535})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1537} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1535})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1537})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1538} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1537})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1539} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1538})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1540} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1538})])
                      (let ([ann #{csc-h dpuuv4a3mobea70icwo8nvdax-1539}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1540})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1541} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1540})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1542} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1541})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1543} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1541})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1542}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1543})
                                      (core-compile-top-syntax expr)
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1534})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1534})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1534}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1534})))))

(define (core-compile-top-import% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1544} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1545} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1544}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1544})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1546} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1544})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1547} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1546})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1548} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1546})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1548}])
                (cons '%\x23;import body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1545})))))

(define (core-compile-top-module% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1549} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1550} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1549}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1549})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1551} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1549})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1552} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1551})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1553} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1551})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1553})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1554} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1553})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1555} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1554})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1556} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1554})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1555}])
                        (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1556}])
                          (cons*
                            '%\x23;module
                            (expander-context-id (syntax-local-e hd))
                            (stx-map core-compile-top-syntax body))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1550}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1550})))))

(define (core-compile-top-export% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1557} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1558} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1557}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1557})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1559} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1557})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1560} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1559})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1561} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1559})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1561}])
                (cons '%\x23;export body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1558})))))

(define (core-compile-top-provide% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1562} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1563} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1562}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1562})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1564} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1562})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1565} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1564})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1566} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1564})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1566}])
                (cons '%\x23;provide body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1563})))))

(define (core-compile-top-extern% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1567} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1568} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1567}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1567})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1569} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1567})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1570} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1569})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1571} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1569})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1571}])
                (cons '%\x23;extern body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1568})))))

(define (core-compile-top-define-values% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1572} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1573} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1572}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1572})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1574} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1572})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1575} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1574})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1576} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1574})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1576})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1577} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1576})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1578} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1577})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1579} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1577})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1578}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1579})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1580} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1579})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1581} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1580})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1582} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1580})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1581}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1582})
                                      (list
                                        '%\x23;define-values
                                        (stx-map
                                          core-compile-top-runtime-bind
                                          hd)
                                        (core-compile-top-syntax expr))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1573})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1573})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1573}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1573})))))

(define (core-compile-top-define-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1583} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1584} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1583}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1583})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1585} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1583})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1586} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1585})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1587} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1585})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1587})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1588} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1587})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1589} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1588})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1590} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1588})])
                      (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1589}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1590})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1591} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1590})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1592} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1591})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1593} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1591})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1592}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1593})
                                      (list
                                        '%\x23;define-syntax
                                        hd
                                        (parameterize ([current-expander-phi
                                                        (fx1+
                                                          (current-expander-phi))])
                                          (core-compile-top-syntax expr)))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1584})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1584})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1584}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1584})))))

(define (core-compile-top-define-alias% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1594} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1595} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1594}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1594})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1596} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1594})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1597} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1596})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1598} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1596})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1598}])
                (cons '%\x23;define-alias body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1595})))))

(define (core-compile-top-define-runtime% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1599} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1600} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1599}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1599})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1601} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1599})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1602} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1601})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1603} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1601})])
              (let ([body #{csc-t dpuuv4a3mobea70icwo8nvdax-1603}])
                (cons '%\x23;define-runtime body))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1600})))))

(define (core-compile-top-declare% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1604} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1605} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1604}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1604})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1606} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1604})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1607} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1606})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1608} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1606})])
              (let ([decls #{csc-t dpuuv4a3mobea70icwo8nvdax-1608}])
                (cons '%\x23;declare decls))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1605})))))

(define (core-compile-top-lambda% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1609} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1610} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1609}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1609})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1611} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1609})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1612} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1611})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1613} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1611})])
              (let ([clause #{csc-t dpuuv4a3mobea70icwo8nvdax-1613}])
                (cons
                  '%\x23;lambda
                  (core-compile-top-lambda-clause clause)))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1610})))))

(define (core-compile-top-lambda-clause stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1614} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1615} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1614}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1614})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1616} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1614})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1617} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1616})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1618} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1616})])
              (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1617}])
                (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1618})
                    (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1619} (syntax-e
                                                                     #{csc-t dpuuv4a3mobea70icwo8nvdax-1618})])
                      (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1620} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1619})]
                            [#{csc-t dpuuv4a3mobea70icwo8nvdax-1621} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1619})])
                        (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-1620}])
                          (if (stx-null?
                                #{csc-t dpuuv4a3mobea70icwo8nvdax-1621})
                              (list
                                (stx-map core-compile-top-runtime-bind hd)
                                (core-compile-top-syntax body))
                              (#{csc-E dpuuv4a3mobea70icwo8nvdax-1615})))))
                    (#{csc-E dpuuv4a3mobea70icwo8nvdax-1615})))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1615})))))

(define (core-compile-top-case-lambda% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1622} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1623} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1622}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1622})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1624} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1622})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1625} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1624})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1626} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1624})])
              (let ([clauses #{csc-t dpuuv4a3mobea70icwo8nvdax-1626}])
                (cons
                  '%\x23;case-lambda
                  (stx-map core-compile-top-lambda-clause clauses)))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1623})))))

(define core-compile-top-let-values%
  (case-lambda
    [(stx)
     (let* ([form '%\x23;let-values])
       (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1627} stx])
         (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1628} (lambda ()
                                                          (raise-syntax-error
                                                            #f
                                                            "Bad syntax; invalid syntax-case clause"
                                                            #{csc-e dpuuv4a3mobea70icwo8nvdax-1627}))])
           (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1627})
               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1629} (syntax-e
                                                                #{csc-e dpuuv4a3mobea70icwo8nvdax-1627})])
                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1630} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1629})]
                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1631} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1629})])
                   (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1631})
                       (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1632} (syntax-e
                                                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1631})])
                         (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1633} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1632})]
                               [#{csc-t dpuuv4a3mobea70icwo8nvdax-1634} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1632})])
                           (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1633}])
                             (if (stx-pair?
                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1634})
                                 (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1635} (syntax-e
                                                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1634})])
                                   (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1636} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1635})]
                                         [#{csc-t dpuuv4a3mobea70icwo8nvdax-1637} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1635})])
                                     (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-1636}])
                                       (if (stx-null?
                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1637})
                                           (list
                                             form
                                             (stx-map
                                               core-compile-top-lambda-clause
                                               hd)
                                             (core-compile-top-syntax
                                               body))
                                           (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628})))))
                                 (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628})))))
                       (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628}))))
               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628})))))]
    [(stx form)
     (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1627} stx])
       (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1628} (lambda ()
                                                        (raise-syntax-error
                                                          #f
                                                          "Bad syntax; invalid syntax-case clause"
                                                          #{csc-e dpuuv4a3mobea70icwo8nvdax-1627}))])
         (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1627})
             (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1629} (syntax-e
                                                              #{csc-e dpuuv4a3mobea70icwo8nvdax-1627})])
               (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1630} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1629})]
                     [#{csc-t dpuuv4a3mobea70icwo8nvdax-1631} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1629})])
                 (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1631})
                     (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1632} (syntax-e
                                                                      #{csc-t dpuuv4a3mobea70icwo8nvdax-1631})])
                       (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1633} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1632})]
                             [#{csc-t dpuuv4a3mobea70icwo8nvdax-1634} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1632})])
                         (let ([hd #{csc-h dpuuv4a3mobea70icwo8nvdax-1633}])
                           (if (stx-pair?
                                 #{csc-t dpuuv4a3mobea70icwo8nvdax-1634})
                               (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1635} (syntax-e
                                                                                #{csc-t dpuuv4a3mobea70icwo8nvdax-1634})])
                                 (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1636} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1635})]
                                       [#{csc-t dpuuv4a3mobea70icwo8nvdax-1637} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1635})])
                                   (let ([body #{csc-h dpuuv4a3mobea70icwo8nvdax-1636}])
                                     (if (stx-null?
                                           #{csc-t dpuuv4a3mobea70icwo8nvdax-1637})
                                         (list
                                           form
                                           (stx-map
                                             core-compile-top-lambda-clause
                                             hd)
                                           (core-compile-top-syntax body))
                                         (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628})))))
                               (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628})))))
                     (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628}))))
             (#{csc-E dpuuv4a3mobea70icwo8nvdax-1628}))))]))

(define (core-compile-top-letrec-values% stx)
  (core-compile-top-let-values% stx '%\x23;letrec-values))

(define (core-compile-top-letrec*-values% stx)
  (core-compile-top-let-values% stx '%\x23;letrec*-values))

(define (core-compile-top-quote% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1638} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1639} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1638}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1638})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1640} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1638})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1641} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1640})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1642} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1640})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1642})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1643} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1642})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1644} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1643})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1645} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1643})])
                      (let ([e #{csc-h dpuuv4a3mobea70icwo8nvdax-1644}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1645})
                            (list '%\x23;quote (syntax->datum e))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1639})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1639}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1639})))))

(define (core-compile-top-quote-syntax% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1646} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1647} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1646}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1646})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1648} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1646})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1649} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1648})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1650} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1648})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1650})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1651} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1650})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1652} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1651})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1653} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1651})])
                      (let ([e #{csc-h dpuuv4a3mobea70icwo8nvdax-1652}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1653})
                            (list
                              '%\x23;quote-syntax
                              (core-quote-syntax e))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1647})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1647}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1647})))))

(define (core-compile-top-call% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1654} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1655} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1654}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1654})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1656} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1654})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1657} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1656})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1658} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1656})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1658})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1659} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1658})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1660} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1659})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1661} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1659})])
                      (let ([rator #{csc-h dpuuv4a3mobea70icwo8nvdax-1660}])
                        (let ([args #{csc-t dpuuv4a3mobea70icwo8nvdax-1661}])
                          (cons*
                            '%\x23;call
                            (core-compile-top-syntax rator)
                            (stx-map core-compile-top-syntax args))))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1655}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1655})))))

(define (core-compile-top-if% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1662} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1663} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1662}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1662})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1664} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1662})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1665} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1664})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1666} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1664})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1666})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1667} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1666})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1668} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1667})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1669} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1667})])
                      (let ([test #{csc-h dpuuv4a3mobea70icwo8nvdax-1668}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1669})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1670} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1669})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1671} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1670})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1672} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1670})])
                                (let ([K #{csc-h dpuuv4a3mobea70icwo8nvdax-1671}])
                                  (if (stx-pair?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1672})
                                      (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1673} (syntax-e
                                                                                       #{csc-t dpuuv4a3mobea70icwo8nvdax-1672})])
                                        (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1674} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1673})]
                                              [#{csc-t dpuuv4a3mobea70icwo8nvdax-1675} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1673})])
                                          (let ([E #{csc-h dpuuv4a3mobea70icwo8nvdax-1674}])
                                            (if (stx-null?
                                                  #{csc-t dpuuv4a3mobea70icwo8nvdax-1675})
                                                (list
                                                  '%\x23;if
                                                  (core-compile-top-syntax
                                                    test)
                                                  (core-compile-top-syntax
                                                    K)
                                                  (core-compile-top-syntax
                                                    E))
                                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1663})))))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1663})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1663})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1663}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1663})))))

(define (core-compile-top-ref% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1676} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1677} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1676}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1676})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1678} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1676})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1679} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1678})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1680} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1678})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1680})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1681} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1680})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1682} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1681})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1683} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1681})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1682}])
                        (if (stx-null?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1683})
                            (if (identifier? id)
                                (list
                                  '%\x23;ref
                                  (core-compile-top-runtime-ref id))
                                (#{csc-E dpuuv4a3mobea70icwo8nvdax-1677}))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1677})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1677}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1677})))))

(define (core-compile-top-setq% stx)
  (let ([#{csc-e dpuuv4a3mobea70icwo8nvdax-1684} stx])
    (let ([#{csc-E dpuuv4a3mobea70icwo8nvdax-1685} (lambda ()
                                                     (raise-syntax-error
                                                       #f
                                                       "Bad syntax; invalid syntax-case clause"
                                                       #{csc-e dpuuv4a3mobea70icwo8nvdax-1684}))])
      (if (stx-pair? #{csc-e dpuuv4a3mobea70icwo8nvdax-1684})
          (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1686} (syntax-e
                                                           #{csc-e dpuuv4a3mobea70icwo8nvdax-1684})])
            (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1687} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1686})]
                  [#{csc-t dpuuv4a3mobea70icwo8nvdax-1688} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1686})])
              (if (stx-pair? #{csc-t dpuuv4a3mobea70icwo8nvdax-1688})
                  (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1689} (syntax-e
                                                                   #{csc-t dpuuv4a3mobea70icwo8nvdax-1688})])
                    (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1690} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1689})]
                          [#{csc-t dpuuv4a3mobea70icwo8nvdax-1691} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1689})])
                      (let ([id #{csc-h dpuuv4a3mobea70icwo8nvdax-1690}])
                        (if (stx-pair?
                              #{csc-t dpuuv4a3mobea70icwo8nvdax-1691})
                            (let ([#{csc-p dpuuv4a3mobea70icwo8nvdax-1692} (syntax-e
                                                                             #{csc-t dpuuv4a3mobea70icwo8nvdax-1691})])
                              (let ([#{csc-h dpuuv4a3mobea70icwo8nvdax-1693} (car #{csc-p dpuuv4a3mobea70icwo8nvdax-1692})]
                                    [#{csc-t dpuuv4a3mobea70icwo8nvdax-1694} (cdr #{csc-p dpuuv4a3mobea70icwo8nvdax-1692})])
                                (let ([expr #{csc-h dpuuv4a3mobea70icwo8nvdax-1693}])
                                  (if (stx-null?
                                        #{csc-t dpuuv4a3mobea70icwo8nvdax-1694})
                                      (if (identifier? id)
                                          (list
                                            '%\x23;set!
                                            (core-compile-top-runtime-ref
                                              id)
                                            (core-compile-top-syntax expr))
                                          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1685}))
                                      (#{csc-E dpuuv4a3mobea70icwo8nvdax-1685})))))
                            (#{csc-E dpuuv4a3mobea70icwo8nvdax-1685})))))
                  (#{csc-E dpuuv4a3mobea70icwo8nvdax-1685}))))
          (#{csc-E dpuuv4a3mobea70icwo8nvdax-1685})))))

(define (core-compile-top-runtime-ref id)
  (cond [(resolve-identifier id) => &binding-id] [else id]))

(define (core-compile-top-runtime-bind hd)
  (and (identifier? hd) (core-compile-top-runtime-ref hd)))

