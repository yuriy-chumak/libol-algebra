Matrices
========

Matrix is a two-dimensional array arranged in rows. Vector of vectors, in other words.  
Ol's matrices are in row-major order.

TOC
---
- [Creation](#creation)
- [Info](#matrix-info)
- [Mapping functions](#mapping-functions)
- [Matrix products](#matrix-products)
- [Other functions](#other-functions)

Note: The output in examples may be reformatted to make it more readable.

Creation
--------

A Matrix can be declared as a vector of vectors. Same rules as a [vector creation](vectors.md#creation) are applicable.

* using native Ol syntax
  ```scheme
  ; short notation,
  ; we'll use such notation widely
  > [ [1 2 3]
      [4 5 6]
      [7 8 9] ]
  #(#(1 2 3) #(4 5 6) #(7 8 9))

* using `Matrix` function
  ```scheme
  ; uninializied matrix of 7 rows and 3 columns,
  ; it's not guaranteed that the matrix will be initialized with zeros.
  > (Matrix 3 7)
  #(#(0 0 0 0 0 0 0) #(0 0 0 0 0 0 0) #(0 0 0 0 0 0 0))

  ; fast (inexact) math matrix (if libol-algebra.so loaded),
  ;  otherwise regular Matrix type used.
  ; it's not guaranteed that the matrix will be initialized with zeros.
  > (Matrix~ 2 3)
  ((2 3) . #u8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))

  ; inializied matrix of any applicable repeating row
  > (Matrix 4 [1 2 3])
  #(#(1 2 3)
    #(1 2 3)
    #(1 2 3)
    #(1 2 3))

  ; fast matrix of a repeating row
  > (Matrix~ 2 [1 2 3])
  ((2 3) . #u8(0 0 128 63 0 0 0 64 0 0 64 64 0 0 128 63 0 0 0 64 0 0 64 64))

  ; fast (inexact) version of a regular matrix
  > (Matrix~ [[1 2]
              [3 4]])
  ((2 2) . #u8(0 0 128 63 0 0 0 64 0 0 64 64 0 0 128 64))
  ```

  ```scheme
  ; Scheme and Ol notations are available, sure
  > (vector
       (vector 1 2 3)
       (vector 4 5 6)
       (vector 7 8 9))
  #(#(1 2 3) #(4 5 6) #(7 8 9))
  ```

* using infix-notation
  ```scheme
  > (infix-notation
       [ [1,2,3],
         [4,5,6],
         [7,8,9] ])
  #(#(1 2 3) #(4 5 6) #(7 8 9))
  ```

* as a matrix of `Zeros`
  ```scheme
  > (Zeros 3 4)
  #(#(0 0 0 0) #(0 0 0 0) #(0 0 0 0))

  > (Zeros~ 2 3)
  ((2 3) . #u8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))

  > (Zeros~ 2 [3 4 5])
  ((2 3) . #u8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))

  > (Zeros~ (Matrix 2 2))
  #(#(0.0 0.0) #(0.0 0.0))
  ```

* as a matrix of `Ones`
  ```scheme
  > (Ones 2 7)
  #(#(1 1 1 1 1 1 1) #(1 1 1 1 1 1 1))

  > (Ones~ 3 2)
  ((3 2) . #u8(0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63))

  > (Ones~ (Matrix 2 2))
  #(#(1.0 1.0) #(1.0 1.0))
  ```

* as a `Copy` of existing matrix
  ```scheme
  > (define M₁ [[1 2 3] [4 5 6] [7 8 9]])

  > (Copy M₁)
  #(#(1 2 3) #(4 5 6) #(7 8 9))
  ```

* as a copy of existing matrix using [matrix mapping functions](#mapping-functions)

* as a `Reshape` of consecutive values, using `Iota`, `Arange`, or `Linspace` functons
  ```scheme
  ; from 0 with step 1
  > (Reshape (Iota 12 1) '(3 4))
  #(#(1 2 3 4) #(5 6 7 8) #(9 10 11 12))

  ; from 0 to 4 with step 1
  > (Reshape (Arange 4) '(2 2))
  #(#(0 1) #(2 3))

  ; 6 elements from 2 to 3
  > (Reshape (Linspace 2 3 12) '(4 3))
  #(#(2 23/11 24/11) #(25/11 26/11 27/11) #(28/11 29/11 30/11) #(31/11 32/11 3))

  ; 
  > (Reshape (Ones~ 6) '(3 2))
  ((3 2) . #u8(0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63 0 0 128 63))
  ```

Matrix Info
-----------

* `Shape` (size of a matrix)
  ```scheme
  > (Shape [[1 2] [3 4] [5 6]])
  (3 2)

  > (Shape (Matrix 112 77))
  (112 77)
  ```

* `Size` (number of elements in a matrix)
  ```scheme
  > (Size (Matrix 112 77))
  8624
  ```

* `Ref`erencing matrix elements, counting starts from 1
  ```scheme
  > (define M [
       [1  2  3  4]
       [5  6  7  8]
       [9 10 11 12]
    ])

  > (Ref M 1)
  #(1 2 3 4)

  > (Ref M 2 3)
  7

  > (Ref M -1)
  #(9 10 11 12)

  > (Ref M -3 -2)
  3

  ; incorrect indexing examples
  ; (#false is a common error indicator)
  > (Ref M 17)
  #false

  > (Ref M 17 2)
  #false

  > (Ref M -9)
  #false
  ```

Mapping Functions
-----------------

* make a same dimensional matrix with any applicable repeating value
  ```scheme
  > (Fill (Matrix 3 4) -1)
  #(#(-1 -1 -1 -1) #(-1 -1 -1 -1) #(-1 -1 -1 -1))
  ```

* make a same dimensional matrix with dynamically computed values
  ```scheme
  > (import (otus random!))
  > (define (rand-i123) (rand! 100))

  > (Fill (Matrix 3 3) rand-i123)
  #(#(5 69 15) #(83 69 14) #(74 22 25))
  ```

* make a same dimensional matrix with dynamically computed values, based on a matrix element indices
  ```scheme
  > (Index (Matrix 4 4) (lambda (i j) (if (= i j) 1 0)))
  #(#(1 0 0 0)
    #(0 1 0 0)
    #(0 0 1 0)
    #(0 0 0 1))

  > (Index (Matrix 6 8)
       (lambda (x y)
          (if (zero? (modulo (+ x y) 2)) 1 0)))
  #(#(1 0 1 0 1 0 1 0)
    #(0 1 0 1 0 1 0 1)
    #(1 0 1 0 1 0 1 0)
    #(0 1 0 1 0 1 0 1)
    #(1 0 1 0 1 0 1 0)
    #(0 1 0 1 0 1 0 1))
  ```

* make a matrix with dynamically computed values, based on a matrix(es) elements
  ```scheme
  ; `Map` accepts any number of vectors, all vectors must have same dimension (is sense of `Shape`) and `Size`.

  > (define (sqr x) (* x x))
  > (Map sqr (Reshape (Iota 12 1) '(3 4)))
  #(#(1 4 9 16) #(25 36 49 64) #(81 100 121 144))

  ; add two matrices manually
  > (Map + (Reshape (Iota 12 0 -1) '(3 4))
           (Reshape (Iota 12 0 3) '(3 4)))
  #(#(0 2 4 6) #(8 10 12 14) #(16 18 20 22))
  ```

Other Functions
---------------

Next function are not stabilized yet and can be changed in feature.

* [Determinant](https://en.wikipedia.org/wiki/Determinant)
  ```scheme
  > (determinant [[3  7]
                  [1 -4]])
  -19
  ```

* [Transpose](https://en.wikipedia.org/wiki/Transpose)
  ```scheme
  > (transpose [[1 2 3]
                [4 5 6]
                [7 8 9]])
  #(#(1 4 7)
    #(2 5 8)
    #(3 6 9))
  ```

* [Matrix multiplication](https://en.wikipedia.org/wiki/Matrix_multiplication)
  ```scheme
  > (define M₁ [[1 2 3 4]
                [7 3 5 1]
                [9 8 2 4]])
  > (define M₂ [[1 2 3]
                [7 3 5]
                [9 8 2]
                [5 2 8]])

  > (matrix-product M₁ M₂)
  #(#(62  40 51)
    #(78  65 54)
    #(103 66 103))

  > (matrix-product M₂ M₁)
  #(#(42 32 19 18)
    #(73 63 46 51)
    #(83 58 71 52)
    #(91 80 41 54))

  ; fast (inexact) matrix product
  > (matrix-product (Matrix~ [[1 2 3]
                              [4 7 6]])
                    (Matrix~ [[7 7]
                              [9 8]
                              [1 6]]))
  ((2 2) . #u8(0 0 224 65 0 0 36 66 0 0 194 66 0 0 240 66))
  ```

* [Hadamard product](https://en.wikipedia.org/wiki/Hadamard_product_(matrices))
  ```scheme
  > (define M₁ [[1 2 3 4]
                [7 3 5 1]
                [9 8 2 4]])
  > (define M₂ [[1 2 3 4]
                [2 9 6 7]
                [2 8 8 7]])

  > (hadamard-product M₁ M₂)
  #(#(1  4  9  16)
    #(14 27 30 7)
    #(18 64 16 28))
  ```

* Matrix power
  ```scheme
  > (define M₁ [[1 2 3 4]
                [7 3 5 1]
                [9 8 2 4]
                [7 4 9 2]])

  > (matrix-power M₁ 0)
  #(#(1 0 0 0)
    #(0 1 0 0)
    #(0 0 1 0)
    #(0 0 0 1))

  > (matrix-power M₁ 3)
  #(#(1083 828  794  600)
    #(1415 1013 1162 713)
    #(2012 1540 1457 1066)
    #(2069 1482 1722 1078))
  ```

* matrix-exponential
* matrix-inverse
* cracovian-product
* kronecker-product
* minor-matrix
* cofactor-matrix
* adjoint-matrix
* inverse-matrix
