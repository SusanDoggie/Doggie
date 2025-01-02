//
//  ASCIIHexFilter.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

struct ASCIIHexFilter: PDFFilter {
    
    static func decode(_ data: inout Data) -> Data? {
        
        var result = Data()
        
        data.pdf_remove_whitespaces()
        
        var counter = 0
        var char: UInt8 = 0
        
        while data.first != 0x3E, let _char = data.popFirst() {
            
            char = (char & 0xF) << 4
            counter += 1
            
            switch _char {
            case 0x30...0x39: char |= _char - 0x30
            case 0x41...0x46: char |= _char - 0x37
            case 0x61...0x66: char |= _char - 0x57
            default: return nil
            }
            
            data.pdf_remove_whitespaces()
            
            if counter & 1 == 0 {
                result.append(char)
                char = 0
            }
        }
        
        if counter & 1 == 1 {
            result.append((char & 0xF) << 4)
        }
        
        return result
    }
}
