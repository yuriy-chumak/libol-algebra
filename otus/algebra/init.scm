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
   (setq ~zeros (dlsym algebra "zeros"))
   (setq ~ones (dlsym algebra "ones"))
   (setq ~zerosE (dlsym algebra "zerosE"))
   (setq ~onesE (dlsym algebra "onesE"))

   ;; --------------------------------------------------------------
   (define (zeros array)
      (case
         ((vector? array)
            #f)
         ((tensor? array)
            (~zeros array))))

   (define (ones array)
      (case (type array)
         ((vector? array)
            #f)
         ((tensor? array)
            (~zeros array))))

   (define (zeros! array)
      #false)

   (define (ones! array)
      #false)

))
