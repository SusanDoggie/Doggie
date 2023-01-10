//
//  TIFFPackBitsCompression.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

public class TIFFPackBitsEncoder: CompressionCodec {
    
    public enum Error: Swift.Error {
        
        case endOfStream
    }
    
    private var buffer: Data
    
    private var record: Data
    private var repeat_count: Int
    
    public private(set) var isEndOfStream: Bool = false
    
    public init() {
        self.buffer = Data()
        self.record = Data()
        self.repeat_count = 0
    }
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        guard !isEndOfStream else { throw Error.endOfStream }
        
        for byte in source {
            
            if record.last == byte {
                
                if record.count > 1 {
                    buffer.append(UInt8(record.count - 2))
                    buffer.append(record.dropLast())
                    record = record.suffix(1)
                    repeat_count = 1
                }
                
                repeat_count += 1
                
                if repeat_count == 128 {
                    buffer.append(129)
                    buffer.append(byte)
                    record.removeAll(keepingCapacity: true)
                    repeat_count = 0
                }
                
            } else {
                
                if repeat_count > 1 {
                    buffer.append(UInt8(257 - repeat_count))
                    buffer.append(record.last!)
                    record.removeAll(keepingCapacity: true)
                    repeat_count = 0
                }
                
                record.append(byte)
                repeat_count = 1
                
                if record.count == 128 {
                    buffer.append(127)
                    buffer.append(record)
                    record.removeAll(keepingCapacity: true)
                    repeat_count = 0
                }
            }
            
            if buffer.count > 4095 {
                try buffer.withUnsafeBufferPointer(callback)
                buffer.removeAll(keepingCapacity: true)
            }
        }
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) throws -> Void) throws {
        
        guard !isEndOfStream else { throw Error.endOfStream }
        
        if repeat_count > 1 {
            
            buffer.append(UInt8(257 - repeat_count))
            buffer.append(record.last!)
            
        } else if record.count > 0 {
            
            buffer.append(UInt8(record.count - 1))
            buffer.append(record)
        }
        
        buffer.append(128)
        
        try buffer.withUnsafeBufferPointer(callback)
        
        isEndOfStream = true
    }
}

public struct TIFFPackBitsDecoder: TIFFCompressionDecoder {
    
    public enum Error: Swift.Error {
        
        case unexpectedEndOfStream
    }
    
    public static func decode(_ input: inout Data) throws -> Data {
        
        var output = Data()
        
        while let count = input.popFirst() {
            
            guard count != 128 else { break }
            
            if count <= 127 {
                
                let bytes = input.popFirst(Int(count) + 1)
                guard bytes.count == count + 1 else { throw Error.unexpectedEndOfStream }
                
                output.append(bytes)
                
            } else {
                
                guard let byte = input.popFirst() else { throw Error.unexpectedEndOfStream }
                output.append(contentsOf: repeatElement(byte, count: 257 - Int(count)))
            }
        }
        
        return output
    }
}
