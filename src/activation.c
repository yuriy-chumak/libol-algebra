// Activation Functions
// =====================
#include "declare.h"

// -----------------------------------------------
// https://en.wikipedia.org/wiki/Logistic_function

static inline fp_t logistic(fp_t x) {
	return (ONE / (ONE + EXP(-x)));
}
static inline fp_t dlogistic_dx(fp_t x) {
	fp_t g = logistic(x);
	return g * (ONE - g);
}
static inline fp_t dlogistic_dx_logistic(fp_t g) {
	return g * (ONE - g);
}

DECLARE1(Logistic, logistic)
DECLARE1(DLogisticDx, dlogistic_dx)
DECLARE1(DLogisticDx_Logistic, dlogistic_dx_logistic)


// ---------------------------------------------------------
// https://en.wikipedia.org/wiki/Rectifier_(neural_networks)

static inline fp_t relu(fp_t x) {
	return x > 0 ? x : ZERO;
}
static inline fp_t drelu_dx(fp_t x) {
	return x > 0 ? 1 : ZERO;
}

DECLARE1(ReLU, relu)
DECLARE1(DReLUDx, drelu_dx)


// -----------------------------------------------------
// https://en.wikipedia.org/wiki/Heaviside_step_function
static inline fp_t heaviside(fp_t x) {
	return x > 0 ? ONE : ZERO;
}

DECLARE1(Heaviside, heaviside)
