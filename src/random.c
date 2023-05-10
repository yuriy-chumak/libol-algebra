#include "declare.h"

// https://en.wikipedia.org/wiki/Normal_distribution#Generating_values_from_normal_distribution
static
fp_t randn()
{
	fp_t u = rand() / (fp_t)RAND_MAX;
	fp_t r = SQRT(-2 * LOG(u));
	return (rand() % 2) ? -r : r;
}

DECLARE0(Randn, randn)
