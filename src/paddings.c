#include "tensor.h"

// todo: add universal function for vectors and tensors
__attribute__((used))
word* Paddings(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments);
	assert (arguments == INULL);

	size_t m = value(caar(A));
	size_t n = value(car(cdar(A)));

	fp_t* a = payload(cdr(A));

	int left = (n-1);
	for (int y = 0; y < m; y++)
		for (int x = 0; x < n; x++)
			if (a[y*n+x] != 0) {
				if (x < left) left = x;
				break;
			}

	int right = 0;
	for (int y = 0; y < m; y++)
		for (int x = n; x > 0; ) {
			--x;
			if (a[y*n+x] != 0) {
				if (x > right) right = x;
				break;
			}
		}
	right = (n-1) - right;

	int top = (m-1);
	for (int x = 0; x < n; x++)
		for (int y = 0; y < m; y++)
			if (a[y*n+x] != 0) {
				if (y < top) top = y;
				break;
			}

	int bottom = 0;
	for (int x = 0; x < n; x++)
		for (int y = m; y > 0; ) {
			--y;
			if (a[y*n+x] != 0) {
				if (y > bottom) bottom = y;
				break;
			}
		}
	bottom = (m-1) - bottom;

	ENTER_SECTION
	word*T = new_list(TPAIR, new_pair(make_enum(-left), make_enump(right)),
	                         new_pair(make_enum(-top), make_enump(bottom)));
	LEAVE_SECTION
	return T;
}

// todo: add universal function for vectors and tensors
__attribute__((used)) // (Shift matrix '(x y ...))
word* Shift(olvm_t* this, word arguments)
{
	word* fp;

	word A = car(arguments); arguments = cdr(arguments);
	word S = car(arguments); arguments = cdr(arguments);
	assert (arguments == INULL);

	size_t m = value(caar(A));
	size_t n = value(car(cdar(A)));

	size_t asize = size(car(A));
	word C = (word) new_floats(this, asize, &A, &S);

	int x = number(car(S));
	int y = number(cadr(S));
	assert (cddr(S) == INULL);

	fp_t* floats = payload(C);
	memcpy (floats, payload(cdr(A)), asize * sizeof(fp_t));

	if (abs(x) < n) {
		if (x < 0) {
			int d = -x;
			for (int y = 0; y < m; y++) {
				for (int i = 0; i < n+x; i++)
					floats[y*n+i] = floats[y*n+i+d];
				for (int i = n+x; i < n; i++)
					floats[y*n+i] = 0;
			}
		}
		else
		if (x > 0) {
			int d = -x;
			for (int y = 0; y < m; y++) {
				for (int i = n-1; i >= x; i--)
					floats[y*n+i] = floats[y*n+i+d];
				for (int i = x-1; i >= 0; i--)
					floats[y*n+i] = 0;
			}
		}
	}
	if (abs(y) < m) {
		if (y < 0) {
			int d = -y*n;
			for (int x = 0; x < n; x++) {
				for (int i = 0; i < m+y; i++)
					floats[i*n+x] = floats[i*n+x+d];
				for (int i = m+y; i < m; i++)
					floats[i*n+x] = 0;
			}
		}
		else
		if (y > 0) {
			int d = -y*n;
			for (int x = 0; x < n; x++) {
				for (int i = m-1; i >= y; i--)
					floats[i*n+x] = floats[i*n+x+d];
				for (int i = y-1; i >= 0; i--)
					floats[i*n+x] = 0;
			}
		}
	}

	RETURN_TENSOR(car(A), C);
}
