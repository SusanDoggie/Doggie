//
//  Polynomial.swift
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
public struct Polynomial : Hashable {
    
    @usableFromInline
    var coeffs: [Double]
    
    /// a + b x + c x^2 + d x^3 + ...
    @inlinable
    public init() {
        self.coeffs = []
    }
    
    /// a + b x + c x^2 + d x^3 + ...
    @inlinable
    public init(_ coeffs: Double ... ) {
        self.init(coeffs)
    }
    /// Construct from an arbitrary sequence of coeffs.
    /// a + b x + c x^2 + d x^3 + ...
    @inlinable
    public init<S : Sequence>(_ s: S) where S.Element == Double {
        self.coeffs = Array(s)
        while self.coeffs.last == 0 {
            self.coeffs.removeLast()
        }
    }
}

extension Polynomial : ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: Double ... ) {
        self.init(elements)
    }
}

extension Polynomial : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return coeffs.description
    }
}

extension Polynomial : Codable {
    
    @inlinable
    public init(from decoder: Decoder) throws {
        
        var container = try decoder.unkeyedContainer()
        var coeffs: [Double] = []
        
        if let count = container.count {
            coeffs.reserveCapacity(count)
            for _ in 0..<count {
                coeffs.append(try container.decode(Double.self))
            }
        }
        
        while !container.isAtEnd {
            coeffs.append(try container.decode(Double.self))
        }
        
        self.init(coeffs)
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(coeffs)
    }
}

extension Polynomial : RandomAccessCollection, MutableCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    @inlinable
    public var startIndex : Int {
        return coeffs.startIndex
    }
    @inlinable
    public var endIndex : Int {
        return coeffs.endIndex
    }
    
    @inlinable
    public subscript(position: Int) -> Double {
        get {
            return position < coeffs.count ? coeffs[position] : 0
        }
        set {
            if position < coeffs.count {
                coeffs[position] = newValue
                while coeffs.last == 0 {
                    coeffs.removeLast()
                }
            } else if newValue != 0 {
                coeffs.append(contentsOf: repeatElement(0, count: position - coeffs.count))
                coeffs.append(newValue)
            }
        }
    }
}

extension Polynomial : RangeReplaceableCollection {
    
    @inlinable
    public mutating func append(_ newElement: Double) {
        if newElement != 0 {
            coeffs.append(newElement)
        }
    }
    
    @inlinable
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == Double {
        coeffs.append(contentsOf: newElements)
        while coeffs.last == 0 {
            coeffs.removeLast()
        }
    }
    
    @inlinable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        coeffs.reserveCapacity(minimumCapacity)
    }
    
    @inlinable
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Double {
        coeffs.replaceSubrange(subRange, with: newElements)
        while coeffs.last == 0 {
            coeffs.removeLast()
        }
    }
}

extension Polynomial {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(coeffs)
    }
}

extension Polynomial {
    
    @inlinable
    public var degree : Int {
        return Swift.max(coeffs.count - 1, 0)
    }
    
    @inlinable
    public func eval(_ x: Double) -> Double {
        switch x {
        case 0: return self[0]
        case 1: return coeffs.reduce(0, +)
        default: return coeffs.reversed().reduce(0) { x * $0 + $1 }
        }
    }
}

extension Polynomial {
    
    @inlinable
    public func roots(in range: ClosedRange<Double> = -.infinity ... .infinity) -> [Double] {
        
        if degree == 0 {
            return []
        }
        if coeffs.last!.almostZero() {
            return Polynomial(coeffs.dropLast()).roots(in: range)
        }
        if coeffs.first!.almostZero() {
            let z = Polynomial(coeffs.dropFirst()).roots(in: range)
            return range ~= 0 && z.contains(0) ? z : [0] + z
        }
        switch degree {
        case 1: return [-coeffs[0] / coeffs[1]].filter { range ~= $0 }
        case 2: return degree2roots(coeffs[1] / coeffs[2], coeffs[0] / coeffs[2]).filter { range ~= $0 }
        case 3: return degree3roots(coeffs[2] / coeffs[3], coeffs[1] / coeffs[3], coeffs[0] / coeffs[3]).filter { range ~= $0 }
        case 4: return degree4roots(coeffs[3] / coeffs[4], coeffs[2] / coeffs[4], coeffs[1] / coeffs[4], coeffs[0] / coeffs[4]).filter { range ~= $0 }
        default:
            let p = self / coeffs.last!
            return p._root(range).filter { range ~= $0 }
        }
    }
    
    @usableFromInline
    func _root(_ range: ClosedRange<Double>) -> [Double] {
        
        let _d = degree & 1
        
        let upperBound = Swift.min(range.upperBound, coeffs.dropLast().lazy.map { -$0 }.max().map { 1 + $0 } ?? 1)
        let lowerBound = Swift.max(range.lowerBound, coeffs.dropLast().enumerated().lazy.map { $0 & 1 == _d ? -$1 : $1 }.max().map { -1 - $0 } ?? -1)
        
        guard lowerBound <= upperBound else { return [] }
        
        var extrema = self.derivative.roots(in: range).sorted()
        
        extrema.append(upperBound)
        extrema.append(lowerBound)
        
        var result = [Double]()
        
        for idx in extrema.indices.dropLast() {
            
            let left = self.eval(extrema[idx])
            let right = self.eval(extrema[idx + 1])
            
            if left.almostZero(reference: extrema[idx]) {
                if !result.contains(extrema[idx]) {
                    result.append(extrema[idx])
                }
                
            } else if !right.almostZero(reference: extrema[idx + 1]) && left.sign != right.sign {
                var neg: Double
                var pos: Double
                if left > 0 {
                    neg = extrema[idx + 1]
                    pos = extrema[idx]
                } else {
                    neg = extrema[idx]
                    pos = extrema[idx + 1]
                }
                
                var negVal = self.eval(neg)
                var posVal = self.eval(pos)
                var previous = extrema[idx + 1]
                
                var eps = 1e-14
                var iter = 0
                
                while true {
                    var mid = (pos * negVal - neg * posVal) / (negVal - posVal)
                    let u = 3.0 * abs(mid - previous)
                    let v = abs(neg - pos)
                    if u < v {
                        mid = 0.5 * (neg + pos)
                    }
                    let midVal = self.eval(mid)
                    if midVal.almostZero(epsilon: eps, reference: mid) || pos.almostEqual(neg, epsilon: eps) {
                        result.append(mid)
                        break
                    }
                    previous = mid
                    if midVal.sign == .minus {
                        neg = mid
                        negVal = midVal
                    } else {
                        pos = mid
                        posVal = midVal
                    }
                    
                    iter += 1
                    if iter % 5000 == 0 {
                        eps *= 2
                    }
                }
            }
        }
        if let last = extrema.last, self.eval(last).almostZero(reference: last) {
            result.append(last)
        }
        return result
    }
}

extension Polynomial {
    
    @inlinable
    public var derivative : Polynomial {
        return count > 1 ? Polynomial(coeffs.enumerated().dropFirst().map { Double($0) * $1 }) : Polynomial()
    }
    
    @inlinable
    public var integral : Polynomial {
        let _coeffs = coeffs.enumerated().lazy.map { $1 / Double($0 + 1) }
        return Polynomial(CollectionOfOne(0).concat(_coeffs))
    }
}

extension Polynomial : Multiplicative, ScalarMultiplicative {
    
    public typealias Scalar = Double
    
    @inlinable
    public static var zero: Polynomial {
        return Polynomial()
    }
}

@inlinable
public func quorem(_ lhs: Double, _ rhs: Polynomial) -> (quo: Polynomial, rem: Polynomial) {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return ([lhs / rhs[0]], [])
    default: return ([], [lhs])
    }
}

@inlinable
public func quorem(_ lhs: Polynomial, _ rhs: Double) -> (quo: Polynomial, rem: Polynomial) {
    return (Polynomial(lhs.coeffs.map { $0 / rhs }), [])
}

@inlinable
public func quorem(_ lhs: Polynomial, _ rhs: Polynomial) -> (quo: Polynomial, rem: Polynomial) {
    if lhs.count < rhs.count {
        return ([], lhs)
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return (lhs / rhs[0], [])
    default:
        var quotient = [Double](repeating: 0, count: lhs.count - rhs.count + 1)
        var residue = [Double](repeating: 0, count: rhs.count - 1)
        Deconvolve(lhs.count, lhs.coeffs.reversed(), 1, rhs.count, rhs.coeffs.reversed(), 1, &quotient, 1, &residue, 1)
        return (Polynomial(quotient.reversed()), Polynomial(residue.reversed()))
    }
}

@inlinable
public func += (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs + rhs
}

@inlinable
public func += (lhs: inout Polynomial, rhs: Double) {
    lhs[0] += rhs
}

@inlinable
public func -= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs - rhs
}

@inlinable
public func -= (lhs: inout Polynomial, rhs: Double) {
    lhs[0] -= rhs
}

@inlinable
public func *= (lhs: inout Polynomial, rhs: Double) {
    lhs = lhs * rhs
}

@inlinable
public func *= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs * rhs
}

@inlinable
public func /= (lhs: inout Polynomial, rhs: Double) {
    lhs = lhs / rhs
}

@inlinable
public func /= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs / rhs
}

@inlinable
public func %= (lhs: inout Polynomial, rhs: Double) {
    lhs = []
}

@inlinable
public func %= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs % rhs
}

@inlinable
public prefix func + (p: Polynomial) -> Polynomial {
    return p
}

@inlinable
public prefix func - (p: Polynomial) -> Polynomial {
    return Polynomial(p.coeffs.map { -$0 })
}

@inlinable
public func + (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var buf = [Double](repeating: 0, count: max(lhs.count, rhs.count))
    for idx in buf.indices {
        buf[idx] = lhs[idx] + rhs[idx]
    }
    return Polynomial(buf)
}

@inlinable
public func + (lhs: Double, rhs: Polynomial) -> Polynomial {
    var rhs = rhs
    rhs[0] += lhs
    return rhs
}

@inlinable
public func + (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] += rhs
    return lhs
}

@inlinable
public func - (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var buf = [Double](repeating: 0, count: max(lhs.count, rhs.count))
    for idx in buf.indices {
        buf[idx] = lhs[idx] - rhs[idx]
    }
    return Polynomial(buf)
}

@inlinable
public func - (lhs: Double, rhs: Polynomial) -> Polynomial {
    var buf = rhs.map { -$0 }
    buf[0] += lhs
    return Polynomial(buf)
}

@inlinable
public func - (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] -= rhs
    return lhs
}

@inlinable
public func * (lhs: Double, rhs: Polynomial) -> Polynomial {
    return Polynomial(rhs.coeffs.map { lhs * $0 })
}

@inlinable
public func * (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 * rhs })
}

@inlinable
public func * (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count == 0 || rhs.count == 0 {
        return Polynomial()
    }
    if lhs.count == 1 {
        return lhs[0] * rhs
    }
    if rhs.count == 1 {
        return lhs * rhs[0]
    }
    var result = [Double](repeating: 0, count: lhs.count + rhs.count - 1)
    DirectConvolve(lhs.count, lhs.coeffs, 1, rhs.count, rhs.coeffs, 1, &result, 1)
    return Polynomial(result)
}

@inlinable
public func / (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return [lhs / rhs[0]]
    default: return []
    }
}

@inlinable
public func / (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 / rhs })
}

@inlinable
public func / (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count < rhs.count {
        return []
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return lhs / rhs[0]
    default:
        var result = [Double](repeating: 0, count: lhs.count - rhs.count + 1)
        Deconvolve(lhs.count, lhs.coeffs.reversed(), 1, rhs.count, rhs.coeffs.reversed(), 1, &result, 1)
        return Polynomial(result.reversed())
    }
}

@inlinable
public func % (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return []
    default: return [lhs]
    }
}

@inlinable
public func % (lhs: Polynomial, rhs: Double) -> Polynomial {
    return []
}

@inlinable
public func % (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count < rhs.count {
        return lhs
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return []
    default:
        var quotient = [Double](repeating: 0, count: lhs.count - rhs.count + 1)
        var result = [Double](repeating: 0, count: rhs.count - 1)
        Deconvolve(lhs.count, lhs.coeffs.reversed(), 1, rhs.count, rhs.coeffs.reversed(), 1, &quotient, 1, &result, 1)
        return Polynomial(result.reversed())
    }
}

@inlinable
public func == (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs == rhs.coeffs
}

@inlinable
public func == (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree == 0 && lhs == rhs[0]
}

@inlinable
public func == (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree == 0 && lhs[0] == rhs
}

@inlinable
public func != (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs != rhs.coeffs
}

@inlinable
public func != (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree != 0 || lhs != rhs[0]
}

@inlinable
public func != (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree != 0 || lhs[0] != rhs
}
@inlinable
public func gcd(_ a: Polynomial, _ b: Polynomial) -> Polynomial {
    var a = a
    var b = b
    while !b.allSatisfy({ $0.almostZero() }) {
        (a, b) = (b, a % b)
    }
    return a
}
@inlinable
public func exgcd(_ a: Polynomial, _ b: Polynomial) -> (gcd: Polynomial, x: Polynomial, y: Polynomial) {
    var a = a
    var b = b
    var x: (Polynomial, Polynomial) = ([1], [0])
    var y: (Polynomial, Polynomial) = ([0], [1])
    while !b.allSatisfy({ $0.almostZero() }) {
        let (quo, rem) = quorem(a, b)
        x = (x.1, x.0 - quo * x.1)
        y = (y.1, y.0 - quo * y.1)
        (a, b) = (b, rem)
    }
    return (a, x.0, y.0)
}
@inlinable
public func pow(_ p: Polynomial, _ n: Int) -> Polynomial {
    if p.count == 0 {
        return Polynomial()
    }
    let count = n * p.count - n + 1
    let _p = p.coeffs + repeatElement(0, count: (count.hibit << 1) - p.count)
    return Polynomial(Radix2PowerCircularConvolve(_p, Double(n))[0..<count])
}
