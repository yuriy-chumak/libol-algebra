(define-library (otus algebra operators)
   (description "Mathematical Operators")

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra scalar)
   (otus algebra vector))

; https://www.compart.com/en/unicode/block/U+2200
(export
   + - * / : ; обычная арифметика (но с векторами)
   • ; скалярное произведение, (·∙)
   ⨯ ; векторное произведение
   ^ ** ; power of (степень числа)
   − ; another "minus" sign

   ; unary operators
   Negate
   Square
   Sqrt Cbrt Root ; roots

   ; binary operators
   Add Sub Mul Pow Div

   ; todo: ÷°∇●○‣◦⦾⦿
   ; todo: sort

   ; дополнительные символы:
   · ; тоже скалярное произведение

   ; folding functions
   Sum
)

(begin

   (define • dot-product)
   (define ⨯ cross-product)
   (define · •) ; interpunct symbol

   ; -=( smart math )=-------------------
   (import (otus ffi))

   ; folding functions
   (define ~sum (dlsym algebra "Sum"))
   (define (Sum a)
      (cond
         ((scalar? a) a)
         ((vector? a) (vector-fold + 0 a))
         ((tensor? a) (~sum a))
      ))

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

   ;; здесь мы допустим некоторые условности,
   ;; в случае "скаляр + вектор" мы расширяем скаляр до вектора
   ;; хотя это и неправильно.

   (define-macro define-unary-function (lambda (name fnc native)
      `(define ,name (lambda (a)
         (define ~fnc (dlsym algebra ,native))
         (cond
            ((scalar? a) (,fnc a))
            ((vector? a) (rmap ,fnc a))
            ((tensor? a) (~fnc a))
         )))
   ))

   (define-macro define-binary-function (lambda (name ol native)
      `(define ,name (lambda (a b)
         (define ~native (dlsym algebra ,native))
         (cond
            ((scalar? a)
               (cond
                  ((scalar? b) (,ol a b)) ; обычная функция
                  ((vector? b) (rmap (lambda (b) (,ol b a)) b)) ; ассоциативность
                  ((tensor? b) (~native b a)))) ; ассоциативность
            ((vector? a)
               (cond
                  ((scalar? b) (vector-map (lambda (a) (,ol a b)) a))
                  ((vector? b) (rmap ,ol a b))
                  ((tensor? b) #f))) ; todo
            ((tensor? a)
               (cond
                  ((scalar? b) (~native a b))
                  ((vector? b) #f) ;todo
                  ((tensor? b) (~native a b))))
         )))
   ))

   (define-unary-function Negate negate "Negate")
   (define-unary-function Square square "Square")
   
   (define-unary-function Sqrt sqrt "Sqrt")
   (define-unary-function Cbrt error "Cbrt")
   (define-unary-function Root error "Root")

   (define-binary-function Add add "Add")
   (define-binary-function Sub sub "Sub")
   (define-binary-function Mul mul "Mul")
   (define-binary-function Pow expt "Pow")
   (define-binary-function Div / "Div")

   ; name: function name
   ; native: "C" function name
   ; unary: unary function
   (define-macro define-left-operator (lambda (name native unary)
      `(define ,name
         (define ~native (dlsym algebra ,native))
         (define binary (lambda (a b)
            (cond
               ((scalar? a)
                  (cond
                     ((scalar? b) (,name a b)) ; regular function
                     ((vector? b) (vector-map (lambda (b) (,name b a)) b))
                     ((tensor? b) (~native b a))))
               ((vector? a)
                  (cond
                     ((scalar? b) (vector-map (lambda (a) (,name a b)) a))
                     ((vector? b) (vector-map (lambda (a b) (,name a b)) a b))
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
            (cond
               ((scalar? a)
                  (cond
                     ((scalar? b) (,name a b)) ; regular function
                     ((vector? b) (vector-map (lambda (b) (,name a b)) b))
                     ((tensor? b) (~native b a))))
               ((vector? a)
                  (cond
                     ((scalar? b) (vector-map (lambda (a) (,name a b)) a))
                     ((vector? b) (vector-map (lambda (a b) (,name a b)) a b))
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
   (define-left-operator / "Div" idf)

   (define ^ Pow)
   (define ** Pow)
   (define : Div)

   (define − -) ; unicode "minus" must be equal to ansi "-" sign
))
