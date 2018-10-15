//
//  LineSegment.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct LineSegment<Element : ScalarMultiplicative> : Equatable, BezierProtocol where Element.Scalar == Double {
    
    public typealias Scalar = Double
    
    public var p0: Element
    public var p1: Element
    
    @inlinable
    @inline(__always)
    public init() {
        self.p0 = Element()
        self.p1 = Element()
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
    public init(_ bezier: LineSegment<Element>) {
        self.init(bezier.p0, bezier.p1)
    }
}

extension LineSegment: Decodable where Element : Decodable {
    
    @inlinable
    @inline(__always)
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init(try container.decode(Element.self), try container.decode(Element.self))
    }
}

extension LineSegment: Encodable where Element : Encodable {
    
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, p0)
        updateAccumulatingResult(&accumulator, p1)
        return accumulator
    }
}

extension LineSegment {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    @_transparent
    public var startIndex: Int {
        return 0
    }
    @_transparent
    public var endIndex: Int {
        return 2
    }
    
    @inlinable
    public subscript(position: Int) -> Element {
        get {
            switch position {
            case 0: return p0
            case 1: return p1
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: p0 = newValue
            case 1: p1 = newValue
            default: fatalError()
            }
        }
    }
}

extension LineSegment {
    
    @inlinable
    @inline(__always)
    public func eval(_ t: Double) -> Element {
        return p0 + t * (p1 - p0)
    }
}

extension LineSegment where Element == Double {
    
    @inlinable
    public var polynomial: Polynomial {
        let a = p0
        let b = p1 - p0
        return [a, b]
    }
}

extension LineSegment {
    
    @inlinable
    @inline(__always)
    public func elevated() -> QuadBezier<Element> {
        return QuadBezier(p0, eval(0.5), p1)
    }
}

extension LineSegment {
    
    @inlinable
    @inline(__always)
    public func split(_ t: Double) -> (LineSegment, LineSegment) {
        let q0 = p0 + t * (p1 - p0)
        return (LineSegment(p0, q0), LineSegment(q0, p1))
    }
}

extension LineSegment where Element == Point {
    
    @inlinable
    public func closest(_ point: Point) -> [Double] {
        let a = p0 - point
        let b = p1 - p0
        return Polynomial(b.x * a.x + b.y * a.y, b.x * b.x + b.y * b.y).roots
    }
}

extension LineSegment where Element == Point {
    
    @_transparent
    public var area: Double {
        return 0.5 * (p0.x * p1.y - p0.y * p1.x)
    }
}

extension LineSegment where Element: Tensor {
    
    @inlinable
    @inline(__always)
    public func length(_ t: Double) -> Double {
        return p0.distance(to: eval(t))
    }
}

extension LineSegment where Element == Point {
    
    @_transparent
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

@inlinable
@inline(__always)
public func + <Element>(lhs: LineSegment<Element>, rhs: LineSegment<Element>) -> LineSegment<Element> {
    return LineSegment(lhs.p0 + rhs.p0, lhs.p1 + rhs.p1)
}
@inlinable
@inline(__always)
public func - <Element>(lhs: LineSegment<Element>, rhs: LineSegment<Element>) -> LineSegment<Element> {
    return LineSegment(lhs.p0 - rhs.p0, lhs.p1 - rhs.p1)
}
