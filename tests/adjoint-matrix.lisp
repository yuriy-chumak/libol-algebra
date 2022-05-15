#!/usr/bin/env ol
(import (otus algebra))

(assert (let ((M [[-3 2 -5]
                  [-1 0 -2]
                  [3 -4 1]]))
      (adjoint-matrix M))  ===> [[-8 18 -4]
                                 [-5 12 -1]
                                 [ 4 -6  2]])

(assert (let ((M [[-3 2 -5]
                  [-1 0 -2]
                  [3 -4 1]]))
      (matrix-product M (adjoint-matrix M)))  ===> [[-6 0 0]
                                                    [0 -6 0]
                                                    [0 0 -6]])

(print "ok.")
