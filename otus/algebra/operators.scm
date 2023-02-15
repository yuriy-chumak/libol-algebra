(define-library (otus algebra operators)
   (description "Mathematical Operators")

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra scalar)
   (otus algebra vector))

; https://www.compart.com/en/unicode/block/U+2200
(export
   • ; скалярное произведение, ·∙•
   ⨯ ; векторное произведение

   ^ ; power of (степень числа)
   √ ; square root (квадратный корень)

   ∞ ; Positive Infinity

   ; todo: ÷°∇
   ; todo: sort
)

(begin

   (define • dot-product)
   (define ⨯ cross-product)

   (define √ sqrt)
   (define ∞ +inf.0)

   (define ^ expt)
))
