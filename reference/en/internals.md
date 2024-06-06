# libol-algebra.so internals

```scheme
```

# evector
`(evector N)`, *core*  
`(evector v)`, *core*

Create vector length N,  
or just a vector v itself (not a copy).


# ivector

Creates a native (*inexact*) vector.


# ~new (C Tensor)
`(~new '(N) '(N))`, ...  
`(~new '(N) '([x1 x2 ...]))`, ...

Returns generated native data (floats).


# scalar?
`(scalar? obj)`, *core*

*True* if obj is a lisp number.


# vector?
`(vector? obj)`, *core*

*True* if obj is a Lisp array (vector, matrix, hipermatrix).


# tensor?
`(tensor? obj)`, *core*

*True* if obj is a C array (vector, matrix, hipermatrix).


# shape
`(shape obj)`, *core*

Returns shape of Lisp array.


# flatten
`(flatten obj)`, *core*

Makes a plain vector from any array. Same as `(reshape x (list (Size x)))`, but faster.
