#!/usr/bin/env ol

(import (otus algebra))
(import (srfi 27)) ; random

(define passes 99)
(define maxdim 10)
(define (rnd)
   (case (random-integer 1)
      (0 (- (random-integer 200000) 100000))
      (else
         0)))
(define (random-dimension)
   (+ (random-integer maxdim) 1))

; Существует нулевая матрица θ такая, что её прибавление к другой матрице A не изменяет A
(for-each (lambda (i)
      (display ".")
      (define M (Fill (Matrix (random-dimension) (random-dimension)) rnd))
      (define θ (Zeros M))
      (assert (Add M θ) ===> M))
   (iota passes))
(print "+")

; Ассоциативность сложения: A+(B+C) = (A+B)+C
(for-each (lambda (i)
      (display ".")
      (define A (Fill (Matrix (random-dimension) (random-dimension)) rnd))
      (define B (Fill A rnd))
      (define C (Fill A rnd))
      (assert (Add A (Add B C)) ===> (Add (Add A B) C)))
   (iota passes))
(print "+")

; Коммутативность сложения: A+B = B+A
(for-each (lambda (i)
      (display ".")
      (define A (Fill (Matrix (random-dimension) (random-dimension)) rnd))
      (define B (Fill A rnd))
      (assert (Add A B) ===> (Add B A)))
   (iota passes))
(print "+")

; Ассоциативность умножения: A(BC)=(AB)C
(for-each (lambda (i)
      (display ".")
      (define M (random-dimension))
      (define A (Fill (Matrix M M) rnd))
      (define B (Fill A rnd))
      (define C (Fill A rnd))
      (assert (matrix-product A (matrix-product B C)) ===> (matrix-product (matrix-product A B) C)))
   (iota passes))
(print "+")

; Дистрибутивность умножения относительно сложения:
(for-each (lambda (i)
      (display ".")
      (define M (random-dimension))
      (define A (Fill (Matrix M M) rnd))
      (define B (Fill A rnd))
      (define C (Fill A rnd))
      ; A(B+C) = AB+AC
      (assert (matrix-product A (Add B C)) ===> (Add (matrix-product A B) (matrix-product A C)))
      ; (B+C)A = BA+CA
      (assert (matrix-product (Add B C) A) ===> (Add (matrix-product B A) (matrix-product C A))))
   (iota passes))
(print "+")

; Свойства операции транспонирования матриц: ('t' means transpose)
(for-each (lambda (i)
      (display ".")
      (define M (+ (random-integer 5) 2))
      (define A (Fill (Matrix M M) rnd))
      (define B (Fill A rnd))
      ; (At)t = A
      (assert (transpose (transpose A)) ===> A)
      ; (AB)t = BtAt
      (assert (transpose (matrix-product A B)) ===> (matrix-product (transpose B) (transpose A)))
      ; (A^-1)t = (At)^-1
      (assert (transpose (matrix-inverse A)) ===> (matrix-inverse (transpose A)))
      ; (A+B)t = At + Bt
      (assert (transpose (Add A B)) ===> (Add (transpose A) (transpose B)))
      ; det A = det At
      (assert (det A) ===> (det (transpose A))))
   (iota passes))
(print "+")

(print "ok.")
