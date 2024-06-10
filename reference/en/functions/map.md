# Map
`(Map f array)`, *procedure*  
`(Map f array1 array2)`, *procedure*  
`(Map f array1 .. arrayN)`, *procedure*

The `Map` procedure applies *F* element-wise to the elements of the *array(s)* and returns new same dimensions array of the results, in order.
All argument arrays must be same dimensional.

The type of `Map` result depends on type of input arrays (return fast array if any of the input arrays is *fast*).

Function *F* must return a number and accept same arguments count as count of arrays provided.

```scheme
; without arrays
> (Map +)
[]

> (Map #f)
[]

> (Map Map)
[]
```

```scheme
; single array
> (Map idf [1 2 3])
[1 2 3]

> (Map idf (Vector~ [1 2 3]))
[1.0 2.0 3.0]

> (Map Sin [1 2 3])
[0.841470984 0.909297426 0.141120008]

> (Map Sin (Vector~ [1 2 3]))
[0.841470956 0.909297406 0.141120001]

> (Map (lambda (x) (* x 2))
       [[1 2 3] [4 5 6]])
[[2 4 6] [8 10 12]]

> (Map (lambda (x) (* x 2))
       (Array~ [[1 2 3] [4 5 6]]))
[[2.0  4.0  6.0]
 [8.0 10.0 12.0]]
```

```scheme
; two arguments
> (define (list->Vector . args)
     (Vector (make-vector args)))

> (Map list->Vector [1 2 3] [4 5 6])
[[1 4] [2 5] [3 6]]

> (Map list->Vector [1 2 3] [4 5 6] [7 8 9])
[[1 4 7] [2 5 8] [3 6 9]]

> (Map - (Matrix~ [[1 2 3] [4 5 6]])
         (Matrix~ [[3 2 1] [9 8 7]]))
[[-2.0  0.0  2.0]
 [-5.0 -3.0 -1.0]]

> (Map + [1 2 3] [4 5 6] [7 8 9])
[12 15 18]

> (Map Pow (Matrix~ [[1 2] [3 4]])
           (Matrix~ [[5 6] [7 8]]))
[[1.0 64.0] [2187.0 65536.0]]
```

```scheme
; 4-D hypermatrix
> (Map sqrt (Array~ [[[[1 2] [3 4]]
                      [[5 6] [7 8]]]
                     [[[1 2] [3 4]]
                      [[5 6] [7 8]]]]))
[[[[1.0        1.414213538] [1.732050776 2.0]]
  [[2.23606801 2.44948983]  [2.64575123  2.82842707]]]
 [[[1.0        1.414213538] [1.732050776 2.0]]
  [[2.23606801 2.44948983]  [2.64575123  2.82842707]]]]
```

```scheme
; more than 3 vectors
> (Map + (Array [1 2 3])
         (Array [4 5 6])
         (Array [7 8 9])
         (Array [10 11 12])
         (Array [13 14 15]))
[35 40 45]

; all vectors are fast
> (Map + (Array~ [1 2 3])
         (Array~ [4 5 6])
         (Array~ [7 8 9])
         (Array~ [10 11 12])
         (Array~ [13 14 15]))
[35.0 40.0 45.0]

; only one of vectors is fast
> (Map + (Array [1 2 3])
         (Array [4 5 6])
         (Array [7 8 9])
         (Array~ [10 11 12])
         (Array [13 14 15]))
[35.0 40.0 45.0]
```
