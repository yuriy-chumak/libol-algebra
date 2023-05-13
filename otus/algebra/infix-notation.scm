(define-library (otus algebra infix-notation)
   (version 0.1)
   (license MIT/LGPL3)
(import
   (otus lisp))
   ;; (otus algebra core))

(export
   infix-notation
   ;; @: ; математический макрос, позволяющий инфиксную нотацию
   ;;    ; кроме того, 2 выступает первым символом специальных математических функций
   ;;    ; (типа @summ, сами названия надо взять из TeX, там они начинаются с \)
)

(begin
   ; todo: add unary function (like -)

   (define-macro infix-notation (lambda args
      ;; (print "args: " args)
      (define priority {
         '+ 2 '- 2
         '* 3 '⨯ 3 '× 3
         '/ 3 ': 3 '÷ 3
         '• 3 ; dot-product
         '^ 4 '** 4 ; power
      })
      (define (operator? op)
         (priority op #false))

      ; без правой ассоциативности мы никуда,
      ; иначе матричная арифметика, например,
      ; может стать очень тяжелой.
      (define (right-operator? op)
         ({
            '* #t ; multiplication
            '^ #t  '** #t ; powers
         } op #f))
      (define (left-operator? op)
         (and (operator? op) (not (right-operator? op))))
      (define (postfix-function? op)
         ({
            '! #t
            '¹ #t  '² #t  '³ #t  '⁴ #t  '⁵ #t
         } op #f))

      ;..
      ; infix -> postfix
      ; в стеке у нас только операторы, функции и левая скобка (в виде символа #eof)
      ; https://en.wikipedia.org/wiki/Shunting_yard_algorithm
      (define-values (stack out)
      (let loop ((queue args) (stack '(#eof)) (out '()))

         ; a right parenthesis (i.e. ")"):
         (if (null? queue)
         then
            (define-values (newstack newout)
               (let subloop ((stack stack) (out out))
                  (if (null? stack)
                     (runtime-error "mismatched parentheses" args)
                  else
                     (define top (car stack))
                     (if (eof? top)
                        (values (cdr stack) out) ; discard "("
                     else
                        (subloop (cdr stack) (cons top out))))))

            (if (null? newstack)
               (values newstack newout)
            else
               (define top (car newstack))
               (if (pair? top) ; префиксная функция?
                  (values (cdr newstack) (cons top newout))
                  (values newstack newout)))

         ; expression arguments
         else
            (define token (car queue))
            (cond
               ((pair? token) ; (...)
                  (define-values (newstack newout) (loop token (cons #eof stack) out))
                  (loop (cdr queue) newstack newout))

               ((null? token) ; ()
                  (define-values (newstack newout) (loop token (cons #eof stack) out))
                  (loop (cdr queue) newstack newout))

               ((number? token)
                  (loop (cdr queue) stack (cons token out)))
               ((string? token)
                  (loop (cdr queue) stack (cons token out)))

               ((eq? token 'unquote)
                  (define-values (newstack newout)
                     (let subloop ((stack stack) (out out))
                        (if (null? stack)
                           stack
                        else
                           (define top (car stack))
                           (if (eof? top)
                              (values stack out)
                           else
                              (subloop (cdr stack) (cons top out))))))
                  (loop (cdr queue) newstack newout))

               ((postfix-function? token)
                  (loop (cdr queue) stack (cons token out)))

               ; todo: vector
               ; todo: handle unary "-"
               ((operator? token) ; binary operator
                  (define-values (newstack newout)
                     (let subloop ((stack stack) (out out))
                        (if (null? stack)
                           stack
                        else
                           (define top (car stack))
                           (if (or
                                 (and
                                    (operator? top)
                                    (> (priority top 0) (priority token 0)))
                                 (and
                                    (left-operator? token)
                                    (= (priority top 0) (priority token 0))) )
                           then
                              (subloop (cdr stack) (cons top out))
                           else
                              (values stack out)))))
                  (loop (cdr queue) (cons token newstack) newout))

               ; special macro (list ...)
               ((eq? token 'list)
                  (loop (list (cons (cadr queue)
                                    (map (lambda (q) (list 'unquote q)) (cddr queue))))
                        (cons (list token) stack) (cons #eof out)))

               ((symbol? token) ; variable or function
                  (if (or
                         (and (not (null? (cdr queue))) ; function with arguments
                              (pair? (car (cdr queue)))
                              (not (eq? (caadr queue) 'unquote)))
                         (and (not (null? (cdr queue))) ; empty function
                              (null? (car (cdr queue)))))
                  then ; function
                     (define arguments
                        (foldr (lambda (x out)
                              ; handle functions in arguments
                              (if (and (pair? x)
                                       (eq? (car x) 'unquote)
                                       (pair? out)
                                       (pair? (car out))
                                       (not (eq? (caar out) 'unquote)))
                                 (cons
                                    (list 'unquote (cadr x) (car out))
                                    (cdr out))
                                 (cons x out)))
                           '()
                           (cadr queue)))
                     (loop (cons
                              arguments
                              (cddr queue))
                           (cons (list token) stack) (cons #eof out))
                  else ; variable
                     (loop (cdr queue) stack (cons token out))))
               (else
                  (print "error"))))))

      (unless (null? stack)
         (runtime-error "invalid infix expression" args))
      ;; (print "out: " (reverse out))

      (define-values (in s-exp)
      (let loop ((in (reverse out)) (stack '()))
         (if (null? in)
            (values in stack)
         else
            (define token (car in))
            (cond
               ((number? token)
                  (loop (cdr in) (cons token stack)))
               ((string? token)
                  (loop (cdr in) (cons token stack)))
               ((eof? token)
                  (define-values (in s-exp)
                     (loop (cdr in) '()))
                  (loop in (cons s-exp stack)))
               ((pair? token) ; function
                  (values (cdr in) (cons (car token) (reverse stack))))
               ((operator? token) ; binary operator
                  (loop (cdr in) (cons (list
                                          token
                                          (cadr stack) (car stack))
                                       (cddr stack))))
               ((postfix-function? token)
                  (loop (cdr in) (cons (list
                                          token
                                          (car stack))
                                       (cdr stack))))
               ((symbol? token)
                  (loop (cdr in) (cons token stack)))
               (else
                  (runtime-error "error" out))))))

      ;; (print "s-exp: " (car s-exp))
      (car s-exp)
   ))
))
