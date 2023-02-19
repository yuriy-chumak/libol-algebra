#include "tensor.h"

static
void fill(word* A, size_t count, fp_t x) {
    fp_t* a = payload(A);
    for (int i = 0; i < count; i++) {
        a[i] = x;
    }
}

word* Fill(olvm_t* this, word* arguments)
{
    heap_t* heap = (struct heap_t*)this;

    word A = car(arguments); arguments = (word*)cdr(arguments);
    word B = car(arguments); arguments = (word*)cdr(arguments);
    assert (arguments == RNULL);

    size_t asize = size(car(A));
    fp_t b = ol2f(B);

    word*C = new_tensor(this, asize * sizeof(fp_t), &A, &B);

    fill(C, asize, b);

    word* fp;
    fp = heap->fp;
    C = new_pair(car(A), C);
    heap->fp = fp;

    return C;
}

word* FillE(olvm_t* this, word* arguments)
{
    heap_t* heap = (struct heap_t*)this;

    word A = car(arguments); arguments = (word*)cdr(arguments);
    word B = car(arguments); arguments = (word*)cdr(arguments);
    assert (arguments == RNULL);

    size_t asize = size(car(A));
    fp_t b = ol2f(B);

    word*C = (word*) cdr(A);
    fill(C, asize, b);
    return C;
}
