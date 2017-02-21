//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

let view = CoonsPatchView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

PlaygroundPage.current.liveView = view

//var square = SDRectangle(x: 0.1, y: 0.1, width: 0.8, height: 0.8)
//square.rotate = M_PI_4
//
//view.shape = square

let ellipse = SDEllipse(x: 0.5, y: 0.5, radius: 0.4)

view.shape = ellipse
