(import (otus algebra))
(import (otus algebra unicode))
(import (otus algebra print))
(define algebra-environment *toplevel*)

(import (owl parse))
(import (lang sexp))
(import (scheme repl))

; color markers
(define red "\x1B;[22;31m")
(define green "\x1B;[22;32m")
(define end "\x1B;[0m")

; collects all ```scheme ... ``` code blocks
(define parser
(greedy+ (let-parse* (
      (text (let-parse* (
               (text (lazy* byte))
               (skip (word "```scheme" #f)))
            text))
      (code (let-parse* (
               (code (lazy* byte))
               (skip (word "  ```" #f)))
            code)))
   (append code '(#\newline)))))

(define sample
(greedy+ (let-parse* (
      (code (greedy+ (let-parse* (
               (skip (greedy+ whitespace-or-comment))
               (prefix (word "> " #t)) ; строка запроса
               (code sexp-parser)
               (skip (greedy+ (imm #\newline)))) ; trailing newlines
         code)))
      (answer (let-parse* (
            (skip (greedy+ whitespace)) ; leading spaces
            (text (lazy+ rune))
            (skip (word "\n\n" #t)))  ; обязательный маркер конца примера
         text)))
   (cons code answer))))

; evaluator
(import (lang eval))
(import (lang macro))
(define (eval exp env)
   (define repl__ (lambda (env in)
                     (repl env in evaluate)))
   (let loop ((exps exp) (env env) (out ""))
      (if (null? exps)
         ['ok out env]
         (let ((exp (car exps)))
            (case (eval-repl exp env repl__ evaluate)
               (['ok exp env]
                  (loop (cdr exps) env exp))
               (['fail reason]
                  (runtime-error red (list "ERROR: can't evaluate" exp))))))))

; -------------------------------------------------------
; fake random library
(define-library (otus random!)
(import (otus lisp))
(export rand! rand-reset!)
(begin
   (define seed '(6370020 . 100))

   (define rand!
      (lambda (limit)
         (let*((next (+ (car seed) (<< (cdr seed) 24)))
               (next (+ (* next 1103515245) 12345)))
            (set-car! seed (band     next     #xffffff))
            (set-cdr! seed (band (>> next 24) #xffffff))

            (mod (mod (floor (/ next 65536)) 32768) limit))))
   (define (rand-reset!)
      (set-car! seed 6370020)
      (set-cdr! seed 100))
))
(import (otus random!))

; -------------------------------------------------------
(define ok '(#true))

(for-each (lambda (filename)
   (print "testing " filename "...")
   (for-each (lambda (code-block)
         ;; (print "code-block")
         ;; (print (list->string code-block))
         (fold (lambda (env sample)
                  ;; (print "----------------")
                  (rand-reset!) ; restart random generator
                  (let*((code answer sample)
                        (answer (s/[ \n]+/ /g (list->string answer))))
                     (display  "  code: ") (display code)
                     (vector-apply (eval code env) (lambda (ok? test env)
                        ; (print "test: " test)
                        (define buffer (open-output-string))
                        (display-to buffer test)
                        (define actual (get-output-string buffer))

                        (if (string=? answer actual)
                           (print green " ok" end)
                        else
                           (print "    test error:")
                           (print "      " red actual " IS NOT EQUAL TO " answer end)
                           (set-car! ok #false))

                        env))))
            (interaction-environment)
            (car (try-parse sample code-block #f))))
      (car (try-parse parser (force (file->bytestream filename)) #f))))
   *vm-args*)
(exit (car ok))
