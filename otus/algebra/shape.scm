(define-library (otus algebra shape)

(import
   (otus lisp)
   (otus algebra core)
   (otus ffi))

(export
   ; The dimension of the array.
   ;  'shape' in numpy
   ; A tuple of integers indicating the size of the array in each dimension.
   ; For a matrix with n rows and m columns, shape will be (n,m).

   shape ; "форма" тензора, его "размерность"
         ; always a list

   ; The number of axes (dimensions) of the array.
   ;  'ndim' in numpy

   ; use `(size (shape .))

   ; todo: reshapings:
   ; todo: repeat_linear, repeat_interleave, expand
   reshape
)

(begin
   (setq ~shape (dlsym algebra "shape"))
   (setq ~reshape (dlsym algebra "reshape"))


   (define (shape array)
      (cond
         ((vector? array)
            (let loop ((el (ref array 1)) (dim (list (size array))))
               (if (not (vector? el))
                  then (reverse dim)
               else
                  (loop (ref el 1) (cons (size el) dim)))))
         ((tensor? array)
            (~shape array))))


   ;; --------------------------------------------------------------
   (define (reshape array new-shape)
      (unless (eq? (fold * 1 (shape array))
                   (fold * 1 new-shape))
         (runtime-error "new shape is not applicable" (list (shape array) " --> " new-shape)))

      (cond
         ((vector? array)
            #f) ;
         ((tensor? array)
            (~reshape array new-shape))))

))
