//
//  DataPackEncodable.swift
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

extension DataPack: Encodable {
    
    @usableFromInline
    struct CodingKey: Swift.CodingKey {
        
        @usableFromInline
        var stringValue: String
        
        @usableFromInline
        var intValue: Int?
        
        @inlinable
        init(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }
        
        @inlinable
        init(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        
        switch self.base {
        case .null:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            
        case let .boolean(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .string(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .signed(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .unsigned(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .number(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .binary(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .uuid(value):
            
            var container = encoder.singleValueContainer()
            try container.encode(value)
            
        case let .array(value):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: value)
            
        case let .undecoded_array(value):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: value)
            
        case let .dictionary(value):
            
            var container = encoder.container(keyedBy: CodingKey.self)
            
            for (key, value) in value {
                try container.encode(value, forKey: CodingKey(stringValue: key))
            }
        }
    }
}
