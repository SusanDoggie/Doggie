//
//  RunLengthFilter.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a data
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, data, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above dataright notice and this permission notice shall be included in
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

public struct RunLengthFilter: PDFFilter {
    
    public static func encode(_ data: Data) -> Data {
        
        var result = Data()
        
        var buffer = Data()
        var repeat_count = 0
        
        for byte in data {
            
            if buffer.last == byte {
                
                while buffer.count > 1 {
                    let bytes = buffer.popFirst(min(128, buffer.count - 1))
                    result.append(UInt8(bytes.count - 1))
                    result.append(bytes)
                }
                
                repeat_count += 1
                
                if repeat_count == 128 {
                    result.append(129)
                    result.append(byte)
                    buffer = Data()
                }
                
            } else {
                
                if repeat_count > 1, let byte = buffer.popLast() {
                    
                    while repeat_count > 0 {
                        let count = min(128, repeat_count)
                        result.append(UInt8(257 - count))
                        result.append(byte)
                        repeat_count -= count
                    }
                }
                
                buffer.append(byte)
                repeat_count = 1
            }
        }
        
        if repeat_count == 1 {
            
            while !buffer.isEmpty {
                let bytes = buffer.popFirst(min(128, buffer.count))
                result.append(UInt8(bytes.count - 1))
                result.append(bytes)
            }
            
        } else if let byte = buffer.popLast() {
            
            while repeat_count > 0 {
                let count = min(128, repeat_count)
                result.append(UInt8(257 - count))
                result.append(byte)
                repeat_count -= count
            }
        }
        
        result.append(128)
        
        return result
    }
    
    public static func decode(_ data: inout Data) -> Data? {
        
        var result = Data()
        
        while let count = data.popFirst() {
            
            guard count != 128 else { break }
            
            if count <= 127 {
                
                let bytes = data.popFirst(Int(count) + 1)
                guard bytes.count == count + 1 else { return nil }
                
                result.append(bytes)
                
            } else {
                
                guard let byte = data.popFirst() else { return nil }
                result.append(contentsOf: repeatElement(byte, count: 257 - Int(count)))
            }
        }
        
        return result
    }
}
