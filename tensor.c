#include <math.h>

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>

#include <stdio.h>
#include <ol/vm.h>
double OL2D(word arg); float OL2F(word arg); // implemented in olvm.c


#include "tensor.h"

typedef int bool;
#define true 1
#define false 0

// #define MEMPAD (1024) // TODO: exclude this
// #define TTENSOR 28

// #define new_tensor(a) ({\
// word _data = (word) a;\
// 	word* _me = new (TTENSOR, 1, 0);\
// 	_me[1] = _data;\
// 	/*return*/ _me;\
// })

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
// 3. изначально тензор либо заполнен мусором, либо заполняем
//    из предоставленных векторов

// // TODO: проверка на хип, (а вдруг будут больше 200 размерностей)
// // TODO: проверка типов аргументов
// __attribute__((used))

// рекурсивная процедурка
void init_with_vector(fp_t**end, word data)
{
    // assert all elements are vectors OR
    // assert all elements are not vectors
    bool vectors = is_vector(ref(data,1));

    // вектор, заполним массив значениями:
    int size = reference_size(data);
    fp_t* ptr = *end;
    for (int i = 1; i <= size; i++) {
        word v = ref(data, i);
        if (is_vector(v))
            init_with_vector(&ptr, v);
        else
            *ptr++ = OL2F(v);
    }
    *end = ptr;
}

// рекурсивная процедурка
void maker(fp_t* begin, fp_t**end, word data) {
    if (data == INULL)
        return;
    maker(begin, end, cdr(data));

    word dimension = car(data);
    if (is_vector(dimension))
        init_with_vector(end, dimension);
    else {
        assert (is_numberp(dimension));
        int count = numberp(dimension);
        fp_t *ptr = *end;
        int size = (ptr - begin);
        for (int i = 1; i < count; i++) { // 1, потому что одна строка уже есть
            memcpy(ptr, begin, size * sizeof(fp_t));
            ptr += size;
        }
        *end = ptr;
    }
    return;
}

// // (new_tensor dim1 dim2 dim3)
// // пока что тензор умеет только создавать по размерам
// // TODO: (new_tensor tensor dimN-1 dimN)
word* create_tensor(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;
	word* fp;

	word dims = car(arguments); arguments = (word*)cdr(arguments); // dimenstions
	word data = car(arguments); arguments = (word*)cdr(arguments); // array data?
    assert (arguments == RNULL);

	// посчитаем размер нужного блока
	unsigned dim_count = 0; // unused?
	unsigned dim_total = 1;
	for (word args = dims; args != INULL; args = cdr(args)) {
        int dim = numberp(car(args));
		dim_count++;
		dim_total *= dim;
	}

	fp_t* array = malloc(sizeof(fp_t) * dim_total);

    fp = heap->fp;
    word* vptr = new_vptr(array);
    heap->fp = fp;

    // проинициализируем готовыми данными:
    if (data != IFALSE) {
        fp_t* end = array;
        maker(array, &end, data);
    }

    return vptr;
}

int size(word dimensions)
{
    if (dimensions == INULL)
        return 1;
    return numberp(car(dimensions)) * size(cdr(dimensions));
}

int offset(word dimensions, word index)
{
    if (dimensions == INULL)
        return 0;
    return offset(cdr(dimensions), cdr(index))
        + (numberp(car(index)) - 1) * size(cdr(dimensions));
}

word* at(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;
	word* fp;

	word array = car(arguments);
	word index = cdr(arguments);

    word dimensions = car(array);
    word ptr = cadr(array);

    fp = heap->fp;
    word* vptr = new_inexact(((fp_t*)ptr)[offset(dimensions, index)]);
    heap->fp = fp;

    return vptr;
}

// __attribute__((used))
// word* dimension(olvm_t* this, word* arguments)
// {
// 	word* fp;
// 	heap_t* heap = (struct heap_t*)this;

// 	tensor_t* tensor = (tensor_t*) caar(arguments);
// 	assert (tensor->ID == TTENSOR);

//     fp = heap->fp;

// 	word* r = RNULL;
// 	for (int i = tensor->type; i > 0; i--)
// 		r = new_pair(I(tensor->dimension[i-1]), r);

//     heap->fp = fp;
//     return r;
// }
