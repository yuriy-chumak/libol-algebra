(otus algebra)
==============

A package for a smart math computing in the [Ol (Otus Lisp)](https://github.com/yuriy-chumak/ol).

[![Github build linux status](https://github.com/yuriy-chumak/libol-algebra/workflows/CI%20Check%20(Linux)/badge.svg)](https://github.com/yuriy-chumak/libol-algebra/actions/workflows/check-linux.yml)
[![Github build macos status](https://github.com/yuriy-chumak/libol-algebra/workflows/CI%20Check%20(MacOS)/badge.svg)](https://github.com/yuriy-chumak/libol-algebra/actions/workflows/check-macos.yml)
[![Github build win64 status](https://github.com/yuriy-chumak/libol-algebra/workflows/CI%20Check%20(Win64)/badge.svg)](https://github.com/yuriy-chumak/libol-algebra/actions/workflows/check-win64.yml)


## For what?

The main purpose of this library is to provide a comfortable way to perform complex math evaluations in a programming environment. Yet another math library? Yes and Not.

The Otus Lisp (Ol) and `(otus algebra)` may provide you very human friendly runtime environment with:
 * *exact* calculations on demand (if your task allows) without losing the readability of the program text
 * the same calculation results regardless of the platform used [*](#note-1)
 * easy switching between fast inexact and ordinary exact calculation modes


## Installing

You have a choice to:
 - `make; make install` inside the project folder,
 - `kiss install libol-algebra` using [ol-packages](https://github.com/yuriy-chumak/ol-packages) repository,
 - If you don't need the fast inexact math support (the optimized C code for floating point machine types) or you don't have the C compiler available (huh?), just *copy the "otus" folder* to the your project folder.


## Usage

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

Infix notation inside Lisp (`\\` is a short for macro `infix-notation`):
```scheme
> (\\
     [1 3 -5] ⨯ [4 -2 -1]
  )
[-13 -19 -14]
```

Some unicode math symbols (don't forget spaces between regular and unicode math letters):
```scheme
> (import (otus algebra unicode))

> (define-values (a b c) (values 5 3 -26))
;; All defined

> (define D (\\
     b ² − 4 * a * c
  ))
> D
529

> (define X₁ (\\
     (- b + √(D)) / (2 * a)
  ))
> (print "X₁ = " X₁)
X₁ = 2

> (define X₂ (\\
     (- b - √(D)) / (2 * a)
  ))
> (print "X₂ = " X₂)
X₂ = -13/5

> (print (\\
     a * (X₂)² + b * X₂ + c
))
0
```

A lot of examples available on the [Reference](reference/README.md) page
and in the ["tests"](tests) folder.


Very Important Notes
====================

* All *algebra* arrays in Ol are **indexed starting from 1**.
  From 1, as mathematicians do! Not from 0, like programmers.  
  **Negative index** means "counting from the end of".

* By default all *algebra* math **are exact** (it can be changed using environment variables). That means no loss of precision during calculations.  
  - Some functions (like *sin*) can't be exact,
  - Some functions (like *floor*) can be exact only,
  - Most functions (like *sqrt*) can be exact and inexact depends on argument(s) exactness.

These and other package features described in detail on the main [Reference](reference/README.md) page.


Good luck and happy calculations!

```scheme
> (\\ ((((((((2)²)²)²)²)²)²)²)² )
115792089237316195423570985008687907853269984665640564039457584007913129639936
```

## Notes

#### note 1
In case of *inexact* (imprecise) calculations, the results of your work may (and will) vary across the same platforms as well, because of fundamental nature of imprecise calculations.
