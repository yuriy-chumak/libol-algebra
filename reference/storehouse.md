# Map
`(Map f array)`, *procedure*
`(Map f array1 array2)`, *procedure*
`(Map f array1 .. arrayN)`, *procedure*

Returns newly created array as map of provided arrays, the type of map result depends on type of input arrays (return fast array if any of the input arrays is *fast*).

Function *f* must return a number and accept same argument count as arrays are provided.

```scheme
> (Map + (Vector~ [1 2 3])
         (Vector~ [4 5 6]))
[5 7 9]

> (Map - (Matrix~ [[1 2 3] [4 5 6]])
         (Matrix~ [[3 2 1] [9 8 7]]))
[[-2.0  0.0  2.0]
 [-5.0 -3.0 -1.0]]
```

# storehouse

```scheme
> (= [1 2 3] #(1 2 3))
#true
```
