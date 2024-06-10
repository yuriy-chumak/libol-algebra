#include "tensor.h"
// todo: Map0 - non recursive top-level map
// todo: MapN - non recursive N-level map

// static
// void map(word A, size_t count, fp_t x) {
// 	fp_t* a = payload(A);
// 	for (int i = 0; i < count; i++) {
// 		a[i] = x;
// 	}
// }

// (Map (λ (a) ..) A) -> new tensor
// (Map (λ (a b) ..) A B) -> new tensor
word Map(olvm_t* this, word arguments)
{
	register word* fp;

	word F = car(arguments); arguments = cdr(arguments);
	word A = car(arguments); arguments = cdr(arguments);
	word B = INULL;
	if (arguments != INULL) {
		B = car(arguments); arguments = cdr(arguments);
	}
	// assert (is_callable(A));

	// (Map f array)
	if (B == INULL) {
		size_t asize = size(car(A));
		word* floats = new_floats(this, asize, &F, &A);

		if (is_procedure(F)) {
			size_t f = OLVM_pin(this, F);
			size_t a = OLVM_pin(this, A);
			size_t c = OLVM_pin(this, (word)floats);

			for (size_t i = 0; i < asize; i++) {
				fp_t arg1 = payload(cdr(A))[i];
				ENTER_SECTION
				word args = (word) new_list(TPAIR, new_inexact(arg1));
				LEAVE_SECTION

				word v0 = OLVM_apply(this, F, args);
				// apply may call GC
				F = OLVM_deref(this, f); // this->pin[f], speedup
				A = OLVM_deref(this, a);
				floats = (word*)OLVM_deref(this, c);

				payload(floats)[i] = ol2fp(v0);
			}
			OLVM_unpin(this, f);
			OLVM_unpin(this, a);
			OLVM_unpin(this, c);

			RETURN_TENSOR(car(A), floats);
		}
		
		return IFALSE;
	}

	word C = INULL;
	if (arguments != INULL) {
		C = car(arguments); arguments = cdr(arguments);
	}
	// (Map f array1 array2)
	if (B != INULL && C == INULL) {
		size_t asize = size(car(A));
		assert (size(car(B)) == asize);

		word* floats = new_floats(this, asize, &F, &A, &B);

		if (is_procedure(F)) {
			size_t f = OLVM_pin(this, F);
			size_t a = OLVM_pin(this, A);
			size_t b = OLVM_pin(this, B);
			size_t q = OLVM_pin(this, (word)floats);

			for (size_t i = 0; i < asize; i++) {
				fp_t arg1 = payload(cdr(A))[i];
				fp_t arg2 = payload(cdr(B))[i];
				ENTER_SECTION
				word args = (word) new_list(TPAIR, new_inexact(arg1), new_inexact(arg2));
				LEAVE_SECTION

				word X = OLVM_apply(this, F, args);
				// apply may call GC
				F = OLVM_deref(this, f);
				A = OLVM_deref(this, a);
				B = OLVM_deref(this, b);
				floats = (word*)OLVM_deref(this,q);

				payload(floats)[i] = ol2fp(X);
			}
			OLVM_unpin(this, f);
			OLVM_unpin(this, a);
			OLVM_unpin(this, b);
			OLVM_unpin(this, q);

			RETURN_TENSOR(car(A), floats);
		}
		
		return IFALSE;
	}

	word D;
	// (Map f array1 .. arrayN)
	if (B != INULL && C != INULL) {
		size_t asize = size(car(A));
		assert (size(car(B)) == asize);
		assert (size(car(C)) == asize);

		D = arguments;
		while (D != INULL) {
			assert (size(caar(D)) == asize);
			D = cdr(D);
		}

		word* floats = new_floats(this, asize, &F, &A, &B, &C, &arguments);

		D = arguments;
		if (is_procedure(F)) {
			size_t f = OLVM_pin(this, F);
			size_t a = OLVM_pin(this, A);
			size_t b = OLVM_pin(this, B);
			size_t c = OLVM_pin(this, C);
			size_t d = OLVM_pin(this, D);
			size_t q = OLVM_pin(this, (word)floats);

			for (size_t i = 0; i < asize; i++) {
				fp_t arg1 = payload(cdr(A))[i];
				fp_t arg2 = payload(cdr(B))[i];
				fp_t arg3 = payload(cdr(C))[i];

				ENTER_SECTION
				word* rlist = RNULL;
				while (D != INULL) {
					fp_t argN = payload(cdar(D))[i];
					rlist = new_pair(TPAIR, new_inexact(argN), rlist);
					D = cdr(D);
				}
				word args = INULL;
				while (rlist != RNULL) {
					args = (word) new_pair(TPAIR, car(rlist), args);
					rlist = (word*) cdr(rlist);
				}
				args = (word) new_pair(TPAIR, new_inexact(arg3), args);
				args = (word) new_pair(TPAIR, new_inexact(arg2), args);
				args = (word) new_pair(TPAIR, new_inexact(arg1), args);
				LEAVE_SECTION

				word X = OLVM_apply(this, F, args);
				// apply may call GC
				F = OLVM_deref(this, f);
				A = OLVM_deref(this, a);
				B = OLVM_deref(this, b);
				C = OLVM_deref(this, c);
				D = OLVM_deref(this, d);
				floats = (word*)OLVM_deref(this, q);

				payload(floats)[i] = ol2fp(X);
			}
			OLVM_unpin(this, f);
			OLVM_unpin(this, a);
			OLVM_unpin(this, b);
			OLVM_unpin(this, c);
			OLVM_unpin(this, d);
			OLVM_unpin(this, q);

			RETURN_TENSOR(car(A), floats);
		}

	}

	return IFALSE;
	// size_t asize = size(car(A));
	// word C = (word) new_floats(this, asize, &A, &B);

	// if (is_inexact(B)) {
	// 	fp_t b = *(inexact_t*)&car(B);
	// 	fill(C, asize, b);
	// }
	// else
	// if (is_callable(B)) { // callback
	// 	// callback can call GC, so need to save A and C
	// 	size_t a = OLVM_pin(this, A);
	// 	size_t c = OLVM_pin(this, C);

	// 	fp_t (*callback)() = (fp_t (*)())car(B);
	// 	for (int i = 0; i < asize; i++) {
	// 		fp_t f = callback();
	// 		payload(OLVM_deref(this, c))[i] = f;
	// 	}

	// 	C = OLVM_unpin(this, c);
	// 	A = OLVM_unpin(this, a);
	// }

	// RETURN_TENSOR(car(A), C);
}

// (Map! (λ (a) ..) A) -> A changed
// (Map! (λ (a b) ..) A B) -> A changed
word* MapE(olvm_t* this, word arguments)
{
	// word* fp;

	// word A = car(arguments); arguments = cdr(arguments);
	// word B = car(arguments); arguments = cdr(arguments);
	// assert (arguments == INULL);

	// size_t asize = size(car(A));
	// word C = cdr(A);

	// if (is_inexact(B)) {
	// 	fp_t b = *(inexact_t*)&car(B);
	// 	fill(C, asize, b);
	// }
	// else
	// if (is_callable(B)) { // callback
	// 	// callback can call GC, so need to save A and C
	// 	size_t a = OLVM_pin(this, A);
	// 	size_t c = OLVM_pin(this, C);

	// 	fp_t (*callback)() = (fp_t (*)()) car(B);
	// 	for (int i = 0; i < asize; i++) {
	// 		payload(OLVM_deref(this, c))[i] = callback();
	// 	}

	// 	C = OLVM_unpin(this, c);
	// 	A = OLVM_unpin(this, a);
	// }

	// return (word*) A;
}
