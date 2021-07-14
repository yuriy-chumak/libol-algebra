#!/usr/bin/env ol
(import (otus algebra))

; Vectors
; -------

; using native lisp syntax, and it's values can be any applicable number or boolean value
(print [1 2 3 4 5])
(print [0 -3 3/7 16+4i 7.12 (inexact 7.12) 123456789876543213546576666777757575757444 +inf.0])

; as a copy of existing vector
(define v [1 2 3 4 5])
(print v)

(print (Copy v))

; as an uninializied vector of N elements
(print (Vector 14))

; as a vector of zeros
(print (Zeros 14))

; as a vector of `1`s
(print (Ones 14))

; as a vector of any applicable repeating value
(print (Fill (Vector 17) -33))

; Matrices
; --------

; using native lisp syntax, and it's values can be any applicable number or boolean value
(print [[1 2 3]
        [4 5 6]
        [7 8 9]])

; as a copy of existing matrix
(define m [[1 2 3] [4 5 6] [7 8 9]])
(print m)
(print (Copy m))

; as a matrix of N same vectors
(print (Matrix [1 2 3] 4))

; as an uninializied matrix of N(rows) * M(columns) elements (it's not guaranteed that the vector will be initialized with zeros, it can be a #false constants for example)
(print (Matrix 3 4))

; as a matrix of zeros, `1`'s
(print (Zeros 3 7))
(print (Ones 1 3))

; as a matrix of zeros (ones) with the same shape of another matrix
(define m (Matrix 2 5))
(print m)
(print (Ones m))

; as a matrix of any applicable repeating value
(print (Fill (Matrix 2 3) -1))

; Tensors
; -------

; using native lisp syntax, and it's values can be any applicable number or boolean value
(define t [[[1 2 3] [4 5 6] [7 8 9]]
           [[2 2 2] [3 3 3] [4 4 4]]])
(print t)
(print (Shape t))

; as an uninializied tensor of N1*N1*...*Nn elements (it's not guaranteed that the vector will be initialized with zeros, it can be a #false constants for example)
(print (Tensor 2 3 2 2))

; as a tensor of zeros, `1`'s
(print (Zeros (Tensor 2 3 2 2)))
(print (Ones (Tensor 2 3 2 2)))

; as a tensor of any applicable repeating value
(print (Fill (Tensor 2 3 2) -1))
