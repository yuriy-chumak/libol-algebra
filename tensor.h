#pragma once

#define VECTOR 1
#define MATRIX 2
// other is tensors

// тип, который мы будем использовать для вычислений (обычно - float)
typedef float fp_t;

// struct tensor
// {
// 	unsigned ID; // уникальный идентификатор объекта, TTENSOR
// 	unsigned type; // 1,2,3,...,N (количество размерностей)
// 	fp_t* data;  // непосредственные данные
// 	unsigned dimension[]; // размеры тензора
// };

// typedef struct tensor tensor_t;

// TODO:
// или держать размерности отдельным объектом в ol
// а данные отдельным в обычной памяти
// и передавать в код пару "размерности"+"данные"
