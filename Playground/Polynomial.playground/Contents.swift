//: Playground - noun: a place where people can play

import Cocoa
import Doggie


let polynomial = [-1, 1] * [-2, 1] * [-3, 1] * [-3, 1] * [-5, 1] * [-6, 1] * [sqrt(5), 1] * [-8, 1] * [-8, 1]

sqrt(5)

print(polynomial.roots)

print(roots(polynomial, eps: 1e-14))

test1(polynomial)

test2(polynomial, eps: 1e-14)
