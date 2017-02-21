//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

let view = TensorPatchView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

PlaygroundPage.current.liveView = view

var square = Shape.Rectangle(Rect(x: 0.2, y: 0.2, width: 0.6, height: 0.6))
square.rotate = M_PI_4

view.shape = square

//let ellipse = Shape.Ellipse(center: Point(x: 0.5, y: 0.5), radius: Radius(x: 0.4, y: 0.4))
//
//view.shape = ellipse
