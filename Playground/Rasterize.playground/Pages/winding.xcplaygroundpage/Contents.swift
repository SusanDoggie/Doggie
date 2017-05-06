//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let size = 20

var shape = try Shape(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")

shape.scale *= Double(size) / shape.boundary.height

shape.center = Point(x: 0.5 * Double(size), y: 0.5 * Double(size))

for y in 0...size {
    for x in 0...size {
        let winding = shape.winding(Point(x: x, y: y))
        if winding == 0 {
            print("  ", terminator: "")
        } else {
            print(" \(-winding)", terminator: "")
        }
    }
    print("")
}
