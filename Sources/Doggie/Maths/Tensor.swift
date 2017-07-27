//
//  Tensor.swift
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

public protocol Tensor : ScalarMultiplicative, RandomAccessCollection, MutableCollection where Element == Scalar, Index == Int, IndexDistance == Int {
    
    static var numberOfComponents: Int { get }
    
    init()
}

extension Tensor {
    
    @_transparent
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
    
    @_transparent
    public var count: Int {
        return Self.numberOfComponents
    }
    
    @_transparent
    public var startIndex: Int {
        return 0
    }
    
    @_transparent
    public var endIndex: Int {
        return Self.numberOfComponents
    }
}

extension Tensor {
    
    @_transparent
    public var magnitude: Scalar {
        get {
            return dot(self, self).squareRoot()
        }
        set {
            let m = self.magnitude
            if m == 0 {
                for i in 0..<Self.numberOfComponents {
                    self[i] = 0
                }
            } else {
                let scale = newValue / m
                for i in 0..<Self.numberOfComponents {
                    self[i] *= scale
                }
            }
        }
    }
    
    @_transparent
    public var unit: Self {
        let m = self.magnitude
        return m == 0 ? Self() : self / m
    }
}

extension Tensor {
    
    @_transparent
    public func distance(to: Self) -> Scalar {
        return (to - self).magnitude
    }
}

@_transparent
public func dot<T : Tensor>(_ lhs: T, _ rhs: T) -> T.Scalar {
    var result: T.Scalar = 0
    for i in 0..<T.numberOfComponents {
        result += lhs[i] * rhs[i]
    }
    return result
}

@_transparent
public prefix func +<T : Tensor>(val: T) -> T {
    return val
}
@_transparent
public prefix func -<T : Tensor>(val: T) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = -val[i]
    }
    return result
}
@_transparent
public func +<T : Tensor>(lhs: T, rhs: T) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = lhs[i] + rhs[i]
    }
    return result
}
@_transparent
public func -<T : Tensor>(lhs: T, rhs: T) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = lhs[i] - rhs[i]
    }
    return result
}

@_transparent
public func *<T : Tensor>(lhs: T.Scalar, rhs: T) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = lhs * rhs[i]
    }
    return result
}
@_transparent
public func *<T : Tensor>(lhs: T, rhs: T.Scalar) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = lhs[i] * rhs
    }
    return result
}

@_transparent
public func /<T : Tensor>(lhs: T, rhs: T.Scalar) -> T {
    var result = T()
    for i in 0..<T.numberOfComponents {
        result[i] = lhs[i] / rhs
    }
    return result
}

@_transparent
public func *=<T : Tensor> (lhs: inout T, rhs: T.Scalar) {
    for i in 0..<T.numberOfComponents {
        lhs[i] = lhs[i] * rhs
    }
}
@_transparent
public func /=<T : Tensor> (lhs: inout T, rhs: T.Scalar) {
    for i in 0..<T.numberOfComponents {
        lhs[i] = lhs[i] / rhs
    }
}
@_transparent
public func +=<T : Tensor> (lhs: inout T, rhs: T) {
    for i in 0..<T.numberOfComponents {
        lhs[i] = lhs[i] + rhs[i]
    }
}
@_transparent
public func -=<T : Tensor> (lhs: inout T, rhs: T) {
    for i in 0..<T.numberOfComponents {
        lhs[i] = lhs[i] - rhs[i]
    }
}
@_transparent
public func ==<T : Tensor>(lhs: T, rhs: T) -> Bool {
    for i in 0..<T.numberOfComponents where lhs[i] != rhs[i] {
        return false
    }
    return true
}
@_transparent
public func !=<T : Tensor>(lhs: T, rhs: T) -> Bool {
    for i in 0..<T.numberOfComponents where lhs[i] != rhs[i] {
        return true
    }
    return false
}
