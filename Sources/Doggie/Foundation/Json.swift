//
//  Json.swift
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

public struct Json {
    
    fileprivate let value: Any
    
    fileprivate init(value: Any?) {
        self.value = value ?? NSNull()
    }
    
    fileprivate static func unwrap(_ value: Any) -> Any {
        if let json = value as? Json {
            return json.value
        }
        return value
    }
}

extension Json {
    
    public init(_ value: Bool) {
        self.value = value
    }
    public init<T : Integer>(_ value: T) {
        self.value = value.toIntMax()
    }
    public init(_ value: Float) {
        self.value = value
    }
    public init(_ value: Double) {
        self.value = value
    }
    public init(_ value: String) {
        self.value = value
    }
    public init<S : Sequence>(_ elements: S) {
        self.value = elements.map { Json.unwrap($0) }
    }
    public init(_ elements: [String: Any]) {
        var elements = elements
        for (key, value) in elements {
            if let json = value as? Json {
                elements[key] = json.value
            } else if value is NSNull {
                elements[key] = nil
            }
        }
        self.value = elements
    }
}

extension Json: ExpressibleByNilLiteral {
    
    public init(nilLiteral value: Void) {
        self.value = NSNull()
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
        self.init(value: elements.map { $0.value })
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Json) ...) {
        var dictionary = [String: Any](minimumCapacity: elements.count)
        for (key, value) in elements {
            let val = value.value
            dictionary[key] = val is NSNull ? nil : val
        }
        self.init(value: dictionary)
    }
}

extension Json: CustomStringConvertible {
    
    public var description: String {
        if self.isNil {
            return "nil"
        }
        switch self.value {
        case let number as NSNumber: return number.description
        case let string as String: return string
        case let array as [Any]:
            var result = "["
            var first = true
            for item in array {
                if first {
                    first = false
                } else {
                    result += ", "
                }
                result += (item as? String).map { "\"\($0)\"" } ?? Json(value: item).description
            }
            result += "]"
            return result
        case let dictionary as [String: Any]:
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
                result += (v as? String).map { "\"\($0)\"" } ?? Json(value: v).description
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
        return self.value is NSNull
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
        return self.value is [Any]
    }
    
    public var isObject : Bool {
        return self.value is [String:Any]
    }
}

extension Json {
    
    fileprivate var numberValue: NSNumber? {
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
    public var decimalValue: Decimal? {
        get {
            return self.numberValue?.decimalValue
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
            if let array = self.value as? [Any] {
                return array.map { Json(value: $0) }
            }
            return nil
        }
        set {
            self = Json(value: newValue?.map { $0.value })
        }
    }
    public var dictionary: [String: Json]? {
        get {
            if let elements = self.value as? [String: Any] {
                var dictionary = [String: Json](minimumCapacity: elements.count)
                for (key, value) in elements {
                    dictionary[key] = Json(value: value)
                }
                return dictionary
            }
            return nil
        }
        set {
            if let elements = newValue {
                var dictionary = [String: Any](minimumCapacity: elements.count)
                for (key, value) in elements {
                    dictionary[key] = value.value
                }
                self = Json(value: dictionary)
            } else {
                self = nil
            }
        }
    }
}

extension Json {
    
    public var count: Int {
        switch self.value {
        case let array as [Any]: return array.count
        case let dictionary as [String: Any]: return dictionary.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(index: Int) -> Json {
        get {
            if case let array as [Any] = self.value {
                let val = array[index]
                return Json(value: val)
            }
            return nil
        }
        set {
            switch self.value {
            case var array as [Any]:
                if index >= array.count {
                    array.append(contentsOf: repeatElement(NSNull() as Any, count: index - array.count + 1))
                }
                array[index] = newValue.value
                self = Json(value: array)
            default:
                self = Json(value: [Any](repeating: NSNull(), count: index) + [newValue.value])
            }
        }
    }
    
    public var keys: LazyMapCollection<Dictionary<String, Any>, String> {
        switch self.value {
        case let dictionary as [String: Any]: return dictionary.keys
        default: fatalError("Not an object.")
        }
    }
    
    public subscript(key: String) -> Json {
        get {
            if case let dictionary as [String: Any] = self.value {
                if let val = dictionary[key] {
                    return Json(value: val)
                }
                return nil
            }
            return nil
        }
        set {
            switch self.value {
            case var dictionary as [String: Any]:
                let val = newValue.value
                dictionary[key] = val is NSNull ? nil : val
                self = Json(value: dictionary)
            default:
                self = Json(value: [key: newValue.value])
            }
        }
    }
}

extension Json {
    
    public var data: Data? {
        if JSONSerialization.isValidJSONObject(self.value) {
            return try? JSONSerialization.data(withJSONObject: self.value, options: [])
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
