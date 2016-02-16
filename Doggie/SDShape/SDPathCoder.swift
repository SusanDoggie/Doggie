//
//  SDPathCoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

private struct PathDataScanner<G : GeneratorType where G.Element == String> : GeneratorType {
    
    var generator: G
    var current: String!
    
    init(_ generator: G) {
        self.generator = generator
    }
    
    init<S : SequenceType where S.Generator == G>(_ sequence: S) {
        self.generator = sequence.generate()
    }
    
    mutating func next() -> String? {
        current = generator.next()
        return current
    }
}

private let pathDataMatcher: Regex = "[MmLlHhVvCcSsQqTtAaZz]|[+-]?(\\d+\\.?\\d*|\\.\\d+)([eE][+-]?\\d+)?"

extension SDPath {
    
    public struct DecoderError : ErrorType {
        
        var command: String?
    }
    
    private func toDouble(str: String?) throws -> Double {
        
        if str != nil, let val = Double(str!) {
            return val
        }
        throw DecoderError(command: str)
    }
    
    private func toInt(str: String?) throws -> Int {
        
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
        
        let commandsymbol = "MmLlHhVvCcSsQqTtAaZz".utf8.array
        
        g.next()
        while let command = g.current {
            g.next()
            switch command {
            case "M":
                repeat {
                    let move = SDPath.Move(x: try toDouble(g.current), y: try toDouble(g.next()))
                    start = move.point
                    relative = move.point
                    lastcontrol = move.point
                    lastbezier = 0
                    self.append(move)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "m":
                repeat {
                    let move = SDPath.Move(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    start = move.point
                    relative = move.point
                    lastcontrol = move.point
                    lastbezier = 0
                    self.append(move)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "L":
                repeat {
                    let line = SDPath.Line(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "l":
                repeat {
                    let line = SDPath.Line(x: try toDouble(g.current) + relative.x, y: try toDouble(g.next()) + relative.y)
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "H":
                repeat {
                    let line = SDPath.Line(x: try toDouble(g.current), y: relative.y)
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "h":
                repeat {
                    let line = SDPath.Line(x: try toDouble(g.current) + relative.x, y: relative.y)
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "V":
                repeat {
                    let line = SDPath.Line(x: relative.x, y: try toDouble(g.current))
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "v":
                repeat {
                    let line = SDPath.Line(x: relative.x, y: try toDouble(g.current) + relative.y)
                    relative = line.point
                    lastcontrol = line.point
                    lastbezier = 0
                    self.append(line)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "C":
                repeat {
                    let bezier = SDPath.CubicBezier(
                        x1: try toDouble(g.current), y1: try toDouble(g.next()),
                        x2: try toDouble(g.next()), y2: try toDouble(g.next()),
                        x3: try toDouble(g.next()), y3: try toDouble(g.next()))
                    relative = bezier.p3
                    lastcontrol = bezier.p2
                    lastbezier = 2
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "c":
                repeat {
                    let bezier = SDPath.CubicBezier(
                        x1: try toDouble(g.current) + relative.x, y1: try toDouble(g.next()) + relative.y,
                        x2: try toDouble(g.next()) + relative.x, y2: try toDouble(g.next()) + relative.y,
                        x3: try toDouble(g.next()) + relative.x, y3: try toDouble(g.next()) + relative.y)
                    relative = bezier.p3
                    lastcontrol = bezier.p2
                    lastbezier = 2
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "S":
                repeat {
                    let bezier: SDPath.CubicBezier
                    if lastbezier == 2 {
                        let p1 = 2 * relative - lastcontrol
                        bezier = SDPath.CubicBezier(
                            x1: p1.x, y1: p1.y,
                            x2: try toDouble(g.current), y2: try toDouble(g.next()),
                            x3: try toDouble(g.next()), y3: try toDouble(g.next()))
                    } else {
                        bezier = SDPath.CubicBezier(
                            x1: relative.x, y1: relative.y,
                            x2: try toDouble(g.current), y2: try toDouble(g.next()),
                            x3: try toDouble(g.next()), y3: try toDouble(g.next()))
                    }
                    relative = bezier.p3
                    lastcontrol = bezier.p2
                    lastbezier = 2
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "s":
                repeat {
                    let bezier: SDPath.CubicBezier
                    if lastbezier == 2 {
                        let p1 = 2 * relative - lastcontrol
                        bezier = SDPath.CubicBezier(
                            x1: p1.x, y1: p1.y,
                            x2: try toDouble(g.current) + relative.x, y2: try toDouble(g.next()) + relative.y,
                            x3: try toDouble(g.next()) + relative.x, y3: try toDouble(g.next()) + relative.y)
                    } else {
                        bezier = SDPath.CubicBezier(
                            x1: relative.x, y1: relative.y,
                            x2: try toDouble(g.current) + relative.x, y2: try toDouble(g.next()) + relative.y,
                            x3: try toDouble(g.next()) + relative.x, y3: try toDouble(g.next()) + relative.y)
                    }
                    relative = bezier.p3
                    lastcontrol = bezier.p2
                    lastbezier = 2
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Q":
                repeat {
                    let bezier = SDPath.QuadBezier(
                        x1: try toDouble(g.current), y1: try toDouble(g.next()),
                        x2: try toDouble(g.next()), y2: try toDouble(g.next()))
                    relative = bezier.p2
                    lastcontrol = bezier.p1
                    lastbezier = 1
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "q":
                repeat {
                    let bezier = SDPath.QuadBezier(
                        x1: try toDouble(g.current) + relative.x, y1: try toDouble(g.next()) + relative.y,
                        x2: try toDouble(g.next()) + relative.x, y2: try toDouble(g.next()) + relative.y)
                    relative = bezier.p2
                    lastcontrol = bezier.p1
                    lastbezier = 1
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "T":
                repeat {
                    let bezier: SDPath.QuadBezier
                    if lastbezier == 1 {
                        let p1 = 2 * relative - lastcontrol
                        bezier = SDPath.QuadBezier(x1: p1.x, y1: p1.y, x2: try toDouble(g.current), y2: try toDouble(g.next()))
                    } else {
                        bezier = SDPath.QuadBezier(x1: relative.x, y1: relative.y, x2: try toDouble(g.current), y2: try toDouble(g.next()))
                    }
                    relative = bezier.p2
                    lastcontrol = bezier.p1
                    lastbezier = 1
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "t":
                repeat {
                    let bezier: SDPath.QuadBezier
                    if lastbezier == 1 {
                        let p1 = 2 * relative - lastcontrol
                        bezier = SDPath.QuadBezier(x1: p1.x, y1: p1.y, x2: try toDouble(g.current) + relative.x, y2: try toDouble(g.next()) + relative.y)
                    } else {
                        bezier = SDPath.QuadBezier(x1: relative.x, y1: relative.y, x2: try toDouble(g.current) + relative.x, y2: try toDouble(g.next()) + relative.y)
                    }
                    relative = bezier.p2
                    lastcontrol = bezier.p1
                    lastbezier = 1
                    self.append(bezier)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "A":
                repeat {
                    let rx = try toDouble(g.current)
                    let ry = try toDouble(g.next())
                    let rotate = try toDouble(g.next())
                    let largeArc = try toInt(g.next()) != 0
                    let sweep = try toInt(g.next()) != 0
                    let x = try toDouble(g.next())
                    let y = try toDouble(g.next())
                    let arc = bezierArc(relative, Point(x: x, y: y), Radius(x: rx, y: ry), M_PI * rotate / 180, largeArc, sweep)
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    self.appendContentsOf(arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "a":
                repeat {
                    let rx = try toDouble(g.current)
                    let ry = try toDouble(g.next())
                    let rotate = try toDouble(g.next())
                    let largeArc = try toInt(g.next()) != 0
                    let sweep = try toInt(g.next()) != 0
                    let x = try toDouble(g.next()) + relative.x
                    let y = try toDouble(g.next()) + relative.y
                    let arc = bezierArc(relative, Point(x: x, y: y), Radius(x: rx, y: ry), M_PI * rotate / 180, largeArc, sweep)
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    self.appendContentsOf(arc)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Z", "z":
                let close = SDPath.ClosePath()
                relative = start
                lastcontrol = start
                lastbezier = 0
                self.append(close)
            default:
                throw DecoderError(command: command)
            }
        }
    }
}

private func arcDetails(start: Point, _ end: Point, _ radius: Radius, _ rotate: Double, _ largeArc: Bool, _ sweep: Bool) -> (Point, Radius) {
    let centers = EllipseCenter(radius, rotate, start, end)
    if centers.count == 0 {
        return (middle(end, start), EllipseRadius(start, end, radius, rotate))
    } else if centers.count == 1 || (!direction(start, centers[0], end).isSignMinus == sweep ? largeArc : !largeArc) {
        return (centers[0], radius)
    } else {
        return (centers[1], radius)
    }
}
private func bezierArc(start: Point, _ end: Point, _ radius: Radius, _ rotate: Double, _ largeArc: Bool, _ sweep: Bool) -> [SDPathCommand] {
    let (center, radius) = arcDetails(start, end, radius, rotate, largeArc, sweep)
    let _arc_transform = SDTransform.Rotate(rotate) * SDTransform.Scale(x: radius.x, y: radius.y)
    let _arc_transform_inverse = _arc_transform.inverse
    let _begin = _arc_transform_inverse * (start - center)
    let _end = _arc_transform_inverse * (end - center)
    let startAngle = atan2(_begin.y, _begin.x)
    var endAngle = atan2(_end.y, _end.x)
    if sweep {
        while endAngle < startAngle {
            endAngle += 2 * M_PI
        }
    } else {
        while endAngle > startAngle {
            endAngle -= 2 * M_PI
        }
    }
    let _transform = _arc_transform * SDTransform.Rotate(startAngle)
    let point = BezierArc(endAngle - startAngle).lazy.map { _transform * $0 + center }
    var result: [SDPathCommand] = []
    if point.count > 1 {
        for i in 0..<point.count / 3 {
            result.append(SDPath.CubicBezier(point[i * 3 + 1], point[i * 3 + 2], point[i * 3 + 3]))
        }
    }
    return result
}

private let dataFormatter: NSNumberFormatter = {
    let formatter = NSNumberFormatter()
    formatter.negativeFormat = "#.#########"
    formatter.positiveFormat = "#.#########"
    return formatter
    }()

private func getDataString(x: [Double]) -> String {
    var str = ""
    for _x in x.map({ dataFormatter.stringFromNumber($0) ?? "0" }) {
        if !str.isEmpty && _x.characters.first != "-" {
            " ".writeTo(&str)
        }
        _x.writeTo(&str)
    }
    return str
}

private func _round(x: Double) -> Double {
    return round(x * 1000000000) / 1000000000
}

private func getPathDataString(command: Character?, _ x: Double ...) -> String {
    var result = ""
    command?.writeTo(&result)
    let dataStr = getDataString(x)
    if result.isEmpty && !dataStr.isEmpty && dataStr.characters.first != "-" {
        " ".writeTo(&result)
    }
    dataStr.writeTo(&result)
    return result
}

public extension SDPath {
    
    @warn_unused_result
    public func encode() -> String {
        
        var data = ""
        var currentState = -1
        var start = Point()
        var relative = Point()
        var lastControl: Point?
        for item in self {
            (item as? SDPathCommandSerializableType)?.serialize(&currentState, start: &start, relative: &relative, lastControl: &lastControl).writeTo(&data)
        }
        return data
    }
}

private protocol SDPathCommandSerializableType {
    
    func serialize(inout currentState: Int, inout start: Point, inout relative: Point, inout lastControl: Point?) -> String
}

private protocol SDPathCommandSerializableShortFormType : SDPathCommandSerializableType {
    
    func serialize1(currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?)
    func serialize2(currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?)
    
}

extension SDPathCommandSerializableShortFormType {
    
    func serialize(inout currentState: Int, inout start: Point, inout relative: Point, inout lastControl: Point?) -> String {
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
}

extension SDPath.Move : SDPathCommandSerializableShortFormType {
    
    private func serialize1(_: Int, _: Point, _: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        return (getPathDataString("M", self.x, self.y), 0, self.point, self.point, nil)
    }
    private func serialize2(_: Int, _: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        return (getPathDataString("m", self.x - relative.x, self.y - relative.y), 1, self.point, self.point, nil)
    }
}

extension SDPath.Line : SDPathCommandSerializableShortFormType {
    
    private func serialize1(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if _round(relative.x) == _round(self.x) {
            if currentState == 2 {
                str = getPathDataString(nil, self.y)
            } else {
                str = getPathDataString("V", self.y)
            }
            currentState = 2
        } else if _round(relative.y) == _round(self.y) {
            if currentState == 4 {
                str = getPathDataString(nil, self.x)
            } else {
                str = getPathDataString("H", self.x)
            }
            currentState = 4
        } else {
            if currentState == 6 {
                str = getPathDataString(nil, self.x, self.y)
            } else {
                str = getPathDataString("L", self.x, self.y)
            }
            currentState = 6
        }
        return (str, currentState, start, self.point, nil)
    }
    private func serialize2(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if _round(relative.x) == _round(self.x) {
            if currentState == 3 {
                str = getPathDataString(nil, self.y - relative.y)
            } else {
                str = getPathDataString("v", self.y - relative.y)
            }
            currentState = 3
        } else if _round(relative.y) == _round(self.y) {
            if currentState == 5 {
                str = getPathDataString(nil, self.x - relative.x)
            } else {
                str = getPathDataString("h", self.x - relative.x)
            }
            currentState = 5
        } else {
            if currentState == 7 {
                str = getPathDataString(nil, self.x - relative.x, self.y - relative.y)
            } else {
                str = getPathDataString("l", self.x - relative.x, self.y - relative.y)
            }
            currentState = 7
        }
        return (str, currentState, start, self.point, nil)
    }
}

extension SDPath.QuadBezier : SDPathCommandSerializableShortFormType {
    
    private func isSmooth(relative: Point, _ lastControl: Point?) -> Bool {
        
        if let lastControl = lastControl {
            let d = self.p1 + lastControl - 2 * relative
            return _round(d.x) == 0 && _round(d.y) == 0
        }
        return false
    }
    
    private func serialize1(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if self.isSmooth(relative, lastControl) && (8...11).contains(currentState) {
            if currentState == 8 {
                str = getPathDataString(nil, self.p2.x, self.p2.y)
            } else {
                str = getPathDataString("T", self.p2.x, self.p2.y)
            }
            currentState = 8
        } else {
            if currentState == 10 {
                str = getPathDataString(nil, self.p1.x, self.p1.y, self.p2.x, self.p2.y)
            } else {
                str = getPathDataString("Q", self.p1.x, self.p1.y, self.p2.x, self.p2.y)
            }
            currentState = 10
        }
        return (str, currentState, start, self.point, self.p1)
    }
    private func serialize2(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if self.isSmooth(relative, lastControl) && (8...11).contains(currentState) {
            if currentState == 9 {
                str = getPathDataString(nil, self.p2.x - relative.x, self.p2.y - relative.y)
            } else {
                str = getPathDataString("t", self.p2.x - relative.x, self.p2.y - relative.y)
            }
            currentState = 9
        } else {
            if currentState == 11 {
                str = getPathDataString(nil, self.p1.x - relative.x, self.p1.y - relative.y, self.p2.x - relative.x, self.p2.y - relative.y)
            } else {
                str = getPathDataString("q", self.p1.x - relative.x, self.p1.y - relative.y, self.p2.x - relative.x, self.p2.y - relative.y)
            }
            currentState = 11
        }
        return (str, currentState, start, self.point, self.p1)
    }
}

extension SDPath.CubicBezier : SDPathCommandSerializableShortFormType {
    
    private func isSmooth(relative: Point, _ lastControl: Point?) -> Bool {
        
        if let lastControl = lastControl {
            let d = self.p1 + lastControl - 2 * relative
            return _round(d.x) == 0 && _round(d.y) == 0
        }
        return false
    }
    
    private func serialize1(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if self.isSmooth(relative, lastControl) && (12...15).contains(currentState) {
            if currentState == 12 {
                str = getPathDataString(nil, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
            } else {
                str = getPathDataString("S", self.p2.x, self.p2.y, self.p3.x, self.p3.y)
            }
            currentState = 12
        } else {
            if currentState == 14 {
                str = getPathDataString(nil, self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
            } else {
                str = getPathDataString("C", self.p1.x, self.p1.y, self.p2.x, self.p2.y, self.p3.x, self.p3.y)
            }
            currentState = 14
        }
        return (str, currentState, start, self.point, self.p2)
    }
    private func serialize2(var currentState: Int, _ start: Point, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point, Point?) {
        let str: String
        if self.isSmooth(relative, lastControl) && (12...15).contains(currentState) {
            if currentState == 13 {
                str = getPathDataString(nil, self.p2.x - relative.x, self.p2.y - relative.y, self.p3.x - relative.x, self.p3.y - relative.y)
            } else {
                str = getPathDataString("s", self.p2.x - relative.x, self.p2.y - relative.y, self.p3.x - relative.x, self.p3.y - relative.y)
            }
            currentState = 13
        } else {
            if currentState == 15 {
                str = getPathDataString(nil, self.p1.x - relative.x, self.p1.y - relative.y, self.p2.x - relative.x, self.p2.y - relative.y, self.p3.x - relative.x, self.p3.y - relative.y)
            } else {
                str = getPathDataString("c", self.p1.x - relative.x, self.p1.y - relative.y, self.p2.x - relative.x, self.p2.y - relative.y, self.p3.x - relative.x, self.p3.y - relative.y)
            }
            currentState = 15
        }
        return (str, currentState, start, self.point, self.p2)
    }
}

extension SDPath.ClosePath : SDPathCommandSerializableType {
    
    private func serialize(inout currentState: Int, inout start: Point, inout relative: Point, inout lastControl: Point?) -> String {
        let str = currentState != 18 ? "z" : ""
        relative = start
        currentState = 18
        lastControl = nil
        return str
    }
}
