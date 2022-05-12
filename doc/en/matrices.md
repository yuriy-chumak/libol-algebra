Matrices
--------

Matrix is a two-dimensional array arranged in rows. Vector of vectors, in other words.

TOC
---
- [Creation](#creation)
- [Info](#matrix-info)
- [Mapping functions](#mapping-functions)

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


Mapping Functions
-----------------

* make a same dimensional matrix with any applicable repeating value
```scheme
> (Fill (Matrix 2 3) 7)
#(#(7 7 7) #(7 7 7))
```

* make a same dimensional matrix with dynamically computed values
```scheme
> (import (otus random!))
> (Fill (Matrix 3 4)
     (lambda ()
        (rand! 123)))
#(#(97 75 21 17) #(23 73 117 113) #(120 102 63 33))

> (Fill (Matrix 4 3)
     (lambda ()
        (inexact (/ (rand! 10000) 100))))
#(#(22.1799999 44.6599999 36.53) #(63.7599999 31.8399999 17.1799999) #(24.44 66.7699999 32.57) #(46.2299999 49.4099999 33.0099999))
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

> (Map sqr (Fill (Matrix 3 4) rnd))
#(#(0 0 25 16) #(49 0 49 49) #(9 36 0 36))

> (Map +
     (Fill (Matrix 3 4) rnd)
     (Fill (Matrix 3 4) rnd)
     (Fill (Matrix 3 4) rnd))
#(#(4 19 21 15) #(12 19 17 11) #(11 14 17 11))
```
