#include "tensor.h"

#define DECLARE(name, fnc) \
__attribute__((used))\
word* name(olvm_t* this, word arguments)\
{\
    word* fp;\
\
    word A = car(arguments); arguments = cdr(arguments);\
    assert (arguments == INULL);\
\
	/* scalar case: */\
    if (is_scalar(A)) {\
        ENTER_SECTION\
        word* scalar = new_inexact(fnc(ol2f(A)));\
        LEAVE_SECTION\
		return scalar;\
    }\
\
	size_t asize = size(car(A));\
	word* floats = new_floats(this, asize, &A);\
\
	fp_t* a = payload(cdr(A));\
	fp_t* c = payload(floats);\
	for (int i = 0; i < asize; i++) {\
		c[i] = fnc(a[i]);\
	}\
\
	ENTER_SECTION\
	word* tensor = new_pair(car(A), floats);\
	LEAVE_SECTION\
	return tensor;\
}

DECLARE(Sine, sin)
DECLARE(Cosine, cos)
DECLARE(Tangent, tan)
