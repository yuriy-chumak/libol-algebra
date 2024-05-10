# 

ok:="\033[1;32mok\033[0m"
failed:="\033[1;31mfailed\033[0m"

define CHECK_REFERENCE
	(import (owl parse))
	(import (lang sexp))

	(define ok '(#true))
	(exit (car ok))
endef
export CHECK_REFERENCE

check-reference: reference/README.md $(wildcard reference/en/*.md)
	@echo "Testing reference:"
	@ol reference/check.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)

#echo "$$CHECK_REFERENCE" | ol - $(filter %.md,$^) && echo $(ok) || echo $(failed)
#ol reference/tool.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)
