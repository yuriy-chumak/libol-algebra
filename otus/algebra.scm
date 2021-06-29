(define-library (otus algebra)
   ; TODO: ? change to (otus algebra linear)
   (version 0.1)
   (license MIT/LGPL3)
   (keywords (math algebra))
   (description "
      Otus-Lisp algebra library.")

(import
   (otus lisp))

(export

   tuple ; заменитель scheme (vector ...)

   @: ; математический макрос, позволяющий инфиксную нотацию
      ; кроме того, 2 выступает первым символом специальных математических функций (типа @summ, сами названия надо взять из TeX, там они начинаются с \)
   

   ;; целочисленную математику мы будем организовывать силами самого ol
   ;; это будет не быстро, но зато точно. само собой, большие матрицы/вектора/тензоры
   ;; реально обрабатывать не выйдет, но будет легко читаемый код с алгоритмами работы
   ;; (заодно и легче проверяемый)
   ;; быстрая, не целочисленная математика предваряется "i"

   type-tensor ; 28

   ; создать вектор, f for "Floating point"
   vector fvector
   ; создать матрицу
   matrix fmatrix
   ; создать тензор
   tensor ftensor

   ;; inexact-vector
   ;; ;; matrix
   ;; ;; inexact-matrix

   ;; ndarray

   ; The number of axes (dimensions) of the array.
   ; 'ndim' in numpy
   ;; ;ndim
   ;; ; use (size (dimension .))

   ; The dimensions of the array.
   ; a tuple of integers indicating the size of the array in each dimension.
   ; for a matrix with n rows and m columns, shape will be (n,m).
   dimension ; 'shape' in numpy

   ;; ; 
   ;; ;asize

   ;; ; redefine math operators
   ;; + - * /

   ;; ; dot-product
   ;; dot-product
   ;; dot @ ;⋅

   ;; ;× ÷

   ;; ; redefine printer
   ;; print

   ;; ; todo:
   ;; ; >>> # from start to position 6, exclusive, set every 2nd element to 1000
   ;; ; >>> a[:6:2] = 1000
)

(import (otus ffi))
(begin

   ; заменитель scheme (vector ...), если вдруг понадобится
   (define-syntax tuple
      (syntax-rules ()
         ((tuple . args)
            (vm:new type-vector . args))))

   ; floating point tensor type
   (define type-tensor 28)

   ; создание вектора заданных размеров
   (define (vector len)
      (make-vector len 0))

   (setq copy (lambda (o) (vm:cast o (type o)))) ; * internal

   ; создание (и инициализация, если вдруг) матрицы заданных размеров
   ; если первый элемент - вектор, то либо остальные тоже вектора, либо второй - количество столбцов, и эту строку надо размножить, либо второго нет и это транспонированный вектор (матрица из одной строки)
   (define (matrix . args)
      (unless (null? args)
         ; если первый элемент - вектор
         (if (vector? (car args))
         then
            ; транспонированный вектор, матрица из одной строки?
            (if (null? (cdr args))
               (car args)
            else
               ; число? значит количество столбцов
               (if (integer? (cadr args))
               then
                  (unless (null? (cddr args)
                     (runtime-error "После количества столбцов аргументы игнорируются" #f)))
                  (list->vector (map (lambda (_) (copy (car args))) (iota (cadr args))))
               else
                  (unless (all vector? (cdr args))
                     (runtime-error "Элементами матрицы могут быть только вектора" #f))
                  (list->vector (map (lambda (row)
                                       (unless (eq? (size row) (size (car args)))
                                          (runtime-error "Элементами матрицы могут быть только вектора одинакового размера. Проблемный вектор: " row))
                                       row)
                                 args))))
         else
            (unless (and
                        (eq? (length args) 2)
                        (integer? (car args))
                        (integer? (cadr args)))
               (runtime-error "неправильно заданные парамтры. смотрите хелп." args))
            (list->vector (map (lambda (_) (make-vector (cadr args) 0)) (iota (car args)))))))

   ; пока что тензор умеет только создавать по размерам
   (define (tensor . args)
      (if (and
            (null? (cdr args))
            (vector? (car args)))
         (car args)
      else
         (define dimension (reverse args))
         (fold (lambda (t arg)
                  (list->vector (map (lambda (_)
                     (copy t)) (iota arg))))
            (make-vector (car dimension) 0)
            (cdr dimension))))


   (define algebra (dlopen "libol-algebra.so"))
   (unless algebra
      (runtime-error "libol-algebra.so not found. Please, install one. For example 'kiss i libol-algebra'."
                     "https://github.com/yuriy-chumak/ol-packages"))

   (define fvector #false)
   (define fmatrix #false)

   (define ftensor (dlsym algebra "create_tensor"))
   (print "ftensor: " ftensor)

   (define fdimension (dlsym algebra "dimension"))
   (define (dimension array)
      (case (type array)
         (type-vector
            (let loop ((el (ref array 1)) (dim (list (size array))))
               (if (not (vector? el))
                  then (list->vector (reverse dim))
               else
                  (loop (ref el 1) (cons (size el) dim)))))
         (type-tensor
            (fdimension array))))

   ;; (define + +)
   ;; (define - -)
   ;; (define * *)
   ;; (define / /)

   ;; (define (dot-product a b)
   ;;    #f
   ;; )

   ;; (define dot dot-product)
   ;; (define @ dot)

   ;; todo: move to (otus algebra infix-notation)
   (define-syntax @:
      (syntax-rules (+ - * /)
         ((@: . x)
            ( . x))))
))
