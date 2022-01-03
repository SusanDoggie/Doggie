//
//  PDFObject.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

public enum PDFObjectType: Hashable {
    
    case null
    case xref
    case boolean
    case name
    case string
    case number
    case stream
    case array
    case dictionary
}

@frozen
public struct PDFObject {
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    var xref: [PDFXref: PDFObject] = [:]
    
    @inlinable
    init(_ value: PDFXref) {
        self.base = .xref(value)
    }
    
    @inlinable
    public init(_ value: Bool) {
        self.base = .boolean(value)
    }
    
    @inlinable
    public init(_ value: PDFName) {
        self.base = .name(value)
    }
    
    @inlinable
    public init(_ value: PDFString) {
        self.base = .string(value)
    }
    
    @inlinable
    public init<S: StringProtocol>(_ value: S) {
        self.base = .string(PDFString(value))
    }
    
    @inlinable
    public init(_ value: PDFNumber) {
        self.base = .number(value)
    }
    
    @inlinable
    public init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self.base = .number(PDFNumber(value))
    }
    
    @inlinable
    public init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self.base = .number(PDFNumber(value))
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ value: T) {
        self.base = .number(PDFNumber(value))
    }
    
    @inlinable
    public init(_ value: Decimal) {
        self.base = .number(PDFNumber(value))
    }
    
    @inlinable
    public init(_ stream: PDFStream) {
        self.base = .stream(stream)
    }
    
    @inlinable
    public init<S: Sequence>(_ elements: S) where S.Element == PDFObject {
        self.base = .array(Array(elements))
    }
    
    @inlinable
    public init(_ elements: [PDFName: PDFObject]) {
        self.base = .dictionary(elements)
    }
    
    @inlinable
    public init(_ dictionary: [PDFName: PDFObject], _ data: Data) {
        self.base = .stream(PDFStream(dictionary: dictionary, data: data))
    }
}

extension PDFObject: ExpressibleByNilLiteral {
    
    @inlinable
    public init(nilLiteral value: Void) {
        self.base = .null
    }
}

extension PDFObject: ExpressibleByBooleanLiteral {
    
    @inlinable
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension PDFObject: ExpressibleByIntegerLiteral {
    
    @inlinable
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension PDFObject: ExpressibleByFloatLiteral {
    
    @inlinable
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension PDFObject: ExpressibleByStringInterpolation {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    @inlinable
    public init(stringInterpolation: String.StringInterpolation) {
        self.init(String(stringInterpolation: stringInterpolation))
    }
}

extension PDFObject: ExpressibleByArrayLiteral {
    
    @inlinable
    public init(arrayLiteral elements: PDFObject ...) {
        self.init(elements)
    }
}

extension PDFObject: ExpressibleByDictionaryLiteral {
    
    @inlinable
    public init(dictionaryLiteral elements: (PDFName, PDFObject) ...) {
        self.init(Dictionary(uniqueKeysWithValues: elements))
    }
}

extension PDFObject {
    
    @inlinable
    func _apply_xref(_ xref: [PDFXref: PDFObject]) -> PDFObject {
        var copy = self
        copy.xref = xref
        return copy
    }
}

extension PDFObject: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch base {
        case .null: return "nil"
        case let .xref(xref): return "\(xref.object) \(xref.generation) R"
        case let .boolean(value): return "\(value)"
        case let .name(value): return "\(value)"
        case let .string(value): return "\(value)"
        case let .number(value): return "\(value)"
        case let .stream(value): return "\(value)"
        case let .array(value): return "\(value)"
        case let .dictionary(value): return "\(value)"
        }
    }
}

extension PDFObject: Hashable {
    
    @inlinable
    public static func == (lhs: PDFObject, rhs: PDFObject) -> Bool {
        switch (lhs.base, rhs.base) {
        case (.null, .null): return true
        case let (.xref(lhs), .xref(rhs)): return lhs == rhs
        case let (.boolean(lhs), .boolean(rhs)): return lhs == rhs
        case let (.name(lhs), .name(rhs)): return lhs == rhs
        case let (.string(lhs), .string(rhs)): return lhs == rhs
        case let (.number(lhs), .number(rhs)): return lhs == rhs
        case let (.stream(lhs), .stream(rhs)): return lhs == rhs
        case let (.array(lhs), .array(rhs)): return lhs == rhs
        case let (.dictionary(lhs), .dictionary(rhs)): return lhs == rhs
        default: return false
        }
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        switch base {
        case let .boolean(value): hasher.combine(value)
        case let .xref(xref): hasher.combine(xref)
        case let .name(value): hasher.combine(value)
        case let .string(value): hasher.combine(value)
        case let .number(value): hasher.combine(value)
        case let .stream(value): hasher.combine(value)
        case let .array(value): hasher.combine(value)
        case let .dictionary(value): hasher.combine(value)
        default: break
        }
    }
}

extension PDFObject {
    
    @inlinable
    public var isNil: Bool {
        switch base {
        case .null: return true
        case let .xref(xref): return self.xref[xref]?.isNil ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isBool: Bool {
        switch base {
        case .boolean: return true
        case let .xref(xref): return self.xref[xref]?.isBool ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isName: Bool {
        switch base {
        case .name: return true
        case let .xref(xref): return self.xref[xref]?.isName ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isString: Bool {
        switch base {
        case .string: return true
        case let .xref(xref): return self.xref[xref]?.isString ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isArray: Bool {
        switch base {
        case .array: return true
        case let .xref(xref): return self.xref[xref]?.isArray ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isDictionary: Bool {
        switch base {
        case .dictionary: return true
        case let .xref(xref): return self.xref[xref]?.isDictionary ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isNumber: Bool {
        switch base {
        case .number: return true
        case let .xref(xref): return self.xref[xref]?.isNumber ?? false
        default: return false
        }
    }
    
    @inlinable
    public var isStream: Bool {
        switch base {
        case .stream: return true
        case let .xref(xref): return self.xref[xref]?.isStream ?? false
        default: return false
        }
    }
}

extension PDFObject {
    
    @usableFromInline
    enum Base: Hashable {
        case null
        case xref(PDFXref)
        case boolean(Bool)
        case name(PDFName)
        case string(PDFString)
        case number(PDFNumber)
        case stream(PDFStream)
        case array([PDFObject])
        case dictionary([PDFName: PDFObject])
    }
}

extension PDFObject {
    
    @inlinable
    public var type: PDFObjectType {
        switch base {
        case .null: return .null
        case let .xref(xref): return self.xref[xref]?.type ?? .xref
        case .boolean: return .boolean
        case .name: return .name
        case .string: return .string
        case .number: return .number
        case .stream: return .stream
        case .array: return .array
        case .dictionary: return .dictionary
        }
    }
    
    @inlinable
    public var boolValue: Bool? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.boolValue
        case let .boolean(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var number: PDFNumber? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.number
        case let .number(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var int16Value: Int16? {
        return number?.int64Value.flatMap { Int16(exactly: $0) }
    }
    
    @inlinable
    public var uint16Value: UInt16? {
        return number?.uint64Value.flatMap { UInt16(exactly: $0) }
    }
    
    @inlinable
    public var int32Value: Int32? {
        return number?.int64Value.flatMap { Int32(exactly: $0) }
    }
    
    @inlinable
    public var uint32Value: UInt32? {
        return number?.uint64Value.flatMap { UInt32(exactly: $0) }
    }
    
    @inlinable
    public var int64Value: Int64? {
        return number?.int64Value
    }
    
    @inlinable
    public var uint64Value: UInt64? {
        return number?.uint64Value
    }
    
    @inlinable
    public var intValue: Int? {
        return number?.int64Value.flatMap { Int(exactly: $0) }
    }
    
    @inlinable
    public var uintValue: UInt? {
        return number?.uint64Value.flatMap { UInt(exactly: $0) }
    }
    
    @inlinable
    public var doubleValue: Double? {
        return number?.doubleValue
    }
    
    @inlinable
    public var decimalValue: Decimal? {
        return number?.decimalValue
    }
    
    @inlinable
    public var name: PDFName? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.name
        case let .name(value): return value
        default: return nil
        }
    }
    
    @inlinable
    public var string: PDFString? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.string
        case let .string(value): return value
        default: return nil
        }
    }
    
    @inlinable
    func dereference() -> PDFObject {
        switch base {
        case let .xref(xref): return self.xref[xref]?._apply_xref(self.xref) ?? PDFObject(xref)._apply_xref(self.xref)
        default: return self
        }
    }
    
    @inlinable
    public var stream: PDFStream? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.stream.map { PDFStream(dictionary: $0.dictionary.mapValues { $0._apply_xref(self.xref).dereference() }, data: $0.data) }
        case let .stream(value): return PDFStream(dictionary: value.dictionary.mapValues { $0._apply_xref(self.xref).dereference() }, data: value.data)
        default: return nil
        }
    }
    
    @inlinable
    public var array: [PDFObject]? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.array?.map { $0._apply_xref(self.xref).dereference() }
        case let .array(value): return value.map { $0._apply_xref(self.xref).dereference() }
        default: return nil
        }
    }
    
    @inlinable
    public var dictionary: [PDFName: PDFObject]? {
        switch base {
        case let .xref(xref): return self.xref[xref]?.dictionary?.mapValues { $0._apply_xref(self.xref).dereference() }
        case let .stream(value): return value.dictionary.mapValues { $0._apply_xref(self.xref).dereference() }
        case let .dictionary(value): return value.mapValues { $0._apply_xref(self.xref).dereference() }
        default: return nil
        }
    }
}

extension PDFObject {
    
    @inlinable
    func dereferenceAll() -> PDFObject {
        return self._dereference_all()._apply_xref(xref)
    }
    
    @inlinable
    func _dereference_all(_ stack: Set<PDFXref> = []) -> PDFObject {
        
        switch base {
        
        case let .array(array): return PDFObject(array.map { $0._apply_xref(xref)._dereference_all(stack) })
        case let .dictionary(dictionary): return PDFObject(dictionary.mapValues { $0._apply_xref(xref)._dereference_all(stack) })
        case let .stream(stream): return PDFObject(stream.dictionary.mapValues { $0._apply_xref(xref)._dereference_all(stack) }, stream.data)
            
        case let .xref(xref):
            
            guard !stack.contains(xref), let target = self.xref[xref] else { return self }
            
            var stack = stack
            stack.insert(xref)
            
            return target._apply_xref(self.xref)._dereference_all(stack)
            
        default: return self
        }
    }
}

extension PDFObject {
    
    @inlinable
    public var count: Int {
        switch base {
        case let .xref(xref): return self.xref[xref]!.count
        case let .array(value): return value.count
        case let .dictionary(value): return value.count
        default: fatalError("Not an array or object.")
        }
    }
    
    @inlinable
    public subscript(index: Int) -> PDFObject {
        get {
            guard 0..<count ~= index else { return nil }
            return self.array?[index] ?? nil
        }
        set {
            guard var array = self.array else { fatalError("Not an array.") }
            
            if index >= array.count {
                array.append(contentsOf: repeatElement(nil, count: index - array.count + 1))
            }
            
            array[index] = newValue
            self = PDFObject(array)._apply_xref(xref)
        }
    }
    
    @inlinable
    public var keys: Dictionary<PDFName, PDFObject>.Keys {
        return self.dictionary?.keys ?? [:].keys
    }
    
    @inlinable
    public subscript(key: PDFName) -> PDFObject {
        get {
            return self.dictionary?[key] ?? nil
        }
        set {
            guard var dictionary = self.dictionary else { fatalError("Not an object.") }
            
            dictionary[key] = newValue.isNil ? nil : newValue
            
            if var stream = self.stream {
                stream.dictionary = dictionary
                self = PDFObject(stream)._apply_xref(xref)
            } else {
                self = PDFObject(dictionary)._apply_xref(xref)
            }
        }
    }
}

extension PDFObject {
    
    @inlinable
    public mutating func merge(_ other: PDFObject, uniquingKeysWith combine: (PDFObject, PDFObject) throws -> PDFObject) rethrows {
        self = try self.merging(other, uniquingKeysWith: combine)
    }
    
    @inlinable
    public func merging(_ other: PDFObject, uniquingKeysWith combine: (PDFObject, PDFObject) throws -> PDFObject) rethrows -> PDFObject {
        switch (self.base, other.base) {
        case let (.dictionary(lhs), .dictionary(rhs)): return try PDFObject(lhs.merging(rhs) { try $0.merging($1, uniquingKeysWith: combine) })._apply_xref(xref)
        default: return try combine(self, other)._apply_xref(xref)
        }
    }
}

extension PDFObject {
    
    @inlinable
    public var vector: Vector? {
        guard let values = self.array?.compactMap({ $0.doubleValue }), values.count == 3 else { return nil }
        return Vector(x: values[0], y: values[1], z: values[2])
    }
    
    @inlinable
    public var rect: Rect? {
        guard let values = self.array?.compactMap({ $0.doubleValue }), values.count == 4 else { return nil }
        let minX = values[0]
        let minY = values[1]
        let maxX = values[2]
        let maxY = values[3]
        return Rect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
    
    @inlinable
    public var transform: SDTransform? {
        guard let values = self.array?.compactMap({ $0.doubleValue }), values.count == 6 else { return nil }
        return SDTransform(a: values[0], b: values[2], c: values[4], d: values[1], e: values[3], f: values[5])
    }
    
    @inlinable
    public var matrix: [Double]? {
        guard let values = self.array?.compactMap({ $0.doubleValue }), values.count == 9 else { return nil }
        return values
    }
}

extension PDFObject {
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ values: T...) {
        self.init(values)
    }
    
    @inlinable
    public init<T: BinaryFloatingPoint>(_ values: [T]) {
        self.init(values.map { PDFObject($0) })
    }
    
    @inlinable
    public init(_ vector: Vector) {
        self.init(vector.x, vector.y, vector.z)
    }
    
    @inlinable
    public init(_ rect: Rect) {
        self.init(rect.minX, rect.minY, rect.maxX, rect.maxY)
    }
    
    @inlinable
    public init(_ transform: SDTransform) {
        self.init(transform.a, transform.d, transform.b, transform.e, transform.c, transform.f)
    }
}

extension PDFObject {
    
    @inlinable
    public func encode(_ data: inout Data) {
        switch base {
        case .null: data.append(utf8: "null")
        case let .xref(xref): xref.encode(&data)
        case let .boolean(value): data.append(utf8: value ? "true" : "false")
        case let .name(value): value.encode(&data)
        case let .string(value): value.encode(&data)
        case let .number(value): value.encode(&data)
        case let .stream(stream): stream.encode(&data)
            
        case let .array(array):
            
            data.append(utf8: "[\n")
            for object in array {
                object.encode(&data)
                data.append(utf8: "\n")
            }
            data.append(utf8: "]")
            
        case let .dictionary(dictionary):
            
            data.append(utf8: "<<\n")
            for (name, object) in dictionary {
                name.encode(&data)
                data.append(utf8: " ")
                object.encode(&data)
                data.append(utf8: "\n")
            }
            data.append(utf8: ">>")
        }
    }
}
