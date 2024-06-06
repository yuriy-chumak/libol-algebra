(define-library (otus algebra print)

(import
   (otus lisp)
   (otus algebra core) ; is it required?
   (otus algebra))
(export
   Print
)

(begin

   (define (Print array)
      (cond
         ;; ((vector? array) ; builtin array
         ;;    (display array))
         ((or (vector? array)
              (tensor? array)) ; external data
            (define indices (Shape array))
            (let cycle ((index #n)
                        (indices indices)
                        (tail #false))
               (if (null? indices)
               then
                  (display (apply Ref (cons array index)))
                  (unless tail (display " "))
               else
                  (display "[")
                  (define last (car indices))
                  (for-each (lambda (i)
                        (cycle (append index (list i)) (cdr indices) (eq? last i)))
                     (iota last 1))
                  (display "]")
                  (unless tail (display " ")))))
         (else
            (write-simple array))))

   (define Print (lambda args
      (for-each Print args) (newline)))

))
