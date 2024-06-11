(define-library (otus algebra)
   ; TODO: ? change to (otus algebra linear)
   (version 0.1)
   (license MIT/LGPL3)
   (keywords (math algebra))
   (description "
      Otus-Lisp algebra library.")

(import
   (otus lisp))
(import
   (otus algebra core)
   (otus algebra shape)

   (otus algebra init)
   (otus algebra fold)

   (otus algebra scalar)
   (otus algebra vector)
   (otus algebra matrix)

   (otus algebra operators)
   (otus algebra functions)

   ; math notations:
   (math infix-notation))

(export

   ;; целочисленную математику мы будем организовывать силами самого ol
   ;; это будет не быстро, но зато точно. само собой, большие матрицы/вектора/тензоры
   ;; реально обрабатывать не выйдет, но будет легко читаемый код с алгоритмами работы
   ;; (заодно и легче проверяемый)
   ;; точная, но медленная предваряется "e" (exact)
   ;; быстрая, неточная математика предваряется "i" (inexact) или "f" (floating point, fast)

   Scalar?

   ; same as Tensor/Tensor~
   Array
   Array~
   Array?

   ; create a Vector
   Vector ; exact vector (lisp)
   Vector~ ; inexact vector (c)
   Vector? ; is a vector?

   ; create a Matrix
   Matrix ; exact matrix (lisp)
   Matrix~ ; inexact matrix (c)
;   Matrix?

   ; create a Tensor
   Tensor ; exact tensor (lisp)
   ;; Tensor~ ; inexact tensor (c)
   ;; Tensor?

   ; get an element
   Ref

   (exports (otus algebra scalar))
   (exports (otus algebra vector))
   (exports (otus algebra matrix))

   (exports (otus algebra init))
   (exports (otus algebra fold))

   (exports (otus algebra operators))
   (exports (otus algebra functions))

   Shape Size
   (exports (otus algebra shape))

   rmap ; Recursive Map, * core, * internal

   ;; print-ftensor

   ;; ; redefine math operators
   ;; + - * /

   ;; ; dot-product
   ;; dot-product
   ;; dot @ ;⋅

   ;; ; todo:
   ;; ; >>> # from start to position 6, exclusive, set every 2nd element to 1000
   ;; ; >>> a[:6:2] = 1000

   ; REPL upgrade:
   repl:write

   ; (math infix-notation) upgrade:
   \\ infix-notation
   \\operators
   \\right-operators
   \\postfix-functions

   ; equation overrides
   = ≠ equal?
)

(import
   (otus algebra config))
(begin

   ; startup notification
   (unless (config 'default-exactness algebra)
      (unless (config 'no-startup-warnings #f)
         (print-to stderr "Warning: you'r requested inexact math usage by default,")
         (if algebra
            (print-to stderr "      calculated results may be inaccurate.")
            (print-to stderr "      but the shared library is not loaded, so that kind of math won't be included."))))

   ; array? / scalar?
   (define (Array? obj)
      (or (vector? obj)
          (tensor? obj)))
   (define Scalar? number?)
   (define (Vector? obj) ()) ; TBD.
   ;Matrix?
   ;Tensor?

   ; todo: make returning rows from matrices, etc
   (define (Ref array . index)
      (apply (cond
            ((vector? array) rref)
            ((tensor? array) ~ref))
         (cons array index)))

   (define Fold rfold)
   
   ;; (define + +)
   ;; (define - -)
   ;; (define * *)
   ;; (define / /)

   ;; (define (dot-product a b)
   ;;    #f
   ;; )

   ;; (define dot dot-product)
   ;; (define @ dot)

   ;; ;; ???
   ;; ;; TODO: update
   ;; (define (pp array dims)
   ;;    (if (null? dims)
   ;;    then
   ;;       (display array)
   ;;       (display " ")
   ;;    else
   ;;       (display "[ ")
   ;;       (for-each (lambda (i)
   ;;             (pp (ref array i) (cdr dims)))
   ;;          (iota (car dims)))
   ;;       (display "] ")))

   ;; (define (print-ftensor tensor)
   ;;    (define dim (Shape tensor))
   ;;    (pp tensor dim))

   ;; (define ::print print)
   ;; (define (print . args)
   ;;    (for-each (lambda (arg)
   ;;          (cond
   ;;             ((tensor? arg)
   ;;                (print-ftensor arg))
   ;;             (else
   ;;                (display arg))))
   ;;       args)
   ;;    (display (string #\newline)))

   ;; upgrade REPL interactive output
   (define self-quoting? (write-format-ff 'self-quoting?))
   (define (cook-number number first? k)
      (if first?
         (format-number number k 10)
         (cons* #\space (format-number number k 10))))

   (define (cook-array this obj k)
      ; this is a fast native tensor, render it!
      (define indices (Shape obj))
      (define (format index indices first? tl)
         (if (null? indices)
         then
            (define number (apply Ref (cons obj index)))
            (if first?
               (format-any number tl)
               (cons* #\space (format-any number tl)))

         else
            (define last (car indices))
            (define (cycle)
               (let loop ((i 1))
                  (if (> i last)
                     (cons #\] tl) ; done
                     (format (append index (list i))
                           (cdr indices)
                           (= i 1)
                           (delay (loop (+ i 1)))))))
            (if first?
               (cons* #\[ (cycle))
               (cons* #\space #\[ (cycle)))))
         (format '() indices #true k))

   (define repl:write {
      ; ()
      1 (lambda (this obj k)
         (if (tensor? obj)
            (cook-array this obj k)
            ((write-format-ff 1) this obj k)))
      ; []
      2 (lambda (this obj k)
         (cook-array this obj k))

      ; no need to quote tensors
      'self-quoting? (lambda (this obj)
                        (if (tensor? obj)
                           #true
                           (self-quoting? this obj)))

   })

   ; update math infix-notation with unicode operators
   (define \\operators (ff-replace \\operators {
      ; todo.
   }))
   (define \\postfix-functions (ff-replace \\postfix-functions {
      ; power
      '¹ #t  '² #t  '³ #t
      '⁴ #t  '⁵ #t  '⁶ #t  '⁷ #t  '⁸ #t  '⁹ #t
      '⁰ #t
   }))
   
   ; universal comparator
   (define = (case-lambda
      ; likely case
      ((a b)
         (if (and (Array? a) (Array? b))
            (if (equal? (Shape a) (Shape b))
               (if (tensor? a)
                  (if (tensor? b)
                     (equal? a b)
                     (equal? a (array~ b)))
                  (if (tensor? b)
                     (equal? (array~ a) b)
                     (call/cc (lambda (ret)
                        (rmap (lambda (a b)
                                 (unless (= a b) (ret #false)))
                           a b)
                        #true)))))
            (= a b)))
      ; other cases
      ((a) #true)
      ((a . args)
         (if (each Array? (cons a args))
            (call/cc (lambda (ret)
               (for-each (lambda (b)
                     (unless (= a b)
                        (ret #false)))
                  args)
               #true))
            (apply = (cons a args))))
   ))

   (define (≠ . args)
      (not (apply = args)))

   (define /equal? equal?)
   (define (equal? a b)
      (if (and (Array? a) (Array? b))
         (= a b)
         (/equal? a b)))
))
