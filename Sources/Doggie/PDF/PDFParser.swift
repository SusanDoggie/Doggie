//
//  PDFParser.swift
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

extension PDFDocument {
    
    public enum ParserError: Error {
        case invalidFormat(String)
        case unknownToken(Int)
        case unexpectedEOF
    }
    
    public static func Parse(data: Data) throws -> PDFDocument {
        
        guard data.starts(with: [37, 80, 68, 70, 45]) else {
            throw ParserError.invalidFormat("'%PDF-' not find.")
        }
        
        let _version = try version(data: data)
        
        let (trailer, xref) = try xrefTable(data: data, version: _version)
        
        var table: [[PDFDocument.Value?]] = []
        var stream: [PDFDocument.ObjectIdentifier: (PDFDocument.Dictionary, Int)] = [:]
        
        for (identifier, offset) in xref {
            
            var _lineStart = lineStartPosition(data: data, position: offset)
            let _lineEnd = lineEndPosition(data: data, position: offset)
            
            if _lineStart >= _lineEnd {
                throw ParserError.invalidFormat("invalid file format.")
            }
            
            var flag = 0
            var id = 0
            var gen = 0
            
            loop: for (pos, d) in data[_lineStart..<_lineEnd].indexed() {
                switch d {
                case 48...57:
                    switch flag {
                    case 0: id = id * 10 + Int(d - 48)
                    case 1: gen = gen * 10 + Int(d - 48)
                    default: throw ParserError.invalidFormat("invalid obj format.")
                    }
                case 32: flag += 1
                case 111:
                    if flag != 2 || !data.suffix(from: pos).starts(with: [111, 98, 106]) {
                        throw ParserError.invalidFormat("'obj' not find.")
                    }
                    break loop
                default: throw ParserError.invalidFormat("invalid obj format.")
                }
            }
            
            if identifier.identifier != id || identifier.generation != gen {
                throw ParserError.invalidFormat("incorrect obj identifier.")
            }
            
            if id >= table.count {
                table.append(contentsOf: repeatElement([], count: id - table.count + 1))
            }
            if gen >= table[id].count {
                table[id].append(contentsOf: repeatElement(nil, count: gen - table[id].count + 1))
            }
            
            _lineStart = nextLineStartPosition(data: data, position: _lineEnd)
            
            let (pos, obj) = try parseValue(data: data, position: _lineStart, version: _version)
            
            if !obj.isDictionary {
                table[id][gen] = obj
                continue
            }
            
            var _tokenStart = pos
            var _tokenEnd = lineEndPosition(data: data, position: pos)
            
            while true {
                
                if _tokenStart > _tokenEnd {
                    throw ParserError.invalidFormat("invalid file format.")
                }
                if _tokenEnd > data.count {
                    throw ParserError.unexpectedEOF
                }
                
                if data[_tokenStart..<_tokenEnd].elementsEqual([101, 110, 100, 111, 98, 106]) {
                    
                    table[id][gen] = obj
                    
                    break
                    
                } else if data[_tokenStart..<_tokenEnd].elementsEqual([115, 116, 114, 101, 97, 109]) {
                    
                    if let dict = obj.dictionary, let length = dict["Length"] {
                        if _version >= (1, 2) && dict["F"] != nil {
                            table[id][gen] = PDFDocument.Value.stream(dict, Data())
                            break
                        }
                        switch length {
                        case let .number(length):
                            
                            let _length = length.intValue
                            
                            let _streamStart = nextLineStartPosition(data: data, position: _tokenEnd)
                            let data = data.suffix(from: _streamStart).prefix(_length)
                            
                            if data.count != _length {
                                throw ParserError.unexpectedEOF
                            }
                            table[id][gen] = PDFDocument.Value.stream(dict, data)
                            
                        case .indirect: stream[identifier] = (dict, _tokenEnd)
                        default: throw ParserError.invalidFormat("invalid stream format.")
                        }
                    } else {
                        throw ParserError.invalidFormat("invalid stream format.")
                    }
                    
                    break
                }
                
                _tokenStart = nextLineStartPosition(data: data, position: _tokenEnd)
                _tokenEnd = lineEndPosition(data: data, position: _tokenStart)
            }
        }
        
        for (identifier, (dict, offset)) in stream {
            let lengthId = dict["Length"]!.identifier!
            if lengthId.identifier < table.count && lengthId.generation < table[lengthId.identifier].count, let length = table[lengthId.identifier][lengthId.generation] {
                
                switch length {
                case let .number(length):
                    
                    let _length = length.intValue
                    
                    let _streamStart = nextLineStartPosition(data: data, position: offset)
                    let data = data.suffix(from: _streamStart).prefix(_length)
                    
                    if data.count != _length {
                        throw ParserError.unexpectedEOF
                    }
                    table[identifier.identifier][identifier.generation] = PDFDocument.Value.stream(dict, data)
                    
                default: throw ParserError.invalidFormat("obj \(lengthId.identifier) \(lengthId.generation) is not a number.")
                }
                
            } else {
                throw ParserError.invalidFormat("obj \(lengthId.identifier) \(lengthId.generation) not found.")
            }
        }
        
        return PDFDocument(version: _version, trailer: trailer, xref: PDFDocument.Xref(table))
    }
    
    fileprivate static func parseValue(data: Data, position: Int, version: (Int, Int)) throws -> (Int, PDFDocument.Value) {
        
        var position = position
        
        while position < data.count {
            switch data[position] {
            case 0, 9, 10, 12, 13, 32: position += 1
            case 125: position = nextLineStartPosition(data: data, position: lineEndPosition(data: data, position: position))
            case 110:
                if data.suffix(from: position).starts(with: [110, 117, 108, 108]) {
                    return (position + 4, .null)
                }
            case 116, 102: return try parseBool(data: data, position: position)
            case 40: return try parseLiteralString(data: data, position: position)
            case 47: return try parseName(data: data, position: position, version: version)
            case 91: return try parseArray(data: data, position: position, version: version)
            case 60:
                if position + 1 != data.count && data[position + 1] == 60 {
                    return try parseDictionary(data: data, position: position, version: version)
                }
                return try parseHexString(data: data, position: position)
            case 43, 45, 46, 48...57: return try parseReference(data: data, position: position) ?? parseNumber(data: data, position: position)
            default: break
            }
        }
        throw ParserError.unknownToken(position)
    }
    fileprivate static func parseBool(data: Data, position: Int) throws -> (Int, PDFDocument.Value) {
        
        if data.suffix(from: position).starts(with: [116, 114, 117, 101]) {
            return (position + 4, true)
        }
        if data.suffix(from: position).starts(with: [102, 97, 108, 115, 101]) {
            return (position + 5, false)
        }
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseName(data: Data, position: Int, version: (Int, Int)) throws -> (Int, PDFDocument.Value) {
        
        var name = [UInt8]()
        var flag = 0
        var t: UInt8 = 0
        
        for (pos, d) in data.indexed().suffix(from: position).dropFirst() {
            switch d {
            case 1...8, 11, 14...31, 33, 34, 36, 38, 39, 42...46, 48...59, 61, 63...90, 92, 94...122, 124, 126...255:
                if flag == 0 {
                    name.append(d)
                } else {
                    switch d {
                    case 48...57:
                        if flag == 2 {
                            t = d - 48
                        } else {
                            name.append(t * 0x10 + (d - 48))
                        }
                    case 65...70:
                        if flag == 2 {
                            t = d - 65 + 0xA
                        } else {
                            name.append(t * 0x10 + (d - 65 + 0xA))
                        }
                    case 97...102:
                        if flag == 2 {
                            t = d - 97 + 0xA
                        } else {
                            name.append(t * 0x10 + (d - 97 + 0xA))
                        }
                    default: throw ParserError.invalidFormat("invalid name format.")
                    }
                    flag -= 1
                }
            case 35:
                if version < (1, 2) {
                    name.append(d)
                } else {
                    flag = 2
                }
            default:
                if flag == 0 {
                    return (pos, .name(PDFDocument.Name(PDFDocDecodeString(Data(name)))))
                }
                throw ParserError.invalidFormat("invalid name format.")
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseReference(data: Data, position: Int) throws -> (Int, PDFDocument.Value)? {
        
        var flag = 0
        var identifier = 0
        var generation = 0
        
        for (pos, d) in data.indexed().suffix(from: position) {
            switch d {
            case 48...57:
                switch flag {
                case 0: identifier = identifier * 10 + Int(d - 48)
                case 1: generation = generation * 10 + Int(d - 48)
                default: return nil
                }
            case 32: flag += 1
            case 82:
                if flag == 2 {
                    return (pos + 1, .indirect(PDFDocument.ObjectIdentifier(identifier: identifier, generation: generation)))
                }
            default: return nil
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseLiteralString(data: Data, position: Int) throws -> (Int, PDFDocument.Value) {
        
        var position = position + 1
        
        var literal = Data()
        var balance = 0
        var flag = 0
        var t: UInt16 = 0
        
        while position < data.count {
            if position == data.count {
                throw ParserError.unexpectedEOF
            }
            let d = data[position]
            switch d {
            case 92:
                switch flag {
                case 0: flag += 1
                case 1:
                    literal.append(92)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    flag = 1
                }
            case 10, 13:
                switch flag {
                case 0:
                    literal.append(10)
                    if position + 1 == data.count {
                        throw ParserError.unexpectedEOF
                    }
                    switch (d, data[position + 1]) {
                    case (10, 13), (13, 10): position += 1
                    default: break
                    }
                case 1:
                    if position + 1 == data.count {
                        throw ParserError.unexpectedEOF
                    }
                    switch (d, data[position + 1]) {
                    case (10, 13), (13, 10): position += 1
                    default: break
                    }
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(10)
                    if position + 1 == data.count {
                        throw ParserError.unexpectedEOF
                    }
                    switch (d, data[position + 1]) {
                    case (10, 13), (13, 10): position += 1
                    default: break
                    }
                    flag = 0
                }
            case 110:
                switch flag {
                case 0: literal.append(110)
                case 1:
                    literal.append(10)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(110)
                    flag = 0
                }
            case 114:
                switch flag {
                case 0: literal.append(114)
                case 1:
                    literal.append(13)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(114)
                    flag = 0
                }
            case 116:
                switch flag {
                case 0: literal.append(116)
                case 1:
                    literal.append(9)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(116)
                    flag = 0
                }
            case 98:
                switch flag {
                case 0: literal.append(98)
                case 1:
                    literal.append(8)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(98)
                    flag = 0
                }
            case 102:
                switch flag {
                case 0: literal.append(102)
                case 1:
                    literal.append(12)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(102)
                    flag = 0
                }
            case 40:
                switch flag {
                case 0:
                    literal.append(40)
                    balance += 1
                case 1:
                    literal.append(40)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(40)
                    flag = 0
                }
            case 41:
                switch flag {
                case 0:
                    if balance == 0 {
                        if t > 1 {
                            literal.append(UInt8(min(255, t)))
                        }
                        return (position + 1, .string(PDFDecodeString(literal)))
                    }
                    balance -= 1
                    literal.append(41)
                case 1:
                    literal.append(41)
                    flag = 0
                default:
                    literal.append(UInt8(min(255, t)))
                    literal.append(41)
                    flag = 0
                }
            case 48...57:
                switch flag {
                case 0: literal.append(d)
                case 1:
                    t = UInt16(d) - 48
                    flag += 1
                case 2:
                    t = t << 3 + (UInt16(d) - 48)
                    flag += 1
                case 3:
                    literal.append(UInt8(min(255, t << 3 + (UInt16(d) - 48))))
                    flag = 0
                default: fatalError()
                }
            default:
                literal.append(d)
                flag = 0
            }
            position += 1
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseHexString(data: Data, position: Int) throws -> (Int, PDFDocument.Value) {
        
        var hex = Data()
        var flag = 0
        var t: UInt8 = 0
        
        for (pos, d) in data.indexed().suffix(from: position).dropFirst() {
            switch d {
            case 0, 9, 10, 12, 13, 32: break
            case 48...57:
                if flag & 1 == 0 {
                    t = d - 48
                } else {
                    hex.append(t * 0x10 + (d - 48))
                }
                flag += 1
            case 65...70:
                if flag & 1 == 0 {
                    t = d - 65 + 0xA
                } else {
                    hex.append(t * 0x10 + (d - 65 + 0xA))
                }
                flag += 1
            case 97...102:
                if flag & 1 == 0 {
                    t = d - 97 + 0xA
                } else {
                    hex.append(t * 0x10 + (d - 97 + 0xA))
                }
                flag += 1
            case 62:
                if flag & 1 == 1 {
                    hex.append(t * 0x10)
                }
                return (pos + 1, .string(PDFDecodeString(hex)))
            default: throw ParserError.invalidFormat("invalid string format.")
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseNumber(data: Data, position: Int) throws -> (Int, PDFDocument.Value) {
        
        var sign: Bool?
        var int: Int64 = 0
        var float = 0.0
        var fflag = false
        
        for (pos, d) in data.indexed().suffix(from: position) {
            switch d {
            case 43:
                if sign != nil {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = false
            case 45:
                if sign != nil {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = true
            case 46:
                if fflag {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = sign ?? false
                fflag = true
            case 48...57:
                sign = sign ?? false
                if fflag {
                    float = (float + Double(d - 48)) / 10
                } else {
                    int = int * 10 + Int64(d - 48)
                }
            default:
                if fflag {
                    let num = Double(int) + float
                    return (pos, PDFDocument.Value(sign == true ? -num : num))
                }
                return (pos, PDFDocument.Value(sign == true ? -int : int))
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseArray(data: Data, position: Int, version: (Int, Int)) throws -> (Int, PDFDocument.Value) {
        
        var array: [PDFDocument.Value] = []
        var position = position
        
        position += 1
        
        if position == data.count {
            throw ParserError.unexpectedEOF
        }
        
        while position < data.count {
            let d = data[position]
            switch d {
            case 0, 9, 10, 12, 13, 32: position += 1
            case 93: return (position + 1, .array(array))
            default:
                let (pos, value) = try parseValue(data: data, position: position, version: version)
                array.append(value)
                position = pos
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    fileprivate static func parseDictionary(data: Data, position: Int, version: (Int, Int)) throws -> (Int, PDFDocument.Value) {
        
        var dictionary: PDFDocument.Dictionary = [:]
        var position = position
        
        position += 2
        
        if position >= data.count {
            throw ParserError.unexpectedEOF
        }
        
        while position < data.count {
            let d = data[position]
            switch d {
            case 0, 9, 10, 12, 13, 32: position += 1
            case 62:
                if position + 1 != data.count && data[position + 1] == 62 {
                    return (position + 2, .dictionary(dictionary))
                }
                throw ParserError.invalidFormat("invalid dictionary format.")
            default:
                let (pos, _key) = try parseValue(data: data, position: position, version: version)
                
                let key: PDFDocument.Name
                if case let .name(name) = _key {
                    key = name
                } else {
                    throw ParserError.invalidFormat("invalid dictionary format.")
                }
                
                position = pos
                
                loop: while true {
                    switch data[position] {
                    case 0, 9, 10, 12, 13, 32: position += 1
                    default: break loop
                    }
                }
                
                let (pos2, value) = try parseValue(data: data, position: position, version: version)
                
                dictionary[key] = value
                position = pos2
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    
    fileprivate static func version(data: Data) throws -> (Int, Int) {
        
        var major = 0
        var minor = 0
        var flag = true
        
        for d in data.dropFirst(5) {
            if 48...57 ~= d {
                if flag {
                    major = major * 10 + Int(d - 48)
                } else {
                    minor = minor * 10 + Int(d - 48)
                }
            } else if flag && d == 46 {
                flag = false
            } else if flag {
                throw ParserError.invalidFormat("invalid version number.")
            } else if d == 10 || d == 13 {
                break
            } else {
                throw ParserError.invalidFormat("invalid version number.")
            }
        }
        
        return (major, minor)
    }
    
    fileprivate static func lineStartPosition(data: Data, position: Int) -> Int {
        if position == 0 {
            return 0
        }
        let _1 = data[position - 1]
        let _2 = data[position]
        
        var index = position
        switch (_1, _2) {
        case (10, 13), (13, 10): index -= 2
        case (_, 10), (_, 13): index -= 1
        default: break
        }
        
        while index != 0 {
            switch data[index] {
            case 10, 13: return index + 1
            default: index -= 1
            }
        }
        return index
    }
    fileprivate static func lineEndPosition(data: Data, position: Int) -> Int {
        if position == 0 {
            return 0
        }
        let _1 = data[position - 1]
        let _2 = data[position]
        
        switch (_1, _2) {
        case (10, 13), (13, 10): return position - 1
        case (_, 10), (_, 13): return position
        default: break
        }
        
        var index = position
        while index != data.count {
            switch data[index] {
            case 10, 13: return index
            default: index += 1
            }
        }
        return index
    }
    fileprivate static func nextLineStartPosition(data: Data, position: Int) -> Int {
        
        if position == data.count {
            return position
        }
        if position + 1 == data.count {
            return position
        }
        
        let _1 = data[position]
        let _2 = data[position + 1]
        
        switch (_1, _2) {
        case (10, 13), (13, 10): return position + 2
        default: return position + 1
        }
    }
    
    fileprivate static func eofPosition(data: Data) throws -> Int {
        let _lineEndPosition = lineEndPosition(data: data, position: data.count - 1)
        if data.prefix(upTo: _lineEndPosition).suffix(5).elementsEqual([37, 37, 69, 79, 70]) {
            return _lineEndPosition - 5
        }
        throw ParserError.invalidFormat("'%%EOF' not find.")
    }
    
    fileprivate static func xrefPosition(data: Data) throws -> Int {
        
        let _eofPosition = try eofPosition(data: data)
        
        let _xrefEndPosition = lineEndPosition(data: data, position: _eofPosition - 1)
        let _xrefStartPosition = lineStartPosition(data: data, position: _xrefEndPosition - 1)
        
        if _xrefStartPosition >= _xrefEndPosition {
            throw ParserError.invalidFormat("invalid file format.")
        }
        
        let _startxref_flag_end = lineEndPosition(data: data, position: _xrefStartPosition - 1)
        if !data.prefix(upTo: _startxref_flag_end).suffix(9).elementsEqual([115, 116, 97, 114, 116, 120, 114, 101, 102]) {
            throw ParserError.invalidFormat("'startxref' not find.")
        }
        
        var offset = 0
        for d in data[_xrefStartPosition..<_xrefEndPosition] {
            switch d {
            case 48...57: offset = offset * 10 + Int(d - 48)
            default: throw ParserError.invalidFormat("invalid xref position.")
            }
        }
        return offset
    }
    
    fileprivate static func xrefTable(data: Data, version: (Int, Int)) throws -> (PDFDocument.Dictionary, [PDFDocument.ObjectIdentifier: Int]) {
        
        var _xrefPosition = try xrefPosition(data: data)
        
        var trailer: PDFDocument.Dictionary?
        var xref: [PDFDocument.ObjectIdentifier: Int] = [:]
        
        while true {
            
            var _lineStart = lineStartPosition(data: data, position: _xrefPosition)
            var _lineEnd = lineEndPosition(data: data, position: _xrefPosition)
            
            if _lineStart >= _lineEnd {
                throw ParserError.invalidFormat("invalid file format.")
            }
            
            if !data[_lineStart..<_lineEnd].elementsEqual([120, 114, 101, 102]) {
                throw ParserError.invalidFormat("'xref' not find.")
            }
            
            _lineStart = nextLineStartPosition(data: data, position: _lineEnd)
            _lineEnd = lineEndPosition(data: data, position: _lineStart)
            
            if _lineStart >= _lineEnd {
                throw ParserError.invalidFormat("invalid file format.")
            }
            
            while true {
                
                var id = 0
                var count = 0
                var flag = false
                
                do {
                    let line = data[_lineStart..<_lineEnd]
                    
                    for d in line {
                        switch d {
                        case 48...57:
                            if flag {
                                count = count * 10 + Int(d - 48)
                            } else {
                                id = id * 10 + Int(d - 48)
                            }
                        case 32:
                            if flag {
                                throw ParserError.invalidFormat("invalid xref format.")
                            }
                            flag = true
                        default: throw ParserError.invalidFormat("invalid xref format.")
                        }
                    }
                }
                
                _lineStart = nextLineStartPosition(data: data, position: _lineEnd)
                
                for i in 0..<count {
                    
                    _lineEnd = _lineStart + 18
                    
                    if _lineStart >= data.count || _lineEnd >= data.count {
                        throw ParserError.unexpectedEOF
                    }
                    
                    if data[_lineStart + 17] == 102 {
                        _lineStart = _lineEnd + 2
                        _lineEnd = _lineStart + 18
                        continue
                    }
                    if data[_lineStart + 10] != 32 || data[_lineStart + 16] != 32 || data[_lineStart + 17] != 110 {
                        throw ParserError.invalidFormat("invalid xref format.")
                    }
                    
                    let line = data[_lineStart..<_lineEnd]
                    
                    var d1 = 0
                    var d2 = 0
                    
                    for d in line.prefix(10) {
                        switch d {
                        case 48...57: d1 = d1 * 10 + Int(d - 48)
                        default: throw ParserError.invalidFormat("invalid xref format.")
                        }
                    }
                    let s1 = line.dropFirst(11)
                    for d in s1.prefix(5) {
                        switch d {
                        case 48...57: d2 = d2 * 10 + Int(d - 48)
                        default: throw ParserError.invalidFormat("invalid xref format.")
                        }
                    }
                    
                    let identifier = PDFDocument.ObjectIdentifier(identifier: id + i, generation: d2)
                    if xref[identifier] == nil {
                        xref[identifier] = d1
                    }
                    
                    _lineStart = _lineEnd + 2
                }
                
                do {
                    _lineEnd = lineEndPosition(data: data, position: _lineStart)
                    
                    if _lineStart >= _lineEnd {
                        throw ParserError.invalidFormat("invalid file format.")
                    }
                    let line = data[_lineStart..<_lineEnd]
                    
                    if line.elementsEqual([116, 114, 97, 105, 108, 101, 114]) {
                        break
                    }
                }
            }
            
            let _trailerStart = nextLineStartPosition(data: data, position: _lineEnd)
            
            if case let .dictionary(dictionary) = try parseValue(data: data, position: _trailerStart, version: version).1 {
                trailer = trailer ?? dictionary
                if case let .some(.number(number)) = dictionary["Prev"] {
                    _xrefPosition = number.intValue
                } else {
                    return (trailer ?? [:], xref)
                }
            } else {
                throw ParserError.invalidFormat("invalid trailer format.")
            }
        }
    }
    
    fileprivate static func trailer(data: Data, position: Int, version: (Int, Int)) throws -> PDFDocument.Dictionary {
        
        switch try parseValue(data: data, position: position, version: version) {
        case let (_, .dictionary(dictionary)): return dictionary
        default: throw ParserError.invalidFormat("invalid trailer format.")
        }
    }
}
