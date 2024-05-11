# https://www.gnu.org/prep/standards/html_node/Standard-Targets.html
.PHONY: all debug release check-reference

export LD_LIBRARY_PATH=$(shell pwd)

all: release

release: CFLAGS += -O3 -g0
release: libol-algebra.so

debug: CFLAGS += -O0 -g3
debug: libol-algebra.so

# #####################################
# install
DESTDIR?=
PREFIX ?= /usr

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

# #####################################
# build
define libol-algebra
	$(CC) $1 -fPIC $(CFLAGS) \
	-fopenmp -I. -include "omp.h" \
	-Xlinker --export-dynamic \
	-shared -o $2
#	-fvisibility=default
endef

libol-algebra.so: $(wildcard src/*.h)
libol-algebra.so: vector.c matrix.c tensor.c $(wildcard src/*.c)
	$(call libol-algebra,$^,$@)

libol-algebra.dll:CC := x86_64-w64-mingw32-gcc
libol-algebra.dll:CFLAGS += -Iwin32 \
                            -DOLVM_PIN_PROTOTYPES \
						    -DOLVM_FCONV_PROTOTYPES -DOLVM_INEXACTS=1
libol-algebra.dll:$(wildcard src/*.h)
libol-algebra.dll:win32/DllMain.c
libol-algebra.dll:vector.c matrix.c tensor.c $(wildcard src/*.c)
	mkdir -p win32/ol
	cp $(DESTDIR)$(PREFIX)/include/ol/vm.h win32/ol/vm.h
	$(call libol-algebra,$^,$@)

# #####################################
# check
check: check-reference
	$(MAKE) -B debug
	# exact math check
	LD_LIBRARY_PATH=`pwd` OTUS_ALGEBRA_DEFAULT_EXACTNESS=1 \
	                      OTUS_ALGEBRA_NO_STARTUP_WARNINGS=1 \
	    $(MAKE) --always-make --quiet tests
	# inexact math check
	LD_LIBRARY_PATH=`pwd` OTUS_ALGEBRA_DEFAULT_EXACTNESS=0 \
	                      OTUS_ALGEBRA_NO_STARTUP_WARNINGS=1 \
	    $(MAKE) --always-make --quiet tests
	@echo "Well done."

-include tests/Makefile
-include reference/Makefile
