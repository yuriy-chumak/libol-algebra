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

check-reference: reference/README.md $(wildcard reference/en/**/*.md)
	@echo "Testing reference:"
	@ol reference/check.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)

check-win64-reference: reference/README.md $(wildcard reference/en/**/*.md)
	# win64 reference check #
	$(MAKE) libol-algebra.dll
	WINEPATH='Z:\usr\lib\gcc\x86_64-w64-mingw32\10-win32;Z:\usr\x86_64-w64-mingw32\lib' \
	wine ol.exe reference/check.lisp $^

#echo "$$CHECK_REFERENCE" | ol - $(filter %.md,$^) && echo $(ok) || echo $(failed)
#ol reference/tool.lisp $(filter %.md,$^) && echo $(ok) || echo $(failed)
