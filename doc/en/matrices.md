Matrices
--------

Matrix is a two-dimensional array arranged in rows. Vector of vectors, in other words.

TOC
---
- [Creation](#creation)
- [Info](#matrix-info)
- [Mapping functions](#mapping-functions)
- [Matrix products](#matrix-products)
- [Other functions](#other-functions)

Creation
--------

A Matrix can be declared as a vector of vectors. Same rules as a [vector creation](vectors.md#creation) are applicable.
```scheme
> [[1 2 3]
   [4 5 6]
   [7 8 9]]
#(#(1 2 3) #(4 5 6) #(7 8 9))
```

Additionally, Matrix can be declared:

* using *otus algebra* `Matrix` function,
  as an uninializied matrix of *rows* * *columns* elements (it's not guaranteed that the matrix elements will be initialized with zeros, it can be a #false constant for example, or NaN)
```scheme
> (Matrix 3 4)
#(#(0 0 0 0) #(0 0 0 0) #(0 0 0 0))
```

* as a matrix of *rows* identical vectors
```scheme
> (Matrix [1 2 3] 4)
#(#(1 2 3) #(1 2 3) #(1 2 3) #(1 2 3))
```

* as a copy of existing matrix
```scheme
> (Copy [[1 2 3] [4 5 6] [7 8 9]])
#(#(1 2 3) #(4 5 6) #(7 8 9))
```

* as a matrix of zeros and '1's
```scheme
> (Zeros 3 7)
#(#(0 0 0 0 0 0 0) #(0 0 0 0 0 0 0) #(0 0 0 0 0 0 0))

> (Ones 1 3)
#(#(1 1 1))
```

* as a copy of existing matrix using [matrix mapping function](#mapping-functions)


Matrix Info
-----------

* size of a matrix
```scheme
> (Shape [[3 3 7 7][1 2 3 4]])
'(2 4)

> (Shape [[3 3][1 2][3 3]])
'(3 2)
```

* total count of a matrix elements
```scheme
> (Size [[3 3 7 7][1 2 3 4]])
8

> (Size [[3 3][1 2][3 3]]))
6
```

* matrix element
```scheme
> (Ref [[1 2]
        [3 4]
        [5 6]] 1)
#(1 2)

> (Ref [[1 2]
        [3 4]
        [5 6]] -1)
#(5 6)

> (Ref [[1 2]
        [3 4]
        [5 6]] 2 1)
3

> (Ref [[1 2]
        [3 4]
        [5 6]] -1 -1)
6
```

Mapping Functions
-----------------

* make a same dimensional matrix with any applicable repeating value
```scheme
> (Fill (Matrix 2 3) 7)
#(#(7 7 7) #(7 7 7))
```

* make a same dimensional matrix with dynamically computed (randomized, for example) values
```scheme
(import (scheme srfi-27))
> (Fill (Matrix 3 2) random-real)
#(#(0.414190420 0.681261342) #(0.911988653 0.887599243) #(0.427052309 0.344429402))

> (Fill (Matrix 4 4)
     (lambda ()
        (random-integer 2)))
#(#(0 1 1 1) #(1 0 0 1) #(1 0 0 0) #(1 1 0 0))

> (Index (Matrix 4 4)
     (lambda (i j)
        (random-integer (* i j))))
#(#(0 1 2 2) #(1 1 3 7) #(2 5 5 1) #(0 1 7 14))
```

* make a same dimensional matrix with dynamically computed values, based on a vector element index
```scheme
> (Index (Matrix 3 3)
     (lambda (i j)
        (if (= i j) 1 0)))
#(#(1 0 0) #(0 1 0) #(0 0 1))
```

* make a matrix with dynamically computed values, based on a matrix(matrices) elements
```scheme
; `Map` accepts any number of matrices, all matrices must have same dimensions!

> (import (otus random!))
> (define (sqr x) (* x x))
> (define (rnd) (rand! 9))

> (Map square (Fill (Matrix 3 4) rnd))
#(#(0 0 25 16) #(49 0 49 49) #(9 36 0 36))

> (Map +
     (Fill (Matrix 3 4) rnd)
     (Fill (Matrix 3 4) rnd)
     (Fill (Matrix 3 4) rnd))
#(#(4 19 21 15) #(12 19 17 11) #(11 14 17 11))
```

Matrix Products
---------------

* Matrix Product
```scheme
> (matrix-product
     [[1 2 3]
      [4 5 6]]

     [[11 12]
      [13 14]
      [15 16]] )
#(#(82 88) #(199 214))

> (matrix-product [[2]] [[7]])
#(#(14))

> (matrix-product
     [[3 4 2]]

     [[13  9  7 15]
      [ 8  7  4  6]
      [ 6  4  0  3]] )
#(#(83 63 37 75))
```

Other Functions
---------------

* determinant (det)
```scheme
> (determinant [[2 -3  1]
                [2  0 -1]
                [1  4  5]])
49

> (det [[2 -3]
        [1  4]])
11
```

* transpose
```scheme
> (transpose [[1 2]])
#(#(1) #(2))

> (transpose [[1 2]
              [4 5]
              [7 8]])
#(#(1 4 7) #(2 5 8))
```

