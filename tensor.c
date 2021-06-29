#include <math.h>

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <stdio.h>
#include <ol/vm.h>

#include "tensor.h"

#define MEMPAD (1024) // TODO: exclude this
#define TTENSOR 28

#define new_tensor(a) ({\
word _data = (word) a;\
	word* _me = new (TTENSOR, 1, 0);\
	_me[1] = _data;\
	/*return*/ _me;\
})

#if 1
#define LOG(...) fprintf(stderr, __VA_ARGS__)
#else
#define LOG(...)
#endif

// TODO: check https://github.com/hfp/libxsmm/blob/master/samples/hello/hello.c
// TODO: Matrix Multiplication
//       https://cnugteren.github.io/tutorial/pages/page1.html

// ---------------------------------------------------------
// 1. представление тензора создается в пространстве кучи Ol
// 2. сам тензор создается в отдельной памяти
//    ибо нехер его гонять туда-сюда во время сборки мусора.
// 3. изначально тензор заполнен мусором

// TODO: проверка на хип, (а вдруг будут больше 200 размерностей)
// TODO: проверка типов аргументов
__attribute__((used))

// (new_tensor dim1 dim2 dim3)
// пока что тензор умеет только создавать по размерам
// TODO: (new_tensor tensor dimN-1 dimN)
word* create_tensor(olvm_t* this, word* arguments)
{
	word* fp;
	heap_t* heap = (struct heap_t*)this;

	// посчитаем размеры
	unsigned dim_count = 0;
	unsigned dim_total = 1;
	for (word* args = arguments; args != RNULL; args = (word*) cdr(args)) {
		dim_count++;
		dim_total *= numberp(car(args));
	}

    fp = heap->fp;
	tensor_t* tensor = malloc(sizeof(tensor_t) + (sizeof(unsigned) * dim_count));

	// // ну и сам тензор
	tensor->ID = TTENSOR;
	tensor->type = dim_count;
	tensor->data = malloc(dim_count * sizeof(fp_t));

	unsigned* p = tensor->dimension;
	for (word* args = arguments; args != RNULL; args = (word*) cdr(args)) {
		*p++ = numberp(car(args));
	}

	word* r = new_tensor(tensor);
    heap->fp = fp;
    return r;
}

__attribute__((used))
word* dimension(olvm_t* this, word* arguments)
{
	word* fp;
	heap_t* heap = (struct heap_t*)this;

	tensor_t* tensor = (tensor_t*) caar(arguments);
	assert (tensor->ID == TTENSOR);

    fp = heap->fp;

	word* r = RNULL;
	for (int i = tensor->type; i > 0; i--)
		r = new_pair(I(tensor->dimension[i-1]), r);

    heap->fp = fp;
    return r;
}
