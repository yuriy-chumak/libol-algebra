(define-library (otus algebra print)

(import
   (otus lisp)
   (otus algebra core)
   (otus ffi))

(export
   Print
)

(begin

   (define (Print array)
      (cond
         ((scalar? array)
            (display array))
         ((vector? array) ; builtin array
            (display array))
         ((tensor? array) ; external data
            (define indices (car array))
            (let cycle ((index #n)
                        (indices indices)
                        (tail #false))
               (if (null? indices)
               then
                  (display (apply ~ref (cons array index)))
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
            (display array))))

   (define Print (lambda args
      (for-each Print args) (newline)))

))
