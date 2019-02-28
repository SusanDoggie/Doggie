//
//  Bezier.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
public struct Bezier<Element : ScalarMultiplicative> : BezierProtocol where Element.Scalar == Double {
    
    public typealias Scalar = Double
    
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
    public init<S : Sequence>(_ s: S) where S.Element == Element {
        self.points = Array(s)
        while points.count < 2 {
            points.append(points.first ?? .zero)
        }
    }
}

extension Bezier : ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: Element ... ) {
        self.init(elements)
    }
}

extension Bezier : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(points)"
    }
}

extension Bezier : Hashable where Element : Hashable {
    
}

extension Bezier: Decodable where Element : Decodable {
    
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

extension Bezier: Encodable where Element : Encodable {
    
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> ()) -> Result {
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
    
    public typealias Index = Int
    
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
}

extension Bezier {
    
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
}

extension Bezier {
    
    @inlinable
    public func derivative() -> Bezier {
        let n = Double(points.count - 1)
        return Bezier(zip(points, points.dropFirst()).map { n * ($1 - $0) })
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public func closest(_ point: Point) -> [Double] {
        switch points.count {
        case 2: return LineSegment(points[0], points[1]).closest(point)
        case 3: return QuadBezier(points[0], points[1], points[2]).closest(point)
        case 4: return CubicBezier(points[0], points[1], points[2], points[3]).closest(point)
        default:
            let x = Bezier<Double>(points.map { $0.x }).polynomial - point.x
            let y = Bezier<Double>(points.map { $0.y }).polynomial - point.y
            let dot = x * x + y * y
            return dot.derivative.roots.sorted(by: { dot.eval($0) })
        }
    }
}

extension Bezier where Element : Tensor {
    
    @inlinable
    public func closest(_ point: Element) -> [Double] {
        var dot: Polynomial = []
        for i in 0..<Element.numberOfComponents {
            let p = Bezier<Double>(points.map { $0[i] }).polynomial - point[i]
            dot += p * p
        }
        return dot.derivative.roots.sorted(by: { dot.eval($0) })
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
            let x = Bezier<Double>(points.map { $0.x }).polynomial
            let y = Bezier<Double>(points.map { $0.y }).polynomial
            let t = x * y.derivative - x.derivative * y
            return 0.5 * t.integral.eval(1)
        }
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public var inflection: [Double] {
        switch points.count {
        case 2, 3: return []
        case 4: return Array(CubicBezier(points[0], points[1], points[2], points[3]).inflection)
        default:
            let x = Bezier<Double>(points.map { $0.x }).polynomial.derivative
            let y = Bezier<Double>(points.map { $0.y }).polynomial.derivative
            return (x * y.derivative - y * x.derivative).roots
        }
    }
}

extension Bezier where Element == Double {
    
    @inlinable
    public var stationary: [Double] {
        switch points.count {
        case 2: return []
        case 3: return Array(QuadBezier(points[0], points[1], points[2]).stationary)
        case 4: return Array(CubicBezier(points[0], points[1], points[2], points[3]).stationary)
        default: return polynomial.derivative.roots
        }
    }
}

extension Bezier where Element == Point {
    
    @inlinable
    public var boundary: Rect {
        let points = self.points
        
        let bx = Bezier<Double>(points.map { $0.x })
        let by = Bezier<Double>(points.map { $0.y })
        
        let _x = bx.stationary.lazy.map { bx.eval($0.clamped(to: 0...1)) }
        let _y = by.stationary.lazy.map { by.eval($0.clamped(to: 0...1)) }
        
        let first = points[0]
        let last = points[points.count - 1]
        
        let minX = _x.min().map { Swift.min(first.x, last.x, $0) } ?? Swift.min(first.x, last.x)
        let minY = _y.min().map { Swift.min(first.y, last.y, $0) } ?? Swift.min(first.y, last.y)
        let maxX = _x.max().map { Swift.max(first.x, last.x, $0) } ?? Swift.max(first.x, last.x)
        let maxY = _y.max().map { Swift.max(first.y, last.y, $0) } ?? Swift.max(first.y, last.y)
        
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension Bezier where Element == Point {
    
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
    
    private func _resultant(_ other: Bezier) -> Polynomial {
        
        let p1_x = Bezier<Double>(self.points.map { $0.x }).polynomial
        let p1_y = Bezier<Double>(self.points.map { $0.y }).polynomial
        let p2_x = Bezier<Double>(other.points.map { $0.x }).polynomial
        let p2_y = Bezier<Double>(other.points.map { $0.y }).polynomial
        
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
        return _resultant(other).allSatisfy { $0.almostZero() }
    }
    
    public func intersect(_ other: Bezier) -> [Double]? {
        let resultant = _resultant(other)
        return resultant.allSatisfy { $0.almostZero() } ? nil : resultant.roots
    }
}
