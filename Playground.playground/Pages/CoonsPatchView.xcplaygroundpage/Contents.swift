//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

let view = CoonsPatchView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

PlaygroundPage.current.liveView = view

let ellipse = Shape.Ellipse(center: Point(x: 0.5, y: 0.5), radius: Radius(x: 0.4, y: 0.4))

view.shape = ellipse
