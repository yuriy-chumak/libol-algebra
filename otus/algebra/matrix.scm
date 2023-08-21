(define-library (otus algebra matrix)

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra init)
   (otus algebra vector)
   (otus algebra shape)
   (otus ffi))

(export

   determinant
   matrix-transpose

   matrix·matrix ; M · M -> M
   matrix·vector ; M · V -> V
   vector·matrix ; V · M -> V

   matrix-product
   hadamard-product

   matrix-power
   matrix-exponential
   matrix-inverse

   ;; cracovian-product
   kronecker-product

   minor-matrix
   cofactor-matrix
   adjoint-matrix ; adjugate
   inverse-matrix
)

(begin
   (import
      (otus algebra macros)
      (otus algebra config))

   ; https://en.wikipedia.org/wiki/Hadamard_product_(matrices)
   (define (hadamard-product A B)
      (assert (equal? (Shape A) (Shape B)) ===> #true)

      (rmap (lambda (a b) (* a b)) A B))

   ; https://en.wikipedia.org/wiki/Determinant
   (define determinant det)


   ; ----------------------------------------------------
   ; Matrix Transpose
   (define matrix-transpose
      (define fast (dlsym algebra "mtranspose"))
      (define lisp (lambda (M)
         (define shape (Shape M))
         (list->vector
            (map (lambda (i)
                  (vector-map (lambda (row)
                        (ref row i))
                     M))
               (iota (second shape) 1)))))

      (lambda (array)
         (cond
            ((vector? array) (lisp array))
            ((tensor? array) (fast array))
            ((scalar? array)       array ) )))

   ; ----------------------------------------------------
   ; https://en.wikipedia.org/wiki/Minor_(linear_algebra)
   (define (minor-matrix A)
      (Index A (lambda (i j) (cofactor A i j))))

   ; https://en.wikipedia.org/wiki/Adjugate_matrix
   ; Присоединённая матрица (союзная, взаимная)
   (define (cofactor-matrix A)
      (Index A (lambda (i j)
         ((if (eq? (band (bxor i j) 1) 0) idf negate)
            (det (minor A i j))))))

   ; Алгебраическое дополнение
   (define (adjoint-matrix A) ; (adjugate M)
      (Index A (lambda (i j)
         ((if (eq? (band (bxor i j) 1) 0) idf negate)
            (det (minor A j i))))))

   ; Обратная матрица
   (define (inverse-matrix A)
      (if (equal? (Shape A) '(1 1))
         [[(/ 1 (ref (ref A 1) 1))]]
      else
         ; naive implementation
         ;; (define d (det A))
         ;; (rmap (lambda (a) (/ a d)) (adjoint-matrix A)))

         ; speedy implementation
         (define adj (adjoint-matrix A))
         (define det (vector-fold (lambda (f a b)
                           (+ f (* a b)))
                        0         ; 1st column of adj. matrix is a row of cofactor matrix
                        (ref A 1) (vector-map (lambda (row) (ref row 1)) adj)))
         (rmap (lambda (a) (/ a det)) adj)))

   (define matrix-inverse inverse-matrix)


   ; ---------------
   ; matrix * matrix
   ; long matrix multiplication version (vector of vectors)
   (define ~mdot (dlsym algebra "mdot"))
   (define (matrix·matrix A B)
      (cond
         ((vector? A) (cond
            ((vector? B)
               ; simplest multiplication implementation:
               ; /rows and columns count limited to 255/
               ;; (map
               ;;    (lambda (row)
               ;;       (apply map
               ;;          (lambda column
               ;;             (apply + (map * row column)))
               ;;          matrix2))
               ;;    matrix1))

               ; real implementation:
               (define m (size A))
               (define n (size (ref A 1)))
               (assert (eq? (size B) n) ===> #true)
               (define q (size (ref B 1)))
               (define (at m x y)
                  (ref (ref m x) y))

               (let mloop ((i m) (rows #null))
                  (if (eq? i 0)
                     (list->vector rows)
                  else
                     (mloop
                        (-- i) ; speedup for (- i 1)
                        (cons
                           (let rloop ((j q) (row #null))
                              ;; (print "j: " j)
                              (if (eq? j 0)
                                 (list->vector row)
                              else
                                 (rloop
                                    (-- j) ; speedup for (- j 1)
                                    (cons
                                       (let loop ((k 1) (c 0))
                                          (if (less? n k) ; speedup for (> k n)
                                             c
                                          else
                                             (loop (++ k) (+ c (* (at A i k) (at B k j))))))
                                       row))))
                           rows)))))
            ((tensor? B)
               (~mdot (imatrix A) B))
            (else
               (runtime-error "Invalid arguments" #n))))
         ((tensor? A) (cond
            ((tensor? B)
               (~mdot A B))
            ((vector? B)
               (~mdot A (imatrix B)))
            (else
               (runtime-error "Invalid arguments" #n))))
         (else
            (runtime-error "Invalid arguments" #n))))

   (define matrix-product matrix·matrix)

   ; (V*M) -> V
   (define (vector·matrix V M)
      ; assert V is a Vector
      (cond
         ((vector? M) (cond
            ((vector? V)
               (define n (size V))
               (define q (size (ref M 1)))
               (assert (eq? q n) ===> #true)
               (define (at m x y)
                  (ref (ref m x) y))

               (let rloop ((i q) (out #null)) ; i - колонка
                  (if (eq? i 0)
                     (list->vector out)
                  else
                     (rloop (-- i)
                        (cons
                           (let loop ((k 1) (c 0)) ; 
                              (if (less? n k)
                                 c
                              else
                                 (loop (++ k) (+ c (* (ref V k) (at M k i))))))
                           out)))))
            ((tensor? V)
               (define len (Size V))
               (cons (list len) (cdr
                  (~mdot (cons (list 1 len) ; vector -> 1-column matrix
                               (cdr V))
                         (imatrix M)))))
            (else
               (runtime-error "unsupported" #n))))
         ((tensor? M) (cond
            ((tensor? V)
               (define len (Size V))
               (cons (list len) (cdr
                  (~mdot (cons (list 1 len) ; vector -> 1-column matrix
                               (cdr V))
                         M))))
            ((vector? V)
               (define len (size V))
               (cons (list len) (cdr
                  (~mdot (cons (list 1 len) ; vector -> 1-column matrix
                               (~create (list len) (list V)))
                         M))))
            (else
               (runtime-error "unsupported" #n))))
         (else
            (runtime-error "Invalid arguments" #n))))

   ; (M*V) -> V
   (define (matrix·vector M V)
      ; assert V is a Vector
      (cond
         ((vector? M) (cond
            ((vector? V)
               (define n (size V))
               (assert (eq? (size M) n) ===> #true)
               (define q (size (ref M 1)))
               (define (at m x y)
                  (ref (ref m x) y))

               (let rloop ((j q) (out #null)) ; j - строка
                  (if (eq? j 0)
                     (list->vector out)
                  else
                     (rloop (-- j)
                        (cons
                           (let loop ((k 1) (c 0)) ; 
                              (if (less? n k)
                                 c
                              else
                                 (loop (++ k) (+ c (* (ref V k) (at M j k))))))
                           out)))))
            ((tensor? V)
               (define len (Size V))
               (cons (list len) (cdr
                           ; вектор -> матрица из одной колонки
                  (~mdot (imatrix M)
                         (cons (list len 1) ; vector -> 1-row matrix
                               (cdr V))))))
            (else
               (runtime-error "unsupported" #n))))
         ((tensor? M) (cond
            ((tensor? V)
               (define len (Size V))
               (cons (list len) (cdr
                  (~mdot M
                         (cons (list len 1) ; vector -> 1-row matrix
                               (cdr V))))))
            ((vector? V)
               (define len (size V))
               (cons (list len) (cdr
                  (~mdot M
                         (cons (list len 1) ; vector -> 1-row matrix
                               (~create (list len) (list V)))))))
            (else
               (runtime-error "unsupported" #n))))
         (else
            (runtime-error "Invalid arguments" #n))))

   ; https://en.wikipedia.org/wiki/Matrix_multiplication#Powers_of_a_matrix
   ; Возведение в степень
   (define (matrix-power A k)
      ;(assert ...
      (case k
         (0 (Index A (lambda (i j) (if (eq? i j) 1 0))))
         (1 A)
         (else ; https://en.wikipedia.org/wiki/Exponentiation_by_squaring
            ; naive algorithm:
            ;;    (let loop ((B A) (k k))
            ;;       (if (eq? k 1)
            ;;          B
            ;;          (loop (matrix-product A B) (-- k)))))))
            ;; 
            ; optimized algorithm:
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

   ;; ; https://en.wikipedia.org/wiki/Cracovian
   ;; ; "Краковское" произведение
   ;; (define (cracovian-product A B)
   ;;    (matrix-product (transpose B) A))

   ; https://en.wikipedia.org/wiki/Kronecker_product
   ; Произведение Кронекера
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

   ; https://en.wikipedia.org/wiki/Matrix_exponential
   ; Экспонента матрицы
   (define (matrix-exponential X)
      #false
   )

))
