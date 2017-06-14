//
//  DeviceNColorModel.swift
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

public protocol DeviceNColorModelProtocol : ColorModelProtocol {
    
}

public struct Device2ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 2
    }
    
    public var component_0: Double
    public var component_1: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return component_0
        case 1: return component_1
        default: fatalError()
        }
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        default: fatalError()
        }
    }
}

public struct Device3ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 3
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return component_0
        case 1: return component_1
        case 2: return component_2
        default: fatalError()
        }
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        default: fatalError()
        }
    }
}

public struct Device4ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 4
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return component_0
        case 1: return component_1
        case 2: return component_2
        case 3: return component_3
        default: fatalError()
        }
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        default: fatalError()
        }
    }
}

public struct Device5ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 5
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return component_0
        case 1: return component_1
        case 2: return component_2
        case 3: return component_3
        case 4: return component_4
        default: fatalError()
        }
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        default: fatalError()
        }
    }
}

public struct Device6ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 6
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return component_0
        case 1: return component_1
        case 2: return component_2
        case 3: return component_3
        case 4: return component_4
        case 5: return component_5
        default: fatalError()
        }
    }
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        default: fatalError()
        }
    }
}

public struct Device7ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 7
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    
    @_inlineable
    public init() {
        self.component_0 = 0
        self.component_1 = 0
        self.component_2 = 0
        self.component_3 = 0
        self.component_4 = 0
        self.component_5 = 0
        self.component_6 = 0
    }
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        default: fatalError()
        }
    }
}

public struct Device8ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 8
    }
    
    public var component_0: Double
    public var component_1: Double
    public var component_2: Double
    public var component_3: Double
    public var component_4: Double
    public var component_5: Double
    public var component_6: Double
    public var component_7: Double
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        default: fatalError()
        }
    }
}

public struct Device9ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 9
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        default: fatalError()
        }
    }
}

public struct Device10ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 10
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        default: fatalError()
        }
    }
}

public struct Device11ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 11
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        case 10: component_10 = value
        default: fatalError()
        }
    }
}

public struct Device12ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 12
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        case 10: component_10 = value
        case 11: component_11 = value
        default: fatalError()
        }
    }
}

public struct Device13ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 13
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        case 10: component_10 = value
        case 11: component_11 = value
        case 12: component_12 = value
        default: fatalError()
        }
    }
}

public struct Device14ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 14
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        case 10: component_10 = value
        case 11: component_11 = value
        case 12: component_12 = value
        case 13: component_13 = value
        default: fatalError()
        }
    }
}

public struct Device15ColorModel : DeviceNColorModelProtocol {
    
    @_inlineable
    public static var count: Int {
        return 15
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
    
    @_inlineable
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
    
    @_inlineable
    public func component(_ index: Int) -> Double {
        switch index {
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
    
    @_inlineable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: component_0 = value
        case 1: component_1 = value
        case 2: component_2 = value
        case 3: component_3 = value
        case 4: component_4 = value
        case 5: component_5 = value
        case 6: component_6 = value
        case 7: component_7 = value
        case 8: component_8 = value
        case 9: component_9 = value
        case 10: component_10 = value
        case 11: component_11 = value
        case 12: component_12 = value
        case 13: component_13 = value
        case 14: component_14 = value
        default: fatalError()
        }
    }
}

