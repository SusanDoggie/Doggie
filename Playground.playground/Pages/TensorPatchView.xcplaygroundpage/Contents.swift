//: Playground - noun: a place where people can play

import Cocoa
import Doggie
import PlaygroundSupport

let view = TensorPatchView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

PlaygroundPage.current.liveView = view

let ellipse = Shape(ellipseIn: Rect(x: 0.1, y: 0.1, width: 0.8, height: 0.8))

view.shape = ellipse

