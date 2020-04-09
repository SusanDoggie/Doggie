//
//  DeviceNColorModel.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct Device2ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device3ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device4ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device5ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device6ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device7ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device8ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct Device9ColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceAColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceBColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceCColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceDColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceEColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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

@frozen
public struct DeviceFColorModel: ColorModel {
    
    public typealias Indices = Range<Int>
    
    public typealias Scalar = Double
    
    @inlinable
    @inline(__always)
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
            return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Double.self)[position] }
        }
        set {
            Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Double.self)[position] = newValue }
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Double) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device2ColorModel {
            get {
                return Device2ColorModel(Double(component_0), Double(component_1))
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device3ColorModel {
            get {
                return Device3ColorModel(Double(component_0), Double(component_1), Double(component_2))
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device4ColorModel {
            get {
                return Device4ColorModel(Double(component_0), Double(component_1), Double(component_2), Double(component_3))
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device5ColorModel {
            get {
                return Device5ColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device6ColorModel {
            get {
                return Device6ColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device7ColorModel {
            get {
                return Device7ColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device8ColorModel {
            get {
                return Device8ColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: Device9ColorModel {
            get {
                return Device9ColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceAColorModel {
            get {
                return DeviceAColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
            self.component_10 = Scalar(components.component_10)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceBColorModel {
            get {
                return DeviceBColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9), Double(component_10)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
            self.component_10 = Scalar(components.component_10)
            self.component_11 = Scalar(components.component_11)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceCColorModel {
            get {
                return DeviceCColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9), Double(component_10), Double(component_11)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
            self.component_10 = Scalar(components.component_10)
            self.component_11 = Scalar(components.component_11)
            self.component_12 = Scalar(components.component_12)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceDColorModel {
            get {
                return DeviceDColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9), Double(component_10), Double(component_11),
                    Double(component_12)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
            self.component_10 = Scalar(components.component_10)
            self.component_11 = Scalar(components.component_11)
            self.component_12 = Scalar(components.component_12)
            self.component_13 = Scalar(components.component_13)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceEColorModel {
            get {
                return DeviceEColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9), Double(component_10), Double(component_11),
                    Double(component_12), Double(component_13)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
    
    @frozen
    public struct FloatComponents<Scalar: BinaryFloatingPoint & ScalarProtocol>: ColorComponents {
        
        public typealias Indices = Range<Int>
        
        @inlinable
        @inline(__always)
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
        public init<T>(_ components: FloatComponents<T>) {
            self.component_0 = Scalar(components.component_0)
            self.component_1 = Scalar(components.component_1)
            self.component_2 = Scalar(components.component_2)
            self.component_3 = Scalar(components.component_3)
            self.component_4 = Scalar(components.component_4)
            self.component_5 = Scalar(components.component_5)
            self.component_6 = Scalar(components.component_6)
            self.component_7 = Scalar(components.component_7)
            self.component_8 = Scalar(components.component_8)
            self.component_9 = Scalar(components.component_9)
            self.component_10 = Scalar(components.component_10)
            self.component_11 = Scalar(components.component_11)
            self.component_12 = Scalar(components.component_12)
            self.component_13 = Scalar(components.component_13)
            self.component_14 = Scalar(components.component_14)
        }
        
        @inlinable
        public subscript(position: Int) -> Scalar {
            get {
                return Swift.withUnsafeBytes(of: self) { $0.bindMemory(to: Scalar.self)[position] }
            }
            set {
                Swift.withUnsafeMutableBytes(of: &self) { $0.bindMemory(to: Scalar.self)[position] = newValue }
            }
        }
        
        @inlinable
        @inline(__always)
        public var model: DeviceFColorModel {
            get {
                return DeviceFColorModel(
                    Double(component_0), Double(component_1), Double(component_2),
                    Double(component_3), Double(component_4), Double(component_5),
                    Double(component_6), Double(component_7), Double(component_8),
                    Double(component_9), Double(component_10), Double(component_11),
                    Double(component_12), Double(component_13), Double(component_14)
                )
            }
            set {
                self = FloatComponents(newValue)
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
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Scalar) -> Void) -> Result {
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
