(otus algebra)
==============

A package for smart math computing in [Ol (Otus Lisp)](https://github.com/yuriy-chumak/ol).

<a href="https://github.com/yuriy-chumak/libol-algebra/actions">
   <img align="right" src="https://github.com/yuriy-chumak/libol-algebra/actions/workflows/ci.yml/badge.svg">
</a>


## Installing

Just do `make; make install` inside the project folder.

Or do `kiss install libol-algebra` with [ol-packages](https://github.com/yuriy-chumak/ol-packages) repository.

If you don't need fast inexact math support (meaning optimized C code for floating point machine types) or you don't have a C compiler available,
you can `just copy the "otus" folder` to your project.


## Usage

To access libol-algebra functions import `(otus algebra)` in your code.  
To access unicode symbols and functions import `(otus algebra unicode)`.


```scheme
$ ol
Welcome to Otus Lisp 2.4
type ',help' to help, ',quit' to end session.
> (import (otus algebra))
> (dot-product [1 2 3] [8 -3 5])
17
> (infix-notation
     [1,3,-5] • [4,-2,-1]
  )
3
```
```scheme
> (import (otus algebra))
> (import (otus algebra unicode))
> (define-values (a b c) (values 5 3 -26))
> (define D (infix-notation
     b ² − 4 * a * c
  ))
> (define X₁ (infix-notation
     (- b + √(D)) / (2 * a)
  ))
> (print "X₁ = " X₁)
X₁ = 2
> (define X₂ (infix-notation
     (- b - √(D)) / (2 * a)
  ))
> (print "X₂ = " X₂)
X₂ = -13/5
> (print (infix-notation
     a * (X₂)² + b * X₂ + c
))
0

> ,quit
bye-bye.
```

You can shorten `infix-notation` macro with any valid symbol
```scheme
> (import (otus algebra))
> (import (otus algebra unicode))

; let's shorten infix-notation
> (define-macro @ (lambda args
     `(infix-notation ,args)))

; now use @ instead
> (print (@
     5 * (2)² + 3 * 2 - 26
))
0

```


A lot of usage examples avaiable in the ["tests"](tests) folder
and in the functions [Reference](reference/README.md).


Very Important Notes
====================

All *algebra* objects in Ol are **indexed starting from 1**.
From 1, as mathematicians do. Not from 0, as programmers do.  
**Negative indices** mean "counting from the end of".

```scheme
> (ref [10 20 30 40] 1)
10
> (ref [10 20 30 40] 0)
#false
> (ref [10 20 30 40] -1)
40
```

By default all *algebra* math **are exact**.
That means no loss of precision during calculations.  
But some functions (like *sin*) can't be exact.
And some functions (like *sqrt* can be exact and inexact). Some functions (like *floor*) can be exact only.

```scheme
> (import (otus algebra))

; exact math:
> (define X 1)
> (infix-notation
    ((X * 1e40 + 42) - (X * 1e40))
  )
42

; inexact math:
> (define I (inexact 1)) ; or just #i1
> (infix-notation
    ((I * 1e40 + 42) - (I * 1e40))
  )
0.0

; one more exact math example
> (infix-notation
    3 ^ (2 ^ (3 ^ 2))
  )
19323349832288915105454068722019581055401465761603328550184537628902466746415537000017939429786029354390082329294586119505153509101332940884098040478728639542560550133727399482778062322407372338121043399668242276591791504658985882995272436541441
```
