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

public enum JsonType: Hashable {
    
    case null
    case boolean
    case string
    case number
    case array
    case dictionary
}

@frozen
public struct Json: Hashable {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    public init(_ value: Bool) {
        self.base = .boolean(value)
    }
    
    @inlinable
    public init(_ value: String) {
        self.base = .string(value)
    }
    
    @inlinable
    public init<S: StringProtocol>(_ value: S) {
        self.base = .string(String(value))
    }
    
    @inlinable
    public init<T: BinaryInteger>(_ value: T) {
        self.base = .number(Number(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self.base = .number(Number(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self.base = .number(Number(value))
    }
    
    @inlinable
    init(_ value: Number) {
        self.base = .number(value)
    }
    
    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element == Json {
        self.base = .array(Array(elements))
    }
    
    @inlinable
    public init(_ elements: [String: Json]) {
        self.base = .dictionary(elements)
    }
    
    @inlinable
    public init(_ elements: OrderedDictionary<String, Json>) {
        self.base = .dictionary(Dictionary(uniqueKeysWithValues: elements.lazy.map { ($0.key, $0.value) }))
    }
}

extension Json {
    
    @usableFromInline
    struct Number: Hashable {
        
        @usableFromInline
        var int64: Int64?
        
        @usableFromInline
        var uint64: UInt64?
        
        @usableFromInline
        var decimal: Decimal?
        
        @usableFromInline
        var double: Double
        
        @inlinable
        init(int64: Int64?, uint64: UInt64?, decimal: Decimal?, double: Double) {
            self.int64 = int64
            self.uint64 = uint64
            self.decimal = decimal
            self.double = double
        }
        
        @inlinable
        init<T: BinaryInteger>(_ value: T) {
            self.int64 = Int64(exactly: value)
            self.uint64 = UInt64(exactly: value)
            self.decimal = UInt64(exactly: value).map(Decimal.init) ?? Int64(exactly: value).map(Decimal.init) ?? Decimal(exactly: value)
            self.double = Double(value)
        }
        
        @inlinable
        init(_ value: Decimal) {
            self.decimal = value
            self.double = value.doubleValue
        }
        
        @inlinable
        init<T: BinaryFloatingPoint>(_ value: T) {
            self.int64 = Int64(exactly: value)
            self.uint64 = UInt64(exactly: value)
            self.double = Double(value)
        }
    }
    
}

extension Json: ExpressibleByNilLiteral {
    
    @inlinable
    public init(nilLiteral value: Void) {
        self.base = .null
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
        switch self.base {
        case .null: return "nil"
        case let .boolean(bool): return "\(bool)"
        case let .string(string): return "\"\(string.escaped(asASCII: false))\""
        case let .number(number): return "\(number.double)"
        case let .array(array): return "\(array)"
        case let .dictionary(dictionary): return "\(dictionary)"
        }
    }
}

extension Json {
    
    @inlinable
    public var type: JsonType {
        return base.type
    }
    
    @inlinable
    public var isNil: Bool {
        return type == .null
    }
    
    @inlinable
    public var isBool: Bool {
        return type == .boolean
    }
    
    @inlinable
    public var isString: Bool {
        return type == .string
    }
    
    @inlinable
    public var isArray: Bool {
        return type == .array
    }
    
    @inlinable
    public var isObject: Bool {
        return type == .dictionary
    }
    
    @inlinable
    public var isNumber: Bool {
        return type == .number
    }
}

extension Json {
    
    @usableFromInline
    enum Base: Hashable {
        case null
        case boolean(Bool)
        case string(String)
        case number(Number)
        case array([Json])
        case dictionary([String: Json])
    }
}

extension Json.Base {
    
    @inlinable
    var type: JsonType {
        switch self {
        case .null: return .null
        case .boolean: return .boolean
        case .string: return .string
        case .number: return .number
        case .array: return .array
        case .dictionary: return .dictionary
        }
    }
    
    @inlinable
    var boolValue: Bool? {
        switch self {
        case let .boolean(value): return value
        default: return nil
        }
    }
    
    @inlinable
    var int64Value: Int64? {
        switch self {
        case let .number(value): return value.int64 ?? Int64(exactly: value.double)
        default: return nil
        }
    }
    
    @inlinable
    var uint64Value: UInt64? {
        switch self {
        case let .number(value): return value.uint64 ?? UInt64(exactly: value.double)
        default: return nil
        }
    }
    
    @inlinable
    var decimalValue: Decimal? {
        switch self {
        case let .number(value): return value.decimal ?? Decimal(value.double)
        default: return nil
        }
    }
    
    @inlinable
    var doubleValue: Double? {
        switch self {
        case let .number(value): return value.double
        default: return nil
        }
    }
    
    @inlinable
    var stringValue: String? {
        switch self {
        case let .string(value): return value
        default: return nil
        }
    }
    
    @inlinable
    var array: [Json]? {
        switch self {
        case let .array(value): return value
        default: return nil
        }
    }
    
    @inlinable
    var dictionary: [String: Json]? {
        switch self {
        case let .dictionary(value): return value
        default: return nil
        }
    }
}

extension Json {
    
    @inlinable
    public var boolValue: Bool? {
        return base.boolValue
    }
    
    @inlinable
    public var int8Value: Int8? {
        return int64Value.flatMap { Int8(exactly: $0) }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        return uint64Value.flatMap { UInt8(exactly: $0) }
    }
    
    @inlinable
    public var int16Value: Int16? {
        return int64Value.flatMap { Int16(exactly: $0) }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        return uint64Value.flatMap { UInt16(exactly: $0) }
    }
    
    @inlinable
    public var int32Value: Int32? {
        return int64Value.flatMap { Int32(exactly: $0) }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        return uint64Value.flatMap { UInt32(exactly: $0) }
    }
    
    @inlinable
    public var intValue: Int? {
        return int64Value.flatMap { Int(exactly: $0) }
    }
    
    @inlinable
    public var uintValue: UInt? {
        return uint64Value.flatMap { UInt(exactly: $0) }
    }
    
    @inlinable
    public var int64Value: Int64? {
        return base.int64Value
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        return base.uint64Value
    }
    
    @inlinable
    public var doubleValue: Double? {
        return base.doubleValue
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        return base.decimalValue
    }
    @inlinable
    public var stringValue: String? {
        return base.stringValue
    }
    @inlinable
    public var array: [Json]? {
        return base.array
    }
    @inlinable
    public var dictionary: [String: Json]? {
        return base.dictionary
    }
}

extension Json {
    
    @inlinable
    public var count: Int {
        switch base {
        case let .array(value): return value.count
        case let .dictionary(value): return value.count
        default: fatalError("Not an array or object.")
        }
    }
    
    @inlinable
    public subscript(index: Int) -> Json {
        get {
            guard 0..<count ~= index else { return nil }
            switch base {
            case let .array(value): return value[index]
            default: return nil
            }
        }
        set {
            switch base {
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
        guard case let .dictionary(value) = base else { return [:].keys }
        return value.keys
    }
    
    @inlinable
    public subscript(key: String) -> Json {
        get {
            guard case let .dictionary(value) = base else { return nil }
            return value[key] ?? nil
        }
        set {
            guard case var .dictionary(value) = base else { fatalError("Not an object.") }
            value[key] = newValue.isNil ? nil : newValue
            self = Json(value)
        }
    }
}

extension Json: Encodable {
    
    @usableFromInline
    struct CodingKey: Swift.CodingKey {
        
        @usableFromInline
        var stringValue: String
        
        @usableFromInline
        var intValue: Int? { nil }
        
        @inlinable
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        @inlinable
        init?(intValue: Int) {
            return nil
        }
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        
        switch self.base {
        case .null:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            
        case let .boolean(bool):
            
            var container = encoder.singleValueContainer()
            try container.encode(bool)
            
        case let .string(string):
            
            var container = encoder.singleValueContainer()
            try container.encode(string)
            
        case let .number(number):
            
            var container = encoder.singleValueContainer()
            
            if let value = number.decimal {
                try container.encode(value)
            } else {
                try container.encode(number.double)
            }
            
        case let .array(array):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: array)
            
        case let .dictionary(dictionary):
            
            var container = encoder.container(keyedBy: CodingKey.self)
            
            for (key, value) in dictionary {
                try container.encode(value, forKey: CodingKey(stringValue: key))
            }
        }
    }
}

extension Json: Decodable {
    
    @inlinable
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.init(nilLiteral: ())
            return
        }
        
        if let bool = try? container.decode(Bool.self) {
            self.init(bool)
            return
        }
        
        if let double = try? container.decode(Double.self) {
            
            let int64 = try? container.decode(Int64.self)
            let uint64 = try? container.decode(UInt64.self)
            let decimal = try? container.decode(Decimal.self)
            
            self.init(Number(int64: int64, uint64: uint64, decimal: decimal, double: double))
            return
        }
        
        if let string = try? container.decode(String.self) {
            self.init(string)
            return
        }
        
        if let array = try? container.decode([Json].self) {
            self.init(array)
            return
        }
        
        if let object = try? container.decode([String: Json].self) {
            self.init(object)
            return
        }
        
        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Attempted to decode Json from unknown structure.")
        )
    }
}

extension Json {
    
    @inlinable
    public init(decode string: String) throws {
        self = try JSONDecoder().decode(Json.self, from: string._utf8_data)
    }
    
    @inlinable
    public init(decode data: Data) throws {
        self = try JSONDecoder().decode(Json.self, from: data)
    }
    
    @inlinable
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: url, options: options))
    }
    
    @inlinable
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: URL(fileURLWithPath: path), options: options))
    }
}

extension Json {
    
    @inlinable
    public func data(prettyPrinted: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting.insert(.prettyPrinted)
        }
        return try? encoder.encode(self)
    }
    
    @inlinable
    public func json(prettyPrinted: Bool = false) -> String? {
        guard let data = self.data(prettyPrinted: prettyPrinted) else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
