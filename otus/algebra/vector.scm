(define-library (otus algebra vector)

(import
   (otus lisp)
   (otus algebra core))

(export

   dot-product ; скалярное произведение
   ; todo: псевдоскалярное произведение
   ;; cross-product ; векторное произведение

   magnitude ; модуль вектора
   square-magnitude ; квадратный модуль вектора
)

(begin
   (define (dot-product a b)
      (vector-fold + 0 (vector-map * a b)))

   (define (magnitude a)
      (sqrt (dot-product a a)))

   (define (square-magnitude a)
      (dot-product a a))

   ;; (define (cross-product a b)
   ;;    #false
   ;; )
))
