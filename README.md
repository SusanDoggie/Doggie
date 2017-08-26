# Doggie Swift Foundation

[![Build Status](https://travis-ci.org/SusanDoggie/Doggie.svg?branch=master)](https://travis-ci.org/SusanDoggie/Doggie)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey.svg?style=flat)
[![GitHub release](https://img.shields.io/github/release/SusanDoggie/Doggie.svg?style=flat&maxAge=2592000)](https://github.com/SusanDoggie/Doggie/releases)
[![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](https://swift.org)
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

## Supporting

<a href='https://pledgie.com/campaigns/34662'><img alt='Click here to lend your support to: Doggie - Swift Foundation Library and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/34662.png?skin_name=chrome' border='0' ></a>

## License

Doggie is licensed under the [MIT license](LICENSE).
