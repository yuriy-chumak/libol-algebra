#include "tensor.h"

__attribute__((used))
word* vdot(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments); // vector A
	word B = car(arguments); arguments = cdr(arguments); // vector B
	assert (arguments == INULL);

	size_t m = value(caar(A));
	size_t n = value(caar(B));

	if (m != n)
		return RFALSE;

	fp_t* a = payload(cdr(A));
	fp_t* b = payload(cdr(B));

	fp_t c = 0;
	size_t i;
	for (i = 0; i < m; i++)
		c += a[i] * b[i];

	ENTER_SECTION
	word* scalar = new_inexact(c);
	LEAVE_SECTION
	return scalar;
}
