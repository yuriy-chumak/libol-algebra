Vectors
=======

Vector is a one-dimensional array.

TOC
---
- [Creation](#creation)
- [Info](#vector-info)
- [Mapping functions](#mapping-functions)

Creation
--------

A Vector can be declared:

* using native lisp syntax, and it's values can be any applicable number or boolean
```scheme
> [1 2 3 4 5]
#(1 2 3 4 5)

> [0 -3 3/7 16+4i 7.12 (inexact 7.12) 123456789876543213546576666777757575757444 +nan.0 -inf.0]
#(0 -3 3/7 16+4i 178/25 7.12 123456789876543213546576666777757575757444 +nan.0 -inf.0)

> (vector 1 2 3 4 5)
#(1 2 3 4 5)

> (make-vector 7)
#(#false #false #false #false #false #false #false)

> (make-vector 4 8)
#(8 8 8 8)

> (make-vector '(3 4 5))
#(3 4 5)
```

* using *otus algebra* `Vector` function,
  as an uninializied vector of N elements (it's not guaranteed that the vector will be initialized with zeros, it can be a #false constant for example, or NaN)
```scheme
> (Vector 7)
#(0 0 0 0 0 0 0)

```

* as a copy of existing vector
```scheme
> (define v [1 2 3 4 5])
> (print v)
#(1 2 3 4 5)

> (Copy v)
#(1 2 3 4 5)
```

* as a vector of zeros
```scheme
> (Zeros 7)
#(0 0 0 0 0 0 0)
```

* as a vector of '1's
```scheme
> (Ones 42)
#(1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1)
```

* as a vector of consecutive values
```scheme
> (Iota 5)
#(0 1 2 3 4)

> (Iota 10 8)
#(8 9 10 11 12 13 14 15 16 17)

> (Iota 6 10 20)
#(10 30 50 70 90 110)
```

* as a vector of another consecutive values
```scheme
> (Arange 10 30 5)
#(10 15 20 25)

> (Arange 0 2 0.3)
#(0 3/10 3/5 9/10 6/5 3/2 9/5)

> (Arange 0 2 (inexact 0.3))
#(0 0.299999999 0.599999999 0.899999999 1.199999999 1.5 1.8)
```

* as a vector of another 
```scheme
> (Linspace 0 2 9)
#(0 2 4 6 8 10 12 14 16)

> (define pi (inexact 3.14159265359))
;; Defined pi
> (Linspace 0 (* 2 pi) 12)
#(0 6.28318530 12.5663706 18.8495559 25.1327412 31.4159265 37.6991118 43.9822971 50.2654824 56.5486677 62.8318530 69.1150383)
```

* as a copy of existing vector using [vector mapping function](#mapping-functions)


Vector Info
-----------

* size of a vector
```scheme
> (Shape [7 7 7 7])
'(4)
```

* total count of a vector elements
```scheme
> (Size [2 2 2 2 2])
5
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
```scheme
> (Index (Vector 8)
    (lambda (i)
        (if (zero? (modulo i 2)) i 0)))
#(0 2 0 4 0 6 0 8)
```

* make a vector with dynamically computed values, based on a vector(s) elements
```scheme
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
