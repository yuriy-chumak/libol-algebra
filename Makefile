all: libol-algebra.so

libol-algebra.so: vector.c matrix.c tensor.c
	gcc $^ -shared -fPIC -o $@ \
	-Xlinker --export-dynamic \
	-fopenmp -O0 -g3
