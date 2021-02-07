//
//  DataPack.swift
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
}

@frozen
public struct DataPack {
    
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
        case undecoded_array(UndecodedArray)
        case dictionary([String: DataPack])
    }
    
    @usableFromInline
    let base: Base
    
    @inlinable
    public init(decode data: Data) {
        self.init(decode: data, xref: data, stack: [])
    }
    
    @inlinable
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: url, options: options))
    }
    
    @inlinable
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: URL(fileURLWithPath: path), options: options))
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
        switch self.base {
        case .null: return "nil"
        case let .boolean(value): return "\(value)"
        case let .string(value): return "\"\(value.escaped(asASCII: false))\""
        case let .signed(value): return "\(value)"
        case let .unsigned(value): return "\(value)"
        case let .number(value): return "\(value)"
        case let .binary(value): return "\(value)"
        case let .uuid(value): return "\(value)"
        case let .array(value): return "\(value)"
        case let .undecoded_array(value): return "\(Array(value))"
        case let .dictionary(value): return "\(value)"
        }
    }
}

extension DataPack: Hashable {
    
    @inlinable
    public static func == (lhs: DataPack, rhs: DataPack) -> Bool {
        switch (lhs.base, rhs.base) {
        case (.null, .null): return true
        case let (.boolean(lhs), .boolean(rhs)): return lhs == rhs
        case let (.string(lhs), .string(rhs)): return lhs == rhs
        case let (.signed(lhs), .signed(rhs)): return lhs == rhs
        case let (.unsigned(lhs), .unsigned(rhs)): return lhs == rhs
        case let (.number(lhs), .number(rhs)): return lhs == rhs
        case let (.binary(lhs), .binary(rhs)): return lhs == rhs
        case let (.uuid(lhs), .uuid(rhs)): return lhs == rhs
        case let (.array(lhs), .array(rhs)): return lhs == rhs
        case let (.array(lhs), .undecoded_array(rhs)): return lhs == Array(rhs)
        case let (.undecoded_array(lhs), .array(rhs)): return Array(lhs) == rhs
        case let (.undecoded_array(lhs), .undecoded_array(rhs)): return Array(lhs) == Array(rhs)
        case let (.dictionary(lhs), .dictionary(rhs)): return lhs == rhs
        default: return false
        }
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        switch self.base {
        case let .boolean(value): hasher.combine(value)
        case let .string(value): hasher.combine(value)
        case let .signed(value): hasher.combine(value)
        case let .unsigned(value): hasher.combine(value)
        case let .number(value): hasher.combine(value)
        case let .binary(value): hasher.combine(value)
        case let .uuid(value): hasher.combine(value)
        case let .array(value): hasher.combine(value)
        case let .undecoded_array(value): hasher.combine(Array(value))
        case let .dictionary(value): hasher.combine(value)
        default: break
        }
    }
}

extension DataPack {
    
    @inlinable
    init(decode data: Data, xref: Data, stack: Set<Int>) {
        
        let type = data.first
        let data = data.dropFirst()
        
        switch type {
        case 0x3F: self.base = .null
        case 0x66: self.base = .boolean(false)
        case 0x74: self.base = .boolean(true)
        case 0x69:
            
            switch data.count {
            case 1: self.base = .signed(Int64(data.load(as: Int8.self)))
            case 2: self.base = .signed(Int64(Int16(bigEndian: data.load(as: Int16.self))))
            case 4: self.base = .signed(Int64(Int32(bigEndian: data.load(as: Int32.self))))
            case 8: self.base = .signed(Int64(bigEndian: data.load(as: Int64.self)))
            default: self.base = .null
            }
            
        case 0x75:
            
            switch data.count {
            case 1: self.base = .unsigned(UInt64(data.load(as: UInt8.self)))
            case 2: self.base = .unsigned(UInt64(UInt16(bigEndian: data.load(as: UInt16.self))))
            case 4: self.base = .unsigned(UInt64(UInt32(bigEndian: data.load(as: UInt32.self))))
            case 8: self.base = .unsigned(UInt64(bigEndian: data.load(as: UInt64.self)))
            default: self.base = .null
            }
            
        case 0x6E:
            
            switch data.count {
            case 4: self.base = .number(Double(Float(bitPattern: UInt32(bigEndian: data.load(as: UInt32.self)))))
            case 8: self.base = .number(Double(bitPattern: UInt64(bigEndian: data.load(as: UInt64.self))))
            default: self.base = .null
            }
            
        case 0x73:
            
            if let string = String(bytes: data, encoding: .utf8) {
                
                self.base = .string(string)
                
            } else {
                
                self.base = .null
            }
            
        case 0x62:
            
            self.base = .binary(data)
            
        case 0x67:
            
            if data.count == 16 {
                
                self.base = .uuid(UUID(uuid: data.load(as: uuid_t.self)))
                
            } else {
                
                self.base = .null
            }
            
        case 0x61:
            
            self.base = .undecoded_array(UndecodedArray(data: data, xref: xref, stack: stack))
            
        case 0x64:
            
            let keyValuePairs = UndecodedKeyValuePairs(data: data, xref: xref, stack: stack)
            self.base = .dictionary(Dictionary(keyValuePairs.lazy.compactMap({ $0 })) { lhs, _ in lhs })
            
        case 0x78:
            
            if data.count == 16 {
                
                let range = data.load(as: (UInt64, UInt64).self)
                
                let startIndex = Int(UInt64(bigEndian: range.0))
                let endIndex = Int(UInt64(bigEndian: range.1))
                
                if !stack.contains(startIndex) {
                    
                    var stack = stack
                    stack.insert(startIndex)
                    
                    self = DataPack(decode: xref.dropFirst(startIndex).prefix(endIndex - startIndex), xref: xref, stack: stack)
                    return
                    
                } else {
                    
                    self.base = .null
                }
                
            } else {
                
                self.base = .null
            }
            
        default: self.base = .null
        }
    }
}

extension DataPack {
    
    @inlinable
    public func encode() -> Data {
        var result = MappedBuffer<UInt8>()
        var xref: [DataPack: (Int, Int)] = [:]
        self.encode(to: &result, base_offset: 0, xref: &xref)
        return result.data
    }
    
    @inlinable
    func encode(to data: inout MappedBuffer<UInt8>, base_offset: Int, xref: inout [DataPack: (Int, Int)]) {
        
        if let (startIndex, endIndex) = xref[self] {
            
            data.append(0x78)
            data.encode(BEUInt64(startIndex))
            data.encode(BEUInt64(endIndex))
            
        } else {
            
            let startIndex = data.count + base_offset
            
            self.base.encode(to: &data, base_offset: base_offset, xref: &xref)
            
            let endIndex = data.count + base_offset
            
            if endIndex - startIndex > 17 {
                xref[self] = (startIndex, endIndex)
            }
        }
    }
}

extension DataPack.Base {
    
    @inlinable
    func encode(to data: inout MappedBuffer<UInt8>, base_offset: Int, xref: inout [DataPack: (Int, Int)]) {
        
        let startIndex = data.count + base_offset
        
        switch self {
        
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
            if let value = Float(exactly: value) {
                data.encode(BEUInt32(value.bitPattern))
            } else {
                data.encode(BEUInt64(value.bitPattern))
            }
            
        case let .binary(value):
            
            data.append(0x62)
            data.append(contentsOf: value)
            
        case let .uuid(value):
            
            data.append(0x67)
            withUnsafeBytes(of: value.uuid) { data.append(contentsOf: $0) }
            
        case let .array(value):
            
            data.append(0x61)
            data.encode(BEUInt64(value.count))
            data.encode(0 as BEUInt64)
            var body = MappedBuffer<UInt8>()
            for item in value {
                item.encode(to: &body, base_offset: startIndex + (value.count + 1) << 3 + 9, xref: &xref)
                data.encode(BEUInt64(body.count))
            }
            data.append(contentsOf: body)
            
        case let .undecoded_array(value):
            
            data.append(0x61)
            data.encode(BEUInt64(value.count))
            data.encode(0 as BEUInt64)
            var body = MappedBuffer<UInt8>()
            for item in value {
                item.encode(to: &body, base_offset: startIndex + (value.count + 1) << 3 + 9, xref: &xref)
                data.encode(BEUInt64(body.count))
            }
            data.append(contentsOf: body)
            
        case let .dictionary(value):
            
            data.append(0x64)
            data.encode(BEUInt64(value.count))
            data.encode(0 as BEUInt64)
            data.encode(0 as BEUInt64)
            var body = MappedBuffer<UInt8>()
            for (key, item) in value {
                body.append(contentsOf: key._utf8_data)
                data.encode(BEUInt64(body.count))
                item.encode(to: &body, base_offset: startIndex + (value.count + 1) << 4 + 9, xref: &xref)
                data.encode(BEUInt64(body.count))
            }
            data.append(contentsOf: body)
            
        default: data.append(0x3F)
        }
    }
}

extension DataPack {
    
    @inlinable
    public var type: DataPackType {
        switch self.base {
        case .null: return .null
        case .boolean: return .boolean
        case .string: return .string
        case .signed: return .signed
        case .unsigned: return .unsigned
        case .number: return .number
        case .binary: return .binary
        case .uuid: return .uuid
        case .array, .undecoded_array: return .array
        case .dictionary: return .dictionary
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
    
    @inlinable
    public var boolValue: Bool? {
        switch self.base {
        case let .boolean(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var int8Value: Int8? {
        switch self.base {
        case let .signed(value): return Int8(exactly: value)
        case let .unsigned(value): return Int8(exactly: value)
        case let .number(value): return Int8(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var uint8Value: UInt8? {
        switch self.base {
        case let .signed(value): return UInt8(exactly: value)
        case let .unsigned(value): return UInt8(exactly: value)
        case let .number(value): return UInt8(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        switch self.base {
        case let .signed(value): return Int16(exactly: value)
        case let .unsigned(value): return Int16(exactly: value)
        case let .number(value): return Int16(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        switch self.base {
        case let .signed(value): return UInt16(exactly: value)
        case let .unsigned(value): return UInt16(exactly: value)
        case let .number(value): return UInt16(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var int32Value: Int32? {
        switch self.base {
        case let .signed(value): return Int32(exactly: value)
        case let .unsigned(value): return Int32(exactly: value)
        case let .number(value): return Int32(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        switch self.base {
        case let .signed(value): return UInt32(exactly: value)
        case let .unsigned(value): return UInt32(exactly: value)
        case let .number(value): return UInt32(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var int64Value: Int64? {
        switch self.base {
        case let .signed(value): return value
        case let .unsigned(value): return Int64(exactly: value)
        case let .number(value): return Int64(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        switch self.base {
        case let .signed(value): return UInt64(exactly: value)
        case let .unsigned(value): return value
        case let .number(value): return UInt64(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var intValue: Int? {
        switch self.base {
        case let .signed(value): return Int(exactly: value)
        case let .unsigned(value): return Int(exactly: value)
        case let .number(value): return Int(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var uintValue: UInt? {
        switch self.base {
        case let .signed(value): return UInt(exactly: value)
        case let .unsigned(value): return UInt(exactly: value)
        case let .number(value): return UInt(exactly: value)
        default: return nil
        }
    }
    
    @inlinable
    public var floatValue: Float? {
        switch self.base {
        case let .signed(value): return Float(exactly: value)
        case let .unsigned(value): return Float(exactly: value)
        case let .number(value): return Float(value)
        default: return nil
        }
    }
    
    @inlinable
    public var doubleValue: Double? {
        switch self.base {
        case let .signed(value): return Double(exactly: value)
        case let .unsigned(value): return Double(exactly: value)
        case let .number(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        switch self.base {
        case let .signed(value): return Decimal(value)
        case let .unsigned(value): return Decimal(value)
        case let .number(value): return Decimal(value)
        default: return nil
        }
    }
    
    @inlinable
    public var string: String? {
        switch self.base {
        case let .string(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var binary: Data? {
        switch self.base {
        case let .binary(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var uuid: UUID? {
        switch self.base {
        case let .uuid(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var array: [DataPack]? {
        switch self.base {
        case let .array(value): return value
        case let .undecoded_array(value): return Array(value)
        default: return nil
        }
    }
    
    @inlinable
    public var dictionary: [String: DataPack]? {
        switch self.base {
        case let .dictionary(value): return value
        default: return nil
        }
    }
}

extension DataPack {
    
    @frozen
    @usableFromInline
    struct UndecodedArray: RandomAccessCollection {
        
        @usableFromInline
        typealias Indices = Range<Int>
        
        @usableFromInline
        typealias Index = Int
        
        @usableFromInline
        let data: Data
        
        @usableFromInline
        let xref: Data
        
        @usableFromInline
        let stack: Set<Int>
        
        @inlinable
        init(data: Data, xref: Data, stack: Set<Int>) {
            self.data = data
            self.xref = xref
            self.stack = stack
        }
    }
}

extension DataPack.UndecodedArray {
    
    @inlinable
    var startIndex: Int {
        return 0
    }
    
    @inlinable
    var endIndex: Int {
        return Int(UInt64(bigEndian: data.prefix(8).load(as: UInt64.self)))
    }
    
    @inlinable
    subscript(index: Int) -> DataPack {
        
        let count = self.count
        let table_size = (count + 1) << 3
        let data = self.data.dropFirst(8)
        
        guard data.count > table_size else { return nil }
        
        let offsets = data.prefix(table_size).typed(as: UInt64.self)
        
        let startIndex = Int(UInt64(bigEndian: offsets[index]))
        let endIndex = Int(UInt64(bigEndian: offsets[index + 1]))
        
        guard endIndex > startIndex && data.count >= table_size + endIndex else { return nil }
        
        return DataPack(decode: data.dropFirst(table_size).dropFirst(startIndex).prefix(endIndex - startIndex), xref: xref, stack: stack)
    }
}

extension DataPack {
    
    @frozen
    @usableFromInline
    struct UndecodedKeyValuePairs: RandomAccessCollection {
        
        @usableFromInline
        typealias Indices = Range<Int>
        
        @usableFromInline
        typealias Index = Int
        
        @usableFromInline
        let data: Data
        
        @usableFromInline
        let xref: Data
        
        @usableFromInline
        let stack: Set<Int>
        
        @inlinable
        init(data: Data, xref: Data, stack: Set<Int>) {
            self.data = data
            self.xref = xref
            self.stack = stack
        }
    }
}

extension DataPack.UndecodedKeyValuePairs {
    
    @inlinable
    var startIndex: Int {
        return 0
    }
    
    @inlinable
    var endIndex: Int {
        return Int(UInt64(bigEndian: data.prefix(8).load(as: UInt64.self)))
    }
    
    @inlinable
    subscript(index: Int) -> (String, DataPack)? {
        
        let count = self.count
        let table_size = (count + 1) << 4
        let data = self.data.dropFirst(8)
        
        guard data.count > table_size else { return nil }
        
        let offsets = data.prefix(table_size).typed(as: (UInt64, UInt64).self)
        
        let startIndex = Int(UInt64(bigEndian: offsets[index].1))
        let splitIndex = Int(UInt64(bigEndian: offsets[index + 1].0))
        let endIndex = Int(UInt64(bigEndian: offsets[index + 1].1))
        
        guard splitIndex > startIndex && endIndex > splitIndex && data.count >= table_size + endIndex else { return nil }
        
        let _key = data.dropFirst(table_size).dropFirst(startIndex).prefix(splitIndex - startIndex)
        let _value = data.dropFirst(table_size).dropFirst(splitIndex).prefix(endIndex - splitIndex)
        
        guard let key = String(bytes: _key, encoding: .utf8) else { return nil }
        
        let value = DataPack(decode: _value, xref: xref, stack: stack)
        return value.isNil ? nil : (key, value)
    }
}

extension DataPack {
    
    @inlinable
    public var count: Int {
        switch self.base {
        case let .array(value): return value.count
        case let .undecoded_array(value): return value.count
        case let .dictionary(value): return value.count
        default: fatalError("Not an array or object.")
        }
    }
    
    @inlinable
    public subscript(index: Int) -> DataPack {
        get {
            guard 0..<count ~= index else { return nil }
            switch self.base {
            case let .array(value): return value[index]
            case let .undecoded_array(value): return value[index]
            default: return nil
            }
        }
        set {
            switch self.base {
            case var .array(value):
                
                if index >= value.count {
                    value.append(contentsOf: repeatElement(nil, count: index - value.count + 1))
                }
                value[index] = newValue
                self = DataPack(value)
                
            case let .undecoded_array(value):
                
                var array = Array(value)
                if index >= array.count {
                    array.append(contentsOf: repeatElement(nil, count: index - array.count + 1))
                }
                array[index] = newValue
                self = DataPack(array)
                
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
        
        switch self.base {
        case .null:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            
        case let .boolean(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .string(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .signed(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .unsigned(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .number(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .binary(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .uuid(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .array(value):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: value)
            
        case let .undecoded_array(value):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: value)
            
        case let .dictionary(value):
            
            var container = encoder.container(keyedBy: CodingKey.self)
            
            for (key, value) in value {
                try container.encode(value, forKey: CodingKey(stringValue: key))
            }
        }
    }
}
