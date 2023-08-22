#include "tensor.h"

__attribute__((used))
word* Linspace(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments);
	word B = car(arguments); arguments = cdr(arguments);
	word C = car(arguments); arguments = cdr(arguments);  assert(is_numberp(C));
	assert (arguments == INULL);

	fp_t from = ol2f(A);  fp_t to = ol2f(B);
	size_t length = value(C);

	// TEMP: only vectors of scalars are suppored
	// TODO: extend to vectors of vectors (they'r linear, so no recursion are required).

	// size_t asize = size(car(A));
	// fp_t b = ol2f(B);

	word* array = new_floats(this, length);
	fp_t* t = payload(array);

	fp_t dv = (to - from) / (fp_t)(length - 1);
	for (int i = 0; i < length; i++) {
		*t++ = from;
		from += dv;
	}

	fp = ((struct heap_t*)this)->fp;
	word* T = new_pair(new_list(TPAIR, I(length)), array);
	((struct heap_t*)this)->fp = fp;

	return T;
}
