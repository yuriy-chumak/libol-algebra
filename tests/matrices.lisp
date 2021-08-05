#!/usr/bin/env ol
(import (otus algebra))

   ;; supports only small matrices
   ;; (define (matrix-multiply matrix1 matrix2)
   ;; (map
   ;;    (lambda (row)
   ;;       (apply map
   ;;          (lambda column
   ;;             (apply + (map * row column)))
   ;;          matrix2))
   ;;    matrix1))

(print (Transpose [[1 2]
                   [4 5]
                   [7 8]]))


(define A [[1 2 3]
           [4 5 6]
           [7 8 9]])
(define B [[7 6 5]
           [3 3 3]
           [2 1 9]])

(print (matrix-product A B))


; test:
(define M 372)
(define N 10)

; [0 1 2 ... 371]
; [1 2 3 ... 372]
; [2 3 4 ... 373]
; ...
; [16 17 ... 387]
(define A (list->vector (map (lambda (i)
                  (list->vector (iota M i)))
            (iota N))))

; [0 1 2 ... 16]
; [1 2 3 ... 17]
; [2 3 4 ... 18]
; ...
; [371 372 ... 387]
(define B (list->vector (map (lambda (i)
                  (list->vector (iota N (+ i i))))
            (iota M))))

(vector-for-each print (matrix-product A B))
;(print (Determinant (matrix-product A B)))
