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

static
word* new_tensor_(olvm_t* this, size_t size, size_t n, ...)
{
    heap_t* heap = (struct heap_t*)this;
    word* fp;

    size_t words = (size + (W - 1)) / W;
    if ((heap->fp + words) > heap->end) {
        // do GC and save/resore pointers
        va_list ptrs;
        size_t id[n];

		va_start(ptrs, n);
        for (int i = 0; i < n; i++)
            id[i] = OLVM_pin(this, *(va_arg(ptrs, word*)));
        va_end(ptrs);
        heap->gc(this, words);
        va_start(ptrs, n);
        for (int i = 0; i < n; i++)
            *(va_arg(ptrs, word*)) = OLVM_unpin(this, id[i]);
        va_end(ptrs);
    }

    fp = heap->fp;
	word* floats = new_bytevector(size);
    heap->fp = fp;

    return floats;
}
#define NARG(...) NARG_N(_, ## __VA_ARGS__,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
#define NARG_N(_,n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,mn10,n11,n12,n13,n14,n15,n16,n17,n18, n,...) n
#define new_tensor(this, size, ...) new_tensor_(this, size, NARG(__VA_ARGS__), ##__VA_ARGS__)

#define FPP(array) ((fp_t*)&car(array)) // payload

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
static
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
static
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

// vector: (create_tensor '(N) '(N))
// vector: (create_tensor '(N) '([x1 x2 ...]))
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

    word* array = new_tensor(this, dim_total * sizeof(fp_t));

    fp = heap->fp;

    // проинициализируем готовыми данными:
    if (data != IFALSE) {
        fp_t* ptr = FPP(array);
        maker(ptr, &ptr, data);
    }

    return array;
}

// -=( ref )=-----------------------------------------------
static
int size(word dimensions)
{
    if (dimensions == INULL)
        return 1;
    return numberp(car(dimensions)) * size(cdr(dimensions));
}

static
int offset(word dimensions, word index)
{
    if (dimensions == INULL)
        return 0;
    return offset(cdr(dimensions), cdr(index))
        + (numberp(car(index)) - 1) * size(cdr(dimensions));
}

word* Ref(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;
	word* fp;

	word array = car(arguments);
	word index = cdr(arguments);

    word dimensions = car(array);
    word array_data = cdr(array);

    fp_t* ptr = FPP(array_data);

    fp = heap->fp;
    word* vptr = new_inexact(ptr[offset(dimensions, index)]);
    heap->fp = fp;

    return vptr;
}

// -=( ref )=-----------------------------------------------
word* Add(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;
	word* fp;

	word A = car(arguments); arguments = (word*)cdr(arguments);
    word B = car(arguments); arguments = (word*)cdr(arguments);
    assert (arguments == RNULL);
    assert (reference_size(cdr(A)) == reference_size(cdr(B)));

    size_t absize = size(car(A));
    word* C = new_tensor(this, absize * sizeof(fp_t), &A, &B);

    // Add(Tensor~ Tensor~):
    fp_t* a = FPP(cdr(A));
    fp_t* b = FPP(cdr(B));
    fp_t* c = FPP(C);
    for (int i = 0; i < absize; i++) {
        c[i] = a[i] + b[i];
    }

    // todo: make (Add Tensor~ Tensor)

    fp = heap->fp;
    C = new_pair(car(A), C);
    heap->fp = fp;

    return C;
}

// // __attribute__((used))
// // word* dimension(olvm_t* this, word* arguments)
// // {
// // 	word* fp;
// // 	heap_t* heap = (struct heap_t*)this;

// // 	tensor_t* tensor = (tensor_t*) caar(arguments);
// // 	assert (tensor->ID == TTENSOR);

// //     fp = heap->fp;

// // 	word* r = RNULL;
// // 	for (int i = tensor->type; i > 0; i--)
// // 		r = new_pair(I(tensor->dimension[i-1]), r);

// //     heap->fp = fp;
// //     return r;
// // }
