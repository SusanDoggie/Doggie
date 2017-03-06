//: Playground - noun: a place where people can play

import Cocoa
import Doggie

func curves(_ shape: Shape) -> [[Point]] {
    var result: [[Point]] = []
    shape.apply { command, state in
        switch command {
        case let .line(p1): result.append([state.last, p1])
        case let .quad(p1, p2): result.append([state.last, p1, p2])
        case let .cubic(p1, p2, p3): result.append([state.last, p1, p2, p3])
        default: break
        }
    }
    return result
}

var square = Shape.Rectangle(x: 0, y: -50, width: 100, height: 100)
let ellipse = Shape.Ellipse(center: Point(x: 700, y: 0), radius: 70.7)

square.rotate += 0.5 * Double.pi
square = square.identity

func ShapeTween(_ t: Double) -> Shape {
    
    var _s = curves(square)
    let _e = curves(ellipse)
    
    if let first = _s.first?.first, let last = _s.last?.last {
        _s.append([last, first])
    }
    
    let b = zip(_s, _e).map { BezierTweening(start: $0, end: $1, t) }
    
    var result: Shape = [.move(b[0][0])]
    for bezier in b {
        switch bezier.count {
        case 2: result.append(.line(bezier[1]))
        case 3: result.append(.quad(bezier[1], bezier[2]))
        case 4: result.append(.cubic(bezier[1], bezier[2], bezier[3]))
        default: break
        }
    }
    result.append(.close)
    return result
}

var shapes: Shape = []
for i in 0...10 {
    shapes.append(contentsOf: ShapeTween(Double(i) / 10))
}

shapes
