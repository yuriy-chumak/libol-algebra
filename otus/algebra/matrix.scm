(define-library (otus algebra matrix)

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra init)
   (otus algebra vector)
   (otus algebra shape))

(export

   determinant
   transpose

   matrix-product
   hadamard-product

   matrix-power
   matrix-exponential
   matrix-inverse

   cracovian-product
   kronecker-product

   minor-matrix
   cofactor-matrix
   adjoint-matrix ; adjugate
   inverse-matrix
)

(begin

   ; https://en.wikipedia.org/wiki/Hadamard_product_(matrices)
   (define (hadamard-product A B)
      (assert (equal? (Shape A) (Shape B)) ===> #true)

      (rmap (lambda (a b) (* a b)) A B))

   ; https://en.wikipedia.org/wiki/Determinant
   (define determinant det)

   ; 
   (define (transpose m)
      (define shape (Shape m))
      (list->vector
         (map (lambda (i)
               (vector-map (lambda (row)
                     (ref row i))
                  m))
            (iota (second shape) 1))))

   ; https://en.wikipedia.org/wiki/Minor_(linear_algebra)
   (define (minor-matrix A)
      (Index A (lambda (i j) (cofactor A i j))))

   ; https://en.wikipedia.org/wiki/Adjugate_matrix
   (define (cofactor-matrix A)
      (Index A (lambda (i j)
         ((if (eq? (band (bxor i j) 1) 0) idf negate)
            (det (minor A i j))))))

   (define (adjoint-matrix A) ; (adjugate M)
      (Index A (lambda (i j)
         ((if (eq? (band (bxor i j) 1) 0) idf negate)
            (det (minor A j i))))))

   (define (matrix-inverse A)
      ; naive implementation
      ;; (define d (det A))
      ;; (rmap (lambda (a) (/ a d)) (adjoint-matrix A)))

      ; speedy implementation
      (define adj (adjoint-matrix A))
      (define det (vector-fold (lambda (f a b)
                  (+ f (* a b)))
               0         ; 1st column of adj. matrix is a row of cofactor matrix
               (ref A 1) (vector-map (lambda (row) (ref row 1)) adj)))
      (rmap (lambda (a) (/ a det)) adj))

   (define inverse-matrix matrix-inverse)

   ; short sample matrix multiplication version (list of lists)
   ;; (define (matrix-multiply matrix1 matrix2)
   ;; (map
   ;;    (lambda (row)
   ;;       (apply map
   ;;          (lambda column
   ;;             (apply + (map * row column)))
   ;;          matrix2))
   ;;    matrix1))

   ; long matrix multiplication version (vector of vectors)
   (define (matrix-product A B)
      (define m (size A))
      (define n (size (ref A 1)))
      (assert (eq? (size B) n) ===> #true)
      (define q (size (ref B 1)))
      (define (at m x y)
         (ref (ref m x) y))


      (let mloop ((i m) (rows #null))
         (if (eq? i 0)
            (list->vector rows)
            (mloop
               (-- i) ; speedup for (- i 1)
               (cons
                  (let rloop ((j q) (row #null))
                     (if (eq? j 0)
                        (list->vector row)
                        (rloop
                           (-- j) ; speedup for (- j 1)
                           (cons
                              (let loop ((k 1) (c 0))
                                 (if (less? n k) ; speedup for (> k n)
                                    c
                                    (loop (++ k) (+ c (* (at A i k) (at B k j)))))) ; speedup for (+ k 1)
                              row))))
                  rows)))))

   ; https://en.wikipedia.org/wiki/Matrix_exponential
   (define (matrix-exponential X)
      #false
   )

   ; https://en.wikipedia.org/wiki/Matrix_multiplication#Powers_of_a_matrix
   (define (matrix-power A k)
      ;(assert ...
      (case k
         (0 (Index A (lambda (i j) (if (eq? i j) 1 0))))
         (1 A)
         ;; (else ; naive algorithm
         ;;    (let loop ((B A) (k k))
         ;;       (if (eq? k 1)
         ;;          B
         ;;          (loop (matrix-product A B) (-- k)))))))
         (else ; https://en.wikipedia.org/wiki/Exponentiation_by_squaring
            (define (expt-loop ap p out)
               (cond
                  ((eq? p 0) out)
                  ((eq? (band p 1) 0)
                     (expt-loop (matrix-product ap ap) (>> p 1) out))
                  (else
                     (expt-loop (matrix-product ap ap) (>> p 1) (matrix-product out ap)))))
            (cond
               ((eq? k 0) 1)
               ((eq? k 1) A)
               ((eq? k 2) (matrix-product A A))
               ((or (eq? (type k) type-enum+)
                    (eq? (type k) type-int+))
                  (expt-loop A (sub k 1) A))
               ((or (eq? (type k) type-enum-)
                    (eq? (type k) type-int-))
                  (inverse-matrix (expt-loop A (sub (negate k) 1) A)))
               (else
                  (runtime-error "power is not an integer:" k))))))

   ; https://en.wikipedia.org/wiki/Cracovian
   (define (cracovian-product A B)
      (matrix-product (transpose B) A))

   ;
   (define (submerge v) ; * internal
      (define N (size (ref v 1)))
      (list->vector
         (vector-foldr (lambda (vec f)
               (let loop ((n N) (o f))
                  (if (eq? n 0)
                     o
                  else
                     (loop (-- n) (cons (ref vec n) o)))))
            #null
            v)))

   (define (kronecker-product A B)
      (define C (rmap (lambda (a)
                        (rmap (lambda (b) (* a b)) B))
                  A))
      (submerge
         (let loop ((n (size A)) (o #null))
            (if (eq? n 0)
               (list->vector o)
            else
               (let subloop ((m (size B)) (p #null))
                  (if (eq? m 0)
                     (loop (-- n) (cons (list->vector p) o))
                  else
                     (define a (submerge (vector-map (lambda (c) (ref c m)) (ref C n))))
                     (subloop (-- m)
                        (cons a p))))))))

   ; -------------------------------------------------------------------------
   ; tests
   (assert (let ((M [[-3 2 -5]
                     [-1 0 -2]
                     [3 -4 1]]))
         (matrix-product M (adjoint-matrix M)))  ===> [[-6 0 0]
                                                       [0 -6 0]
                                                       [0 0 -6]])
))
