; custom random library with predefined seed
; for testing purposes (gives same sequences between different runs)
(define-library (otus random!)
(import
   (otus lisp))
(export
   rand!)

(begin

(define rand!
   (let* ((ss ms (values #xDEAD #xCAFE))
          (seed (band (+ ss ms) #xffffffff))
          (seed (cons (band seed #xffffff) (>> seed 24))))
      (lambda (limit)
         (let*((next (+ (car seed) (<< (cdr seed) 24)))
               (next (+ (* next 1103515245) 12345)))
            (set-car! seed (band     next     #xffffff))
            (set-cdr! seed (band (>> next 24) #xffffff))

            (mod (mod (floor (/ next 65536)) 32768) limit)))))
))
