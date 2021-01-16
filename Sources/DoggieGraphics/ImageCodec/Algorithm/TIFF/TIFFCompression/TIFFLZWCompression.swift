//
//  TIFFLZWCompression.swift
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

private struct TIFFLZWBitsWriter {
    
    var buffer = Data()
    
    var byte: UInt8 = 0
    var bitsize: UInt = 0
    
    mutating func write(_ bits: UInt, _ size: UInt) {
        
        var bits = bits & ((1 << size) - 1)
        var remain = size
        
        while remain != 0 {
            
            let _size = min(8 - bitsize, remain)
            remain -= _size
            
            byte = (byte << _size) | UInt8(bits >> remain)
            bits &= (1 << remain) - 1
            
            bitsize += _size
            
            if bitsize == 8 {
                buffer.append(byte)
                byte = 0
                bitsize = 0
            }
        }
    }
    
    mutating func finalize() {
        if bitsize != 0 {
            buffer.append(byte << (8 - bitsize))
        }
    }
}

public class TIFFLZWEncoder: CompressionCodec {
    
    public enum Error: Swift.Error {
        
        case endOfStream
    }
    
    private let maxBitsWidth: Int
    
    private var tableLimit: Int {
        return 1 << maxBitsWidth
    }
    
    private var table: [Data] = []
    private var writer: TIFFLZWBitsWriter = {
        var writer = TIFFLZWBitsWriter()
        writer.write(256, 9)
        return writer
    }()
    
    public private(set) var isEndOfStream: Bool = false
    
    public init(maxBitsWidth: Int = 12) {
        self.maxBitsWidth = max(9, maxBitsWidth)
        self.table.reserveCapacity(tableLimit - 258)
    }
    
    public func update(_ source: UnsafeBufferPointer<UInt8>, _ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        guard !isEndOfStream else { throw Error.endOfStream }
        
        var source = source
        
        while let char = source.first {
            
            let bit_count = log2(UInt(table.count + 258)) + 1
            
            var max_length = 0
            var index: Int?
            
            for (i, sequence) in table.enumerated() where max_length < sequence.count && source.starts(with: sequence) {
                max_length = sequence.count
                index = i
            }
            
            if let index = index {
                writer.write(UInt(index + 258), bit_count)
            } else {
                writer.write(UInt(char), bit_count)
                max_length = 1
            }
            
            let sequence = source.prefix(max_length + 1)
            source = UnsafeBufferPointer(rebasing: source.dropFirst(max_length))
            
            if table.count + 259 < tableLimit {
                
                table.append(Data(sequence))
                
            } else {
                
                writer.write(256, bit_count)
                table.removeAll(keepingCapacity: true)
            }
            
            if writer.buffer.count > 4095 {
                writer.buffer.withUnsafeBufferPointer(callback)
                writer.buffer.removeAll(keepingCapacity: true)
            }
        }
    }
    
    public func finalize(_ callback: (UnsafeBufferPointer<UInt8>) -> Void) throws {
        
        guard !isEndOfStream else { throw Error.endOfStream }
        
        writer.write(257, log2(UInt(table.count + 258)) + 1)
        
        writer.finalize()
        
        writer.buffer.withUnsafeBufferPointer(callback)
        
        isEndOfStream = true
    }
}

public struct TIFFLZWDecoder: TIFFCompressionDecoder {
    
    public enum Error: Swift.Error {
        
        case invalidInputData
    }
    
    public static func decode(_ input: inout Data) throws -> Data {
        
        var table: [Data] = []
        table.reserveCapacity(0xEFE)
        
        var bits: UInt = 0
        var bitsize: UInt = 0
        
        var last_code_size: UInt?
        
        func next_code() -> UInt? {
            
            while let byte = input.popFirst() {
                
                bits = (bits << 8) | UInt(byte)
                bitsize += 8
                
                if let code_size = last_code_size, bitsize >= code_size {
                    
                    let remain = bitsize - code_size
                    let code = bits >> remain
                    
                    if code == 256 {
                        
                        bits &= (1 << remain) - 1
                        bitsize = remain
                        
                        last_code_size = nil
                        
                        return code
                    }
                }
                
                let code_size = log2(UInt(table.count + 258)) + 1
                
                guard bitsize >= code_size else { continue }
                
                let remain = bitsize - code_size
                let code = bits >> remain
                
                bits &= (1 << remain) - 1
                bitsize = remain
                
                last_code_size = code_size
                
                return code
            }
            
            return nil
        }
        
        var output = Data()
        
        while let code = next_code() {
            
            guard code != 257 else { break }
            
            if code == 256 {
                
                table.removeAll(keepingCapacity: true)
                
            } else if 0...255 ~= code {
                
                if var last_sequence = table.last {
                    last_sequence.append(UInt8(code))
                    table[table.count - 1] = last_sequence
                }
                
                output.append(UInt8(code))
                table.append(output.suffix(1))
                
            } else {
                
                let index = Int(code - 258)
                guard index < table.count else { throw Error.invalidInputData }
                
                if var last_sequence = table.last {
                    last_sequence.append(table[index].first!)
                    table[table.count - 1] = last_sequence
                }
                
                let sequence = table[index]
                
                output.append(sequence)
                table.append(sequence)
            }
        }
        
        return output
    }
}
