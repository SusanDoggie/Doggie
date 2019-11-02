//: Playground - noun: a place where people can play

import Cocoa
import Doggie



let arrayA = [1, 2, 3, 4]
let arrayB = [5, 6, 7, 8]
let concatenated = arrayA.concat(arrayB)

Array(concatenated)  // [1, 2, 3, 4, 5, 6, 7, 8]



let task = SDTask.async { () -> Int in
    sleep(2)
    return 5
}

let task2 = task.then { a -> Int in
    sleep(2)
    return a + 1
}

task.wait(until: .now() + 1)

task.result   // 5
task2.result  // 6

task.wait(until: .now() + 1)


let shape = try Shape(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")

let region = ShapeRegion(shape, winding: .nonZero)
let ellipse = ShapeRegion(ellipseIn: shape.boundary)

region.union(ellipse).preview()

region.intersection(ellipse).preview()

region.subtracting(ellipse).preview()
ellipse.subtracting(region).preview()

region.symmetricDifference(ellipse).preview()
