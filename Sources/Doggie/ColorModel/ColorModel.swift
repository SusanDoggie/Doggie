//
//  ColorModel.swift
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

public protocol ColorModelProtocol : Hashable {
    
    static var numberOfComponents: Int { get }
    
    static func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    init()
    
    func component(_ index: Int) -> Double
    
    mutating func setComponent(_ index: Int, _ value: Double)
}

extension ColorModelProtocol {
    
    @_transparent
    public var numberOfComponents: Int {
        return Self.numberOfComponents
    }
    
    @_transparent
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return Self.rangeOfComponent(i)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public func normalizedComponent(_ index: Int) -> Double {
        let range = Self.rangeOfComponent(index)
        return (self.component(index) - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
    
    @_transparent
    public mutating func setNormalizedComponent(_ index: Int, _ value: Double) {
        let range = Self.rangeOfComponent(index)
        self.setComponent(index, value * (range.upperBound - range.lowerBound) + range.lowerBound)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public var hashValue: Int {
        var hash = 0
        for i in 0..<Self.numberOfComponents {
            hash = hash_combine(seed: hash, self.component(i))
        }
        return hash
    }
}

public struct ColorModelComponentCollection<Model: ColorModelProtocol>: RandomAccessCollection {
    
    public let base: Model
    
    @_transparent
    public init(base: Model) {
        self.base = base
    }
    
    @_transparent
    public var startIndex: Int {
        return 0
    }
    @_transparent
    public var endIndex: Int {
        return Model.numberOfComponents
    }
    
    @_inlineable
    public subscript(position: Int) -> Double {
        _failEarlyRangeCheck(position, bounds: startIndex..<endIndex)
        return base.component(position)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public var components: ColorModelComponentCollection<Self> {
        return ColorModelComponentCollection(base: self)
    }
}

@_transparent
public prefix func +<Model : ColorModelProtocol>(val: Model) -> Model {
    return val
}
@_transparent
public prefix func -<Model : ColorModelProtocol>(val: Model) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, -val.component(i))
    }
    return result
}
@_transparent
public func +<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, lhs.component(i) + rhs.component(i))
    }
    return result
}
@_transparent
public func -<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, lhs.component(i) - rhs.component(i))
    }
    return result
}

@_transparent
public func *<Model : ColorModelProtocol>(lhs: Double, rhs: Model) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, lhs * rhs.component(i))
    }
    return result
}
@_transparent
public func *<Model : ColorModelProtocol>(lhs: Model, rhs: Double) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, lhs.component(i) * rhs)
    }
    return result
}

@_transparent
public func /<Model : ColorModelProtocol>(lhs: Model, rhs: Double) -> Model {
    var result = Model()
    for i in 0..<Model.numberOfComponents {
        result.setComponent(i, lhs.component(i) / rhs)
    }
    return result
}

@_transparent
public func *=<Model : ColorModelProtocol> (lhs: inout Model, rhs: Double) {
    for i in 0..<Model.numberOfComponents {
        lhs.setComponent(i, lhs.component(i) * rhs)
    }
}
@_transparent
public func /=<Model : ColorModelProtocol> (lhs: inout Model, rhs: Double) {
    for i in 0..<Model.numberOfComponents {
        lhs.setComponent(i, lhs.component(i) / rhs)
    }
}
@_transparent
public func +=<Model : ColorModelProtocol> (lhs: inout Model, rhs: Model) {
    for i in 0..<Model.numberOfComponents {
        lhs.setComponent(i, lhs.component(i) + rhs.component(i))
    }
}
@_transparent
public func -=<Model : ColorModelProtocol> (lhs: inout Model, rhs: Model) {
    for i in 0..<Model.numberOfComponents {
        lhs.setComponent(i, lhs.component(i) - rhs.component(i))
    }
}
@_transparent
public func ==<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Bool {
    for i in 0..<Model.numberOfComponents where lhs.component(i) != rhs.component(i) {
        return false
    }
    return true
}
@_transparent
public func !=<Model : ColorModelProtocol>(lhs: Model, rhs: Model) -> Bool {
    for i in 0..<Model.numberOfComponents where lhs.component(i) != rhs.component(i) {
        return true
    }
    return false
}

