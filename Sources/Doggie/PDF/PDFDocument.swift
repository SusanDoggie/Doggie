//
//  PDFDocument.swift
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

import Foundation

public struct PDFDocument {
    
    public let trailer: PDFDocument.Dictionary
    public let xref: Xref
    
    public let version: (major: Int, minor: Int)
    
    public init(version: (major: Int, minor: Int), trailer: PDFDocument.Dictionary, xref: Xref) {
        self.version = version
        self.trailer = trailer
        self.xref = xref
    }
    
    public struct View {
        
        fileprivate let xref: PDFDocument.Xref
        
        public let identifier: PDFDocument.ObjectIdentifier?
        public let value: PDFDocument.Value
    }
    
    public struct Xref {
        
        fileprivate let table: [[PDFDocument.Value?]]
        
        public init(_ table: [[PDFDocument.Value?]]) {
            self.table = table
        }
    }
    
    public struct ObjectIdentifier {
        
        public var identifier: Int
        public var generation: Int
        
        public init(identifier: Int, generation: Int) {
            self.identifier = identifier
            self.generation = generation
        }
    }
    
    public typealias Dictionary = [PDFDocument.Name: PDFDocument.Value]
    
    public struct Name {
        
        public var name: String
        
        public init(_ name: String) {
            self.name = name
        }
    }
    
    public enum Value {
        
        case null
        case indirect(ObjectIdentifier)
        case bool(Bool)
        case number(NSNumber)
        case string(String)
        case name(Name)
        case array([Value])
        case dictionary(PDFDocument.Dictionary)
        case stream(PDFDocument.Dictionary, Data)
    }
}

extension PDFDocument {
    
    public var info: PDFDocument.View? {
        if case let .some(.indirect(identifier)) = trailer["Info"] {
            return xref[identifier].flatMap { $0.isIndirect ? nil : View(xref: xref, identifier: identifier, value: $0) }
        }
        return nil
    }
    public var root: PDFDocument.View? {
        if case let .some(.indirect(identifier)) = trailer["Root"] {
            return xref[identifier].flatMap { $0.isIndirect ? nil : View(xref: xref, identifier: identifier, value: $0) }
        }
        return nil
    }
}

extension PDFDocument.View {
    
    public var count: Int {
        return self.value.count
    }
    
    public subscript(index: Int) -> PDFDocument.View {
        let value = self.value[index]
        switch value {
        case let .indirect(identifier): return xref[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(xref: xref, identifier: identifier, value: $0) } ?? PDFDocument.View(xref: xref, identifier: identifier, value: nil)
        default: return PDFDocument.View(xref: xref, identifier: nil, value: value)
        }
    }
    
    public var keys: LazyMapCollection<PDFDocument.Dictionary, PDFDocument.Name> {
        return self.value.keys
    }
    
    public subscript(key: PDFDocument.Name) -> PDFDocument.View {
        let value = self.value[key]
        switch value {
        case let .indirect(identifier): return xref[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(xref: xref, identifier: identifier, value: $0) } ?? PDFDocument.View(xref: xref, identifier: identifier, value: nil)
        default: return PDFDocument.View(xref: xref, identifier: nil, value: value)
        }
    }
}

extension PDFDocument.Xref : BidirectionalCollection {
    
    public typealias Indices = DefaultBidirectionalIndices<PDFDocument.Xref>
    
    public typealias Iterator = IndexingIterator<PDFDocument.Xref>
    
    fileprivate typealias _Collection = FlattenBidirectionalCollection<LazyMapBidirectionalCollection<IndexedRandomAccessCollection<[[PDFDocument.Value?]]>, LazyMapRandomAccessCollection<IndexedRandomAccessCollection<[PDFDocument.Value?]>, (PDFDocument.ObjectIdentifier, PDFDocument.Value?)>>>
    
    public struct Index : Comparable {
        
        fileprivate let base: _Collection.Index
    }
    
    private var _collection: _Collection {
        return table.indexed().lazy.flatMap { id, objs in objs.indexed().lazy.map { (PDFDocument.ObjectIdentifier(identifier: id, generation: $0), $1) } }.elements
    }
    
    public var startIndex: Index {
        return PDFDocument.Xref.Index(base: _collection.startIndex)
    }
    
    public var endIndex: Index {
        return PDFDocument.Xref.Index(base: _collection.endIndex)
    }
    
    public func index(after i: Index) -> Index {
        return PDFDocument.Xref.Index(base: _collection.index(after: i.base))
    }
    
    public func index(before i: Index) -> Index {
        return PDFDocument.Xref.Index(base: _collection.index(before: i.base))
    }
    
    public subscript(position: Index) -> (PDFDocument.ObjectIdentifier, PDFDocument.Value?) {
        return _collection[position.base]
    }
}

public func == (lhs: PDFDocument.Xref.Index, rhs: PDFDocument.Xref.Index) -> Bool {
    return lhs.base == rhs.base
}
public func < (lhs: PDFDocument.Xref.Index, rhs: PDFDocument.Xref.Index) -> Bool {
    return lhs.base < rhs.base
}

extension PDFDocument.Xref {
    
    public subscript(index: PDFDocument.ObjectIdentifier) -> PDFDocument.Value? {
        if table.indices ~= index.identifier {
            let objects = table[index.identifier]
            if objects.indices ~= index.generation {
                return objects[index.generation]
            }
        }
        return nil
    }
}

extension PDFDocument.ObjectIdentifier : Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, identifier, generation)
    }
}

public func ==(lhs: PDFDocument.ObjectIdentifier, rhs: PDFDocument.ObjectIdentifier) -> Bool {
    return lhs.identifier == rhs.identifier && lhs.generation == rhs.generation
}

extension PDFDocument.Name : Hashable {
    
    public var hashValue: Int {
        return name.hashValue
    }
}

public func ==(lhs: PDFDocument.Name, rhs: PDFDocument.Name) -> Bool {
    return lhs.name == rhs.name
}

extension PDFDocument.Name : CustomStringConvertible {
    
    public var description: String {
        return "/\(name)"
    }
}

extension PDFDocument.Name: ExpressibleByStringLiteral {
    
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

extension PDFDocument.Value : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .null: return "nil"
        case let .indirect(identifier): return "\(identifier)"
        case let .bool(bool): return "\(bool)"
        case let .number(number): return "\(number)"
        case let .string(string): return string
        case let .name(name): return "\(name)"
        case let .array(array):
            var result = "["
            var first = true
            for item in array {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                result += item.stringValue.map { "\"\($0)\"" } ?? item.description
            }
            result += "]"
            return result
        case let .dictionary(dictionary):
            var result = "["
            var first = true
            for (k, v) in dictionary {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                result += k.description
                result += ": "
                result += v.stringValue.map { "\"\($0)\"" } ?? v.description
            }
            result += "]"
            return result
        case let .stream(stream): return "\(stream)"
        }
    }
}

extension PDFDocument.Value {
    
    public init<T : Integer>(_ value: T) {
        self = .number(NSNumber(value: value.toIntMax()))
    }
    public init(_ value: Float) {
        self = .number(NSNumber(value: value))
    }
    public init(_ value: Double) {
        self = .number(NSNumber(value: value))
    }
    public init(_ value: Bool) {
        self = .bool(value)
    }
    public init(_ value: PDFDocument.ObjectIdentifier) {
        self = .indirect(value)
    }
    public init(_ value: String) {
        self = .string(value)
    }
    public init(_ value: PDFDocument.Name) {
        self = .name(value)
    }
    public init(_ elements: PDFDocument.Value ...) {
        self = .array(elements)
    }
    public init<S : Sequence>(_ elements: S) where S.Iterator.Element == PDFDocument.Value {
        self = .array(Array(elements))
    }
    public init(_ elements: PDFDocument.Dictionary) {
        self = .dictionary(elements)
    }
}

extension PDFDocument.Value: ExpressibleByNilLiteral {
    
    public init(nilLiteral value: Void) {
        self = .null
    }
}

extension PDFDocument.Value: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension PDFDocument.Value: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension PDFDocument.Value: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension PDFDocument.Value: ExpressibleByStringLiteral {
    
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

extension PDFDocument.Value: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: PDFDocument.Value ...) {
        self.init(elements)
    }
}

extension PDFDocument.Value: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (PDFDocument.Name, PDFDocument.Value) ...) {
        var dictionary: PDFDocument.Dictionary = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary)
    }
}

extension PDFDocument.Value {
    
    public var isNil : Bool {
        switch self {
        case .null: return true
        default: return false
        }
    }
    
    public var isBool : Bool {
        switch self {
        case .bool: return true
        default: return false
        }
    }
    
    public var isIndirect : Bool {
        switch self {
        case .indirect: return true
        default: return false
        }
    }
    
    public var isNumber : Bool {
        switch self {
        case .number: return true
        default: return false
        }
    }
    
    public var isString : Bool {
        switch self {
        case .string: return true
        default: return false
        }
    }
    
    public var isName : Bool {
        switch self {
        case .name: return true
        default: return false
        }
    }
    
    public var isArray : Bool {
        switch self {
        case .array: return true
        default: return false
        }
    }
    
    public var isDictionary : Bool {
        switch self {
        case .dictionary: return true
        default: return false
        }
    }
    
    public var isStream : Bool {
        switch self {
        case .stream: return true
        default: return false
        }
    }
}

extension PDFDocument.Value {
    
    fileprivate var numberValue: NSNumber? {
        switch self {
        case let .number(number): return number
        default: return nil
        }
    }
    public var boolValue: Bool? {
        get {
            switch self {
            case let .bool(bool): return bool
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var int8Value: Int8? {
        get {
            return self.numberValue?.int8Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var uint8Value: UInt8? {
        get {
            return self.numberValue?.uint8Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var int16Value: Int16? {
        get {
            return self.numberValue?.int16Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var uint16Value: UInt16? {
        get {
            return self.numberValue?.uint16Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var int32Value: Int32? {
        get {
            return self.numberValue?.int32Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var uint32Value: UInt32? {
        get {
            return self.numberValue?.uint32Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var int64Value: Int64? {
        get {
            return self.numberValue?.int64Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var uint64Value: UInt64? {
        get {
            return self.numberValue?.uint64Value
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var floatValue: Float? {
        get {
            return self.numberValue?.floatValue
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var doubleValue: Double? {
        get {
            return self.numberValue?.doubleValue
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var intValue: Int? {
        get {
            return self.numberValue?.intValue
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var uintValue: UInt? {
        get {
            return self.numberValue?.uintValue
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var stringValue: String? {
        get {
            switch self {
            case let .string(string): return string
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var nameValue: PDFDocument.Name? {
        get {
            switch self {
            case let .name(name): return name
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var identifier: PDFDocument.ObjectIdentifier? {
        get {
            switch self {
            case let .indirect(identifier): return identifier
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var array: [PDFDocument.Value]? {
        get {
            switch self {
            case let .array(array): return array
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var dictionary: PDFDocument.Dictionary? {
        get {
            switch self {
            case let .dictionary(dictionary): return dictionary
            default: return nil
            }
        }
        set {
            self = newValue.map { PDFDocument.Value($0) } ?? .null
        }
    }
    
    public var stream: (PDFDocument.Dictionary, Data)? {
        get {
            switch self {
            case let .stream(stream): return stream
            default: return nil
            }
        }
        set {
            self = newValue.map { .stream($0, $1) } ?? .null
        }
    }
}

extension PDFDocument.Value {
    
    public var count: Int {
        switch self {
        case let .array(array): return array.count
        case let .dictionary(dictionary): return dictionary.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(index: Int) -> PDFDocument.Value {
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
                self = .array(array)
            default: fatalError("Not an array.")
            }
        }
    }
    
    public var keys: LazyMapCollection<PDFDocument.Dictionary, PDFDocument.Name> {
        switch self {
        case let .dictionary(dictionary): return dictionary.keys
        default: fatalError("Not an object.")
        }
    }
    
    public subscript(key: PDFDocument.Name) -> PDFDocument.Value {
        get {
            if case let .dictionary(dictionary) = self {
                if let val = dictionary[key] {
                    return val
                }
                return nil
            }
            return nil
        }
        set {
            switch self {
            case var .dictionary(dictionary):
                dictionary[key] = newValue.isNil ? nil : newValue
                self = .dictionary(dictionary)
            default: fatalError("Not an object.")
            }
        }
    }
}
