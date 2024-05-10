Reference
=========

Indicing
--------

All math objects in Ol are indexed starting from **1 (one)**, just as mathematicians do. Not from 0 (zero), as do the programmers.


# ~
A tilde (`~`) as a function suffix means to explicitly use the **inexact** arithmetics and fast (C-optimized) function version if available. Please note that inexact math calculations typically much faster for very big or very small numbers, but it may lose exactness.

You can force the `(otus algebra)` library to always use inexact math even for "no tilded" functions using the following startup code:
```
(define-library (otus algebra config)
(import (otus lisp))  (export config)
(begin   ; always use fast math
   (define config {
      'default-exactness #F
   }) ))
```

Fast versions of math objects has own internal format, so use the `Print` function to display them in readable way.
  ```scheme
  > (define x (Vector~ [1 2 3]))
  > x
  '((3) . #u8(0 0 128 63 0 0 0 64 0 0 64 64))

  > (Print x)
  [1.0 2.0 3.0]
  ```

# !
Mutators (typically ends with "`!`" suffix) applicable only to *enums* (positive and negative values) and *inexact*s. Mutators are dangerous and giving no real benefit. Use them only if you really understand what you are doing.

Fast vectors, matrices and tensors are supported, of course, without any restrictions.

  ```scheme
  ; a heterogeneous vector
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
