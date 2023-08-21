#include "tensor.h"

typedef int bool;
#define true 1
#define false 0

// эта функция не только создает новый тензор, но и
// 1. вызывает GC, если для матрицы не хватает места
// 2. сохраняет и восстанавливает Ol-объекты, если они были
//    перемещены GC

__attribute__((visibility("hidden")))
word* new_floats_(olvm_t* this, size_t length, size_t n, ...)
{
    heap_t* heap = (struct heap_t*)this;

    size_t size = length * sizeof(fp_t);
    size_t words = (size + (W - 1)) / W;
    if ((heap->fp + words) > heap->end) {
        // do GC and save/resore pointers
        va_list ptrs;
        size_t id[n];

        // save Ol objects before GC
        va_start(ptrs, n);
        for (int i = 0; i < n; i++)
            id[i] = OLVM_pin(this, *(va_arg(ptrs, word*)));
        va_end(ptrs);

        heap->gc(this, words);

        // restore OL objects after GC
        va_start(ptrs, n);
        for (int i = 0; i < n; i++)
            *(va_arg(ptrs, word*)) = OLVM_unpin(this, id[i]);
        va_end(ptrs);
    }

    word* fp;
    fp = heap->fp;
    word* floats = new_bytevector(size);
    memset(payload(floats), 0, size); // DEBUG
    heap->fp = fp;

    return floats;
}

// TODO: check https://github.com/hfp/libxsmm/blob/master/samples/hello/hello.c
// TODO: Matrix Multiplication
//       https://cnugteren.github.io/tutorial/pages/page1.html

// ---------------------------------------------------------
// 1. представление тензора создается в пространстве кучи Ol
// 2. изначально тензор либо заполнен мусором, либо заполняем
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
            *ptr++ = ol2f(v);
    }
    *end = ptr;
}

static
void init_with_list(fp_t**end, word data)
{
	// ...
	
}

// рекурсивная процедурка
static
void maker(fp_t* begin, fp_t**end, word data) {
    if (data == INULL)
        return;
    maker(begin, end, cdr(data));

    word dimension = car(data);
	// todo: add list initialization
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

// vector: (Tensor '(N) '(N))
// vector: (Tensor '(N) '([x1 x2 ...]))
// (???) пока что тензор умеет только создавать по размерам
// TODO: (new_floats tensor dimN-1 dimN)
word* Tensor(olvm_t* this, word* arguments)
{
	word dims = car(arguments); arguments = (word*)cdr(arguments); // dimensions
	word data = car(arguments); arguments = (word*)cdr(arguments); // array data
	assert (arguments == RNULL);

	// размер блока данных
	unsigned dim_total = size(dims);
	word* array = new_floats(this, dim_total);

	// проинициализируем готовыми данными
	if (data != IFALSE) {
		fp_t* ptr = payload(array);
		maker(ptr, &ptr, data);
	}

	return array;
}

// -=( ref )=-----------------------------------------------
word* Ref(olvm_t* this, word arguments)
{
	word* fp;

	// (Ref array i j k l m...)
    word array = car(arguments);
	word index = cdr(arguments);

    //array is a '(dimensions . floats)
    word dimensions = car(array);
    word array_data = cdr(array);

    fp = ((struct heap_t*)this)->fp;
    word* vptr = new_inexact(payload(array_data)[offset(dimensions, index)]);
    ((struct heap_t*)this)->fp = fp;

    return vptr;
}

// -=( fill )=-----------------------------------------------
