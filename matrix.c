#include "tensor.h"

// todo: make function create_new_matrix (or new_matrix) like new_floats

// add
// sub
// mul
// dot (matrix-multiplication)

__attribute__((used))
word* mdot(olvm_t* this, word arguments) // todo: change to word arguments
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments); // matrix A
	word B = car(arguments); arguments = cdr(arguments); // matrix B
	assert (arguments == INULL);
	// assert matrices

	size_t m = value(caar(A));
	size_t n = value(car(cdar(A)));
	size_t q = value(car(cdar(B)));

	if (value(caar(B)) != n)
		return RFALSE;

	word* floats = new_floats(this, m * q, &A, &B);

	fp_t* a = payload(cdr(A));
	fp_t* b = payload(cdr(B));
	fp_t* c = payload(floats);

	size_t i,j,k;
	memset(c, 0, m * q * sizeof(fp_t)); // clear with "0.0"

	#pragma omp parallel for private(i,j,k) shared(a,b,c) \
			schedule(static)
	for (i = 0; i < m; i++)
		for (j = 0; j < q; j++)
			for (k = 0; k < n; k++)
				c[i*q + j] += a[i*n + k] * b[k*q + j];

	RETURN_TENSOR(new_list(TPAIR, I(m), I(q)), floats);
}

// Matrix Transposition
__attribute__((used))
word* mtranspose(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments);
	assert (arguments == INULL);

	word M = caar(A);
	word N = car(cdar(A));

	size_t m = value(M); // rows
	size_t n = value(N); // columns

	// vector
	if (m == 1 || n == 1) {
		// swap m and n, that's it!
		RETURN_TENSOR(new_list(TPAIR, car(cdar(A)), caar(A)), cdr(A));
	}

	// matrix
	if (cdr(cdar(A)) == INULL)
	{
		size_t asize = size(car(A));
		word* floats = new_floats(this, asize, &A);

		fp_t* a = payload(cdr(A));
		fp_t* f = payload(floats);
		for (size_t i = 0; i < asize; i++) {
			size_t x = i % n;
			size_t y = i / n;
			f[x * m + y] = a[i];
		}

		RETURN_TENSOR(new_list(TPAIR, car(cdar(A)), caar(A)), floats);
	}

	return (word*) IFALSE; // invalid call
}