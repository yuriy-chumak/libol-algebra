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
)

(begin
   (setq ~copy (dlsym algebra "copy"))
   (setq ~zeros (dlsym algebra "zeros"))
   (setq ~ones (dlsym algebra "ones"))
   (setq ~zerosE (dlsym algebra "zerosE"))
   (setq ~onesE (dlsym algebra "onesE"))


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

   ;; --------------------------------------------------------------
   ; local function
   (define (reset array N ~function)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (make-vector (size array) N))))
         ((tensor? array)
            (~function array))))

   (define (reset! array N ~function!)
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
            (~function! array))))


   (define (zeros array)
      (reset array 0 ~zeros))

   (define (zeros! array)
      (reset! array 0 ~zerosE))

   (define (ones array)
      (reset array 1 ~ones))

   (define (ones! array)
      (reset! array 1 ~onesE))

))
