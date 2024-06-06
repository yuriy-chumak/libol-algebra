#include "tensor.h"

static
void fill(word A, size_t count, fp_t x) {
	fp_t* a = payload(A);
	for (int i = 0; i < count; i++) {
		a[i] = x;
	}
}

word* Fill(olvm_t* this, word* arguments)
{
	word* fp;

	word A = car(arguments); arguments = (word*)cdr(arguments);
	word B = car(arguments); arguments = (word*)cdr(arguments);
	assert (arguments == RNULL);

	size_t asize = size(car(A));
	word C = (word) new_floats(this, asize, &A, &B);

	if (is_inexact(B)) {
		fp_t b = *(inexact_t*)&car(B);
		fill(C, asize, b);
	}
	else
	if (is_callable(B)) { // callback
		// callback can call GC, so need to save A and C
		size_t a = OLVM_pin(this, A);
		size_t c = OLVM_pin(this, C);

		fp_t (*callback)() = (fp_t (*)())car(B);
		for (int i = 0; i < asize; i++) {
			fp_t f = callback();
			payload(OLVM_deref(this, c))[i] = f;
		}

		C = OLVM_unpin(this, c);
		A = OLVM_unpin(this, a);
	}

	RETURN_TENSOR(car(A), C);
}

word* FillE(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments);
	word B = car(arguments); arguments = cdr(arguments);
	assert (arguments == INULL);

	size_t asize = size(car(A));
	word C = cdr(A);

	if (is_inexact(B)) {
		fp_t b = *(inexact_t*)&car(B);
		fill(C, asize, b);
	}
	else
	if (is_callable(B)) { // callback
		// callback can call GC, so need to save A and C
		size_t a = OLVM_pin(this, A);
		size_t c = OLVM_pin(this, C);

		fp_t (*callback)() = (fp_t (*)()) car(B);
		for (int i = 0; i < asize; i++) {
			payload(OLVM_deref(this, c))[i] = callback();
		}

		C = OLVM_unpin(this, c);
		A = OLVM_unpin(this, a);
	}

	return (word*) A;
}
