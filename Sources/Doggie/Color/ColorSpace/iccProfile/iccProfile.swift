//
//  iccProfile.swift
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

@_versioned
struct iccProfile {
    
    @_versioned
    var header: Header
    
    fileprivate var table: [TagSignature: TagData] = [:]
    
    @_versioned
    init(_ data: Data) throws {
        
        guard data.count > 132 else { throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.") }
        
        self.header = data.withUnsafeBytes { $0.pointee }
        
        guard data.count >= header.size else { throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.") }
        
        let tag_count = data[128..<132].withUnsafeBytes { $0.pointee as BEUInt32 }
        
        typealias TagList = (TagSignature, BEUInt32, BEUInt32)
        
        let tag_list_size = MemoryLayout<TagList>.stride * Int(tag_count)
        
        guard data.count > 132 + tag_list_size else { throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.") }
        
        try data[132..<132 + tag_list_size].withUnsafeBytes { (ptr: UnsafePointer<TagList>) in
            
            for (sig, offset, size) in UnsafeBufferPointer(start: ptr, count: Int(tag_count)) {
                
                let start = Int(offset)
                let end = start + Int(size)
                
                guard data.count >= end else { throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.") }
                
                table[sig] = TagData(rawData: data[start..<end])
            }
        }
    }
}

extension iccProfile : Collection {
    
    @_versioned
    var startIndex: Dictionary<TagSignature, TagData>.Index {
        return table.startIndex
    }
    
    @_versioned
    var endIndex: Dictionary<TagSignature, TagData>.Index {
        return table.endIndex
    }
    
    @_versioned
    subscript(position: Dictionary<TagSignature, TagData>.Index) -> (TagSignature, TagData) {
        return table[position]
    }
    
    @_versioned
    subscript(signature: TagSignature) -> TagData? {
        get {
            return table[signature]
        }
        set {
            table[signature] = newValue
        }
    }
    
    @_versioned
    func index(after i: Dictionary<TagSignature, TagData>.Index) -> Dictionary<TagSignature, TagData>.Index {
        return table.index(after: i)
    }
    
    @_versioned
    var keys: Dictionary<TagSignature, TagData>.Keys {
        return table.keys
    }
    
    @_versioned
    var values: Dictionary<TagSignature, TagData>.Values {
        return table.values
    }
}

