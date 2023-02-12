Vectors
=======

Vector is a one-dimensional array.

TOC
---
- [Creation](#creation)
- [Info](#vector-info)
- [Mapping functions](#mapping-functions)
- [Vector products](#vector-products)
- [Other functions](#other-functions)


Creation
--------

A Vector can be created

* using `Vector` function
  ```scheme
  ; uninializied vector of N elements,
  ; it's not guaranteed that the vector will be initialized with zeros.
  > (Vector 7)
  #(0 0 0 0 0 0 0)
  ```

* using native Ol syntax
  ```scheme
  ; inializied vector
  > (vector 1 2 3 4 5)
  #(1 2 3 4 5)

  ; nicer notation,
  ; we'll use such notation widely
  > [1 2 3 4 5]
  #(1 2 3 4 5)

  ; uninializied vector of N elements
  > (make-vector 7)
  #(#false #false #false #false #false #false #false)

  ; inializied vector of any applicable repeating value
  > (make-vector 4 8)
  #(8 8 8 8)

  ; as convertion of a list to vector
  > (make-vector '(3 4 5))
  #(3 4 5)


  ; you can use any number as vector arguments,
  ; including ratios, complex, looong integers, NaN and Infinity
  > [-3 3/7 16+4i 7.12 (inexact 7.12) 618970019642290147449562111 +inf.0]
  #(-3 3/7 16+4i 178/25 7.12 618970019642290147449562111 +inf.0)
  ```

* using infix-notation
  ```scheme
  > (infix-notation
       vector(1,2,3,4,5)
    )
  #(1 2 3 4 5)

  > (infix-notation
       [3,4,5,6,7]
    )
  #(3 4 5 6 7)
  ```

* as a vector of `Zeros`
  ```scheme
  > (Zeros 7)
  #(0 0 0 0 0 0 0)
  ```

* as a vector of `Ones`
  ```scheme
  > (Ones 42)
  #(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
  ```

* as a `Copy` of existing vector
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

  ; 3 elements from 1 to 2π
  > (define pi #i3.14159265359)
  > (Linspace 1 (* 2 pi) 3)
  #(1 3.64159265 6.28318530)
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
  ```

* make a same dimensional vector with dynamically computed values
  ```scheme
  > (import (otus random!))
  > (define (rand-i123) (rand! 123))
  > (define (rand-f100) (/ (rand! 10000) #i100))

  > (Fill (Vector 17) rand-i123)
  #(22 27 55 7 110 19 66 61 12 18 21 122 101 121 78 53 86)

  > (Fill (Vector 7) rand-f100)
  #(21.8799999 21.9899999 20.4499999 50.1599999 51.3299999 37.5399999 83.64)
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
       [-2,3,1] ✕ [0,4,0]
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
       [-2,3,1] • ([0,4,0] ✕ [-1,3,3])
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

