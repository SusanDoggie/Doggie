//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let _path = CGMutablePath()

_path.move(to: CGPoint(x: 0, y: 0))
_path.addLine(to: CGPoint(x: -50, y: 50))
_path.addQuadCurve(to: CGPoint(x: 0, y: 100), control: CGPoint(x: -50, y: 100))
_path.addLine(to: CGPoint(x: 50, y: 50))

_path.move(to: CGPoint(x: 0, y: -50))
_path.addLine(to: CGPoint(x: 50, y: 0))
_path.addQuadCurve(to: CGPoint(x: 0, y: 50), control: CGPoint(x: 50, y: 50))
_path.addLine(to: CGPoint(x: -50, y: 0))

Shape(_path)

NSBezierPath(cgPath: _path)

_path.closeSubpath()

Shape(_path)

NSBezierPath(cgPath: _path)
