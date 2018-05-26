//
//  iccProfile.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

struct iccProfile {
    
    typealias TagList = (TagSignature, BEUInt32, BEUInt32)
    
    var header: Header
    
    fileprivate var table: [TagSignature: TagData] = [:] {
        didSet {
            header.size = BEUInt32(132 + MemoryLayout<TagList>.stride * Int(table.count) + table.values.reduce(0) { $0 + $1.rawData.count })
        }
    }
    
    init(header: Header) {
        self.header = header
    }
    
    init(_ data: Data) throws {
        
        var _data = data
        
        do {
            
            self.header = try _data.decode(Header.self)
            
            let tag_count = try _data.decode(BEUInt32.self)
            
            for _ in 0..<Int(tag_count) {
                
                let sig = try _data.decode(TagSignature.self)
                let offset = try _data.decode(BEUInt32.self)
                let size = try _data.decode(BEUInt32.self)
                
                guard size > 8 else { continue }
                
                guard data.count >= Int(offset) + Int(size) else { throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.") }
                
                table[sig] = TagData(rawData: data.dropFirst(Int(offset)).prefix(Int(size)))
            }
            
        } catch {
            throw AnyColorSpace.ICCError.invalidFormat(message: "Unexpected end of file.")
        }
    }
}

extension iccProfile {
    
    var data: Data {
        
        let tag_list_size = MemoryLayout<TagList>.stride * Int(table.count)
        
        var buffer = Data(capacity: 128 + tag_list_size)
        
        buffer.encode(header)
        buffer.encode(BEUInt32(table.count))
        
        var _data = Data()
        
        var offset = tag_list_size + 132
        
        for (tag, data) in table {
            buffer.encode(tag)
            buffer.encode(BEUInt32(offset))
            buffer.encode(BEUInt32(data.rawData.count))
            _data.append(data.rawData)
            offset += data.rawData.count
        }
        
        return buffer + _data
    }
}

extension iccProfile : Collection {
    
    var startIndex: Dictionary<TagSignature, TagData>.Index {
        return table.startIndex
    }
    
    var endIndex: Dictionary<TagSignature, TagData>.Index {
        return table.endIndex
    }
    
    subscript(position: Dictionary<TagSignature, TagData>.Index) -> (TagSignature, TagData) {
        return table[position]
    }
    
    subscript(signature: TagSignature) -> TagData? {
        get {
            return table[signature]
        }
        set {
            table[signature] = newValue
        }
    }
    
    func index(after i: Dictionary<TagSignature, TagData>.Index) -> Dictionary<TagSignature, TagData>.Index {
        return table.index(after: i)
    }
    
    var keys: Dictionary<TagSignature, TagData>.Keys {
        return table.keys
    }
    
    var values: Dictionary<TagSignature, TagData>.Values {
        return table.values
    }
}

