#lang racket

(define (quote? x) (equal? x 'quote))
(define (lambda? x) (equal? x 'lambda))
(define (let? x) (equal? x 'let))
(define (if? x) (equal? x 'if))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; could not figure out how to output a!b, etc. for let/lambda bindings :(

(define (lambda-bind arr x y)
  arr)

(define (lambda-var arr bx by x y)
  (cond [(and (null? bx) (null? by))
         (let-bind arr x y)]
        [else (cond [(not (equal? (caar bx) (caar by)))
                     (let ((var (list (list (caar bx) (caar by))
                                      (string->symbol (string-append (symbol->string (caar bx))
                                                                     "!"
                                                                     (symbol->string (caar by)))))))
                       (append arr var))]
                    [else (let-var arr (cdr bx) (cdr by) x y)])]))

(define (let-bind arr x y)
  arr)

(define (let-var arr bx by x y)
  (cond [(and (null? bx) (null? by))
         (let-bind arr x y)]
        [else (cond [(not (equal? (caar bx) (caar by)))
                     (let ((var (list (list (caar bx) (caar by))
                                      (string->symbol (string-append (symbol->string (caar bx))
                                                                     "!"
                                                                     (symbol->string (caar by)))))))
                       (append arr var))]
                    [else (let-var arr (cdr bx) (cdr by) x y)])]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (diff x y)
  (or (xor (quote? x) (quote? y))
      (xor (lambda? x) (lambda? y))
      (xor (let? x) (let? y))
      (xor (if? x) (if? y))))

(define (expr-compare x y)
  (cond [(or (null? x) (null? y)) '()]
        [(and x (not y)) (quasiquote %)]
        [(and (not x) y) (quasiquote (not %))]
        [(equal? x y) x]
        [(cond [(and (and (list? x) (list? y))
                     (equal? (length x) (length y)))
                (cond [(and (quote? (car x)) (quote? (car y)))
                       (quasiquote (if % (unquote x) (unquote y)))]
                      ;[(and (lambda? (and (car x) (car y)))
                      ;      (not (equal? (cdr x) (cdr y))))
                      ;(cons 'lambda (lambda-var '() (cadr x) (cadr y) (cdr x) (cdr y)))]
                      ;[(and (let? (and (car x) (car y)))
                      ;      (not (equal? (cdr x) (cdr y))))
                      ;(cons 'let (let-var '() (cadr x) (cadr y) (cdr x) (cdr y)))]
                      [(diff (car x) (car y)) (quasiquote (if % (unquote x) (unquote y)))]
                      [else (cons (expr-compare (car x) (car y)) (expr-compare (cdr x) (cdr y)))])]
               [else (quasiquote (if % (unquote x) (unquote y)))])]
        [else (quasiquote (if % (unquote x) (unquote y)))]))

(define (test-expr-compare x y)
  (and (equal? (eval x) (eval `(let ((% #t)) ,(expr-compare x y)))))
       (equal? (eval y) (eval `(let ((% #f)) ,(expr-compare x y)))))

(define test-expr-x
  '(+ (cons (quote n) (list b (let ((q 2) (p 3)) (lambda (q) p)) (if y x)))))

(define test-expr-y
  '(+ (cons (quote n) (list c (let ((q 2) (r 3)) (lambda (q) p)) (if x y)))))