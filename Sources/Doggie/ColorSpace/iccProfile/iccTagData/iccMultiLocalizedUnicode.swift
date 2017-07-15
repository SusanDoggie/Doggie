//
//  iccMultiLocalizedUnicode.swift
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

struct iccMultiLocalizedUnicode : RandomAccessCollection, DataCodable {
    
    var messages: [(LanguageCode, CountryCode, String)]
    
    init<S : Sequence>(_ messages: S) where S.Element == (LanguageCode, CountryCode, String) {
        self.messages = Array(messages)
    }
    
    init(from data: inout Data) throws {
        
        let _data = Data(data)
        
        guard data.count > 8 else { throw AnyColorSpace.ParserError.endOfData }
        
        guard try data.decode(iccProfile.TagType.self) == .multiLocalizedUnicode else { throw AnyColorSpace.ParserError.invalidFormat(message: "Invalid multiLocalizedUnicode.") }
        
        data.removeFirst(4)
        
        let header = try data.decode(Header.self)
        
        var entries = [Entry]()
        for _ in 0..<Int(header.count) {
            entries.append(try data.decode(Entry.self))
        }
        
        self.messages = []
        
        for entry in entries {
            
            let offset = Int(entry.offset)
            let length = Int(entry.length)
            
            guard _data.count >= offset + length else { throw AnyColorSpace.ParserError.endOfData }
            
            let strData = _data[offset..<offset + length]
            
            messages.append((entry.language, entry.country, String(bytes: strData, encoding: .utf16BigEndian) ?? ""))
        }
    }
    
    func encode(to data: inout Data) {
        
        data.encode(iccProfile.TagType.multiLocalizedUnicode)
        data.encode(0 as BEUInt32)
        data.encode(Header(count: BEUInt32(messages.count), size: BEUInt32(MemoryLayout<Entry>.stride)))
        
        let entry_size = messages.count * MemoryLayout<Entry>.stride
        var strData = Data()
        
        var offset = data.count + entry_size
        
        for (language, country, string) in messages {
            var str = string.data(using: .utf16BigEndian)!
            strData.append(str)
            data.encode(Entry(language: language, country: country, length: BEUInt32(str.count), offset: BEUInt32(offset)))
            offset += str.count
        }
        
        data.append(strData)
    }
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return messages.count
    }
    
    subscript(position: Int) -> (language: LanguageCode, country: CountryCode, String) {
        return messages[position]
    }

}

extension iccMultiLocalizedUnicode {
    
    struct LanguageCode: SignatureProtocol {
        
        var rawValue: BEUInt16
        
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    struct CountryCode: SignatureProtocol {
        
        var rawValue: BEUInt16
        
        init(rawValue: BEUInt16) {
            self.rawValue = rawValue
        }
    }
    
    struct Header : DataCodable {
        
        var count: BEUInt32
        var size: BEUInt32
        
        init(count: BEUInt32, size: BEUInt32) {
            self.count = count
            self.size = size
        }
        
        init(from data: inout Data) throws {
            self.count = try data.decode(BEUInt32.self)
            self.size = try data.decode(BEUInt32.self)
        }
        
        func encode(to data: inout Data) {
            data.encode(count)
            data.encode(size)
        }
    }
    
    struct Entry : DataCodable {
        
        var language: LanguageCode
        var country: CountryCode
        var length: BEUInt32
        var offset: BEUInt32
        
        init(language: LanguageCode, country: CountryCode, length: BEUInt32, offset: BEUInt32) {
            self.language = language
            self.country = country
            self.length = length
            self.offset = offset
        }
        
        init(from data: inout Data) throws {
            self.language = try data.decode(LanguageCode.self)
            self.country = try data.decode(CountryCode.self)
            self.length = try data.decode(BEUInt32.self)
            self.offset = try data.decode(BEUInt32.self)
        }
        
        func encode(to data: inout Data) {
            data.encode(language)
            data.encode(country)
            data.encode(length)
            data.encode(offset)
        }
    }
}
