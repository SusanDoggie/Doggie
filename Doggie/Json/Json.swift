//
//  Json.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

private enum jValue {
    
    case Null
    case Bool(Swift.Bool)
    case Integer(Swift.IntMax)
    case Float(Swift.Double)
    case String(Swift.String)
    case Array([Json])
    case Object([Swift.String: Json])
}

public struct Json {
    
    private var value: jValue
    
    public init(_ val: Bool) {
        self.value = .Bool(val)
    }
    public init<S : SignedIntegerType>(_ val: S) {
        self.value = .Integer(val.toIntMax())
    }
    public init(_ val: Float) {
        self.value = .Float(Double(val))
    }
    public init(_ val: Double) {
        self.value = .Float(val)
    }
    public init(_ val: String) {
        self.value = .String(val)
    }
    public init(_ val: [Json]) {
        self.value = .Array(val)
    }
    public init(_ val: [String: Json]) {
        self.value = .Object(val)
    }
}

extension Json: NilLiteralConvertible {
    
    public init(nilLiteral value: Void) {
        self.value = .Null
    }
}

extension Json: BooleanLiteralConvertible {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension Json: IntegerLiteralConvertible {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Json: FloatLiteralConvertible {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension Json: StringLiteralConvertible {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(value)
    }
}

extension Json: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Json ...) {
        self.init(elements)
    }
}

extension Json: DictionaryLiteralConvertible {
    
    public init(dictionaryLiteral elements: (String, Json) ...) {
        var dictionary = [String: Json](minimumCapacity: elements.count)
        for pair in elements {
            dictionary[pair.0] = pair.1
        }
        self.init(dictionary)
    }
}

extension Json: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self.value {
        case .Null: return "nil"
        case .Bool(let x): return x.description
        case .Integer(let x): return x.description
        case .Float(let x): return x.description
        case .String(let x): return x
        case .Array(let x): return x.description
        case .Object(let x): return x.description
        }
    }
    public var debugDescription: String {
        switch self.value {
        case .Null: return "nil"
        case .Bool(let x): return x.description
        case .Integer(let x): return x.description
        case .Float(let x): return x.description
        case .String(let x): return x.debugDescription
        case .Array(let x): return x.debugDescription
        case .Object(let x): return x.debugDescription
        }
    }
}

extension Json {
    
    public var isNull : Bool {
        switch self.value {
        case .Null: return true
        default: return false
        }
    }
    
    public var isBool : Bool {
        switch self.value {
        case .Bool: return true
        default: return false
        }
    }
    
    public var isNumber : Bool {
        switch self.value {
        case .Integer, .Float: return true
        default: return false
        }
    }
    
    public var isString : Bool {
        switch self.value {
        case .String: return true
        default: return false
        }
    }
    
    public var isArray : Bool {
        switch self.value {
        case .Array: return true
        default: return false
        }
    }
    
    public var isObject : Bool {
        switch self.value {
        case .Object: return true
        default: return false
        }
    }
}

extension Json {
    
    var isInteger: Bool {
        switch self.value {
        case .Integer: return true
        case .Float: return false
        default: return false
        }
    }
    var isFloat: Bool {
        switch self.value {
        case .Integer: return false
        case .Float: return true
        default: return false
        }
    }
}

extension Json {
    
    public var boolValue: Bool! {
        switch self.value {
        case .Bool(let x): return x
        case .Integer(let x): return x != 0
        case .Float(let x): return x != 0
        default: return nil
        }
    }
    public var intValue: Int! {
        switch self.value {
        case .Bool(let x): return x ? 1 : 0
        case .Integer(let x): return Int(truncatingBitPattern: x)
        case .Float(let x): return Int(x)
        default: return nil
        }
    }
    public var longIntValue: IntMax! {
        switch self.value {
        case .Bool(let x): return x ? 1 : 0
        case .Integer(let x): return x
        case .Float(let x): return IntMax(x)
        default: return nil
        }
    }
    public var doubleValue: Double! {
        switch self.value {
        case .Bool(let x): return x ? 1 : 0
        case .Integer(let x): return Double(x)
        case .Float(let x): return x
        default: return nil
        }
    }
    public var stringValue: String! {
        switch self.value {
        case .String(let x): return x
        default: return nil
        }
    }
}

extension Json {
    
    public var count: Int {
        switch self.value {
        case .Array(let x): return x.count
        case .Object(let x): return x.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(idx: Int) -> Json {
        get {
            switch self.value {
            case .Array(let x): return idx < x.count ? x[idx] : nil
            default: fatalError("Not an array.")
            }
        }
        set {
            switch self.value {
            case .Array(var x):
                x[idx] = newValue
                self.value = .Array(x)
            default: fatalError("Not an array.")
            }
        }
    }
    public subscript(key: String) -> Json {
        get {
            switch self.value {
            case .Object(let x): return x[key] ?? nil
            default: fatalError("Not an object.")
            }
        }
        set {
            switch self.value {
            case .Object(var x):
                x[key] = newValue
                self.value = .Object(x)
            default: fatalError("Not an object.")
            }
        }
    }
}

extension Json {
    
    public var array: [Json]! {
        switch self.value {
        case .Array(let x): return x
        default: return nil
        }
    }
    public var dictionary: [String: Json]! {
        switch self.value {
        case .Object(let x): return x
        default: return nil
        }
    }
}

private func escapeString(source : String, inout _ result: [UInt8]) {
    result.append(34)
    for c in source.utf8 {
        switch c {
        case 13:
            result.append(92)
            result.append(114)
        case 10:
            result.append(92)
            result.append(110)
        case 9:
            result.append(92)
            result.append(116)
        case 34, 39, 47, 92:
            result.append(92)
            result.append(c)
        default: result.append(c)
        }
    }
    result.append(34)
}

extension Json {
    
    public func write(inout data: [UInt8]) {
        switch self.value {
        case .Null:
            data.append(110)
            data.append(117)
            data.append(108)
            data.append(108)
        case .Bool(let x):
            if x {
                data.append(116)
                data.append(114)
                data.append(117)
                data.append(101)
            } else {
                data.append(102)
                data.append(97)
                data.append(108)
                data.append(115)
                data.append(101)
            }
        case .Integer(let x): data.appendContentsOf(String(x).utf8)
        case .Float(let x): data.appendContentsOf(String(x).utf8)
        case .String(let x): escapeString(x, &data)
        case .Array(let x):
            data.append(91)
            var flag = false
            for item in x {
                if flag {
                    data.append(44)
                }
                item.write(&data)
                flag = true
            }
            data.append(93)
        case .Object(let x):
            data.append(123)
            var flag = false
            for (key, item) in x {
                if flag {
                    data.append(44)
                }
                escapeString(key, &data)
                data.append(58)
                item.write(&data)
                flag = true
            }
            data.append(125)
        }
    }
    
    public var data: [UInt8] {
        var _data = [UInt8]()
        self.write(&_data)
        return _data
    }
    public var string: String {
        var _data = self.data
        _data.append(0)
        return String.fromCString(UnsafePointer(_data)) ?? ""
    }
}

extension Json : Equatable {
    
}

public func == (lhs: Json, rhs: Json) -> Bool {
    switch lhs.value {
    case .Null: return rhs.isNull
    case .Bool(let l):
        switch rhs.value {
        case .Bool(let r): return l == r
        default: return false
        }
    case .Integer(let l):
        switch rhs.value {
        case .Integer(let r): return l == r
        case .Float(let r): return Double(l) == r
        default: return false
        }
    case .Float(let l):
        switch rhs.value {
        case .Integer(let r): return l == Double(r)
        case .Float(let r): return l == r
        default: return false
        }
    case .String(let l):
        switch rhs.value {
        case .String(let r): return l == r
        default: return false
        }
    case .Array(let l):
        switch rhs.value {
        case .Array(let r): return l == r
        default: return false
        }
    case .Object(let l):
        switch rhs.value {
        case .Object(let r): return l == r
        default: return false
        }
    }
}