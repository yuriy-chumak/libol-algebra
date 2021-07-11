(define-library (otus algebra vector)

(import
   (otus lisp)
   (otus algebra core))

(export

   dot-product    ; скалярное произведение
      ; todo: псевдоскалярное произведение
   cross-product  ; векторное произведение
   triple-product ; смешанное произведение
   ; inner-product ??

   magnitude ; модуль вектора
   square-magnitude ; квадратный модуль вектора
)

(begin

   (define (dot-product a b)
      (vector-fold + 0 (vector-map * a b)))

   ; -- cross-product ----------
   ; удалить n-й элемент вектора (начиная с 1-го)
   ; todo: process errors
   (define (cut vec n)
      (let loop ((l '()) (r (vector->list vec)) (n (-- n)))
         (if (eq? n 0)
            (list->vector (append (reverse l) (cdr r)))
         else
            (loop (cons (car r) l) (cdr r) (-- n)))))

   (define (submatrix m row column)
      (cut (vector-map (lambda (row)
               (cut row column))
            m) row))


   (define (at m i j)
      (ref (ref m i) j))

   (define (det m)
      (cond
         ((eq? (size m) 1)
            (ref (ref m 1) 1))
         ((eq? (size m) 2) ; just speedup for [2 x 2] matrix
            (- (* (at m 1 1) (at m 2 2))
               (* (at m 1 2) (at m 2 1))))
         (else
            (fold + 0
               (map (lambda (s i)
                     ((if (eq? (band i 1) 1) + -) ; sign
                        (* s (det (submatrix m 1 i)))))
                  (vector->list (ref m 1))
                  (iota (size (ref m 1)) 1))))))

   (define (cross-product . args)
      ; todo: size of all vectors should be identical
      (list->vector
         (map (lambda (i)
               ((if (eq? (band i 1) 1) + -) ; sign
                  (det (list->vector (map (lambda (row)
                              (cut row i))
                        args)))))
            (iota (size (car args)) 1))))

   ; -- tripple-product ----------
   (define (triple-product a b c)
      (dot-product a (cross-product b c)))

   (assert (triple-product
      [ 1  2  3]
      [ 1  1  1]
      [ 1  2  1])  ===> 2)
   (assert (triple-product
      [ 1  0  1]
      [-1  2  3]
      [ 0  1 -2])  ===> -8)

   ; ----------------------------------

   (define (magnitude a)
      (sqrt (dot-product a a)))

   (define (square-magnitude a)
      (dot-product a a))

))
