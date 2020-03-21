//
//  LineSegment.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@frozen
public struct LineSegment<Element: ScalarMultiplicative>: BezierProtocol where Element.Scalar == Double {
    
    public var p0: Element
    public var p1: Element
    
    @inlinable
    @inline(__always)
    public init() {
        self.p0 = .zero
        self.p1 = .zero
    }
    
    @inlinable
    @inline(__always)
    public init(_ p0: Element, _ p1: Element) {
        self.p0 = p0
        self.p1 = p1
    }
}

extension Bezier {
    
    @inlinable
    @inline(__always)
    public init(_ bezier: LineSegment<Element>) {
        self.init(bezier.p0, bezier.p1)
    }
}

extension LineSegment: Hashable where Element: Hashable {
    
}

extension LineSegment: Decodable where Element: Decodable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(try container.decode(Element.self), try container.decode(Element.self))
    }
}

extension LineSegment: Encodable where Element: Encodable {
    
    @inlinable
    @inline(__always)
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(p0)
        try container.encode(p1)
    }
}

extension LineSegment {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Element) -> Element) -> LineSegment {
        return LineSegment(transform(p0), transform(p1))
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> Void) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, p0)
        updateAccumulatingResult(&accumulator, p1)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: LineSegment, _ transform: (Element, Element) -> Element) -> LineSegment {
        return LineSegment(transform(p0, other.p0), transform(p1, other.p1))
    }
}

extension LineSegment {
    
    public typealias Indices = Range<Int>
    
    @inlinable
    @inline(__always)
    public var startIndex: Int {
        return 0
    }
    @inlinable
    @inline(__always)
    public var endIndex: Int {
        return 2
    }
    
    @inlinable
    @inline(__always)
    public subscript(position: Int) -> Element {
        get {
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Element.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Element.self)[position] = newValue }
        }
    }
}

extension LineSegment {
    
    @inlinable
    @inline(__always)
    public var start: Element {
        return p0
    }
    
    @inlinable
    @inline(__always)
    public var end: Element {
        return p1
    }
    
    @inlinable
    @inline(__always)
    public func eval(_ t: Double) -> Element {
        return p0 + t * (p1 - p0)
    }
    
    @inlinable
    @inline(__always)
    public func split(_ t: Double) -> (LineSegment, LineSegment) {
        let q0 = p0 + t * (p1 - p0)
        return (LineSegment(p0, q0), LineSegment(q0, p1))
    }
    
    @inlinable
    @inline(__always)
    public func elevated() -> QuadBezier<Element> {
        return QuadBezier(p0, eval(0.5), p1)
    }
    
    @inlinable
    @inline(__always)
    public func derivative() -> LineSegment {
        let q = p1 - p0
        return LineSegment(q, q)
    }
}

extension LineSegment where Element == Double {
    
    @inlinable
    @inline(__always)
    public var polynomial: Polynomial {
        let a = p0
        let b = p1 - p0
        return [a, b]
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    @inline(__always)
    public func _closest(_ point: Point) -> Double {
        let a = p0 - point
        let b = p1 - p0
        let c = b.x * a.x + b.y * a.y
        let d = b.x * b.x + b.y * b.y
        return -c / d
    }
    @inlinable
    @inline(__always)
    public func distance(from point: Point) -> Double {
        let d = p1 - p0
        let m = p0.y * p1.x - p0.x * p1.y
        return abs(d.y * point.x - d.x * point.y + m) / d.magnitude
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    @inline(__always)
    public func closest(_ point: Point, in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double] {
        let a = p0 - point
        let b = p1 - p0
        return Polynomial(b.x * a.x + b.y * a.y, b.x * b.x + b.y * b.y).roots(in: range)
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    @inline(__always)
    public var area: Double {
        return 0.5 * (p0.x * p1.y - p0.y * p1.x)
    }
}

extension LineSegment where Element: Tensor {
    
    @inlinable
    @inline(__always)
    public func length(_ t: Double = 1) -> Double {
        return p0.distance(to: eval(t))
    }
    
    @inlinable
    @inline(__always)
    public func inverseLength(_ length: Double) -> Double {
        return length / p0.distance(to: p1)
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    @inline(__always)
    public var boundary: Rect {
        let minX = Swift.min(p0.x, p1.x)
        let minY = Swift.min(p0.y, p1.y)
        let maxX = Swift.max(p0.x, p1.x)
        let maxY = Swift.max(p0.y, p1.y)
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    @inline(__always)
    public func intersect(_ other: LineSegment) -> Point? {
        
        let q0 = p0 - p1
        let q1 = other.p0 - other.p1
        
        let d = q0.x * q1.y - q0.y * q1.x
        if d.almostZero() {
            return nil
        }
        let a = (p0.x * p1.y - p0.y * p1.x) / d
        let b = (other.p0.x * other.p1.y - other.p0.y * other.p1.x) / d
        return Point(x: q1.x * a - q0.x * b, y: q1.y * a - q0.y * b)
    }
}
