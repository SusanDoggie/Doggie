//
//  Polynomial.swift
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

public struct Polynomial {
    
    private var coeffs: [Double]
    
    /// a + b x + c x^2 + d x^3 + ...
    public init() {
        self.coeffs = []
    }
    
    /// a + b x + c x^2 + d x^3 + ...
    public init(_ coeffs: Double ... ) {
        self.coeffs = coeffs
        while self.coeffs.last == 0 {
            self.coeffs.removeLast()
        }
    }
    /// Construct from an arbitrary sequence of coeffs.
    /// a + b x + c x^2 + d x^3 + ...
    public init<S : Sequence where S.Iterator.Element == Double>(_ s: S) {
        self.coeffs = s.array
        while self.coeffs.last == 0 {
            self.coeffs.removeLast()
        }
    }
}

extension Polynomial : ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Double ... ) {
        self.coeffs = elements
        while self.coeffs.last == 0 {
            self.coeffs.removeLast()
        }
    }
}

extension Polynomial : CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        return coeffs.description
    }
    public var debugDescription: String {
        return coeffs.debugDescription
    }
}

extension Polynomial : RandomAccessCollection, MutableCollection {
    
    public typealias Iterator = IndexingIterator<Polynomial>
    
    public typealias Indices = CountableRange<Int>
    public typealias Index = Int
    
    public typealias SubSequence = MutableRangeReplaceableRandomAccessSlice<Polynomial>
    
    public var startIndex : Int {
        return coeffs.startIndex
    }
    public var endIndex : Int {
        return coeffs.endIndex
    }
    public var count : Int {
        return coeffs.count
    }
    
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
                coeffs.append(repeatElement(0, count: position - coeffs.count))
                coeffs.append(newValue)
            }
        }
    }
}

extension Polynomial : RangeReplaceableCollection {
    
    public mutating func append(_ x: Double) {
        if x != 0 {
            coeffs.append(x)
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        coeffs.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(_ keepingCapacity: Bool = false) {
        coeffs.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection where C.Iterator.Element == Double>(_ subRange: Range<Int>, with newElements: C) {
        coeffs.replaceSubrange(subRange, with: newElements)
        while coeffs.last == 0 {
            coeffs.removeLast()
        }
    }
}

extension Polynomial : Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, coeffs)
    }
}

extension Polynomial {
    
    public var degree : Int {
        return Swift.max(coeffs.count - 1, 0)
    }
    
    public func eval(_ x: Double) -> Double {
        switch x {
        case 0: return self[0]
        case 1: return coeffs.reduce(0, combine: +)
        default: return coeffs.reversed().reduce(0) { x * $0 + $1 }
        }
    }
}

extension Polynomial {
    
    public var roots : [Double] {
        
        if degree == 0 {
            return []
        }
        if coeffs.last!.almostZero() {
            return Polynomial(coeffs.dropLast()).roots
        }
        if coeffs.first!.almostZero() {
            let z = Polynomial(coeffs.dropFirst()).roots
            return z.contains(0) ? z : [0] + z
        }
        switch degree {
        case 1: return [-coeffs[0] / coeffs[1]]
        case 2: return degree2roots(coeffs[1] / coeffs[2], coeffs[0] / coeffs[2])
        case 3: return degree3roots(coeffs[2] / coeffs[3], coeffs[1] / coeffs[3], coeffs[0] / coeffs[3])
        case 4: return degree4roots(coeffs[3] / coeffs[4], coeffs[2] / coeffs[4], coeffs[1] / coeffs[4], coeffs[0] / coeffs[4])
        default: return _root(self / coeffs.last!)
        }
    }
}

private func _root(_ p: Polynomial) -> [Double] {
    
    var extrema = p.derivative.roots.sorted()
    
    var probe = max(extrema.last ?? 1, 1)
    while p.eval(probe) < 0 {
        probe *= 2
    }
    extrema.append(probe)
    
    probe = min(extrema.first!, -1)
    if p.coeffs.count & 1 == 0 {
        while p.eval(probe) > 0 {
            probe *= 2
        }
    } else {
        while p.eval(probe) < 0 {
            probe *= 2
        }
    }
    extrema.insert(probe, at: 0)
    
    var result = [Double]()
    
    for idx in extrema.indices.dropLast() {
        
        let left = p.eval(extrema[idx])
        let right = p.eval(extrema[idx + 1])
        
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
            
            var negVal = p.eval(neg)
            var posVal = p.eval(pos)
            var previous = extrema[idx + 1]
            
            var eps = 1e-14
            var iter = 0
            
            while true {
                var mid = (pos * negVal - neg * posVal) / (negVal - posVal)
                if 3 * abs(mid - previous) < abs(neg - pos) {
                    mid = 0.5 * (neg + pos)
                }
                let midVal = p.eval(mid)
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
    if let last = extrema.last where p.eval(last).almostZero(reference: last) {
        result.append(last)
    }
    return result
}

extension Polynomial {
    
    public var derivative : Polynomial {
        return count > 1 ? Polynomial(coeffs.enumerated().dropFirst().lazy.map { Double($0) * $1 }) : Polynomial()
    }
    
    public var integral : Polynomial {
        let _coeffs = coeffs.enumerated().lazy.map { $1 / Double($0 + 1) }
        return Polynomial(CollectionOfOne(0).concat(with: _coeffs))
    }
}

public func quorem(_ lhs: Double, _ rhs: Polynomial) -> (quo: Polynomial, rem: Polynomial) {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return ([lhs / rhs[0]], [])
    default: return ([], [lhs])
    }
}

public func quorem(_ lhs: Polynomial, _ rhs: Double) -> (quo: Polynomial, rem: Polynomial) {
    return (Polynomial(lhs.coeffs.map { $0 / rhs }), [])
}

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

public func += (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs + rhs
}

public func += (lhs: inout Polynomial, rhs: Double) {
    lhs[0] += rhs
}

public func -= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs - rhs
}

public func -= (lhs: inout Polynomial, rhs: Double) {
    lhs[0] -= rhs
}

public func *= (lhs: inout Polynomial, rhs: Double) {
    lhs = lhs * rhs
}

public func *= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs * rhs
}

public func /= (lhs: inout Polynomial, rhs: Double) {
    lhs = lhs / rhs
}

public func /= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs / rhs
}

public func %= (lhs: inout Polynomial, rhs: Double) {
    lhs = []
}

public func %= (lhs: inout Polynomial, rhs: Polynomial) {
    lhs = lhs % rhs
}

public prefix func + (p: Polynomial) -> Polynomial {
    return p
}

public prefix func - (p: Polynomial) -> Polynomial {
    return Polynomial(p.coeffs.map { -$0 })
}

public func + (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var lhs = lhs
    var buf = [Double](repeating: 0, count: max(lhs.count, rhs.count))
    for idx in buf.indices {
        buf[idx] = lhs[idx] + rhs[idx]
    }
    return Polynomial(buf)
}

public func + (lhs: Double, rhs: Polynomial) -> Polynomial {
    var rhs = rhs
    rhs[0] += lhs
    return rhs
}

public func + (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] += rhs
    return lhs
}

public func - (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var lhs = lhs
    var buf = [Double](repeating: 0, count: max(lhs.count, rhs.count))
    for idx in buf.indices {
        buf[idx] = lhs[idx] - rhs[idx]
    }
    return Polynomial(buf)
}

public func - (lhs: Double, rhs: Polynomial) -> Polynomial {
    var buf = rhs.map { -$0 }
    buf[0] += lhs
    return Polynomial(buf)
}

public func - (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] -= rhs
    return lhs
}

public func * (lhs: Double, rhs: Polynomial) -> Polynomial {
    return Polynomial(rhs.coeffs.map { lhs * $0 })
}

public func * (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 * rhs })
}

public func * (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count == 0 || rhs.count == 0 {
        return Polynomial()
    }
    var result = [Double](repeating: 0, count: lhs.count + rhs.count - 1)
    DiscreteConvolve(lhs.count, lhs.coeffs, 1, rhs.count, rhs.coeffs, 1, &result, 1)
    return Polynomial(result)
}

public func / (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return [lhs / rhs[0]]
    default: return []
    }
}

public func / (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 / rhs })
}

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

public func % (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return []
    default: return [lhs]
    }
}

public func % (lhs: Polynomial, rhs: Double) -> Polynomial {
    return []
}

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

public func == (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs == rhs.coeffs
}

public func == (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree == 0 && lhs == rhs[0]
}

public func == (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree == 0 && lhs[0] == rhs
}

public func != (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs != rhs.coeffs
}

public func != (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree != 0 || lhs != rhs[0]
}

public func != (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree != 0 || lhs[0] != rhs
}
public func gcd(_ a: Polynomial, _ b: Polynomial) -> Polynomial {
    var a = a
    var b = b
    while !b.all({ $0.almostZero() }) {
        (a, b) = (b, a % b)
    }
    return a
}
public func exgcd(_ a: Polynomial, _ b: Polynomial) -> (gcd: Polynomial, x: Polynomial, y: Polynomial) {
    var a = a
    var b = b
    var x: (Polynomial, Polynomial) = ([1], [0])
    var y: (Polynomial, Polynomial) = ([0], [1])
    while !b.all({ $0.almostZero() }) {
        let (quo, rem) = quorem(a, b)
        x = (x.1, x.0 - quo * x.1)
        y = (y.1, y.0 - quo * y.1)
        (a, b) = (b, rem)
    }
    return (a, x.0, y.0)
}
public func pow(_ p: Polynomial, _ n: Int) -> Polynomial {
    if p.count == 0 {
        return Polynomial()
    }
    let count = n * p.count - n + 1
    let _p = p.coeffs + repeatElement(0, count: (count.hibit << 1) - p.count)
    return Polynomial(Radix2PowerCircularConvolve(_p, Double(n))[0..<count])
}
