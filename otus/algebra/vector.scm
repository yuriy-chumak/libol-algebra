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
   
   ; * internal matrix functions
   minor
   det
   negate
   cofactor
)

(begin

   ; remove n-th element of a vector
   (define (cut vec n)
      (let loop ((l '()) (r (vector->list vec)) (n (-- n)))
         (if (eq? n 0)
            (list->vector (append (reverse l) (cdr r)))
         else
            (loop (cons (car r) l) (cdr r) (-- n)))))

   ; minor matrix of the matrix
   (define (minor m row column)
      (cut (vector-map (lambda (row)
               (cut row column))
            m) row))

   (define (at m i j)
      (ref (ref m i) j))

   ; https://en.wikipedia.org/wiki/Determinant
   ; Определитель матрицы
   (define (det m)
      (cond
         ((eq? (size m) 1)
            (ref (ref m 1) 1))
         ((eq? (size m) 2) ; speedup for [2 x 2] matrix
            (- (* (at m 1 1) (at m 2 2))
               (* (at m 1 2) (at m 2 1))))
         (else
            (fold + 0
               (map (lambda (s i)
                     ((if (eq? (band i 1) 1) idf negate) ; sign
                        (* s (det (minor m 1 i)))))
                  (vector->list (ref m 1))
                  (iota (size (ref m 1)) 1))))))

   ; negate tensor/scalar
   (define /negate negate)
   (define (negate A)
      (if (vector? A)
         (rmap (lambda (a) (negate a)) A)
      else
         (/negate A)))

   ; https://www.cuemath.com/algebra/cofactor-matrix/
   ; submatrix formed by deleting the i th row and j th column
   (define (cofactor A i j)
      ((if (eq? (band (bxor i j) 1) 0) idf negate) (minor A i j)))

   ; -------------------------------------------------------------
   (define (dot-product a b)
      (vector-fold + 0 (vector-map * a b)))
   (define scalar-product dot-product)

   ; -- cross-product ----------
   (define (cross-product a b)
      ; todo: size of all vectors should be identical
      (list->vector
         (map (lambda (i)
               ((if (eq? (band i 1) 1) + -) ; sign
                  (det (list->vector (map (lambda (row)
                              (cut row i))
                        (list a b))))))
            (iota (size a) 1))))

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
