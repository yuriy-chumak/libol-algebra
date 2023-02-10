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

A Vector can be declared:

* using native Ol (Scheme) syntax,
  ```scheme
  ; inializied vector
  (vector 1 2 3 4 5)       ==>  #(1 2 3 4 5)
  
  ; nicer notation
  [1 2 3 4 5]              ==>  #(1 2 3 4 5)
  
  ; uninializied vector of N elements
  (make-vector 7)          ==>  #(#f #f #f #f #f #f #f)
  
  ; inializied vector of any applicable repeating value
  (make-vector 4 8)        ==>  #(8 8 8 8)
  
  ; as convertion of a list to a vector
  (make-vector '(3 4 5))   ==>  #(3 4 5)
  ```

* using `Vector` function,
  ```scheme
  ; uninializied vector of N elements
  ; (it's not guaranteed that the vector will be initialized with zeros)
  (Vector 7)               ==>  #(0 0 0 0 0 0 0)
  ```

* using vector `evector` and `fvector` specificators,
  ```scheme
  ; exact vector, same as `Vector`
  (evector 7)              ==>  #(0 0 0 0 0 0 0)

  ; fast inexact vector, not implemented yet
  ;(fvector 7 3 5 1)        ==>  #<wtf>
  ```

* as a vector of `Zeros`
  ```scheme
  (Zeros 7)                ==>  #(0 0 0 0 0 0 0)
  ```

* as a vector of `Ones`
  ```scheme
  (Ones 42)                ==>  #(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
  ```

* as a `Copy` of existing vector
  ```scheme
  (begin
     (define v [1 2.3 4 5e8])
  
     (Copy v))             ==>  #(1 2.3 4 500000000)
  ```

* as a copy of existing vector using  
  [vector mapping functions](#mapping-functions)

* as a vector of consecutive values, using `Iota` functon
  ```scheme
  ; from 0 with step 1
  (Iota 5)                 ==>  #(0 1 2 3 4)
  
  ; from N with step 1
  (Iota 10 8)              ==>  #(8 9 10 11 12 13 14 15 16 17)
  
  ; from N with step M
  (Iota 6 10 20)           ==>  #(10 30 50 70 90 110)
  ```

* as a vector of consecutive values, using `Arange` function
  ```scheme
  ; from [A to B) with step C
  (Arange 10 30 5)         ==>  #(10 15 20 25)
  
  (Arange 0 2 0.3)         ==>  #(0 3/10 3/5 9/10 6/5 3/2 9/5)
  ```

* as a vector of consecutive values, using `Linspace` function
  ```scheme
  ; C elements from A with step B
  (Linspace 0 2 9)         ==>  #(0 2 4 6 8 10 12 14 16)
  
  (begin
    (define pi 3.14159265359)
    (Linspace 1 (* 2 pi) 3))
                           ==>  #(1 7.28318530718 13.56637061436)
  ```


Vector Info
-----------

* `Shape` (size) of a vector
  ```scheme
  (Shape [7 7 7 7])     ==>  '(4)
  ```

* `Size` (count of elements) of a vector
  ```scheme
  (Size [2 2 2 2 2])    ==>  5
  ```

* `Ref`erencing vector elements
  ```scheme
  ; from the beginning
  (Ref [11 12 13 14 15] 1)  ==>  11
  (Ref [11 12 13 14 15] 3)  ==>  13
  
  ; from the end
  (Ref [11 12 13 14 15] -1) ==>  15
  
  ; invalid index
  (Ref [11 12 13 14 15] 0)  ==>  #false
  (Ref [11 12 13 14 15] 70) ==>  #false
  (Ref [11 12 13 14 15] -9) ==>  #false
  ```

Mapping Functions
-----------------

* make a same dimensional vector with any applicable repeating value
  ```scheme
  (Fill (Vector 17) -33)   ==>  [-33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33 -33]
  ```

* make a same dimensional vector with dynamically computed values
  ```lisp
  > (import (otus random!))
  > (Fill (Vector 17)
       (lambda ()
          (rand! 123)))
  #(110 8 119 79 8 75 111 93 87 15 63 122 87 46 110 74 94)
  
  > (Fill (Vector 7)
       (lambda ()
          (inexact (/ (rand! 10000) 100))))
  #(98.62 41.7199999 20.37 73.59 9.82 93.81 96.9599999)
  ```

* make a same dimensional vector with dynamically computed values, based on a vector element index
```schem
> (Index (Vector 8)
    (lambda (i)
        (if (zero? (modulo i 2)) i 0)))
#(0 2 0 4 0 6 0 8)
```

* make a vector with dynamically computed values, based on a vector(s) elements
```schem
; `Map` accepts any number of vectors, all vectors must have same dimension

> (define (sqr x) (* x x))
> (Map sqr (Iota 8))
#(0 1 4 9 16 25 36 49)

> (print (Iota 8 1))
#(1 2 3 4 5 6 7 8)
> (print (Iota 8 10 5))
#(10 15 20 25 30 35 40 45)
> (Map + (Iota 8 1) (Iota 8 10 5))
#(11 17 23 29 35 41 47 53)
```

Vector Products
---------------

* Dot (scalar) product
```schem
; `dot-product` accepts two vectors with same dimensions
> (dot-product [1 3 -5] [4 -2 -1])
3

> (dot-product [4 -2 -1] [1 3 -5])
3

> (scalar-product [1 3 -5] [4 -2 -1])
3
```

* Cross Product
```schem
; `cross-product` accepts two vectors with same dimensions
> (cross-product [-2 3 1] [0 4 0])
#(-4 0 8)
```

* Triple product
```schem
; `triple-product` accepts three vectors with same dimensions
> (triple-product [-2 3 1] [0 4 0] [-1 3 3])
-20
```

Other Functions
---------------

* Magnitude
```schem
> (magnitude [1 2 3 7])
32257/4064

> (inexact (magnitude [1 2 3 9]))
9.74679434
```

* Square magnitude
```schem
> (square-magnitude [1 2 3 7])
63

> (inexact (square-magnitude [1 2 3 9]))
95.0
```