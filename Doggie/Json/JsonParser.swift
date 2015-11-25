//
//  JsonParser.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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

public enum JsonParseError : ErrorType {
    
    case UnexpectedEndOfToken
    case UnexpectedToken(position: Int)
    case InvalidEscapeCharacter(position: Int)
}

extension Json {
    
    public static func Parse(bytes bytes: UnsafePointer<UInt8>, count: Int) throws -> Json {
        var parser = JsonParser(bytes: bytes, count: count)
        return try parser.parseValue()
    }
    public static func Parse(str: String) throws -> Json {
        return try Parse(str.dataUsingEncoding(NSUTF8StringEncoding)!)
    }
}

extension Json {
    
    public static func Parse(data: NSData) throws -> Json {
        return try Parse(bytes: UnsafePointer(data.bytes), count: data.length)
    }
}

private struct CharacterScanner : GeneratorType {
    
    let count: Int
    var pos: Int
    var bytes: UnsafePointer<UInt8>
    var current: UInt8?
    
    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.bytes = bytes
        self.count = count
        self.pos = 0
    }
    
    mutating func next() -> UInt8? {
        if pos < count {
            ++pos
            current = (bytes++).memory
            return current
        } else {
            return nil
        }
    }
}

private struct StringBuilder {
    
    var buf: [UInt8]
    var pos: Int
    
    init() {
        buf = [UInt8]()
        pos = 0
    }
    
    mutating func append(x: UInt8) {
        if pos < buf.count {
            buf[pos] = x
        } else {
            buf.append(x)
        }
        ++pos
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
    
    mutating func clear() {
        pos = 0
    }
    
    mutating func getString() -> String? {
        self.append(0)
        return String.fromCString(UnsafePointer(buf))
    }
}

private struct JsonParser {
    
    var strbuf: StringBuilder
    var scanner: CharacterScanner
    
    init(bytes: UnsafePointer<UInt8>, count: Int) {
        self.strbuf = StringBuilder()
        self.scanner = CharacterScanner(bytes: bytes, count: count)
        self.scanner.next()
    }
    
    var currentChar : UInt8? {
        return scanner.current
    }
    
    mutating func skipWhitespaces() throws {
        while currentChar != nil && [9, 10, 13, 32].contains(currentChar!) {
            scanner.next()
        }
        if currentChar == nil {
            throw JsonParseError.UnexpectedEndOfToken
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
        case 91: return try parseArray()
        case 123: return try parseObject()
        default: throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
    }
    
    mutating func parseNull() throws -> Json {
        if scanner.next() != 117 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        scanner.next()
        return nil
    }
    mutating func parseTrue() throws -> Json {
        if scanner.next() != 114 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 117 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 101 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        scanner.next()
        return true
    }
    mutating func parseFalse() throws -> Json {
        if scanner.next() != 97 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 108 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 115 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        if scanner.next() != 101 {
            throw JsonParseError.UnexpectedToken(position: scanner.pos)
        }
        scanner.next()
        return false
    }
    
    mutating func parseNumber() throws -> Json {
        strbuf.clear()
        var isFloat = false
        Loop: while currentChar != nil {
            switch currentChar! {
            case 43, 45, 48...57:
                strbuf.append(currentChar!)
                scanner.next()
            case 46, 69, 101:
                strbuf.append(currentChar!)
                scanner.next()
                isFloat = true
            default: break Loop
            }
        }
        strbuf.append(0)
        if isFloat {
            var error: UnsafeMutablePointer<Int8> = nil
            let val = strtod(UnsafePointer(strbuf.buf), &error)
            if error.memory == 0 {
                return Json(val)
            }
        } else {
            var error: UnsafeMutablePointer<Int8> = nil
            let val = strtol(UnsafePointer(strbuf.buf), &error, 10)
            if error.memory == 0 {
                return Json(val)
            }
        }
        throw JsonParseError.UnexpectedToken(position: scanner.pos)
    }
    
    mutating func parseString() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.UnexpectedEndOfToken
        }
        strbuf.clear()
        Loop: while currentChar != nil {
            switch currentChar! {
            case 92:
                if let current = scanner.next() {
                    if strbuf.append(escape: current) {
                        scanner.next()
                    } else {
                        throw JsonParseError.InvalidEscapeCharacter(position: scanner.pos)
                    }
                } else {
                    throw JsonParseError.UnexpectedEndOfToken
                }
            case 34:
                scanner.next()
                break Loop
            default:
                strbuf.append(currentChar!)
                scanner.next()
            }
        }
        if let val = strbuf.getString() {
            return Json(val)
        }
        throw JsonParseError.UnexpectedToken(position: scanner.pos)
    }
    
    mutating func parseArray() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.UnexpectedEndOfToken
        }
        try skipWhitespaces()
        var array = [Json]()
        Loop: while currentChar != nil {
            switch currentChar! {
            case 44:
                if scanner.next() == nil {
                    throw JsonParseError.UnexpectedEndOfToken
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
        strbuf.clear()
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
        return strbuf.getString()
    }
    
    mutating func parseObject() throws -> Json {
        if scanner.next() == nil {
            throw JsonParseError.UnexpectedEndOfToken
        }
        try skipWhitespaces()
        var dict = [String: Json]()
        Loop: while currentChar != nil {
            switch currentChar! {
            case 44:
                if scanner.next() == nil {
                    throw JsonParseError.UnexpectedEndOfToken
                }
                try skipWhitespaces()
            case 125:
                scanner.next()
                break Loop
            case 34:
                if let key = parseKey() {
                    try skipWhitespaces()
                    if currentChar != 58 {
                        throw JsonParseError.UnexpectedToken(position: scanner.pos)
                    }
                    if scanner.next() == nil {
                        throw JsonParseError.UnexpectedEndOfToken
                    }
                    dict[key] = try parseValue()
                    try skipWhitespaces()
                } else {
                    throw JsonParseError.UnexpectedToken(position: scanner.pos)
                }
            default: throw JsonParseError.UnexpectedToken(position: scanner.pos)
            }
        }
        return Json(dict)
    }
    
}