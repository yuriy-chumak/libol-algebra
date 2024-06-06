(import (otus algebra))
(import (otus algebra unicode))
(import (otus algebra print))
(define algebra-environment *toplevel*)

(import (owl parse))
(import (lang sexp))
(import (scheme repl))

(import (only (otus algebra core) tensor?))

; color markers
(define red "\x1B;[22;31m")
(define green "\x1B;[22;32m")
(define end "\x1B;[0m")

; collects all ```scheme ... ``` code blocks
(define parser
(greedy+ (let-parse* (
      (text (let-parse* (
               (text (lazy* byte))
               (skip (word "```scheme\n" #f)))
            text))
      (code (let-parse* (
               (code (lazy* byte))
               (skip (word "```\n" #f)))
            code)))
   (append code '(#\newline #\newline)))))

(define samples
(either
   (greedy+ (let-parse* (
         (code (greedy+ (let-parse* (
                  (skip (greedy* whitespace-or-comment))
                  (prefix (word "> " #t)) ; строка запроса
                  (code sexp-parser)
                  (skip (greedy+ (imm #\newline)))) ; trailing newlines
            code)))
         (answer (let-parse* (
               (skip (greedy* whitespace)) ; leading spaces
               (text (lazy+ rune))
               (skip (word "\n\n" #t)))  ; обязательный маркер конца примера
            text)))
      (cons code answer)))
   (epsilon '())
))

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

(define dup (case-lambda
   ((p) (syscall 32 p))
   ((p1 p2) (syscall 32 p1 p2))))

; -------------------------------------------------------
(define ok '(#true))

(for-each (lambda (filename)
   (for-each display (list "testing " filename "..."))
   (for-each (lambda (code-block)
         ;; (print "code-block")
         ;; (print (list->string code-block))
         (fold (lambda (env sample)
                  ;; (print "----------------")
                  (rand-reset!) ; restart random generator
                  (let*((code answer sample)
                        (answer (s/[ \n]+$//
                                (s/[ \n]+/ /g (list->string answer)))))
                     (write-char #\. stderr)
                     ;; (display  "  code: ") (write code) (newline)
                     ; handle special case with "Print"
                     (define stdout-new
                        (when (member (ref (last code) 1) '(print Print))
                           (define bak (dup stdout))
                           (define port (open-output-string))
                           (dup port stdout)
                           [port bak]))
                     (vector-apply (eval code env) (lambda (ok? test env)
                        (define actual (s/[ \n]+$// ; remove trailing newline
                           (if stdout-new
                              ; handle special case with "Print"
                              (vector-apply stdout-new (lambda (port bak)
                                 ;; todo: flush
                                 (dup bak stdout)
                                 (close-port bak)
                                 (get-output-string port)))
                           else
                              ; common case with returned value
                              (define bak (dup stdout))
                              (define buffer (open-output-string))
                              (dup buffer stdout)
                              ;; (if (tensor? test)
                                 ;; (print-to stderr "test: " test)
                                 (Print test)
                              ;;    (write-simple test))
                              (dup bak stdout)
                              (close-port bak)
                              (get-output-string buffer)) ))

                           ;; (when stdout-new
                        ;; (print)
                        ;; (print "actual: <" actual ">")
                        ;; (print "answer: <" answer ">")

                        (if (string=? answer actual)
                           #t ;(print green " ok" end)
                        else
                           (print "    test error:")
                           (print "      " red actual " IS NOT EQUAL TO " answer end)
                           (set-car! ok #false))

                        env))))
            (interaction-environment)
            (car (try-parse samples code-block #f))))
      (car (try-parse parser (force (file->bytestream filename)) #f)))
      (if (car ok)
         (print green " ok" end)))
   *vm-args*)
(exit (car ok))
