(define-library (otus algebra scalar)

(import
   (otus lisp)
   (otus algebra core))

(export

   √ ; Square Root
   ∞ ; Positive Infinity

   ; todo: ∛ ∜
   ; https://www.compart.com/en/unicode/block/U+2200
)

(begin
   (define √ sqrt)
   (define ∞ +inf.0)
))
