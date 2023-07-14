Reference
=========

Indicing
--------

All math objects in Ol are indexed starting from 1. From 1, as mathematicians do. Not from 0, as programmers do.



~
=
A tilde (`~`) as a function suffix means to explicitly use the fast (C-optimized) function version. Please note that these functions make inexact math calculations (CPU or GPU "float" or "double" numbers).

You can change default behavior to the fast math using next code:
```scheme
(define-library (otus algebra config)
(import (otus lisp))  (export config)
(begin
   (define config { ;; use fast vectors
      'default-exactness #F
   })))
```

Note:

(Ones) without arguments returns 1
(Ones~) without arguments returns 1.0
(Zeros) without arguments returns 0

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