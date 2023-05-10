(define-library (otus algebra operators)
   (description "Mathematical Operators")

(import
   (otus lisp)
   (otus algebra core)
   (otus algebra scalar)
   (otus algebra vector))

; https://www.compart.com/en/unicode/block/U+2200
(export
   + - * / ; обычная арифметика (но с векторами)
   • ; скалярное произведение, (·∙)
   ⨯ ; векторное произведение

   ^ ** ; power of (степень числа)
   √ ; square root (квадратный корень)

   ∞ ; Positive Infinity

   ; todo: ÷°∇●○‣◦⦾⦿
   ; todo: sort

   ; дополнительные символы:
   · ; тоже скалярное произведение

   Square
   Sum
)

(begin

   (define • dot-product)
   (define ⨯ cross-product)

   (define √ sqrt)
   (define ∞ +inf.0)

   ; 
   (define · •) ; interpunct symbol

   ; -=( smart math )=-------------------
   (import (otus ffi))

   ; ..
   (define ~negate (dlsym algebra "Negate"))
   (define (Negate a)
      (cond
         ((scalar? a) (negate a))
         ((vector? a) (vector-map negate a))
         ((tensor? a) (~negate a))
      ))

   (define ~square (dlsym algebra "Square"))
   (define (Square a)
      (cond
         ((scalar? a) (* a a))
         ((vector? a) (vector-map * a a))
         ((tensor? a) (~square a))
      ))

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

   ; smart plus
   (define-left-operator + "Add" idf)
   (define-left-operator - "Sub" Negate)
   (define-right-operator * "Mul" idf)
   (define-left-operator / "Div" idf)

   (define ~pow (dlsym algebra "Pow"))
   (define (^ a b)
      (cond
         ((scalar? a)
            (cond
               ((scalar? b) (expt a b))
               ;; ((vector? b) (vector-map (lambda (b) (,name a b)) b))
               ;; ((tensor? b) (~native b a))
            ))
         ((vector? a)
            (cond
               ((scalar? b) (vector-map (lambda (a) (expt a b)) a))
               ;; ((vector? b) #f) ; todo
               ;; ((tensor? b) #f) ; todo
            ))
         ((tensor? a)
            (cond
               ((scalar? b) (~pow a b))
               ;; ((vector? b) #f) ; todo
               ;; ((tensor? b) #f) ; todo
            ))
      ))

   (define ** ^)

))
