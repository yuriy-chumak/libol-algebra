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

$ ol
Welcome to Otus Lisp 2.4
type ',help' to help, ',quit' to end session.
> (import (otus algebra))
> (dot-product [1 2 3] [8 -3 5])
17
> ,quit
bye-bye.
```

Functions Reference
===================

(en)
----
- [Vectors](reference/en/vectors.md)
  - [Creation](reference/en/vectors.md#creation)
  - [Vector Info](reference/en/vectors.md#vector-info)
  - [Mapping functions](reference/en/vectors.md#mapping-functions)
  - [Vector products](reference/en/vectors.md#vector-products)
  - [Other functions](reference/en/vectors.md#other-functions)
- [Matrices](reference/en/matrices.md)
  - [Creation](reference/en/matrices.md#creation)
  - [Matrix Info](reference/en/matrices.md#matrix-info)
  - [Mapping functions](reference/en/matrices.md#mapping-functions)
  - [Matrix products](reference/en/matrices.md#matrix-products)
  - [Other functions](reference/en/matrices.md#other-functions)
- [Tensors](reference/en/tensors.md)
  - TBD.

