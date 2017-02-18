//
//  DGParser.swift
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

extension DGDocument {
    
    public enum ParserError: Error {
        case invalidFormat(String)
        case unknownToken(Int)
        case unexpectedEOF
    }
    
    public static func Parse(data: Data) throws -> DGDocument {
        
        guard equals(data.prefix(4), [37, 68, 79, 71]) else {
            throw ParserError.invalidFormat("'%DOG' not find.")
        }
        
        let (root, xref) = try xrefTable(data: data)
        var table: [Int: DGDocument.Value] = [:]
        
        for (i, offset) in xref {
            table[i] = try parseValue(data: data, position: offset).1
        }
        
        return DGDocument(root: root, table: table)
    }
    
    private static func parseValue(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        switch data[position] {
        case 110:
            if equals(data.suffix(from: position).prefix(3), [110, 105, 108]) {
                return (position + 3, .nil)
            }
        case 64: return try parseString(data: data, position: position)
        case 37: return try parseStream(data: data, position: position)
        case 38: return try parseReference(data: data, position: position)
        case 91: return try parseArray(data: data, position: position)
        case 123: return try parseDictionary(data: data, position: position)
        case 43, 45, 46, 48...57: return try parseNumber(data: data, position: position)
        default: break
        }
        throw ParserError.unknownToken(position)
    }
    private static func parseString(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var count = 0
        var position = position
        
        loop: for (pos, d) in data.suffix(from: position).dropFirst().indexed() {
            switch d {
            case 48...57: count = count * 10 + Int(d - 48)
            case 32:
                position = pos + 1
                break loop
            default: throw ParserError.unknownToken(pos)
            }
        }
        
        let str = data.suffix(from: position).prefix(count)
        
        if str.count != count {
            throw ParserError.unexpectedEOF
        }
        
        if let string = String(bytes: str, encoding: .utf8) {
            return (position + count, .string(string))
        }
        
        throw ParserError.invalidFormat("invalid string format.")
    }
    private static func parseStream(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var count = 0
        var position = position
        
        loop: for (pos, d) in data.suffix(from: position).dropFirst().indexed() {
            switch d {
            case 48...57: count = count * 10 + Int(d - 48)
            case 32:
                position = pos + 1
                break loop
            default: throw ParserError.unknownToken(pos)
            }
        }
        
        let stream = data.suffix(from: position).prefix(count)
        
        if stream.count != count {
            throw ParserError.unexpectedEOF
        }
        
        return (position + count, .stream(Data(stream)))
    }
    private static func parseReference(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var ref = 0
        
        loop: for (pos, d) in data.suffix(from: position).dropFirst().indexed() {
            switch d {
            case 48...57: ref = ref * 10 + Int(d - 48)
            default: return (pos, .indirect(ref))
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    private static func parseNumber(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var sign: Bool?
        var int: IntMax = 0
        var float = 0.0
        var e: IntMax = 0
        var fflag = false
        var eflag = false
        
        loop: for (pos, d) in data.suffix(from: position).dropFirst().indexed() {
            switch d {
            case 43:
                if sign != nil {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = true
            case 45:
                if sign != nil {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = false
            case 46:
                if fflag || eflag {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = sign ?? false
                fflag = true
            case 69, 101:
                if eflag {
                    throw ParserError.invalidFormat("invalid number format.")
                }
                sign = sign ?? false
                eflag = true
            case 48...57:
                sign = sign ?? false
                if eflag {
                    e = e * 10 + Int(d - 48)
                } else if fflag {
                    float = (float + Double(d - 48)) / 10
                } else {
                    int = int * 10 + Int(d - 48)
                }
            default:
                if fflag || eflag {
                    let num = (Double(int) + float) * pow(10, Double(e))
                    return (pos, DGDocument.Value(sign == true ? -num : num))
                }
                return (pos, DGDocument.Value(sign == true ? -int : int))
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    private static func parseArray(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var array: [DGDocument.Value] = []
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
                let (pos, value) = try parseValue(data: data, position: position)
                array.append(value)
                position = pos
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    private static func parseDictionary(data: Data, position: Int) throws -> (Int, DGDocument.Value) {
        
        var dictionary: [String: DGDocument.Value] = [:]
        var position = position
        
        position += 1
        
        if position == data.count {
            throw ParserError.unexpectedEOF
        }
        
        while position < data.count {
            let d = data[position]
            switch d {
            case 0, 9, 10, 12, 13, 32: position += 1
            case 125: return (position + 1, .dictionary(dictionary))
            default:
                let (pos, _key) = try parseValue(data: data, position: position)
                
                let key: String
                if case let .string(str) = _key {
                    key = str
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
                
                let (pos2, value) = try parseValue(data: data, position: position)
                
                dictionary[key] = value
                position = pos2
            }
        }
        
        throw ParserError.unexpectedEOF
    }
    
    private static func equals<S1 : Sequence, S2 : Sequence>(_ lhs: S1, _ rhs: S2) -> Bool where S1.Iterator.Element : Equatable, S1.Iterator.Element == S2.Iterator.Element {
        var i1 = lhs.makeIterator()
        var i2 = rhs.makeIterator()
        while true {
            let e1 = i1.next()
            let e2 = i2.next()
            if e1 == nil && e2 == nil {
                return true
            } else if e1 != e2 {
                return false
            }
        }
    }
    
    private static func lineStartPosition(data: Data, position: Int) -> Int {
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
    private static func lineEndPosition(data: Data, position: Int) -> Int {
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
    
    private static func xrefTable(data: Data) throws -> (Int, [Int: Int]) {
        
        var root = 0
        var table: [Int: Int] = [:]
        
        let _eofPosition = try eofPosition(data: data)
        
        let _rootIdEndPosition = lineEndPosition(data: data, position: _eofPosition - 1)
        let _rootIdStartPosition = lineStartPosition(data: data, position: _rootIdEndPosition - 1)
        
        if _rootIdStartPosition >= _rootIdEndPosition {
            throw ParserError.invalidFormat("invalid file format.")
        }
        
        loop: for d in data[_rootIdStartPosition..<_rootIdEndPosition] {
            switch d {
            case 48...57: root = root * 10 + Int(d - 48)
            default: throw ParserError.invalidFormat("invalid file format.")
            }
        }
        var offset = _rootIdStartPosition - 1
        while let next = try xrefDecode(data: data, position: offset, table: &table) {
            offset = next - 1
        }
        return (root, table)
    }
    
    private static func xrefDecode(data: Data, position: Int, table: inout [Int: Int]) throws -> Int? {
        
        var _lineStart = lineStartPosition(data: data, position: position)
        var _lineEnd = lineEndPosition(data: data, position: position)
        
        while true {
            
            if _lineStart >= _lineEnd {
                throw ParserError.invalidFormat("invalid file format.")
            }
            let line = data[_lineStart..<_lineEnd]
            
            if line.count > 5 && equals(line.prefix(6), [37, 88, 82, 69, 70, 32]) {
                var offset = 0
                for d in line.dropFirst(6) {
                    switch d {
                    case 48...57: offset = offset * 10 + Int(d - 48)
                    default: throw ParserError.invalidFormat("invalid file format.")
                    }
                }
                return offset
            } else if line.count == 5 && equals(line, [37, 88, 82, 69, 70]) {
                return nil
            } else {
                var numList = [0]
                for d in line {
                    switch d {
                    case 48...57:
                        let _last = numList.endIndex - 1
                        numList[_last] = numList[_last] * 10 + Int(d - 48)
                    case 32: numList.append(0)
                    default: throw ParserError.invalidFormat("invalid file format.")
                    }
                }
                if numList.count > 1 {
                    var counter = numList[0]
                    for d in numList.dropFirst() {
                        if table[counter] == nil {
                            table[counter] = d
                        }
                        counter += 1
                    }
                }
                _lineEnd = lineEndPosition(data: data, position: _lineStart - 1)
                _lineStart = lineStartPosition(data: data, position: _lineStart - 1)
            }
        }
    }
    
    private static func eofPosition(data: Data) throws -> Int {
        let _lineEndPosition = lineEndPosition(data: data, position: data.count - 1)
        if equals(data.prefix(upTo: _lineEndPosition).suffix(5), [37, 37, 69, 79, 70]) {
            return _lineEndPosition - 5
        }
        throw ParserError.invalidFormat("'%%EOF' not find.")
    }
}

extension DGDocument.Value {
    
    fileprivate func write(_ data: inout [UInt8]) {
        
        switch self {
        case .nil:
            data.append(110)
            data.append(105)
            data.append(108)
        case let .indirect(identifier):
            data.append(38)
            data.append(contentsOf: "\(identifier)".utf8)
        case let .number(number):
            data.append(contentsOf: "\(number)".utf8)
        case let .string(string):
            data.append(64)
            data.append(contentsOf: "\(string.utf8.count)".utf8)
            data.append(32)
            data.append(contentsOf: string.utf8)
        case let .array(array):
            data.append(91)
            var first = true
            for item in array {
                if first {
                    first = false
                } else {
                    data.append(32)
                }
                item.write(&data)
            }
            data.append(93)
        case let .dictionary(dictionary):
            data.append(123)
            var first = true
            for (k, v) in dictionary {
                if first {
                    first = false
                } else {
                    data.append(32)
                }
                data.append(64)
                data.append(contentsOf: "\(k.utf8.count)".utf8)
                data.append(32)
                data.append(contentsOf: k.utf8)
                data.append(32)
                v.write(&data)
            }
            data.append(125)
        case let .stream(stream):
            data.append(37)
            data.append(contentsOf: "\(stream.count)".utf8)
            data.append(32)
            data.append(contentsOf: stream)
        }
    }
}

extension DGDocument {
    
    public var data: Data {
        
        var data: [UInt8] = [37, 68, 79, 71, 10]
        var xref: [Int: Int] = [:]
        
        for (i, value) in table {
            xref[i] = data.count
            value.write(&data)
            data.append(10)
        }
        
        data.append(37)
        data.append(88)
        data.append(82)
        data.append(69)
        data.append(70)
        
        var d: Int?
        for (i, offset) in xref.sorted(by: { $0.0 }) {
            if d == nil || i != d! + 1 {
                data.append(10)
                data.append(contentsOf: "\(i)".utf8)
            }
            data.append(32)
            data.append(contentsOf: "\(offset)".utf8)
            d = i
        }
        
        data.append(10)
        data.append(contentsOf: "\(rootId)".utf8)
        data.append(10)
        data.append(37)
        data.append(37)
        data.append(69)
        data.append(79)
        data.append(70)
        
        return Data(data)
    }
}
