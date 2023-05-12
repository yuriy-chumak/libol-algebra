(define-library (otus algebra unicode)

(import
   (otus lisp)
   (otus algebra))

(export
   ; short fractions
   ⅐ ⅑ ⅒ ⅓ ⅔ ⅕ ⅖ ⅗ ⅘ ⅙ ⅚ ⅛ ⅜ ⅝ ⅞ ⅟
   ½


   ; todo: ½ ⅓ ... ⅚ ...₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎ ... ０１...
   ; https://www.compart.com/en/unicode/decomposition/%3Csub%3E
   ; https://www.compart.com/en/unicode/decomposition/%3Csuper%3E
   ; https://www.compart.com/en/unicode/block/U+2200

   ; arithmetic
   × ÷
   ; exponentiations
   ¹ ² ³ ⁴ ⁵
   ; roots
   √ ∛ ∜

   ∞ ; positive Infinity
   -∞ ; negative Infinity
)

(begin
   (define ⅐ 1/7)
   (define ⅑ 1/9)
   (define ⅒ 1/10)
   (define ⅓ 1/3)
   (define ⅔ 2/3)
   (define ⅕ 1/5)
   (define ⅖ 2/5)
   (define ⅗ 3/5)
   (define ⅘ 4/5)
   (define ⅙ 1/6)
   (define ⅚ 5/6)
   (define ⅛ 1/8)
   (define ⅜ 3/8)
   (define ⅝ 5/8)
   (define ⅞ 7/8)

   (define ½ 1/2)

   (define (⅟ x)
      (/ 1 x))

   ; -=( Regular math )=-----------------
   (define ÷ /)
   (define × *)

   (define ∞ +inf.0)
   (define -∞ -inf.0)

   ; -=( Exponentiations )=--------------
   (define (¹ x) x)
   (define (² x) (** x 2))
   (define (³ x) (** x 3))
   (define (⁴ x) (** x 4))
   (define (⁵ x) (** x 5))

   (define √ Sqrt)
   (define ∛ Cbrt) ; todo: make a real cube root as set of three values []
   (define (∜ x) (√ (√ x)))

))
