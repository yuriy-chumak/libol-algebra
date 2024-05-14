#!/usr/bin/env ol
(import (otus algebra))

(assert (det [[3  7]
              [1 -4]]) ===> -19)

(assert (det [[1 2 3]
              [4 5 6]
              [7 8 9]]) ===> 0)

(assert (det [[-2 -1  2]
              [ 2  1  4]
              [-3  3 -1]]) ===> 54)

(assert (det (Index (Matrix 8 8) (lambda (i j)
      (+ i j (* i j))))) ===> 0)

(print "ok.")
