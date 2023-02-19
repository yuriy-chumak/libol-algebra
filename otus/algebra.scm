(define-library (otus algebra)
   ; TODO: ? change to (otus algebra linear)
   (version 0.1)
   (license MIT/LGPL3)
   (keywords (math algebra))
   (description "
      Otus-Lisp algebra library.")

(import
   (otus lisp))
(import
   (otus algebra core)
   (otus algebra shape)
   (otus algebra init)

   (otus algebra scalar)
   (otus algebra vector)
   (otus algebra matrix)

   (otus algebra operators)
   (otus algebra infix-notation))

(export

   ;; целочисленную математику мы будем организовывать силами самого ol
   ;; это будет не быстро, но зато точно. само собой, большие матрицы/вектора/тензоры
   ;; реально обрабатывать не выйдет, но будет легко читаемый код с алгоритмами работы
   ;; (заодно и легче проверяемый)
   ;; точная, но медленная предваряется "e" (exact)
   ;; быстрая, неточная математика предваряется "f" (floating point) или "i" (inexact)

   ;; по умолчанию vector, matrix и tensor сделаны "exact"

   ; create a Vector
   Vector ; exact vector (lisp)
   Vector~ ; inexact vector (c)

   ; create a Matrix
   Matrix ; exact matrix (lisp)
   Matrix~ ; inexact matrix (c)

   ; create a Tensor
   Tensor ; exact tensor (lisp)
   Tensor~ ; inexact tensor (c)

   ; get an element
   Ref
   ; map an elements by value
   Map
   ; map an elements by index
   Index

   Add Sub


   (exports (otus algebra scalar))
   (exports (otus algebra vector))
   (exports (otus algebra matrix))

   (exports (otus algebra shape))
   (exports (otus algebra init))

   (exports (otus algebra operators))
   (exports (otus algebra infix-notation))

   rmap ; Recursive Map, * core, * internal

   ;; print-ftensor

   ;; ; redefine math operators
   ;; + - * /

   ;; ; dot-product
   ;; dot-product
   ;; dot @ ;⋅

   ;; ;× ÷

   ; redefine printer
   ;; print

   ;; ; todo:
   ;; ; >>> # from start to position 6, exclusive, set every 2nd element to 1000
   ;; ; >>> a[:6:2] = 1000
)

(import (otus ffi))
(begin

   (define Vector evector)
   (define Matrix ematrix)
   (define Tensor etensor)

   (define Vector~ (if algebra ivector Vector))
   (define Matrix~ (if algebra imatrix Matrix))
   (define Tensor~ (if algebra itensor Tensor))

   (define (Ref array . index)
      (apply (cond
            ((vector? array) rref)
            ((tensor? array) ~ref))
         (cons array index)))

   (define Map rmap)
   (define (Add array . rest)
      (apply (cond
            ((vector? array) radd)
            ((tensor? array) ~add))
         (cons array rest)))

   (define Sub rsub)
   
   ;; (define + +)
   ;; (define - -)
   ;; (define * *)
   ;; (define / /)

   ;; (define (dot-product a b)
   ;;    #f
   ;; )

   ;; (define dot dot-product)
   ;; (define @ dot)

   (define (pp array dims)
      (if (null? dims)
      then
         (display array)
         (display " ")
      else
         (display "[ ")
         (for-each (lambda (i)
               (pp (ref array i) (cdr dims)))
            (iota (car dims)))
         (display "] ")))

   (define (print-ftensor tensor)
      (define dim (Shape tensor))
      (pp tensor dim))

   (define ::print print)
   (define (print . args)
      (for-each (lambda (arg)
            (cond
               ((tensor? arg)
                  (print-ftensor arg))
               (else
                  (display arg))))
         args)
      (display (string #\newline)))

))
