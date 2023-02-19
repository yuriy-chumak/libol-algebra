libol-algebra
=============

Trying to make a one more package for math computing in Lisp.  
Should be used with [Ol (Otus Lisp)](https://github.com/yuriy-chumak/ol).

<a href="https://github.com/yuriy-chumak/libol-algebra/actions">
   <img align="right" src="https://github.com/yuriy-chumak/libol-algebra/actions/workflows/ci.yml/badge.svg">
</a>

Usage
-----

```shell
$ make
$ sudo make install
```

And now let's code.
```scheme
$ ol
Welcome to Otus Lisp 2.4
type ',help' to help, ',quit' to end session.
> (import (otus algebra))
> (dot-product [1 2 3] [8 -3 5])
17
> (infix-notation
     [1,3,-5] • [4,-2,-1] )
3
> ,quit
bye-bye.
```

Functions Reference
===================

By default all *algebra* math are exact.
That means no loss of precision during calculations.  
Some functions (like *sin*) can't be exact. Some functions (like *sqrt* can be exact and inexact). Some functions (like *floor*) can be exact only.

```scheme
> (import (otus algebra))
; exact math
> (define x 1)
> (infix-notation
    ((x * 1e40 + 42) - (x * 1e40))
  )
42

; inexact math
> (define i (inexact 1)) ; or just #i1
> (infix-notation
    ((i * 1e40 + 42) - (i * 1e40))
  )
0.0

; one more exact math example
> (infix-notation
    3 ^ (2 ^ (3 ^ 2))
  )
19323349832288915105454068722019581055401465761603328550184537628902466746415537000017939429786029354390082329294586119505153509101332940884098040478728639542560550133727399482778062322407372338121043399668242276591791504658985882995272436541441
> (expt 3 (expt 2 (expt 3 2)))
```

TOC (en)
---

- [Vectors](reference/en/vectors.md)
  - [Creation](reference/en/vectors.md#creation)
  - [Vector Info](reference/en/vectors.md#vector-info)
  - [Mapping functions](reference/en/vectors.md#mapping-functions)
  - [Vector products](reference/en/vectors.md#vector-products)
  - [Other functions](reference/en/vectors.md#other-functions)
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