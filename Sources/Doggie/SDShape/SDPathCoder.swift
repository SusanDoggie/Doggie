//
//  SDPathCoder.swift
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
    
    @_transparent
    init(_ iterator: I) {
        self.iterator = iterator
    }
    
    @_transparent
    init<S : Sequence>(_ sequence: S) where S.Iterator == I {
        self.iterator = sequence.makeIterator()
    }
    
    @_transparent
    @discardableResult
    mutating func next() -> String? {
        current = iterator.next()
        return current
    }
}

private let pathDataMatcher: Regex = "[MmLlHhVvCcSsQqTtAaZz]|[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?"

extension SDPath {
    
    public struct DecoderError : Error {
        
        var command: String?
    }
    
    @_transparent
    fileprivate func toDouble(_ str: String?) throws -> Double {
        
        if str != nil, let val = Double(str!) {
            return val
        }
        throw DecoderError(command: str)
    }
    
    @_transparent
    fileprivate func toInt(_ str: String?) throws -> Int {
        
        if str != nil, let val = Int(str!) {
            return val
        }
        throw DecoderError(command: str)
    }
    
    public init(code: String) throws {
        self.init()
        
        var g = PathDataScanner(code.match(pathDataMatcher))
        var start = Point()
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
                    if self.lastMove {
                        self.removeLast()
                    }
                    let move = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    start = move
                    relative = move
                    lastcontrol = move
                    lastbezier = 0
                    self.append(.move(move))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "m":
                repeat {
                    if self.lastMove {
                        self.removeLast()
                    }
                    let move = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    start = move
                    relative = move
                    lastcontrol = move
                    lastbezier = 0
                    self.append(.move(move))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "L":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "l":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "H":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: try toDouble(g.current), y: relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "h":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: try toDouble(g.current) + relative.x, y: relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "V":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: relative.x, y: try toDouble(g.current))
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "v":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let line = Point(x: relative.x, y: try toDouble(g.current) + relative.y)
                    relative = line
                    lastcontrol = line
                    lastbezier = 0
                    self.append(.line(line))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "C":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p2 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    let p3 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    self.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "c":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p2 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p3 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    self.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "S":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p3 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    self.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "s":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p3 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p3
                    lastcontrol = p2
                    lastbezier = 2
                    self.append(.cubic(p1, p2, p3))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Q":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    let p2 = Point(x: try toDouble(g.next()), y: try toDouble(g.next()))
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    self.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "q":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    let p2 = Point(x: try toDouble(g.next()) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    self.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "T":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    self.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "t":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
                repeat {
                    let p1 = lastbezier == 2 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    self.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "A":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
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
                    self.append(contentsOf: arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "a":
                if self.count == 0 || self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.move(start))
                }
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
                    self.append(contentsOf: arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Z", "z":
                if self.lastMove {
                    self.removeLast()
                } else if self.count != 0 && !self.lastClose {
                    relative = start
                    lastcontrol = start
                    lastbezier = 0
                    self.append(.close)
                }
            default:
                throw DecoderError(command: command)
            }
        }
    }
}

@_transparent
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
@_transparent
private func bezierArc(_ start: Point, _ end: Point, _ radius: Radius, _ rotate: Double, _ largeArc: Bool, _ sweep: Bool) -> [SDPath.Command] {
    let (center, radius) = arcDetails(start, end, radius, rotate, largeArc, sweep)
    let _arc_transform = SDTransform.Scale(x: radius.x, y: radius.y) * SDTransform.Rotate(rotate)
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
    let _transform = SDTransform.Rotate(startAngle) * _arc_transform
    let point = BezierArc(endAngle - startAngle).lazy.map { $0 * _transform + center }
    var result: [SDPath.Command] = []
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

@_transparent
private func getDataString(_ x: [Double]) -> String {
    var str = ""
    for _x in x.map({ dataFormatter.string(from: NSNumber(value: $0)) ?? "0" }) {
        if !str.isEmpty && _x.characters.first != "-" {
            " ".write(to: &str)
        }
        _x.write(to: &str)
    }
    return str
}

@_transparent
private func _round(_ x: Double) -> Double {
    return round(x * 1000000000) / 1000000000
}

@_transparent
private func getPathDataString(_ command: Character?, _ x: Double ...) -> String {
    var result = ""
    command?.write(to: &result)
    let dataStr = getDataString(x)
    if result.isEmpty && !dataStr.isEmpty && dataStr.characters.first != "-" {
        " ".write(to: &result)
    }
    dataStr.write(to: &result)
    return result
}

public extension SDPath {
    
    public func encode() -> String {
        
        var data = ""
        var currentState = -1
        var start = Point()
        var relative = Point()
        var lastControl: Point?
        for item in self {
            item.serialize(&currentState, start: &start, relative: &relative, lastControl: &lastControl).write(to: &data)
        }
        return data
    }
}

private extension SDPath.Command {
    
    func serialize(_ currentState: inout Int, start: inout Point, relative: inout Point, lastControl: inout Point?) -> String {
        
        if case .close = self {
            let str = currentState != 18 ? "z" : ""
            relative = start
            currentState = 18
            lastControl = nil
            return str
        }
        
        let _serialize1 = serialize1(currentState, start, relative, lastControl)
        let _serialize2 = serialize2(currentState, start, relative, lastControl)
        if _serialize1.0.characters.count <= _serialize2.0.characters.count {
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
    
    @_transparent
    func isSmooth(_ p: Point, _ relative: Point, _ lastControl: Point?) -> Bool {
        
        if let lastControl = lastControl {
            let d = p + lastControl - 2 * relative
            return _round(d.x) == 0 && _round(d.y) == 0
        }
        return false
    }
    
    func serialize1(_ currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        
        switch self {
        case let .move(point): return (getPathDataString("M", point.x, point.y), 0, point, point, nil)
            
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if _round(relative.x) == _round(point.x) {
                if currentState == 2 {
                    str = getPathDataString(nil, point.y)
                } else {
                    str = getPathDataString("V", point.y)
                }
                currentState = 2
            } else if _round(relative.y) == _round(point.y) {
                if currentState == 4 {
                    str = getPathDataString(nil, point.x)
                } else {
                    str = getPathDataString("H", point.x)
                }
                currentState = 4
            } else {
                if currentState == 6 {
                    str = getPathDataString(nil, point.x, point.y)
                } else {
                    str = getPathDataString("L", point.x, point.y)
                }
                currentState = 6
            }
            return (str, currentState, start, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p2, relative, lastControl) && 8...11 ~= currentState {
                if currentState == 8 {
                    str = getPathDataString(nil, p2.x, p2.y)
                } else {
                    str = getPathDataString("T", p2.x, p2.y)
                }
                currentState = 8
            } else {
                if currentState == 10 {
                    str = getPathDataString(nil, p1.x, p1.y, p2.x, p2.y)
                } else {
                    str = getPathDataString("Q", p1.x, p1.y, p2.x, p2.y)
                }
                currentState = 10
            }
            return (str, currentState, start, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p3, relative, lastControl) && 12...15 ~= currentState {
                if currentState == 12 {
                    str = getPathDataString(nil, p2.x, p2.y, p3.x, p3.y)
                } else {
                    str = getPathDataString("S", p2.x, p2.y, p3.x, p3.y)
                }
                currentState = 12
            } else {
                if currentState == 14 {
                    str = getPathDataString(nil, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
                } else {
                    str = getPathDataString("C", p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
                }
                currentState = 14
            }
            return (str, currentState, start, p3, p2)
        default: fatalError()
        }
    }
    
    func serialize2(_ currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        
        switch self {
        case let .move(point): return (getPathDataString("m", point.x - relative.x, point.y - relative.y), 1, point, point, nil)
            
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if _round(relative.x) == _round(point.x) {
                if currentState == 3 {
                    str = getPathDataString(nil, point.y - relative.y)
                } else {
                    str = getPathDataString("v", point.y - relative.y)
                }
                currentState = 3
            } else if _round(relative.y) == _round(point.y) {
                if currentState == 5 {
                    str = getPathDataString(nil, point.x - relative.x)
                } else {
                    str = getPathDataString("h", point.x - relative.x)
                }
                currentState = 5
            } else {
                if currentState == 7 {
                    str = getPathDataString(nil, point.x - relative.x, point.y - relative.y)
                } else {
                    str = getPathDataString("l", point.x - relative.x, point.y - relative.y)
                }
                currentState = 7
            }
            return (str, currentState, start, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p2, relative, lastControl) && 8...11 ~= currentState {
                if currentState == 9 {
                    str = getPathDataString(nil, p2.x - relative.x, p2.y - relative.y)
                } else {
                    str = getPathDataString("t", p2.x - relative.x, p2.y - relative.y)
                }
                currentState = 9
            } else {
                if currentState == 11 {
                    str = getPathDataString(nil, p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y)
                } else {
                    str = getPathDataString("q", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y)
                }
                currentState = 11
            }
            return (str, currentState, start, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p3, relative, lastControl) && 12...15 ~= currentState {
                if currentState == 13 {
                    str = getPathDataString(nil, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                } else {
                    str = getPathDataString("s", p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                }
                currentState = 13
            } else {
                if currentState == 15 {
                    str = getPathDataString(nil, p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                } else {
                    str = getPathDataString("c", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                }
                currentState = 15
            }
            return (str, currentState, start, p3, p2)
        default: fatalError()
        }
    }
}
