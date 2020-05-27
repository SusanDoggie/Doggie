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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension Data {
    
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
    
    public init(data: Data) throws {
        
        self.init()
        
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
        
        var _xref = data.popFirst(xref_offset)
        swap(&data, &_xref)
        
        self.trailer = try PDFDocument.decode_trailer(data, _xref)
    }
    
    static func dereference_all(_ object: PDFObject) -> PDFObject {
        
        switch object.base {
            
        case let .array(array): return PDFObject(array.map { dereference_all($0._apply_xref(object.xref)) })
        case let .dictionary(dictionary): return PDFObject(dictionary.mapValues { dereference_all($0._apply_xref(object.xref)) })
        case let .stream(stream): return PDFObject(stream.dictionary.mapValues { dereference_all($0._apply_xref(object.xref)) }, stream.data)
            
        case let .xref(xref):
            
            guard var target = object.xref[xref] else { return object }
            
            var xref_table = object.xref
            xref_table[xref] = nil
            target.xref = xref_table
            
            return dereference_all(target)
            
        default: return object
        }
    }
    
    private static func decode_trailer(_ data: Data, _ xref_data: Data) throws -> PDFObject {
        
        let (trailer, _xref_table) = try _decode_trailer(data, xref_data)
        
        var xref_table = try Dictionary(uniqueKeysWithValues: _xref_table.map { ($0, try decode_indirect_object($0, $1, _xref_table)) })
        xref_table = xref_table.mapValues { dereference_all($0._apply_xref(xref_table)) }
        
        return dereference_all(trailer._apply_xref(xref_table))
    }
    
    private static func _decode_trailer(_ data: Data, _ xref_data: Data) throws -> (PDFObject, [PDFXref: Data]) {
        
        var xref_data = xref_data
        
        guard xref_data.popFirst(4).elementsEqual("xref".utf8) else { throw Error.invalidFormat(#line) }
        
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
        
        xref_data.pdf_remove_whitespaces()
        
        guard let trailer = PDFObject(&xref_data, [:]), trailer.isObject else { throw Error.invalidFormat(#line) }
        
        var xref_table: [PDFXref: Data] = [:]
        
        if let prev = trailer["Prev"].intValue {
            var data = data
            var _xref = data.popFirst(prev)
            swap(&data, &_xref)
            xref_table = try _decode_trailer(data, _xref).1
        }
        
        xref_offsets.sort { $0.1 < $1.1 }
        
        for (xref, offset, flag) in xref_offsets where flag {
            xref_table[xref] = data.dropFirst(offset)
        }
        
        return (trailer, xref_table)
    }
    
    private static func decode_indirect_object(_ xref: PDFXref, _ data: Data, _ xref_table: [PDFXref: Data]) throws -> PDFObject {
        
        var data = data
        data.pdf_remove_whitespaces()
        
        guard let object = data.pdf_decode_digits(), xref.object == object else { throw Error.invalidFormat(#line) }
        guard data.popFirst() == 0x20 else { throw Error.invalidFormat(#line) }
        guard let generation = data.pdf_decode_digits(), xref.generation == generation else { throw Error.invalidFormat(#line) }
        guard data.popFirst() == 0x20 else { throw Error.invalidFormat(#line) }
        
        guard data.popFirst(3).elementsEqual("obj".utf8) else { throw Error.invalidFormat(#line) }
        
        guard let obj = PDFObject(&data, xref_table) else { throw Error.invalidFormat(#line) }
        
        data.pdf_remove_whitespaces()
        
        guard data.popFirst(6).elementsEqual("endobj".utf8) else { throw Error.invalidFormat(#line) }
        
        return obj
    }
    
}

extension PDFObject {
    
    init?(_ data: inout Data, _ xref_table: [PDFXref: Data] = [:]) {
        
        data.pdf_remove_whitespaces()
        
        while data.first == 0x25 {
            
            while data.first != 0x0A && data.first != 0x0D {
                data = data.dropFirst()
            }
            
            data.pdf_remove_whitespaces()
        }
        
        switch data.first ?? 0 {
            
        case 0x3C:
            
            if data.dropFirst().first == 0x3C {
                
                guard let obj = PDFObject.decode_dictionary_or_stream(&data, xref_table) else { return nil }
                self = obj
                
            } else {
                
                guard let string = PDFString(&data) else { return nil }
                self.init(string)
            }
            
        case 0x2F:
            
            guard let name = PDFName(&data) else { return nil }
            self.init(name)
            
        case 0x5B:
            
            guard let array = PDFObject.decode_array(&data, xref_table) else { return nil }
            self = array
            
        case 0x28:
            
            guard let string = PDFString(&data) else { return nil }
            self.init(string)
            
        case 0x2B, 0x2D, 0x2E:
            
            guard let number = PDFNumber(&data) else { return nil }
            self.init(number)
            
        case 0x30...0x39:
            
            if let xref = PDFXref(&data) {
                
                self.init(xref)
                
            } else if let number = PDFNumber(&data) {
                
                self.init(number)
                
            } else {
                
                return nil
            }
            
        case 0x74:
            
            guard data.popFirst(4).elementsEqual("true".utf8) else { return nil }
            self = true
            
        case 0x66:
            
            guard data.popFirst(5).elementsEqual("false".utf8) else { return nil }
            self = false
            
        case 0x6E:
            
            guard data.popFirst(4).elementsEqual("null".utf8) else { return nil }
            self = nil
            
        default: return nil
        }
    }
    
    private static func decode_array(_ data: inout Data, _ xref_table: [PDFXref: Data]) -> PDFObject? {
        
        var copy = data
        
        guard copy.popFirst() == 0x5B else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        var array: [PDFObject] = []
        
        while copy.first != 0x5D, let obj = PDFObject(&copy, xref_table) {
            
            array.append(obj)
            copy.pdf_remove_whitespaces()
        }
        
        guard copy.popFirst() == 0x5D else { return nil }
        
        data = copy
        return PDFObject(array)
    }
    
    private static func decode_dictionary_or_stream(_ data: inout Data, _ xref_table: [PDFXref: Data]) -> PDFObject? {
        
        var copy = data
        
        guard copy.popFirst() == 0x3C else { return nil }
        guard copy.popFirst() == 0x3C else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        var dictionary: [PDFName: PDFObject] = [:]
        
        while copy.first != 0x3E, let name = PDFName(&copy) {
            
            guard let value = PDFObject(&copy, xref_table) else { return nil }
            dictionary[name] = value
            
            copy.pdf_remove_whitespaces()
        }
        
        guard copy.popFirst() == 0x3E else { return nil }
        guard copy.popFirst() == 0x3E else { return nil }
        
        copy.pdf_remove_whitespaces()
        
        if copy.prefix(6).elementsEqual("stream".utf8) {
            
            if let _length = dictionary["Length"] {
                
                var xref_table = xref_table
                
                while case let .xref(xref) = _length.base {
                    
                    guard var length_data = xref_table[xref] else { return nil }
                    xref_table[xref] = nil
                    
                    guard let length = PDFObject(&length_data, xref_table) else { return nil }
                    dictionary["Length"] = length
                }
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
        
        copy.pdf_remove_whitespaces()
        
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
