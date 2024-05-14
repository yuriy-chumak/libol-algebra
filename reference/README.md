README
======

* [Terminology](#terminology)
* [Indicing](#indicing)
* [Infix Notation](#infix-notation)
* [Print and Examples](#print-and-examples)
* [~ (tilde suffix)](#tilde-suffix)
* [Vector vs Vector~](#vector-vs-vector)
* [Other Conventions](#other-function-naming-conventions)
* Skip to [Library Reference](#library-reference)

## Terminology


The `(otus algebra)` library operates slightly different terms for the objects it uses than Lisp or Python. All *algebra* objects are divides into:
* *Numbers*, the any kind of numbers - integers, rational (`17/3`), complex (`3+7i`); in decimal, binary, octal, or hexadecimal notation
  - the `number?` predicate returns `#true` for all and only numbers
* *Strings*, any unicode or regular (ansi) strings emphasized with `"`
  - the `string?` predicate returns `#true` for all and only strings
* *Functions*, any program objects that can be called with ot without argument(s) to produce result(s)
  - the `function?` predicate returns `#true` for all and only functions, predicates are functions too
* *Arrays*, any complex objects that allow indexed access to their parts (using the `Ref` function)
  - the `Array?` predicate returns `#true` for all and only arrays

All objects that mathematicians call *vector*, *matrix*, *hypermatix*, etc. are the *Arrays* in terms of *algebra* library. Ol *vectors* (started with lower-case 'v') are internal Ol objects that may be, or may not be the Array (from the capital 'A').

## Indicing

All math objects in Ol are **indexed starting from 1 (one)**, just as mathematicians do! Not from 0 (zero), like programmers. **Negative index** means "counting from the end of".

```scheme
> (Ref [10 11 12] 1)
10

> (Ref [10 11 12] 0)
#false

> (Ref [10 11 12] -1)
12
```

## Infix Notation

You can use traditional infix math notation freely, if you want. Just use `\\` macro (which is short for `infix-notation`).

```scheme
> (\\  2 * (3 + 4) )
14

> (infix-notation
     [1 2 3] + [4 5 6] )
#(5 7 9)
```

## Print and Examples

Examples in this and subsequent reference docs are provided in form named "REPL" using prompt symbol "> ", which shows the behavior like if someone were typing code in an interactive ol session.
The only difference from the real REPL session is the visual form of inexact (fast) arrays which are displayed like as [Print](#algebra/print.md) function output.

Please pay attention that `print`ed values of fast (*inexact*) algebra arrays differ from REPL output. That's happen because the fast versions of algebra math objects have their own internal format that depends on the hardware used and is not intended to be readable by humans. So you should use the special `Print` function to display them in a readable way.

```lisp
> (define x (Vector~ [1 2 3]))
> x
[1.0 2.0 3.0]

; the ol 'print' output
> (print x)
'((3) . #u8(0 0 128 63 0 0 0 64 0 0 64 64))

; the algebra 'Print' output
> (Print x)
[1.0 2.0 3.0]
```

## ~ (tilde suffix)

The `(otus algebra)` library operates on two major kind of numbers - *exact* numbers and *inexact* numbers. *Exact* numbers do not loose their precision during math transformations. But *inexact* numbers may do.

```scheme
; exact number
> (define a 1e34)
> a
10000000000000000000000000000000000

; inexact number ('#i' is an explicit prefix for such numbers)
> (define b #i1e34)
> b
1.0e34

; exact calculations
> (\\ a + 2 - a)
2

; inexact calculations
> (\\ b + 2 - b)
0.0
```

As an undeniable benefit, *inexact* numbers math is highly optimized and fast (especially for very big and very small numbers or vectors).

Many functions have a special form of name that causes them to explicitly produce *inexact* numbers. It includes the tilde (`~`) as a function suffix.

```scheme
; a regular vector of exact numbers
> (Vector [1 2 3])
#(1 2 3)

; a regular vector of inexact numbers
> (Vector [#i1 #i2 #i3])
#(1.0 2.0 3.0)

; a fast vector of inexact numbers
> (Vector~ [1 2 3])
[1.0 2.0 3.0]

; it is impossible to create a
; fast vector of exact numbers
```

By default, `(otus algebra)` uses *exact* math. You can change default behavior with:
 * Set environment variable `OTUS_ALGEBRA_DEFAULT_EXACTNESS` with "0", "False", "1", or "True" value:
   ```shell
   # with global variable set
   $ export OTUS_ALGEBRA_DEFAULT_EXACTNESS=0
   $ ol your-evaluations.lisp
   # or with just running session variable
   $ OTUS_ALGEBRA_DEFAULT_EXACTNESS=False ol your-evaluations.lisp
   ```

 * Directly in the lisp code (`#t` to override possible previously assigned value, `#f` to not):
   ```scheme
   (import (scheme process-context))
   (set-environment-variable! "OTUS_ALGEBRA_DEFAULT_EXACTNESS" "0" #t)
   ```

 * At least, which is not a recommended way, using next lisp startup code before loading the algebra library:
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

## Vector vs Vector~

*Maker* and *Maker~* may produce different arrays depending on the *default-exactness* option and existing of the compiled library:
 * *Maker* produce exact array if *default-exactness* is *true*, and works as *Maker~* otherwise.
 * *Maker~* ignore *default-exactness* option (`~` is an explicit choose), and
   - makes fast (c) array with inexact components, if fast library loaded,
   - makes regular (lisp) array with inexact components, if fast library not loaded.

So, briefly: *Maker* works as exact or inexact depending on *default-exactness* option, *Maker*~ always works as inexact, but depends on fast library existent.

## Other function naming conventions

The `(otus algebra)` functions begin with a capital letter to distinguish them from the ol functions which are in a lowercase.

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

## Notes

#### note 1
Why inexact number `#i1e14` prints as `1.0e14`, but `#i1e15` as `10.0e14`? Because of nature of imprecise hardware  calculations.
