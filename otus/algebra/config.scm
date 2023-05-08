; default otus algebra configuration
(define-library (otus algebra config)
(export config)
(import (otus lisp))
(begin
   (define config {
      'default-exactness #T ; Vector, Matrix, Linspace, etc. are EXACT by default
   })))

; todo: make Vector, Matrix, etc... config dependent 
