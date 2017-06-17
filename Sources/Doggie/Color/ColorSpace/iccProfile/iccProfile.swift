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

public struct iccProfile {
    
    public var header: Header
    
    fileprivate var table: [TagSignature: TagData] = [:]
    
    public init(_ data: Data) throws {
        
        guard data.count > 132 else { throw InvalidFormat() }
        
        self.header = data.withUnsafeBytes { $0.pointee }
        
        guard data.count >= header.size else { throw InvalidFormat() }
        
        let tag_count = data[128..<132].withUnsafeBytes { $0.pointee as BEUInt32 }
        
        typealias TagList = (TagSignature, BEUInt32, BEUInt32)
        
        let tag_list_size = MemoryLayout<TagList>.stride * Int(tag_count)
        
        guard data.count > 132 + tag_list_size else { throw InvalidFormat() }
        
        try data[132..<132 + tag_list_size].withUnsafeBytes { (ptr: UnsafePointer<TagList>) in
            
            for (sig, offset, size) in UnsafeBufferPointer(start: ptr, count: Int(tag_count)) {
                
                let start = Int(offset)
                let end = start + Int(size)
                
                guard data.count >= end else { throw InvalidFormat() }
                
                table[sig] = TagData(rawData: data[start..<end])
            }
        }
    }
}

extension iccProfile {
    
    public struct InvalidFormat : Error {
        
    }
}

extension iccProfile : Collection {
    
    public var startIndex: Dictionary<TagSignature, TagData>.Index {
        return table.startIndex
    }
    
    public var endIndex: Dictionary<TagSignature, TagData>.Index {
        return table.endIndex
    }
    
    public subscript(position: Dictionary<TagSignature, TagData>.Index) -> (TagSignature, TagData) {
        return table[position]
    }
    
    public subscript(signature: TagSignature) -> TagData? {
        get {
            return table[signature]
        }
        set {
            table[signature] = newValue
        }
    }
    
    public func index(after i: Dictionary<TagSignature, TagData>.Index) -> Dictionary<TagSignature, TagData>.Index {
        return table.index(after: i)
    }
    
    public var keys: Dictionary<TagSignature, TagData>.Keys {
        return table.keys
    }
    
    public var values: Dictionary<TagSignature, TagData>.Values {
        return table.values
    }
}

