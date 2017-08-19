# Doggie Swift Foundation

[![Build Status](https://travis-ci.org/SusanDoggie/Doggie.svg?branch=master)](https://travis-ci.org/SusanDoggie/Doggie)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey.svg?style=flat)
[![GitHub release](https://img.shields.io/github/release/SusanDoggie/Doggie.svg?style=flat&maxAge=2592000)](https://github.com/SusanDoggie/Doggie/releases)
[![Swift](https://img.shields.io/badge/swift-3.1-orange.svg?style=flat)](https://swift.org)
[![MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

Doggie is a foundational support library for Apple's swift. It includes Functional programming support, Mathematics, Accelerate, Signal processing and Graphic Libraries.

## Features

- standard like functional programming methods support.
```swift
let arrayA = [1, 2, 3, 4]
let arrayB = [5, 6, 7, 8]
let concated = arrayA.concat(arrayB)  // [1, 2, 3, 4, 5, 6, 7, 8]
```
- complex number supports with transcendentals overloads such as sin(z), cos(z) etc.
- polynomial library with operators.
- accelerate libraries.
- asynchronous task.
```swift
let task = SDTask { () -> Int in
    sleep(2)
    return 5
}

let task2 = task.then { a -> Int in
    sleep(2)
    return a + 1
}

print(task.result)   // 5
print(task2.result)  // 6
```
- atomic and lockable class (threading).
- rectangle, ellipse and path (graphic).
```swift
let path = try SDPath(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")
```

## Benchmark

Real to complex Radix 2 Cooley-Tukey (time in second):

Log(n) | vDSP - vDSP_fft_zropD(Half length) | Doggie - HalfRadix2CooleyTukey(Half length) | Doggie - Radix2CooleyTukey(Full length)
----- | ----- | ----- | -----
2 | 8e-07 | 5e-07 | 5e-07
3 | 9e-07 | 9e-07 | 5e-07
4 | 9e-07 | 5e-07 | 7e-07
5 | 7e-07 | 9e-07 | 1.2e-06
6 | 9e-07 | 1.3e-06 | 1.8e-06
7 | 1e-06 | 2.2e-06 | 2.2e-06
8 | 1.5e-06 | 4.3e-06 | 4.7e-06
9 | 2.6e-06 | 8.9e-06 | 8.8e-06
10 | 4.7e-06 | 1.84e-05 | 1.86e-05
11 | 1.13e-05 | 3.89e-05 | 4.18e-05
12 | 2.3e-05 | 8.41e-05 | 8.54e-05
13 | 5.63e-05 | 0.000179 | 0.0001802
14 | 0.000121 | 0.0003829 | 0.0003825
15 | 0.0002964 | 0.0008038 | 0.0007956
16 | 0.0007503 | 0.0018305 | 0.0016818
17 | 0.0013825 | 0.0037203 | 0.0041209
18 | 0.0049216 | 0.0101282 | 0.0110208
19 | 0.0222736 | 0.0260269 | 0.0278754
20 | 0.0542149 | 0.0558044 | 0.0596883

Complex to complex Radix 2 Cooley-Tukey (time in second):

Log(n) | vDSP - vDSP_fft_zopD | Doggie - Radix2CooleyTukey
----- | ----- | -----
2 | 1e-06 | 4e-07
3 | 1.4e-06 | 7e-07
4 | 7e-07 | 9e-07
5 | 7e-07 | 1.3e-06
6 | 8e-07 | 2.3e-06
7 | 1.2e-06 | 4e-06
8 | 2.6e-06 | 9.2e-06
9 | 5.2e-06 | 1.73e-05
10 | 1e-05 | 3.41e-05
11 | 2.01e-05 | 7.48e-05
12 | 4.92e-05 | 0.0001649
13 | 9.97e-05 | 0.0003494
14 | 0.0002454 | 0.000749
15 | 0.0005086 | 0.0017483
16 | 0.0012301 | 0.0032617
17 | 0.003645 | 0.0094316
18 | 0.020886 | 0.0267119
19 | 0.0501573 | 0.0610655
20 | 0.1102911 | 0.1287243

## License

Doggie is licensed under the [MIT license](LICENSE).
