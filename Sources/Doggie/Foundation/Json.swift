//
//  Json.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct Json {
    
    private let value: Any
    
    private init(value: Any?) {
        self.value = value ?? NSNull()
    }
    
    private static func unwrap(_ value: Any) -> Any? {
        switch value {
        case is NSNull: return nil
        case let json as Json: return json.value
        case let array as [Json]: return array.map { Json.unwrap($0.value) ?? NSNull() }
        case let array as [Any]: return array.map { Json.unwrap($0) ?? NSNull() }
        case let dictionary as [String: Json]: return Dictionary(uniqueKeysWithValues: dictionary.lazy.compactMap { key, value in Json.unwrap(value.value).map { (key, $0) } })
        case let dictionary as [String: Any]: return Dictionary(uniqueKeysWithValues: dictionary.lazy.compactMap { key, value in Json.unwrap(value).map { (key, $0) } })
        default: return value
        }
    }
}

extension Json {
    
    public init(_ value: Bool) {
        self.value = value
    }
    public init<T : FixedWidthInteger>(_ value: T) {
        self.value = value
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
    public init(_ elements: [Any]) {
        self.value = elements.map { Json.unwrap($0) ?? NSNull() }
    }
    public init(_ elements: [String: Any]) {
        self.value = Json.unwrap(elements)!
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
        self.init(value: elements.map { Json.unwrap($0) })
    }
}

extension Json: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, Json) ...) {
        self.init(value: Json.unwrap(Dictionary(uniqueKeysWithValues: elements)))
    }
}

extension Json: CustomStringConvertible {
    
    public var description: String {
        switch self.value {
        case is NSNull: return "nil"
        case let number as NSNumber: return number.description
        case let number as Int: return number.description
        case let number as Int64: return number.description
        case let number as Int32: return number.description
        case let number as Int16: return number.description
        case let number as Int8: return number.description
        case let number as UInt: return number.description
        case let number as UInt64: return number.description
        case let number as UInt32: return number.description
        case let number as UInt16: return number.description
        case let number as UInt8: return number.description
        case let number as Double: return number.description
        case let number as Float: return number.description
        case let bool as Bool: return bool.description
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
        switch self.value {
        case is NSNumber: return true
        case is Int: return true
        case is Int64: return true
        case is Int32: return true
        case is Int16: return true
        case is Int8: return true
        case is UInt: return true
        case is UInt64: return true
        case is UInt32: return true
        case is UInt16: return true
        case is UInt8: return true
        case is Double: return true
        case is Float: return true
        default: return false
        }
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
    
    private var numberValue: NSNumber? {
        switch value {
        case let number as NSNumber: return number
        case let number as Int: return NSNumber(value: number)
        case let number as Int64: return NSNumber(value: number)
        case let number as Int32: return NSNumber(value: number)
        case let number as Int16: return NSNumber(value: number)
        case let number as Int8: return NSNumber(value: number)
        case let number as UInt: return NSNumber(value: number)
        case let number as UInt64: return NSNumber(value: number)
        case let number as UInt32: return NSNumber(value: number)
        case let number as UInt16: return NSNumber(value: number)
        case let number as UInt8: return NSNumber(value: number)
        case let number as Double: return NSNumber(value: number)
        case let number as Float: return NSNumber(value: number)
        default: return nil
        }
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
            self = Json(value: newValue?.map { Json.unwrap($0.value) ?? NSNull() })
        }
    }
    public var dictionary: [String: Json]? {
        get {
            if let elements = self.value as? [String: Any] {
                return elements.mapValues { Json(value: $0) }
            }
            return nil
        }
        set {
            self = Json(value: newValue.map { Json.unwrap($0)! })
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
                array[index] = Json.unwrap(newValue.value) ?? NSNull()
                self = Json(value: array)
            default: fatalError("Not an array.")
            }
        }
    }
    
    public var keys: Dictionary<String, Any>.Keys {
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
                dictionary[key] = Json.unwrap(newValue.value)
                self = Json(value: dictionary)
            default: fatalError("Not an object.")
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
