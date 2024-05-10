(define-library (otus algebra functions)
   (description "Mathematical Functions")

(import
   (otus lisp)
   (otus algebra core))

(export
   ; trigonometric functions
   Sin Sin! Sine Sine!
   Cos Cos! Cosine Cosine!
   Tan Tan! Tangent Tangent!
   ; cosecant, secant, cotangent

   ; activation functions
   Logistic Logistic!
   DLogisticDx_Logistic DLogisticDx_Logistic!
)

(begin
   (import
      (otus algebra config))

   ;; ---------------
   ;; trigonometric functions
   (import (scheme inexact))

   (define-macro DECLARE1 (lambda (name fnc native)
   `  (define ,name
         (letrec ((fast (dlsym algebra ,native))
                  (lisp (lambda (array)
                           (cond
                              ((scalar? array)
                                 (,fnc array))
                              ((vector? array)
                                 (rmap ,fnc array))
                              ((tensor? array)
                                 (fast array))))))
            (if (config 'default-exactness algebra) lisp (if algebra fast lisp))))
      ))

   ; available only for native code
   (define-macro DECLARE! (lambda (name native)
   `  (define ,name
         (letrec ((fast (dlsym algebra ,native)))
            (if algebra fast Unavailable)))
      ))

   ; -=( Sin )=------------------------
   (DECLARE1 Sin sin "Sine") (DECLARE! Sin! "SineE")
   (define Sine Sin) (define Sine! Sin!)

   ; -=( Cos )=------------------------
   (DECLARE1 Cos cos "Cosine") (DECLARE! Cos! "CosineE")
   (define Cosine Cos) (define Cosine! Cos!)

   ; -=( Tan )=------------------------
   (DECLARE1 Tan tan "Tangent") (DECLARE! Tan! "TangentE")
   (define Tangent Tan) (define Tangent! Tan!)

   ; ========================================================================
   ; -=( Logistic function )=----------
   (define (logistic x)
      (/ 1 (+ 1 (exp (negate x)))))
   (define (dlogistic_dx_logistic g)
      (* g (- 1 g)))

   (DECLARE1 Logistic logistic "Logistic")
   (DECLARE! Logistic! "LogisticE")

   ; derivatives
   (DECLARE1 DLogisticDx_Logistic dlogistic_dx_logistic "DLogisticDx_Logistic")
   (DECLARE! DLogisticDx_Logistic! "DLogisticDx_LogisticE")
   
))
