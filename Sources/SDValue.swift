//
//  SDValue.swift
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

public enum SDValue {
    
    case none
    case bool(Bool)
    case int(IntMax)
    case uint(UIntMax)
    case float(Double)
    case string(String)
    case array([SDValue])
    case object([String: SDValue])
    case any(Any)
}

extension SDValue {
    
    public init(_ val: Bool) {
        self = .bool(val)
    }
    public init<S : SignedInteger>(_ val: S) {
        self = .int(val.toIntMax())
    }
    public init<S : UnsignedInteger>(_ val: S) {
        self = .uint(val.toUIntMax())
    }
    public init(_ val: Float) {
        self = .float(Double(val))
    }
    public init(_ val: Double) {
        self = .float(val)
    }
    public init(_ val: String) {
        self = .string(val)
    }
    public init(_ val: [String: SDValue]) {
        self = .object(val)
    }
    public init<S : Sequence>(_ val: S) where S.Iterator.Element == SDValue {
        self = .array(Array(val))
    }
    public init(any: Any) {
        self = .any(any)
    }
}

extension SDValue : ExpressibleByNilLiteral {
    
    public init(nilLiteral: ()){
        self = .none
    }
}

extension SDValue: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension SDValue: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension SDValue: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension SDValue: ExpressibleByStringLiteral {
    
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

extension SDValue: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: SDValue ...) {
        self.init(elements)
    }
}

extension SDValue: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, SDValue) ...) {
        var dictionary: [String: SDValue] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self = .object(dictionary)
    }
}

extension SDValue {
    
    fileprivate var value: Any? {
        switch self {
        case .none: return nil
        case let .bool(bool): return bool
        case let .int(int): return int
        case let .uint(uint): return uint
        case let .float(float): return float
        case let .string(string): return string
        case let .array(array): return array
        case let .object(object): return object
        case let .any(any): return any
        }
    }
}

extension SDValue: CustomStringConvertible {
    
    public var description: String {
        if let value = self.value {
            return "\(value)"
        }
        return "nil"
    }
}

extension SDValue {
    
    public var isNil : Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
    
    public var isBool : Bool {
        switch self {
        case .bool(_): return true
        default: return false
        }
    }
    
    public var isUnsignedInteger : Bool {
        switch self {
        case .uint(_): return true
        default: return false
        }
    }
    
    public var isSignedInteger : Bool {
        switch self {
        case .int(_): return true
        default: return false
        }
    }
    
    public var isInteger : Bool {
        switch self {
        case .int(_): return true
        case .uint(_): return true
        default: return false
        }
    }
    
    public var isString : Bool {
        switch self {
        case .string(_): return true
        default: return false
        }
    }
    
    public var isArray : Bool {
        switch self {
        case .array(_): return true
        default: return false
        }
    }
    
    public var isObject : Bool {
        switch self {
        case .object(_): return true
        default: return false
        }
    }
    
    public var isAny : Bool {
        switch self {
        case .any(_): return true
        default: return false
        }
    }
}

extension SDValue {
    
    public var boolValue: Bool? {
        get {
            switch self {
            case let .bool(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var int8Value: Int8? {
        get {
            switch self {
            case let .int(value): return Int8(exactly: value)
            case let .uint(value): return Int8(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var uint8Value: UInt8? {
        get {
            switch self {
            case let .int(value): return UInt8(exactly: value)
            case let .uint(value): return UInt8(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var int16Value: Int16? {
        get {
            switch self {
            case let .int(value): return Int16(exactly: value)
            case let .uint(value): return Int16(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var uint16Value: UInt16? {
        get {
            switch self {
            case let .int(value): return UInt16(exactly: value)
            case let .uint(value): return UInt16(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var int32Value: Int32? {
        get {
            switch self {
            case let .int(value): return Int32(exactly: value)
            case let .uint(value): return Int32(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var uint32Value: UInt32? {
        get {
            switch self {
            case let .int(value): return UInt32(exactly: value)
            case let .uint(value): return UInt32(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var int64Value: Int64? {
        get {
            switch self {
            case let .int(value): return Int64(exactly: value)
            case let .uint(value): return Int64(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var uint64Value: UInt64? {
        get {
            switch self {
            case let .int(value): return UInt64(exactly: value)
            case let .uint(value): return UInt64(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var floatValue: Float? {
        get {
            switch self {
            case let .float(value): return Float(value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var doubleValue: Double? {
        get {
            switch self {
            case let .float(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var intValue: Int? {
        get {
            switch self {
            case let .int(value): return Int(exactly: value)
            case let .uint(value): return Int(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    
    public var uintValue: UInt? {
        get {
            switch self {
            case let .int(value): return UInt(exactly: value)
            case let .uint(value): return UInt(exactly: value)
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    public var stringValue: String? {
        get {
            switch self {
            case let .string(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    public var array: [SDValue]? {
        get {
            switch self {
            case let .array(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    public var dictionary: [String: SDValue]? {
        get {
            switch self {
            case let .object(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(value)
            } else {
                self = nil
            }
        }
    }
    public var anyValue: Any? {
        get {
            switch self {
            case let .any(value): return value
            default: return nil
            }
        }
        set {
            if let value = newValue {
                self = SDValue(any: value)
            } else {
                self = nil
            }
        }
    }
}

extension SDValue {
    
    public var count: Int {
        switch self {
        case let .array(array): return array.count
        case let .object(object): return object.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(index: Int) -> SDValue {
        get {
            if case let .array(array) = self {
                return array[index]
            }
            return nil
        }
        set {
            switch self {
            case var .array(array):
                array[index] = newValue
                self = SDValue(array)
            default: fatalError("Not an array.")
            }
        }
    }
    
    public subscript(key: String) -> SDValue {
        get {
            if case let .object(object) = self, let val = object[key] {
                return val
            }
            return nil
        }
        set {
            switch self {
            case var .object(object):
                if case .none = newValue {
                    object[key] = nil
                } else {
                    object[key] = newValue
                }
                self = SDValue(object)
            default: fatalError("Not an object.")
            }
        }
    }
}

extension SDValue {
    
    public func json() -> String {
        var str = ""
        self.writeJson { str.append($0) }
        return str
    }
    
    private static func writeStringToJson(_ str: String, _ writer: (String) -> Void) {
        writer("\"")
        for scalar in str.unicodeScalars {
            switch scalar {
            case "\"":
                writer("\\\"") // U+0022 quotation mark
            case "\\":
                writer("\\\\") // U+005C reverse solidus
                               // U+002F solidus not escaped
            case "\u{8}":
                writer("\\b") // U+0008 backspace
            case "\u{c}":
                writer("\\f") // U+000C form feed
            case "\n":
                writer("\\n") // U+000A line feed
            case "\r":
                writer("\\r") // U+000D carriage return
            case "\t":
                writer("\\t") // U+0009 tab
            case "\u{0}"..."\u{f}":
                writer("\\u000\(String(scalar.value, radix: 16))") // U+0000 to U+000F
            case "\u{10}"..."\u{1f}":
                writer("\\u00\(String(scalar.value, radix: 16))") // U+0010 to U+001F
            default:
                writer(String(scalar))
            }
        }
        writer("\"")
    }
    
    private func writeJson(_ writer: (String) -> Void) {
        switch self {
        case .none: writer("null")
        case let .bool(bool): writer("\(bool)")
        case let .int(int): writer("\(int)")
        case let .uint(uint): writer("\(uint)")
        case let .float(float): writer("\(float)")
        case let .string(string): SDValue.writeStringToJson(string, writer)
        case let .array(array):
            writer("[")
            var first = true
            for item in array {
                if first {
                    first = false
                } else {
                    writer(",")
                }
                item.writeJson(writer)
            }
            writer("]")
        case let .object(object):
            writer("{")
            var first = true
            for (key, value) in object {
                if first {
                    first = false
                } else {
                    writer(",")
                }
                SDValue.writeStringToJson(key, writer)
                writer(":")
                value.writeJson(writer)
            }
            writer("}")
        default: break
        }
    }
}
