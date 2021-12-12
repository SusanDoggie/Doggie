//
//  JsonCodable.swift
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

extension Json: Encodable {
    
    @usableFromInline
    struct CodingKey: Swift.CodingKey {
        
        @usableFromInline
        var stringValue: String
        
        @usableFromInline
        var intValue: Int? { nil }
        
        @inlinable
        init(stringValue: String) {
            self.stringValue = stringValue
        }
        
        @inlinable
        init?(intValue: Int) {
            return nil
        }
    }
    
    @inlinable
    public func encode(to encoder: Encoder) throws {
        
        switch self {
        case .null:
            
            var container = encoder.singleValueContainer()
            try container.encodeNil()
            
        case let .boolean(bool):
            
            var container = encoder.singleValueContainer()
            try container.encode(bool)
            
        case let .string(string):
            
            var container = encoder.singleValueContainer()
            try container.encode(string)
            
        case let .signed(number):
            
            var container = encoder.singleValueContainer()
            try container.encode(number)
            
        case let .unsigned(number):
            
            var container = encoder.singleValueContainer()
            try container.encode(number)
            
        case let .number(number):
            
            var container = encoder.singleValueContainer()
            try container.encode(number)
            
        case let .decimal(number):
            
            var container = encoder.singleValueContainer()
            try container.encode(number)
            
        case let .array(array):
            
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: array)
            
        case let .dictionary(dictionary):
            
            var container = encoder.container(keyedBy: CodingKey.self)
            
            for (key, value) in dictionary {
                try container.encode(value, forKey: CodingKey(stringValue: key))
            }
        }
    }
}

extension Json: Decodable {
    
    @inlinable
    static func _decode_number(_ container: SingleValueDecodingContainer) -> Json? {
        
        if let double = try? container.decode(Double.self) {
            
            if let uint64 = try? container.decode(UInt64.self), Double(uint64) == double {
                return .unsigned(uint64)
            } else if let int64 = try? container.decode(Int64.self), Double(int64) == double {
                return .signed(int64)
            } else if let decimal = try? container.decode(Decimal.self), decimal.doubleValue == double {
                return .decimal(decimal)
            } else {
                return .number(double)
            }
        }
        
        if let uint64 = try? container.decode(UInt64.self) {
            return .unsigned(uint64)
        }
        
        if let int64 = try? container.decode(Int64.self) {
            return .signed(int64)
        }
        
        if let decimal = try? container.decode(Decimal.self) {
            return .decimal(decimal)
        }
        
        return nil
    }
    
    @inlinable
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
            return
        }
        
        if let bool = try? container.decode(Bool.self) {
            self = .boolean(bool)
            return
        }
        
        if let number = Json._decode_number(container) {
            self = number
            return
        }
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
            return
        }
        
        if let array = try? container.decode([Json].self) {
            self = .array(array)
            return
        }
        
        if let object = try? container.decode([String: Json].self) {
            self = .dictionary(object)
            return
        }
        
        throw DecodingError.dataCorrupted(DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Attempted to decode Json from unknown structure.")
        )
    }
}

extension Json {
    
    @inlinable
    public init(decode string: String) throws {
        self = try JSONDecoder().decode(Json.self, from: string._utf8_data)
    }
    
    @inlinable
    public init(decode data: Data) throws {
        self = try JSONDecoder().decode(Json.self, from: data)
    }
    
    @inlinable
    public init(contentsOf url: URL, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: url, options: options))
    }
    
    @inlinable
    public init(contentsOfFile path: String, options: Data.ReadingOptions = []) throws {
        try self.init(decode: Data(contentsOf: URL(fileURLWithPath: path), options: options))
    }
}

extension Json {
    
    @inlinable
    public func data(prettyPrinted: Bool = false) -> Data? {
        let encoder = JSONEncoder()
        if prettyPrinted {
            encoder.outputFormatting.insert(.prettyPrinted)
        }
        return try? encoder.encode(self)
    }
    
    @inlinable
    public func json(prettyPrinted: Bool = false) -> String? {
        guard let data = self.data(prettyPrinted: prettyPrinted) else { return nil }
        return String(data: data, encoding: String.Encoding.utf8)
    }
}
