Arrays
======

Notes
-----

1. All arrays are **indexed starting from 1 (one)**, just as mathematicians do! Not from 0 (zero), like programmers.

1. Negative index means "counting from the end of".


Creating Arrays
---------------

An Array can be created:

* using native Ol syntax
  ```scheme
  ; shortest notation,
  ;  we'll use such notation widely
  > [1 2 3 4 5]
  [1 2 3 4 5]
  ```

* using algebra `Array` function
  ```scheme
  ; linear array with 7 elements
  > (Array 7)
  [0 0 0 0 0 0 0]

  ; fast (inexact) math vector explicit declaration,
  ;  it's not guaranteed that the array will be initialized with zeros.
  > (Array~ 2 3)  ; 2 rows, 3 columns
  [[0.0 0.0 0.0] [0.0 0.0 0.0]]

  ; fast (inexact) copy of a regular array
  > (Array~ [[1 2] [3 4]])
  [[1.0 2.0] [3.0 4.0]]
  ```

* as an array of *zero*s or *one*s.
  ```scheme
  > (Zeros 7)
  [0 0 0 0 0 0 0]

  > (Ones 2 3)
  [[1 1 1] [1 1 1]]

  ; fast vector with inexact zeros
  > (Zeros~ 4)
  [0.0 0.0 0.0 0.0]

  > (Ones~ 4)
  [1.0 1.0 1.0 1.0]
  ```


Dimensions in Arrays
--------------------

### 0-D Arrays

0-D array is Scalar (a number in simple words).

You can use any number as an array elements, including negatives, ratios, complex, inexact numbers (*floats*), looong integers, NaN and Infinity.

```scheme
; note: '#i' is a Lisp prefix for "inexact number"
> [-3 3/7 16+4i 7.12 #i7.12 618970019642290147449562111 +inf.0 (sqrt 16)]
[-3 3/7 16+4i 178/25 7.12 618970019642290147449562111 +inf.0 4]
```

Use `Scalar?` predicate to check the value for "scalarnesss".

```scheme
; 7 is a scalar
> (Scalar? 7)
#true

; [0 0 0 0] is not a scalar
> (Scalar? (Array 4))
#false

; 0+i is a scalar
> (Scalar? (sqrt -1))
#true
```

### 1-D Arrays

1-D array is Vector (a uni-dimensional array).

```scheme
; empty vector
> (Vector 0)
[]

; vector with 4 elements
> (Vector 4)
[0 0 0 0]

; vector with 4 inexact elements
> (Vector~ 4)
[0.0 0.0 0.0 0.0]
```

More about vectors can be found at [Vector page](vector.md).

### 2-D Arrays

2-D array is Matrix (in row-major order).

```scheme
; 2 rows, 3 columns
> (Matrix 2 3)
[[0 0 0] [0 0 0]]

; 3 rows, 2 columns, inexact elements
> (Matrix~ 3 2)
[[0.0 0.0] [0.0 0.0] [0.0 0.0]]

; 2 rows, 3 columns, filled with "1"
> (Ones (Matrix 2 3))
[[1 1 1] [1 1 1]]

; 3 similar rows
> (Matrix 3 [1 2 3 4 5])
[[1 2 3 4 5]
 [1 2 3 4 5]
 [1 2 3 4 5]]
```

More about matrices can be found at [Matrix page](matrix.md).

### N-D Arrays

3-D, 4-D, ..., N-D array is Tensor. Actually, Vector and Matrix are Tensor too.

An array can have any number of dimensions. Just enumerate them in `Tensor` constructor. You can provide a *subarray* instead of last dimension(s).

```scheme
> (Tensor 2 3 4 5)
[[[[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]
  [[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]
  [[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]]
 [[[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]
  [[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]
  [[0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0] [0 0 0 0 0]]]]

> (Tensor 2 3 [5 6 7])
[[[5 6 7] [5 6 7] [5 6 7]]
 [[5 6 7] [5 6 7] [5 6 7]]]
```

More about tensors can be found at [Tensor page](tensor.md).


Number of Dimensions
--------------------

The shape of an array is the number of elements in each dimension.  
[Shape](algebra/core.md#shape) returns list of such numbers. The count of shape elements is a number of array dimensions.

```scheme
> (Shape (Tensor 2 3 [5 6 7]))
'(2 3 3)

> (length (Shape (Tensor 2 3 [5 6 7])))
3
```


Access Array Elements
---------------------

You can access an array element by referring to its index number. Remembering again, all array are **indexed starting from 1 (one)** just as mathematicians do, not from 0 (zero) like programmers.

Use negative indexing to access an array from the end.

```scheme
> (define v [[1 2 3]
             [4 5 6]])

> (Ref v 1 1)
1

> (Ref v 2 2)
5

> (Ref v -1 -1)
6

> (Ref v -2)
[1 2 3]

> (Ref v 1)
[1 2 3]
```


Slicing arrays (TBD.)
---------------------


Clone and Reference
-------------------

By default arrays are not cloning. Use `Copy` function to copy the array.

You can't check who's owner of referenced data, all data owners are equivalent.

```scheme
> (define main [[1 2 3]
                [4 5 6]])
> (define aref main)
> (define copy (Copy main))

; a hack, don't repeat such things
> (set-ref! (ref main 2) 2 42)

> main
[[1 2 3] [4 42 6]]

> aref
[[1 2 3] [4 42 6]]

> copy
[[1 2 3] [4 5 6]]
```


Reshaping arrays
----------------

Reshaping means changing the shape of an array. The count of array elements should not be changed.

```scheme
; create matrix x
> (define x [[1 2 3 4]
             [5 6 7 8]])
> x
[[1 2 3 4] [5 6 7 8]]

> (Shape x)
'(2 4)

; make a vector from matrix x
> (define y (Reshape x '(8)))
> y
[1 2 3 4 5 6 7 8]

> (Shape y)
'(8)

; create a 3-d array from vector y
> (define z (Reshape y '(2 2 2)))
> z
[[[1 2] [3 4]]
 [[5 6] [7 8]]]
```


Iterating Arrays
----------------

Use `Map` function to create new array based on mapped one.

```scheme
> (define x [[1 2 3] [4 5 6]])
> (Map sqrt x)
[[1 665857/470832    18817/10864]
 [2  51841/23184  46099201/18819920]]

> (define y (Array~ [[1 2 3] [4 5 6]]))
> (Map sqrt y)
[[1.0 1.414213538 1.732050776] [2.0 2.23606801 2.44948983]]
```

```scheme
> (define x [[1 2 3 4] [5 6 7 8]])
> (define y [[2 2 2 2] [1 1 1 1]])
> (Map + x y)
[[3 4 5 6] [6 7 8 9]]

> (define x (Matrix~ [[1 2 3 4] [5 6 7 8]]))
> (define y (Matrix~ [[2 2 2 2] [1 1 1 1]]))
> (Map + x y)
[[3.0 4.0 5.0 6.0] [6.0 7.0 8.0 9.0]]
```

