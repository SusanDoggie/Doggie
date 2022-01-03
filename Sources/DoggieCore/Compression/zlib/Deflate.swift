//
//  Deflate.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

public class Deflate: _Z_STREAM {
    
    public init(level: Level = .default, windowBits: Int32 = MAX_WBITS, memLevel: Int32 = MAX_MEM_LEVEL, strategy: Strategy = .default) throws {
        try super.init()
        let status = deflateInit2_(&stream, level.rawValue, Z_DEFLATED, windowBits, memLevel, strategy.rawValue, ZLIB_VERSION, Int32(MemoryLayout<z_stream>.size))
        guard status == Z_OK else { throw Error(code: status, msg: stream.msg) }
    }
    
    deinit {
        deflateEnd(&stream)
    }
    
    override func _z_stream_process(_ flush: Int32) -> Int32 {
        return deflate(&stream, flush)
    }
}

extension Deflate {
    
    public enum Strategy: CaseIterable {
        
        case `default`
        case filtered
        case huffmanOnly
        case rle
        case fixed
    }
    
    public enum Level: CaseIterable {
        
        case `default`
        case speed
        case compact
        case none
    }
}

extension Deflate.Strategy {
    
    var rawValue: Int32 {
        switch self {
        case .default: return Z_DEFAULT_STRATEGY
        case .filtered: return Z_FILTERED
        case .huffmanOnly: return Z_HUFFMAN_ONLY
        case .rle: return Z_RLE
        case .fixed: return Z_FIXED
        }
    }
}

extension Deflate.Level {
    
    var rawValue: Int32 {
        switch self {
        case .default: return Z_DEFAULT_COMPRESSION
        case .speed: return Z_BEST_SPEED
        case .compact: return Z_BEST_COMPRESSION
        case .none: return Z_NO_COMPRESSION
        }
    }
}
