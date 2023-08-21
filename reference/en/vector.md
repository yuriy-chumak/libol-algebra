Vectors
=======

Vector is a one-dimensional array.


Note
----

1. A tilde (`~`) as a function suffix means to explicitly use the inexact arithmetics and fast (C-optimized) function version if available. Please note that inexact math calculations may be much faster with very big or very small numbers, but it may lose exactness.


TOC
---
- [Creation](#creation)
- [Info](#vector-info)
- [Mapping functions](#mapping-functions)
- [Vector products](#vector-products)
- [Other functions](#other-functions)


Creation
--------

A Vector can be created:

* using native Ol syntax
  ```scheme
  ; short notation
  ; we'll use such notation widely
  > [1 2 3 4 5]
  #(1 2 3 4 5)
  ```

* using `Vector` function
  ```scheme
  ; uninializied vector of N elements,
  ; it's not guaranteed that the vector will be initialized with zeros.
  > (Vector 7)
  #(0 0 0 0 0 0 0)

  ; fast (inexact) math vector (if libol-algebra.so has been loaded),
  ;   otherwise regular Vector type used (but with inexact numbers!).
  ; it's not guaranteed that the vector will be initialized with zeros.
  > (Vector~ 7)  ; 7 elements
  ((7) . #u8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))

  ; fast (inexact) version of a regular vector
  > (Vector~ [1 2 3 4])
  ((4) . #u8(0 0 128 63 0 0 0 64 0 0 64 64 0 0 128 64))
  ```

* using Scheme `vector` and Ol `make-vector` functions
  ```scheme
  ; lisp notation
  > (vector 1 2 3 4 5)
  #(1 2 3 4 5)

  ; uninializied vector of N elements
  > (make-vector 7)
  #(#false #false #false #false #false #false #false)

  ; inializied vector of any applicable repeating value
  ;   attention! all elements of such vector are same in sense of `eq?`
  > (make-vector 4 2/3)
  #(2/3 2/3 2/3 2/3)

  ; vector from list
  > (make-vector '(3 4 5))
  #(3 4 5)
  ```

* you can use any number as a vector arguments,
  including negatives, ratios, complex, inexact numbers (floats),
  looong integers, NaN and Infinity
  ```scheme
  ; note: #i is a prefix for "inexact number"
  > [-3 3/7 16+4i 7.12 #i7.12 618970019642290147449562111 +inf.0 (sqrt 16)]
  #(-3 3/7 16+4i 178/25 7.12 618970019642290147449562111 +inf.0 4)
  ```

* you can use infix notation
  ```scheme
  > (infix-notation
       vector(1,2,3,4,5)
    )
  #(1 2 3 4 5)

  ; even for a native Ol syntax
  > (infix-notation
       [3 4 5 6 7]
    )
  #(3 4 5 6 7)
  ```

* as a vector of zeros
  ```scheme
  > (Zeros 7)
  #(0 0 0 0 0 0 0)

  > (Zeros [1 2 3 4])
  #(0 0 0 0)

  ; fast zeros vector
  > (Zeros~ 4)
  ((4) . #u8(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0))

  ; regular vector with inexact zeros
  > (Zeros~ (Vector 7))
  #(0.0 0.0 0.0 0.0 0.0 0.0 0.0)
  ```

* as a vector of ones
  ```scheme
  > (Ones 11)
  #(1 1 1 1 1 1 1 1 1 1 1)

  > (Ones [3 4 3 4 3 4])
  #(1 1 1 1 1 1)

  ; fast vector
  > (Ones~ 3)
  ((3) . #u8(0 0 128 63 0 0 128 63 0 0 128 63))

  ; regular vector with inexact ones
  > (Ones~ (Vector 8))
  #(1.0 1.0 1.0 1.0 1.0 1.0 1.0 1.0)
  ```

* as a deep `Copy` of existing vector
  ```scheme
  > (define V₁ [1 2.3 #i2.3 4 5e8])

  > (Copy V₁)
  #(1 23/10 2.29999999 4 500000000)
  ```

* as a copy of existing vector using [vector mapping functions](#mapping-functions)

* as a vector of consecutive values, using `Iota` functon
  ```scheme
  ; from 0 with step 1
  > (Iota 5)
  #(0 1 2 3 4)

  ; from 8 with step 1
  > (Iota 10 8)
  #(8 9 10 11 12 13 14 15 16 17)

  ; from 10 with step 12.3
  > (Iota 6 10 #i12.3)
  #(10 22.3 34.6 46.9 59.2 71.5)
  ```

* as a vector of consecutive values, using `Arange` function
  ```scheme
  ; from 0 to 4 with step 1
  > (Arange 4)
  #(0 1 2 3)

  ; from 5 to 9 with step 1
  > (Arange 5 9)
  #(5 6 7 8)

  ; from 10 to 30 with step 5
  > (Arange 10 30 5)
  #(10 15 20 25)
  ```

* as a vector of consecutive values, using `Linspace` function
  ```scheme
  ; 4 elements from 2 to 3
  > (Linspace 2 3 4)
  #(2 7/3 8/3 3)

  ; 4 elements from 2.0 to 3.0
  > (Linspace #i2 3 4)
  #(2.0 2.33333333 2.66666666 3.0)

  ; 3 elements from 0 to 2π
  > (define pi #i3.14159265359)
  > (Linspace 0 (* 2 pi) 3)
  #(0 3.14159265 6.28318530)
  ```

Vector Info
-----------

* `Shape` (size of a vector)
  ```scheme
  > (Shape [7 7 7 7])
  (4)
  ```

* `Size` (number of elements in a vector)
  ```scheme
  > (Size [2 2 2 2 2])
  5
  ```

* `Ref`erencing vector elements, counting starts from 1
  ```scheme
  ; from the begin of a vector
  > (Ref [11 12 13 14 15] 1)
  11

  > (Ref [11 12 13 14 15] 3)
  13

  ; from the end, counting starts from 1
  > (Ref [11 12 13 14 15] -1)
  15

  ; incorrect indexing examples
  ; (#false is a common error indicator)
  > (Ref [11 12 13 14 15] 0)
  #false

  > (Ref [11 12 13 14 15] 70)
  #false

  > (Ref [11 12 13 14 15] -9)
  #false
  ```

Mapping Functions
-----------------

* make a same dimensional vector with any applicable repeating value
  ```scheme
  > (Fill (Vector 17) -33)
  #(-33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33)

  > (Fill (Vector~ 3) 1.2)
  ((3) . #u8(154 153 153 63 154 153 153 63 154 153 153 63))
  ```

* make a same dimensional vector with dynamically computed values
  ```scheme
  > (import (otus random!))
  > (define (rand-i123) (rand! 123))
  > (define (rand-f100) (/ (rand! 10000) #i100))

  > (Fill (Vector 17) rand-i123)
  #(81 43 6 73 34 106 76 76 71 100 103 60 46 108 28 89 84)

  > (Fill (Vector 7) rand-f100)
  #(97.8299999 53.49 73.03 52.0 31.5199999 98.5499999 69.7199999)
  ```

* make a same dimensional vector with dynamically computed values, based on a vector element index
  ```scheme
  > (Index (Vector 8)
       (lambda (i)
          (if (zero? (modulo i 2)) i 0)))
  #(0 2 0 4 0 6 0 8)
  ```

* make a vector with dynamically computed values, based on a vector(s) elements
  ```scheme
  ; `Map` accepts any number of vectors, all vectors must have same dimension (is sense of `Shape`) and `Size`.

  > (define (sqr x) (* x x))
  > (Map sqr (Iota 8))
  #(0 1 4 9 16 25 36 49)

  ; add two vectors manually
  > (Map + (Iota 8 1) (Iota 8 10 5))
  #(11 17 23 29 35 41 47 53)
  ```

Vector Products
---------------

* Dot (scalar) product
  ```scheme
  ; `dot-product` accepts two vectors with same dimension and size
  > (dot-product [1 3 -5] [4 -2 -1])
  3

  > (dot-product [4 -2 -1] [1 3 -5])
  3

  ; `scalar-product` is a same as `dot-product`
  > (scalar-product [1 3 -5] [4 -2 -1])
  3

  ; using infix notation and a short operator:
  > (infix-notation
       vector(1,3,-5) • vector(4,-2,-1)
    )
  3

  > (infix-notation
       [1,3,-5] • [4,-2,-1]
    )
  3
  ```

* Cross Product
  ```scheme
  ; `cross-product` accepts two vectors with same dimension and size
  > (cross-product [-2 3 1] [0 4 0])
  #(-4 0 -8)

  ; using infix notation and short operators
  > (infix-notation
       [-2,3,1] ⨯ [0,4,0]
    )
  #(-4 0 -8)
  ```

* Triple product
  ```scheme
  ; `triple-product` accepts three vectors with same dimension and size
  > (triple-product [-2 3 1] [0 4 0] [-1 3 3])
  -20

  ; using infix notation and short operators
  > (infix-notation
       [-2,3,1] • ([0,4,0] ⨯ [-1,3,3])
    )
  -20
  ```


Other Functions
---------------

* Magnitude
  ```scheme
  > (magnitude [1 2 3 7])
  32257/4064

  > (inexact (magnitude [1 2 3 7]))
  7.93725393
  ```

* Square magnitude
  ```scheme
  > (square-magnitude [1 2 3 7])
  63

  > (inexact (square-magnitude [1 2 3 7]))
  63.0
  ```

