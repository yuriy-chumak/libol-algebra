(define-library (otus algebra matrix)

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra vector)
   (otus algebra shape))

(export

   Determinant
   Transpose

   matrix-product
)

(begin

   (define Determinant det)

   (define (Transpose m)
      (define shape (Shape m))
      (list->vector
         (map (lambda (i)
               (vector-map (lambda (row)
                     (ref row i))
                  m))
            (iota (second shape) 1))))


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

))
