; default otus algebra configuration
(define-library (otus algebra config)
(export config)
(import (otus lisp))
(begin
   (define (getenv str)
      (let ((value (syscall 1016 str)))
         (if (string? value) value "")))

   (define string-ci= string-ci=?)
   (define (bool name default)
      (let ((value (getenv name)))
         (cond
            ((string-eq? value "1") #T)
            ((string-ci= value "True") #T)
            ((string-eq? value "0") #F)
            ((string-ci= value "False") #F)
            (else default))))

   (define config {
      ; exactness of Vector, Matrix, Linspace, etc.
      'default-exactness        ; EXACT by default
            (bool "OTUS_ALGEBRA_DEFAULT_EXACTNESS" #T) 

      ; no warning for 'libol-algebra not found' and others
      'no-startup-warnings      ; show warnings by default
            (bool "OTUS_ALGEBRA_NO_STARTUP_WARNINGS" #F)
   })))

; todo: make Vector, Matrix, etc... config dependent 
