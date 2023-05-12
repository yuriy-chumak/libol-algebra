(define-library (otus algebra roots)
   (description "Mathematical Roots")

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra scalar)
   (otus algebra vector))

; https://www.compart.com/en/unicode/block/U+2200
(export
   Sqrt Cbrt Root
)

(begin
   (import (otus ffi))

   ; ..
   (define ~sqrt (dlsym algebra "Sqrt"))
   (define (Sqrt a)
      (cond
         ((scalar? a) (sqrt a))
         ((vector? a) (vector-map sqrt a))
         ((tensor? a) (~sqrt a))
      ))

   (define Cbrt #f)
   (define Root #f)
))
