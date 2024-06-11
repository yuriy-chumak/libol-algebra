(define-library (otus algebra init)

(import
   (otus lisp)
   (otus algebra core)
   (otus ffi))

(export
   Copy Copy~

   Zeros Ones
   Zeros! Ones!
   Zeros~ Ones~

   Fill Fill!
   ; todo: Empty ()

   ;random
   Randn Randn~ ; random from the "standard normal" distribution

   Iota Arange Linspace

   Linspace~
)

(begin
   (import
      (otus algebra config))

   (define (Iota . args)
      (list->vector (apply iota args)))

   ; ....

   (setq ~fill (dlsym algebra "Fill"))
   (setq ~fill! (dlsym algebra "FillE"))
   ;; (setq ~zeros (dlsym algebra "zeros"))
   ;; (setq ~ones (dlsym algebra "ones"))
   ;; (setq ~zerosE (dlsym algebra "zerosE"))
   ;; (setq ~onesE (dlsym algebra "onesE"))


   ; inexact copy of any array
   (define Copy~ Array~)

   ; deep copy of array
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


   (define (Fill array N)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-map loop array)
               else
                  (cond
                     ((function? N)
                        (vector-map (lambda (i) (N)) array))
                     ((value? N)
                        (make-vector (size array) N))
                     (else
                        (vector-map (lambda (i) (vm:cast N (type N))) array))))))
         ((tensor? array)
            (cond
               ((inexact? N)
                  (~fill array N))
               ((rational? N)
                  (~fill array (inexact N)))
               ((function? N)
                  (define id (vm:pin (cons
                     (cons fft-float (list ))
                     N)))
                  (define callback (make-callback id))
                  (define tensor (~fill array callback))
                  (vm:unpin id); must free before exit
                  tensor)))))

   (define (Fill! array N)
      (cond
         ((vector? array)
            (let loop ((array array))
               (if (vector? (ref array 1))
                  (vector-for-each loop array)
               else
                  (for-each (lambda (i)
                        (define x (ref array i))
                        (define y (if (function? N) (N) N))
                        (cond
                           ((and (value? x) (value? y))
                              (set-ref! array i y))
                           ((inexact? x)
                              (vm:set! x (if (inexact? y) y (inexact y))))))
                     (iota (size array) 1))))
            array)
         ((tensor? array)
            (cond
               ((inexact? N)
                  (~fill! array N))
               ((rational? N)
                  (~fill! array (inexact N)))
               ((function? N)
                  (define id (vm:pin (cons
                     (cons fft-float (list ))
                     N)))
                  (define callback (make-callback id))
                  (define tensor (~fill! array callback))
                  (vm:unpin id); must free before exit
                  tensor)))))

   ;; --------------------------------------------------------------
   ; * internal function
   ; fill, tensor - default functions
   (define (make-filler tensor N)
      (case-lambda
         (()
            (cond
               ((function? N) (N))
               ((eq? (type N) type-vptr) (N))
               (else N)))
         ((array) ; copy of existing array
            (cond
               ((vector? array)
                  (Fill array N))
               ((tensor? array)
                  (Fill array N))
               ((integer? array)
                  (Fill (tensor array) N))))
         (array
            (Fill (apply tensor array) N))))

   (define zero (if (config 'default-exactness algebra) 0 #i0)) ;?

   (define Zeros (make-filler Array zero))
   (define Zeros~ (if algebra (make-filler Array~ #i0) Zeros))

   (define one (if (config 'default-exactness algebra) 1 #i1)) ;?

   (define Ones (make-filler Array one))
   (define Ones~ (if algebra (make-filler Array~ #i1) Ones))

   (define (Zeros! array) (Fill! array 0))
   (define (Ones! array) (Fill! array 1))

   ;; -=( Randn )=------------------------
   (define ~randn (dlsym algebra "Randn"))

   (import (srfi 27))
   (import (scheme inexact))
   (define (randn)
      (define u (random-real))
      (define r (sqrt (* -2 (log u))))
      (if (eq? (random-integer 2) 1) r (negate r)))

   (define Randn~ (if algebra (make-filler array~ ~randn)
                              (make-filler iarray randn)))
   (define Randn (if (config 'default-exactness algebra)
                              (make-filler earray randn) Randn~))


   ;; --------------------------------------------------------------

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

   ;; -=( Linspace )=---------------------------
   (define ~linspace (dlsym algebra "Linspace"))

   (define (linspace from to count)
      ;; (if (vector? from)
      ;;    (vector-map (lambda (a b)
      ;;          (Linspace a b count)
      ;;    ))
      (define step (/ (- to from) (- count 1)))
      (let loop ((from from) (count count) (p #null))
         (if (zero? count)
            (make-vector (reverse p))
         else
            (loop (+ from step) (- count 1) (cons from p)))))
   (define Linspace (case-lambda
      ((from to count) (linspace from to count))
      ((from to)       (linspace from to 50))
   ))

   (define Linspace~ (if algebra ~linspace Linspace))
   (define Linspace (if (config 'default-exactness) Linspace ~linspace))


))
