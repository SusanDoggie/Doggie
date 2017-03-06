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

public struct GzipLevel: RawRepresentable {
    
    public var rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static var `default` = GzipLevel(rawValue: Z_DEFAULT_COMPRESSION)
    public static var speed = GzipLevel(rawValue: Z_BEST_SPEED)
    public static var compact = GzipLevel(rawValue: Z_BEST_COMPRESSION)
    public static var noCompression = GzipLevel(rawValue: Z_NO_COMPRESSION)
}

public enum GzipError: Error {
    
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

public extension Data {
    
    private func streamBuffer(body: (z_stream) throws -> Void) rethrows {
        
        try self.withUnsafeBytes { (bytes: UnsafePointer<Bytef>) in
            
            var stream = z_stream()
            stream.next_in = UnsafeMutablePointer<Bytef>(mutating: bytes)
            stream.avail_in = uint(self.count)
            
            try body(stream)
        }
    }
    
    public func gzipped(level: GzipLevel = .default) throws -> Data {
        
        guard !self.isEmpty else {
            return Data()
        }
        
        var data = Data(capacity: self.count)
        
        try self.streamBuffer { stream in
            
            var stream = stream
            
            let status = deflateInit2_(&stream, level.rawValue, Z_DEFLATED, MAX_WBITS + 16 as Int32, MAX_MEM_LEVEL, Z_DEFAULT_STRATEGY, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
            
            guard status == Z_OK else {
                throw GzipError(code: status, msg: stream.msg)
            }
            
            while stream.avail_out == 0 {
                if Int(stream.total_out) >= data.count {
                    data.count += 32
                }
                
                data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                    stream.next_out = bytes.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(data.count) - uInt(stream.total_out)
                    
                    deflate(&stream, Z_FINISH)
                }
            }
            
            guard deflateEnd(&stream) == Z_OK else {
                throw GzipError(code: status, msg: stream.msg)
            }
            
            data.count = Int(stream.total_out)
        }
        
        return data
    }
    
    public func gunzipped() throws -> Data {
        
        guard !self.isEmpty else {
            return Data()
        }
        
        var data = Data(capacity: self.count << 1)
        
        try self.streamBuffer { stream in
            
            var stream = stream
            
            var status = inflateInit2_(&stream, MAX_WBITS + 32 as Int32, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
            
            guard status == Z_OK else {
                throw GzipError(code: status, msg: stream.msg)
            }
            
            repeat {
                if Int(stream.total_out) >= data.count {
                    data.count += self.count >> 1
                }
                
                data.withUnsafeMutableBytes { (bytes: UnsafeMutablePointer<Bytef>) in
                    stream.next_out = bytes.advanced(by: Int(stream.total_out))
                    stream.avail_out = uInt(data.count) - uInt(stream.total_out)
                    
                    status = inflate(&stream, Z_SYNC_FLUSH)
                }
                
            } while status == Z_OK
            
            guard inflateEnd(&stream) == Z_OK && status == Z_STREAM_END else {
                throw GzipError(code: status, msg: stream.msg)
            }
            
            data.count = Int(stream.total_out)
        }
        
        return data
    }
}

