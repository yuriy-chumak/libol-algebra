# 

ok:="\033[1;32mok\033[0m"
failed:="\033[1;31mfailed\033[0m"

define CHECK_REFERENCE
	(import (owl parse))
	(import (lang sexp))

	; collects all ```scheme ... ``` code blocks
	(define parser
	(greedy+ (let-parse* (
			(text (let-parse* (
						(text (lazy* byte))
						(skip (word "```scheme" #f)))
					text))
			(code (let-parse* (
						(code (lazy* byte))
						(skip (word "```" #f)))
					code)))
		code)))

	(import (lang eval))
	(import (otus algebra))

	(define ok '(#true))
	(for-each (lambda (filename)
		(print "  testing " filename "...")
		(for-each (lambda (test)
				(let loop ((test test))
					(define expressions (try-parse (greedy+ sexp-parser) test #false))
					(when expressions
						(define sexps (car expressions))
						(let subloop ((sexps sexps))
							(let*((query tail sexps)
									(arrow tail tail)
									(answer tail tail))
								(define a (eval query *toplevel*))
								(define b (eval answer *toplevel*))
								(unless (equal? a b)
									(print "test error:")
									(print "  " query " IS NOT EQUAL TO " answer)
									(set-car! ok #false))
								(unless (null? tail)
								(subloop tail))))
						(loop (cdr expressions)))))
			(car (try-parse parser (force (file->bytestream filename)) #f))))
		*vm-args*)
	(exit (car ok))
endef
export CHECK_REFERENCE

check-reference: $(wildcard reference/en/*.md) reference/README.md
	@echo "Testing reference:"
	@ol reference/check.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)

#echo "$$CHECK_REFERENCE" | ol - $(filter %.md,$^) && echo $(ok) || echo $(failed)
#ol reference/tool.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)
