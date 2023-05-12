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
