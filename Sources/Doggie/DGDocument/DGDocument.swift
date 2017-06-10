//
//  DGDocument.swift
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

public struct DGDocument {
    
    public var rootId: Int
    public var table: [Int: Value]
    
    public init(root: Int, table: [Int: Value]) {
        self.rootId = root
        self.table = table
    }
    
    public enum Value {
        
        case `nil`
        case indirect(Int)
        case number(NSNumber)
        case string(String)
        case array([Value])
        case dictionary([String: Value])
        case stream(Data)
    }
    
    public struct View {
        
        fileprivate var table: [Int: Value] = [:]
        
        public let identifier: Int?
        public let value: DGDocument.Value
    }
}

extension DGDocument.Value {
    
    fileprivate var identifiers: [Int] {
        switch self {
        case let .indirect(identifier): return [identifier]
        case let .array(array): return array.flatMap { $0.identifiers }
        case let .dictionary(dictionary): return dictionary.flatMap { $0.1.identifiers }
        default: return []
        }
    }
}

extension DGDocument {
    
    public mutating func trimTable() {
        var trimed: [Int: Value] = [:]
        if table[rootId] != nil {
            var checking = [rootId]
            while let id = checking.popLast() {
                if let item = table[id] {
                    switch item {
                    case .indirect: break
                    case let .array(array):
                        trimed[id] = table[id]
                        checking.append(contentsOf: Set(array.flatMap { Set($0.identifiers).flatMap { trimed[$0] == nil ? $0 : nil } }))
                    case let .dictionary(dictionary):
                        trimed[id] = table[id]
                        checking.append(contentsOf: Set(dictionary.flatMap { Set($0.1.identifiers).flatMap { trimed[$0] == nil ? $0 : nil } }))
                    default: trimed[id] = table[id]
                    }
                }
            }
        }
        self.table = trimed
    }
}

extension DGDocument {
    
    public var root: DGDocument.View? {
        return table[rootId].map { DGDocument.View(table: table, identifier: rootId, value: $0) }
    }
}

extension DGDocument.View {
    
    public var count: Int {
        return self.value.count
    }
    
    public subscript(index: Int) -> DGDocument.View {
        let value = self.value[index]
        switch value {
        case let .indirect(identifier): return table[identifier].map { DGDocument.View(table: table, identifier: identifier, value: $0) } ?? DGDocument.View(table: table, identifier: identifier, value: nil)
        default: return DGDocument.View(table: table, identifier: nil, value: value)
        }
    }
    
    public var keys: Dictionary<String, DGDocument.Value>.Keys {
        return self.value.keys
    }
    
    public subscript(key: String) -> DGDocument.View {
        let value = self.value[key]
        switch value {
        case let .indirect(identifier): return table[identifier].map { DGDocument.View(table: table, identifier: identifier, value: $0) } ?? DGDocument.View(table: table, identifier: identifier, value: nil)
        default: return DGDocument.View(table: table, identifier: nil, value: value)
        }
    }
}

extension DGDocument.Value : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .nil: return "nil"
        case let .indirect(identifier): return "&\(identifier)"
        case let .number(number): return "\(number)"
        case let .string(string): return string
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
                result += k
                result += ": "
                result += v.stringValue.map { "\"\($0)\"" } ?? v.description
            }
            result += "]"
            return result
        case let .stream(stream): return "\(stream)"
        }
    }
}

extension DGDocument.Value {
    
    public init<T : FixedWidthInteger>(_ value: T) {
        self = .number(value as! NSNumber)
    }
    public init(_ value: Float) {
        self = .number(NSNumber(value: value))
    }
    public init(_ value: Double) {
        self = .number(NSNumber(value: value))
    }
    public init(_ value: Bool) {
        self = .number(NSNumber(value: value))
    }
    public init(_ value: String) {
        self = .string(value)
    }
    public init(_ elements: DGDocument.Value ...) {
        self = .array(elements)
    }
    public init<S : Sequence>(_ elements: S) where S.Iterator.Element == DGDocument.Value {
        self = .array(Array(elements))
    }
    public init(_ elements: [String: DGDocument.Value]) {
        self = .dictionary(elements)
    }
}

extension DGDocument.Value: ExpressibleByNilLiteral {
    
    public init(nilLiteral value: Void) {
        self = .nil
    }
}

extension DGDocument.Value: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension DGDocument.Value: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension DGDocument.Value: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension DGDocument.Value: ExpressibleByStringLiteral {
    
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

extension DGDocument.Value: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: DGDocument.Value ...) {
        self.init(elements)
    }
}

extension DGDocument.Value: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, DGDocument.Value) ...) {
        var dictionary: [String: DGDocument.Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary)
    }
}

extension DGDocument.Value {
    
    public var isNil : Bool {
        switch self {
        case .nil: return true
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

extension DGDocument.Value {
    
    fileprivate var numberValue: NSNumber? {
        switch self {
        case let .number(number): return number
        default: return nil
        }
    }
    public var boolValue: Bool? {
        get {
            return self.numberValue?.boolValue
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var int8Value: Int8? {
        get {
            return self.numberValue?.int8Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var uint8Value: UInt8? {
        get {
            return self.numberValue?.uint8Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var int16Value: Int16? {
        get {
            return self.numberValue?.int16Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var uint16Value: UInt16? {
        get {
            return self.numberValue?.uint16Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var int32Value: Int32? {
        get {
            return self.numberValue?.int32Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var uint32Value: UInt32? {
        get {
            return self.numberValue?.uint32Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var int64Value: Int64? {
        get {
            return self.numberValue?.int64Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var uint64Value: UInt64? {
        get {
            return self.numberValue?.uint64Value
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var floatValue: Float? {
        get {
            return self.numberValue?.floatValue
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var doubleValue: Double? {
        get {
            return self.numberValue?.doubleValue
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var intValue: Int? {
        get {
            return self.numberValue?.intValue
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var uintValue: UInt? {
        get {
            return self.numberValue?.uintValue
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
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
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var identifier: Int? {
        get {
            switch self {
            case let .indirect(identifier): return identifier
            default: return nil
            }
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var array: [DGDocument.Value]? {
        get {
            switch self {
            case let .array(array): return array
            default: return nil
            }
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var dictionary: [String: DGDocument.Value]? {
        get {
            switch self {
            case let .dictionary(dictionary): return dictionary
            default: return nil
            }
        }
        set {
            self = newValue.map { DGDocument.Value($0) } ?? .nil
        }
    }
    
    public var stream: Data? {
        get {
            switch self {
            case let .stream(stream): return stream
            default: return nil
            }
        }
        set {
            self = newValue.map { .stream($0) } ?? .nil
        }
    }
}

extension DGDocument.Value {
    
    public var count: Int {
        switch self {
        case let .array(array): return array.count
        case let .dictionary(dictionary): return dictionary.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(index: Int) -> DGDocument.Value {
        get {
            if case let .array(array) = self {
                return array[index]
            }
            return nil
        }
        set {
            switch self {
            case var .array(array):
                if index >= array.count {
                    array.append(contentsOf: repeatElement(.nil, count: index - array.count + 1))
                }
                array[index] = newValue
                self = .array(array)
            default:
                self = .array(Array(repeating: .nil, count: index) + [newValue])
            }
        }
    }
    
    public var keys: Dictionary<String, DGDocument.Value>.Keys {
        switch self {
        case let .dictionary(dictionary): return dictionary.keys
        default: fatalError("Not an object.")
        }
    }
    
    public subscript(key: String) -> DGDocument.Value {
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
            default:
                self = .dictionary([key: newValue])
            }
        }
    }
}
