//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let square = Shape(rect: Rect(x: 0, y: -50, width: 100, height: 100))
let ellipse = Shape(ellipseIn: Rect(x: 629.3, y: -70.7, width: 141.4, height: 141.4))

var shapes: Shape = []
for i in 0...10 {
    shapes.append(contentsOf: square.tweened(to: ellipse, Double(i) / 10))
}

shapes.preview()
