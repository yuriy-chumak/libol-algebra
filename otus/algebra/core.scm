(define-library (otus algebra core)

(import
   (otus lisp)
   (otus ffi))

(export

   ; создать вектор (Euclidean)
   evector ivector

   ; создать матрицу
   ematrix imatrix

   ; создать тензор
   etensor itensor

   scalar? vector? tensor? copy
   ; TODO: rename tensor? to some internal name

   algebra ; ffi
   mmap
)

(begin
   (define algebra (dlopen "libol-algebra.so"))
   (unless algebra
      (runtime-error "libol-algebra.so not found. Please, install one. For example 'kiss i libol-algebra'."
                     "https://github.com/yuriy-chumak/ol-packages"))

   (define ~create (dlsym algebra "create"))
   (define ~at (dlsym algebra "at"))


   ; floating point tensor type
   (define type-tensor 28)

   (define (scalar? s)
      (number? s))
   (define vector? vector?)
   (define (tensor? t)
      (eq? (type t) type-tensor))

   ; ================================================================
   ; создание вектора заданных размеров
   (define (evector len)
      (make-vector len 0))

   (setq copy (lambda (o) (vm:cast o (type o)))) ; * internal

   ; создание (и инициализация, если вдруг) матрицы заданных размеров
   ; если первый элемент - вектор, то либо остальные тоже вектора, либо второй - количество столбцов, и эту строку надо размножить, либо второго нет и это транспонированный вектор (матрица из одной строки)
   (define (ematrix . args)
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
   (define (etensor . args)
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

   ; ...
   (define itensor ~create)

   (define (ivector size)
      (itensor size))

   (define imatrix #false)
   (define mmap
      (case-lambda
         ((f array)
            (cond
               ((vector? array)
                  (let loop ((array array))
                     (if (vector? (ref array 1))
                        (vector-map loop array)
                     else
                        (vector-map f array))))
               (else
                  (runtime-error "TBD" f))))
         ((f array1 array2)
            ; TODO: test all arguments the same size
            ; TODO: if different types - cast to the the first argument type
            (cond
               ((vector? array1)
                  (let loop ((array1 array1) (array2 array2))
                     (if (vector? (ref array1 1))
                        (vector-map loop array1 array2)
                     else
                        (vector-map f array1 array2))))
               (else
                  (runtime-error "TBD" f))))
         ((f . arrays)
            (runtime-error "TBD" f))))
))
