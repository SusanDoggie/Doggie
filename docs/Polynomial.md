# Introduction

Polynomial is a abstract struct for algebraic calculation. It conforms to `CollectionType`.

# Usage

Define a polynomial:
```swift
let poly: Polynomial = [-5, 2, 1]  // -5 + 2x + x^2
```

Polynomial arithmetic:
```swift
// addition
let add = poly + [4, 5]  // -1 + 7x + x^2

// subtraction
let sub = poly - [4, 5]  // -9 - 3x + x^2

// multiplication
let mul = poly * [4, 5]  // -20 - 17x + 14x^2 + 5x^3

// division
let div = poly / [4, 5]  // 0.24 + 0.2x

// remainder
let rem = poly % [4, 5]  // -5.96
```

Real roots of polynomial:
```swift
print(poly.roots)  // [1.449489742783178, -3.449489742783178]
```

Evaluate value of P(x):
```swift
print(poly.eval(7))  // P(7) = 58
```

Calculate derivative of polynomial:
```swift
let d = poly.derivative  // P'(x) = 2 + 2x
```

And power of polynomial:
```swift
let power = pow(poly, 2)  // P^2(x) = 25 - 20x - 6x^2 + 4x^3 + x^4
```

# Solving system of polynomial by Bézout matrix

Example:

1. x^2 + 4y^2 + 8y - 12 = 0
2. x^2 + 16y - 16 = 0

First, rewrite the above equations:

1. x^2 + (4y^2 + 8y - 12) = 0
2. x^2 + (16y - 16) = 0

And we get two quadratic equations about x.
```swift
// (4y^2 + 8y - 12) + 0x + x^2 = 0
let u2 = 1.0
let u1 = 0.0
let u0: Polynomial = [-12, 8, 4]

// (16y - 16) + 0x + x^2 = 0
let v2 = 1.0
let v1 = 0.0
let v0: Polynomial = [-16, 16]
```

Then, we write the equations as Bézout matrix:
```swift
let m00 = u2 * v1 - u1 * v2
let m01 = u2 * v0 - u0 * v2
let m10 = m01
let m11 = u1 * v0 - u0 * v1
```

If the system of polynomial have intersections on (x, y), the determinant of Bézout matrix is equal to zero. Hence, we can find roots of `Det(Bézout matrix) = 0` which represent the result of the system of polynomial.
```swift
let det = m00 * m11 - m01 * m10  // -16 + 64y - 96y^2 + 64y^3 - 16y^4
let result = det.roots  // results of y
```
