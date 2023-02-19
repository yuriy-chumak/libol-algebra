#pragma once

#define TENSOR 0xFAFFF1ED

#include <stddef.h>

// тип, который мы будем использовать для вычислений (обычно - float)
typedef float fp_t;

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
