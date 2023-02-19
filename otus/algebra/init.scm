(define-library (otus algebra init)

(import
   (otus lisp)
   (otus algebra core)
   (otus ffi))

(export
   Copy
   ; init
   Zeros Ones
   Zeros! Ones!
   Fill Fill!
   ; todo: Empty ()
   ;random
   Iota Arange Linspace

   Index

)

(begin
   (setq ~fill (dlsym algebra "fill"))
   (setq ~fill! (dlsym algebra "fillE"))
   ;; (setq ~zeros (dlsym algebra "zeros"))
   ;; (setq ~ones (dlsym algebra "ones"))
   ;; (setq ~zerosE (dlsym algebra "zerosE"))
   ;; (setq ~onesE (dlsym algebra "onesE"))


   (define (Copy array)
      (cond
         ((vector? array) ; deep copy
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (vm:cast array (type array)))))
         ((tensor? array)
            (cons (car array)
                  (vm:cast (cdr array) type-bytevector)))))

   ; internal
   (define (Fill array N)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (if (function? N)
                     (vector-map (lambda (i) (N)) array)
                  else
                     (make-vector (size array) N)))))
         ((tensor? array) ; todo:
            (~fill array N))))

   (define (Fill! array N)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-for-each loop array)
               else
                  (for-each (lambda (i)
                        (set-ref! array i N))
                     (iota (size array) 1))))
            array)
         ((tensor? array)
            (~fill! array N))))

   ;; --------------------------------------------------------------

   ; * internal function
   (define (filler N)
      (case-lambda
         ((array)
            (if (vector? array)
               (Fill array N)
            else
               (Fill (evector array) N))) ; TODO: change to etensor
         (args
            (Fill (apply ematrix args) N)))) ; TODO: change to etensor

   (define Zeros (filler 0))
   (define Ones (filler 1))

   (define (Zeros! array) (Fill! array 0))
   (define (Ones! array) (Fill! array 1))

   ;; --------------------------------------------------------------
   (define (Iota . args)
      (list->vector (apply iota args)))

   ; (Arange count)
   ; (Arange from to)
   ; (Arange from to step)
   (define (Arange from to step)
      (let loop ((from from) (p #null))
         (if (>= from to)
            (make-vector (reverse p))
         else
            (loop (+ from step) (cons from p)))))
   (define Arange (case-lambda
      ((count)
         (Arange 0 count 1))
      ((from to)
         (Arange from to 1))
      ((from to step)
         (Arange from to step))))

   (define (Linspace from to count)
      (define step (/ (- to from) (- count 1)))
      (let loop ((from from) (count count) (p #null))
         (if (zero? count)
            (make-vector (reverse p))
         else
            (loop (+ from step) (- count 1) (cons from p)))))


   (define (Index array F)
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
         (else
            (runtime-error "error" array))))

))
