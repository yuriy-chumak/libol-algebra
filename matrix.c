#include "tensor.h"

// todo: make function create_new_matrix (or new_matrix) like new_floats

// add
// sub
// mul
// dot (matrix-multiplication)

// word* Matrix_Product(olvm_t* this, word* arguments)
// {
//     heap_t* heap = (struct heap_t*)this;

//     word A = car(arguments); arguments = (word*)cdr(arguments);
//     word B = car(arguments); arguments = (word*)cdr(arguments);
//     assert (arguments == RNULL);
// }

__attribute__((used))
word* mdot(olvm_t* this, word* arguments) // todo: change to word arguments
{
	// todo: use ENTER_SECTION/LEAVE_SECTION, remove heap, add fp
    heap_t* heap = (struct heap_t*)this;

    word A = car(arguments); arguments = (word*)cdr(arguments); // matrix A
    word B = car(arguments); arguments = (word*)cdr(arguments); // matrix B
    assert (arguments == RNULL);
    // assert matrices

    size_t m = value(caar(A));
    size_t n = value(car(cdar(A)));
    size_t q = value(car(cdar(B)));

    if (value(caar(B)) != n)
        return RFALSE;

    word* C = new_floats(this, m * q, &A, &B);

    fp_t* a = payload(cdr(A));
    fp_t* b = payload(cdr(B));
    fp_t* c = payload(C);

	size_t i,j,k;
#pragma omp parallel shared(a,b,c) private(i,j)
    for (i = 0; i < m; i++) {
        for (j = 0; j < q; j++) {
            fp_t S = 0;
#pragma omp parallel shared(a,b,c) firstprivate(i,j) private(k) reduction(+:S)
            for (k = 0; k < n; k++) {
                fp_t f1 = a[i*n + k];
                fp_t f2 = b[k*q + j];
                S += a[i*n + k] * b[k*q + j];
            }

            c[i*q + j] = S;
        }
    }

    word* fp;
    fp = heap->fp;
    C = new_pair(new_list(TPAIR, I(m), I(q)), C);
    heap->fp = fp;
    return C;
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