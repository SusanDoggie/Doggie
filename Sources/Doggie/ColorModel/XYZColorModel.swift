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
    
    public typealias Scalar = Double
    
    @_inlineable
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_inlineable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        switch i {
        case 1: return 0...1
        default: return 0...2
        }
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
        if y == 0 {
            self.x = 0
            self.y = 0
            self.z = 0
        } else {
            let _y = 1 / y
            self.x = x * _y * luminance
            self.y = luminance
            self.z = (1 - x - y) * _y * luminance
        }
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return x
            case 1: return y
            case 2: return z
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: x = newValue
            case 1: y = newValue
            case 2: z = newValue
            default: fatalError()
            }
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

@_inlineable
public prefix func +(val: XYZColorModel) -> XYZColorModel {
    return val
}
@_inlineable
public prefix func -(val: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: -val.x, y: -val.y, z: -val.z)
}
@_inlineable
public func +(lhs: XYZColorModel, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
}
@_inlineable
public func -(lhs: XYZColorModel, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
}

@_inlineable
public func *(lhs: Double, rhs: XYZColorModel) -> XYZColorModel {
    return XYZColorModel(x: lhs * rhs.x, y: lhs * rhs.y, z: lhs * rhs.z)
}
@_inlineable
public func *(lhs: XYZColorModel, rhs: Double) -> XYZColorModel {
    return XYZColorModel(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
}

@_inlineable
public func /(lhs: XYZColorModel, rhs: Double) -> XYZColorModel {
    return XYZColorModel(x: lhs.x / rhs, y: lhs.y / rhs, z: lhs.z / rhs)
}

@_inlineable
public func *= (lhs: inout XYZColorModel, rhs: Double) {
    lhs.x *= rhs
    lhs.y *= rhs
    lhs.z *= rhs
}
@_inlineable
public func /= (lhs: inout XYZColorModel, rhs: Double) {
    lhs.x /= rhs
    lhs.y /= rhs
    lhs.z /= rhs
}
@_inlineable
public func += (lhs: inout XYZColorModel, rhs: XYZColorModel) {
    lhs.x += rhs.x
    lhs.y += rhs.y
    lhs.z += rhs.z
}
@_inlineable
public func -= (lhs: inout XYZColorModel, rhs: XYZColorModel) {
    lhs.x -= rhs.x
    lhs.y -= rhs.y
    lhs.z -= rhs.z
}
@_inlineable
public func ==(lhs: XYZColorModel, rhs: XYZColorModel) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}
@_inlineable
public func !=(lhs: XYZColorModel, rhs: XYZColorModel) -> Bool {
    return lhs.x != rhs.x || lhs.y != rhs.y || lhs.z != rhs.z
}
