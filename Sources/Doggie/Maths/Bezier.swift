//
//  Bezier.swift
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

public protocol BezierElementProtocol {
    
    static prefix func + (_: Self) -> Self
    static prefix func - (_: Self) -> Self
    static func + (_: Self, _: Self) -> Self
    static func - (_: Self, _: Self) -> Self
    static func * (_: Double, _: Self) -> Self
    static func * (_: Self, _: Double) -> Self
    static func / (_: Self, _: Double) -> Self
    static func += (_: inout Self, _: Self)
    static func -= (_: inout Self, _: Self)
    static func *= (_: inout Self, _: Double)
    static func /= (_: inout Self, _: Double)
}

extension Double : BezierElementProtocol {
    
}
extension Point : BezierElementProtocol {
    
}
extension Vector : BezierElementProtocol {
    
}

@_versioned
@_fixed_layout
enum BezierBase<Element : BezierElementProtocol> {
    case _2(Element, Element)
    case _3(Element, Element, Element)
    case _4(Element, Element, Element, Element)
    case many([Element])
}

@_fixed_layout
public struct Bezier<Element : BezierElementProtocol> {
    
    @_versioned
    var base: BezierBase<Element>
    
    public init(_ p0: Element, _ p1: Element) {
        self.base = ._2(p0, p1)
    }
    public init(_ p0: Element, _ p1: Element, _ p2: Element) {
        self.base = ._3(p0, p1, p2)
    }
    public init(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element) {
        self.base = ._4(p0, p1, p2, p3)
    }
    public init(_ p0: Element, _ p1: Element, _ p2: Element, _ p3: Element, _ p4: Element, _ p: Element ... ) {
        self.base = .many([p0, p1, p2, p3, p4] + p)
    }
    public init<S : Sequence>(_ s: S) where S.Iterator.Element == Element {
        let s = Array(s)
        switch s.count {
        case 0, 1: fatalError("count of points less than 2.")
        case 2: self.base = ._2(s[0], s[1])
        case 3: self.base = ._3(s[0], s[1], s[2])
        case 4: self.base = ._4(s[0], s[1], s[2], s[3])
        default: self.base = .many(s)
        }
    }
}

extension Bezier : ExpressibleByArrayLiteral {
    
    @_inlineable
    public init(arrayLiteral elements: Element ... ) {
        self.init(elements)
    }
}

extension Bezier : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "\(points)"
    }
}

extension Bezier : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<Bezier>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    @_inlineable
    public var degree: Int {
        switch base {
        case ._2: return 1
        case ._3: return 2
        case ._4: return 3
        case let .many(p): return p.count - 1
        }
    }
    @_inlineable
    public var count: Int {
        switch base {
        case ._2: return 2
        case ._3: return 3
        case ._4: return 4
        case let .many(p): return p.count
        }
    }
    @_inlineable
    public var startIndex: Int {
        return 0
    }
    @_inlineable
    public var endIndex: Int {
        switch base {
        case ._2: return 2
        case ._3: return 3
        case ._4: return 4
        case let .many(p): return p.count
        }
    }
    
    public subscript(position: Int) -> Element {
        get {
            switch base {
            case let ._2(p0, p1):
                switch position {
                case 0: return p0
                case 1: return p1
                default: fatalError("out of index.")
                }
            case let ._3(p0, p1, p2):
                switch position {
                case 0: return p0
                case 1: return p1
                case 2: return p2
                default: fatalError("out of index.")
                }
            case let ._4(p0, p1, p2, p3):
                switch position {
                case 0: return p0
                case 1: return p1
                case 2: return p2
                case 3: return p3
                default: fatalError("out of index.")
                }
            case let .many(p): return p[position]
            }
        }
        set {
            switch base {
            case let ._2(p0, p1):
                switch position {
                case 0: base = ._2(newValue, p1)
                case 1: base = ._2(p0, newValue)
                default: fatalError("out of index.")
                }
            case let ._3(p0, p1, p2):
                switch position {
                case 0: base = ._3(newValue, p1, p2)
                case 1: base = ._3(p0, newValue, p2)
                case 2: base = ._3(p0, p1, newValue)
                default: fatalError("out of index.")
                }
            case let ._4(p0, p1, p2, p3):
                switch position {
                case 0: base = ._4(newValue, p1, p2, p3)
                case 1: base = ._4(p0, newValue, p2, p3)
                case 2: base = ._4(p0, p1, newValue, p3)
                case 3: base = ._4(p0, p1, p2, newValue)
                default: fatalError("out of index.")
                }
            case var .many(p):
                p[position] = newValue
                base = .many(p)
            }
        }
    }
}

extension Bezier {
    
    @_inlineable
    public var points: [Element] {
        switch base {
        case let ._2(p0, p1): return [p0, p1]
        case let ._3(p0, p1, p2): return [p0, p1, p2]
        case let ._4(p0, p1, p2, p3): return [p0, p1, p2, p3]
        case let .many(p): return p
        }
    }
}

extension Bezier {
    
    @_inlineable
    public func eval(_ t: Double) -> Element {
        switch base {
        case let ._2(p0, p1): return p0 + t * (p1 - p0)
        case let ._3(p0, p1, p2):
            let _t = 1 - t
            let a = _t * _t * p0
            let b = 2 * _t * t * p1
            let c = t * t * p2
            return a + b + c
        case let ._4(p0, p1, p2, p3):
            let t2 = t * t
            let _t = 1 - t
            let _t2 = _t * _t
            let a = _t * _t2 * p0
            let b = 3 * _t2 * t * p1
            let c = 3 * _t * t2 * p2
            let d = t * t2 * p3
            return a + b + c + d
        case let .many(points):
            var result: Element?
            let _n = points.count - 1
            for (idx, k) in CombinationList(UInt(_n)).enumerated() {
                let b = Double(k) * pow(t, Double(idx)) * pow(1 - t, Double(_n - idx))
                if result == nil {
                    result = b * points[idx]
                } else {
                    result! += b * points[idx]
                }
            }
            return result!
        }
    }
    
}

extension Bezier where Element == Double {
    
    @_inlineable
    public var polynomial: Polynomial {
        switch base {
        case let ._2(p0, p1):
            let a = p0
            let b = p1 - p0
            return [a, b]
        case let ._3(p0, p1, p2):
            let a = p0
            let b = 2 * (p1 - p0)
            let c = p0 + p2 - 2 * p1
            return [a, b, c]
        case let ._4(p0, p1, p2, p3):
            let a = p0
            let b = 3 * (p1 - p0)
            let c = 3 * (p2 + p0) - 6 * p1
            let d = p3 - p0 + 3 * (p1 - p2)
            return [a, b, c, d]
        case let .many(points):
            var result = PermutationList(UInt(points.count - 1)).map(Double.init) as Array
            for i in result.indices {
                var sum = 0.0
                let fact = Array(FactorialList(UInt(i)))
                for (j, f) in zip(fact, fact.reversed()).map(*).enumerated() {
                    if (i + j) & 1 == 0 {
                        sum += points[j] / Double(f)
                    } else {
                        sum -= points[j] / Double(f)
                    }
                }
                result[i] *= sum
            }
            return Polynomial(result)
        }
    }
    
    @_inlineable
    public init(_ polynomial: Polynomial) {
        let de = (0..<Swift.max(1, polynomial.degree)).scan(polynomial) { p, _ in p.derivative / Double(p.degree) }
        var points: [Double] = []
        for n in de.indices {
            let s = zip(CombinationList(UInt(n)), de)
            points.append(s.reduce(0) { $0 + Double($1.0) * $1.1[0] })
        }
        self.init(points)
    }
}

extension Bezier {
    
    @_inlineable
    public func elevated() -> Bezier {
        let p = self.points
        let n = Double(p.count)
        var result = [p[0]]
        for (k, points) in zip(p, p.dropFirst()).enumerated() {
            let t = Double(k + 1) / n
            result.append(t * points.0 + (1 - t) * points.1)
        }
        result.append(p.last!)
        return Bezier(result)
    }
}

extension Bezier {
    
    @_versioned
    static func split(_ t: Double, _ p: [Element]) -> ([Element], [Element]) {
        let _t = 1 - t
        if p.count == 2 {
            let split = _t * p.first! + t * p.last!
            return ([p.first!, split], [split, p.last!])
        }
        var subpath = [Element]()
        var lastPoint = p.first!
        for current in p.dropFirst() {
            subpath.append(_t * lastPoint + t * current)
            lastPoint = current
        }
        let _split = split(t, subpath)
        return ([p.first!] + _split.0, _split.1 + [p.last!])
    }
    @_inlineable
    public func split(_ t: Double) -> (Bezier, Bezier) {
        let points = self.points
        if t.almostZero() {
            return (Bezier(repeatElement(points.first!, count: points.count)), self)
        }
        if t.almostEqual(1) {
            return (self, Bezier(repeatElement(points.last!, count: points.count)))
        }
        let split = Bezier.split(t, points)
        return (Bezier(split.0), Bezier(split.1))
    }
    
    @_inlineable
    public func split(_ t: [Double]) -> [Bezier] {
        var result: [Bezier] = []
        var remain = self
        var last_t = 0.0
        for _t in t.sorted() {
            let split = remain.split((_t - last_t) / (1 - last_t))
            result.append(split.0)
            remain = split.1
            last_t = _t
        }
        result.append(remain)
        return result
    }
}

extension Bezier {
    
    @_inlineable
    public func derivative() -> Bezier {
        let p = self.points
        let n = Double(p.count - 1)
        var de = [Element]()
        var lastPoint = p.first!
        for current in p.dropFirst() {
            de.append(n * (current - lastPoint))
            lastPoint = current
        }
        return Bezier(de)
    }
}

extension Bezier where Element == Point {
    
    @_inlineable
    public func closest(_ point: Point) -> [Double] {
        switch base {
        case let ._2(p0, p1):
            let a = p0 - point
            let b = p1 - p0
            let x: Polynomial = [a.x, b.x]
            let y: Polynomial = [a.y, b.y]
            let dot = x * x + y * y
            return dot.derivative.roots.sorted(by: { dot.eval($0) })
        case let ._3(p0, p1, p2):
            let a = p0 - point
            let b = 2 * (p1 - p0)
            let c = p0 + p2 - 2 * p1
            let x: Polynomial = [a.x, b.x, c.x]
            let y: Polynomial = [a.y, b.y, c.y]
            let dot = x * x + y * y
            return dot.derivative.roots.sorted(by: { dot.eval($0) })
        case let ._4(p0, p1, p2, p3):
            let a = p0 - point
            let b = 3 * (p1 - p0)
            let c = 3 * (p2 + p0) - 6 * p1
            let d = p3 - p0 + 3 * (p1 - p2)
            let x: Polynomial = [a.x, b.x, c.x, d.x]
            let y: Polynomial = [a.y, b.y, c.y, d.y]
            let dot = x * x + y * y
            return dot.derivative.roots.sorted(by: { dot.eval($0) })
        case let .many(points):
            let x = Bezier<Double>(points.map { $0.x }).polynomial - point.x
            let y = Bezier<Double>(points.map { $0.y }).polynomial - point.y
            let dot = x * x + y * y
            return dot.derivative.roots.sorted(by: { dot.eval($0) })
        }
    }
}

extension Bezier where Element == Point {
    
    @_inlineable
    public var area: Double {
        switch base {
        case let ._2(p0, p1): return 0.5 * (p0.x * p1.y - p0.y * p1.x)
        case let ._3(p0, p1, p2):
            let a = p0.x - 2 * p1.x + p2.x
            let b = 2 * (p1.x - p0.x)
            
            let c = p0.y - 2 * p1.y + p2.y
            let d = 2 * (p1.y - p0.y)
            
            return 0.5 * (p0.x * p2.y - p2.x * p0.y) + (b * c - a * d) / 6
        case let ._4(p0, p1, p2, p3):
            let a = p3.x - p0.x + 3 * (p1.x - p2.x)
            let b = 3 * (p2.x + p0.x) - 6 * p1.x
            let c = 3 * (p1.x - p0.x)
            
            let d = p3.y - p0.y + 3 * (p1.y - p2.y)
            let e = 3 * (p2.y + p0.y) - 6 * p1.y
            let f = 3 * (p1.y - p0.y)
            
            return 0.5 * (p0.x * p3.y - p3.x * p0.y) + 0.1 * (b * d - a * e) + 0.25 * (c * d - a * f) + (c * e - b * f) / 6
        case let .many(points):
            let x = Bezier<Double>(points.map { $0.x }).polynomial
            let y = Bezier<Double>(points.map { $0.y }).polynomial
            let t = x * y.derivative - x.derivative * y
            return 0.5 * t.integral.eval(1)
        }
    }
}

extension Bezier where Element == Point {
    
    @_inlineable
    public var inflection: [Double] {
        switch base {
        case ._2, ._3: return []
        case let ._4(p0, p1, p2, p3):
            let p = (p3 - p0).phase
            let _p1 = (p1 - p0) * SDTransform.Rotate(-p)
            let _p2 = (p2 - p0) * SDTransform.Rotate(-p)
            let _p3 = (p3 - p0) * SDTransform.Rotate(-p)
            let a = _p2.x * _p1.y
            let b = _p3.x * _p1.y
            let c = _p1.x * _p2.y
            let d = _p3.x * _p2.y
            let x = 18 * (2 * b + 3 * (c - a) - d)
            let y = 18 * (3 * (a - c) - b)
            let z = 18 * (c - a)
            if x.almostZero() {
                return y.almostZero() ? [] : [-z / y]
            }
            return degree2roots(y / x, z / x)
        case let .many(points):
            let x = Bezier<Double>(points.map { $0.x }).polynomial.derivative
            let y = Bezier<Double>(points.map { $0.y }).polynomial.derivative
            return (x * y.derivative - y * x.derivative).roots
        }
    }
}

extension Bezier where Element == Double {
    
    @_inlineable
    public var stationary: [Double] {
        switch base {
        case ._2: return []
        case let ._3(p0, p1, p2):
            let d = p0 + p2 - 2 * p1
            if d.almostZero() {
                return []
            }
            return [(p0 - p1) / d]
        case let ._4(p0, p1, p2, p3):
            let _a = 3 * (p3 - p0) + 9 * (p1 - p2)
            let _b = 6 * (p2 + p0) - 12 * p1
            let _c = 3 * (p1 - p0)
            if _a.almostZero() {
                if _b.almostZero() {
                    return []
                }
                let t = -_c / _b
                return [t]
            } else {
                let delta = _b * _b - 4 * _a * _c
                let _a2 = 2 * _a
                let _b2 = -_b / _a2
                if delta.sign == .plus {
                    let sqrt_delta = sqrt(delta) / _a2
                    let t1 = _b2 + sqrt_delta
                    let t2 = _b2 - sqrt_delta
                    return [t1, t2]
                } else if delta.almostZero() {
                    return [_b2]
                }
            }
            return []
        default: return polynomial.derivative.roots
        }
    }
}

extension Bezier where Element == Point {
    
    @_inlineable
    public var stationary: [Double] {
        let bx = Bezier<Double>(points.map { $0.x }).stationary.lazy.map { $0.clamped(to: 0...1) }
        let by = Bezier<Double>(points.map { $0.y }).stationary.lazy.map { $0.clamped(to: 0...1) }
        return [0.0, 1.0] + bx + by
    }
    
    @_inlineable
    public var boundary: Rect {
        let points = self.points
        
        let bx = Bezier<Double>(points.map { $0.x })
        let by = Bezier<Double>(points.map { $0.y })
        
        let tx = [0.0, 1.0] + bx.stationary.lazy.map { $0.clamped(to: 0...1) }
        let ty = [0.0, 1.0] + by.stationary.lazy.map { $0.clamped(to: 0...1) }
        
        let _x = tx.map { bx.eval($0) }
        let _y = ty.map { by.eval($0) }
        
        let minX = _x.min()!
        let minY = _y.min()!
        let maxX = _x.max()!
        let maxY = _y.max()!
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

@_inlineable
public prefix func + <Element>(x: Bezier<Element>) -> Bezier<Element> {
    return x
}
@_inlineable
public prefix func - <Element>(x: Bezier<Element>) -> Bezier<Element> {
    return Bezier(x.points.map { -$0 })
}
@_inlineable
public func + <Element>(lhs: Bezier<Element>, rhs: Bezier<Element>) -> Bezier<Element> {
    var lhs = lhs
    var rhs = rhs
    let degree = max(lhs.degree, rhs.degree)
    while lhs.degree != degree {
        lhs = lhs.elevated()
    }
    while rhs.degree != degree {
        rhs = rhs.elevated()
    }
    return Bezier(zip(lhs.points, rhs.points).map(+))
}
@_inlineable
public func - <Element>(lhs: Bezier<Element>, rhs: Bezier<Element>) -> Bezier<Element> {
    var lhs = lhs
    var rhs = rhs
    let degree = max(lhs.degree, rhs.degree)
    while lhs.degree != degree {
        lhs = lhs.elevated()
    }
    while rhs.degree != degree {
        rhs = rhs.elevated()
    }
    return Bezier(zip(lhs.points, rhs.points).map(-))
}
@_inlineable
public func * <Element>(lhs: Double, rhs: Bezier<Element>) -> Bezier<Element> {
    return Bezier(rhs.points.map { lhs * $0 })
}
@_inlineable
public func * <Element>(lhs: Bezier<Element>, rhs: Double) -> Bezier<Element> {
    return Bezier(lhs.points.map { $0 * rhs })
}
@_inlineable
public func / <Element>(lhs: Bezier<Element>, rhs: Double) -> Bezier<Element> {
    return Bezier(lhs.points.map { $0 / rhs })
}
@_inlineable
public func += <Element>(lhs: inout Bezier<Element>, rhs: Bezier<Element>) {
    lhs = lhs + rhs
}
@_inlineable
public func -= <Element>(lhs: inout Bezier<Element>, rhs: Bezier<Element>) {
    lhs = lhs - rhs
}
@_inlineable
public func *= <Element>(lhs: inout Bezier<Element>, rhs: Double) {
    lhs = lhs * rhs
}
@_inlineable
public func /= <Element>(lhs: inout Bezier<Element>, rhs: Double) {
    lhs = lhs / rhs
}

// MARK: Bezier Length

@_transparent
private func QuadBezierLength(_ t: Double, _ a: Double, _ b: Double, _ c: Double) -> Double {
    
    if a.almostZero() {
        if b.almostZero() {
            return sqrt(c) * t
        }
        let g = pow(b * t + c, 1.5)
        let h = pow(c, 1.5)
        return 2 * (g - h) / (3 * b)
    }
    if b.almostZero() {
        let g = sqrt(a * t * t + c)
        let h = sqrt(a)
        let i = log(h * g + a * t)
        let j = log(h * sqrt(c))
        return 0.5 * (t * g + c * (i - j) / h)
    }
    if a.almostEqual(c) && a.almostEqual(-0.5 * b) {
        let g = t - 1
        if g.almostZero() {
            return 0.5 * sqrt(a)
        }
        let h = sqrt(a * g * g)
        return 0.5 * t * (t - 2) * h / g
    }
    
    let delta = b * b - 4 * a * c
    if delta.almostZero() {
        let g = sqrt(a)
        let h = b > 0 ? sqrt(c) : -sqrt(c)
        let i = g * t + h
        if i.almostZero() {
            return 0.5 * c / g
        }
        let j = 0.5 * t * abs(i) * (i + h) / i
        return t < -b / a ? c / g + j : j
    }
    
    let g = 2 * sqrt(a * (t * (a * t + b) + c))
    let h = 2 * a * t + b
    let i = 0.125 * pow(a, -1.5)
    let j = 2 * sqrt(a * c)
    let k = log(g + h)
    let l = log(j + b)
    return i * (g * h - j * b - delta * (k - l))
}
public func QuadBezierLength(_ t: Double, _ p0: Point, _ p1: Point, _ p2: Point) -> Double {
    
    if t.almostZero() {
        return t
    }
    
    let x = Bezier(p0.x, p1.x, p2.x).polynomial.derivative
    let y = Bezier(p0.y, p1.y, p2.y).polynomial.derivative
    
    let u = x * x + y * y
    
    return QuadBezierLength(t, u[2], u[1], u[0])
}
public func InverseQuadBezierLength(_ length: Double, _ p0: Point, _ p1: Point, _ p2: Point) -> Double {
    
    if length.almostZero() {
        return length
    }
    
    let x = Bezier(p0.x, p1.x, p2.x).polynomial.derivative
    let y = Bezier(p0.y, p1.y, p2.y).polynomial.derivative
    
    let u = x * x + y * y
    
    let a = u[2]
    let b = u[1]
    let c = u[0]
    
    if a.almostZero() {
        return b.almostZero() ? length / sqrt(c) : (pow(1.5 * b * length, 2 / 3) - c) / b
    }
    if a.almostEqual(c) && a.almostEqual(-0.5 * b) && length.almostEqual(0.5 * sqrt(a)) {
        return 1
    }
    
    var t = length / QuadBezierLength(1, a, b, c)
    
    t -= (QuadBezierLength(t, a, b, c) - length) / sqrt((a * t + b) * t + c)
    t -= (QuadBezierLength(t, a, b, c) - length) / sqrt((a * t + b) * t + c)
    t -= (QuadBezierLength(t, a, b, c) - length) / sqrt((a * t + b) * t + c)
    t -= (QuadBezierLength(t, a, b, c) - length) / sqrt((a * t + b) * t + c)
    
    return t
}

// MARK: Fitting

public func QuadBezierFitting(_ p0: Point, _ p2: Point, _ m0: Point, _ m2: Point) -> Point? {
    let a = p2.x - p0.x
    let b = p2.y - p0.y
    let c = m0.x * m2.y - m0.y * m2.x
    if c == 0 {
        return nil
    }
    let d = a * m2.y - b * m2.x
    return p0 + m0 * d / c
}

@_transparent
private func QuadBezierFittingCurvature(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let u = p2 - p0
    let v = p1 - 0.5 * (p2 + p0)
    return u.magnitude < v.magnitude * 3
}
private func QuadBezierFitting(_ p: [Point], _ limit: Int, _ inflection_check: Bool) -> [[Point]] {
    
    if p.count < 4 {
        return [p]
    }
    
    if inflection_check {
        var t = Bezier(p).inflection.filter { !$0.almostZero() && !$0.almostEqual(1) && 0...1 ~= $0 }
        t.append(contentsOf: Bezier(p.map { $0.x }).stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
        t.append(contentsOf: Bezier(p.map { $0.y }).stationary.filter { _t in !_t.almostZero() && !_t.almostEqual(1) && 0...1 ~= _t && !t.contains { $0.almostEqual(_t) } })
        return Bezier(p).split(t).flatMap { QuadBezierFitting($0.points, limit - 1, false) }
    }
    
    let d = zip(p.dropFirst(), p).map { $0 - $1 }
    
    func split(_ t: Double) -> [[Point]] {
        let (left, right) = Bezier(p).split(t)
        return QuadBezierFitting(left.points, limit - 1, false) + QuadBezierFitting(right.points, limit - 1, false)
    }
    
    let start = p.first!
    let end = p.last!
    
    if limit > 0 && p.dropFirst().dropLast().contains(where: { QuadBezierFittingCurvature(start, $0, end) }) {
        return split(0.5)
    }
    
    let m0 = d.first { !$0.x.almostZero() || !$0.y.almostZero() }
    let m1 = d.last { !$0.x.almostZero() || !$0.y.almostZero() }
    
    if let m0 = m0, let m1 = m1 {
        if let mid = QuadBezierFitting(start, end, m0, m1) {
            if QuadBezierFittingCurvature(start, mid, end) {
                if limit > 0 {
                    return split(0.5)
                } else {
                    return [[start, 2 * (Bezier(p).eval(0.5) - 0.25 * (start + end)), end]]
                }
            }
            return [[start, mid, end]]
        }
    }
    return [[start, end]]
}
public func QuadBezierFitting(_ p: [Point]) -> [[Point]] {
    
    return QuadBezierFitting(p, 3, true)
}

public func CubicBezierFitting(_ p0: Point, _ p3: Point, _ m0: Point, _ m1: Point, _ points: [(Double, Point)]) -> (Point, Point)? {
    
    var _a1 = 0.0
    var _b1 = 0.0
    var _c1 = 0.0
    var _a2 = 0.0
    var _b2 = 0.0
    var _c2 = 0.0
    
    for (t, p) in points {
        
        let t2 = t * t
        let t3 = t2 * t
        
        let _t = 1 - t
        let _t2 = _t * _t
        let _t3 = _t2 * _t
        
        let t_t2 = 3 * _t2 * t
        let t2_t = 3 * _t * t2
        
        let _a = t_t2 * m0
        let _b = t2_t * m1
        let _c = (_t3 + t_t2) * p0 + (t3 + t2_t) * p3 - p
        
        _a1 += dot(_a, _a)
        _b1 += dot(_a, _b)
        _c1 += dot(_a, _c)
        
        _a2 += dot(_b, _a)
        _b2 += dot(_b, _b)
        _c2 += dot(_b, _c)
    }
    
    _c1 = abs(_c1)
    _c2 = abs(_c2)
    
    let t = _a1 * _b2 - _b1 * _a2
    
    if t.almostZero() {
        return nil
    }
    
    let _t = 1 / t
    
    let u = (_c1 * _b2 - _c2 * _b1) * _t
    let v = (_c2 * _a1 - _c1 * _a2) * _t
    
    return (u * m0 + p0, v * m1 + p3)
}
public func CubicBezierFitting(_ p0: Point, _ p3: Point, _ m0: Point, _ m1: Point, _ points: [Point]) -> (Point, Point)? {
    
    let ds = zip(CollectionOfOne(p0).concat(points), points).map { ($0 - $1).magnitude }
    let dt = zip(points, points.dropFirst().concat(CollectionOfOne(p3))).map { ($0 - $1).magnitude }
    return CubicBezierFitting(p0, p3, m0, m1, Array(zip(zip(ds, dt).map { $0 / ($0 + $1) }, points)))
}

@_transparent
private func BezierFitting(start: Double, end: Double, _ passing: [(Double, Double)]) -> [Double]? {
    
    let n = passing.count
    
    var matrix: [Double] = []
    matrix.reserveCapacity(n * (n + 1))
    
    let c = CombinationList(UInt(n + 1)).dropFirst().dropLast()
    for (t, p) in passing {
        let s = 1 - t
        let tn = pow(t, Double(n + 1))
        let sn = pow(s, Double(n + 1))
        let st = t / s
        let u = sequence(first: sn * st) { $0 * st }
        let v = zip(c, u).lazy.map { Double($0) * $1 }
        matrix.append(contentsOf: v.concat(CollectionOfOne(p - sn * start - tn * end)))
    }
    
    if MatrixElimination(n, &matrix) {
        let a: LazyMapSequence = matrix.lazy.slice(by: n + 1).map { $0.last! }
        let b = CollectionOfOne(start).concat(a).concat(CollectionOfOne(end))
        return Array(b)
    }
    
    return nil
}

public func BezierFitting(start: Double, end: Double, _ passing: (Double, Double) ...) -> [Double]? {
    
    return BezierFitting(start: start, end: end, passing)
}

public func BezierFitting(start: Point, end: Point, _ passing: (Double, Point) ...) -> [Point]? {
    
    let x = BezierFitting(start: start.x, end: end.x, passing.map { ($0, $1.x) })
    let y = BezierFitting(start: start.y, end: end.y, passing.map { ($0, $1.y) })
    if let x = x, let y = y {
        return zip(x, y).map { Point(x: $0, y: $1) }
    }
    return nil
}

public func BezierFitting(start: Vector, end: Vector, _ passing: (Double, Vector) ...) -> [Vector]? {
    
    let x = BezierFitting(start: start.x, end: end.x, passing.map { ($0, $1.x) })
    let y = BezierFitting(start: start.y, end: end.y, passing.map { ($0, $1.y) })
    let z = BezierFitting(start: start.z, end: end.z, passing.map { ($0, $1.z) })
    if let x = x, let y = y, let z = z {
        return zip(zip(x, y), z).map { Vector(x: $0.0, y: $0.1, z: $1) }
    }
    return nil
}

// MARK: Bezier Offset

public func BezierOffset(_ p0: Point, _ p1: Point, _ a: Double) -> (Point, Point)? {
    if a.almostZero() {
        return (p0, p1)
    }
    let _x = p1.x - p0.x
    let _y = p1.y - p0.y
    if _x.almostZero() && _y.almostZero() {
        return nil
    }
    let _xy = sqrt(_x * _x + _y * _y)
    let s = a * _y / _xy
    let t = -a * _x / _xy
    return (p0 + Point(x: s, y: t), p1 + Point(x: s, y: t))
}

@_transparent
private func BezierOffsetCurvature(_ p0: Point, _ p1: Point, _ p2: Point) -> Bool {
    let u = p2 - p0
    let v = p1 - 0.5 * (p2 + p0)
    return u.magnitude < v.magnitude * 3
}

public func BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double) -> [[Point]] {
    
    return _BezierOffset(p0, p1, p2, a, 3)
}
public func BezierOffset(_ p: [Point], _ a: Double) -> [[Point]] {
    
    var ph0: Double?
    
    return QuadBezierFitting(p).flatMap { points -> [[Point]] in
        
        var join: [[Point]]  = []
        let d = zip(points.dropFirst(), points).map { $0 - $1 }
        
        if let ph0 = ph0, let ph1 = d.first(where: { !$0.x.almostZero() || !$0.y.almostZero() })?.phase {
            let angle = (ph1 - ph0).remainder(dividingBy: 2 * Double.pi)
            if !angle.almostZero() {
                let rotate = SDTransform.Rotate(ph0 - 0.5 * Double.pi)
                let offset = points[0]
                let bezierArc = BezierArc(angle).lazy.map { $0 * rotate * a + offset }
                for i in 0..<bezierArc.count / 3 {
                    join.append([bezierArc[i * 3], bezierArc[i * 3 + 1], bezierArc[i * 3 + 2], bezierArc[i * 3 + 3]])
                }
            }
        }
        ph0 = d.last { !$0.x.almostZero() || !$0.y.almostZero() }?.phase ?? ph0
        
        switch points.count {
        case 2: return BezierOffset(points[0], points[1], a).map { join + [[$0, $1]] } ?? join
        case 3: return join + _BezierOffset(points[0], points[1], points[2], a, 3)
        default: fatalError()
        }
    }
}
private func _BezierOffset(_ p0: Point, _ p1: Point, _ p2: Point, _ a: Double, _ limit: Int) -> [[Point]] {
    
    if a.almostZero() {
        return [[p0, p1, p2]]
    }
    
    let q0 = p1 - p0
    let q1 = p2 - p1
    
    if (q0.x.almostZero() && q0.y.almostZero()) || (q1.x.almostZero() && q1.y.almostZero()) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
    }
    let ph0 = q0.phase
    let ph1 = q1.phase
    
    if ph0.almostEqual(ph1) || ph0.almostEqual(ph1 + 2 * Double.pi) || ph0.almostEqual(ph1 - 2 * Double.pi) {
        return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
    }
    if ph0.almostEqual(ph1 + Double.pi) || ph0.almostEqual(ph1 - Double.pi) {
        if let w = Bezier(p0, p1, p2).stationary.first, !w.almostZero() && !w.almostEqual(1) && 0...1 ~= w {
            let g = Bezier(p0, p1, p2).eval(w)
            let angle = ph0 - 0.5 * Double.pi
            let bezierCircle = BezierCircle.lazy.map { $0 * SDTransform.Rotate(angle) * a + g }
            let v0 = OptionOneCollection(BezierOffset(p0, g, a).map { [$0, $1] })
            let v1 = OptionOneCollection([bezierCircle[0], bezierCircle[1], bezierCircle[2], bezierCircle[3]])
            let v2 = OptionOneCollection([bezierCircle[3], bezierCircle[4], bezierCircle[5], bezierCircle[6]])
            let v3 = OptionOneCollection(BezierOffset(g, p2, a).map { [$0, $1] })
            return Array([v0, v1, v2, v3].joined())
        }
    }
    
    func split(_ t: Double) -> [[Point]] {
        let (left, right) = Bezier(p0, p1, p2).split(t)
        return _BezierOffset(left[0], left[1], left[2], a, limit - 1) + _BezierOffset(right[0], right[1], right[2], a, limit - 1)
    }
    
    if limit > 0 && BezierOffsetCurvature(p0, p1, p2) {
        return split(0.5)
    }
    
    let s = 1 / q0.magnitude
    let t = 1 / q1.magnitude
    let start = Point(x: p0.x + a * q0.y * s, y: p0.y - a * q0.x * s)
    let end = Point(x: p2.x + a * q1.y * t, y: p2.y - a * q1.x * t)
    
    if let mid = QuadBezierFitting(start, end, q0, q1) {
        if BezierOffsetCurvature(start, mid, end) {
            if limit > 0 {
                return split(0.5)
            } else {
                let m = Bezier(q0, q1).eval(0.5)
                let _s = 1 / m.magnitude
                let _mid = Bezier(p0, p1, p2).eval(0.5) + Point(x: a * m.y * _s, y: -a * m.x * _s)
                return [[start, 2 * (_mid - 0.25 * (start + end)), end]]
            }
        }
        return [[start, mid, end]]
    }
    
    return BezierOffset(p0, p2, a).map { [[$0, $1]] } ?? []
}

// MARK: Shape Tweening

public func BezierTweening(start: [Point], end: [Point], _ t: Double) -> [Point] {
    
    let start_start = start.first!
    let start_end = start.last!
    let end_start = end.first!
    let end_end = end.last!
    let d1 = start_end - start_start
    let d2 = end_end - end_start
    
    let transform1 = SDTransform.Translate(x: -start_start.x, y: -start_start.y) * SDTransform.Scale(1 / d1.magnitude) * SDTransform.Rotate(-d1.phase)
    let s = Bezier(start.map { $0 * transform1 })
    
    let transform2 = SDTransform.Translate(x: -end_start.x, y: -end_start.y) * SDTransform.Scale(1 / d2.magnitude) * SDTransform.Rotate(-d2.phase)
    let e = Bezier(end.map { $0 * transform2 })
    
    let m = (1 - t) * s + t * e
    
    let m_start = (1 - t) * start_start + t * end_start
    let m_end = (1 - t) * start_end + t * end_end
    let m_d = m_end - m_start
    
    let transform3 = SDTransform.Rotate(m_d.phase) * SDTransform.Scale(m_d.magnitude) * SDTransform.Translate(x: m_start.x, y: m_start.y)
    return m.points.map { $0 * transform3 }
}

// MARK: Mesh Warping

public func CoonsPatch(_ m00: Point, _ m01: Point, _ m02: Point, _ m03: Point,
                       _ m10: Point, _ m13: Point, _ m20: Point, _ m23: Point,
                       _ m30: Point, _ m31: Point, _ m32: Point, _ m33: Point,
                       _ p: Point ... ) -> [[Point]] {
    
    let u = Bezier(p.map { $0.x }).polynomial
    let v = Bezier(p.map { $0.y }).polynomial
    let u2 = u * u
    let v2 = v * v
    let u3 = u2 * u
    let v3 = v2 * v
    
    let _u = 1 - u
    let _v = 1 - v
    let _u2 = _u * _u
    let _v2 = _v * _v
    let _u3 = _u2 * _u
    let _v3 = _v2 * _v
    
    let u_u2 = 3 * _u2 * u
    let u2_u = 3 * _u * u2
    let v_v2 = 3 * _v2 * v
    let v2_v = 3 * _v * v2
    
    let bx = (m00.x * _u + m03.x * u) * _v + (m30.x * _u + m33.x * u) * v
    let by = (m00.y * _u + m03.y * u) * _v + (m30.y * _u + m33.y * u) * v
    
    let c0x = _u3 * m00.x + u_u2 * m01.x + u2_u * m02.x + u3 * m03.x
    let c0y = _u3 * m00.y + u_u2 * m01.y + u2_u * m02.y + u3 * m03.y
    let c1x = _u3 * m30.x + u_u2 * m31.x + u2_u * m32.x + u3 * m33.x
    let c1y = _u3 * m30.y + u_u2 * m31.y + u2_u * m32.y + u3 * m33.y
    let c2x = _v3 * m00.x + v_v2 * m10.x + v2_v * m20.x + v3 * m30.x
    let c2y = _v3 * m00.y + v_v2 * m10.y + v2_v * m20.y + v3 * m30.y
    let c3x = _v3 * m03.x + v_v2 * m13.x + v2_v * m23.x + v3 * m33.x
    let c3y = _v3 * m03.y + v_v2 * m13.y + v2_v * m23.y + v3 * m33.y
    
    let d0x = _v * c0x + v * c1x
    let d0y = _v * c0y + v * c1y
    let d1x = _u * c2x + u * c3x
    let d1y = _u * c2y + u * c3y
    
    var _x = d0x + d1x - bx
    var _y = d0y + d1y - by
    
    while _x.last?.almostZero() == true {
        _x.removeLast()
    }
    while _y.last?.almostZero() == true {
        _y.removeLast()
    }
    
    var x = Bezier(_x)
    var y = Bezier(_y)
    
    let degree = max(x.degree, y.degree)
    
    while x.degree != degree {
        x = x.elevated()
    }
    while y.degree != degree {
        y = y.elevated()
    }
    
    let points = zip(x, y).map { Point(x: $0, y: $1) }
    
    switch degree {
    case 1, 2, 3: return [points]
    default: return QuadBezierFitting(points)
    }
}

public func TensorPatch(_ m00: Point, _ m01: Point, _ m02: Point, _ m03: Point,
                        _ m10: Point, _ m11: Point, _ m12: Point, _ m13: Point,
                        _ m20: Point, _ m21: Point, _ m22: Point, _ m23: Point,
                        _ m30: Point, _ m31: Point, _ m32: Point, _ m33: Point,
                        _ p: Point ... ) -> [[Point]] {
    
    let u = Bezier(p.map { $0.x }).polynomial
    let v = Bezier(p.map { $0.y }).polynomial
    let u2 = u * u
    let v2 = v * v
    let u3 = u2 * u
    let v3 = v2 * v
    
    let _u = 1 - u
    let _v = 1 - v
    let _u2 = _u * _u
    let _v2 = _v * _v
    let _u3 = _u2 * _u
    let _v3 = _v2 * _v
    
    let u_u2 = 3 * _u2 * u
    let u2_u = 3 * _u * u2
    let v_v2 = 3 * _v2 * v
    let v2_v = 3 * _v * v2
    
    let c0x = _u3 * m00.x + u_u2 * m01.x + u2_u * m02.x + u3 * m03.x
    let c0y = _u3 * m00.y + u_u2 * m01.y + u2_u * m02.y + u3 * m03.y
    let c1x = _u3 * m10.x + u_u2 * m11.x + u2_u * m12.x + u3 * m13.x
    let c1y = _u3 * m10.y + u_u2 * m11.y + u2_u * m12.y + u3 * m13.y
    let c2x = _u3 * m20.x + u_u2 * m21.x + u2_u * m22.x + u3 * m23.x
    let c2y = _u3 * m20.y + u_u2 * m21.y + u2_u * m22.y + u3 * m23.y
    let c3x = _u3 * m30.x + u_u2 * m31.x + u2_u * m32.x + u3 * m33.x
    let c3y = _u3 * m30.y + u_u2 * m31.y + u2_u * m32.y + u3 * m33.y
    
    var _x = _v3 * c0x + v_v2 * c1x + v2_v * c2x + v3 * c3x
    var _y = _v3 * c0y + v_v2 * c1y + v2_v * c2y + v3 * c3y
    
    while _x.last?.almostZero() == true {
        _x.removeLast()
    }
    while _y.last?.almostZero() == true {
        _y.removeLast()
    }
    
    var x = Bezier(_x)
    var y = Bezier(_y)
    
    let degree = max(x.degree, y.degree)
    
    while x.degree != degree {
        x = x.elevated()
    }
    while y.degree != degree {
        y = y.elevated()
    }
    
    let points = zip(x, y).map { Point(x: $0, y: $1) }
    
    switch degree {
    case 1, 2, 3: return [points]
    default: return QuadBezierFitting(points)
    }
}

var BezierCircle: [Point] {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    return [
        Point(x: 1, y: 0),
        Point(x: 1, y: c),
        Point(x: c, y: 1),
        Point(x: 0, y: 1),
        Point(x: -c, y: 1),
        Point(x: -1, y: c),
        Point(x: -1, y: 0),
        Point(x: -1, y: -c),
        Point(x: -c, y: -1),
        Point(x: 0, y: -1),
        Point(x: c, y: -1),
        Point(x: 1, y: -c),
        Point(x: 1, y: 0)
    ]
}
public func BezierArc(_ angle: Double) -> [Point] {
    
    //
    // root of 18225 x^12 + 466560 x^11 - 28977264 x^10 + 63288000 x^9 + 96817248 x^8
    //         - 515232000 x^7 + 883891456 x^6 - 921504768 x^5 + 668905728 x^4
    //         - 342814720 x^3 + 117129216 x^2 - 23592960 x + 2097152
    // reference: http://spencermortensen.com/articles/bezier-circle/
    //
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    var counter = 0
    var _angle = abs(angle)
    var result = [Point(x: 1, y: 0)]
    
    while _angle > 0 && !_angle.almostZero() {
        switch counter & 3 {
        case 0:
            result.append(Point(x: 1, y: c))
            result.append(Point(x: c, y: 1))
            result.append(Point(x: 0, y: 1))
        case 1:
            result.append(Point(x: -c, y: 1))
            result.append(Point(x: -1, y: c))
            result.append(Point(x: -1, y: 0))
        case 2:
            result.append(Point(x: -1, y: -c))
            result.append(Point(x: -c, y: -1))
            result.append(Point(x: 0, y: -1))
        case 3:
            result.append(Point(x: c, y: -1))
            result.append(Point(x: 1, y: -c))
            result.append(Point(x: 1, y: 0))
        default: break
        }
        if _angle < 0.5 * Double.pi {
            let offset = Double(counter & 3) * 0.5 * Double.pi
            let s = _angle + offset
            let _a = result.count - 4
            let _b = result.count - 3
            let _c = result.count - 2
            let _d = result.count - 1
            let end = Point(x: cos(s), y: sin(s))
            let t = Bezier(result[_a], result[_b], result[_c], result[_d]).closest(end).first!
            let split = Bezier(result[_a], result[_b], result[_c], result[_d]).split(t).0
            result[_b] = split[1]
            result[_c] = split[2]
            result[_d] = end
        }
        _angle -= 0.5 * Double.pi
        counter += 1
    }
    return angle.sign == .minus ? result.map { Point(x: $0.x, y: -$0.y) } : result
}

// MARK: Path Intersection

public func CubicBezierSelfIntersect(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> (Double, Double)? {
    
    let q1 = 3 * (p1 - p0)
    let q2 = 3 * (p2 + p0) - 6 * p1
    let q3 = p3 - p0 + 3 * (p1 - p2)
    
    let d1 = -cross(q3, q2)
    let d2 = cross(q3, q1)
    let d3 = -cross(q2, q1)
    
    let discr = 3 * d2 * d2 - 4 * d1 * d3
    
    if !d1.almostZero() && !discr.almostZero() && discr < 0 {
        
        let delta = sqrt(-discr)
        
        let s = 0.5 / d1
        let td = d2 + delta
        let te = d2 - delta
        
        return (td * s, te * s)
    }
    
    return nil
}

public func LinesIntersect(_ p0: Point, _ p1: Point, _ p2: Point, _ p3: Point) -> Point? {
    
    let d = (p0.x - p1.x) * (p2.y - p3.y) - (p0.y - p1.y) * (p2.x - p3.x)
    if d.almostZero() {
        return nil
    }
    let a = (p0.x * p1.y - p0.y * p1.x) / d
    let b = (p2.x * p3.y - p2.y * p3.x) / d
    return Point(x: (p2.x - p3.x) * a - (p0.x - p1.x) * b, y: (p2.y - p3.y) * a - (p0.y - p1.y) * b)
}

public func QuadBezierLineIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let a = b0 - l0
    let b = 2 * (b1 - b0)
    let c = b0 - 2 * b1 + b2
    
    let u0: Polynomial = [a.x, b.x, c.x]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [a.y, b.y, c.y]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all(where: { $0.almostZero() }) ? nil : poly.roots
}

public func CubicBezierLineIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ l0: Point, _ l1: Point) -> [Double]? {
    
    let a = b0 - l0
    let b = 3 * (b1 - b0)
    let c = 3 * (b2 + b0) - 6 * b1
    let d = b3 - b0 + 3 * (b1 - b2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = l0.x - l1.x
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = l0.y - l1.y
    
    let poly = u1 * v0 - u0 * v1
    return poly.all(where: { $0.almostZero() }) ? nil : poly.roots
}

public func QuadBeziersIntersect(_ b0: Point, _ b1: Point, _ b2: Point, _ b3: Point, _ b4: Point, _ b5: Point) -> [Double]? {
    
    let a = b0 - b3
    let b = 2 * (b1 - b0)
    let c = b0 - 2 * b1 + b2
    
    let u0: Polynomial = [a.x, b.x, c.x]
    let u1 = 2 * (b3.x - b4.x)
    let u2 = 2 * b4.x - b3.x -  b5.x
    
    let v0: Polynomial = [a.y, b.y, c.y]
    let v1 = 2 * (b3.y - b4.y)
    let v2 = 2 * b4.y - b3.y -  b5.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all(where: { $0.almostZero() }) ? nil : det.roots
}

public func CubicQuadBezierIntersect(_ c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ q0: Point, _ q1: Point, _ q2: Point) -> [Double]? {
    
    let a = c0 - q0
    let b = 3 * (c1 - c0)
    let c = 3 * (c2 + c0) - 6 * c1
    let d = c3 - c0 + 3 * (c1 - c2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = 2 * (q0.x - q1.x)
    let u2 = 2 * q1.x - q0.x - q2.x
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = 2 * (q0.y - q1.y)
    let v2 = 2 * q1.y - q0.y - q2.y
    
    // Bézout matrix
    let m00 = u2 * v1 - u1 * v2
    let m01 = u2 * v0 - u0 * v2
    let m10 = m01
    let m11 = u1 * v0 - u0 * v1
    
    let det = m00 * m11 - m01 * m10
    return det.all(where: { $0.almostZero() }) ? nil : det.roots
}

public func CubicBeziersIntersect(_ c0: Point, _ c1: Point, _ c2: Point, _ c3: Point, _ c4: Point, _ c5: Point, _ c6: Point, _ c7: Point) -> [Double]? {
    
    let a = c0 - c4
    let b = 3 * (c1 - c0)
    let c = 3 * (c2 + c0) - 6 * c1
    let d = c3 - c0 + 3 * (c1 - c2)
    
    let u0: Polynomial = [a.x, b.x, c.x, d.x]
    let u1 = 3 * (c4.x - c5.x)
    let u2 = 6 * c5.x - 3 * (c6.x + c4.x)
    let u3 = c4.x - c7.x + 3 * (c6.x - c5.x)
    
    let v0: Polynomial = [a.y, b.y, c.y, d.y]
    let v1 = 3 * (c4.y - c5.y)
    let v2 = 6 * c5.y - 3 * (c6.y + c4.y)
    let v3 = c4.y - c7.y + 3 * (c6.y - c5.y)
    
    // Bézout matrix
    let m00 = u3 * v2 - u2 * v3
    let m01 = u3 * v1 - u1 * v3
    let m02 = u3 * v0 - u0 * v3
    let m10 = m01
    let m11 = u2 * v1 - u1 * v2 + m02
    let m12 = u2 * v0 - u0 * v2
    let m20 = m02
    let m21 = m12
    let m22 = u1 * v0 - u0 * v1
    
    let _a = m11 * m22 - m12 * m21
    let _b = m12 * m20 - m10 * m22
    let _c = m10 * m21 - m11 * m20
    let det = m00 * _a + m01 * _b + m02 * _c
    return det.all(where: { $0.almostZero() }) ? nil : det.roots
}
