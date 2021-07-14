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

   Shape ; "форма" тензора, его "размерность"
         ; always a list

   Size  ; The count of all elements in the v/m/t.

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


   (define (Shape array)
      (cond
         ((vector? array) ; builtin array
            (let loop ((el (ref array 1)) (dim (list (size array))))
               (if (not (vector? el)) then
                  (reverse dim)
               else
                  (loop (ref el 1) (cons (size el) dim)))))
         ((tensor? array) ; external data
            (~shape array))))

   (define (Size array)
      (fold * 1 (Shape array)))


   ;; --------------------------------------------------------------
   (define (reshape array new-shape)
      #f)
      ;; (unless (eq? (fold * 1 (shape array))
      ;;              (fold * 1 new-shape))
      ;;    (runtime-error "new shape is not applicable" (list (shape array) " --> " new-shape)))

      ;; (cond
      ;;    ((vector? array)
      ;;       #f) ;
      ;;    ((tensor? array)
      ;;       (~reshape array new-shape))))

))
