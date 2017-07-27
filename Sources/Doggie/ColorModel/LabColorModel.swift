//
//  LabColorModel.swift
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

import Foundation

public struct LabColorModel : ColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_inlineable
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_inlineable
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        switch i {
        case 0: return 0...100
        default: return -128...128
        }
    }

    /// The lightness dimension.
    public var lightness: Double
    /// The a color component.
    public var a: Double
    /// The b color component.
    public var b: Double
    
    @_inlineable
    public init() {
        self.lightness = 0
        self.a = 0
        self.b = 0
    }
    
    @_inlineable
    public init(lightness: Double, a: Double, b: Double) {
        self.lightness = lightness
        self.a = a
        self.b = b
    }
    @_inlineable
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.a = chroma * cos(2 * Double.pi * hue)
        self.b = chroma * sin(2 * Double.pi * hue)
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return lightness
            case 1: return a
            case 2: return b
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: lightness = newValue
            case 1: a = newValue
            case 2: b = newValue
            default: fatalError()
            }
        }
    }
}

extension LabColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "LabColorModel(lightness: \(lightness), a: \(a), b: \(b))"
    }
}

extension LabColorModel {
    
    @_inlineable
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(b, a) / Double.pi, 1)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @_inlineable
    public var chroma: Double {
        get {
            return sqrt(a * a + b * b)
        }
        set {
            self = LabColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

@_inlineable
public prefix func +(val: LabColorModel) -> LabColorModel {
    return val
}
@_inlineable
public prefix func -(val: LabColorModel) -> LabColorModel {
    return LabColorModel(lightness: -val.lightness, a: -val.a, b: -val.b)
}
@_inlineable
public func +(lhs: LabColorModel, rhs: LabColorModel) -> LabColorModel {
    return LabColorModel(lightness: lhs.lightness + rhs.lightness, a: lhs.a + rhs.a, b: lhs.b + rhs.b)
}
@_inlineable
public func -(lhs: LabColorModel, rhs: LabColorModel) -> LabColorModel {
    return LabColorModel(lightness: lhs.lightness - rhs.lightness, a: lhs.a - rhs.a, b: lhs.b - rhs.b)
}

@_inlineable
public func *(lhs: Double, rhs: LabColorModel) -> LabColorModel {
    return LabColorModel(lightness: lhs * rhs.lightness, a: lhs * rhs.a, b: lhs * rhs.b)
}
@_inlineable
public func *(lhs: LabColorModel, rhs: Double) -> LabColorModel {
    return LabColorModel(lightness: lhs.lightness * rhs, a: lhs.a * rhs, b: lhs.b * rhs)
}

@_inlineable
public func /(lhs: LabColorModel, rhs: Double) -> LabColorModel {
    return LabColorModel(lightness: lhs.lightness / rhs, a: lhs.a / rhs, b: lhs.b / rhs)
}

@_inlineable
public func *= (lhs: inout LabColorModel, rhs: Double) {
    lhs.lightness *= rhs
    lhs.a *= rhs
    lhs.b *= rhs
}
@_inlineable
public func /= (lhs: inout LabColorModel, rhs: Double) {
    lhs.lightness /= rhs
    lhs.a /= rhs
    lhs.b /= rhs
}
@_inlineable
public func += (lhs: inout LabColorModel, rhs: LabColorModel) {
    lhs.lightness += rhs.lightness
    lhs.a += rhs.a
    lhs.b += rhs.b
}
@_inlineable
public func -= (lhs: inout LabColorModel, rhs: LabColorModel) {
    lhs.lightness -= rhs.lightness
    lhs.a -= rhs.a
    lhs.b -= rhs.b
}
@_inlineable
public func ==(lhs: LabColorModel, rhs: LabColorModel) -> Bool {
    return lhs.lightness == rhs.lightness && lhs.a == rhs.a && lhs.b == rhs.b
}
@_inlineable
public func !=(lhs: LabColorModel, rhs: LabColorModel) -> Bool {
    return lhs.lightness != rhs.lightness || lhs.a != rhs.a || lhs.b != rhs.b
}
