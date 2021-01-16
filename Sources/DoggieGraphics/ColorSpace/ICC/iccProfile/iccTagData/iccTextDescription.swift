//
//  iccTextDescription.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

struct iccTextDescription: ByteDecodable {
    
    var ascii: String?
    var unicode: String?
    
    init(from data: inout Data) throws {
        
        guard data.count > 8 else { throw AnyColorSpace.ICCError.endOfData }
        
        guard try data.decode(iccProfile.TagType.self) == .textDescription else { throw AnyColorSpace.ICCError.invalidFormat(message: "Invalid textDescription.") }
        
        data.removeFirst(4)
        
        let asciiCount = Int(try data.decode(BEUInt32.self))
        if asciiCount != 0 {
            self.ascii = String(data: data.popFirst(asciiCount), encoding: .ascii)
        }
        
        let unicodeCount = Int(try data.decode(BEUInt32.self))
        if unicodeCount != 0 {
            self.unicode = String(data: data.popFirst(unicodeCount), encoding: .utf16BigEndian)
        }
    }
    
}
