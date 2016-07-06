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

private enum jValue {
    
    case null
    case bool(Swift.Bool)
    case integer(Swift.IntMax)
    case float(Swift.Double)
    case string(Swift.String)
    case array([Json])
    case object([Swift.String: Json])
}

public struct Json {
    
    private var value: jValue
    
    public init(_ val: Bool) {
        self.value = .bool(val)
    }
    public init<S : SignedInteger>(_ val: S) {
        self.value = .integer(val.toIntMax())
    }
    public init(_ val: Float) {
        self.value = .float(Double(val))
    }
    public init(_ val: Double) {
        self.value = .float(val)
    }
    public init(_ val: String) {
        self.value = .string(val)
    }
    public init(_ val: [Json]) {
        self.value = .array(val)
    }
    public init(_ val: [String: Json]) {
        self.value = .object(val)
    }
}

extension Json: NilLiteralConvertible {
    
    public init(nilLiteral value: Void) {
        self.value = .null
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
        case .null: return "nil"
        case .bool(let x): return x.description
        case .integer(let x): return x.description
        case .float(let x): return x.description
        case .string(let x): return x
        case .array(let x): return x.description
        case .object(let x): return x.description
        }
    }
    public var debugDescription: String {
        switch self.value {
        case .null: return "nil"
        case .bool(let x): return x.description
        case .integer(let x): return x.description
        case .float(let x): return x.description
        case .string(let x): return x.debugDescription
        case .array(let x): return x.debugDescription
        case .object(let x): return x.debugDescription
        }
    }
}

extension Json {
    
    public var isNull : Bool {
        switch self.value {
        case .null: return true
        default: return false
        }
    }
    
    public var isBool : Bool {
        switch self.value {
        case .bool: return true
        default: return false
        }
    }
    
    public var isNumber : Bool {
        switch self.value {
        case .integer, .float: return true
        default: return false
        }
    }
    
    public var isString : Bool {
        switch self.value {
        case .string: return true
        default: return false
        }
    }
    
    public var isArray : Bool {
        switch self.value {
        case .array: return true
        default: return false
        }
    }
    
    public var isObject : Bool {
        switch self.value {
        case .object: return true
        default: return false
        }
    }
}

extension Json {
    
    var isInteger: Bool {
        switch self.value {
        case .integer: return true
        case .float: return false
        default: return false
        }
    }
    var isFloat: Bool {
        switch self.value {
        case .integer: return false
        case .float: return true
        default: return false
        }
    }
}

extension Json {
    
    public var boolValue: Bool! {
        switch self.value {
        case .bool(let x): return x
        case .integer(let x): return x != 0
        case .float(let x): return x != 0
        default: return nil
        }
    }
    public var intValue: Int! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return Int(truncatingBitPattern: x)
        case .float(let x): return Int(x)
        default: return nil
        }
    }
    public var longIntValue: IntMax! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return x
        case .float(let x): return IntMax(x)
        default: return nil
        }
    }
    public var doubleValue: Double! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return Double(x)
        case .float(let x): return x
        default: return nil
        }
    }
    public var stringValue: String! {
        switch self.value {
        case .string(let x): return x
        default: return nil
        }
    }
}

extension Json {
    
    public var count: Int {
        switch self.value {
        case .array(let x): return x.count
        case .object(let x): return x.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(position: Int) -> Json {
        get {
            switch self.value {
            case .array(let x): return position < x.count ? x[position] : nil
            default: fatalError("Not an array.")
            }
        }
        set {
            switch self.value {
            case .array(var x):
                x[position] = newValue
                self.value = .array(x)
            default: fatalError("Not an array.")
            }
        }
    }
    public subscript(key: String) -> Json {
        get {
            switch self.value {
            case .object(let x): return x[key] ?? nil
            default: fatalError("Not an object.")
            }
        }
        set {
            switch self.value {
            case .object(var x):
                x[key] = newValue
                self.value = .object(x)
            default: fatalError("Not an object.")
            }
        }
    }
}

extension Json {
    
    public var array: [Json]! {
        switch self.value {
        case .array(let x): return x
        default: return nil
        }
    }
    public var dictionary: [String: Json]! {
        switch self.value {
        case .object(let x): return x
        default: return nil
        }
    }
}

private func escapeString(_ source : String, _ result: inout [UInt8]) {
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
    
    public func write(_ data: inout [UInt8]) {
        switch self.value {
        case .null:
            data.append(110)
            data.append(117)
            data.append(108)
            data.append(108)
        case .bool(let x):
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
        case .integer(let x): data.append(contentsOf: String(x).utf8)
        case .float(let x): data.append(contentsOf: String(x).utf8)
        case .string(let x): escapeString(x, &data)
        case .array(let x):
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
        case .object(let x):
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
        return String(cString: UnsafePointer(_data)) ?? ""
    }
}

extension Json : Equatable {
    
}

public func == (lhs: Json, rhs: Json) -> Bool {
    switch lhs.value {
    case .null: return rhs.isNull
    case .bool(let l):
        switch rhs.value {
        case .bool(let r): return l == r
        default: return false
        }
    case .integer(let l):
        switch rhs.value {
        case .integer(let r): return l == r
        case .float(let r): return Double(l) == r
        default: return false
        }
    case .float(let l):
        switch rhs.value {
        case .integer(let r): return l == Double(r)
        case .float(let r): return l == r
        default: return false
        }
    case .string(let l):
        switch rhs.value {
        case .string(let r): return l == r
        default: return false
        }
    case .array(let l):
        switch rhs.value {
        case .array(let r): return l == r
        default: return false
        }
    case .object(let l):
        switch rhs.value {
        case .object(let r): return l == r
        default: return false
        }
    }
}
