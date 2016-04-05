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

import Foundation

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
    public init<S : SequenceType where S.Generator.Element == Double>(_ s: S) {
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

extension Polynomial : MutableCollectionType {
    
    public typealias Generator = IndexingGenerator<Polynomial>
    
    public var startIndex : Int {
        return coeffs.startIndex
    }
    public var endIndex : Int {
        return coeffs.endIndex
    }
    public var count : Int {
        return coeffs.count
    }
    public subscript(n: Int) -> Double {
        get {
            return n < coeffs.count ? coeffs[n] : 0
        }
        set {
            if n < coeffs.count {
                coeffs[n] = newValue
                while coeffs.last == 0 {
                    coeffs.removeLast()
                }
            } else if newValue != 0 {
                coeffs.appendContentsOf(Repeat(count: n - coeffs.count, repeatedValue: 0))
                coeffs.append(newValue)
            }
        }
    }
}

extension Polynomial : Hashable {
    
    public var hashValue: Int {
        return hash_combine(0, coeffs)
    }
}

extension Polynomial {
    
    public var degree : Int {
        return max(coeffs.count - 1, 0)
    }
    
    @warn_unused_result
    public func eval(x: Double) -> Double {
        switch x {
        case 0: return self[0]
        case 1: return coeffs.reduce(0, combine: +)
        default: return coeffs.reverse().reduce(0) { x * $0 + $1 }
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

private func _root(p: Polynomial) -> [Double] {
    
    var extrema = p.derivative.roots.sort()
    
    var probe = max(extrema.last ?? 1, 1)
    while p.eval(probe) < 0 {
        probe *= 2
    }
    extrema.append(probe)
    
    probe = min(extrema.first!, -1)
    if p.coeffs.count % 2 == 0 {
        while p.eval(probe) > 0 {
            probe *= 2
        }
    } else {
        while p.eval(probe) < 0 {
            probe *= 2
        }
    }
    extrema.insert(probe, atIndex: 0)
    
    var result = [Double]()
    
    for idx in extrema.indices.dropLast() {
        
        let left = p.eval(extrema[idx])
        let right = p.eval(extrema[idx + 1])
        
        if left.almostZero(reference: extrema[idx]) {
            if !result.contains(extrema[idx]) {
                result.append(extrema[idx])
            }
            
        } else if !right.almostZero(reference: extrema[idx + 1]) && left.isSignMinus != right.isSignMinus {
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
                if midVal.almostZero(eps, reference: mid) || pos.almostEqual(neg, epsilon: eps) {
                    result.append(mid)
                    break
                }
                previous = mid
                if midVal.isSignMinus {
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
        return count > 1 ? Polynomial(coeffs.enumerate().dropFirst().lazy.map { Double($0) * $1 }) : Polynomial()
    }
    
    public var integral : Polynomial {
        let _coeffs = coeffs.enumerate().lazy.map { $1 / Double($0 + 1) }
        return Polynomial(CollectionOfOne(0).concat(_coeffs))
    }
}

@warn_unused_result
public func remquo(lhs: Double, _ rhs: Polynomial) -> (quo: Polynomial, rem: Polynomial) {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return ([lhs / rhs[0]], [])
    default: return ([], [lhs])
    }
}

@warn_unused_result
public func remquo(lhs: Polynomial, _ rhs: Double) -> (quo: Polynomial, rem: Polynomial) {
    return (Polynomial(lhs.coeffs.map { $0 / rhs }), [])
}

@warn_unused_result
public func remquo(lhs: Polynomial, _ rhs: Polynomial) -> (quo: Polynomial, rem: Polynomial) {
    if lhs.count < rhs.count {
        return ([], lhs)
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return (lhs / rhs[0], [])
    default:
        var quotient = [Double](count: lhs.count - rhs.count + 1, repeatedValue: 0)
        var residue = [Double](count: rhs.count - 1, repeatedValue: 0)
        Deconvolve(lhs.count, lhs.coeffs.reverse(), 1, rhs.count, rhs.coeffs.reverse(), 1, &quotient, 1, &residue, 1)
        return (Polynomial(quotient.reverse()), Polynomial(residue.reverse()))
    }
}

public func += (inout lhs: Polynomial, rhs: Polynomial) {
    lhs = lhs + rhs
}

public func += (inout lhs: Polynomial, rhs: Double) {
    lhs[0] += rhs
}

public func -= (inout lhs: Polynomial, rhs: Polynomial) {
    lhs = lhs - rhs
}

public func -= (inout lhs: Polynomial, rhs: Double) {
    lhs[0] -= rhs
}

public func *= (inout lhs: Polynomial, rhs: Double) {
    lhs = lhs * rhs
}

public func *= (inout lhs: Polynomial, rhs: Polynomial) {
    lhs = lhs * rhs
}

public func /= (inout lhs: Polynomial, rhs: Double) {
    lhs = lhs / rhs
}

public func /= (inout lhs: Polynomial, rhs: Polynomial) {
    lhs = lhs / rhs
}

public func %= (inout lhs: Polynomial, rhs: Double) {
    lhs = []
}

public func %= (inout lhs: Polynomial, rhs: Polynomial) {
    lhs = lhs % rhs
}

@warn_unused_result
public prefix func + (p: Polynomial) -> Polynomial {
    return p
}

@warn_unused_result
public prefix func - (p: Polynomial) -> Polynomial {
    return Polynomial(p.coeffs.map { -$0 })
}

@warn_unused_result
public func + (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var lhs = lhs
    var buf = [Double](count: max(lhs.count, rhs.count), repeatedValue: 0)
    for idx in buf.indices {
        buf[idx] = lhs[idx] + rhs[idx]
    }
    return Polynomial(buf)
}

@warn_unused_result
public func + (lhs: Double, rhs: Polynomial) -> Polynomial {
    var rhs = rhs
    rhs[0] += lhs
    return rhs
}

@warn_unused_result
public func + (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] += rhs
    return lhs
}

@warn_unused_result
public func - (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    var lhs = lhs
    var buf = [Double](count: max(lhs.count, rhs.count), repeatedValue: 0)
    for idx in buf.indices {
        buf[idx] = lhs[idx] - rhs[idx]
    }
    return Polynomial(buf)
}

@warn_unused_result
public func - (lhs: Double, rhs: Polynomial) -> Polynomial {
    var buf = rhs.map { -$0 }
    buf[0] += lhs
    return Polynomial(buf)
}

@warn_unused_result
public func - (lhs: Polynomial, rhs: Double) -> Polynomial {
    var lhs = lhs
    lhs[0] -= rhs
    return lhs
}

@warn_unused_result
public func * (lhs: Double, rhs: Polynomial) -> Polynomial {
    return Polynomial(rhs.coeffs.map { lhs * $0 })
}

@warn_unused_result
public func * (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 * rhs })
}

@warn_unused_result
public func * (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count == 0 || rhs.count == 0 {
        return Polynomial()
    }
    var result = [Double](count: lhs.count + rhs.count - 1, repeatedValue: 0)
    DiscreteConvolve(lhs.count, lhs.coeffs, 1, rhs.count, rhs.coeffs, 1, &result, 1)
    return Polynomial(result)
}

@warn_unused_result
public func / (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return [lhs / rhs[0]]
    default: return []
    }
}

@warn_unused_result
public func / (lhs: Polynomial, rhs: Double) -> Polynomial {
    return Polynomial(lhs.coeffs.map { $0 / rhs })
}

@warn_unused_result
public func / (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count < rhs.count {
        return []
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return lhs / rhs[0]
    default:
        var result = [Double](count: lhs.count - rhs.count + 1, repeatedValue: 0)
        Deconvolve(lhs.count, lhs.coeffs.reverse(), 1, rhs.count, rhs.coeffs.reverse(), 1, &result, 1)
        return Polynomial(result.reverse())
    }
}

@warn_unused_result
public func % (lhs: Double, rhs: Polynomial) -> Polynomial {
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return []
    default: return [lhs]
    }
}

@warn_unused_result
public func % (lhs: Polynomial, rhs: Double) -> Polynomial {
    return []
}

@warn_unused_result
public func % (lhs: Polynomial, rhs: Polynomial) -> Polynomial {
    if lhs.count < rhs.count {
        return lhs
    }
    switch rhs.count {
    case 0: fatalError("Divide by zero.")
    case 1: return []
    default:
        var quotient = [Double](count: lhs.count - rhs.count + 1, repeatedValue: 0)
        var result = [Double](count: rhs.count - 1, repeatedValue: 0)
        Deconvolve(lhs.count, lhs.coeffs.reverse(), 1, rhs.count, rhs.coeffs.reverse(), 1, &quotient, 1, &result, 1)
        return Polynomial(result.reverse())
    }
}

@warn_unused_result
public func == (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs == rhs.coeffs
}

@warn_unused_result
public func == (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree == 0 && lhs == rhs[0]
}

@warn_unused_result
public func == (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree == 0 && lhs[0] == rhs
}

@warn_unused_result
public func != (lhs: Polynomial, rhs: Polynomial) -> Bool {
    return lhs.coeffs != rhs.coeffs
}

@warn_unused_result
public func != (lhs: Double, rhs: Polynomial) -> Bool {
    return rhs.degree != 0 || lhs != rhs[0]
}

@warn_unused_result
public func != (lhs: Polynomial, rhs: Double) -> Bool {
    return lhs.degree != 0 || lhs[0] != rhs
}
@warn_unused_result
public func gcd(a: Polynomial, _ b: Polynomial) -> Polynomial {
    var a = a
    var b = b
    while !b.all({ $0.almostZero() }) {
        (a, b) = (b, a % b)
    }
    return a
}
@warn_unused_result
public func exgcd(a: Polynomial, _ b: Polynomial) -> (gcd: Polynomial, x: Polynomial, y: Polynomial) {
    var a = a
    var b = b
    var x: (Polynomial, Polynomial) = ([1], [0])
    var y: (Polynomial, Polynomial) = ([0], [1])
    while !b.all({ $0.almostZero() }) {
        let (quo, rem) = remquo(a, b)
        x = (x.1, x.0 - quo * x.1)
        y = (y.1, y.0 - quo * y.1)
        (a, b) = (b, rem)
    }
    return (a, x.0, y.0)
}
@warn_unused_result
public func pow(p: Polynomial, _ n: Int) -> Polynomial {
    if p.count == 0 {
        return Polynomial()
    }
    let count = n * p.count - n + 1
    let _p = p.coeffs + Repeat(count: (count.hibit << 1) - p.count, repeatedValue: 0)
    return Polynomial(Radix2PowerCircularConvolve(_p, Double(n))[0..<count])
}
