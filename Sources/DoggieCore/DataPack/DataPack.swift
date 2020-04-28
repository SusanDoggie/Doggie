//
//  DataPack.swift
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

public enum DataPackType: Hashable {
    
    case null
    case boolean
    case string
    case signed
    case unsigned
    case number
    case binary
    case uuid
    case array
    case dictionary
    case unknown(UInt8)
}

@frozen
public struct DataPack {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    init(_ base: Base) {
        self.base = base.dictionary.map { .dictionary($0) } ?? base
    }
    
    @inlinable
    public init(decode data: Data) {
        self.init(.undecoded(SDUndecodedObject(data: data)))
    }
    
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
    public init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self.base = .signed(Int64(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self.base = .unsigned(UInt64(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self.base = .number(Double(value))
    }
    
    @inlinable
    public init(_ binary: Data) {
        self.base = .binary(binary)
    }
    
    @inlinable
    public init(_ uuid: UUID) {
        self.base = .uuid(uuid)
    }
    
    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element == DataPack {
        self.base = .array(Array(elements))
    }
    
    @inlinable
    public init(_ elements: [String: DataPack]) {
        self.base = .dictionary(elements)
    }
}

extension DataPack: ExpressibleByNilLiteral {
    
    @inlinable
    public init(nilLiteral value: Void) {
        self.base = .null
    }
}

extension DataPack: ExpressibleByBooleanLiteral {
    
    @inlinable
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension DataPack: ExpressibleByIntegerLiteral {
    
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension DataPack: ExpressibleByFloatLiteral {
    
    @inlinable
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension DataPack: ExpressibleByStringLiteral {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension DataPack: ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: DataPack ...) {
        self.init(elements)
    }
}

extension DataPack: ExpressibleByDictionaryLiteral {
    
    @inlinable
    public init(dictionaryLiteral elements: (String, DataPack) ...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension DataPack: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch type {
        case .null: return "nil"
        case .boolean: return "\(boolValue!)"
        case .string: return "\"\(string!.escaped(asASCII: false))\""
        case .signed: return "\(int64Value!)"
        case .unsigned: return "\(uint64Value!)"
        case .number: return "\(doubleValue!)"
        case .binary: return "\(binary!)"
        case .uuid: return "\(uuid!)"
        case .array: return "\(array!)"
        case .dictionary: return "\(dictionary!)"
        case .unknown(_): return "unknown"
        }
    }
}

extension DataPack: Hashable {
    
    @inlinable
    public static func == (lhs: DataPack, rhs: DataPack) -> Bool {
        switch (lhs.type, rhs.type) {
        case (.null, .null): return true
        case (.boolean, .boolean): return lhs.boolValue == rhs.boolValue
        case (.string, .string): return lhs.string == rhs.string
        case (.signed, .signed): return lhs.int64Value == rhs.int64Value
        case (.unsigned, .unsigned): return lhs.uint64Value == rhs.uint64Value
        case (.number, .number): return lhs.doubleValue == rhs.doubleValue
        case (.binary, .binary): return lhs.binary == rhs.binary
        case (.uuid, .uuid): return lhs.uuid == rhs.uuid
        case (.array, .array): return lhs.array == rhs.array
        case (.dictionary, .dictionary): return lhs.dictionary == rhs.dictionary
        default: return false
        }
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        switch type {
        case .boolean: hasher.combine(boolValue!)
        case .string: hasher.combine(string!)
        case .signed: hasher.combine(int64Value!)
        case .unsigned: hasher.combine(uint64Value!)
        case .number: hasher.combine(doubleValue!)
        case .binary: hasher.combine(binary!)
        case .uuid: hasher.combine(uuid!)
        case .array: hasher.combine(array!)
        case .dictionary: hasher.combine(dictionary!)
        default: break
        }
    }
}

extension DataPack {
    
    @inlinable
    public func encode() -> Data {
        var result = MappedBuffer<UInt8>()
        base.encode(to: &result)
        return result.data
    }
}

extension DataPack {
    
    @inlinable
    public var type: DataPackType {
        return base.type
    }
    
    @inlinable
    public var isUnknownType: Bool {
        switch type {
        case .unknown(_): return true
        default: return false
        }
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
    public var isSigned: Bool {
        return type == .signed
    }
    
    @inlinable
    public var isUnsigned: Bool {
        return type == .unsigned
    }
    
    @inlinable
    public var isNumber: Bool {
        return type == .number
    }
    
    @inlinable
    public var isNumeric: Bool {
        switch type {
        case .signed: return true
        case .unsigned: return true
        case .number: return true
        default: return false
        }
    }
    
    @inlinable
    public var isBinary: Bool {
        return type == .binary
    }
    
    @inlinable
    public var isUUID: Bool {
        return type == .uuid
    }
}

extension DataPack {
    
    @usableFromInline
    enum Base {
        case null
        case boolean(Bool)
        case string(String)
        case signed(Int64)
        case unsigned(UInt64)
        case number(Double)
        case binary(Data)
        case uuid(UUID)
        case array([DataPack])
        case dictionary([String:DataPack])
        case undecoded(SDUndecodedObject)
    }
}

extension DataPack.Base {
    
    @inlinable
    var type: DataPackType {
        switch self {
        case .null: return .null
        case .boolean(_): return .boolean
        case .string(_): return .string
        case .signed(_): return .signed
        case .unsigned(_): return .unsigned
        case .number(_): return .number
        case .binary(_): return .binary
        case .uuid(_): return .uuid
        case .array(_): return .array
        case .dictionary(_): return .dictionary
        case let .undecoded(value): return value.type
        }
    }
    
    @inlinable
    var boolValue: Bool? {
        switch self {
        case let .boolean(value): return value
        case let .undecoded(value): return value.boolValue
        default: return nil
        }
    }
    
    @inlinable
    var int64Value: Int64? {
        switch self {
        case let .signed(value): return value
        case let .undecoded(value): return value.int64Value
        default: return nil
        }
    }
    
    @inlinable
    var uint64Value: UInt64? {
        switch self {
        case let .unsigned(value): return value
        case let .undecoded(value): return value.uint64Value
        default: return nil
        }
    }
    
    @inlinable
    var doubleValue: Double? {
        switch self {
        case let .number(value): return value
        case let .undecoded(value): return value.doubleValue
        default: return nil
        }
    }
    
    @inlinable
    var string: String? {
        switch self {
        case let .string(value): return value
        case let .undecoded(value): return value.string
        default: return nil
        }
    }
    
    @inlinable
    var binary: Data? {
        switch self {
        case let .binary(value): return value
        case let .undecoded(value): return value.binary
        default: return nil
        }
    }
    
    @inlinable
    var uuid: UUID? {
        switch self {
        case let .uuid(value): return value
        case let .undecoded(value): return value.uuid
        default: return nil
        }
    }
    
    @inlinable
    var array: [DataPack]? {
        switch self {
        case let .array(value): return value
        case let .undecoded(value): return value.array
        default: return nil
        }
    }
    
    @inlinable
    var dictionary: [String: DataPack]? {
        switch self {
        case let .dictionary(value): return value
        case let .undecoded(value): return value.dictionary
        default: return nil
        }
    }
    
    @inlinable
    func encode(to data: inout MappedBuffer<UInt8>) {
        switch self {
        case .null: data.append(0x3F)
        case let .boolean(value):
            
            if value {
                data.append(0x74)
            } else {
                data.append(0x66)
            }
            
        case let .string(value):
            
            data.append(0x73)
            data.append(utf8: value)
            
        case let .signed(value):
            
            data.append(0x69)
            if let value = Int8(exactly: value) {
                data.encode(value)
            } else if let value = Int16(exactly: value) {
                data.encode(BEInt16(value))
            } else if let value = Int32(exactly: value) {
                data.encode(BEInt32(value))
            } else {
                data.encode(BEInt64(value))
            }
            
        case let .unsigned(value):
            
            data.append(0x75)
            if let value = UInt8(exactly: value) {
                data.encode(value)
            } else if let value = UInt16(exactly: value) {
                data.encode(BEUInt16(value))
            } else if let value = UInt32(exactly: value) {
                data.encode(BEUInt32(value))
            } else {
                data.encode(BEUInt64(value))
            }
            
        case let .number(value):
            
            data.append(0x6E)
            data.encode(BEUInt64(value.bitPattern))
            
        case let .binary(value):
            
            data.append(0x62)
            data.append(contentsOf: value)
            
        case let .uuid(value):
            
            data.append(0x67)
            withUnsafeBytes(of: value.uuid) { data.append(contentsOf: $0) }
            
        case let .array(array):
            
            data.append(0x61)
            data.encode(BEUInt64(array.count))
            data.encode(0 as BEUInt64)
            var body = MappedBuffer<UInt8>()
            for item in array {
                item.base.encode(to: &body)
                data.encode(BEUInt64(body.count))
            }
            data.append(contentsOf: body)
            
        case let .dictionary(dictionary):
            
            data.append(0x64)
            data.encode(BEUInt64(dictionary.count))
            data.encode(0 as BEUInt64)
            data.encode(0 as BEUInt64)
            var body = MappedBuffer<UInt8>()
            for (key, value) in dictionary {
                body.append(contentsOf: key._utf8_data)
                data.encode(BEUInt64(body.count))
                value.base.encode(to: &body)
                data.encode(BEUInt64(body.count))
            }
            data.append(contentsOf: body)
            
        case let .undecoded(value): value.encode(to: &data)
        }
    }
}

extension DataPack {
    
    @inlinable
    public var boolValue: Bool? {
        return base.boolValue
    }
    
    @inlinable
    public var int8Value: Int8? {
        switch type {
        case .signed: return base.int64Value.flatMap { Int8(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Int8(exactly: $0) }
        case .number: return base.doubleValue.flatMap { Int8(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        switch type {
        case .signed: return base.int64Value.flatMap { UInt8(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { UInt8(exactly: $0) }
        case .number: return base.doubleValue.flatMap { UInt8(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        switch type {
        case .signed: return base.int64Value.flatMap { Int16(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Int16(exactly: $0) }
        case .number: return base.doubleValue.flatMap { Int16(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        switch type {
        case .signed: return base.int64Value.flatMap { UInt16(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { UInt16(exactly: $0) }
        case .number: return base.doubleValue.flatMap { UInt16(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var int32Value: Int32? {
        switch type {
        case .signed: return base.int64Value.flatMap { Int32(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Int32(exactly: $0) }
        case .number: return base.doubleValue.flatMap { Int32(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        switch type {
        case .signed: return base.int64Value.flatMap { UInt32(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { UInt32(exactly: $0) }
        case .number: return base.doubleValue.flatMap { UInt32(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var int64Value: Int64? {
        switch type {
        case .signed: return base.int64Value
        case .unsigned: return base.uint64Value.flatMap { Int64(exactly: $0) }
        case .number: return base.doubleValue.flatMap { Int64(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch type {
        case .signed: return base.int64Value.flatMap { UInt64(exactly: $0) }
        case .unsigned: return base.uint64Value
        case .number: return base.doubleValue.flatMap { UInt64(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var intValue: Int? {
        switch type {
        case .signed: return base.int64Value.flatMap { Int(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Int(exactly: $0) }
        case .number: return base.doubleValue.flatMap { Int(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var uintValue: UInt? {
        switch type {
        case .signed: return base.int64Value.flatMap { UInt(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { UInt(exactly: $0) }
        case .number: return base.doubleValue.flatMap { UInt(exactly: $0) }
        default: return nil
        }
    }
    
    @inlinable
    public var floatValue: Float? {
        switch type {
        case .signed: return base.int64Value.flatMap { Float(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Float(exactly: $0) }
        case .number: return base.doubleValue.map { Float($0) }
        default: return nil
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch type {
        case .signed: return base.int64Value.flatMap { Double(exactly: $0) }
        case .unsigned: return base.uint64Value.flatMap { Double(exactly: $0) }
        case .number: return base.doubleValue
        default: return nil
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch type {
        case .signed: return base.int64Value.map { Decimal($0) }
        case .unsigned: return base.uint64Value.map { Decimal($0) }
        case .number: return base.doubleValue.flatMap { Int64(exactly: $0) }.map { Decimal($0) }
        default: return nil
        }
    }
    
    @inlinable
    public var string: String? {
        return base.string
    }
    
    @inlinable
    public var binary: Data? {
        return base.binary
    }
    
    @inlinable
    public var uuid: UUID? {
        return base.uuid
    }
    
    @inlinable
    public var array: [DataPack]? {
        return base.array
    }
    
    @inlinable
    public var dictionary: [String: DataPack]? {
        return base.dictionary
    }
}

@frozen
@usableFromInline
struct SDUndecodedObject {
    
    @usableFromInline
    let type: DataPackType
    
    @usableFromInline
    let data: Data
    
    @inlinable
    init(data: Data) {
        if let type = data.first {
            switch type {
            case 0x3F: self.type = .null
            case 0x66, 0x74: self.type = .boolean
            case 0x69: self.type = .signed
            case 0x75: self.type = .unsigned
            case 0x6E: self.type = .number
            case 0x73: self.type = .string
            case 0x62: self.type = .binary
            case 0x67: self.type = .uuid
            case 0x61: self.type = .array
            case 0x64: self.type = .dictionary
            default: self.type = .unknown(type)
            }
        } else {
            self.type = .null
        }
        self.data = type == .boolean ? data : data.dropFirst()
    }
    
    @inlinable
    var boolValue: Bool? {
        guard let value = data.first else { return nil }
        switch value {
        case 0x66: return false
        case 0x74: return true
        default: return nil
        }
    }
    
    @inlinable
    var int64Value: Int64? {
        guard type == .signed else { return nil }
        switch data.count {
        case 1: return Int64(data.load(as: Int8.self))
        case 2: return Int64(Int16(bigEndian: data.load(as: Int16.self)))
        case 4: return Int64(Int32(bigEndian: data.load(as: Int32.self)))
        case 8: return Int64(bigEndian: data.load(as: Int64.self))
        default: return nil
        }
    }
    
    @inlinable
    var uint64Value: UInt64? {
        guard type == .unsigned else { return nil }
        switch data.count {
        case 1: return UInt64(data.load(as: UInt8.self))
        case 2: return UInt64(UInt16(bigEndian: data.load(as: UInt16.self)))
        case 4: return UInt64(UInt32(bigEndian: data.load(as: UInt32.self)))
        case 8: return UInt64(bigEndian: data.load(as: UInt64.self))
        default: return nil
        }
    }
    
    @inlinable
    var doubleValue: Double? {
        guard data.count == 8 && type == .number else { return nil }
        return Double(bitPattern: UInt64(bigEndian: data.load(as: UInt64.self)))
    }
    
    @inlinable
    var string: String? {
        guard type == .string else { return nil }
        return String(bytes: data, encoding: .utf8)
    }
    
    @inlinable
    var binary: Data? {
        switch type {
        case .binary: return data
        case .unknown(_): return data
        default: return nil
        }
    }
    
    @inlinable
    var uuid: UUID? {
        guard data.count == 16 && type == .uuid else { return nil }
        return UUID(uuid: data.load(as: uuid_t.self))
    }
    
    @inlinable
    var array: [DataPack]? {
        guard type == .array else { return nil }
        return (0..<count).map { self[$0] }
    }
    
    @inlinable
    var dictionary: [String: DataPack]? {
        guard type == .dictionary else { return nil }
        return Dictionary((0..<count).lazy.compactMap { self[keyValuePairs: $0] }) { lhs, _ in lhs }
    }
    
    @inlinable
    var count: Int {
        guard data.count >= 8 && (type == .array || type == .dictionary) else { return 0 }
        return Int(UInt64(bigEndian: data.prefix(8).load(as: UInt64.self)))
    }
    
    @inlinable
    subscript(index: Int) -> DataPack {
        
        guard type == .array else { return nil }
        
        let count = self.count
        let table_size = (count + 1) << 3
        let data = self.data.dropFirst(8)
        
        guard data.count > table_size else { return nil }
        
        let offsets = data.prefix(table_size).typed(as: UInt64.self)
        
        let from = Int(UInt64(bigEndian: offsets[index]))
        let to = Int(UInt64(bigEndian: offsets[index + 1]))
        
        guard to > from && data.count >= table_size + to else { return nil }
        
        return DataPack(decode: data.dropFirst(table_size).dropFirst(from).prefix(to - from))
    }
    
    @inlinable
    subscript(keyValuePairs index: Int) -> (String, DataPack)? {
        
        guard type == .dictionary else { return nil }
        
        let count = self.count
        let table_size = (count + 1) << 4
        let data = self.data.dropFirst(8)
        
        guard data.count > table_size else { return nil }
        
        let offsets = data.prefix(table_size).typed(as: (UInt64, UInt64).self)
        let from = Int(UInt64(bigEndian: offsets[index].1))
        
        let offset_0 = Int(UInt64(bigEndian: offsets[index + 1].0))
        let offset_1 = Int(UInt64(bigEndian: offsets[index + 1].1))
        
        guard offset_0 > from && offset_1 > offset_0 && data.count >= table_size + offset_1 else { return nil }
        
        let _key = data.dropFirst(table_size).dropFirst(from).prefix(offset_0 - from)
        let _value = data.dropFirst(table_size).dropFirst(offset_0).prefix(offset_1 - offset_0)
        
        guard let key = String(bytes: _key, encoding: .utf8) else { return nil }
        
        let value = DataPack(decode: _value)
        return value.isNil ? nil : (key, value)
    }
    
    @inlinable
    func encode(to data: inout MappedBuffer<UInt8>) {
        switch type {
        case .null: data.append(0x3F)
        case .boolean: break
        case .string: data.append(0x73)
        case .signed: data.append(0x69)
        case .unsigned: data.append(0x75)
        case .number: data.append(0x6E)
        case .binary: data.append(0x62)
        case .uuid: data.append(0x67)
        case .array: data.append(0x61)
        default: return
        }
        data.append(contentsOf: self.data)
    }
}

extension DataPack {
    
    @inlinable
    public var count: Int {
        switch base {
        case let .undecoded(value): return value.count
        case let .array(value): return value.count
        case let .dictionary(value): return value.count
        default: fatalError("Not an array or object.")
        }
    }
    
    @inlinable
    public subscript(index: Int) -> DataPack {
        get {
            guard 0..<count ~= index else { return nil }
            switch base {
            case let .undecoded(value): return value[index]
            case let .array(value): return value[index]
            default: return nil
            }
        }
        set {
            switch base {
            case let .undecoded(value):
                
                guard var array = value.array else { fatalError("Not an array.") }
                if index >= array.count {
                    array.append(contentsOf: repeatElement(nil, count: index - array.count + 1))
                }
                array[index] = newValue
                self = DataPack(array)
                
            case var .array(value):
                
                if index >= value.count {
                    value.append(contentsOf: repeatElement(nil, count: index - value.count + 1))
                }
                value[index] = newValue
                self = DataPack(value)
                
            default: fatalError("Not an array.")
            }
        }
    }
    
    @inlinable
    public var keys: Dictionary<String, DataPack>.Keys {
        guard case let .dictionary(value) = base else { return [:].keys }
        return value.keys
    }
    
    @inlinable
    public subscript(key: String) -> DataPack {
        get {
            guard case let .dictionary(value) = base else { return nil }
            return value[key] ?? nil
        }
        set {
            guard case var .dictionary(value) = base else { fatalError("Not an object.") }
            value[key] = newValue.isNil ? nil : newValue
            self = DataPack(value)
        }
    }
}

extension DataPack: Encodable {
    
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
        
        switch self.type {
        case .null:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            
        case .boolean:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.boolValue!)
            
        case .string:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.string!)
            
        case .signed:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.int64Value!)
            
        case .unsigned:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.uint64Value!)
            
        case .number:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.doubleValue!)
            
        case .binary:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.binary!)
            
        case .uuid:
            
            var container = encoder.singleValueContainer()
            try container.encode(self.uuid!)
            
        case .array:
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: self.array!)
            
        case .dictionary:
            
            var container = encoder.container(keyedBy: CodingKey.self)
            
            for (key, value) in self.dictionary! {
                try container.encode(value, forKey: CodingKey(stringValue: key))
            }
            
        default:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}
