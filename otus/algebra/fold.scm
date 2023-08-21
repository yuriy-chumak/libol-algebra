(define-library (otus algebra fold)

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra shape)
   (otus ffi))

(export
   rfoldr
)

(begin
   (import
      (otus algebra config))

   (define rfoldr
      (case-lambda
         ((f S array)
            (cond
               ;; ((vector? array)
               ;;    (let loop ((S S) (array array))
               ;;       (if (vector? (ref array 1))
               ;;          (vector-foldr loop S array)
               ;;       else
               ;;          (vector-foldr f S array))))
               ((tensor? array)
                  (define asize (Size array))
                  (define adata (Reshape array (list asize)))
                                  ; make a linear vector (very fast op)
                  (let loop ((S S) (i asize))
                     (if (eq? i 0)
                        S
                        (loop (f (~ref adata i) S) (- i 1)))))
               (else
                  (runtime-error "TBD" f))))
      ))

))
