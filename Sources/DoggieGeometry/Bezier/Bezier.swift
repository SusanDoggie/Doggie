//
//  Bezier.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

@frozen
public struct Bezier<Element: ScalarMultiplicative>: BezierProtocol where Element.Scalar == Double {
    
    @usableFromInline
    var points: [Element]
    
    @inlinable
    public init() {
        self.init(.zero, .zero)
    }
    
    @inlinable
    public init(_ p: Element ... ) {
        self.init(p)
    }
    
    @inlinable
    public init<S: Sequence>(_ s: S) where S.Element == Element {
        self.points = Array(s)
        while points.count < 2 {
            points.append(points.first ?? .zero)
        }
    }
}

extension Bezier: ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: Element ... ) {
        self.init(elements)
    }
}

extension Bezier: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(points)"
    }
}

extension Bezier: Hashable where Element: Hashable {
    
}

extension Bezier: Decodable where Element: Decodable {
    
    @inlinable
    public init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        var points: [Element] = []
        
        if let count = container.count {
            points.reserveCapacity(count)
            for _ in 0..<count {
                points.append(try container.decode(Element.self))
            }
        }
        
        while !container.isAtEnd {
            points.append(try container.decode(Element.self))
        }
        
        self.init(points)
    }
}

extension Bezier: Encodable where Element: Encodable {
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(points)
    }
}

extension Bezier {
    
    @inlinable
    public func map(_ transform: (Element) -> Element) -> Bezier {
        return Bezier(points.map(transform))
    }
    
    @inlinable
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) -> Result) -> Result {
        return points.reduce(initialResult, nextPartialResult)
    }
    
    @inlinable
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) -> Result {
        return points.reduce(into: initialResult, updateAccumulatingResult)
    }
    
    @inlinable
    public func combined(_ other: Bezier, _ transform: (Element, Element) -> Element) -> Bezier {
        
        var lhs = self
        var rhs = other
        
        let degree = Swift.max(lhs.degree, rhs.degree)
        
        while lhs.degree != degree {
            lhs = lhs.elevated()
        }
        while rhs.degree != degree {
            rhs = rhs.elevated()
        }
        
        return Bezier(zip(lhs.points, rhs.points).map(transform))
    }
}

extension Bezier {
    
    public typealias Indices = Range<Int>
    
    @inlinable
    public var startIndex: Int {
        return points.startIndex
    }
    @inlinable
    public var endIndex: Int {
        return points.endIndex
    }
    
    @inlinable
    public subscript(position: Int) -> Element {
        get {
            return points[position]
        }
        set {
            points[position] = newValue
        }
    }
}

extension Bezier {
    
    @inlinable
    public var start: Element {
        return points[0]
    }
    
    @inlinable
    public var end: Element {
        return points[points.count - 1]
    }
    
    @inlinable
    public func eval(_ t: Double) -> Element {
        switch points.count {
        case 2: return LineSegment(points[0], points[1]).eval(t)
        case 3: return QuadBezier(points[0], points[1], points[2]).eval(t)
        case 4: return CubicBezier(points[0], points[1], points[2], points[3]).eval(t)
        default:
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
    
    @inlinable
    static func split(_ t: Double, _ p: [Element]) -> ([Element], [Element]) {
        switch p.count {
        case 2:
            let p0 = p[0]
            let p1 = p[1]
            let q0 = p0 + t * (p1 - p0)
            return ([p0, q0], [q0, p1])
        case 3:
            let p0 = p[0]
            let p1 = p[1]
            let p2 = p[2]
            let q0 = p0 + t * (p1 - p0)
            let q1 = p1 + t * (p2 - p1)
            let u0 = q0 + t * (q1 - q0)
            return ([p0, q0, u0], [u0, q1, p2])
        case 4:
            let p0 = p[0]
            let p1 = p[1]
            let p2 = p[2]
            let p3 = p[3]
            let q0 = p0 + t * (p1 - p0)
            let q1 = p1 + t * (p2 - p1)
            let q2 = p2 + t * (p3 - p2)
            let u0 = q0 + t * (q1 - q0)
            let u1 = q1 + t * (q2 - q1)
            let v0 = u0 + t * (u1 - u0)
            return ([p0, q0, u0, v0], [v0, u1, q2, p3])
        default:
            let _split = split(t, zip(p, p.dropFirst()).map { $0 + t * ($1 - $0) })
            return ([p[0]] + _split.0, _split.1 + [p.last!])
        }
    }
    
    @inlinable
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
    
    @inlinable
    public func elevated() -> Bezier {
        let p = self.points
        let n = Double(p.count)
        var result = [p[0]]
        result.reserveCapacity(p.count + 1)
        for (k, points) in zip(p, p.dropFirst()).enumerated() {
            let t = Double(k + 1) / n
            result.append(t * (points.0 - points.1) + points.1)
        }
        result.append(p.last!)
        return Bezier(result)
    }
    
    @inlinable
    public func derivative() -> Bezier {
        let n = Double(points.count - 1)
        return Bezier(zip(points, points.dropFirst()).map { n * ($1 - $0) })
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public var x: Bezier<Double> {
        return Bezier<Double>(points.map { $0.x })
    }
    
    @inlinable
    public var y: Bezier<Double> {
        return Bezier<Double>(points.map { $0.y })
    }
}

extension Bezier where Element == Vector {
    
    @inlinable
    public var x: Bezier<Double> {
        return Bezier<Double>(points.map { $0.x })
    }
    
    @inlinable
    public var y: Bezier<Double> {
        return Bezier<Double>(points.map { $0.y })
    }
    
    @inlinable
    public var z: Bezier<Double> {
        return Bezier<Double>(points.map { $0.z })
    }
}

extension Bezier where Element == Double {
    
    @inlinable
    public var polynomial: Polynomial {
        switch points.count {
        case 2: return LineSegment(points[0], points[1]).polynomial
        case 3: return QuadBezier(points[0], points[1], points[2]).polynomial
        case 4: return CubicBezier(points[0], points[1], points[2], points[3]).polynomial
        default:
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
    
    @inlinable
    public init(_ polynomial: Polynomial) {
        let de = (0..<Swift.max(1, polynomial.degree)).reductions(polynomial) { p, _ in p.derivative / Double(p.degree) }
        var points: [Double] = []
        for n in de.indices {
            let s = zip(CombinationList(UInt(n)), de)
            points.append(s.reduce(0) { $0 + Double($1.0) * $1.1[0] })
        }
        self.init(points)
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public func closest(_ point: Point, in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double] {
        switch points.count {
        case 2: return LineSegment(points[0], points[1]).closest(point, in: range)
        case 3: return QuadBezier(points[0], points[1], points[2]).closest(point, in: range)
        case 4: return CubicBezier(points[0], points[1], points[2], points[3]).closest(point, in: range)
        default:
            let x = self.x.polynomial - point.x
            let y = self.y.polynomial - point.y
            let dot = x * x + y * y
            return dot.derivative.roots(in: range).sorted(by: { dot.eval($0) })
        }
    }
}

extension Bezier where Element: Tensor {
    
    @inlinable
    public func closest(_ point: Element, in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double] {
        var dot: Polynomial = []
        for i in 0..<Element.numberOfComponents {
            let p = Bezier<Double>(points.map { $0[i] }).polynomial - point[i]
            dot += p * p
        }
        return dot.derivative.roots(in: range).sorted(by: { dot.eval($0) })
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public var area: Double {
        switch points.count {
        case 2: return LineSegment(points[0], points[1]).area
        case 3: return QuadBezier(points[0], points[1], points[2]).area
        case 4: return CubicBezier(points[0], points[1], points[2], points[3]).area
        default:
            let x = self.x.polynomial
            let y = self.y.polynomial
            let t = x * y.derivative - x.derivative * y
            return 0.5 * t.integral.eval(1)
        }
    }
}

@inlinable
func _bezier_curvature(_ x: Polynomial, _ y: Polynomial, _ t: Double) -> Double {
    let dx = x.derivative
    let dy = y.derivative
    let ddx = dx.derivative
    let ddy = dy.derivative
    let u = dx * ddy - ddx * dy
    let v = dx * dx + dy * dy
    return u.eval(t) * pow(v.eval(t), -1.5)
}

@inlinable
func _bezier_stationary(_ x: Polynomial, _ y: Polynomial) -> [Double] {
    let dx = x.derivative
    let dy = y.derivative
    let ddx = dx.derivative
    let ddy = dy.derivative
    let u = dx * ddy - ddx * dy
    let v = dx * dx + dy * dy
    let du = u.derivative
    let dv = v.derivative
    let k = du * v * v - 1.5 * u * v * dv
    return k.roots()
}

extension Bezier where Element == Point {
    
    @inlinable
    public var inflection: [Double] {
        switch points.count {
        case 2, 3: return []
        case 4: return Array(CubicBezier(points[0], points[1], points[2], points[3]).inflection)
        default:
            let x = self.x.polynomial.derivative
            let y = self.y.polynomial.derivative
            return (x * y.derivative - y * x.derivative).roots()
        }
    }
    
    @inlinable
    public func curvature(_ t: Double) -> Double {
        let x = self.x.polynomial
        let y = self.y.polynomial
        return _bezier_curvature(x, y, t)
    }
    
    @inlinable
    public var stationary: [Double] {
        let x = self.x.polynomial
        let y = self.y.polynomial
        return _bezier_stationary(x, y)
    }
}

extension Bezier where Element == Double {
    
    @inlinable
    public var stationary: [Double] {
        switch points.count {
        case 2: return []
        case 3: return Array(QuadBezier(points[0], points[1], points[2]).stationary)
        case 4: return Array(CubicBezier(points[0], points[1], points[2], points[3]).stationary)
        default: return polynomial.derivative.roots()
        }
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public var boundary: Rect {
        let points = self.points
        
        let bx = self.x
        let by = self.y
        
        let _x = bx.stationary.lazy.map { bx.eval($0.clamped(to: 0...1)) }.minAndMax()
        let _y = by.stationary.lazy.map { by.eval($0.clamped(to: 0...1)) }.minAndMax()
        
        let first = points[0]
        let last = points[points.count - 1]
        
        let minX = _x.map { Swift.min(first.x, last.x, $0.min) } ?? Swift.min(first.x, last.x)
        let minY = _y.map { Swift.min(first.y, last.y, $0.min) } ?? Swift.min(first.y, last.y)
        let maxX = _x.map { Swift.max(first.x, last.x, $0.max) } ?? Swift.max(first.x, last.x)
        let maxY = _y.map { Swift.max(first.y, last.y, $0.max) } ?? Swift.max(first.y, last.y)
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

private enum BézoutElement {
    
    case number(Double)
    case polynomial(Polynomial)
    
    var polynomial: Polynomial {
        switch self {
        case let .number(x): return [x]
        case let .polynomial(x): return x
        }
    }
    
    static prefix func -(x: BézoutElement) -> BézoutElement {
        switch x {
        case let .number(x): return .number(-x)
        case let .polynomial(x): return .polynomial(-x)
        }
    }
    
    static func +(lhs: BézoutElement, rhs: BézoutElement) -> BézoutElement {
        switch lhs {
        case let .number(lhs):
            switch rhs {
            case let .number(rhs): return .number(lhs + rhs)
            case let .polynomial(rhs): return .polynomial(lhs + rhs)
            }
        case let .polynomial(lhs):
            switch rhs {
            case let .number(rhs): return .polynomial(lhs + rhs)
            case let .polynomial(rhs): return .polynomial(lhs + rhs)
            }
        }
    }
    
    static func -(lhs: BézoutElement, rhs: BézoutElement) -> BézoutElement {
        switch lhs {
        case let .number(lhs):
            switch rhs {
            case let .number(rhs): return .number(lhs - rhs)
            case let .polynomial(rhs): return .polynomial(lhs - rhs)
            }
        case let .polynomial(lhs):
            switch rhs {
            case let .number(rhs): return .polynomial(lhs - rhs)
            case let .polynomial(rhs): return .polynomial(lhs - rhs)
            }
        }
    }
    
    static func *(lhs: BézoutElement, rhs: BézoutElement) -> BézoutElement {
        switch lhs {
        case let .number(lhs):
            switch rhs {
            case let .number(rhs): return .number(lhs * rhs)
            case let .polynomial(rhs): return .polynomial(lhs * rhs)
            }
        case let .polynomial(lhs):
            switch rhs {
            case let .number(rhs): return .polynomial(lhs * rhs)
            case let .polynomial(rhs): return .polynomial(lhs * rhs)
            }
        }
    }
}

extension Bezier where Element == Point {
    
    public func _intersect(_ other: Bezier) -> Polynomial {
        
        let p1_x = self.x.polynomial
        let p1_y = self.y.polynomial
        let p2_x = other.x.polynomial
        let p2_y = other.y.polynomial
        
        let u = [BézoutElement.polynomial(p1_x - p2_x[0])] + p2_x.dropFirst().map { BézoutElement.number(-$0) }
        let v = [BézoutElement.polynomial(p1_y - p2_y[0])] + p2_y.dropFirst().map { BézoutElement.number(-$0) }
        
        let n = other.degree
        var bézout: [BézoutElement] = []
        bézout.reserveCapacity(n * n)
        
        for j in 1...n {
            for i in 1...n {
                let m = Swift.min(i, n + 1 - j)
                var b: BézoutElement?
                for k in 1...m {
                    let c1 = u[j + k - 1] * v[i - k]
                    let c2 = u[i - k] * v[j + k - 1]
                    let c3 = c1 - c2
                    b = b.map { $0 + c3 } ?? c3
                }
                bézout.append(b!)
            }
        }
        
        func det(_ n: Int, _ matrix: UnsafePointer<BézoutElement>) -> BézoutElement {
            
            guard n != 1 else { return matrix.pointee }
            
            let _n = n - 1
            var result: BézoutElement?
            
            for k in 0..<n {
                var matrix = matrix
                let c = matrix[k]
                var sub_matrix: [BézoutElement] = []
                sub_matrix.reserveCapacity(_n * _n)
                for _ in 1..<n {
                    matrix += n
                    for j in 0..<n where j != k {
                        sub_matrix.append(matrix[j])
                    }
                }
                let r = k & 1 == 0 ? c * det(_n, sub_matrix) : -c * det(_n, sub_matrix)
                result = result.map { $0 + r } ?? r
            }
            return result!
        }
        
        return det(n, bézout).polynomial
    }
    
    public func overlap(_ other: Bezier) -> Bool {
        return self._intersect(other).allSatisfy { $0.almostZero() }
    }
    
    public func intersect(_ other: Bezier, in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double]? {
        let resultant = self._intersect(other)
        return resultant.allSatisfy { $0.almostZero() } ? nil : resultant.roots(in: range)
    }
}
