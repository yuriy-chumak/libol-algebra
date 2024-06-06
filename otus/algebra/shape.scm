(define-library (otus algebra shape)

(import
   (otus lisp)
   (otus algebra core))

(export
   ; todo: repeat_linear, repeat_interleave, expand
   Reshape
   Flatten ; convert array to 1-dimensional

   ; todo: move to other library
   Padding Shift
)

(begin
   ; -> list

   ; - Flatten -------------------------------------------------------------
   (define (flatten x tail)
      (if (vector? x)
         (vector-foldr flatten tail x)
      else
         (cons x tail)))

   (define (Flatten array)
      (cond
         ((vector? array) ; builtin array
            (list->vector (flatten array #null)))
         ((tensor? array) ; external data
            (cons (list (fold * 1 (car array))) (cdr array)))))


   ; - Reshape -------------------------------------------------------------
   (define (reshape A shapes)
      (unless (integer? (car shapes))
         (runtime-error "impossible shape" (car shapes)))

      (define shape (/ (length A) (car shapes)))
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
         (runtime-error "new shape is not applicable"
            (Shape array) " --> " vector-shape))
      (cond
         ((vector? array) ; builtin array
            (list->vector (reshape (flatten array #n) vector-shape)))
         ((tensor? array) ; external data
            (cons vector-shape (cdr array)))))


   ; -  -------------------------------------------------------------
   ; todo: move to other library
   (define ~padding (dlsym algebra "Padding"))
   (define (padding A)
      (define shape (Shape A))
      (assert (eq? (length shape) 2)) ; must be a matrix
      (define H (first shape)) ; matrix height
      (define W (second shape)) ; matrix width

      ; fast and smart "min"
      (define (min args)
         (let loop ((args args) (min #false))
            (if (null? args)
               (if min min 0)
               (if min
                  (loop (cdr args) (let ((a (car args))) (if (and a (less? a min)) a min)))
                  (loop (cdr args) (car args))))))

      ; padding
      (define left-space
         (min (map (lambda (y)
                  (call/cc (lambda (break)
                     (for-each (lambda (x)
                           (unless (zero? (rref A y x)) (break (- x 1))))
                        (iota W 1 +1)))))
               (iota H 1))))
      (define right-space
         (min (map (lambda (y)
                  (call/cc (lambda (break)
                     (for-each (lambda (x)
                           (unless (zero? (rref A y x)) (break (- W x))))
                        (iota W W -1))
                     W)))
               (iota H 1))))
      (define top-space
         (min (map (lambda (x)
                  (call/cc (lambda (break)
                     (for-each (lambda (y)
                           (unless (zero? (rref A y x)) (break (- y 1))))
                        (iota H 1 +1)))))
               (iota W 1))))
      (define bottom-space
         (min (map (lambda (x)
                  (call/cc (lambda (break)
                     (for-each (lambda (y)
                           (unless (zero? (rref A y x)) (break (- H y))))
                        (iota H H -1)))))
               (iota W 1))))
      ; result
      (list
         (cons (- left-space) right-space)
         (cons (- top-space) bottom-space)
      ))

   (define (Padding array)
      (cond
         ((vector? array) ; builtin array
            (padding array))
         ((tensor? array) ; external data
            (~padding array))))


   ; -----------------------------------
   (define ~shift (dlsym algebra "Shift"))
   (define (shift array dxdy)
      (define shape (Shape array))
      (assert (eq? (length shape) 2)) ; must be a matrix
      (define W (second shape)) ; matrix width
      (define H (first shape)) ; matrix height

      (define horizontal-move (first dxdy))
      (define vertical-move (second dxdy))

      ; matrix copy
      (define out
         (vector-map (lambda (row)
               (vector-map idf row))
            array))

      (cond
         ((< horizontal-move 0)
            (define dx (negate horizontal-move))
            (for-each (lambda (y)
                  (for-each (lambda (x)
                        (set-ref! (ref out y) x (ref (ref out y) (+ x dx))))
                     (iota (- W dx) 1 +1))
                  (for-each (lambda (x)
                        (set-ref! (ref out y) x 0))
                     (iota dx W -1)) )
               (iota H 1)))
         ((> horizontal-move 0)
            (define dx horizontal-move)
            (for-each (lambda (y)
                  (for-each (lambda (x)
                        (set-ref! (ref out y) x (ref (ref out y) (- x dx))))
                     (iota (- W dx) W -1))
                  (for-each (lambda (x)
                        (set-ref! (ref out y) x 0))
                     (iota dx 1 +1)) )
               (iota H 1))) )

      (cond
         ((< vertical-move 0)
            (define dy (negate vertical-move))
            (for-each (lambda (x)
                  (for-each (lambda (y)
                        (set-ref! (ref out y) x (ref (ref out (+ y dy)) x)))
                     (iota (- H dy) 1 +1))
                  (for-each (lambda (y)
                        (set-ref! (ref out y) x 0))
                     (iota dy H -1)) )
               (iota W 1)))
         ((> vertical-move 0)
            (define dy vertical-move)
            (for-each (lambda (x)
                  (for-each (lambda (y)
                        (set-ref! (ref out y) x (ref (ref out (- y dy)) x)))
                     (iota (- H dy) H -1))
                  (for-each (lambda (y)
                        (set-ref! (ref out y) x 0))
                     (iota dy 1 +1)) )
               (iota W 1))) )
      ; result
      out)

   (define (Shift array dxdy)
      (cond
         ((vector? array) ; builtin array
            (shift array dxdy))
         ((tensor? array) ; external data
            (~shift array dxdy))))

   ; todo: Shift!
))
