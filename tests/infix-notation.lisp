(import (otus algebra))

(define A₁ 12)
(define A₂ 7)
(define C 111)

(define (f x) (infix-notation
   A₁ * x * x + A₂ * x + C
))
,expand (infix-notation
   A₁ * x * x + A₂ * sin(x) + C
)

(print (f 14))
