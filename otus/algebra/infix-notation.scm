(define-library (otus algebra infix-notation)

(import
   (otus lisp)
   (otus algebra core))

(export
   @: ; математический макрос, позволяющий инфиксную нотацию
      ; кроме того, 2 выступает первым символом специальных математических функций (типа @summ, сами названия надо взять из TeX, там они начинаются с \)
)

(begin

   (define-syntax @:
      (syntax-rules (+ - * /)
         ((@: . x)
            ( . x))))

))
