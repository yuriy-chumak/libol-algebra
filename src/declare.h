#ifndef __SRC_DECLARE_H__
#define __SRC_DECLARE_H__
#include <stdlib.h>

#include "tensor.h"

// 0
#define DECLARE0(name, fnc) \
__attribute__((used))\
word* name(olvm_t* this, word arguments)\
{\
    word* fp;\
\
	/* special case:*/\
    if (arguments == INULL) {\
        ENTER_SECTION\
        word* scalar = new_inexact(fnc());\
        LEAVE_SECTION\
		return scalar;\
    }\
\
    word A = car(arguments); arguments = cdr(arguments);\
    assert (arguments == INULL);\
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

// 1
#define DECLARE1(name, fnc) \
__attribute__((used))\
word* name(olvm_t* this, word arguments)\
{\
	word* fp;\
\
	word A = car(arguments); arguments = cdr(arguments);\
	assert (arguments == INULL);\
\
	if (is_scalar(A)) {\
		fp_t a = ol2f(A);\
        ENTER_SECTION\
		word* scalar = new_inexact(fnc(a));\
        LEAVE_SECTION\
		return scalar;\
	}\
\
	size_t asize = size(car(A));\
	word* floats = new_floats(this, asize, &A);\
\
	fp_t* a = payload(cdr(A));\
	fp_t* f = payload(floats);\
	for (int i = 0; i < asize; i++) {\
		f[i] = fnc(a[i]);\
	}\
\
	RETURN_TENSOR(car(A), floats);\
}

// 2
#define DECLARE2(name, fnc) \
__attribute__((used))\
word* name(olvm_t* this, word arguments)\
{\
    word* fp;\
\
	word A = car(arguments); arguments = cdr(arguments);\
    word B = car(arguments); arguments = cdr(arguments);\
    assert (arguments == INULL);\
\
	CHECK (is_tensor(A), #name " error: left operand must be a tensor.");\
	CHECK_IF (is_tensor(B),\
		size(car(B)) == size(car(A)), #name " error: arguments sizes mismatch");\
\
    size_t asize = size(car(A));\
    word* floats = new_floats(this, asize, &A, &B);\
\
    fp_t* a = payload(cdr(A));\
	fp_t* f = payload(floats);\
    if (is_scalar(B)) {/* tensor, scalar */\
		fp_t b = ol2f(B);\
		for (int i = 0; i < asize; i++) {\
			f[i] = fnc(a[i], b);\
		}\
    }\
	else\
	if (is_tensor(B)) {/* tensor, tensor */\
		fp_t* b = payload(cdr(B));\
		for (int i = 0; i < asize; i++) {\
			f[i] = fnc(a[i], b[i]);\
		}\
	}\
\
    /* todo: make (Name Tensor~ Tensor) and (Name Tensor Tensor~)*/\
	RETURN_TENSOR(car(A), floats);\
}

#endif//__SRC_DECLARE_H__
