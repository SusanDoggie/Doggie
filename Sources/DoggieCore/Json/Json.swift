//
//  Json.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
    
    case number(Number)
    
    case array([Json])
    
    case dictionary([String: Json])
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Json: Sendable { }

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
        self = .number(Number(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self = .number(Number(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self = .number(Number(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self = .number(Number(value))
    }
    
    @inlinable
    public init(_ value: Number) {
        self = .number(value)
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

extension Json: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .null: return "nil"
        case let .boolean(bool): return "\(bool)"
        case let .string(string): return "\"\(string.escaped(asASCII: false))\""
        case let .number(value): return "\(value)"
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
        case .number: return true
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
        case let .number(value): return value.int8Value
        default: return nil
        }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        switch self {
        case let .number(value): return value.uint8Value
        default: return nil
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        switch self {
        case let .number(value): return value.int16Value
        default: return nil
        }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        switch self {
        case let .number(value): return value.uint16Value
        default: return nil
        }
    }
    
    @inlinable
    public var int32Value: Int32? {
        switch self {
        case let .number(value): return value.int32Value
        default: return nil
        }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        switch self {
        case let .number(value): return value.uint32Value
        default: return nil
        }
    }
    
    @inlinable
    public var int64Value: Int64? {
        switch self {
        case let .number(value): return value.int64Value
        default: return nil
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch self {
        case let .number(value): return value.uint64Value
        default: return nil
        }
    }
    
    @inlinable
    public var intValue: Int? {
        switch self {
        case let .number(value): return value.intValue
        default: return nil
        }
    }
    
    @inlinable
    public var uintValue: UInt? {
        switch self {
        case let .number(value): return value.uintValue
        default: return nil
        }
    }
    
    @inlinable
    public var floatValue: Float? {
        switch self {
        case let .number(value): return value.floatValue
        default: return nil
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch self {
        case let .number(value): return value.doubleValue
        default: return nil
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch self {
        case let .number(value): return value.decimalValue
        default: return nil
        }
    }
    
    @inlinable
    public var numberValue: Number? {
        switch self {
        case let .number(value): return value
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
                
                replaceValue(&self) {
                    if index >= value.count {
                        value.append(contentsOf: repeatElement(nil, count: index - value.count + 1))
                    }
                    value[index] = newValue
                    return Json(value)
                }
                
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
            
            replaceValue(&self) {
                value[key] = newValue.isNil ? nil : newValue
                return Json(value)
            }
        }
    }
}
