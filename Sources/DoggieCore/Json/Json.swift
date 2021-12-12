//
//  Json.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public enum Json: Hashable {
    
    case null
    
    case boolean(Bool)
    
    case string(String)
    
    case signed(Int64)
    
    case unsigned(UInt64)
    
    case number(Double)
    
    case decimal(Decimal)
    
    case array([Json])
    
    case dictionary([String: Json])
    
}

extension Json {
    
    @inlinable
    public init(_ value: Bool) {
        self = .boolean(value)
    }
    
    @inlinable
    public init(_ value: String) {
        self = .string(value)
    }
    
    @inlinable
    public init<S: StringProtocol>(_ value: S) {
        self = .string(String(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self = .signed(Int64(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self = .unsigned(UInt64(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self = .number(Double(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self = .decimal(value)
    }
    
    @inlinable
    public init<Wrapped: JsonConvertible>(_ value: Wrapped?) {
        self = value.toJson()
    }
    
    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element: JsonConvertible {
        self = .array(elements.map { $0.toJson() })
    }
    
    @inlinable
    public init<Value: JsonConvertible>(_ elements: [String: Value]) {
        self = .dictionary(elements.mapValues { $0.toJson() })
    }
    
    @inlinable
    public init<Value: JsonConvertible>(_ elements: OrderedDictionary<String, Value>) {
        self = .dictionary(Dictionary(elements.mapValues { $0.toJson() }))
    }
}

extension Json: ExpressibleByNilLiteral {
    
    @inlinable
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension Json: ExpressibleByBooleanLiteral {
    
    @inlinable
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByIntegerLiteral {
    
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByFloatLiteral {
    
    @inlinable
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByStringInterpolation {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    @inlinable
    public init(stringInterpolation: String.StringInterpolation) {
        self.init(String(stringInterpolation: stringInterpolation))
    }
}

extension Json: ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: Json ...) {
        self.init(elements)
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    
    @inlinable
    public init(dictionaryLiteral elements: (String, Json) ...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension Json {
    
    @inlinable
    public static func ==(lhs: Json, rhs: Json) -> Bool {
        switch (lhs, rhs) {
        case (.null, .null): return true
        case let (.boolean(lhs), .boolean(rhs)): return lhs == rhs
        case let (.string(lhs), .string(rhs)): return lhs == rhs
        case let (.signed(lhs), .signed(rhs)): return lhs == rhs
        case let (.signed(lhs), .unsigned(rhs)): return lhs == rhs
        case let (.signed(lhs), .number(rhs)): return lhs == Int64(exactly: rhs)
        case let (.signed(lhs), .decimal(rhs)): return lhs == Int64(exactly: rhs)
        case let (.unsigned(lhs), .signed(rhs)): return lhs == rhs
        case let (.unsigned(lhs), .unsigned(rhs)): return lhs == rhs
        case let (.unsigned(lhs), .number(rhs)): return lhs == UInt64(exactly: rhs)
        case let (.unsigned(lhs), .decimal(rhs)): return lhs == UInt64(exactly: rhs)
        case let (.number(lhs), .signed(rhs)): return Int64(exactly: lhs) == rhs
        case let (.number(lhs), .unsigned(rhs)): return UInt64(exactly: lhs) == rhs
        case let (.number(lhs), .number(rhs)): return lhs == rhs
        case let (.number(lhs), .decimal(rhs)): return lhs == rhs.doubleValue
        case let (.decimal(lhs), .signed(rhs)): return Int64(exactly: lhs) == rhs
        case let (.decimal(lhs), .unsigned(rhs)): return UInt64(exactly: lhs) == rhs
        case let (.decimal(lhs), .number(rhs)): return lhs.doubleValue == rhs
        case let (.decimal(lhs), .decimal(rhs)): return lhs == rhs
        case let (.array(lhs), .array(rhs)): return lhs == rhs
        case let (.dictionary(lhs), .dictionary(rhs)): return lhs == rhs
        default: return false
        }
    }
}

extension Json: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .null: return "nil"
        case let .boolean(bool): return "\(bool)"
        case let .string(string): return "\"\(string.escaped(asASCII: false))\""
        case let .signed(value): return "\(value)"
        case let .unsigned(value): return "\(value)"
        case let .number(value): return "\(value)"
        case let .decimal(value): return "\(value)"
        case let .array(array): return "\(array)"
        case let .dictionary(dictionary): return "\(dictionary)"
        }
    }
}

extension Json {
    
    @inlinable
    public var isNil: Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }
    
    @inlinable
    public var isBool: Bool {
        switch self {
        case .boolean: return true
        default: return false
        }
    }
    
    @inlinable
    public var isString: Bool {
        switch self {
        case .string: return true
        default: return false
        }
    }
    
    @inlinable
    public var isArray: Bool {
        switch self {
        case .array: return true
        default: return false
        }
    }
    
    @inlinable
    public var isObject: Bool {
        switch self {
        case .dictionary: return true
        default: return false
        }
    }
    
    @inlinable
    public var isNumber: Bool {
        switch self {
        case .signed: return true
        case .unsigned: return true
        case .number: return true
        case .decimal: return true
        default: return false
        }
    }
}

extension Json {
    
    @inlinable
    public var boolValue: Bool? {
        switch self {
        case let .boolean(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var int8Value: Int8? {
        switch self {
        case let .signed(value): return Int8(exactly: value)
        case let .unsigned(value): return Int8(exactly: value)
        case let .number(value): return Int8(exactly: value)
        case let .decimal(value): return Int8(exactly: value)
        case let .string(string): return Int8(string)
        default: return nil
        }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        switch self {
        case let .signed(value): return UInt8(exactly: value)
        case let .unsigned(value): return UInt8(exactly: value)
        case let .number(value): return UInt8(exactly: value)
        case let .decimal(value): return UInt8(exactly: value)
        case let .string(string): return UInt8(string)
        default: return nil
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        switch self {
        case let .signed(value): return Int16(exactly: value)
        case let .unsigned(value): return Int16(exactly: value)
        case let .number(value): return Int16(exactly: value)
        case let .decimal(value): return Int16(exactly: value)
        case let .string(string): return Int16(string)
        default: return nil
        }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        switch self {
        case let .signed(value): return UInt16(exactly: value)
        case let .unsigned(value): return UInt16(exactly: value)
        case let .number(value): return UInt16(exactly: value)
        case let .decimal(value): return UInt16(exactly: value)
        case let .string(string): return UInt16(string)
        default: return nil
        }
    }
    
    @inlinable
    public var int32Value: Int32? {
        switch self {
        case let .signed(value): return Int32(exactly: value)
        case let .unsigned(value): return Int32(exactly: value)
        case let .number(value): return Int32(exactly: value)
        case let .decimal(value): return Int32(exactly: value)
        case let .string(string): return Int32(string)
        default: return nil
        }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        switch self {
        case let .signed(value): return UInt32(exactly: value)
        case let .unsigned(value): return UInt32(exactly: value)
        case let .number(value): return UInt32(exactly: value)
        case let .decimal(value): return UInt32(exactly: value)
        case let .string(string): return UInt32(string)
        default: return nil
        }
    }
    
    @inlinable
    public var int64Value: Int64? {
        switch self {
        case let .signed(value): return value
        case let .unsigned(value): return Int64(exactly: value)
        case let .number(value): return Int64(exactly: value)
        case let .decimal(value): return Int64(exactly: value)
        case let .string(string): return Int64(string)
        default: return nil
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch self {
        case let .signed(value): return UInt64(exactly: value)
        case let .unsigned(value): return value
        case let .number(value): return UInt64(exactly: value)
        case let .decimal(value): return UInt64(exactly: value)
        case let .string(string): return UInt64(string)
        default: return nil
        }
    }
    
    @inlinable
    public var intValue: Int? {
        switch self {
        case let .signed(value): return Int(exactly: value)
        case let .unsigned(value): return Int(exactly: value)
        case let .number(value): return Int(exactly: value)
        case let .decimal(value): return Int(exactly: value)
        case let .string(string): return Int(string)
        default: return nil
        }
    }
    
    @inlinable
    public var uintValue: UInt? {
        switch self {
        case let .signed(value): return UInt(exactly: value)
        case let .unsigned(value): return UInt(exactly: value)
        case let .number(value): return UInt(exactly: value)
        case let .decimal(value): return UInt(exactly: value)
        case let .string(string): return UInt(string)
        default: return nil
        }
    }
    
    @inlinable
    public var floatValue: Float? {
        switch self {
        case let .signed(value): return Float(exactly: value)
        case let .unsigned(value): return Float(exactly: value)
        case let .number(value): return Float(value)
        case let .decimal(value): return Float(exactly: value)
        case let .string(string): return Float(string)
        default: return nil
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch self {
        case let .signed(value): return Double(exactly: value)
        case let .unsigned(value): return Double(exactly: value)
        case let .number(value): return value
        case let .decimal(value): return Double(exactly: value)
        case let .string(string): return Double(string)
        default: return nil
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch self {
        case let .signed(value): return Decimal(exactly: value)
        case let .unsigned(value): return Decimal(exactly: value)
        case let .number(value): return Decimal(exactly: value)
        case let .decimal(value): return value
        case let .string(string): return Decimal(exactly: string)
        default: return nil
        }
    }
    
    @inlinable
    public var stringValue: String? {
        switch self {
        case let .string(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var array: [Json]? {
        switch self {
        case let .array(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var dictionary: [String: Json]? {
        switch self {
        case let .dictionary(value): return value
        default: return nil
        }
    }
}

extension Json {
    
    @inlinable
    public var count: Int {
        switch self {
        case let .array(value): return value.count
        case let .dictionary(value): return value.count
        default: fatalError("Not an array or object.")
        }
    }
    
    @inlinable
    public subscript(index: Int) -> Json {
        get {
            guard 0..<count ~= index else { return nil }
            switch self {
            case let .array(value): return value[index]
            default: return nil
            }
        }
        set {
            switch self {
            case var .array(value):
                
                if index >= value.count {
                    value.append(contentsOf: repeatElement(nil, count: index - value.count + 1))
                }
                value[index] = newValue
                self = Json(value)
                
            default: fatalError("Not an array.")
            }
        }
    }
    
    @inlinable
    public var keys: Dictionary<String, Json>.Keys {
        guard case let .dictionary(value) = self else { return [:].keys }
        return value.keys
    }
    
    @inlinable
    public subscript(key: String) -> Json {
        get {
            guard case let .dictionary(value) = self else { return nil }
            return value[key] ?? nil
        }
        set {
            guard case var .dictionary(value) = self else { fatalError("Not an object.") }
            value[key] = newValue.isNil ? nil : newValue
            self = Json(value)
        }
    }
}
