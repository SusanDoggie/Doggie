//
//  Tensor.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol Tensor: MapReduceArithmetic, RandomAccessCollection, MutableCollection where Scalar: BinaryFloatingPoint, Element == Scalar, Index == Int {
    
    init()
    
    static var numberOfComponents: Int { get }
    
    var magnitude: Scalar { get set }
    
    var unit: Self { get }
    
    func distance(to: Self) -> Scalar
}

extension Tensor {
    
    @inlinable
    public static var zero: Self {
        return Self()
    }
}

extension Tensor {
    
    @inlinable
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
    
    @inlinable
    public var count: Int {
        return Self.numberOfComponents
    }
    
    @inlinable
    public var startIndex: Int {
        return 0
    }
    
    @inlinable
    public var endIndex: Int {
        return Self.numberOfComponents
    }
}

extension Tensor {
    
    @inlinable
    public var magnitude: Scalar {
        get {
            return self.reduce { fma($1, $1, $0) }?.squareRoot() ?? 0
        }
        set {
            let m = self.magnitude
            let scale = m == 0 ? 0 : newValue / m
            self *= scale
        }
    }
    
    @inlinable
    public var unit: Self {
        let m = self.magnitude
        return m == 0 ? Self() : self / m
    }
    
    @inlinable
    public func distance(to: Self) -> Scalar {
        return (to - self).magnitude
    }
}

@inlinable
public func abs<T: Tensor>(_ x: T) -> T.Scalar {
    return x.magnitude
}

@inlinable
public func dot<T: Tensor>(_ lhs: T, _ rhs: T) -> T.Scalar {
    return lhs.combined(rhs) { $0 * $1 }.reduce { $0 + $1 } ?? 0
}
