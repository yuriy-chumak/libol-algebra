(define-library (otus algebra macros)

(import
   (otus lisp)
   (otus algebra core))

(export
   define-unary-function
   define-binary-function
)

(begin

   (define-macro define-unary-function (lambda (name olf native)
   `  (define ,name
         (letrec ((fast (dlsym algebra ,native))
                  (lisp (lambda (array)
                           (cond
                              ((vector? array)
                                 (rmap ,olf array))
                              ((tensor? array)
                                 (fast array))
                              ((scalar? array)
                                 (,olf array)) ))))
            ,(if (config 'default-exactness algebra) 'lisp (if algebra 'fast 'lisp))))
      ))

   (define-macro define-binary-function (lambda (name olf native)
   `  (define ,name
         (letrec ((fast (dlsym algebra ,native))
                  (lisp (lambda (a b)
                           (cond
                              ((vector? a)
                                 (cond
                                    ((vector? b) (rmap ,olf a b))
                                    ((tensor? b) (rmap ,olf a b))
                                    ((scalar? b) (rmap (lambda (a) (,olf a b)) a)) ))
                              ((tensor? a)
                                 (cond
                                    ((vector? b) Unimplemented) ; todo
                                    ((tensor? b) (fast a b))
                                    ((scalar? b) (fast a b)) )) ; todo: test this
                              ((scalar? a)
                                 (cond
                                    ;; здесь мы допустим некоторые условности,
                                    ;; в случае "скаляр x вектор" мы расширяем скаляр до вектора
                                    ;; хотя это и неправильно.
                                    ((vector? b) (rmap (lambda (b) (,olf b a)) b)) ; ассоциативность
                                    ((tensor? b) (fast b a))
                                    ((scalar? b) (,olf a b)) )) ))))
            ,(if (config 'default-exactness algebra) 'lisp (if algebra 'fast 'lisp))))
      ))

))
