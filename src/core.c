#include "tensor.h"

__attribute__((visibility("hidden")))
int size(word dimensions)
{
    if (dimensions == INULL)
        return 1;
    return numberp(car(dimensions)) * size(cdr(dimensions));
}

__attribute__((visibility("hidden")))
int offset(word dimensions, word index)
{
    if (dimensions == INULL)
        return 0;
    return offset(cdr(dimensions), cdr(index))
        + (numberp(car(index)) - 1) * size(cdr(dimensions));
}
