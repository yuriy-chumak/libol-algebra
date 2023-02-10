# https://www.gnu.org/prep/standards/html_node/Standard-Targets.html
export LD_LIBRARY_PATH=$(shell pwd)

all: libol-algebra.so

libol-algebra.so: vector.c matrix.c tensor.c
	gcc $^ -shared -fPIC -o $@ \
	-Xlinker --export-dynamic \
	-fopenmp -O0 -g3

install: libol-algebra.so
	@echo Installing ol libraries...
	install -d $(DESTDIR)$(PREFIX)/lib/ol/otus
	install -m 644 otus/algebra.scm $(DESTDIR)$(PREFIX)/lib/ol/otus/algebra.scm
	find otus -type d -exec bash -c 'install -d "$(DESTDIR)$(PREFIX)/lib/ol/otus/$${0/otus\/}"' {} \;
	find otus -type f -exec bash -c 'install -m 644 "$$0" "$(DESTDIR)$(PREFIX)/lib/ol/otus/$${0/otus\/}"' {} \;
	@echo Installing shared library...
	install -m 644 libol-algebra.so $(DESTDIR)$(PREFIX)/lib/libol-algebra.so
	@echo Ok

check: check-reference
	LD_LIBRARY_PATH=`pwd` $(MAKE) --always-make --quiet tests
	@echo "Well done."

-include tests/Makefile
-include reference/Makefile
