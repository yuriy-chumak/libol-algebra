#pragma once
#include <stdlib.h>
#include <stdarg.h>
#include <stddef.h>

#include <assert.h>
#include <string.h>

//#define TENSOR 0xFAFFF1ED

#include <math.h>
typedef float fp_t; // inexact тип для вычислений (обычно - float)

#include <stdio.h>
#include <ol/vm.h>
double OL2D(word arg); float OL2F(word arg); // implemented in olvm.c
#define ol2f(num)\
    __builtin_choose_expr( __builtin_types_compatible_p\
        (fp_t, double), OL2D(num), OL2F(num) )

#ifdef payload
#undef payload
#endif
#define payload(array) ((fp_t*)&car(array))

// allocator:
// TODO: rename to new_float_array_
word* new_tensor_(olvm_t* this, size_t size, size_t n, ...);
#define NARG(...) NARG_N(_, ## __VA_ARGS__,19,18,17,16,15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)
#define NARG_N(_,n0,n1,n2,n3,n4,n5,n6,n7,n8,n9,mn10,n11,n12,n13,n14,n15,n16,n17,n18, n,...) n
#define new_tensor(this, size, ...) new_tensor_(this, size, NARG(__VA_ARGS__), ##__VA_ARGS__)

// core functions:
int size(word dimensions);
int offset(word dimensions, word index);



// typedef struct tensor_t
// {
//     unsigned ID; // уникальный идентификатор объекта, TTENSOR
//     size_t size; // размер даннызх
//     fp_t data[]; // непосредственные данные
// } tensor_t;

// typedef struct tensor tensor_t;

// TODO:
// или держать размерности отдельным объектом в ol
// а данные отдельным в обычной памяти
// и передавать в код пару "размерности"+"данные"
