; default otus algebra configuration
(define-library (otus algebra config)
(export config)
(import (otus lisp))
(begin
   (define config {
      'default-exactness #T ; Vector, Matrix, Linspace, etc. are EXACT by default
      'no-startup-warnings #F ; no wanings for 'libol-algebra not found' and ...
   })))

; todo: make Vector, Matrix, etc... config dependent 
