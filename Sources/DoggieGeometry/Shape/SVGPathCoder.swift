//
//  SVGPathCoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

private struct PathDataScanner<I: IteratorProtocol>: IteratorProtocol, Sequence where I.Element == String {
    
    var iterator: I
    var current: String!
    
    @inlinable
    @inline(__always)
    init(_ iterator: I) {
        self.iterator = iterator
    }
    
    @inlinable
    @inline(__always)
    init<S : Sequence>(_ sequence: S) where S.Iterator == I {
        self.iterator = sequence.makeIterator()
    }
    
    @inlinable
    @inline(__always)
    @discardableResult
    mutating func next() -> String? {
        current = iterator.next()
        return current
    }
}

private let pathDataMatcher: Regex = "[MmLlHhVvCcSsQqTtAaZz]|[+-]?\\d*\\.?\\d+([eE][+-]?\\d+)?"

extension Shape {
    
    @frozen
    public struct ParserError: Error {
        
        var command: String?
    }
    
    @inline(__always)
    private func toDouble(_ str: String?) throws -> Double {
        
        if str != nil, let val = Double(str!) {
            return val
        }
        throw ParserError(command: str)
    }
    
    @inline(__always)
    private func toInt(_ str: String?) throws -> Int {
        
        if str != nil, let val = Int(str!) {
            return val
        }
        throw ParserError(command: str)
    }
    
    public init(code: String) throws {
        self.init()
        
        var g = PathDataScanner(code.match(regex: pathDataMatcher))
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
                    if !component.isEmpty {
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
                    if !component.isEmpty {
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
                    let p1 = lastbezier == 1 ? 2 * relative - lastcontrol : relative
                    let p2 = Point(x: try toDouble(g.current), y: try toDouble(g.next()))
                    relative = p2
                    lastcontrol = p1
                    lastbezier = 1
                    component.append(.quad(p1, p2))
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "t":
                repeat {
                    let p1 = lastbezier == 1 ? 2 * relative - lastcontrol : relative
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
                        default: throw ParserError(command: val)
                        }
                    } else {
                        throw ParserError(command: nil)
                    }
                    let x = try toDouble(g.next())
                    let y = try toDouble(g.next())
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    component.arc(to: Point(x: x, y: y), radius: Radius(x: rx, y: ry), rotate: .pi * rotate / 180, largeArc: largeArc, sweep: sweep)
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
                        default: throw ParserError(command: val)
                        }
                    } else {
                        throw ParserError(command: nil)
                    }
                    let x = try toDouble(g.next()) + relative.x
                    let y = try toDouble(g.next()) + relative.y
                    relative = Point(x: x, y: y)
                    lastcontrol = Point(x: x, y: y)
                    lastbezier = 0
                    component.arc(to: Point(x: x, y: y), radius: Radius(x: rx, y: ry), rotate: .pi * rotate / 180, largeArc: largeArc, sweep: sweep)
                } while g.next() != nil && !commandsymbol.contains(g.current.utf8.first!)
            case "Z", "z":
                if !component.isEmpty {
                    component.isClosed = true
                    self.append(component)
                    component.removeAll(keepingCapacity: true)
                    component.isClosed = false
                    relative = component.start
                    lastcontrol = component.start
                    lastbezier = 0
                }
            default:
                throw ParserError(command: command)
            }
        }
        
        if !component.isEmpty {
            self.append(component)
        }
        
        self.makeContiguousBuffer()
    }
}

@inline(__always)
private func getDataString(_ x: [Double]) -> String {
    var str = ""
    for _x in x.map({ "\(Decimal($0).rounded(scale: 9))" }) {
        if !str.isEmpty && _x.first != "-" {
            str.append(" ")
        }
        _x.write(to: &str)
    }
    return str
}

@inline(__always)
private func getPathDataString(_ command: Character?, _ x: Double ...) -> String {
    var result = ""
    command?.write(to: &result)
    let dataStr = getDataString(x)
    if result.isEmpty && !dataStr.isEmpty && dataStr.first != "-" {
        result.append(" ")
    }
    dataStr.write(to: &result)
    return result
}

extension Shape {
    
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

extension Shape.Component {
    
    fileprivate func serialize(_ currentState: inout Int, start: inout Point, relative: inout Point, lastControl: inout Point?, _ data: inout String) {
        
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
            let _serialize1 = item.serialize1(currentState, relative, lastControl)
            let _serialize2 = item.serialize2(currentState, relative, lastControl)
            if _serialize1.0.count <= _serialize2.0.count {
                _serialize1.0.write(to: &data)
                currentState = _serialize1.1
                relative = _serialize1.2
                lastControl = _serialize1.3
            } else {
                _serialize2.0.write(to: &data)
                currentState = _serialize2.1
                relative = _serialize2.2
                lastControl = _serialize2.3
            }
        }
        
        if self.isClosed {
            data.append("z")
            relative = self.start
        }
    }
    
}

extension Shape.Segment {
    
    @inline(__always)
    fileprivate func isSmooth(_ p: Point, _ relative: Point, _ lastControl: Point?) -> Bool {
        
        if let lastControl = lastControl {
            let d = p + lastControl - 2 * relative
            return Decimal(d.x).rounded(scale: 9) == 0 && Decimal(d.y).rounded(scale: 9) == 0
        }
        return false
    }
    
    fileprivate func serialize1(_ currentState: Int, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point?) {
        
        switch self {
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if Decimal(relative.x).rounded(scale: 9) == Decimal(point.x).rounded(scale: 9) {
                str = getPathDataString(currentState == 1 ? nil : "V", point.y)
                currentState = 1
            } else if Decimal(relative.y).rounded(scale: 9) == Decimal(point.y).rounded(scale: 9) {
                str = getPathDataString(currentState == 3 ? nil : "H", point.x)
                currentState = 3
            } else {
                str = getPathDataString(currentState == 5 ? nil : "L", point.x, point.y)
                currentState = 5
            }
            return (str, currentState, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p1, relative, lastControl) && 7...10 ~= currentState {
                str = getPathDataString(currentState == 7 ? nil : "T", p2.x, p2.y)
                currentState = 7
            } else {
                str = getPathDataString(currentState == 9 ? nil : "Q", p1.x, p1.y, p2.x, p2.y)
                currentState = 9
            }
            return (str, currentState, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p1, relative, lastControl) && 11...14 ~= currentState {
                str = getPathDataString(currentState == 11 ? nil : "S", p2.x, p2.y, p3.x, p3.y)
                currentState = 11
            } else {
                str = getPathDataString(currentState == 13 ? nil : "C", p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
                currentState = 13
            }
            return (str, currentState, p3, p2)
        }
    }
    
    fileprivate func serialize2(_ currentState: Int, _ relative: Point, _ lastControl: Point?) -> (String, Int, Point, Point?) {
        
        switch self {
        case let .line(point):
            
            var currentState = currentState
            let str: String
            if Decimal(relative.x).rounded(scale: 9) == Decimal(point.x).rounded(scale: 9) {
                str = getPathDataString(currentState == 2 ? nil : "v", point.y - relative.y)
                currentState = 2
            } else if Decimal(relative.y).rounded(scale: 9) == Decimal(point.y).rounded(scale: 9) {
                str = getPathDataString(currentState == 4 ? nil : "h", point.x - relative.x)
                currentState = 4
            } else {
                str = getPathDataString(currentState == 6 ? nil : "l", point.x - relative.x, point.y - relative.y)
                currentState = 6
            }
            return (str, currentState, point, nil)
        case let .quad(p1, p2):
            
            var currentState = currentState
            let str: String
            if isSmooth(p1, relative, lastControl) && 7...10 ~= currentState {
                str = getPathDataString(currentState == 8 ? nil : "t", p2.x - relative.x, p2.y - relative.y)
                currentState = 8
            } else {
                str = getPathDataString(currentState == 10 ? nil : "q", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y)
                currentState = 10
            }
            return (str, currentState, p2, p1)
        case let .cubic(p1, p2, p3):
            
            var currentState = currentState
            let str: String
            if isSmooth(p1, relative, lastControl) && 11...14 ~= currentState {
                str = getPathDataString(currentState == 12 ? nil : "s", p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                currentState = 12
            } else {
                str = getPathDataString(currentState == 14 ? nil : "c", p1.x - relative.x, p1.y - relative.y, p2.x - relative.x, p2.y - relative.y, p3.x - relative.x, p3.y - relative.y)
                currentState = 14
            }
            return (str, currentState, p3, p2)
        }
    }
}
