#pragma once
#include <stdlib.h>
#include <stdarg.h>
#include <stddef.h>

#include <assert.h>
#include <string.h>

#include <math.h>

// -----------------------------------------------------------------
// тип, который мы будем использовать для вычислений (обычно - float)
typedef float fp_t;

// basic numerical constants:
#define ONE		 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), 1.0, 1.0f)
#define ZERO	 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), 0.0, 0.0f)

// float/double functions:
#define SQRT(x)	 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), sqrt, sqrtf)(x)

#define LOG(x)	 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), log, logf)(x)
#define LOG10(x) __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), log10, log10f)(x)
#define LOG2(x)	 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), log2, log2f)(x)

#define EXP(x)	 __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), exp, expf)(x)
#define POW(x,y) __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), pow, powf)(x,y)

#define SQRT(x)  __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), sqrt, sqrtf)(x)
#define CBRT(x)  __builtin_choose_expr(__builtin_types_compatible_p(fp_t, double), cbrt, cbrtf)(x)

// -----------------------------------------------------------------
// ONLY tensors and scalars may be
#define is_tensor(x) is_pair(x)
#define is_scalar(x) !is_tensor(x)

//#define TENSOR 0xFAFFF1ED


// -------------------------
#include <stdio.h>
#include <ol/vm.h>
#define ol2f(num)\
    __builtin_choose_expr( __builtin_types_compatible_p\
        (fp_t, double), OL2D(num), OL2F(num) )

#ifdef payload
#undef payload
#endif
#define payload(array) ((fp_t*)&car(array))

#define scalarp numberp

// allocator:
word* new_floats_(olvm_t* this, size_t size, size_t n, ...);
#define NARG(...) NARG_N(_, ## __VA_ARGS__,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
#define NARG_N(_,n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,mn10,n11,n12,n13,n14,n15,n16,n17,n18, n,...) n
#define new_floats(this, size, ...) new_floats_(this, size, NARG(__VA_ARGS__), ##__VA_ARGS__)

// core functions:
int size(word dimensions);
int offset(word dimensions, word index);
// #define dimensions(A) car(A)

#define BEGIN fp = ((struct heap_t*)this)->fp;
#define END   ((struct heap_t*)this)->fp = fp;

#define ENTER_SECTION fp = ((struct heap_t*)this)->fp;
#define LEAVE_SECTION ((struct heap_t*)this)->fp = fp;

#define RETURN_TENSOR(dims, floats){\
	ENTER_SECTION \
	word*T = new_pair(dims, floats);\
	LEAVE_SECTION \
	return T; }

#define CHECK(q, str) \
	if (!(q)) {\
		fprintf(stderr, str);\
		return (word*)IFALSE;\
	}
#define CHECK_IF(sel, q, str)\
	if (sel) CHECK(q, str);

// typedef struct tensor_t
// {
//     unsigned ID; // уникальный идентификатор объекта, TTENSOR
//     size_t size; // размер даннызх
//     fp_t data[]; // непосредственные данные
// } tensor_t;

// typedef struct tensor tensor_t;

// TODO:
// или держать размерности отдельным объектом в ol
// а данные отдельным в обычной памяти
// и передавать в код пару "размерности"+"данные"
