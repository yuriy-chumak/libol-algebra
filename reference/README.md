README
======

* [Indicing](#indicing)
* [Infix Notation](#infix-notation)
* [Print and Examples](#print-and-examples)
* [~ (tilde suffix)](#tilde-suffix)
* [Other Conventions](#other-function-naming-conventions)
* Skip to [Library Reference](#library-reference)

## Indicing

All math objects in Ol are indexed starting from **1 (one)**, just as mathematicians do. Not from 0 (zero), as do the programmers!

```scheme
> (Ref [10 11 12] 1)
10

> (Ref [10 11 12] 0)
#false
```

## Infix Notation

You can use traditional infix math notation freely, if you want. Just import `(math infix-notation)` library and use `\\` macro (is the short for `infix-notation`).

```scheme
> (import (math infix-notation))
> (\\  2 * (3 + 4) )
14

> (infix-notation
     [1 2 3] + [4 5 6] )
#(5 7 9)
```

## Print and Examples

Examples in this and subsequent reference docs are provided in form named "repl" using prompt symbol "> ", which shows the behavior like if someone were typing code in an interactive ol session.
The only difference from the real REPL session is the visual form of inexact (fast) arrays which are displayed like as [Print](#algebra/print.md) function output.

That's made because the fast (*inexact*) versions of all algebra math objects have their own internal format that depends on the hardware used and is not intended to be readable by humans, so you should use the special `Print` function to display them in a readable way.
```lisp
; raw REPL dump
> (Vector~ [1 2 3])
'((3) . #u8(0 0 128 63 0 0 0 64 0 0 64 64))

> (Print (Vector~ [1 2 3]))
[1.0 2.0 3.0]
```

We apply `Print` function implicitly in all required cases and you will not see the raw fast object output.
This helps us make examples more brief and simple.

```scheme
; our REPL dump
> (Vector~ [1 2 3])
[1.0 2.0 3.0]

> (Print (Vector~ [1 2 3]))
[1.0 2.0 3.0]
```

That's the only difference between examples and real REPL output.

## ~ (tilde suffix)

The `(otus algebra)` library operates on two major kind of numbers - *exact* numbers and *inexact* numbers. *Exact* numbers do not loose their precision during math transformations. But *inexact* numbers may do.

```scheme
; exact number
> 1e32
100000000000000000000000000000000

; inexact number ('#i' is an explicit prefix for such numbers)
> #i1e32
10.0e31

; exact calculations
> (\\ 1e32 + 2 - 1e32)
2

; inexact calculations
> (\\ #i1e32 + 2 - #i1e32)
0.0
```

As an undeniable benefit, *inexact* numbers math is highly optimized and fast (especially for very big and very small numbers or vectors). Many functions have a special form of name that causes them to explicitly produce *inexact* numbers. It includes the tilde (`~`) as a function suffix.

```scheme
> (Vector [1 2 3])
#(1 2 3)

> (Vector~ [1 2 3])
[1.0 2.0 3.0]
```

By default, `(otus algebra)` uses *exact* math. You can change default behavior by:
 * Using environment variable `OTUS_ALGEBRA_DEFAULT_EXACTNESS` with "0", "False", "1", or "True" value:
   ```shell
   # with global variable set
   $ export OTUS_ALGEBRA_DEFAULT_EXACTNESS=0
   $ ol your-evaluations.lisp
   # or with just running session variable
   $ OTUS_ALGEBRA_DEFAULT_EXACTNESS=False ol your-evaluations.lisp
   ```
 * Directly in the lisp code (*#t* to override possible previously assigned value, *#f* to not):
   ```scheme
   (import (scheme process-context))
   (set-environment-variable! "OTUS_ALGEBRA_DEFAULT_EXACTNESS" "0" #t)
   ```

 * At least, using next lisp startup code before loading the algebra library (which is not a recommended way):
   ```scheme
   (define-library (otus algebra config)
   (import (otus lisp))  (export config)
   (begin
      (define config {
         'default-exactness #F
      }) ))
   ; and now load library
   (import (otus algebra))
   ```

The default exactness cannot be changed once the `(otus algebra)` library is loaded.

## Other function naming conventions

The `(otus algebra)` functions begin with a capital letter to distinguish them from the Ol functions which are in a lowercase.

# !
~~Mutators (typically ends with "`!`" suffix) applicable only to *enums* (positive and negative values) and *inexact*s. Mutators are dangerous and giving no real benefit. Use them only if you really understand what you are doing.~~

~~Fast vectors, matrices and tensors are supported, of course, without any restrictions.~~

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


Library Reference
=================

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
