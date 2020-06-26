//
//  ImageRepDecoder.swift
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

protocol ImageRepDecoder: ImageRepBase {
    
    static var supportedMediaTypes: [MediaType] { get }
    
    var mediaType: MediaType { get }
    
    init?(data: Data) throws
}

struct ImageRepDecoderBitStream: Sequence, IteratorProtocol {
    
    let mask: UInt8
    let shift: Int
    let bitWidth: Int
    let count1: Int
    let count2: Int
    
    var counter1: Int
    var counter2: Int
    var byte: UInt8
    var buffer: UnsafePointer<UInt8>
    
    init(buffer: UnsafePointer<UInt8>, count: Int, bitWidth: Int) {
        switch bitWidth {
        case 1:
            self.count1 = 8
            self.shift = 7
            self.mask = 0x80
        case 2:
            self.count1 = 4
            self.shift = 6
            self.mask = 0xC0
        case 4:
            self.count1 = 2
            self.shift = 4
            self.mask = 0xF0
        case 8:
            self.count1 = 1
            self.shift = 0
            self.mask = 0xFF
        default: fatalError()
        }
        self.count2 = count
        self.bitWidth = bitWidth
        self.counter1 = 0
        self.counter2 = 0
        self.byte = 0
        self.buffer = buffer
    }
    
    mutating func next() -> UInt8? {
        
        guard counter2 < count2 else { return nil }
        
        if counter1 == 0 {
            byte = buffer.pointee
            buffer += 1
            counter1 = count1
        }
        
        let value = (byte & mask) >> shift
        byte <<= bitWidth
        
        counter1 -= 1
        counter2 += 1
        
        return value
    }
}
