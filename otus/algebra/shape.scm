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
   Reshape
)

(begin
   (setq ~shape (dlsym algebra "shape"))
   (setq ~reshape (dlsym algebra "reshape"))

   (define (shape array)
      (let loop ((el (ref array 1)) (dim (list (size array))))
         (if (not (vector? el)) then
            (reverse dim)
         else
            (loop (ref el 1) (cons (size el) dim)))))

   (define (Shape array)
      (cond
         ((vector? array) ; builtin array
            (shape array))
         ((tensor? array) ; external data
            (~shape array))))

   (define (Size array)
      (fold * 1 (Shape array)))

   ; -> list
   (define (flatten x tail)
      (if (vector? x)
         (vector-foldr flatten tail x)
      else
         (cons x tail)))

   ; - Reshape -------------------------------------------------------------
   (define (reshape A shapes)
      (define shape (/ (length A) (car shapes)))
      (unless (integer? shape)
         (runtime-error "impossible shape " (car shapes)))
      (if (eq? shape 1)
         A
         (let loop ((row (reverse A)) (tmp #null) (out #null) (n shape))
            (if (eq? n 0)
               (if (null? row)
                  (cons
                     (list->vector (if (null? (cdr shapes)) tmp (reshape tmp (cdr shapes))))
                     out)
               else
                  (loop row #null (cons
                        (list->vector (if (null? (cdr shapes)) tmp (reshape tmp (cdr shapes))))
                        out)
                     shape))
            else
               (loop (cdr row) (cons (car row) tmp) out (- n 1))))))

   (define (Reshape array vector-shape)
      (unless (eq? (fold * 1 (Shape array))
                   (fold * 1 vector-shape))
         (runtime-error "new shape is not applicable" (list (Shape array) " --> " vector-shape)))
      (cond
         ((vector? array) ; builtin array
            (print (flatten array #n))
            (list->vector (reshape (flatten array #n) vector-shape)))
         ((tensor? array) ; external data
            (~reshape array vector-shape))))

))
