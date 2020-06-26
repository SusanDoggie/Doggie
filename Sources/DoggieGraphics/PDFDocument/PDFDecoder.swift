//
//  PDFDecoder.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Data {
    
    mutating func pdf_remove_whitespaces_and_comment() {
        
        self.pdf_remove_whitespaces()
        
        while self.first == 0x25 {
            
            while self.first != 0x0A && self.first != 0x0D {
                self = self.dropFirst()
            }
            
            self.pdf_remove_whitespaces()
        }
    }
    
    mutating func pdf_remove_whitespaces() {
        while self.first == 0x00 || self.first == 0x09 || self.first == 0x0A || self.first == 0x0C || self.first == 0x0D || self.first == 0x20 {
            self = self.dropFirst()
        }
    }
    
    fileprivate mutating func pdf_remove_last_whitespaces() {
        while self.last == 0x00 || self.last == 0x09 || self.last == 0x0A || self.last == 0x0C || self.last == 0x0D || self.last == 0x20 {
            self = self.dropLast()
        }
    }
    
    mutating func pdf_decode_digits() -> Int? {
        
        var number = 0
        var flag = false
        var copy = self
        
        let number_max = Int.max >> 1
        
        while let char = copy.first {
            guard number < number_max, 0x30...0x39 ~= char else { break }
            number *= 10
            number += Int(char - 0x30)
            copy = copy.dropFirst()
            flag = true
        }
        
        guard flag else { return nil }
        self = copy
        
        return number
    }
}

extension PDFDocument {
    
    public enum Error: Swift.Error {
        
        case invalidFormat(Int)
    }
    
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: url, options: options))
    }
    
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(data: Data(contentsOf: URL(fileURLWithPath: path), options: options))
    }
    
    public init(data: Data) throws {
        
        var data = data
        
        data.pdf_remove_last_whitespaces()
        
        guard data.popLast(5).elementsEqual("%%EOF".utf8) else { throw Error.invalidFormat(#line) }
        
        data.pdf_remove_last_whitespaces()
        
        var xref_offset = 0
        var xref_offset_mul = 1
        
        while let char = data.popLast() {
            
            if 0x30...0x39 ~= char {
                
                xref_offset += Int(char - 0x30) * xref_offset_mul
                xref_offset_mul *= 10
                
            } else if char == 0x0A || char == 0x0D || data.last == 0x20 {
                
                break
            }
        }
        
        data.pdf_remove_last_whitespaces()
        
        guard data.popLast(9).elementsEqual("startxref".utf8) else { throw Error.invalidFormat(#line) }
        
        try self.init(PDFDocument.decode_trailer(data, data.dropFirst(xref_offset), [xref_offset]))
    }
    
    static func dereference_all(_ object: PDFObject, _ xref_table: [PDFXref: PDFObject], _ stack: Set<PDFXref> = []) -> PDFObject {
        
        switch object.base {
            
        case let .array(array): return PDFObject(array.map { dereference_all($0, xref_table, stack)._apply_xref(xref_table) })
        case let .dictionary(dictionary): return PDFObject(dictionary.mapValues { dereference_all($0, xref_table, stack)._apply_xref(xref_table) })
        case let .stream(stream): return PDFObject(stream.dictionary.mapValues { dereference_all($0, xref_table, stack)._apply_xref(xref_table) }, stream.data)
            
        case let .xref(xref):
            
            guard !stack.contains(xref), let target = xref_table[xref] else { return object }
            
            var stack = stack
            stack.insert(xref)
            
            return dereference_all(target, xref_table, stack)
            
        default: return object
        }
    }
    
    private static func decode_trailer(_ data: Data, _ xref_data: Data, _ stack: Set<Int>) throws -> PDFObject {
        
        let (trailer, _xref_table) = try _decode_trailer(data, xref_data, stack)
        
        let xref_table = Dictionary(uniqueKeysWithValues: _xref_table.compactMap { key, data in PDFObject.decode_indirect_object(key, data, _xref_table, []).map { (key, $0.1) } })
        
        return dereference_all(trailer, xref_table)._apply_xref(xref_table)
    }
    
    private static func _decode_object_stream(_ object: PDFObject, _ xref_table: [PDFXref: Data]) throws -> [PDFXref: Data] {
        
        guard object.isStream else { throw Error.invalidFormat(#line) }
        
        var xref_table = xref_table
        
        guard object["Type"].name == "ObjStm" else { throw Error.invalidFormat(#line) }
        
        guard let count = object["N"].intValue else { throw Error.invalidFormat(#line) }
        guard let first = object["First"].intValue else { throw Error.invalidFormat(#line) }
        
        guard var stream = object.stream?.decode() else { throw Error.invalidFormat(#line) }
        let stream_start = stream.dropFirst(first)
        
        var xref_offsets: [(PDFXref, Int)] = []
        
        for _ in 0..<count {
            stream.pdf_remove_whitespaces()
            guard let object = stream.pdf_decode_digits() else { throw Error.invalidFormat(#line) }
            stream.pdf_remove_whitespaces()
            guard let offset = stream.pdf_decode_digits() else { throw Error.invalidFormat(#line) }
            xref_offsets.append((PDFXref(object: object, generation: 0), offset))
        }
        
        var result: [PDFXref: Data] = [:]
        
        var extends = object["Extends"]
        
        while case let .xref(xref) = extends.base {
            
            guard let extends_data = xref_table[xref] else { break }
            xref_table[xref] = nil
            
            guard let _extends = PDFObject.decode_indirect_object(nil, extends_data, xref_table, [])?.1 else { break }
            extends = _extends
        }
        
        if let table = try? _decode_object_stream(extends, xref_table) {
            result = table
        }
        
        for (xref, offset) in xref_offsets {
            result[xref] = stream_start.dropFirst(offset)
        }
        
        return result
    }
    
    private static func _decode_object_stream(_ data: Data, _ xref_table: [PDFXref: Data]) throws -> [PDFXref: Data] {
        
        guard let (_, object_stream) = PDFObject.decode_indirect_object(nil, data, xref_table, []) else { throw Error.invalidFormat(#line) }
        
        return try _decode_object_stream(object_stream, xref_table)
    }
    
    private static func _decode_xref_stream(_ data: Data, _ xref_data: Data, _ stack: Set<Int>) throws -> (PDFObject, [PDFXref: Data]) {
        
        guard let (trailer_xref, trailer) = PDFObject.decode_indirect_object(nil, xref_data, [:], []) else { throw Error.invalidFormat(#line) }
        guard trailer.isStream else { throw Error.invalidFormat(#line) }
        
        guard trailer["Type"].name == "XRef" else { throw Error.invalidFormat(#line) }
        
        guard let field_size = trailer["W"].array?.compactMap({ $0.intValue }), field_size.count == 3 else { throw Error.invalidFormat(#line) }
        guard let size = trailer["Size"].intValue else { throw Error.invalidFormat(#line) }
        
        let index = trailer["Index"].array?.compactMap({ $0.intValue }) ?? [0, size]
        guard index.count == 2 else { throw Error.invalidFormat(#line) }
        
        guard var stream = trailer.stream?.decode() else { throw Error.invalidFormat(#line) }
        
        func read_bytes(_ size: Int) -> Int? {
            var bytes = 0
            for _ in 0..<size {
                guard let byte = stream.popFirst() else { return nil }
                bytes = (bytes << 8) | Int(byte)
            }
            return bytes
        }
        
        var xref_offsets: [(PDFXref, Int)] = []
        var object_stream: Set<PDFXref> = []
        
        for object in index[0]..<index[0] + index[1] {
            
            guard let type = read_bytes(field_size[0]) else { throw Error.invalidFormat(#line) }
            guard let field2 = read_bytes(field_size[1]) else { throw Error.invalidFormat(#line) }
            guard let field3 = read_bytes(field_size[2]) else { throw Error.invalidFormat(#line) }
            
            switch type {
            case 0: break
            case 1: xref_offsets.append((PDFXref(object: object, generation: UInt16(field3)), field2))
            case 2: object_stream.insert(PDFXref(object: field2, generation: 0))
            default: break
            }
        }
        
        var xref_table: [PDFXref: Data] = [:]
        
        if let prev = trailer["Prev"].intValue, !stack.contains(prev) {
            var stack = stack
            stack.insert(prev)
            xref_table = try _decode_xref_stream(data, data.dropFirst(prev), stack).1
        }
        
        for (xref, offset) in xref_offsets where xref != trailer_xref {
            xref_table[xref] = data.dropFirst(offset)
        }
        
        for object_xref in object_stream where object_xref != trailer_xref {
            guard let object_stream = xref_table[object_xref] else { continue }
            var xref_table = xref_table
            xref_table[object_xref] = nil
            xref_table[trailer_xref] = nil
            guard let table = try? _decode_object_stream(object_stream, xref_table) else { continue }
            xref_table.merge(table) { _, rhs in rhs }
        }
        
        return (PDFObject(trailer.dictionary ?? [:]), xref_table)
    }
    
    private static func _decode_trailer(_ data: Data, _ xref_data: Data, _ stack: Set<Int>) throws -> (PDFObject, [PDFXref: Data]) {
        
        if !xref_data.prefix(4).elementsEqual("xref".utf8) {
            return try _decode_xref_stream(data, xref_data, stack)
        }
        
        var xref_data = xref_data.dropFirst(4)
        xref_data.pdf_remove_whitespaces()
        
        var xref_offsets: [(PDFXref, Int, Bool)] = []
        
        while let xref_start = xref_data.pdf_decode_digits() {
            
            guard xref_data.popFirst() == 0x20 else { throw Error.invalidFormat(#line) }
            guard let xref_count = xref_data.pdf_decode_digits() else { throw Error.invalidFormat(#line) }
            
            for object in xref_start..<xref_start + xref_count {
                
                xref_data.pdf_remove_whitespaces()
                
                guard let offset = xref_data.pdf_decode_digits() else { throw Error.invalidFormat(#line) }
                guard xref_data.popFirst() == 0x20 else { throw Error.invalidFormat(#line) }
                guard let _generation = xref_data.pdf_decode_digits(), let generation = UInt16(exactly: _generation) else { throw Error.invalidFormat(#line) }
                guard xref_data.popFirst() == 0x20 else { throw Error.invalidFormat(#line) }
                
                switch xref_data.popFirst() {
                case 0x66: xref_offsets.append((PDFXref(object: object, generation: generation), offset, false))
                case 0x6E: xref_offsets.append((PDFXref(object: object, generation: generation), offset, true))
                default: throw Error.invalidFormat(#line)
                }
            }
            
            xref_data.pdf_remove_whitespaces()
        }
        
        guard !xref_offsets.isEmpty else { throw Error.invalidFormat(#line) }
        guard xref_data.popFirst(7).elementsEqual("trailer".utf8) else { throw Error.invalidFormat(#line) }
        
        guard let trailer = PDFObject(&xref_data), trailer.isDictionary else { throw Error.invalidFormat(#line) }
        
        var xref_table: [PDFXref: Data] = [:]
        
        if let prev = trailer["Prev"].intValue, !stack.contains(prev) {
            var stack = stack
            stack.insert(prev)
            xref_table = try _decode_trailer(data, data.dropFirst(prev), stack).1
        }
        
        for (xref, offset, flag) in xref_offsets where flag {
            xref_table[xref] = data.dropFirst(offset)
        }
        
        return (trailer, xref_table)
    }
    
}

extension PDFObject {
    
    init?(_ data: inout Data, _ xref_table: [PDFXref: Data] = [:]) {
        guard let object = PDFObject.decode(&data, xref_table, []) else { return nil }
        self = object
    }
    
    fileprivate static func decode_indirect_object(_ xref: PDFXref?, _ data: Data, _ xref_table: [PDFXref: Data], _ stack: Set<PDFXref>) -> (PDFXref, PDFObject)? {
        
        var data = data
        data.pdf_remove_whitespaces_and_comment()
        
        guard let object = data.pdf_decode_digits() else { return nil }
        guard data.popFirst() == 0x20 else { return nil }
        guard let generation = data.pdf_decode_digits() else { return nil }
        guard data.popFirst() == 0x20 else { return nil }
        
        if let xref = xref {
            guard xref.object == object && xref.generation == generation else { return nil }
        }
        
        guard data.popFirst(3).elementsEqual("obj".utf8) else { return nil }
        
        guard let obj = decode(&data, xref_table, stack) else { return nil }
        
        data.pdf_remove_whitespaces_and_comment()
        
        guard data.popFirst(6).elementsEqual("endobj".utf8) else { return nil }
        
        return (PDFXref(object: object, generation: UInt16(generation)), obj)
    }
    
    private static func decode(_ data: inout Data, _ xref_table: [PDFXref: Data], _ stack: Set<PDFXref>) -> PDFObject? {
        
        data.pdf_remove_whitespaces_and_comment()
        
        switch data.first ?? 0 {
            
        case 0x2F:
            
            guard let name = PDFName(&data) else { return nil }
            return PDFObject(name)
            
        case 0x5B:
            
            guard let array = decode_array(&data, xref_table, stack) else { return nil }
            return array
            
        case 0x3C:
            
            if data.dropFirst().first == 0x3C {
                
                guard let obj = decode_dictionary_or_stream(&data, xref_table, stack) else { return nil }
                return obj
                
            } else {
                
                guard let string = PDFString(&data) else { return nil }
                return PDFObject(string)
            }
            
        case 0x28:
            
            guard let string = PDFString(&data) else { return nil }
            return PDFObject(string)
            
        case 0x2B, 0x2D, 0x2E:
            
            guard let number = PDFNumber(&data) else { return nil }
            return PDFObject(number)
            
        case 0x30...0x39:
            
            if let xref = PDFXref(&data) {
                
                return PDFObject(xref)
                
            } else if let number = PDFNumber(&data) {
                
                return PDFObject(number)
                
            } else {
                
                return nil
            }
            
        case 0x74:
            
            guard data.popFirst(4).elementsEqual("true".utf8) else { return nil }
            return true
            
        case 0x66:
            
            guard data.popFirst(5).elementsEqual("false".utf8) else { return nil }
            return false
            
        case 0x6E:
            
            guard data.popFirst(4).elementsEqual("null".utf8) else { return nil }
            return nil as PDFObject
            
        default: return nil
        }
    }
    
    private static func decode_array(_ data: inout Data, _ xref_table: [PDFXref: Data], _ stack: Set<PDFXref>) -> PDFObject? {
        
        var copy = data
        
        guard copy.popFirst() == 0x5B else { return nil }
        
        copy.pdf_remove_whitespaces_and_comment()
        
        var array: [PDFObject] = []
        
        while copy.first != 0x5D, let obj = decode(&copy, xref_table, stack) {
            
            array.append(obj)
            copy.pdf_remove_whitespaces_and_comment()
        }
        
        guard copy.popFirst() == 0x5D else { return nil }
        
        data = copy
        return PDFObject(array)
    }
    
    private static func decode_dictionary_or_stream(_ data: inout Data, _ xref_table: [PDFXref: Data], _ stack: Set<PDFXref>) -> PDFObject? {
        
        var copy = data
        
        guard copy.popFirst() == 0x3C else { return nil }
        guard copy.popFirst() == 0x3C else { return nil }
        
        copy.pdf_remove_whitespaces_and_comment()
        
        var dictionary: [PDFName: PDFObject] = [:]
        
        while copy.first != 0x3E, let name = PDFName(&copy) {
            
            guard let value = decode(&copy, xref_table, stack) else { return nil }
            dictionary[name] = value
            
            copy.pdf_remove_whitespaces_and_comment()
        }
        
        guard copy.popFirst() == 0x3E else { return nil }
        guard copy.popFirst() == 0x3E else { return nil }
        
        copy.pdf_remove_whitespaces_and_comment()
        
        if copy.prefix(6).elementsEqual("stream".utf8) {
            
            var stack = stack
            
            while case let .xref(xref) = dictionary["Length"]?.base {
                
                guard !stack.contains(xref), let length_data = xref_table[xref] else { return nil }
                
                stack.insert(xref)
                
                guard let length = decode_indirect_object(xref, length_data, xref_table, stack)?.1 else { return nil }
                dictionary["Length"] = length
            }
            
            guard let stream = decode_stream(&copy, dictionary) else { return nil }
            
            data = copy
            return PDFObject(stream)
        }
        
        data = copy
        return PDFObject(dictionary)
    }
    
    private static func decode_stream(_ data: inout Data, _ dictionary: [PDFName: PDFObject]) -> PDFStream? {
        
        var copy = data
        
        guard copy.popFirst(6).elementsEqual("stream".utf8) else { return nil }
        
        if copy.first == 0x0D {
            guard copy.popFirst() == 0x0D else { return nil }
        }
        
        guard copy.popFirst() == 0x0A else { return nil }
        
        guard let length = dictionary["Length"]?.intValue else { return nil }
        
        let stream = copy.popFirst(length)
        
        copy.pdf_remove_whitespaces_and_comment()
        
        guard copy.popFirst(9).elementsEqual("endstream".utf8) else { return nil }
        
        data = copy
        return PDFStream(dictionary: dictionary, data: stream)
    }
}

extension PDFNumber {
    
    private static func is_number(_ char: UInt8) -> Bool {
        return 0x30...0x39 ~= char || char == 0x2B || char == 0x2D || char == 0x2E
    }
    
    init?(_ data: inout Data) {
        
        var copy = data
        
        guard let str = String(data: copy.popFirst(copy.prefix { PDFNumber.is_number($0) }.count), encoding: .ascii) else { return nil }
        guard let value = Decimal(string: str) else { return nil }
        
        data = copy
        self.init(value)
    }
}

extension PDFXref {
    
    init?(_ data: inout Data) {
        
        var copy = data
        
        guard let object = copy.pdf_decode_digits() else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        guard let _generation = copy.pdf_decode_digits(), let generation = UInt16(exactly: _generation) else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        guard copy.popFirst() == 0x52 else { return nil }
        
        data = copy
        self.init(object: object, generation: generation)
    }
}

extension PDFName {
    
    init?(_ data: inout Data) {
        
        var copy = data
        guard copy.popFirst() == 0x2F else { return nil }
        
        var chars = Data()
        
        loop: while let char = copy.first {
            switch char {
            case 0x00, 0x09, 0x0A, 0x0C, 0x0D, 0x20: break loop
            case 0x28, 0x29, 0x3C, 0x3E, 0x5B, 0x5D, 0x7B, 0x7D, 0x2F, 0x25: break loop
            default: chars.append(char)
            }
            copy = copy.dropFirst()
        }
        
        guard !chars.isEmpty else { return nil }
        
        data = copy
        self.init(chars.pdf_string())
    }
}

extension PDFString {
    
    init?(_ data: inout Data) {
        
        var copy = data
        var chars = Data()
        
        switch copy.popFirst() {
            
        case 0x28:
            
            var parentheses = 1
            var escaping = false
            
            var escaping_digits: UInt16 = 0
            var escaping_digits_count = 0
            
            loop: while let char = copy.popFirst() {
                
                if escaping && 0x30...0x37 ~= char {
                    
                    escaping_digits <<= 3
                    escaping_digits |= UInt16(char) - 0x30
                    
                    if escaping_digits_count == 2 {
                        
                        chars.append(UInt8(truncatingIfNeeded: escaping_digits))
                        escaping_digits = 0
                        escaping_digits_count = 0
                        escaping = false
                        
                    } else {
                        
                        escaping_digits_count += 1
                    }
                    
                    continue
                }
                
                if escaping_digits_count != 0 {
                    
                    chars.append(UInt8(truncatingIfNeeded: escaping_digits))
                    escaping_digits = 0
                    escaping_digits_count = 0
                    escaping = false
                }
                
                if escaping {
                    
                    switch char {
                    case 0x5C: chars.append(0x5C)
                    case 0x28: chars.append(0x28)
                    case 0x29: chars.append(0x29)
                    case 0x6E: chars.append(0x0A)
                    case 0x72: chars.append(0x0A)
                    case 0x74: chars.append(0x09)
                    case 0x62: chars.append(0x08)
                    case 0x66: chars.append(0x0C)
                        
                    case 0x0A:
                        
                        if copy.first == 0x0D {
                            copy = copy.dropFirst()
                        }
                        
                    case 0x0D:
                        
                        if copy.first == 0x0A {
                            copy = copy.dropFirst()
                        }
                        
                    default: chars.append(char)
                    }
                    
                    escaping = false
                    
                } else {
                    
                    switch char {
                        
                    case 0x5C:
                        
                        escaping = true
                        
                    case 0x28:
                        
                        parentheses += 1
                        chars.append(0x28)
                        
                    case 0x29:
                        
                        parentheses -= 1
                        guard parentheses > 0 else { break loop }
                        
                        chars.append(0x29)
                        
                    case 0x0A:
                        
                        if copy.first == 0x0D {
                            copy = copy.dropFirst()
                        }
                        
                        chars.append(0x0A)
                        
                    case 0x0D:
                        
                        if copy.first == 0x0A {
                            copy = copy.dropFirst()
                        }
                        
                        chars.append(0x0A)
                        
                    default: chars.append(char)
                    }
                }
                
            }
            
            guard parentheses == 0 else { return nil }
            
        case 0x3C:
            
            guard let _chars = ASCIIHexFilter.decode(&copy) else { return nil }
            chars = _chars
            
            guard copy.popFirst() == 0x3E else { return nil }
            
        default: return nil
        }
        
        data = copy
        self.init(chars)
    }
    
}
