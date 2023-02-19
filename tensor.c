#include "tensor.h"

typedef int bool;
#define true 1
#define false 0

__attribute__((visibility("hidden")))
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
    memset(payload(floats), 0, size); // DEBUG
    heap->fp = fp;

    return floats;
}

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
            *ptr++ = ol2f(v);
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
        fp_t* ptr = payload(array);
        maker(ptr, &ptr, data);
    }

    return array;
}

// -=( ref )=-----------------------------------------------
word* Ref(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;

	word array = car(arguments);
	word index = cdr(arguments);

    word dimensions = car(array);
    word array_data = cdr(array);

	word* fp;
    fp = heap->fp;
    word* vptr = new_inexact(payload(array_data)[offset(dimensions, index)]);
    heap->fp = fp;

    return vptr;
}

// -=( add )=-----------------------------------------------
// todo: void add(word* a, word* b)
word* Add(olvm_t* this, word* arguments)
{
	heap_t* heap = (struct heap_t*)this;

	word A = car(arguments); arguments = (word*)cdr(arguments);
    word B = car(arguments); arguments = (word*)cdr(arguments);
    size_t asize = size(car(A));

    //assert (reference_size(cdr(A)) == reference_size(cdr(B)));

    word* C = new_tensor(this, asize * sizeof(fp_t), &A, &B);
    fp_t* c = payload(C);

    fp_t* a = payload(cdr(A));
    // memcpy(c, a, size * sizeof())

    // while (B != INULL) ...
    // Add(Tensor~ Tensor~):
    fp_t* b = payload(cdr(B));
    for (int i = 0; i < asize; i++) {
        c[i] = a[i] + b[i];
    }

    // todo: make (Add Tensor~ Tensor) and (Add Tensor Tensor~)

	word* fp;
    fp = heap->fp;
    C = new_pair(car(A), C);
    heap->fp = fp;

    return C;
}


// -=( fill )=-----------------------------------------------
