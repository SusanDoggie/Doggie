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

private enum jValue {
    
    case bool(Swift.Bool)
    case integer(Swift.IntMax)
    case float(Swift.Double)
    case string(Swift.String)
    case array([Json])
    case object([Swift.String: Json])
}

public struct Json {
    
    private var value: jValue
    
    public init(_ val: Bool) {
        self.value = .bool(val)
    }
    public init<S : SignedInteger>(_ val: S) {
        self.value = .integer(val.toIntMax())
    }
    public init(_ val: Float) {
        self.value = .float(Double(val))
    }
    public init(_ val: Double) {
        self.value = .float(val)
    }
    public init(_ val: String) {
        self.value = .string(val)
    }
    public init(_ val: [Json]) {
        self.value = .array(val)
    }
    public init(_ val: [String: Json]) {
        self.value = .object(val)
    }
}

extension Json: BooleanLiteralConvertible {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension Json: IntegerLiteralConvertible {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Json: FloatLiteralConvertible {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension Json: StringLiteralConvertible {
    
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

extension Json: ArrayLiteralConvertible {
    
    public init(arrayLiteral elements: Json ...) {
        self.init(elements)
    }
}

extension Json: DictionaryLiteralConvertible {
    
    public init(dictionaryLiteral elements: (String, Json) ...) {
        var dictionary = [String: Json](minimumCapacity: elements.count)
        for pair in elements {
            dictionary[pair.0] = pair.1
        }
        self.init(dictionary)
    }
}

extension Json: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        switch self.value {
        case .bool(let x): return x.description
        case .integer(let x): return x.description
        case .float(let x): return x.description
        case .string(let x): return x
        case .array(let x): return x.description
        case .object(let x): return x.description
        }
    }
    public var debugDescription: String {
        switch self.value {
        case .bool(let x): return x.description
        case .integer(let x): return x.description
        case .float(let x): return x.description
        case .string(let x): return x.debugDescription
        case .array(let x): return x.debugDescription
        case .object(let x): return x.debugDescription
        }
    }
}

extension Json {
    
    public var isBool : Bool {
        switch self.value {
        case .bool: return true
        default: return false
        }
    }
    
    public var isNumber : Bool {
        switch self.value {
        case .integer, .float: return true
        default: return false
        }
    }
    
    public var isString : Bool {
        switch self.value {
        case .string: return true
        default: return false
        }
    }
    
    public var isArray : Bool {
        switch self.value {
        case .array: return true
        default: return false
        }
    }
    
    public var isObject : Bool {
        switch self.value {
        case .object: return true
        default: return false
        }
    }
}

extension Json {
    
    var isInteger: Bool {
        switch self.value {
        case .integer: return true
        case .float: return false
        default: return false
        }
    }
    var isFloat: Bool {
        switch self.value {
        case .integer: return false
        case .float: return true
        default: return false
        }
    }
}

extension Json {
    
    public var boolValue: Bool! {
        switch self.value {
        case .bool(let x): return x
        case .integer(let x): return x != 0
        case .float(let x): return x != 0
        default: return nil
        }
    }
    public var intValue: Int! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return Int(truncatingBitPattern: x)
        case .float(let x): return Int(x)
        default: return nil
        }
    }
    public var longIntValue: IntMax! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return x
        case .float(let x): return IntMax(x)
        default: return nil
        }
    }
    public var doubleValue: Double! {
        switch self.value {
        case .bool(let x): return x ? 1 : 0
        case .integer(let x): return Double(x)
        case .float(let x): return x
        default: return nil
        }
    }
    public var stringValue: String! {
        switch self.value {
        case .string(let x): return x
        default: return nil
        }
    }
}

extension Json {
    
    public var count: Int {
        switch self.value {
        case .array(let x): return x.count
        case .object(let x): return x.count
        default: fatalError("Not an array or object.")
        }
    }
    
    public subscript(position: Int) -> Json {
        get {
            switch self.value {
            case .array(let x): return x[position]
            default: fatalError("Not an array.")
            }
        }
        set {
            switch self.value {
            case .array(var x):
                x[position] = newValue
                self.value = .array(x)
            default: fatalError("Not an array.")
            }
        }
    }
    public subscript(key: String) -> Json? {
        get {
            switch self.value {
            case .object(let x): return x[key] ?? nil
            default: fatalError("Not an object.")
            }
        }
        set {
            switch self.value {
            case .object(var x):
                x[key] = newValue
                self.value = .object(x)
            default: fatalError("Not an object.")
            }
        }
    }
}

extension Json {
    
    public var array: [Json]! {
        switch self.value {
        case .array(let x): return x
        default: return nil
        }
    }
    public var dictionary: [String: Json]! {
        switch self.value {
        case .object(let x): return x
        default: return nil
        }
    }
}

private func escapeString(_ source : String, _ result: inout [UInt8]) {
    result.append(34)
    for c in source.utf8 {
        switch c {
        case 13:
            result.append(92)
            result.append(114)
        case 10:
            result.append(92)
            result.append(110)
        case 9:
            result.append(92)
            result.append(116)
        case 34, 39, 47, 92:
            result.append(92)
            result.append(c)
        default: result.append(c)
        }
    }
    result.append(34)
}

extension Json {
    
    public func write(_ data: inout [UInt8]) {
        switch self.value {
        case .bool(let x):
            if x {
                data.append(116)
                data.append(114)
                data.append(117)
                data.append(101)
            } else {
                data.append(102)
                data.append(97)
                data.append(108)
                data.append(115)
                data.append(101)
            }
        case .integer(let x): data.append(contentsOf: String(x).utf8)
        case .float(let x): data.append(contentsOf: String(x).utf8)
        case .string(let x): escapeString(x, &data)
        case .array(let x):
            data.append(91)
            var flag = false
            for item in x {
                if flag {
                    data.append(44)
                }
                item.write(&data)
                flag = true
            }
            data.append(93)
        case .object(let x):
            data.append(123)
            var flag = false
            for (key, item) in x {
                if flag {
                    data.append(44)
                }
                escapeString(key, &data)
                data.append(58)
                item.write(&data)
                flag = true
            }
            data.append(125)
        }
    }
    
    public var data: [UInt8] {
        var _data = [UInt8]()
        self.write(&_data)
        return _data
    }
    public var string: String {
        var _data = self.data
        _data.append(0)
        return String(cString: UnsafePointer(_data)) ?? ""
    }
}

extension Json : Equatable {
    
}

public func == (lhs: Json, rhs: Json) -> Bool {
    switch lhs.value {
    case .bool(let l):
        switch rhs.value {
        case .bool(let r): return l == r
        default: return false
        }
    case .integer(let l):
        switch rhs.value {
        case .integer(let r): return l == r
        case .float(let r): return Double(l) == r
        default: return false
        }
    case .float(let l):
        switch rhs.value {
        case .integer(let r): return l == Double(r)
        case .float(let r): return l == r
        default: return false
        }
    case .string(let l):
        switch rhs.value {
        case .string(let r): return l == r
        default: return false
        }
    case .array(let l):
        switch rhs.value {
        case .array(let r): return l == r
        default: return false
        }
    case .object(let l):
        switch rhs.value {
        case .object(let r): return l == r
        default: return false
        }
    }
}

public enum JsonParseError : ErrorProtocol {
    
    case unexpectedEndOfToken
    case unexpectedToken(position: Int)
    case invalidEscapeCharacter(position: Int)
    case invalidArrayStructure(position: Int)
}

extension Json {
    
    public static func Parse(bytes: UnsafePointer<UInt8>, count: Int) throws -> Json? {
        var parser = JsonParser(bytes: bytes, count: count)
        return try parser.parseValue()
    }
    public static func Parse(string: String) throws -> Json? {
        return try Parse(data: string.data(using: .utf8)!)
    }
}

extension Json {
    
    public static func Parse(data: Data) throws -> Json? {
        return try data.withUnsafeBytes { try Parse(bytes: $0, count: data.count) }
    }
}

private struct CharacterScanner : IteratorProtocol, Sequence {
    
    let count: Int
    var pos: Int
    var bytes: UnsafePointer<UInt8>
    var current: UInt8?
    
    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.bytes = bytes
        self.count = count
        self.pos = 0
    }
    
    @discardableResult
    mutating func next() -> UInt8? {
        if pos < count {
            current = bytes.pointee
            pos += 1
            bytes += 1
            return current
        } else {
            return nil
        }
    }
}

private extension String {
    
    mutating func append(_ x: UInt8) {
        UnicodeScalar(x).write(to: &self)
    }
    
    mutating func append(escape x: UInt8) -> Bool {
        switch x {
        case 34, 39, 47, 92:
            self.append(x)
        case 116:
            self.append(9)
        case 114:
            self.append(13)
        case 110:
            self.append(10)
        default:
            return false
        }
        return true
    }
}

private struct JsonParser {
    
    var strbuf: String
    var scanner: CharacterScanner
    
    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.strbuf = String()
        self.scanner = CharacterScanner(bytes: bytes, count: count)
        self.scanner.next()
    }
    
    var currentChar : UInt8? {
        return scanner.current
    }
    
    mutating func skipWhitespaces() throws {
        Loop: while currentChar != nil {
            switch currentChar! {
            case 9, 10, 13, 32: scanner.next()
            default: break Loop
            }
        }
        if currentChar == nil {
            throw JsonParseError.unexpectedEndOfToken
        }
    }
    
    mutating func parseValue() throws -> Json? {
        try skipWhitespaces()
        switch currentChar! {
        case 110: try parseNull()
            return nil
        case 116: return try parseTrue()
        case 102: return try parseFalse()
        case 45, 48...57: return try parseNumber()
        case 34: return try parseString()
        case 123: return try parseObject()
        case 91: return try parseArray()
        default: throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
    }
    
    mutating func parseNull() throws {
        if scanner.next() != 117 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        scanner.next()
    }
    mutating func parseTrue() throws -> Json {
        if scanner.next() != 114 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 117 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 101 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        scanner.next()
        return true
    }
    mutating func parseFalse() throws -> Json {
        if scanner.next() != 97 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 115 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 101 {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        scanner.next()
        return false
    }
    
    mutating func parseNumber() throws -> Json {
        let start: UnsafeMutablePointer<Int8> = UnsafeMutablePointer(scanner.bytes - 1)
        var end: UnsafeMutablePointer<Int8>? = start
        let val = strtod(start, &end)
        if start == end {
            throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
        scanner.bytes = UnsafePointer(end!)
        scanner.pos += abs(end! - start) - 1
        scanner.next()
        return Json(val)
    }
    
    mutating func parseString() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.unexpectedEndOfToken
        }
        strbuf.removeAll(keepingCapacity: true)
        Loop: while currentChar != nil {
            switch currentChar! {
            case 92:
                if let current = scanner.next() {
                    if strbuf.append(escape: current) {
                        scanner.next()
                    } else {
                        throw JsonParseError.invalidEscapeCharacter(position: scanner.pos)
                    }
                } else {
                    throw JsonParseError.unexpectedEndOfToken
                }
            case 34:
                scanner.next()
                break Loop
            default:
                strbuf.append(currentChar!)
                scanner.next()
            }
        }
        return Json(strbuf)
    }
    
    mutating func parseArray() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.unexpectedEndOfToken
        }
        try skipWhitespaces()
        var array = [Json]()
        Loop: while currentChar != nil {
            switch currentChar! {
            case 44:
                if scanner.next() == nil {
                    throw JsonParseError.unexpectedEndOfToken
                }
                try skipWhitespaces()
            case 93:
                scanner.next()
                break Loop
            default:
                if let val = try parseValue() {
                    array.append(val)
                } else {
                    throw JsonParseError.invalidArrayStructure(position: scanner.pos)
                }
                try skipWhitespaces()
            }
        }
        return Json(array)
    }
    
    mutating func parseKey() -> String? {
        if scanner.next() == nil {
            return nil
        }
        strbuf.removeAll(keepingCapacity: true)
        Loop: while currentChar != nil {
            switch currentChar! {
            case 92:
                if let current = scanner.next() where strbuf.append(escape: current) {
                    scanner.next()
                } else {
                    return nil
                }
            case 34:
                scanner.next()
                break Loop
            default:
                strbuf.append(currentChar!)
                scanner.next()
            }
        }
        return strbuf
    }
    
    mutating func parseObject() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.unexpectedEndOfToken
        }
        try skipWhitespaces()
        var dict = [String: Json]()
        Loop: while currentChar != nil {
            switch currentChar! {
            case 44:
                if scanner.next() == nil {
                    throw JsonParseError.unexpectedEndOfToken
                }
                try skipWhitespaces()
            case 125:
                scanner.next()
                break Loop
            case 34:
                if let key = parseKey() {
                    try skipWhitespaces()
                    if currentChar != 58 {
                        throw JsonParseError.unexpectedToken(position: scanner.pos)
                    }
                    if scanner.next() == nil {
                        throw JsonParseError.unexpectedEndOfToken
                    }
                    dict[key] = try parseValue()
                    try skipWhitespaces()
                } else {
                    throw JsonParseError.unexpectedToken(position: scanner.pos)
                }
            default: throw JsonParseError.unexpectedToken(position: scanner.pos)
            }
        }
        return Json(dict)
    }
    
}
