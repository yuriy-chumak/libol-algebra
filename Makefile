# https://www.gnu.org/prep/standards/html_node/Standard-Targets.html
.PHONY: all debug release

export LD_LIBRARY_PATH=$(shell pwd)

all: libol-algebra.so

release: CFLAGS += -O3 -g0
release: libol-algebra.so

debug: CFLAGS += -O0 -g3
debug: libol-algebra.so

libol-algebra.so: $(wildcard src/*.h)
libol-algebra.so: vector.c matrix.c tensor.c $(wildcard src/*.c)
	gcc $^ -fPIC $(CFLAGS) \
	-fopenmp -I. -include "omp.h" \
	-Xlinker --export-dynamic \
	-shared -o $@
#	-fvisibility=default

install: libol-algebra.so
	@echo Installing libol-algebra libraries...
	install -d $(DESTDIR)$(PREFIX)/lib/ol/otus
	install -m 644 otus/algebra.scm $(DESTDIR)$(PREFIX)/lib/ol/otus/algebra.scm
	find otus -type d -exec install -d "{}" "$(DESTDIR)$(PREFIX)/lib/ol/{}" \;
	find otus -type f -exec install -m 644 "{}" "$(DESTDIR)$(PREFIX)/lib/ol/{}" \;
	@echo Installing libol-algebra shared library...
	install -m 644 libol-algebra.so $(DESTDIR)$(PREFIX)/lib/libol-algebra.so
	@echo Ok

uninstall:
	-rm -rf $(DESTDIR)$(PREFIX)/lib/ol/otus/algebra
	-rm -rf $(DESTDIR)$(PREFIX)/lib/ol/otus/algebra.scm
	-rm -rf $(DESTDIR)$(PREFIX)/lib/libol-algebra.so


check: check-reference
	LD_LIBRARY_PATH=`pwd` $(MAKE) --always-make --quiet tests
	@echo "Well done."

-include tests/Makefile
-include reference/Makefile
