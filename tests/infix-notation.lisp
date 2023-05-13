(import (otus algebra))
(import (lang eval))

(setq RED "\e[0;31m")
(setq GREEN "\e[0;32m")
(setq BLUE "\e[0;34m")
(setq MAGENTA "\e[0;35m")
(setq CYAN "\e[0;36m")
(setq YELLOW "\e[0;33m")
(setq WHITE "\e[0;37m")
(setq END "\e[0;0m")

(define-lazy-macro (TEST str = expected)
   (begin
      (display BLUE) (display str) (display END)
      (display "  -->  ")
      (define-values (ok value)
         (vector-apply (repl-port current-environment (open-input-string
                           (string-append "(infix-notation " str ")")))
         (lambda (ok value) (values ok value))))
      (define result (ref (eval expected current-environment) 2))

      (display (cond
         ((not (eq? ok 'ok))    RED)
         ((equal? value result) GREEN)
         (else                  RED)))

      (repl-port current-environment (open-input-string
         (string-append ",expand (infix-notation " str ")")))

      (unless (equal? value result) ; if invalid value
         (print WHITE "   expected " GREEN result WHITE " but got " RED value))
      (display END) ))

(define-macro DEFINE (lambda (name value)
   (print YELLOW "> " name " = " value END)
   `(define ,name ,value)))

; =============================================================================
(import (scheme inexact))
(import (otus algebra unicode))

(print "defines:")
(DEFINE A₁ 12)
(DEFINE A₂ 7)
(DEFINE C 111)
(print)

(print "evaluations:")
; simple
(TEST "1" = 1)
(TEST "1 + 2" = 3)
(TEST "1 + 2 + 3" = 6)
(TEST "1 + 2 + 3 + 4" = 10)
(TEST "1 + 2 - 3" = 0)
(TEST "1 - 3 + 2" = 0)
(TEST "1 + 2 * 3 + 4" = 11)
(TEST "(1 + 2) * (3 + 4)" = 21)
(TEST "1 + 2 * 3 / 4" = 2.5)
(TEST "1 + 2 * 3 / 4 + 5" = 7.5)
(TEST "2 ** 3 ** 4" = 2417851639229258349412352)

(TEST "A₁ + A₂ * A₂ / C" = 1381/111) ; 12 + 49/111
(TEST "12 + 49/111" = 1381/111)
(TEST "12 + 49 / 111" = 1381/111)
(TEST "12 + 49 : 111" = 1381/111)
(TEST "(12 + 49) / 111" = 61/111)
(TEST "7 + (12 + 49) / 111" = 838/111)
(TEST "sin(1)" = (sin 1))
(TEST "Sqrt(4)" = 2)
(TEST "Sqrt([1 (1 + 2) 3 4])" = [(sqrt 1) (sqrt 3) (sqrt 3) (sqrt 4)])
(TEST "Sqrt([1, (1 + 2), 3, 4])" = [(sqrt 1) (sqrt 3) (sqrt 3) (sqrt 4)])
(TEST "√(12321)" = 111)
(TEST "[1 2 3] + [5 6 7]" = [6 8 10])

(DEFINE x 7)
(TEST "A₁ * x * x + A₂ * sin(x) + C" = (+ 699 (* A₂ (sin 7))))

(DEFINE one (lambda () 1))
(TEST "7 + one() + 8" = 16)
