Reference
=========

Indicing
--------

All math objects in Ol are indexed starting from 1. From 1, as mathematicians do. Not from 0, as programmers do.


# ~
A tilde (`~`) as a function suffix means to explicitly use the inexact arithmetics and fast (C-optimized) function version if available. Please note that inexact math calculations may be much faster with very big or very small numbers, but it may lose exactness.

You can force the (otus algebra) library to always use inexact math with "no tilde" functions using the following code:
```
(define-library (otus algebra config)
(import (otus lisp))  (export config)
(begin
   (define config { ;; use fast vectors
      'default-exactness #F
   }) ))
```

Fast vectors have own internal format, use the `Print` function to display it in a usual way.
  ```scheme
  > (define x (Vector~ [1 2 3]))
  > x
  ((3) . #u8(0 0 128 63 0 0 0 64 0 0 64 64))
  ```

# !
Mutators (typically ends with "!" suffix) applicable only to *enums* (positive and negative values) and *inexact*s. Mutators are dangerous and giving no real benefit. Use them only if you really understand what you are doing.

Fast vectors, matrices and tensors are supported, of course, without any restrictions.

  ```scheme
  ; a heterogeneous vector,
  > (define x [3 4/5 7 #i12.34])
  > x
  #(3 4/5 7 12.3399999)

  ; let's fill with exact number "1",
  ; you see, inexact number changed too
  > (Fill! x 1)
  #(1 4/5 1 1.0)

  ; and now with inexact number,
  ; exact numbers are not changed
  > (Fill! x #i7.42)
  #(1 4/5 1 7.41999999)
  ```


TOC (en)
---

- [Vectors](reference/en/vector.md)
  - [Creation](reference/en/vector.md#creation)
  - [Vector Info](reference/en/vector.md#vector-info)
  - [Mapping functions](reference/en/vector.md#mapping-functions)
  - [Vector products](reference/en/vector.md#vector-products)
  - [Other functions](reference/en/vector.md#other-functions)
  - ...
- [Matrices](reference/en/matrices.md)
  - [Creation](reference/en/matrices.md#creation)
  - [Matrix Info](reference/en/matrices.md#matrix-info)
  - [Mapping functions](reference/en/matrices.md#mapping-functions)
  - [Matrix products](reference/en/matrices.md#matrix-products)
  - [Other functions](reference/en/matrices.md#other-functions)
  - ...
- [Tensors](reference/en/tensors.md)
  - [Creation](reference/en/tensor.md#creation)
  - ...
