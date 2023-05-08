#include "tensor.h"
#include <stdlib.h>

#define DECLARE(name, fnc) \
__attribute__((used))\
word* name(olvm_t* this, word arguments)\
{\
    word* fp;\
\
	/* special case: */\
    if (arguments == INULL) {\
        ENTER_SECTION\
        word* scalar = new_inexact(fnc());\
        LEAVE_SECTION\
		return scalar;\
    }\
\
    word A = car(arguments); arguments = cdr(arguments);\
    assert (arguments == INULL);\
	fprintf(stderr, "DECLARE\n");\
\
	size_t asize = size(car(A));\
	word* floats = new_floats(this, asize, &A);\
\
	fp_t* c = payload(floats);\
	for (int i = 0; i < asize; i++) {\
		c[i] = fnc();\
	}\
\
	ENTER_SECTION\
	word* tensor = new_pair(car(A), floats);\
	LEAVE_SECTION\
	return tensor;\
}


static
fp_t randn()
{
	fp_t u = rand() / (fp_t)RAND_MAX;
	fp_t r = __builtin_choose_expr( __builtin_types_compatible_p(fp_t, double), sqrt, sqrtf) (-2 * __builtin_choose_expr( __builtin_types_compatible_p(fp_t, double), log, logf) (u));
	return (rand() % 2) ? -r : r;
}

DECLARE(Randn, randn)
