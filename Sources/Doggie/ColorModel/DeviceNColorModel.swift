//
//  DeviceNColorModel.swift
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

public protocol DeviceNColorModelProtocol : ColorModelProtocol {
    
}

public struct Device2ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 2
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device2ColorModel {
    
    @_transparent
    public func blended(source: Device2ColorModel, blending: (Double, Double) -> Double) -> Device2ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        return Device2ColorModel(component_0, component_1)
    }
}

@_transparent
public prefix func +(val: Device2ColorModel) -> Device2ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device2ColorModel) -> Device2ColorModel {
    return Device2ColorModel(-val.component_0, -val.component_1)
}
@_transparent
public func +(lhs: Device2ColorModel, rhs: Device2ColorModel) -> Device2ColorModel {
    return Device2ColorModel(lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1)
}
@_transparent
public func -(lhs: Device2ColorModel, rhs: Device2ColorModel) -> Device2ColorModel {
    return Device2ColorModel(lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1)
}

@_transparent
public func *(lhs: Double, rhs: Device2ColorModel) -> Device2ColorModel {
    return Device2ColorModel(lhs * rhs.component_0, lhs * rhs.component_1)
}
@_transparent
public func *(lhs: Device2ColorModel, rhs: Double) -> Device2ColorModel {
    return Device2ColorModel(lhs.component_0 * rhs, lhs.component_1 * rhs)
}

@_transparent
public func /(lhs: Device2ColorModel, rhs: Double) -> Device2ColorModel {
    return Device2ColorModel(lhs.component_0 / rhs, lhs.component_1 / rhs)
}

@_transparent
public func *= (lhs: inout Device2ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
}
@_transparent
public func /= (lhs: inout Device2ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
}
@_transparent
public func += (lhs: inout Device2ColorModel, rhs: Device2ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
}
@_transparent
public func -= (lhs: inout Device2ColorModel, rhs: Device2ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
}
@_transparent
public func ==(lhs: Device2ColorModel, rhs: Device2ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1
}
@_transparent
public func !=(lhs: Device2ColorModel, rhs: Device2ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1
}


public struct Device3ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device3ColorModel {
    
    @_transparent
    public func blended(source: Device3ColorModel, blending: (Double, Double) -> Double) -> Device3ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        return Device3ColorModel(component_0, component_1, component_2)
    }
}

@_transparent
public prefix func +(val: Device3ColorModel) -> Device3ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device3ColorModel) -> Device3ColorModel {
    return Device3ColorModel(-val.component_0, -val.component_1, -val.component_2)
}
@_transparent
public func +(lhs: Device3ColorModel, rhs: Device3ColorModel) -> Device3ColorModel {
    return Device3ColorModel(lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2)
}
@_transparent
public func -(lhs: Device3ColorModel, rhs: Device3ColorModel) -> Device3ColorModel {
    return Device3ColorModel(lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2)
}

@_transparent
public func *(lhs: Double, rhs: Device3ColorModel) -> Device3ColorModel {
    return Device3ColorModel(lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2)
}
@_transparent
public func *(lhs: Device3ColorModel, rhs: Double) -> Device3ColorModel {
    return Device3ColorModel(lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs)
}

@_transparent
public func /(lhs: Device3ColorModel, rhs: Double) -> Device3ColorModel {
    return Device3ColorModel(lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs)
}

@_transparent
public func *= (lhs: inout Device3ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
}
@_transparent
public func /= (lhs: inout Device3ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
}
@_transparent
public func += (lhs: inout Device3ColorModel, rhs: Device3ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
}
@_transparent
public func -= (lhs: inout Device3ColorModel, rhs: Device3ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
}
@_transparent
public func ==(lhs: Device3ColorModel, rhs: Device3ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
}
@_transparent
public func !=(lhs: Device3ColorModel, rhs: Device3ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
}


public struct Device4ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 4
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double, _ component_3: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device4ColorModel {
    
    @_transparent
    public func blended(source: Device4ColorModel, blending: (Double, Double) -> Double) -> Device4ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        return Device4ColorModel(component_0, component_1, component_2, component_3)
    }
}

@_transparent
public prefix func +(val: Device4ColorModel) -> Device4ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device4ColorModel) -> Device4ColorModel {
    return Device4ColorModel(-val.component_0, -val.component_1, -val.component_2, -val.component_3)
}
@_transparent
public func +(lhs: Device4ColorModel, rhs: Device4ColorModel) -> Device4ColorModel {
    return Device4ColorModel(lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2, lhs.component_3 + rhs.component_3)
}
@_transparent
public func -(lhs: Device4ColorModel, rhs: Device4ColorModel) -> Device4ColorModel {
    return Device4ColorModel(lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2, lhs.component_3 - rhs.component_3)
}

@_transparent
public func *(lhs: Double, rhs: Device4ColorModel) -> Device4ColorModel {
    return Device4ColorModel(lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2, lhs * rhs.component_3)
}
@_transparent
public func *(lhs: Device4ColorModel, rhs: Double) -> Device4ColorModel {
    return Device4ColorModel(lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs, lhs.component_3 * rhs)
}

@_transparent
public func /(lhs: Device4ColorModel, rhs: Double) -> Device4ColorModel {
    return Device4ColorModel(lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs, lhs.component_3 / rhs)
}

@_transparent
public func *= (lhs: inout Device4ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
}
@_transparent
public func /= (lhs: inout Device4ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
}
@_transparent
public func += (lhs: inout Device4ColorModel, rhs: Device4ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
}
@_transparent
public func -= (lhs: inout Device4ColorModel, rhs: Device4ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
}
@_transparent
public func ==(lhs: Device4ColorModel, rhs: Device4ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2 && lhs.component_3 == rhs.component_3
}
@_transparent
public func !=(lhs: Device4ColorModel, rhs: Device4ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2 || lhs.component_3 != rhs.component_3
}


public struct Device5ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 5
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device5ColorModel {
    
    @_transparent
    public func blended(source: Device5ColorModel, blending: (Double, Double) -> Double) -> Device5ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        return Device5ColorModel(
            component_0, component_1, component_2,
            component_3, component_4
        )
    }
}

@_transparent
public prefix func +(val: Device5ColorModel) -> Device5ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device5ColorModel) -> Device5ColorModel {
    return Device5ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4
    )
}
@_transparent
public func +(lhs: Device5ColorModel, rhs: Device5ColorModel) -> Device5ColorModel {
    return Device5ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4
    )
}
@_transparent
public func -(lhs: Device5ColorModel, rhs: Device5ColorModel) -> Device5ColorModel {
    return Device5ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4
    )
}

@_transparent
public func *(lhs: Double, rhs: Device5ColorModel) -> Device5ColorModel {
    return Device5ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4
    )
}
@_transparent
public func *(lhs: Device5ColorModel, rhs: Double) -> Device5ColorModel {
    return Device5ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs
    )
}

@_transparent
public func /(lhs: Device5ColorModel, rhs: Double) -> Device5ColorModel {
    return Device5ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device5ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
}
@_transparent
public func /= (lhs: inout Device5ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
}
@_transparent
public func += (lhs: inout Device5ColorModel, rhs: Device5ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
}
@_transparent
public func -= (lhs: inout Device5ColorModel, rhs: Device5ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
}
@_transparent
public func ==(lhs: Device5ColorModel, rhs: Device5ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4
}
@_transparent
public func !=(lhs: Device5ColorModel, rhs: Device5ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4
}


public struct Device6ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 6
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device6ColorModel {
    
    @_transparent
    public func blended(source: Device6ColorModel, blending: (Double, Double) -> Double) -> Device6ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        return Device6ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5
        )
    }
}

@_transparent
public prefix func +(val: Device6ColorModel) -> Device6ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device6ColorModel) -> Device6ColorModel {
    return Device6ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5
    )
}
@_transparent
public func +(lhs: Device6ColorModel, rhs: Device6ColorModel) -> Device6ColorModel {
    return Device6ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5
    )
}
@_transparent
public func -(lhs: Device6ColorModel, rhs: Device6ColorModel) -> Device6ColorModel {
    return Device6ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5
    )
}

@_transparent
public func *(lhs: Double, rhs: Device6ColorModel) -> Device6ColorModel {
    return Device6ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5
    )
}
@_transparent
public func *(lhs: Device6ColorModel, rhs: Double) -> Device6ColorModel {
    return Device6ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs
    )
}

@_transparent
public func /(lhs: Device6ColorModel, rhs: Double) -> Device6ColorModel {
    return Device6ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device6ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
}
@_transparent
public func /= (lhs: inout Device6ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
}
@_transparent
public func += (lhs: inout Device6ColorModel, rhs: Device6ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
}
@_transparent
public func -= (lhs: inout Device6ColorModel, rhs: Device6ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
}
@_transparent
public func ==(lhs: Device6ColorModel, rhs: Device6ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
}
@_transparent
public func !=(lhs: Device6ColorModel, rhs: Device6ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
}


public struct Device7ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 7
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device7ColorModel {
    
    @_transparent
    public func blended(source: Device7ColorModel, blending: (Double, Double) -> Double) -> Device7ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        return Device7ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6
        )
    }
}

@_transparent
public prefix func +(val: Device7ColorModel) -> Device7ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device7ColorModel) -> Device7ColorModel {
    return Device7ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6
    )
}
@_transparent
public func +(lhs: Device7ColorModel, rhs: Device7ColorModel) -> Device7ColorModel {
    return Device7ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6
    )
}
@_transparent
public func -(lhs: Device7ColorModel, rhs: Device7ColorModel) -> Device7ColorModel {
    return Device7ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6
    )
}

@_transparent
public func *(lhs: Double, rhs: Device7ColorModel) -> Device7ColorModel {
    return Device7ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6
    )
}
@_transparent
public func *(lhs: Device7ColorModel, rhs: Double) -> Device7ColorModel {
    return Device7ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs
    )
}

@_transparent
public func /(lhs: Device7ColorModel, rhs: Double) -> Device7ColorModel {
    return Device7ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device7ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
}
@_transparent
public func /= (lhs: inout Device7ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
}
@_transparent
public func += (lhs: inout Device7ColorModel, rhs: Device7ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
}
@_transparent
public func -= (lhs: inout Device7ColorModel, rhs: Device7ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
}
@_transparent
public func ==(lhs: Device7ColorModel, rhs: Device7ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6
}
@_transparent
public func !=(lhs: Device7ColorModel, rhs: Device7ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6
}


public struct Device8ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 8
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device8ColorModel {
    
    @_transparent
    public func blended(source: Device8ColorModel, blending: (Double, Double) -> Double) -> Device8ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        return Device8ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7
        )
    }
}

@_transparent
public prefix func +(val: Device8ColorModel) -> Device8ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device8ColorModel) -> Device8ColorModel {
    return Device8ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7
    )
}
@_transparent
public func +(lhs: Device8ColorModel, rhs: Device8ColorModel) -> Device8ColorModel {
    return Device8ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7
    )
}
@_transparent
public func -(lhs: Device8ColorModel, rhs: Device8ColorModel) -> Device8ColorModel {
    return Device8ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7
    )
}

@_transparent
public func *(lhs: Double, rhs: Device8ColorModel) -> Device8ColorModel {
    return Device8ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7
    )
}
@_transparent
public func *(lhs: Device8ColorModel, rhs: Double) -> Device8ColorModel {
    return Device8ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs
    )
}

@_transparent
public func /(lhs: Device8ColorModel, rhs: Double) -> Device8ColorModel {
    return Device8ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device8ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
}
@_transparent
public func /= (lhs: inout Device8ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
}
@_transparent
public func += (lhs: inout Device8ColorModel, rhs: Device8ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
}
@_transparent
public func -= (lhs: inout Device8ColorModel, rhs: Device8ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
}
@_transparent
public func ==(lhs: Device8ColorModel, rhs: Device8ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7
}
@_transparent
public func !=(lhs: Device8ColorModel, rhs: Device8ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7
}


public struct Device9ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 9
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device9ColorModel {
    
    @_transparent
    public func blended(source: Device9ColorModel, blending: (Double, Double) -> Double) -> Device9ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        return Device9ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8
        )
    }
}

@_transparent
public prefix func +(val: Device9ColorModel) -> Device9ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device9ColorModel) -> Device9ColorModel {
    return Device9ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8
    )
}
@_transparent
public func +(lhs: Device9ColorModel, rhs: Device9ColorModel) -> Device9ColorModel {
    return Device9ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8
    )
}
@_transparent
public func -(lhs: Device9ColorModel, rhs: Device9ColorModel) -> Device9ColorModel {
    return Device9ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8
    )
}

@_transparent
public func *(lhs: Double, rhs: Device9ColorModel) -> Device9ColorModel {
    return Device9ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8
    )
}
@_transparent
public func *(lhs: Device9ColorModel, rhs: Double) -> Device9ColorModel {
    return Device9ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs
    )
}

@_transparent
public func /(lhs: Device9ColorModel, rhs: Double) -> Device9ColorModel {
    return Device9ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device9ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
}
@_transparent
public func /= (lhs: inout Device9ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
}
@_transparent
public func += (lhs: inout Device9ColorModel, rhs: Device9ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
}
@_transparent
public func -= (lhs: inout Device9ColorModel, rhs: Device9ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
}
@_transparent
public func ==(lhs: Device9ColorModel, rhs: Device9ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
}
@_transparent
public func !=(lhs: Device9ColorModel, rhs: Device9ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
}


public struct Device10ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 10
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device10ColorModel {
    
    @_transparent
    public func blended(source: Device10ColorModel, blending: (Double, Double) -> Double) -> Device10ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        return Device10ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9
        )
    }
}

@_transparent
public prefix func +(val: Device10ColorModel) -> Device10ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device10ColorModel) -> Device10ColorModel {
    return Device10ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9
    )
}
@_transparent
public func +(lhs: Device10ColorModel, rhs: Device10ColorModel) -> Device10ColorModel {
    return Device10ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9
    )
}
@_transparent
public func -(lhs: Device10ColorModel, rhs: Device10ColorModel) -> Device10ColorModel {
    return Device10ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9
    )
}

@_transparent
public func *(lhs: Double, rhs: Device10ColorModel) -> Device10ColorModel {
    return Device10ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9
    )
}
@_transparent
public func *(lhs: Device10ColorModel, rhs: Double) -> Device10ColorModel {
    return Device10ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs
    )
}

@_transparent
public func /(lhs: Device10ColorModel, rhs: Double) -> Device10ColorModel {
    return Device10ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device10ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
}
@_transparent
public func /= (lhs: inout Device10ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
}
@_transparent
public func += (lhs: inout Device10ColorModel, rhs: Device10ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
}
@_transparent
public func -= (lhs: inout Device10ColorModel, rhs: Device10ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
}
@_transparent
public func ==(lhs: Device10ColorModel, rhs: Device10ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9
}
@_transparent
public func !=(lhs: Device10ColorModel, rhs: Device10ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9
}


public struct Device11ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 11
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    public var component_10: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
        self.component_10 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double, _ component_10: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
        self.component_10 = component_10
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            case 10: return component_10
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            case 10: component_10 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device11ColorModel {
    
    @_transparent
    public func blended(source: Device11ColorModel, blending: (Double, Double) -> Double) -> Device11ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        let component_10 = blending(source.component_10, self.component_10)
        return Device11ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10
        )
    }
}

@_transparent
public prefix func +(val: Device11ColorModel) -> Device11ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device11ColorModel) -> Device11ColorModel {
    return Device11ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9, -val.component_10
    )
}
@_transparent
public func +(lhs: Device11ColorModel, rhs: Device11ColorModel) -> Device11ColorModel {
    return Device11ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9, lhs.component_10 + rhs.component_10
    )
}
@_transparent
public func -(lhs: Device11ColorModel, rhs: Device11ColorModel) -> Device11ColorModel {
    return Device11ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9, lhs.component_10 - rhs.component_10
    )
}

@_transparent
public func *(lhs: Double, rhs: Device11ColorModel) -> Device11ColorModel {
    return Device11ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9, lhs * rhs.component_10
    )
}
@_transparent
public func *(lhs: Device11ColorModel, rhs: Double) -> Device11ColorModel {
    return Device11ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs, lhs.component_10 * rhs
    )
}

@_transparent
public func /(lhs: Device11ColorModel, rhs: Double) -> Device11ColorModel {
    return Device11ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs, lhs.component_10 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device11ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
    lhs.component_10 *= rhs
}
@_transparent
public func /= (lhs: inout Device11ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
    lhs.component_10 /= rhs
}
@_transparent
public func += (lhs: inout Device11ColorModel, rhs: Device11ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
    lhs.component_10 += rhs.component_10
}
@_transparent
public func -= (lhs: inout Device11ColorModel, rhs: Device11ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
    lhs.component_10 -= rhs.component_10
}
@_transparent
public func ==(lhs: Device11ColorModel, rhs: Device11ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9 && lhs.component_10 == rhs.component_10
}
@_transparent
public func !=(lhs: Device11ColorModel, rhs: Device11ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9 || lhs.component_10 != rhs.component_10
}


public struct Device12ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 12
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    public var component_10: Double
    public var component_11: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
        self.component_10 = 0
        self.component_11 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double, _ component_10: Double, _ component_11: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
        self.component_10 = component_10
        self.component_11 = component_11
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            case 10: return component_10
            case 11: return component_11
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            case 10: component_10 = newValue
            case 11: component_11 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device12ColorModel {
    
    @_transparent
    public func blended(source: Device12ColorModel, blending: (Double, Double) -> Double) -> Device12ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        let component_10 = blending(source.component_10, self.component_10)
        let component_11 = blending(source.component_11, self.component_11)
        return Device12ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11
        )
    }
}

@_transparent
public prefix func +(val: Device12ColorModel) -> Device12ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device12ColorModel) -> Device12ColorModel {
    return Device12ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9, -val.component_10, -val.component_11
    )
}
@_transparent
public func +(lhs: Device12ColorModel, rhs: Device12ColorModel) -> Device12ColorModel {
    return Device12ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9, lhs.component_10 + rhs.component_10, lhs.component_11 + rhs.component_11
    )
}
@_transparent
public func -(lhs: Device12ColorModel, rhs: Device12ColorModel) -> Device12ColorModel {
    return Device12ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9, lhs.component_10 - rhs.component_10, lhs.component_11 - rhs.component_11
    )
}

@_transparent
public func *(lhs: Double, rhs: Device12ColorModel) -> Device12ColorModel {
    return Device12ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9, lhs * rhs.component_10, lhs * rhs.component_11
    )
}
@_transparent
public func *(lhs: Device12ColorModel, rhs: Double) -> Device12ColorModel {
    return Device12ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs, lhs.component_10 * rhs, lhs.component_11 * rhs
    )
}

@_transparent
public func /(lhs: Device12ColorModel, rhs: Double) -> Device12ColorModel {
    return Device12ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs, lhs.component_10 / rhs, lhs.component_11 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device12ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
    lhs.component_10 *= rhs
    lhs.component_11 *= rhs
}
@_transparent
public func /= (lhs: inout Device12ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
    lhs.component_10 /= rhs
    lhs.component_11 /= rhs
}
@_transparent
public func += (lhs: inout Device12ColorModel, rhs: Device12ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
    lhs.component_10 += rhs.component_10
    lhs.component_11 += rhs.component_11
}
@_transparent
public func -= (lhs: inout Device12ColorModel, rhs: Device12ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
    lhs.component_10 -= rhs.component_10
    lhs.component_11 -= rhs.component_11
}
@_transparent
public func ==(lhs: Device12ColorModel, rhs: Device12ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9 && lhs.component_10 == rhs.component_10 && lhs.component_11 == rhs.component_11
}
@_transparent
public func !=(lhs: Device12ColorModel, rhs: Device12ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9 || lhs.component_10 != rhs.component_10 || lhs.component_11 != rhs.component_11
}


public struct Device13ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 13
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    public var component_10: Double
    public var component_11: Double
    public var component_12: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
        self.component_10 = 0
        self.component_11 = 0
        self.component_12 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double, _ component_10: Double, _ component_11: Double,
                _ component_12: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
        self.component_10 = component_10
        self.component_11 = component_11
        self.component_12 = component_12
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            case 10: return component_10
            case 11: return component_11
            case 12: return component_12
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            case 10: component_10 = newValue
            case 11: component_11 = newValue
            case 12: component_12 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device13ColorModel {
    
    @_transparent
    public func blended(source: Device13ColorModel, blending: (Double, Double) -> Double) -> Device13ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        let component_10 = blending(source.component_10, self.component_10)
        let component_11 = blending(source.component_11, self.component_11)
        let component_12 = blending(source.component_12, self.component_12)
        return Device13ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12
        )
    }
}

@_transparent
public prefix func +(val: Device13ColorModel) -> Device13ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device13ColorModel) -> Device13ColorModel {
    return Device13ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9, -val.component_10, -val.component_11,
        -val.component_12
    )
}
@_transparent
public func +(lhs: Device13ColorModel, rhs: Device13ColorModel) -> Device13ColorModel {
    return Device13ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9, lhs.component_10 + rhs.component_10, lhs.component_11 + rhs.component_11,
        lhs.component_12 + rhs.component_12
    )
}
@_transparent
public func -(lhs: Device13ColorModel, rhs: Device13ColorModel) -> Device13ColorModel {
    return Device13ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9, lhs.component_10 - rhs.component_10, lhs.component_11 - rhs.component_11,
        lhs.component_12 - rhs.component_12
    )
}

@_transparent
public func *(lhs: Double, rhs: Device13ColorModel) -> Device13ColorModel {
    return Device13ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9, lhs * rhs.component_10, lhs * rhs.component_11,
        lhs * rhs.component_12
    )
}
@_transparent
public func *(lhs: Device13ColorModel, rhs: Double) -> Device13ColorModel {
    return Device13ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs, lhs.component_10 * rhs, lhs.component_11 * rhs,
        lhs.component_12 * rhs
    )
}

@_transparent
public func /(lhs: Device13ColorModel, rhs: Double) -> Device13ColorModel {
    return Device13ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs, lhs.component_10 / rhs, lhs.component_11 / rhs,
        lhs.component_12 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device13ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
    lhs.component_10 *= rhs
    lhs.component_11 *= rhs
    lhs.component_12 *= rhs
}
@_transparent
public func /= (lhs: inout Device13ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
    lhs.component_10 /= rhs
    lhs.component_11 /= rhs
    lhs.component_12 /= rhs
}
@_transparent
public func += (lhs: inout Device13ColorModel, rhs: Device13ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
    lhs.component_10 += rhs.component_10
    lhs.component_11 += rhs.component_11
    lhs.component_12 += rhs.component_12
}
@_transparent
public func -= (lhs: inout Device13ColorModel, rhs: Device13ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
    lhs.component_10 -= rhs.component_10
    lhs.component_11 -= rhs.component_11
    lhs.component_12 -= rhs.component_12
}
@_transparent
public func ==(lhs: Device13ColorModel, rhs: Device13ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9 && lhs.component_10 == rhs.component_10 && lhs.component_11 == rhs.component_11
        && lhs.component_12 == rhs.component_12
}
@_transparent
public func !=(lhs: Device13ColorModel, rhs: Device13ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9 || lhs.component_10 != rhs.component_10 || lhs.component_11 != rhs.component_11
        || lhs.component_12 != rhs.component_12
}


public struct Device14ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 14
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    public var component_10: Double
    public var component_11: Double
    public var component_12: Double
    public var component_13: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
        self.component_10 = 0
        self.component_11 = 0
        self.component_12 = 0
        self.component_13 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double, _ component_10: Double, _ component_11: Double,
                _ component_12: Double, _ component_13: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
        self.component_10 = component_10
        self.component_11 = component_11
        self.component_12 = component_12
        self.component_13 = component_13
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            case 10: return component_10
            case 11: return component_11
            case 12: return component_12
            case 13: return component_13
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            case 10: component_10 = newValue
            case 11: component_11 = newValue
            case 12: component_12 = newValue
            case 13: component_13 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device14ColorModel {
    
    @_transparent
    public func blended(source: Device14ColorModel, blending: (Double, Double) -> Double) -> Device14ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        let component_10 = blending(source.component_10, self.component_10)
        let component_11 = blending(source.component_11, self.component_11)
        let component_12 = blending(source.component_12, self.component_12)
        let component_13 = blending(source.component_13, self.component_13)
        return Device14ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13
        )
    }
}

@_transparent
public prefix func +(val: Device14ColorModel) -> Device14ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device14ColorModel) -> Device14ColorModel {
    return Device14ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9, -val.component_10, -val.component_11,
        -val.component_12, -val.component_13
    )
}
@_transparent
public func +(lhs: Device14ColorModel, rhs: Device14ColorModel) -> Device14ColorModel {
    return Device14ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9, lhs.component_10 + rhs.component_10, lhs.component_11 + rhs.component_11,
        lhs.component_12 + rhs.component_12, lhs.component_13 + rhs.component_13
    )
}
@_transparent
public func -(lhs: Device14ColorModel, rhs: Device14ColorModel) -> Device14ColorModel {
    return Device14ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9, lhs.component_10 - rhs.component_10, lhs.component_11 - rhs.component_11,
        lhs.component_12 - rhs.component_12, lhs.component_13 - rhs.component_13
    )
}

@_transparent
public func *(lhs: Double, rhs: Device14ColorModel) -> Device14ColorModel {
    return Device14ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9, lhs * rhs.component_10, lhs * rhs.component_11,
        lhs * rhs.component_12, lhs * rhs.component_13
    )
}
@_transparent
public func *(lhs: Device14ColorModel, rhs: Double) -> Device14ColorModel {
    return Device14ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs, lhs.component_10 * rhs, lhs.component_11 * rhs,
        lhs.component_12 * rhs, lhs.component_13 * rhs
    )
}

@_transparent
public func /(lhs: Device14ColorModel, rhs: Double) -> Device14ColorModel {
    return Device14ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs, lhs.component_10 / rhs, lhs.component_11 / rhs,
        lhs.component_12 / rhs, lhs.component_13 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device14ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
    lhs.component_10 *= rhs
    lhs.component_11 *= rhs
    lhs.component_12 *= rhs
    lhs.component_13 *= rhs
}
@_transparent
public func /= (lhs: inout Device14ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
    lhs.component_10 /= rhs
    lhs.component_11 /= rhs
    lhs.component_12 /= rhs
    lhs.component_13 /= rhs
}
@_transparent
public func += (lhs: inout Device14ColorModel, rhs: Device14ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
    lhs.component_10 += rhs.component_10
    lhs.component_11 += rhs.component_11
    lhs.component_12 += rhs.component_12
    lhs.component_13 += rhs.component_13
}
@_transparent
public func -= (lhs: inout Device14ColorModel, rhs: Device14ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
    lhs.component_10 -= rhs.component_10
    lhs.component_11 -= rhs.component_11
    lhs.component_12 -= rhs.component_12
    lhs.component_13 -= rhs.component_13
}
@_transparent
public func ==(lhs: Device14ColorModel, rhs: Device14ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9 && lhs.component_10 == rhs.component_10 && lhs.component_11 == rhs.component_11
        && lhs.component_12 == rhs.component_12 && lhs.component_13 == rhs.component_13
}
@_transparent
public func !=(lhs: Device14ColorModel, rhs: Device14ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9 || lhs.component_10 != rhs.component_10 || lhs.component_11 != rhs.component_11
        || lhs.component_12 != rhs.component_12 || lhs.component_13 != rhs.component_13
}


public struct Device15ColorModel : DeviceNColorModelProtocol {
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 15
    }
    
    @_transparent
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    public var component_8: Double
    public var component_9: Double
    public var component_10: Double
    public var component_11: Double
    public var component_12: Double
    public var component_13: Double
    public var component_14: Double
    
    @_transparent
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
        self.component_7 = 0
        self.component_8 = 0
        self.component_9 = 0
        self.component_10 = 0
        self.component_11 = 0
        self.component_12 = 0
        self.component_13 = 0
        self.component_14 = 0
    }
    
    @_transparent
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double,
                _ component_6: Double, _ component_7: Double, _ component_8: Double,
                _ component_9: Double, _ component_10: Double, _ component_11: Double,
                _ component_12: Double, _ component_13: Double, _ component_14: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
        self.component_6 = component_6
        self.component_7 = component_7
        self.component_8 = component_8
        self.component_9 = component_9
        self.component_10 = component_10
        self.component_11 = component_11
        self.component_12 = component_12
        self.component_13 = component_13
        self.component_14 = component_14
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        get {
            switch position {
            case 0: return component_0
            case 1: return component_1
            case 2: return component_2
            case 3: return component_3
            case 4: return component_4
            case 5: return component_5
            case 6: return component_6
            case 7: return component_7
            case 8: return component_8
            case 9: return component_9
            case 10: return component_10
            case 11: return component_11
            case 12: return component_12
            case 13: return component_13
            case 14: return component_14
            default: fatalError()
            }
        }
        set {
            switch position {
            case 0: component_0 = newValue
            case 1: component_1 = newValue
            case 2: component_2 = newValue
            case 3: component_3 = newValue
            case 4: component_4 = newValue
            case 5: component_5 = newValue
            case 6: component_6 = newValue
            case 7: component_7 = newValue
            case 8: component_8 = newValue
            case 9: component_9 = newValue
            case 10: component_10 = newValue
            case 11: component_11 = newValue
            case 12: component_12 = newValue
            case 13: component_13 = newValue
            case 14: component_14 = newValue
            default: fatalError()
            }
        }
    }
}

extension Device15ColorModel {
    
    @_transparent
    public func blended(source: Device15ColorModel, blending: (Double, Double) -> Double) -> Device15ColorModel {
        let component_0 = blending(source.component_0, self.component_0)
        let component_1 = blending(source.component_1, self.component_1)
        let component_2 = blending(source.component_2, self.component_2)
        let component_3 = blending(source.component_3, self.component_3)
        let component_4 = blending(source.component_4, self.component_4)
        let component_5 = blending(source.component_5, self.component_5)
        let component_6 = blending(source.component_6, self.component_6)
        let component_7 = blending(source.component_7, self.component_7)
        let component_8 = blending(source.component_8, self.component_8)
        let component_9 = blending(source.component_9, self.component_9)
        let component_10 = blending(source.component_10, self.component_10)
        let component_11 = blending(source.component_11, self.component_11)
        let component_12 = blending(source.component_12, self.component_12)
        let component_13 = blending(source.component_13, self.component_13)
        let component_14 = blending(source.component_14, self.component_14)
        return Device15ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13, component_14
        )
    }
}

@_transparent
public prefix func +(val: Device15ColorModel) -> Device15ColorModel {
    return val
}
@_transparent
public prefix func -(val: Device15ColorModel) -> Device15ColorModel {
    return Device15ColorModel(
        -val.component_0, -val.component_1, -val.component_2,
        -val.component_3, -val.component_4, -val.component_5,
        -val.component_6, -val.component_7, -val.component_8,
        -val.component_9, -val.component_10, -val.component_11,
        -val.component_12, -val.component_13, -val.component_14
    )
}
@_transparent
public func +(lhs: Device15ColorModel, rhs: Device15ColorModel) -> Device15ColorModel {
    return Device15ColorModel(
        lhs.component_0 + rhs.component_0, lhs.component_1 + rhs.component_1, lhs.component_2 + rhs.component_2,
        lhs.component_3 + rhs.component_3, lhs.component_4 + rhs.component_4, lhs.component_5 + rhs.component_5,
        lhs.component_6 + rhs.component_6, lhs.component_7 + rhs.component_7, lhs.component_8 + rhs.component_8,
        lhs.component_9 + rhs.component_9, lhs.component_10 + rhs.component_10, lhs.component_11 + rhs.component_11,
        lhs.component_12 + rhs.component_12, lhs.component_13 + rhs.component_13, lhs.component_14 + rhs.component_14
    )
}
@_transparent
public func -(lhs: Device15ColorModel, rhs: Device15ColorModel) -> Device15ColorModel {
    return Device15ColorModel(
        lhs.component_0 - rhs.component_0, lhs.component_1 - rhs.component_1, lhs.component_2 - rhs.component_2,
        lhs.component_3 - rhs.component_3, lhs.component_4 - rhs.component_4, lhs.component_5 - rhs.component_5,
        lhs.component_6 - rhs.component_6, lhs.component_7 - rhs.component_7, lhs.component_8 - rhs.component_8,
        lhs.component_9 - rhs.component_9, lhs.component_10 - rhs.component_10, lhs.component_11 - rhs.component_11,
        lhs.component_12 - rhs.component_12, lhs.component_13 - rhs.component_13, lhs.component_14 - rhs.component_14
    )
}

@_transparent
public func *(lhs: Double, rhs: Device15ColorModel) -> Device15ColorModel {
    return Device15ColorModel(
        lhs * rhs.component_0, lhs * rhs.component_1, lhs * rhs.component_2,
        lhs * rhs.component_3, lhs * rhs.component_4, lhs * rhs.component_5,
        lhs * rhs.component_6, lhs * rhs.component_7, lhs * rhs.component_8,
        lhs * rhs.component_9, lhs * rhs.component_10, lhs * rhs.component_11,
        lhs * rhs.component_12, lhs * rhs.component_13, lhs * rhs.component_14
    )
}
@_transparent
public func *(lhs: Device15ColorModel, rhs: Double) -> Device15ColorModel {
    return Device15ColorModel(
        lhs.component_0 * rhs, lhs.component_1 * rhs, lhs.component_2 * rhs,
        lhs.component_3 * rhs, lhs.component_4 * rhs, lhs.component_5 * rhs,
        lhs.component_6 * rhs, lhs.component_7 * rhs, lhs.component_8 * rhs,
        lhs.component_9 * rhs, lhs.component_10 * rhs, lhs.component_11 * rhs,
        lhs.component_12 * rhs, lhs.component_13 * rhs, lhs.component_14 * rhs
    )
}

@_transparent
public func /(lhs: Device15ColorModel, rhs: Double) -> Device15ColorModel {
    return Device15ColorModel(
        lhs.component_0 / rhs, lhs.component_1 / rhs, lhs.component_2 / rhs,
        lhs.component_3 / rhs, lhs.component_4 / rhs, lhs.component_5 / rhs,
        lhs.component_6 / rhs, lhs.component_7 / rhs, lhs.component_8 / rhs,
        lhs.component_9 / rhs, lhs.component_10 / rhs, lhs.component_11 / rhs,
        lhs.component_12 / rhs, lhs.component_13 / rhs, lhs.component_14 / rhs
    )
}

@_transparent
public func *= (lhs: inout Device15ColorModel, rhs: Double) {
    lhs.component_0 *= rhs
    lhs.component_1 *= rhs
    lhs.component_2 *= rhs
    lhs.component_3 *= rhs
    lhs.component_4 *= rhs
    lhs.component_5 *= rhs
    lhs.component_6 *= rhs
    lhs.component_7 *= rhs
    lhs.component_8 *= rhs
    lhs.component_9 *= rhs
    lhs.component_10 *= rhs
    lhs.component_11 *= rhs
    lhs.component_12 *= rhs
    lhs.component_13 *= rhs
    lhs.component_14 *= rhs
}
@_transparent
public func /= (lhs: inout Device15ColorModel, rhs: Double) {
    lhs.component_0 /= rhs
    lhs.component_1 /= rhs
    lhs.component_2 /= rhs
    lhs.component_3 /= rhs
    lhs.component_4 /= rhs
    lhs.component_5 /= rhs
    lhs.component_6 /= rhs
    lhs.component_7 /= rhs
    lhs.component_8 /= rhs
    lhs.component_9 /= rhs
    lhs.component_10 /= rhs
    lhs.component_11 /= rhs
    lhs.component_12 /= rhs
    lhs.component_13 /= rhs
    lhs.component_14 /= rhs
}
@_transparent
public func += (lhs: inout Device15ColorModel, rhs: Device15ColorModel) {
    lhs.component_0 += rhs.component_0
    lhs.component_1 += rhs.component_1
    lhs.component_2 += rhs.component_2
    lhs.component_3 += rhs.component_3
    lhs.component_4 += rhs.component_4
    lhs.component_5 += rhs.component_5
    lhs.component_6 += rhs.component_6
    lhs.component_7 += rhs.component_7
    lhs.component_8 += rhs.component_8
    lhs.component_9 += rhs.component_9
    lhs.component_10 += rhs.component_10
    lhs.component_11 += rhs.component_11
    lhs.component_12 += rhs.component_12
    lhs.component_13 += rhs.component_13
    lhs.component_14 += rhs.component_14
}
@_transparent
public func -= (lhs: inout Device15ColorModel, rhs: Device15ColorModel) {
    lhs.component_0 -= rhs.component_0
    lhs.component_1 -= rhs.component_1
    lhs.component_2 -= rhs.component_2
    lhs.component_3 -= rhs.component_3
    lhs.component_4 -= rhs.component_4
    lhs.component_5 -= rhs.component_5
    lhs.component_6 -= rhs.component_6
    lhs.component_7 -= rhs.component_7
    lhs.component_8 -= rhs.component_8
    lhs.component_9 -= rhs.component_9
    lhs.component_10 -= rhs.component_10
    lhs.component_11 -= rhs.component_11
    lhs.component_12 -= rhs.component_12
    lhs.component_13 -= rhs.component_13
    lhs.component_14 -= rhs.component_14
}
@_transparent
public func ==(lhs: Device15ColorModel, rhs: Device15ColorModel) -> Bool {
    return lhs.component_0 == rhs.component_0 && lhs.component_1 == rhs.component_1 && lhs.component_2 == rhs.component_2
        && lhs.component_3 == rhs.component_3 && lhs.component_4 == rhs.component_4 && lhs.component_5 == rhs.component_5
        && lhs.component_6 == rhs.component_6 && lhs.component_7 == rhs.component_7 && lhs.component_8 == rhs.component_8
        && lhs.component_9 == rhs.component_9 && lhs.component_10 == rhs.component_10 && lhs.component_11 == rhs.component_11
        && lhs.component_12 == rhs.component_12 && lhs.component_13 == rhs.component_13 && lhs.component_14 == rhs.component_14
}
@_transparent
public func !=(lhs: Device15ColorModel, rhs: Device15ColorModel) -> Bool {
    return lhs.component_0 != rhs.component_0 || lhs.component_1 != rhs.component_1 || lhs.component_2 != rhs.component_2
        || lhs.component_3 != rhs.component_3 || lhs.component_4 != rhs.component_4 || lhs.component_5 != rhs.component_5
        || lhs.component_6 != rhs.component_6 || lhs.component_7 != rhs.component_7 || lhs.component_8 != rhs.component_8
        || lhs.component_9 != rhs.component_9 || lhs.component_10 != rhs.component_10 || lhs.component_11 != rhs.component_11
        || lhs.component_12 != rhs.component_12 || lhs.component_13 != rhs.component_13 || lhs.component_14 != rhs.component_14
}

