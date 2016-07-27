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

import Foundation

public struct Json {
    
    private let value: AnyObject?
    
    private init(value: AnyObject?) {
        self.value = value
    }
}

extension Json {
    
    public init(_ value: Bool) {
        self.value = value
    }
    public init<T : Integer>(_ value: T) {
        self.value = NSNumber(value: value.toIntMax())
    }
    public init(_ value: Float) {
        self.value = Double(value)
    }
    public init(_ value: Double) {
        self.value = value
    }
    public init(_ value: String) {
        self.value = value
    }
    public init<S : Sequence where S.Iterator.Element == Json>(_ elements: S) {
        self.value = elements.map { $0.value! }
    }
    public init(_ elements: [String: Json]) {
        var dictionary = [String: AnyObject](minimumCapacity: elements.count)
        for (key, value) in elements {
            dictionary[key] = value.value
        }
        self.value = dictionary
    }
}

extension Json: ExpressibleByNilLiteral {
    
    public init(nilLiteral value: Void) {
        self.value = nil
    }
}

extension Json: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension Json: ExpressibleByStringLiteral {
    
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

extension Json: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Json ...) {
        self.init(elements)
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Json) ...) {
        var dictionary = [String: AnyObject](minimumCapacity: elements.count)
        for (key, value) in elements {
            dictionary[key] = value.value
        }
        self.init(value: dictionary)
    }
}

extension Json: CustomStringConvertible {
    
    public var description: String {
        switch self.value {
        case nil: return "nil"
        case let number as NSNumber: return number.description
        case let string as String: return string
        case let array as [AnyObject]:
            var result = "["
            var first = true
            for item in array {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                result += Json(value: item).description
            }
            result += "]"
            return result
        case let dictionary as [String: AnyObject]:
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
                result += Json(value: v).description
            }
            result += "]"
            return result
        default: return "invalid object"
        }
    }
}

extension Json {
    
    public static func Parse(data: Data) throws -> Json {
        return Json(value: try JSONSerialization.jsonObject(with: data, options: []))
    }
    
    public static func Parse(stream: InputStream) throws -> Json {
        return Json(value: try JSONSerialization.jsonObject(with: stream, options: []))
    }
}

extension Json {
    
    public var isNil : Bool {
        return self.value == nil
    }
    
    public var isBool : Bool {
        return self.value is Bool
    }
    
    public var isNumber : Bool {
        return self.value is NSNumber
    }
    
    public var isString : Bool {
        return self.value is String
    }
    
    public var isArray : Bool {
        return self.value is [AnyObject]
    }
    
    public var isObject : Bool {
        return self.value is [String:AnyObject]
    }
}

extension Json {
    
    private var numberValue: NSNumber? {
        return value as? NSNumber
    }
    public var boolValue: Bool? {
        get {
            return value as? Bool
        }
        set {
            self = Json(value: newValue)
        }
    }
    
    public var int8Value: Int8? {
        get {
            return self.numberValue?.int8Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var uint8Value: UInt8? {
        get {
            return self.numberValue?.uint8Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var int16Value: Int16? {
        get {
            return self.numberValue?.int16Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var uint16Value: UInt16? {
        get {
            return self.numberValue?.uint16Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var int32Value: Int32? {
        get {
            return self.numberValue?.int32Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var uint32Value: UInt32? {
        get {
            return self.numberValue?.uint32Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var int64Value: Int64? {
        get {
            return self.numberValue?.int64Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var uint64Value: UInt64? {
        get {
            return self.numberValue?.uint64Value
        }
        set {
            self = Json(value: newValue.map(NSNumber.init))
        }
    }
    
    public var floatValue: Float? {
        get {
            return self.numberValue?.floatValue
        }
        set {
            self = Json(value: newValue)
        }
    }
    
    public var doubleValue: Double? {
        get {
            return self.numberValue?.doubleValue
        }
        set {
            self = Json(value: newValue)
        }
    }
    
    public var intValue: Int? {
        get {
            return self.numberValue?.intValue
        }
        set {
            self = Json(value: newValue)
        }
    }
    
    public var uintValue: UInt? {
        get {
            return self.numberValue?.uintValue
        }
        set {
            self = Json(value: newValue)
        }
    }
    public var stringValue: String? {
        get {
            return value as? String
        }
        set {
            self = Json(value: newValue)
        }
    }
    public var array: [Json]? {
        get {
            if let array = self.value as? [AnyObject] {
                return array.map { Json(value: $0) }
            }
            return nil
        }
        set {
            self = Json(value: newValue?.map { $0.value! })
        }
    }
    public var dictionary: [String: Json]? {
        if let elements = self.value as? [String: AnyObject] {
            var dictionary = [String: Json](minimumCapacity: elements.count)
            for (key, value) in elements {
                dictionary[key] = Json(value: value)
            }
            return dictionary
        }
        return nil
    }
}

extension Json {
    
    public struct Index : Comparable {
        
        private enum Base {
            case array(Int)
            case object(DictionaryIndex<String, AnyObject>)
        }
        
        private let base: Base
    }
}

public func ==(lhs: Json.Index, rhs: Json.Index) -> Bool {
    switch lhs.base {
    case .array(let _lhs):
        switch rhs.base {
        case .array(let _rhs): return _lhs == _rhs
        case .object(_): fatalError("Not the same index type.")
        }
    case .object(let _lhs):
        switch rhs.base {
        case .array(_): fatalError("Not the same index type.")
        case .object(let _rhs): return _lhs == _rhs
        }
    }
}
public func <(lhs: Json.Index, rhs: Json.Index) -> Bool {
    switch lhs.base {
    case .array(let _lhs):
        switch rhs.base {
        case .array(let _rhs): return _lhs < _rhs
        case .object(_): fatalError("Not the same index type.")
        }
    case .object(let _lhs):
        switch rhs.base {
        case .array(_): fatalError("Not the same index type.")
        case .object(let _rhs): return _lhs < _rhs
        }
    }
}

private extension Json.Index {
    
    var intValue: Int? {
        switch self.base {
        case .array(let x): return x
        default: return nil
        }
    }
    
    var objectIndex: DictionaryIndex<String, AnyObject>? {
        switch self.base {
        case .object(let x): return x
        default: return nil
        }
    }
}

extension Json : MutableCollection {
    
    public var startIndex : Index {
        switch self.value {
        case let array as [AnyObject]: return Index(base: .array(array.startIndex))
        case let dictionary as [String: AnyObject]: return Index(base: .object(dictionary.startIndex))
        default: fatalError("Not an array or object.")
        }
    }
    public var endIndex : Index {
        switch self.value {
        case let array as [AnyObject]: return Index(base: .array(array.endIndex))
        case let dictionary as [String: AnyObject]: return Index(base: .object(dictionary.endIndex))
        default: fatalError("Not an array or object.")
        }
    }
    
    public func index(after i: Index) -> Index {
        switch self.value {
        case let array as [AnyObject]:
            if let index = i.intValue {
                return Index(base: .array(array.index(after: index)))
            }
            fatalError("Not an object.")
        case let dictionary as [String: AnyObject]:
            if let index = i.objectIndex {
                return Index(base: .object(dictionary.index(after: index)))
            }
            fatalError("Not an array.")
        default: fatalError("Not an array or object.")
        }
    }
    
    public var count: Int {
        switch self.value {
        case let array as [AnyObject]: return array.count
        case let dictionary as [String: AnyObject]: return dictionary.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(position: Index) -> Json {
        get {
            switch self.value {
            case let array as [AnyObject]:
                if let index = position.intValue {
                    return Json(value: array[index])
                }
            case let dictionary as [String: AnyObject]:
                if let index = position.objectIndex {
                    return Json(value: dictionary[index].1)
                }
            default: break
            }
            return nil
        }
        set {
            switch self.value {
            case var array as [AnyObject]:
                if let index = position.intValue {
                    array[index] = newValue.value!
                    self = Json(value: array)
                } else {
                    fatalError("Not an object.")
                }
            case var dictionary as [String: AnyObject]:
                if let index = position.objectIndex {
                    dictionary[dictionary[index].0] = newValue.value
                    self = Json(value: dictionary)
                } else {
                    fatalError("Not an array.")
                }
            default:
                if position.intValue != nil {
                    fatalError("Not an array.")
                } else {
                    fatalError("Not an object.")
                }
            }
        }
    }
    
    public subscript(index: Int) -> Json {
        get {
            switch self.value {
            case let array as [AnyObject]: return Json(value: array[index])
            default: break
            }
            return nil
        }
        set {
            switch self.value {
            case var array as [AnyObject]:
                array[index] = newValue.value!
                self = Json(value: array)
            default: fatalError("Not an array.")
            }
        }
    }
    
    public subscript(key: String) -> Json {
        get {
            switch self.value {
            case let dictionary as [String: AnyObject]:
                if let val = dictionary[key] {
                    return Json(value: val)
                }
                return Json(value: nil)
            default: break
            }
            return nil
        }
        set {
            switch self.value {
            case var dictionary as [String: AnyObject]:
                dictionary[key] = newValue.value
                self = Json(value: dictionary)
            default: fatalError("Not an object.")
            }
        }
    }
}

extension Json {
    
    public var data: Data? {
        if let value = self.value, JSONSerialization.isValidJSONObject(value) {
            return try? JSONSerialization.data(withJSONObject: value, options: [])
        }
        return nil
    }
    public var string: String? {
        if let _data = self.data {
            return String(data: _data, encoding: String.Encoding.utf8)
        }
        return nil
    }
}
