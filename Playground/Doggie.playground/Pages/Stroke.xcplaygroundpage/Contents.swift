//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

let view = StrokeView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

view.p0 = Point(x: 193.351540581, y: 450.0)
view.p1 = Point(x: 68.419626742, y: 405.533547909)
view.p2 = Point(x: 235.441166727, y: 102.471733928)
view.p3 = Point(x: 350.973064061, y: 50.0)

PlaygroundPage.current.liveView = view
