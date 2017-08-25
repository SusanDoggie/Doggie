//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let b1: Bezier = [Point(x: 10, y: 0), Point(x: 20, y: 10), Point(x: 80, y: -10), Point(x: 100, y: 0)]
let b2: Bezier = [Point(x: 10, y: 0), Point(x: 50, y: 10), Point(x: 100, y: 10)]

let t1 = Date()

CubicQuadBezierIntersect(b1[0], b1[1], b1[2], b1[3], b2[0], b2[1], b2[2])

t1.timeIntervalSinceNow

let t2 = Date()

b1.intersect(b2)

t2.timeIntervalSinceNow

let t3 = Date()

CubicQuadBezierIntersect(b1[0], b1[1], b1[2], b1[3], b2[0], b2[1], b2[2])

t3.timeIntervalSinceNow

let t4 = Date()

b1.intersect(b2)

t4.timeIntervalSinceNow
