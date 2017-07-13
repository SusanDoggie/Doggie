//
//  zlib.swift
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
import zlib

public class Deflate : CompressionCodec {
    
    private var stream: z_stream
    
    public init(level: Level = .default) throws {
        self.stream = z_stream()
        let status = deflateInit2_(&stream, level.rawValue, Z_DEFLATED, MAX_WBITS + 16 as Int32, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { throw Error(code: status, msg: stream.msg) }
    }
    
    deinit {
        deflateEnd(&stream)
    }
}

extension Deflate {
    
    public struct Level: RawRepresentable {
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static var `default` = Level(rawValue: Z_DEFAULT_COMPRESSION)
        public static var speed = Level(rawValue: Z_BEST_SPEED)
        public static var compact = Level(rawValue: Z_BEST_COMPRESSION)
        public static var noCompression = Level(rawValue: Z_NO_COMPRESSION)
    }
    
    public enum Error: Swift.Error {
        
        case stream(message: String)
        case data(message: String)
        case memory(message: String)
        case buffer(message: String)
        case version(message: String)
        case unknown(message: String, code: Int)
        
        fileprivate init(code: Int32, msg: UnsafePointer<CChar>?) {
            
            let message: String = msg.flatMap { String(validatingUTF8: $0) } ?? "Unknown error."
            
            switch code {
            case Z_STREAM_ERROR: self = .stream(message: message)
            case Z_DATA_ERROR: self = .data(message: message)
            case Z_MEM_ERROR: self = .memory(message: message)
            case Z_BUF_ERROR: self = .buffer(message: message)
            case Z_VERSION_ERROR: self = .version(message: message)
            default: self = .unknown(message: message, code: Int(code))
            }
        }
    }
}

extension Deflate {
    
    private func _process(_ capacity: Int, _ flag: Int32) throws -> Data {
        
        var result = Data(capacity: capacity)
        
        stream.avail_out = 0
        
        var written = 0
        
        while stream.avail_in != 0 || stream.avail_out == 0 {
            
            result.count = written + 32
            
            try result.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                
                stream.next_out = bytes.advanced(by: written)
                stream.avail_out = 32
                
                let status = deflate(&stream, flag)
                
                guard status == Z_OK || status == Z_BUF_ERROR || status == Z_STREAM_END else { throw Error(code: status, msg: stream.msg) }
                
                written = result.count - Int(stream.avail_out)
            }
        }
        
        result.count -= Int(stream.avail_out)
        stream.avail_out = 0
        
        return result
    }
    
    public func process(data: Data) throws -> Data {
        
        return try data.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: bytes)
            stream.avail_in = uInt(data.count)
            
            return try _process(data.count, Z_NO_FLUSH)
        }
    }
    
    public func final() throws -> Data {
        
        stream.next_in = nil
        stream.avail_in = 0
        
        return try _process(0, Z_FINISH)
    }
}

public class Inflate : CompressionCodec {
    
    private var stream: z_stream
    
    public init() throws {
        self.stream = z_stream()
        let status = inflateInit2_(&stream, MAX_WBITS + 32 as Int32, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { throw Error(code: status, msg: stream.msg) }
    }
    
    deinit {
        inflateEnd(&stream)
    }
}

extension Inflate {
    
    public enum Error: Swift.Error {
        
        case stream(message: String)
        case data(message: String)
        case memory(message: String)
        case buffer(message: String)
        case version(message: String)
        case unknown(message: String, code: Int)
        
        fileprivate init(code: Int32, msg: UnsafePointer<CChar>?) {
            
            let message: String = msg.flatMap { String(validatingUTF8: $0) } ?? "Unknown error."
            
            switch code {
            case Z_STREAM_ERROR: self = .stream(message: message)
            case Z_DATA_ERROR: self = .data(message: message)
            case Z_MEM_ERROR: self = .memory(message: message)
            case Z_BUF_ERROR: self = .buffer(message: message)
            case Z_VERSION_ERROR: self = .version(message: message)
            default: self = .unknown(message: message, code: Int(code))
            }
        }
    }
}

extension Inflate {
    
    private func _process(_ capacity: Int, _ flag: Int32) throws -> Data {
        
        var result = Data(capacity: capacity)
        
        stream.avail_out = 0
        
        var written = 0
        
        while stream.avail_in != 0 || stream.avail_out == 0 {
            
            result.count = written + 32
            
            try result.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                
                stream.next_out = bytes.advanced(by: written)
                stream.avail_out = 32
                
                let status = inflate(&stream, flag)
                
                guard status == Z_OK || status == Z_BUF_ERROR || status == Z_STREAM_END else { throw Error(code: status, msg: stream.msg) }
                
                written = result.count - Int(stream.avail_out)
            }
        }
        
        result.count -= Int(stream.avail_out)
        stream.avail_out = 0
        
        return result
    }
    
    public func process(data: Data) throws -> Data {
        
        return try data.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: bytes)
            stream.avail_in = uInt(data.count)
            
            return try _process(data.count, Z_NO_FLUSH)
        }
    }
    
    public func final() throws -> Data {
        
        stream.next_in = nil
        stream.avail_in = 0
        
        return try _process(0, Z_FINISH)
    }
}
