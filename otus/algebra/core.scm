(define-library (otus algebra core)

(import
   (otus lisp)
   (otus algebra config)
   (otus ffi))

; * all exports are algebra internal
(export
   algebra ; optimized "C" code shared library
   Unavailable Unimplemented

   ; v/m/t aka array is a basic math object.

   ; создать вектор (Euclidean)
   evector ivector Vector Vector~
   ; создать матрицу
   ematrix imatrix Matrix Matrix~
   ; создать тензор (многомерную матрицу)
   etensor itensor Tensor Tensor~

   ; предикаты (для внутреннего пользования)
   scalar? vector? tensor?

   ; helper functions
   ~create
   rmap ~map ; recursive map, inexact map
   rref ~ref ; recursive ref, inexact ref
   rfold)

(begin
   (define algebra (dlopen "libol-algebra.so"))
   (unless algebra
      (print-to stderr "Warning: 'libol-algebra' shared library is not found.
      Please install one, otherwise fast math will be unavailable.
      https://github.com/yuriy-chumak/libol-algebra"))

   (define (Unavailable . args)
      (runtime-error "'libol-algebra' library is not loaded!" "Function unavailable."))
   (define (Unimplemented . args)
      (runtime-error "Function is not implemented." "Sorry."))
   (define (Invalid . args)
      (runtime-error "Invalid function use" #n))

   (define ~create (dlsym algebra "Tensor")) ; dims, data|0
   (define ~ref (dlsym algebra "Ref"))
   (define ~map (dlsym algebra "Map"))

   ; ----------------
   (define (scalar? s)
      (number? s))
   
   (setq vector? vector?) ; lisp vector

   (define (tensor? t)    ; c vector
      (and
         (eq? (type t) type-pair)
         (eq? (type (cdr t)) type-bytevector)))

   ;; (define (matrix? t)    ; internal

   ; note: we can compare sizes, btw.


   ; ================================================================
   ; --------------------
   (define (rref array . args)
      (let loop ((array array) (args args))
         (if (null? args)
            array
         else
            (loop (ref array (car args)) (cdr args)))))

   (define ~map (dlsym algebra "Map"))
   (define rmap
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
               ((tensor? array1)
                  ; todo: handle tensor+vector
                  (f array1 array2))

               (else
                  (runtime-error "TBD" f))))
         ((f . arrays)
            ; TODO: test all arguments the same size
            ; TODO: if different types - cast to the the first argument type
            (cond
               ((vector? (car arrays))
                  (let loop ((arrays arrays))
                     (define (reloop . args) (loop args))
                     (if (vector? (ref (car arrays) 1))
                        (apply vector-map (cons reloop arrays))
                     else
                        (apply vector-map (cons f arrays)))))
               (else
                  (runtime-error "TBD" f)))) ))

   ; ================================================================
   ; универсальные функции создания массивов

   (setq shallowcopy (lambda (o) (vm:cast o (type o)))) ; * internal
   (define (deepcopy o) ; * internal
      (if (vector? o)
         (vector-map deepcopy o)
         (shallowcopy o)))

   ; exact (lisp) tensor creation
   (define (etensor . args)
      (foldr (lambda (dim tail)
            (if (vector? dim)
            ;  (deepcopy dim)
               dim
            else
               (list->vector (map (lambda (i) (deepcopy tail)) (iota dim)))))
         0
         args))

   ; inexact (c) tensor creation
   (define (itensor . args)
      (define dimensions
         (foldr (lambda (x tail)
               (if (vector? x) ; вектор всегда последний
                  (reverse (let loop ((x (ref x 1))
                                    (out (cons (size x) #n)))
                     (if (vector? x)
                        (loop (ref x 1) (cons (size x) out))
                        out)))
                  (cons x tail)))
            #null
            args))
      (unless (equal? dimensions '(#f))
         (cons dimensions (~create dimensions args))))

   ; public:
   (define Tensor~ (if algebra itensor etensor))
   (define Tensor (if (config 'default-exactness algebra) etensor Tensor~))

   ; -- matrix -----------------------------------
   ; создание (и инициализация, если есть чем) матрицы заданных размеров
   ; если первый элемент - вектор, то это матрица; иначе количество строк
   ; если второй элемент - вектор, то это строка и ее надо размножить на количество строк
   ; если второй элемент - число, то создаем пустую матрицу rows * cols
   (define ematrix (case-lambda
      ; todo: assertions
      ((matrix)  matrix)
      ((rows columns)
         (if (vector? columns)
            (list->vector (map (lambda (i) (deepcopy columns)) (iota rows)))
         else
            (list->vector (map (lambda (i) (make-vector columns 0)) (iota rows))))) ))

   (define imatrix (case-lambda
      ; todo: assertions
      ((matrix) (itensor matrix))
      ((rows columns)
         (itensor rows columns))))

   ; public:
   ; TODO: change like Vector
   (define Matrix~ (if algebra imatrix ematrix))
   (define Matrix (if (config 'default-exactness algebra) ematrix Matrix~))

   ; -- vector -----------------------------------
   (define (evector arg)
      (if (vector? arg)
         arg
      else
         (make-vector arg 0)))

   (define (ivector dim)
      (assert (or
         (scalar? dim)
         (and (vector? dim) (scalar? (ref dim 1)))))
      (itensor dim))

   ; public:
   (define Vector~ (if algebra ivector (lambda args (rmap inexact (apply evector args)))))
   (define Vector (if (config 'default-exactness algebra) evector Vector~))

   ; -------------------------------------------
   ;(define ~fold (dlsym algebra "Fold"))
   (define rfold
      (case-lambda
         ((f S array)
            (cond
               ((vector? array)
                  (let loop ((S S) (array array))
                     (if (vector? (ref array 1))
                        (vector-fold loop S array)
                     else
                        (vector-fold f S array))))
               (else
                  (runtime-error "TBD" f))))
         ((f S array1 array2)
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
         ((f S . arrays)
            ; TODO: test all arguments the same size
            ; TODO: if different types - cast to the the first argument type
            (cond
               ((vector? (car arrays))
                  (let loop ((arrays arrays))
                     (define (reloop . args) (loop args))
                     (if (vector? (ref (car arrays) 1))
                        (apply vector-map (cons reloop arrays))
                     else
                        (apply vector-map (cons f arrays)))))
               (else
                  (runtime-error "TBD" f)))) ))

))
