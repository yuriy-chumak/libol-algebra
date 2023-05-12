// Arithmetic Operations
// =====================
#include "declare.h"

static inline fp_t addition(fp_t a, fp_t b) {
	return a + b;
}
static inline fp_t subtraction(fp_t a, fp_t b) {
	return a - b;
}
static inline fp_t multiplication(fp_t a, fp_t b) {
	return a * b;
}
static inline fp_t division(fp_t a, fp_t b) {
	return a / b;
}
static inline fp_t exponentiation(fp_t x, fp_t n) {
	return POW(x, n);
}
static inline fp_t logarithm_e(fp_t a) {
	return LOG(a);
}
static inline fp_t logarithm_10(fp_t a) {
	return LOG10(a);
}
static inline fp_t logarithm_2(fp_t a) {
	return LOG2(a);
}
static inline fp_t square(fp_t a) {
	return a * a;
}
static inline fp_t negate(fp_t a) {
	return -a;
}
static inline fp_t square_root(fp_t a) {
	return SQRT(a);
}
static inline fp_t cube_root(fp_t a) {
	return CBRT(a);
}
static inline fp_t root(fp_t x, fp_t n) {
	return POW(x, (fp_t)1 / n);
}


// Basic
DECLARE2(Add, addition)
DECLARE2(Sub, subtraction)
DECLARE2(Mul, multiplication)
DECLARE2(Div, division)
DECLARE2(Pow, exponentiation)

// Logarithms
DECLARE1(Log, logarithm_e)
DECLARE1(Log10, logarithm_10)
DECLARE1(Log2, logarithm_2)

DECLARE1(Square, square)
DECLARE1(Negate, negate)

// Roots
DECLARE1(Sqrt, square_root)
DECLARE1(Cbrt, cube_root)
DECLARE2(Root, root)
