(define-library (otus algebra fold)

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra shape)
   (otus algebra init))

(export
   rfoldr

   ; map an elements by value
   Map
   ; map an elements by index
   Index
)

(begin
   (import
      (otus algebra config))

   (define Map rmap)

   ;; -=( Index )=------------------------
   (define ~index (dlsym algebra "Index"))
   (define (Index F array)
      (cond
         ((vector? array)
            (define (vm array index)
               (if (vector? array)
                  (vector-map vm array
                     (vector-map (lambda (i)
                           (append index (list i)))
                        (Iota (size array) 1)))
               else
                  (apply F index)))
            (vector-map vm array
               (vector-map (lambda (i)
                     (list i))
                  (Iota (size array) 1))))
         ((tensor? array)
            (~index F array))
         (else
            (runtime-error "Index accepts only arrays"))))


   ; -------------------------------------------
   ;(define ~fold (dlsym algebra "Fold"))
   (define rfold
      (case-lambda
         ((f S array)
            (cond
               ((vector? array)
                  (let loop ((S S) (array array))
                     (if (vector? (ref array 1))
                        (vector-fold loop S array)
                     else
                        (vector-fold f S array))))
               (else
                  (runtime-error "TBD"))))
         ((f S array1 array2)
            ; TODO: test all arguments the same size
            ; TODO: if different types - cast to the the first argument type
            (cond
               ((vector? array1)
                  (let loop ((array1 array1) (array2 array2))
                     (if (vector? (ref array1 1))
                        (vector-map loop array1 array2)
                     else
                        (vector-map f array1 array2))))
               (else
                  (runtime-error "TBD"))))
         ((f S . arrays)
            ; TODO: test all arguments the same size
            ; TODO: if different types - cast to the the first argument type
            (cond
               ((vector? (car arrays))
                  (let loop ((arrays arrays))
                     (define (reloop . args) (loop args))
                     (if (vector? (ref (car arrays) 1))
                        (apply vector-map (cons reloop arrays))
                     else
                        (apply vector-map (cons f arrays)))))
               (else
                  (runtime-error "TBD")))) ))


   (define rfoldr
      (case-lambda
         ((f S array)
            (cond
               ((vector? array)
                  (vector->list (Reshape array (list (Size array)))))
               ;;    (let loop ((S S) (array array))
               ;;       (if (vector? (ref array 1))
               ;;          (vector-foldr loop S array)
               ;;       else
               ;;          (vector-foldr f S array))))
               ((tensor? array)
                  (define asize (Size array))
                  (define adata (Reshape array (list asize))) ; make a linear vector (very fast op)
                  (let loop ((S S) (i asize))
                     (if (eq? i 0)
                        S
                        (loop (f (~ref adata i) S) (- i 1)))))
               (else
                  (runtime-error "TBD"))))
      ))

))
