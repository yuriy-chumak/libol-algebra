(otus algebra)
==============

A package for a smart math computing in the [Ol (Otus Lisp)](https://github.com/yuriy-chumak/ol).

<a href="https://github.com/yuriy-chumak/libol-algebra/actions">
   <img align="right" src="https://github.com/yuriy-chumak/libol-algebra/actions/workflows/ci.yml/badge.svg">
</a>


## Installing

Possible options:
 - Just `make; make install` inside the project folder,
 - Or `kiss install libol-algebra` using [ol-packages](https://github.com/yuriy-chumak/ol-packages) repository,
 - If you don't need the fast inexact math support (meaning optimized C code for floating point machine types) or you don't have the C compiler available,
 you can just `copy the "otus" folder` to your project.


## Usage

Simple example:
```scheme
$ ol
Welcome to Otus Lisp 2.5
type ',help' to help, ',quit' to end session.
> (import (otus algebra))
;; Library (otus algebra) added
;; Imported (otus algebra)
> (dot-product [1 2 3] [8 -3 5])
17
```

How to use infix notation inside Lisp (`\\` is a short for `infix-notation`):
```scheme
> (import (math infix-notation))
;; Library (math infix-notation) added
;; Imported (math infix-notation)
> (\\
     [1,3,-5] • [4,-2,-1]
  )
3
```

Additional unicode math symbols usage:
```scheme
> (import (otus algebra unicode))
;; Library (otus algebra unicode) added
;; Imported (otus algebra unicode)

> (define-values (a b c) (values 5 3 -26))
;; All defined

> (define D (\\
     b ² − 4 * a * c
  ))
;; Defined D

> (define X₁ (\\
     (- b + √(D)) / (2 * a)
  ))
;; Defined X₁
> (print "X₁ = " X₁)
X₁ = 2

> (define X₂ (\\
     (- b - √(D)) / (2 * a)
  ))
;; Defined X₂
> (print "X₂ = " X₂)
X₂ = -13/5

> (print (\\
     a * (X₂)² + b * X₂ + c
))
0
```


A lot of examples available under the [Reference](reference/README.md) page
and in the ["tests"](tests) folder.


Very Important Notes
====================

* All *algebra* arrays in Ol are **indexed starting from 1**.
  From 1, as mathematicians do. Not from 0, as programmers do.  
  **Negative indices** mean "counting from the end of".

* By default all *algebra* math **are exact** (but it's can be changed using environment variables). That means no loss of precision during calculations.  
  * Some functions (like *sin*) can't be exact,
  * Some functions (like *floor*) can be exact only,
  * Most functions (like *sqrt*) can be exact and inexact depends on argument(s) exactness.

These and other package features described in detail on the main [Reference](reference/README.md) page.


Good luck and happy calculations!

```scheme
> (\\
    3 ^ (2 ^ (3 ^ 2))
  )
19323349832288915105454068722019581055401465761603328550184537628902466746415537000017939429786029354390082329294586119505153509101332940884098040478728639542560550133727399482778062322407372338121043399668242276591791504658985882995272436541441
```
