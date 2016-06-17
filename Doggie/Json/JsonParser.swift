//
//  JsonParser.swift
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

public enum JsonParseError : ErrorProtocol {
    
    case unexpectedEndOfToken
    case unexpectedToken(position: Int)
    case invalidEscapeCharacter(position: Int)
}

extension Json {
    
    public static func Parse(bytes: UnsafePointer<UInt8>, count: Int) throws -> Json {
        var parser = JsonParser(bytes: bytes, count: count)
        return try parser.parseValue()
    }
    public static func Parse(string: String) throws -> Json {
        return try Parse(data: string.data(using: .utf8)!)
    }
}

extension Json {
    
    public static func Parse(data: Data) throws -> Json {
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
    
    mutating func parseValue() throws -> Json {
        try skipWhitespaces()
        switch currentChar! {
        case 110: return try parseNull()
        case 116: return try parseTrue()
        case 102: return try parseFalse()
        case 45, 48...57: return try parseNumber()
        case 34: return try parseString()
        case 123: return try parseObject()
        case 91: return try parseArray()
        default: throw JsonParseError.unexpectedToken(position: scanner.pos)
        }
    }
    
    mutating func parseNull() throws -> Json {
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
        return nil
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
                array.append(try parseValue())
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
