#include "tensor.h"

__attribute__((visibility("hidden")))
int size(word dimensions)
{
    if (dimensions == INULL)
        return 1;
    return numberp(car(dimensions)) * size(cdr(dimensions));
}
/*
	unsigned dim_count = 0; // unused?
	unsigned dim_total = 1;
	for (word args = dims; args != INULL; args = cdr(args)) {
        int dim = numberp(car(args));
		dim_count++;
		dim_total *= dim;
	}
*/

__attribute__((visibility("hidden")))
int offset(word dimensions, word index)
{
    if (dimensions == INULL)
        return 0;
    return offset(cdr(dimensions), cdr(index))
        + (numberp(car(index)) - 1) * size(cdr(dimensions));
}
