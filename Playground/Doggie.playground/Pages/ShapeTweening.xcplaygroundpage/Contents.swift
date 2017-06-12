//: Playground - noun: a place where people can play

import Cocoa
import Doggie

func curves(_ shape: Shape) -> [[Point]] {
    var result: [[Point]] = []
    for item in shape {
        var last = item.start
        for segment in item {
            switch segment {
            case let .line(p1):
                result.append([last, p1])
                last = p1
            case let .quad(p1, p2):
                result.append([last, p1, p2])
                last = p2
            case let .cubic(p1, p2, p3):
                result.append([last, p1, p2, p3])
                last = p3
            }
        }
    }
    return result
}

let square = Shape.Rectangle(x: 0, y: -50, width: 100, height: 100)
let ellipse = Shape.Ellipse(center: Point(x: 700, y: 0), radius: 70.7)

func ShapeTween(_ t: Double) -> Shape {
    
    var _s = curves(square)
    let _e = curves(ellipse)
    
    if let first = _s.first?.first, let last = _s.last?.last {
        _s.append([last, first])
    }
    
    let b = zip(_s, _e).map { BezierTweening(start: $0.0, end: $0.1, t) }
    
    return [Shape.Component(start: b[0][0], closed: true, segments: b.flatMap {
        switch $0.count {
        case 2: return .line($0[1])
        case 3: return .quad($0[1], $0[2])
        case 4: return .cubic($0[1], $0[2], $0[3])
        default: return nil
        }
    })]
}

var shapes: Shape = []
for i in 0...10 {
    shapes.append(contentsOf: ShapeTween(Double(i) / 10))
}

shapes
