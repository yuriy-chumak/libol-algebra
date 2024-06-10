(define-library (otus algebra core)

(import
   (otus lisp)
   (otus algebra config))

; * all exports are algebra internal
(export
   algebra ; optimized ("C") shared library
   Unavailable Unimplemented

   ; v/m/t aka array is a basic math object
   Array Array~
   earray iarray array~ ; * internal

   ; создать вектор (Euclidean)
   evector ivector Vector Vector~
   ; создать матрицу
   ematrix imatrix Matrix Matrix~
   ; создать тензор (многомерную матрицу)
   Tensor Tensor~

   ; предикаты (для внутреннего пользования)
   scalar? vector? tensor?

   ; helper functions
   ~new

   ; ------------------------------------
   ; The dimension of the array.
   ; A list of integers indicating the size of the array in each dimension.
   ;  for a matrix with n rows and m columns, shape will be '(n m).
   Shape ; "форма" тензора, его "размерность"
         ; always a list
   Size  ; The count of all elements in the v/m/t.
   ; The number of axes (dimensions) of the array:
   ; use `(size (Shape .))

   ; ------------------------------------
   rref ~ref ; recursive ref, inexact ref
   rmap ~map ; recursive map, inexact map
   rfold)

(begin
   (define algebra (or
      (dlopen "libol-algebra.so") ; Linux
      (dlopen "libol-algebra.dll"); Windows
      (dlopen "libol-algebra.dylib"); macOS
   ))
   (unless algebra
      (unless (config 'no-startup-warnings #f)
         (print-to stderr "Warning: 'libol-algebra' shared library is not found.
      Please install one, otherwise fast math will be unavailable.
      https://github.com/yuriy-chumak/libol-algebra")))

   (define (Unavailable . args)
      (runtime-error "'libol-algebra' library is not loaded!" "Function unavailable."))
   (define (Unimplemented . args)
      (runtime-error "Function is not implemented." "Sorry."))
   ;; (define (Invalid-function-use-error . args)
   ;;    (runtime-error "Invalid function use"))

   (define ~new (dlsym algebra "New")) ; dims, data|0
   (define ~ref (dlsym algebra "Ref"))

   ; ----------------
   (define (scalar? s)
      (number? s))
   
   (setq vector? vector?) ; lisp vector

   (define (tensor? t)    ; c vector
      (and
         (eq? (type t) type-pair)
         (eq? (type (cdr t)) type-bytevector)))

   ; ================================================================
   ; универсальные функции создания массивов

   ; inexact (lisp) array creation
   (setq shallowcopy (lambda (o) (vm:cast o type-inexact)))
   (define (deepcopy o) ; * internal
      (if (vector? o)
         (vector-map deepcopy o)
         (shallowcopy o)))

   (define (iarray . args)
      (foldr (lambda (dim tail)
            (if (vector? dim)
               (deepcopy dim)
            else
               (list->vector (map (lambda (i) (deepcopy tail)) (iota dim)))))
         0
         args))

   ; exact (lisp) array creation
   (setq shallowcopy (lambda (o) (vm:cast o (type o)))) ; * internal
   (define (deepcopy o) ; * internal
      (if (vector? o)
         (vector-map deepcopy o)
         (shallowcopy o)))

   (define (earray . args)
      (foldr (lambda (dim tail)
            (if (vector? dim)
               (deepcopy dim)
            else
               (list->vector (map (lambda (i) (deepcopy tail)) (iota dim)))))
         0
         args))

   ; inexact (c) array creation
   (define (array~ . args)
      (define dimensions
         (foldr (lambda (x tail)
               (cond
                  ((vector? x) ; вектор всегда последний
                     (reverse (let loop ((x (ref x 1))
                                       (out (cons (size x) #n)))
                        (if (vector? x)
                           (loop (ref x 1) (cons (size x) out))
                           out))))
                  ((tensor? x)
                     (append (car x) tail))
                  ((scalar? x)
                     (cons x tail))))
            #null
            args))
      (unless (equal? dimensions '(#f))
         (cons dimensions (~new dimensions args))))

   ; public:
   (define Array~ (if algebra array~ iarray))
   (define Array (if (config 'default-exactness) earray Array~))

   ; ================================================================
   ; shape and size
   (define (shape array) ; c array shape
      (let loop ((el (ref array 1)) (dim (list (size array))))
         (if (not (vector? el)) then
            (reverse dim)
         else
            (loop (ref el 1) (cons (size el) dim)))))

   (define (Shape array)
      (cond
         ((vector? array) ; builtin array
            (shape array))
         ((tensor? array) ; external data
            (car array))))


   (define (Size array)
      (fold * 1 (Shape array)))

   ; ================================================================
   ; -=( Map )=------
   ;            Одна из базовейших функций алгебры

   (define ~map (dlsym algebra "Map"))
   (define rmap
      (case-lambda
         ((f) [])
         ((f array)
            (cond
               ((vector? array)
                  (let loop ((array array))
                     (if (vector? (ref array 1))
                        (vector-map loop array)
                     else
                        (vector-map f array))))
               ((tensor? array)
                  (~map f array))
               (else
                  (runtime-error "Map accepts only arrays"))))
         ((f array1 array2)
            (if (equal? (Shape array1) (Shape array2))
               (cond
                  ((vector? array1)
                     (cond
                        ; vector & vector
                        ((vector? array2)
                           (let loop ((array1 array1) (array2 array2))
                              (if (vector? (ref array1 1))
                                 (vector-map loop array1 array2)
                              else
                                 (vector-map f array1 array2))))
                        ; vector & tensor
                        ((tensor? array2)
                           (~map f (array~ array1) array2))
                        (else
                           (runtime-error "Map accepts only arrays"))))
                  ((tensor? array1)
                     (cond
                        ; tensor & vector
                        ((vector? array2)
                           (~map f array1 (array~ array2)))
                        ; tensor & tensor
                        ((tensor? array2)
                           (~map f array1 array2))
                        (else
                           (runtime-error "Map accepts only arrays"))))
                  (else
                     (runtime-error "Map accepts only arrays")))
               (runtime-error "Both arrays must have same shapes")))
         ((f . arrays) ; ???, todo: change to (f array1 . arrays)
            ; all shapes must be equal
            (define shapes (map Shape arrays))
            (define shape-a (car shapes))
            (for-each (lambda (shape)
                  (unless (equal? shape shape-a)
                     (runtime-error "All arrays must have same shapes")))
               (cdr shapes))
            ; TODO: if some array is tensor, cast all to the tensors
            (cond
               ((some tensor? arrays)
                  (apply ~map (cons f (map (lambda (array)
                                             (if (tensor? array) array (array~ array)))
                                          arrays))))
               ((vector? (car arrays))
                  (let loop ((arrays arrays))
                     (define (reloop . arrays) (loop arrays))
                     (if (vector? (ref (car arrays) 1))
                        (apply vector-map (cons reloop arrays))
                     else
                        (apply vector-map (cons f arrays)))))
               (else
                  (runtime-error "Map accepts only arrays")))) ))

   ; - rref -------------------
   (define (rref array . args) ; todo: move it to another place
      (let loop ((array array) (args args))
         (if (null? args)
            array
         else
            (loop (ref array (car args)) (cdr args)))))

   ; -- vector -----------------------------------
   (define (evector arg)
      (if (vector? arg)
         arg
      else
         (make-vector arg 0)))

   (define (ivector arg)
      (rmap inexact (evector arg)))

   (define (vector~ dim)
      (assert (or
         (scalar? dim)
         (and (vector? dim)
              (scalar? (ref dim 1)))))
      (array~ dim))

   ; public:
   (define Vector~ (if algebra vector~ ivector))
   (define Vector (if (config 'default-exactness) evector Vector~))

   ; -- matrix -----------------------------------
   ; создание (и инициализация, если есть чем) матрицы заданных размеров
   ; если первый элемент - вектор, то это матрица; иначе количество строк
   ; если второй элемент - вектор, то это строка и ее надо размножить на количество строк
   ; если второй элемент - число, то создаем пустую матрицу rows * cols
   (define ematrix (case-lambda
      ; todo: assertions
      ((matrix)
         (cond
            ((scalar? matrix)
               [[matrix]])
            ((vector? matrix)
               (rmap idf matrix))
            ;; ((tensor? matrix)
            ;;    ()
         )
        matrix)
      ((rows columns)
         (if (vector? columns)
            (list->vector (map (lambda (i) (deepcopy columns)) (iota rows)))
         else
            (list->vector (map (lambda (i) (make-vector columns 0)) (iota rows))))) ))

   (define imatrix (case-lambda
      ; todo: assertions
      ((matrix) (iarray matrix))
      ((rows columns)
         (iarray rows columns))))

   (define matrix~ array~)

   ; public:
   (define Matrix~ (if algebra matrix~ imatrix))
   (define Matrix (if (config 'default-exactness) ematrix Matrix~))

   ; -- tensor -----------------------------------
   (define Tensor~ Array~)
   (define Tensor Array)

   ; ================================================================


))
