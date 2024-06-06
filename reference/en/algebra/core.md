# Shape
`(Shape array)`, *core*

The dimensions of the array. This is a list of integers indicating the size of the array *array* in each dimension.  
The length of returned list is the number of axes (dimensions) of the array.


# Size
`(Size obj)`, *core*

The total number of elements of the array. This is equal to the product of the elements of shape.


# Reshape
`(Reshape obj newshape)`, *shape*

Gives a new shape to an array without changing its data. *Newshape* must be a list.  
The new shape should be compatible with the original shape (the sizes of arrays must be equal).


# Flatten
`(Flatten array)`, *shape*

Makes a plain vector from any array (convert *array* to 1-dimensional). Same as `(Reshape x (list (Size x)))`, but faster.


# Padding
`(Padding matrix)`, *shape*

Returns the padding of the matrix.

```scheme
> (Padding [[0 0 1 0] [0 0 2 0]])
'((-2 . 1) (0 . 0))

> (Padding [[1 1 1 0] [0 1 2 0]])
'((0 . 1) (0 . 0))
```


# Shift
`(Shift matrix shift)`, *shape*

Shifts matrix for *'(columns . rows)*.

```scheme
> (Shift [[1 1 1 0]
          [0 1 2 0]]
     '(1 0))
[[0 1 1 1]
 [0 0 1 2]]
```
