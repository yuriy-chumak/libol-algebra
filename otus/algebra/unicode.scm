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

   ; https://www.vertex42.com/ExcelTips/unicode-symbols.html#math

   ; https://character.construction/numbers
   ; 🄀🄁🄂🄃🄄🄅🄆🄇🄈🄉🄊

   ; arithmetic
   × ÷
   ; exponentiations
   ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ⁰
   ; roots
   √ ∛ ∜

   ∞ ; positive Infinity
   -∞ ; negative Infinity

   ∑ ; Sum, ⅀

   ; superscript
   ; ⁰ ¹ ² ³ ⁴ ⁵ ⁶ ⁷ ⁸ ⁹ ᵃ ᵇ ᶜ ᵈ ᵉ ᶠ ᵍ ʰ ⁱ ʲ ᵏ ˡ ᵐ ⁿ ᵒ ᵖ ʳ ˢ ᵗ ᵘ ᵛ ʷ ˣ ʸ ᶻ ᵝ ᵞ ᵟ ᵋ ᶿ ᶥ ᶹ ᵠ ᵡ   ⁽ ⁺ ⁻ ⁼ ⁾  ⱽ   ᵎ ᵔ ᵕ ᵙ ᵜ
   ; ⁰ⁱ⁴⁵⁶⁷⁸⁹⁺⁻⁼⁽⁾ⁿ
   ; ᶛ ᶜ ᶝ ᶞ ᶟ ᶠ ᶡ ᶢ ᶣ ᶤ ᶥ ᶦ ᶧ ᶨ ᶩ ᶪ ᶫ ᶬ ᶭ ᶮ ᶯ ᶰ ᶱ ᶲ ᶳ ᶴ ᶵ ᶶ ᶷ ᶸ ᶹ ᶺ ᶻ ᶼ ᶽ ᶾ
   ; ᐜ ᐝ ᐞ ᐟ ᐠ ᐡ ᐢ ᐣ ᐤ ᐥ ᐦ ᐧ ᐨ ᐩ ᐪ ᑉ ᑊ ᑋ ᒃ ᒄ ᒡ ᒢ ᒻ ᒼ ᒽ ᒾ ᓐ ᓑ ᓒ ᓪ ᓫ ᔅ ᔆ ᔇ ᔈ ᔉ ᔊ ᔋ ᔥ ᔾ ᔿ ᕀ ᕁ ᕐ ᕑ ᕝ ᕪ ᕻ ᕯ ᕽ ᖅ ᖕ ᖖ ᖟ ᖦ ᖮ ᗮ ᘁ ᙆ ᙇ ᙚ ᙾ ᙿ
   ; ᣔ ᣕ ᣖ ᣗ ᣘ ᣙ ᣚ ᣛ ᣜ ᣝ ᣞ ᣟ ᣳ ᣴ ᣵ
   ; ᴬ ᴮ ꟲ ᴰ ᴱ ꟳ ᴳ ᴴ ᴵ ᴶ ᴷ ᴸ ᴹ ᴺ ᴼ ᴾ ꟴ ᴿ ᵀ ᵁ ⱽ ᵂ
   ᵀ
   ; subscript
   ; ₀ ₁ ₂ ₃ ₄ ₅ ₆ ₇ ₈ ₉ ₐ ₑ ₕ ᵢ ⱼ ₖ ₗ ₘ ₙ ₒ ₚ ᵣ ₛ ₜ ᵤ ᵥ ₓ ᵦ ᵧ ᵨ ᵩ ᵪ  ₍₊ ₋ ₌ ₎
   ; indices
   ; ₀₁₂₃₄₅₆₇₈₉₊₋₌₍₎
)

(begin
   (define ⅐ 1/7) ; is it superscript or subscript?
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
   (define (⁶ x) (** x 6))
   (define (⁷ x) (** x 7))
   (define (⁸ x) (** x 8))
   (define (⁹ x) (** x 9))
   (define (⁰ x) 1)

   (define √ Sqrt)
   (define ∛ Cbrt) ; todo: make a real cube root as set of three values []
   (define (∜ x) (√ (√ x)))

   (define ∑ Sum)
   (define ᵀ Transpose)
))
