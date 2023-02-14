(define-library (otus algebra scalar)

(import
   (otus lisp)
   (otus algebra core))

(export

   √ ; Square Root
   ∞ ; Positive Infinity
   ^ power ; expt

   ; todo: ∛ ∜ ½ ⅓ ... ⅚ ...₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ ... ¹²³⁴⁵... ０１...
   ; https://www.compart.com/en/unicode/decomposition/%3Csub%3E
   ; https://www.compart.com/en/unicode/decomposition/%3Csuper%3E
   ; https://www.compart.com/en/unicode/block/U+2200
)

(begin
   (define √ sqrt)
   (define ∞ +inf.0)

   (define ^ expt)
   (define power expt)
))
