//
//  SFNTNAME.swift
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

struct SFNTNAME : DataDecodable {
    
    var format: BEUInt16
    var count: BEUInt16
    var stringOffset: BEUInt16
    var name: [Name]
    
    init(from data: inout Data) throws {
        let copy = data
        self.format = try data.decode(BEUInt16.self)
        self.count = try data.decode(BEUInt16.self)
        self.stringOffset = try data.decode(BEUInt16.self)
        self.name = []
        for _ in 0..<Int(count) {
            let platform = try data.decode(SFNTPlatform.self)
            let language = try data.decode(BEUInt16.self)
            let name = try data.decode(BEUInt16.self)
            let length = try data.decode(BEUInt16.self)
            let offset = try data.decode(BEUInt16.self)
            if let encoding = platform.encoding {
                let strData: Data = copy.dropFirst(Int(stringOffset) + Int(offset)).prefix(Int(length))
                guard strData.count == Int(length) else { throw DataDecodeError.endOfData }
                guard let string = String(data: strData, encoding: encoding) else { continue }
                self.name.append(Name(platform: platform, language: language, name: name, value: string))
            }
        }
    }
    
    struct Name {
        
        var platform: SFNTPlatform
        var language: BEUInt16
        var name: BEUInt16
        var value: String
    }
    
}

