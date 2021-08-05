ok:="\033[1;32mok\033[0m"
failed:="\033[1;31mfailed\033[0m"

TESTS:=$(shell mktemp -u /tmp/tests.XXXXXXXXX)

tests: $(wildcard tests/*.lisp.ok)
	@if [ -f $(TESTS) ]; then \
	   rm -f $(TESTS) ;\
	   exit 1 ;\
	fi

%.lisp.ok: %.lisp
	@printf "testing $^: "
	@if ([ -f $^.in ] && ol $^ <$^.in || ol $^) | diff --strip-trailing-cr - $^.ok >/dev/null; then\
	   printf $(ok) ;\
	else \
	   printf $(failed) ;\
	   touch $(TESTS) ;\
	fi
	@printf ".\n"
