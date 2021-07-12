(define-library (otus algebra init)

(import
   (otus lisp)
   (otus algebra core)
   (otus ffi))

(export
   copy
   ; init
   zeros ones
   zeros! ones!
   fill fill!
)

(begin
   (setq ~copy (dlsym algebra "copy"))
   (setq ~fill (dlsym algebra "fill"))
   (setq ~fill! (dlsym algebra "fillE"))
   ;; (setq ~zeros (dlsym algebra "zeros"))
   ;; (setq ~ones (dlsym algebra "ones"))
   ;; (setq ~zerosE (dlsym algebra "zerosE"))
   ;; (setq ~onesE (dlsym algebra "onesE"))


   (define (copy array)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (vm:cast array (type array)))))
         ((tensor? array)
            (~copy array))))

   ; internal
   (define (fill array N)
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

   (define (fill! array N)
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
               (fill array N)
            else
               (fill (evector array) N))) ; TODO: change to etensor
         (args
            (fill (apply ematrix args) N)))) ; TODO: change to etensor

   (define zeros (filler 0))
   (define ones (filler 1))

   (define (zeros! array) (fill! array 0))
   (define (ones! array) (fill! array 1))
))
