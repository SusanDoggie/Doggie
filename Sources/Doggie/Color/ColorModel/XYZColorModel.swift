//
//  XYZColorModel.swift
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

public struct XYZColorModel : ColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    public var x: Double
    public var y: Double
    public var z: Double
    
    @_inlineable
    public init() {
        self.x = 0
        self.y = 0
        self.z = 0
    }
    
    @_inlineable
    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    @_inlineable
    public init(luminance: Double, point: Point) {
        self.init(luminance: luminance, x: point.x, y: point.y)
    }
    
    @_inlineable
    public init(luminance: Double, x: Double, y: Double) {
        let _y = 1 / y
        self.x = x * _y * luminance
        self.y = luminance
        self.z = (1 - x - y) * _y * luminance
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return x
        case 1: return y
        case 2: return z
        default: fatalError()
        }
    }
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: x = value
        case 1: y = value
        case 2: z = value
        default: fatalError()
        }
    }
}

extension XYZColorModel {
    
    @_inlineable
    public var luminance: Double {
        get {
            return y
        }
        set {
            self = XYZColorModel(luminance: newValue, point: point)
        }
    }
    
    @_inlineable
    public var point: Point {
        get {
            return Point(x: x, y: y) / (x + y + z)
        }
        set {
            self = XYZColorModel(luminance: luminance, point: newValue)
        }
    }
}

extension XYZColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "XYZColorModel(x: \(x), y: \(y), z: \(z))"
    }
}

@_inlineable
public func * (lhs: XYZColorModel, rhs: Matrix) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs.a + lhs.y * rhs.b + lhs.z * rhs.c + rhs.d, y: lhs.x * rhs.e + lhs.y * rhs.f + lhs.z * rhs.g + rhs.h, z: lhs.x * rhs.i + lhs.y * rhs.j + lhs.z * rhs.k + rhs.l)
}
@_inlineable
public func *= (lhs: inout XYZColorModel, rhs: Matrix) {
    lhs = lhs * rhs
}
