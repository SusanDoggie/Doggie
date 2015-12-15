# Doggie Swift Foundation

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
- lockable class (threading).
- rectangle, ellipse and path (graphic).
```swift
let path = try SDPath(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")
```

### License

Doggie is licensed under the [MIT license](LICENSE).
