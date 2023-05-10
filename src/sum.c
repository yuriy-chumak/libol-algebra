#include "tensor.h"

// todo: add "Fold" function

__attribute__((used))
word* Sum(olvm_t* this, word arguments)
{
    word* fp;

    word A = car(arguments); arguments = cdr(arguments);
    assert (arguments == INULL);

    if (is_scalar(A)) {
        ENTER_SECTION
        word* scalar = new_inexact(ol2f(A));
        LEAVE_SECTION
		return scalar;
    }

	size_t asize = size(car(A));

    fp_t s = 0;
	fp_t* a = payload(cdr(A));
    for (int i = 0; i < asize; i++) {
        s += a[i];
    }

	ENTER_SECTION
	word* tensor = new_inexact(s);
	LEAVE_SECTION
	return tensor;
}
