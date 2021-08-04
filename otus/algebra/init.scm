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
   ;random
   Iota

   Index

)

(begin
   (setq ~copy (dlsym algebra "copy"))
   (setq ~fill (dlsym algebra "fill"))
   (setq ~fill! (dlsym algebra "fillE"))
   ;; (setq ~zeros (dlsym algebra "zeros"))
   ;; (setq ~ones (dlsym algebra "ones"))
   ;; (setq ~zerosE (dlsym algebra "zerosE"))
   ;; (setq ~onesE (dlsym algebra "onesE"))


   (define (Copy array)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (vm:cast array (type array))))) ; shallow copy
         ((tensor? array)
            (~copy array))))

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
         ((tensor? array)
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
