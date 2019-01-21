//
//  DeviceNColorModel.swift
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

public struct Device2ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 2
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
    }
    
    @inlinable
    @inline(__always)
    public init(_ component_0: Double, _ component_1: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device2ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        return Device2ColorModel(component_0, component_1)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device2ColorModel, _ transform: (Double, Double) -> Double) -> Device2ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        return Device2ColorModel(component_0, component_1)
    }
}

public struct Device3ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 3
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
    }
    
    @inlinable
    @inline(__always)
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device3ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        return Device3ColorModel(component_0, component_1, component_2)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device3ColorModel, _ transform: (Double, Double) -> Double) -> Device3ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        return Device3ColorModel(component_0, component_1, component_2)
    }
}

public struct Device4ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 4
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
    }
    
    @inlinable
    @inline(__always)
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double, _ component_3: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device4ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        return Device4ColorModel(component_0, component_1, component_2, component_3)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device4ColorModel, _ transform: (Double, Double) -> Double) -> Device4ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        return Device4ColorModel(component_0, component_1, component_2, component_3)
    }
}

public struct Device5ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 5
    }
    
    @inlinable
    @inline(__always)
    public static func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        precondition(0..<numberOfComponents ~= i, "Index out of range.")
        return 0...1
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
    }
    
    @inlinable
    @inline(__always)
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device5ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        return Device5ColorModel(
            component_0, component_1, component_2,
            component_3, component_4
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device5ColorModel, _ transform: (Double, Double) -> Double) -> Device5ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        return Device5ColorModel(
            component_0, component_1, component_2,
            component_3, component_4
        )
    }
}

public struct Device6ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 6
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
    }
    
    @inlinable
    @inline(__always)
    public init(_ component_0: Double, _ component_1: Double, _ component_2: Double,
                _ component_3: Double, _ component_4: Double, _ component_5: Double) {
        self.component_0 = component_0
        self.component_1 = component_1
        self.component_2 = component_2
        self.component_3 = component_3
        self.component_4 = component_4
        self.component_5 = component_5
    }
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device6ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        return Device6ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device6ColorModel, _ transform: (Double, Double) -> Double) -> Device6ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        return Device6ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5
        )
    }
}

public struct Device7ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 7
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device7ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        return Device7ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device7ColorModel, _ transform: (Double, Double) -> Double) -> Device7ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        return Device7ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6
        )
    }
}

public struct Device8ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 8
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device8ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        return Device8ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device8ColorModel, _ transform: (Double, Double) -> Double) -> Device8ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        return Device8ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7
        )
    }
}

public struct Device9ColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 9
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> Device9ColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        return Device9ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device9ColorModel, _ transform: (Double, Double) -> Double) -> Device9ColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        return Device9ColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8
        )
    }
}

public struct DeviceAColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 10
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceAColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceAColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        return DeviceAColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceAColorModel, _ transform: (Double, Double) -> Double) -> DeviceAColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        return DeviceAColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9
        )
    }
}

public struct DeviceBColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 11
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceBColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceBColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        return DeviceBColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceBColorModel, _ transform: (Double, Double) -> Double) -> DeviceBColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        return DeviceBColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10
        )
    }
}

public struct DeviceCColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 12
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceCColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceCColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        return DeviceCColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceCColorModel, _ transform: (Double, Double) -> Double) -> DeviceCColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        return DeviceCColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11
        )
    }
}

public struct DeviceDColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 13
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceDColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceDColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        return DeviceDColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceDColorModel, _ transform: (Double, Double) -> Double) -> DeviceDColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        return DeviceDColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12
        )
    }
}

public struct DeviceEColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 14
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceEColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceEColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        let component_13 = transform(self.component_13)
        return DeviceEColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        updateAccumulatingResult(&accumulator, component_13)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceEColorModel, _ transform: (Double, Double) -> Double) -> DeviceEColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        let component_13 = transform(self.component_13, other.component_13)
        return DeviceEColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13
        )
    }
}

public struct DeviceFColorModel : ColorModelProtocol {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @_transparent
    public static var numberOfComponents: Int {
        return 15
    }
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
    @inline(__always)
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
    
    @inlinable
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

extension DeviceFColorModel {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Double) -> Double) -> DeviceFColorModel {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        let component_13 = transform(self.component_13)
        let component_14 = transform(self.component_14)
        return DeviceFColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13, component_14
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        updateAccumulatingResult(&accumulator, component_13)
        updateAccumulatingResult(&accumulator, component_14)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceFColorModel, _ transform: (Double, Double) -> Double) -> DeviceFColorModel {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        let component_13 = transform(self.component_13, other.component_13)
        let component_14 = transform(self.component_14, other.component_14)
        return DeviceFColorModel(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13, component_14
        )
    }
}

// MARK: FloatComponents

extension Device2ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device2ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 2
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device2ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device2ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device2ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        return Device2ColorModel.FloatComponents(component_0, component_1)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device2ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device2ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        return Device2ColorModel.FloatComponents(component_0, component_1)
    }
}

extension Device3ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device3ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 3
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
            self.component_2 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device3ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device3ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device3ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        return Device3ColorModel.FloatComponents(component_0, component_1, component_2)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device3ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device3ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        return Device3ColorModel.FloatComponents(component_0, component_1, component_2)
    }
}

extension Device4ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device4ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 4
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
            self.component_2 = 0
            self.component_3 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar, _ component_3: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
            self.component_3 = component_3
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device4ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device4ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device4ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        return Device4ColorModel.FloatComponents(component_0, component_1, component_2, component_3)
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device4ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device4ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        return Device4ColorModel.FloatComponents(component_0, component_1, component_2, component_3)
    }
}

extension Device5ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device5ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 5
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
            self.component_2 = 0
            self.component_3 = 0
            self.component_4 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
            self.component_3 = component_3
            self.component_4 = component_4
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device5ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device5ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device5ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        return Device5ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device5ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device5ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        return Device5ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4
        )
    }
}

extension Device6ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device6ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 6
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
            self.component_2 = 0
            self.component_3 = 0
            self.component_4 = 0
            self.component_5 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
            self.component_3 = component_3
            self.component_4 = component_4
            self.component_5 = component_5
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device6ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device6ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device6ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        return Device6ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device6ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device6ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        return Device6ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5
        )
    }
}

extension Device7ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device7ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 7
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        
        @inline(__always)
        public init() {
            self.component_0 = 0
            self.component_1 = 0
            self.component_2 = 0
            self.component_3 = 0
            self.component_4 = 0
            self.component_5 = 0
            self.component_6 = 0
        }
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
            self.component_3 = component_3
            self.component_4 = component_4
            self.component_5 = component_5
            self.component_6 = component_6
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device7ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device7ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device7ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        return Device7ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device7ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device7ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        return Device7ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6
        )
    }
}

extension Device8ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device8ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 8
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar) {
            self.component_0 = component_0
            self.component_1 = component_1
            self.component_2 = component_2
            self.component_3 = component_3
            self.component_4 = component_4
            self.component_5 = component_5
            self.component_6 = component_6
            self.component_7 = component_7
        }
        
        @inlinable
        @inline(__always)
        public init(_ color: Device8ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device8ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device8ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        return Device8ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device8ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device8ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        return Device8ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7
        )
    }
}

extension Device9ColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = Device9ColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 9
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: Device9ColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension Device9ColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> Device9ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        return Device9ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: Device9ColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> Device9ColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        return Device9ColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8
        )
    }
}

extension DeviceAColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceAColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 10
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceAColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceAColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceAColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        return DeviceAColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceAColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceAColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        return DeviceAColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9
        )
    }
}

extension DeviceBColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
        self.component_10 = Double(floatComponents.component_10)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceBColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 11
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        public var component_10: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar, _ component_10: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceBColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
            self.component_10 = Scalar(color.component_10)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
            self.component_10 = Scalar(floatComponents.component_10)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceBColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceBColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        return DeviceBColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceBColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceBColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        return DeviceBColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10
        )
    }
}

extension DeviceCColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
        self.component_10 = Double(floatComponents.component_10)
        self.component_11 = Double(floatComponents.component_11)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceCColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 12
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        public var component_10: Scalar
        public var component_11: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar, _ component_10: Scalar, _ component_11: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceCColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
            self.component_10 = Scalar(color.component_10)
            self.component_11 = Scalar(color.component_11)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
            self.component_10 = Scalar(floatComponents.component_10)
            self.component_11 = Scalar(floatComponents.component_11)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceCColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceCColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        return DeviceCColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceCColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceCColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        return DeviceCColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11
        )
    }
}

extension DeviceDColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
        self.component_10 = Double(floatComponents.component_10)
        self.component_11 = Double(floatComponents.component_11)
        self.component_12 = Double(floatComponents.component_12)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceDColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 13
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        public var component_10: Scalar
        public var component_11: Scalar
        public var component_12: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar, _ component_10: Scalar, _ component_11: Scalar,
                    _ component_12: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceDColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
            self.component_10 = Scalar(color.component_10)
            self.component_11 = Scalar(color.component_11)
            self.component_12 = Scalar(color.component_12)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
            self.component_10 = Scalar(floatComponents.component_10)
            self.component_11 = Scalar(floatComponents.component_11)
            self.component_12 = Scalar(floatComponents.component_12)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceDColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceDColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        return DeviceDColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceDColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceDColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        return DeviceDColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12
        )
    }
}

extension DeviceEColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
        self.component_10 = Double(floatComponents.component_10)
        self.component_11 = Double(floatComponents.component_11)
        self.component_12 = Double(floatComponents.component_12)
        self.component_13 = Double(floatComponents.component_13)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceEColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 14
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        public var component_10: Scalar
        public var component_11: Scalar
        public var component_12: Scalar
        public var component_13: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar, _ component_10: Scalar, _ component_11: Scalar,
                    _ component_12: Scalar, _ component_13: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceEColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
            self.component_10 = Scalar(color.component_10)
            self.component_11 = Scalar(color.component_11)
            self.component_12 = Scalar(color.component_12)
            self.component_13 = Scalar(color.component_13)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
            self.component_10 = Scalar(floatComponents.component_10)
            self.component_11 = Scalar(floatComponents.component_11)
            self.component_12 = Scalar(floatComponents.component_12)
            self.component_13 = Scalar(floatComponents.component_13)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceEColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceEColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        let component_13 = transform(self.component_13)
        return DeviceEColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        updateAccumulatingResult(&accumulator, component_13)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceEColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceEColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        let component_13 = transform(self.component_13, other.component_13)
        return DeviceEColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13
        )
    }
}

extension DeviceFColorModel {
    
    public typealias Float32Components = FloatComponents<Float>
    
    @inlinable
    @inline(__always)
    public init<T>(floatComponents: FloatComponents<T>) {
        self.component_0 = Double(floatComponents.component_0)
        self.component_1 = Double(floatComponents.component_1)
        self.component_2 = Double(floatComponents.component_2)
        self.component_3 = Double(floatComponents.component_3)
        self.component_4 = Double(floatComponents.component_4)
        self.component_5 = Double(floatComponents.component_5)
        self.component_6 = Double(floatComponents.component_6)
        self.component_7 = Double(floatComponents.component_7)
        self.component_8 = Double(floatComponents.component_8)
        self.component_9 = Double(floatComponents.component_9)
        self.component_10 = Double(floatComponents.component_10)
        self.component_11 = Double(floatComponents.component_11)
        self.component_12 = Double(floatComponents.component_12)
        self.component_13 = Double(floatComponents.component_13)
        self.component_14 = Double(floatComponents.component_14)
    }
    
    @_transparent
    public var float32Components: Float32Components {
        get {
            return Float32Components(self)
        }
        set {
            self = DeviceFColorModel(floatComponents: newValue)
        }
    }
    
    public struct FloatComponents<Scalar : BinaryFloatingPoint & ScalarProtocol> : _FloatColorComponents {
        
        public typealias Indices = Range<Int>
        
        @_transparent
        public static var numberOfComponents: Int {
            return 15
        }
        
        public var component_0: Scalar
        public var component_1: Scalar
        public var component_2: Scalar
        public var component_3: Scalar
        public var component_4: Scalar
        public var component_5: Scalar
        public var component_6: Scalar
        public var component_7: Scalar
        public var component_8: Scalar
        public var component_9: Scalar
        public var component_10: Scalar
        public var component_11: Scalar
        public var component_12: Scalar
        public var component_13: Scalar
        public var component_14: Scalar
        
        @inline(__always)
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
        
        @inline(__always)
        public init(_ component_0: Scalar, _ component_1: Scalar, _ component_2: Scalar,
                    _ component_3: Scalar, _ component_4: Scalar, _ component_5: Scalar,
                    _ component_6: Scalar, _ component_7: Scalar, _ component_8: Scalar,
                    _ component_9: Scalar, _ component_10: Scalar, _ component_11: Scalar,
                    _ component_12: Scalar, _ component_13: Scalar, _ component_14: Scalar) {
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
        
        @inlinable
        @inline(__always)
        public init(_ color: DeviceFColorModel) {
            self.component_0 = Scalar(color.component_0)
            self.component_1 = Scalar(color.component_1)
            self.component_2 = Scalar(color.component_2)
            self.component_3 = Scalar(color.component_3)
            self.component_4 = Scalar(color.component_4)
            self.component_5 = Scalar(color.component_5)
            self.component_6 = Scalar(color.component_6)
            self.component_7 = Scalar(color.component_7)
            self.component_8 = Scalar(color.component_8)
            self.component_9 = Scalar(color.component_9)
            self.component_10 = Scalar(color.component_10)
            self.component_11 = Scalar(color.component_11)
            self.component_12 = Scalar(color.component_12)
            self.component_13 = Scalar(color.component_13)
            self.component_14 = Scalar(color.component_14)
        }
        
        @inlinable
        @inline(__always)
        public init<T>(floatComponents: FloatComponents<T>) {
            self.component_0 = Scalar(floatComponents.component_0)
            self.component_1 = Scalar(floatComponents.component_1)
            self.component_2 = Scalar(floatComponents.component_2)
            self.component_3 = Scalar(floatComponents.component_3)
            self.component_4 = Scalar(floatComponents.component_4)
            self.component_5 = Scalar(floatComponents.component_5)
            self.component_6 = Scalar(floatComponents.component_6)
            self.component_7 = Scalar(floatComponents.component_7)
            self.component_8 = Scalar(floatComponents.component_8)
            self.component_9 = Scalar(floatComponents.component_9)
            self.component_10 = Scalar(floatComponents.component_10)
            self.component_11 = Scalar(floatComponents.component_11)
            self.component_12 = Scalar(floatComponents.component_12)
            self.component_13 = Scalar(floatComponents.component_13)
            self.component_14 = Scalar(floatComponents.component_14)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
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
}

extension DeviceFColorModel.FloatComponents {
    
    @inlinable
    @inline(__always)
    public func map(_ transform: (Scalar) -> Scalar) -> DeviceFColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0)
        let component_1 = transform(self.component_1)
        let component_2 = transform(self.component_2)
        let component_3 = transform(self.component_3)
        let component_4 = transform(self.component_4)
        let component_5 = transform(self.component_5)
        let component_6 = transform(self.component_6)
        let component_7 = transform(self.component_7)
        let component_8 = transform(self.component_8)
        let component_9 = transform(self.component_9)
        let component_10 = transform(self.component_10)
        let component_11 = transform(self.component_11)
        let component_12 = transform(self.component_12)
        let component_13 = transform(self.component_13)
        let component_14 = transform(self.component_14)
        return DeviceFColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13, component_14
        )
    }
    
    @inlinable
    @inline(__always)
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> ()) -> Result {
        var accumulator = initialResult
        updateAccumulatingResult(&accumulator, component_0)
        updateAccumulatingResult(&accumulator, component_1)
        updateAccumulatingResult(&accumulator, component_2)
        updateAccumulatingResult(&accumulator, component_3)
        updateAccumulatingResult(&accumulator, component_4)
        updateAccumulatingResult(&accumulator, component_5)
        updateAccumulatingResult(&accumulator, component_6)
        updateAccumulatingResult(&accumulator, component_7)
        updateAccumulatingResult(&accumulator, component_8)
        updateAccumulatingResult(&accumulator, component_9)
        updateAccumulatingResult(&accumulator, component_10)
        updateAccumulatingResult(&accumulator, component_11)
        updateAccumulatingResult(&accumulator, component_12)
        updateAccumulatingResult(&accumulator, component_13)
        updateAccumulatingResult(&accumulator, component_14)
        return accumulator
    }
    
    @inlinable
    @inline(__always)
    public func combined(_ other: DeviceFColorModel.FloatComponents<Scalar>, _ transform: (Scalar, Scalar) -> Scalar) -> DeviceFColorModel.FloatComponents<Scalar> {
        let component_0 = transform(self.component_0, other.component_0)
        let component_1 = transform(self.component_1, other.component_1)
        let component_2 = transform(self.component_2, other.component_2)
        let component_3 = transform(self.component_3, other.component_3)
        let component_4 = transform(self.component_4, other.component_4)
        let component_5 = transform(self.component_5, other.component_5)
        let component_6 = transform(self.component_6, other.component_6)
        let component_7 = transform(self.component_7, other.component_7)
        let component_8 = transform(self.component_8, other.component_8)
        let component_9 = transform(self.component_9, other.component_9)
        let component_10 = transform(self.component_10, other.component_10)
        let component_11 = transform(self.component_11, other.component_11)
        let component_12 = transform(self.component_12, other.component_12)
        let component_13 = transform(self.component_13, other.component_13)
        let component_14 = transform(self.component_14, other.component_14)
        return DeviceFColorModel.FloatComponents(
            component_0, component_1, component_2,
            component_3, component_4, component_5,
            component_6, component_7, component_8,
            component_9, component_10, component_11,
            component_12, component_13, component_14
        )
    }
}
