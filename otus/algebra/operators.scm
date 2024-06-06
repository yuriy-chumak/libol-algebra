(define-library (otus algebra operators)
   (description "Mathematical Operators")

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra shape)

   (otus algebra scalar)
   (otus algebra vector)
   (otus algebra matrix))

; https://www.compart.com/en/unicode/block/U+2200
(export
   + - * / : ; обычная арифметика (но с векторами)
   • ; скалярное произведение, dot-product (·∙)
   ⨯ ; векторное произведение
   ^ ** ; power of (степень числа)
   − ; another "minus" sign

   ; unary operators
   Negate Reciprocal
   Square
   Sqrt Cbrt Root ; roots

   ; binary operators
   Add Sub Mul Pow Div Dot

   ; todo: ÷°∇●○‣◦⦾⦿
   ; todo: sort

   ; дополнительные символы:
   • · ; тоже скалярное произведение

   ; folding functions
   Sum
)

(begin
   (import
      (otus algebra macros))

   (define ⨯ cross-product)

   ; -=( smart math )=-------------------
   (import (otus algebra config))

   ; folding functions
   ; todo: create define-fold-function macro
   (define ~sum (dlsym algebra "Sum"))
   (define (Sum a)
      (cond
         ((scalar? a) a)
         ((vector? a) (vector-fold + 0 a))
         ((tensor? a) (~sum a))
      ))

   (define (reciprocal n)
      (divide 1 n))

   ; smart plus
   ;; (define +
   ;;    (define plus (lambda (a b)
   ;;       (if (eq? (type a) type-vector)
   ;;          (if (eq? (type b) type-vector)
   ;;             (vec3+vec3 a b)
   ;;             (runtime-error "invalid vector math: " a " + " b))
   ;;          (+ a b))))
   ;;    (case-lambda
   ;;       ((a b) (plus a b))
   ;;       ((a . bc) (fold plus a bc))
   ;;       (() 0)))

   (define-unary-function Negate negate "Negate")
   (define-unary-function Reciprocal reciprocal "Reciprocal")
   (define-unary-function Square square "Square")
   
   (define-unary-function Sqrt sqrt "Sqrt")
   (define-unary-function Cbrt Unimplemented "Cbrt")
   (define-unary-function Root Unimplemented "Root")

   (define-binary-function Add add "Add")
   (define-binary-function Sub sub "Sub")
   (define-binary-function Mul mul "Mul")
   (define-binary-function Pow expt "Pow")
   (define-binary-function Div divide "Div")

   ; name: function name
   ; native: "C" function name
   ; unary: unary function
   (define-macro define-left-operator (lambda (name native unary)
      `(define ,name
         (define ~native (dlsym algebra ,native))
         (define binary (lambda (a b)
            ; todo: reorder like define-unary-function
            (cond
               ((scalar? a)
                  (cond
                     ((scalar? b) (,name a b)) ; regular function
                     ((vector? b) (rmap (lambda (b) (,name b a)) b))
                     ((tensor? b) (~native b a))))
               ((vector? a)
                  (cond
                     ((scalar? b) (rmap (lambda (a) (,name a b)) a))
                     ((vector? b) (rmap (lambda (a b) (,name a b)) a b))
                     ((tensor? b) #f))) ; todo
               ((tensor? a)
                  (cond
                     ((scalar? b) (~native a b))
                     ((vector? b) #f) ;todo
                     ((tensor? b) (~native a b))))
            )))
         (case-lambda
            ((a) (,unary a))
            ((a b) (binary a b))
            ((a . bc) (fold binary a bc))
            (() 0)))
   ))

   (define-macro define-right-operator (lambda (name native unary)
      `(define ,name
         (define ~native (dlsym algebra ,native))
         (define binary (lambda (a b)
            ; todo: reorder like define-unary-function
            (cond
               ((scalar? a)
                  (cond
                     ((scalar? b) (,name a b)) ; regular function
                     ((vector? b) (rmap (lambda (b) (,name a b)) b))
                     ((tensor? b) (~native b a))))
               ((vector? a)
                  (cond
                     ((scalar? b) (rmap (lambda (a) (,name a b)) a))
                     ((vector? b) (rmap (lambda (a b) (,name a b)) a b))
                     ((tensor? b) #f))) ; todo
               ((tensor? a)
                  (cond
                     ((scalar? b) (~native a b))
                     ((vector? b) #f) ;todo
                     ((tensor? b) (~native a b))))
            )))
         (case-lambda
            ((a) (,unary a))
            ((a b) (binary a b))
            ((a . bc)
                  ; правоассоциативное, поэтому вычисляется справа-налево!
                  (define abc (cons a bc))
                  (define cba (reverse abc))
                  (define c (car cba))
                  (define ba (cdr cba))
                  (define ab (reverse ba))
                  (foldr binary c ab))
            (() 1)))
   ))

   ; smart operators
   (define-left-operator + "Add" idf)
   (define-left-operator - "Sub" Negate)
   (define-right-operator * "Mul" idf)
   (define-left-operator / "Div" Reciprocal)

   (define ^ Pow)
   (define ** Pow)
   (define : Div)

   (define − -) ; unicode "minus" must be equal to ansi "-" sign

   ; ------------------------------
   ; smart dot-product

   ; matrix and vector dot-product
   ; ??? why don't use "~mdot" ?
   (define Dot (lambda (a b)
      (define sa (length (Shape a)))
      (define sb (length (Shape b)))
      (case sa
         (1 (case sb
               (1 (vector·vector a b)) ; dot-product of two horizontal vectors
               (2 (vector·matrix a b)) ; hvector * matrix
               (else (runtime-error "unsupported"))))
         (2 (case sb
               (1 (matrix·vector a b)) ; matrix * vvector (in form of hvector)
               (2 (matrix·matrix a b)) ; matrix-product
               (else (runtime-error "unsupported"))))
         (else
            (runtime-error "unsupported")))))

   (define · Dot) ; interpunct symbol
   (define • Dot)
))
