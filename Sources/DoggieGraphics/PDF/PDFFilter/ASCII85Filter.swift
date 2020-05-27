//
//  ASCII85Filter.swift
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

public struct ASCII85Filter: PDFFilter {
    
    public static func encode(_ data: Data) -> Data {
        
        var result = Data()
        
        var counter = 0
        var value: UInt32 = 0
        
        for byte in data {
            
            value = (value << 8) + UInt32(byte)
            counter += 1
            
            if counter & 3 == 0 {
                
                if value == 0 {
                    
                    result.append(0x7A)
                    
                } else {
                    
                    var val = value
                    
                    let c5 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                    val /= 85
                    let c4 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                    val /= 85
                    let c3 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                    val /= 85
                    let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                    val /= 85
                    let c1 = UInt8(truncatingIfNeeded: val + 0x21)
                    
                    result.append(c1)
                    result.append(c2)
                    result.append(c3)
                    result.append(c4)
                    result.append(c5)
                    
                    value = 0
                }
            }
        }
        
        switch counter & 3 {
            
        case 1:
            
            var val = value << 24
            
            val /= 85 * 85 * 85
            let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c1 = UInt8(truncatingIfNeeded: val + 0x21)
            
            result.append(c1)
            result.append(c2)
            
        case 2:
            
            var val = value << 16
            
            val /= 85 * 85
            let c3 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c1 = UInt8(truncatingIfNeeded: val + 0x21)
            
            result.append(c1)
            result.append(c2)
            result.append(c3)
            
        case 3:
            
            var val = value << 8
            
            val /= 85
            let c4 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c3 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
            val /= 85
            let c1 = UInt8(truncatingIfNeeded: val + 0x21)
            
            result.append(c1)
            result.append(c2)
            result.append(c3)
            result.append(c4)
            
        default: break
        }
        
        result.append(0x7E)
        result.append(0x3E)
        
        return result
    }
    
    public static func decode(_ data: inout Data) -> Data? {
        
        var result = Data()
        
        var counter = 0
        var value: UInt64 = 0
        
        loop: while let char = data.popFirst() {
            
            switch char {
                
            case 0x21...0x75:
                
                if char == 0x3C, data.first == 0x7E {
                    
                    data = data.dropFirst()
                    
                    guard counter == 0 else { return nil }
                    
                } else {
                    
                    value *= 85
                    value += UInt64(char - 0x21)
                    
                    counter += 1
                    
                    guard value <= UInt32.max else { return nil }
                }
                
            case 0x7A:
                
                result.append(0)
                result.append(0)
                result.append(0)
                result.append(0)
                
            case 0x7E:
                
                guard data.popFirst() == 0x3E else { continue }
                
                break loop
                
            default: continue
            }
            
            if counter % 5 == 0 {
                
                result.append(UInt8(truncatingIfNeeded: value >> 24))
                result.append(UInt8(truncatingIfNeeded: value >> 16))
                result.append(UInt8(truncatingIfNeeded: value >> 8))
                result.append(UInt8(truncatingIfNeeded: value))
                
                value = 0
            }
        }
        
        switch counter % 5 {
            
        case 2:
            
            value *= 85 * 85 * 85
            
            if value != 0 {
                
                var val = (value & 0xFFFF0000) / (85 * 85 * 85)
                
                let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c1 = UInt8(truncatingIfNeeded: val + 0x21)
                
                val = UInt64(c1 - 0x21)
                val = val * 85 + UInt64(c2 - 0x21)
                val *= 85 * 85 * 85
                
                if val != value {
                    value += 0x01000000
                }
            }
            
            result.append(UInt8(truncatingIfNeeded: value >> 24))
            
        case 3:
            
            value *= 85 * 85
            
            if value != 0 {
                
                var val = (value & 0xFFFF0000) / (85 * 85)
                
                let c3 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c1 = UInt8(truncatingIfNeeded: val + 0x21)
                
                val = UInt64(c1 - 0x21)
                val = val * 85 + UInt64(c2 - 0x21)
                val = val * 85 + UInt64(c3 - 0x21)
                val *= 85 * 85
                
                if val != value {
                    value += 0x00010000
                }
            }
            
            result.append(UInt8(truncatingIfNeeded: value >> 24))
            result.append(UInt8(truncatingIfNeeded: value >> 16))
            
        case 4:
            
            value *= 85
            
            if value != 0 {
                
                var val = (value & 0xFFFFFF00) / 85
                
                let c4 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c3 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c2 = UInt8(truncatingIfNeeded: val % 85 + 0x21)
                val /= 85
                let c1 = UInt8(truncatingIfNeeded: val + 0x21)
                
                val = UInt64(c1 - 0x21)
                val = val * 85 + UInt64(c2 - 0x21)
                val = val * 85 + UInt64(c3 - 0x21)
                val = val * 85 + UInt64(c4 - 0x21)
                val *= 85
                
                if val != value {
                    value += 0x00000100
                }
            }
            
            result.append(UInt8(truncatingIfNeeded: value >> 24))
            result.append(UInt8(truncatingIfNeeded: value >> 16))
            result.append(UInt8(truncatingIfNeeded: value >> 8))
            
        default: break
        }
        
        return result
    }
}
