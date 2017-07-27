//
//  LuvColorModel.swift
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

public struct LuvColorModel : ColorModelProtocol {
    
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
    /// The u color component.
    public var u: Double
    /// The v color component.
    public var v: Double
    
    @_inlineable
    public init() {
        self.lightness = 0
        self.u = 0
        self.v = 0
    }
    @_inlineable
    public init(lightness: Double, u: Double, v: Double) {
        self.lightness = lightness
        self.u = u
        self.v = v
    }
    @_inlineable
    public init(lightness: Double, chroma: Double, hue: Double) {
        self.lightness = lightness
        self.u = chroma * cos(2 * Double.pi * hue)
        self.v = chroma * sin(2 * Double.pi * hue)
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return lightness
            case 1: return u
            case 2: return v
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: lightness = newValue
            case 1: u = newValue
            case 2: v = newValue
            default: fatalError()
            }
        }
    }
}

extension LuvColorModel : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "LuvColorModel(lightness: \(lightness), u: \(u), v: \(v))"
    }
}

extension LuvColorModel {
    
    @_inlineable
    public var hue: Double {
        get {
            return positive_mod(0.5 * atan2(v, u) / Double.pi, 1)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: chroma, hue: newValue)
        }
    }
    
    @_inlineable
    public var chroma: Double {
        get {
            return sqrt(u * u + v * v)
        }
        set {
            self = LuvColorModel(lightness: lightness, chroma: newValue, hue: hue)
        }
    }
}

@_inlineable
public prefix func +(val: LuvColorModel) -> LuvColorModel {
    return val
}
@_inlineable
public prefix func -(val: LuvColorModel) -> LuvColorModel {
    return LuvColorModel(lightness: -val.lightness, u: -val.u, v: -val.v)
}
@_inlineable
public func +(lhs: LuvColorModel, rhs: LuvColorModel) -> LuvColorModel {
    return LuvColorModel(lightness: lhs.lightness + rhs.lightness, u: lhs.u + rhs.u, v: lhs.v + rhs.v)
}
@_inlineable
public func -(lhs: LuvColorModel, rhs: LuvColorModel) -> LuvColorModel {
    return LuvColorModel(lightness: lhs.lightness - rhs.lightness, u: lhs.u - rhs.u, v: lhs.v - rhs.v)
}

@_inlineable
public func *(lhs: Double, rhs: LuvColorModel) -> LuvColorModel {
    return LuvColorModel(lightness: lhs * rhs.lightness, u: lhs * rhs.u, v: lhs * rhs.v)
}
@_inlineable
public func *(lhs: LuvColorModel, rhs: Double) -> LuvColorModel {
    return LuvColorModel(lightness: lhs.lightness * rhs, u: lhs.u * rhs, v: lhs.v * rhs)
}

@_inlineable
public func /(lhs: LuvColorModel, rhs: Double) -> LuvColorModel {
    return LuvColorModel(lightness: lhs.lightness / rhs, u: lhs.u / rhs, v: lhs.v / rhs)
}

@_inlineable
public func *= (lhs: inout LuvColorModel, rhs: Double) {
    lhs.lightness *= rhs
    lhs.u *= rhs
    lhs.v *= rhs
}
@_inlineable
public func /= (lhs: inout LuvColorModel, rhs: Double) {
    lhs.lightness /= rhs
    lhs.u /= rhs
    lhs.v /= rhs
}
@_inlineable
public func += (lhs: inout LuvColorModel, rhs: LuvColorModel) {
    lhs.lightness += rhs.lightness
    lhs.u += rhs.u
    lhs.v += rhs.v
}
@_inlineable
public func -= (lhs: inout LuvColorModel, rhs: LuvColorModel) {
    lhs.lightness -= rhs.lightness
    lhs.u -= rhs.u
    lhs.v -= rhs.v
}
@_inlineable
public func ==(lhs: LuvColorModel, rhs: LuvColorModel) -> Bool {
    return lhs.lightness == rhs.lightness && lhs.u == rhs.u && lhs.v == rhs.v
}
@_inlineable
public func !=(lhs: LuvColorModel, rhs: LuvColorModel) -> Bool {
    return lhs.lightness != rhs.lightness || lhs.u != rhs.u || lhs.v != rhs.v
}
