//
//  PathCoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

private struct PathDataScanner<I : IteratorProtocol> : IteratorProtocol, Sequence where I.Element == String {
    
    var iterator: I
    var current: String!
    
    @inline(__always)
    init(_ iterator: I) {
        self.iterator = iterator
    }
    
    @inline(__always)
    init<S : Sequence>(_ sequence: S) where S.Iterator == I {
        self.iterator = sequence.makeIterator()
    }
    
    @inline(__always)
    @discardableResult
    mutating func next() -> String? {
        current = iterator.next()
        return current
    }
}

private let pathDataMatcher: Regex = "[MmLlHhVvCcSsQqTtAaZz]|[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?"

extension Shape {
    
    public struct DecoderError : Error {
        
        var command: String?
    }
    
    @inline(__always)
    private func toDouble(_ str: String?) throws -> Double {
        
        if str != nil, let val = Double(str!) {
            return val
        }
        throw DecoderError(command: str)
    }
    
    @inline(__always)
    private func toInt(_ str: String?) throws -> Int {
        
        if str != nil, let val = Int(str!) {
            return val
        }
        throw DecoderError(command: str)
    }
    
    public init(code: String) throws {
        self.init()
        
        var g = PathDataScanner(code.match(pathDataMatcher))
        var component = Component()
        var relative = Point()
        var lastcontrol = Point()
        var lastbezier = 0
        
        let commandsymbol = Array("MmLlHhVvCcSsQqTtAaZz".utf8)
        
        g.next()
        while let command = g.current {
            g.next()
            switch command {
            case "M":
                repeat {
                    if component.count != 0 {
                        self.append(component)
                        component.removeAll(keepingCapacity: true)
                        component.isClosed = false
                    }
                    let move = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    component.start = move
                    relative = move
                    lastcontrol = move
                    lastbezier = 0
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "m":
                repeat {
                    if component.count != 0 {
                        self.append(component)
                        component.removeAll(keepingCapacity: true)
                        component.isClosed = false
                    }
                    let move = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    component.start = move
                    relative = move
                    lastcontrol = move
                    lastbezier = 0
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "L":
                repeat {
                    let line = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "l":
                repeat {
                    let line = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "H":
                repeat {
                    let line = Point(x: try toDouble(g.current), y: relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "h":
                repeat {
                    let line = Point(x: try toDouble(g.current) + relative.x, y: relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "V":
                repeat {
                    let line = Point(x: relative.x, y: try toDouble(g.current))
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "v":
                repeat {
                    let line = Point(x: relative.x, y: try toDouble(g.current) + relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    component.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "C":
                repeat {
                    let p1 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p2 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    let p3 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    component.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "c":
                repeat {
                    let p1 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p2 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p3 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    component.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "S":
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p3 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    component.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "s":
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p3 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    component.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Q":
                repeat {
                    let p1 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p2 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    component.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "q":
                repeat {
                    let p1 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p2 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    component.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "T":
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    component.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "t":
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    component.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "A":
                repeat {
                    let rx = try toDouble(g.current)
                    let ry = try toDouble(g.next())
                    let rotate = try toDouble(g.next())
                    let largeArc: Bool
                    let sweep: Bool
                    if let val = g.next() {
                        switch val {
                        case "0":
                            largeArc = false
                            sweep = try toInt(g.next()) != 0
                        case "1":
                            largeArc = true
                            sweep = try toInt(g.next()) != 0
                        case "00":
                            largeArc = false
                            sweep = false
                        case "01":
                            largeArc = false
                            sweep = true
                        case "10":
                            largeArc = true
                            sweep = false
                        case "11":
                            largeArc = true
                            sweep = true
                        default: throw DecoderError(command: val)
                        }
                    } else {
                        throw DecoderError(command: nil)
                    }
                    let x = try toDouble(g.next())
                    let y = try toDouble(g.next())
                    let arc = bezierArc(relative, Point(x: x, y: y), Radius(x: rx, y: ry), Double.pi * rotate / 180, largeArc, sweep)
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    component.append(contentsOf: arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "a":
                repeat {
                    let rx = try toDouble(g.current)
                    let ry = try toDouble(g.next())
                    let rotate = try toDouble(g.next())
                    let largeArc: Bool
                    let sweep: Bool
                    if let val = g.next() {
                        switch val {
                        case "0":
                            largeArc = false
                            sweep = try toInt(g.next()) != 0
                        case "1":
                            largeArc = true
                            sweep = try toInt(g.next()) != 0
                        case "00":
                            largeArc = false
                            sweep = false
                        case "01":
                            largeArc = false
                            sweep = true
                        case "10":
                            largeArc = true
                            sweep = false
                        case "11":
                            largeArc = true
                            sweep = true
                        default: throw DecoderError(command: val)
                        }
                    } else {
                        throw DecoderError(command: nil)
                    }
                    let x = try toDouble(g.next()) + relative.x
                    let y = try toDouble(g.next()) + relative.y
                    let arc = bezierArc(relative, Point(x: x, y: y), Radius(x: rx, y: ry), Double.pi * rotate / 180, largeArc, sweep)
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    component.append(contentsOf: arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Z", "z":
                if component.count != 0 {
                    component.isClosed = true
                    self.append(component)
                    component.removeAll(keepingCapacity: true)
                    component.isClosed = false
                    relative = component.start
                    lastcontrol = component.start
                    lastbezier = 0
                }
            default:
                throw DecoderError(command: command)
            }
        }
        if component.count != 0 {
            self.append(component)
        }
    }
}

@inline(__always)
private func arcDetails(_ start: Point, _ end: Point, _ radius: Radius, _ rotate: Double, _ largeArc: Bool, _ sweep: Bool) -> (Point, Radius) {
    let centers = EllipseCenter(radius, rotate, start, end)
    if centers.count == 0 {
        return (0.5 * (start + end), EllipseRadius(start, end, radius, rotate))
    } else if centers.count == 1 || (cross(centers[0] - start, end - start).sign == (sweep ? .plus : .minus) ? largeArc : !largeArc) {
        return (centers[0], radius)
    } else {
        return (centers[1], radius)
    }
}
@inline(__always)
private func bezierArc(_ start: Point, _ end: Point, _ radius: Radius, _ rotate: Double, _ largeArc: Bool, _ sweep: Bool) -> [Shape.Segment] {
    let (center, radius) = arcDetails(start, end, radius, rotate, largeArc, sweep)
    let _arc_transform = SDTransform.scale(x: radius.x, y: radius.y) * SDTransform.rotate(rotate)
    let _arc_transform_inverse = _arc_transform.inverse
    let _begin = (start - center) * _arc_transform_inverse
    let _end = (end - center) * _arc_transform_inverse
    let startAngle = atan2(_begin.y, _begin.x)
    var endAngle = atan2(_end.y, _end.x)
    if sweep {
        while endAngle < startAngle {
            endAngle += 2 * Double.pi
        }
    } else {
        while endAngle > startAngle {
            endAngle -= 2 * Double.pi
        }
    }
    let _transform = SDTransform.rotate(startAngle) * _arc_transform
    let point = BezierArc(endAngle - startAngle).lazy.map { $0 * _transform + center }
    var result: [Shape.Segment] = []
    if point.count > 1 {
        result.reserveCapacity(point.count / 3)
        for i in 0..<point.count / 3 {
            result.append(.cubic(point[i * 3 + 1], point[i * 3 + 2], point[i * 3 + 3]))
        }
    }
    return result
}

private let dataFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.negativeFormat = "#.#########"
    formatter.positiveFormat = "#.#########"
    return formatter
    }()

@inline(__always)
private func getDataString(_ x: [Double]) -> String {
    var str = ""
    for _x in x.map({ dataFormatter.string(from: NSNumber(value: $0)) ?? "0" }) {
        if !str.isEmpty && _x.first != "-" {
            " ".write(to: &str)
        }
        _x.write(to: &str)
    }
    return str
}

@inline(__always)
private func _round(_ x: Double) -> Double {
    return round(x * 1000000000) / 1000000000
}

@inline(__always)
private func getPathDataString(_ command: Character?, _ x: Double ...) -> String {
    var result = ""
    command?.write(to: &result)
    let dataStr = getDataString(x)
    if result.isEmpty && !dataStr.isEmpty && dataStr.first != "-" {
        " ".write(to: &result)
    }
    dataStr.write(to: &result)
    return result
}

public extension Shape {
    
    public func encode() -> String {
        
        var data = ""
        var currentState = -1
        var start = Point()
        var relative = Point()
        var lastControl: Point?
        for item in self {
            item.serialize(&currentState, start: &start, relative: &relative, lastControl: &lastControl, &data)
        }
        return data
    }
}

private extension Shape.Component {
    
    func serialize(_ currentState: inout Int, start: inout Point, relative: inout Point, lastControl: inout Point?, _ data: inout String) {
        
        let move1 = getPathDataString("M", self.start.x, self.start.y)
        let move2 = getPathDataString("m", self.start.x - relative.x, self.start.y - relative.y)
        
        currentState = 0
        start = self.start
        relative = self.start
        lastControl = nil
        
        if move1.count <= move2.count {
            move1.write(to: &data)
        } else {
            move2.write(to: &data)
        }
        
        for item in self {
            item.serialize(&currentState, start: &start, relative: &relative, lastControl: &lastControl).write(to: &data)
        }
        
        if self.isClosed {
            "z".write(to: &data)
        }
    }
    
}

private extension Shape.Segment {
    
    func serialize(_ currentState: inout Int, start: inout Point, relative: inout Point, lastControl: inout Point?) -> String {
        
        let _serialize1 = serialize1(currentState, start, relative, lastControl)
        let _serialize2 = serialize2(currentState, start, relative, lastControl)
        if _serialize1.0.count <= _serialize2.0.count {
            currentState = _serialize1.1
            start = _serialize1.2
            relative = _serialize1.3
            lastControl = _serialize1.4
            return _serialize1.0
        }
        currentState = _serialize2.1
        start = _serialize2.2
        relative = _serialize2.3
        lastControl = _serialize2.4
        return _serialize2.0
    }
    
    @inline(__always)
    func isSmooth(_ p: Point, _ relative: Point, _ lastControl: Point?) -> Bool {
        
        if let lastControl = lastControl {
            let d = p + lastControl - 2 * relative
            return _round(d.x) == 0 && _round(d.y) == 0
        }
        return false
    }
    
    func serialize1(_ currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        
        switch self {
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if _round(relative.x) == _round(point.x) {
                if currentState == 1 {
                    str = getPathDataString(nil, point.y)
                } else {
                    str = getPathDataString("V", point.y)
                }
                currentState = 1
            } else if _round(relative.y) == _round(point.y) {
                if currentState == 3 {
                    str = getPathDataString(nil, point.x)
                } else {
                    str = getPathDataString("H", point.x)
                }
                currentState = 3
            } else {
                if currentState == 5 {
                    str = getPathDataString(nil, point.x, point.y)
                } else {
                    str = getPathDataString("L", point.x, point.y)
                }
                currentState = 5
            }
            return (str, currentState, start, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p2, relative, lastControl) && 7...10 ~= currentState {
                if currentState == 7 {
                    str = getPathDataString(nil, p2.x, p2.y)
                } else {
                    str = getPathDataString("T", p2.x, p2.y)
                }
                currentState = 7
            } else {
                if currentState == 9 {
                    str = getPathDataString(nil, p1.x, p1.y, p2.x, p2.y)
                } else {
                    str = getPathDataString("Q", p1.x, p1.y, p2.x, p2.y)
                }
                currentState = 9
            }
            return (str, currentState, start, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p3, relative, lastControl) && 11...14 ~= currentState {
                if currentState == 11 {
                    str = getPathDataString(nil, p2.x, p2.y, p3.x, p3.y)
                } else {
                    str = getPathDataString("S", p2.x, p2.y, p3.x, p3.y)
                }
                currentState = 11
            } else {
                if currentState == 13 {
                    str = getPathDataString(nil, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
                } else {
                    str = getPathDataString("C", p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
                }
                currentState = 13
            }
            return (str, currentState, start, p3, p2)
        }
    }
    
    func serialize2(_ currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        
        switch self {
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if _round(relative.x) == _round(point.x) {
                if currentState == 2 {
                    str = getPathDataString(nil, point.y - relative.y)
                } else {
                    str = getPathDataString("v", point.y - relative.y)
                }
                currentState = 2
            } else if _round(relative.y) == _round(point.y) {
                if currentState == 4 {
                    str = getPathDataString(nil, point.x - relative.x)
                } else {
                    str = getPathDataString("h", point.x - relative.x)
                }
                currentState = 4
            } else {
                if currentState == 6 {
                    str = getPathDataString(nil, point.x - relative.x, point.y - relative.y)
                } else {
                    str = getPathDataString("l", point.x - relative.x, point.y - relative.y)
                }
                currentState = 6
            }
            return (str, currentState, start, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p2, relative, lastControl) && 7...10 ~= currentState {
                if currentState == 8 {
                    str = getPathDataString(nil, p2.x - relative.x, p2.y - relative.y)
                } else {
                    str = getPathDataString("t", p2.x - relative.x, p2.y - relative.y)
                }
                currentState = 8
            } else {
                if currentState == 10 {
                    str = getPathDataString(nil, p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y)
                } else {
                    str = getPathDataString("q", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y)
                }
                currentState = 10
            }
            return (str, currentState, start, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p3, relative, lastControl) && 11...14 ~= currentState {
                if currentState == 12 {
                    str = getPathDataString(nil, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                } else {
                    str = getPathDataString("s", p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                }
                currentState = 12
            } else {
                if currentState == 14 {
                    str = getPathDataString(nil, p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                } else {
                    str = getPathDataString("c", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                }
                currentState = 14
            }
            return (str, currentState, start, p3, p2)
        }
    }
}
