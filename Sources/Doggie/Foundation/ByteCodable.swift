//
//  ByteCodable.swift
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

public protocol ByteEncodable {
    
    func encode<C : RangeReplaceableCollection>(to: inout C) where C.Element == UInt8
}

public protocol ByteDecodable {
    
    init(from: inout Data) throws
}

extension ByteDecodable {
    
    @_inlineable
    public init(_ data: Data) throws {
        var data = data
        try self.init(from: &data)
    }
}

public typealias ByteCodable = ByteEncodable & ByteDecodable

public enum ByteDecodeError : Error {
    
    case endOfData
}

extension RangeReplaceableCollection where Element == UInt8 {
    
    @_inlineable
    public mutating func encode<T : ByteEncodable>(_ value: T) {
        value.encode(to: &self)
    }
}

extension Data {
    
    @_inlineable
    public mutating func decode<T : ByteDecodable>(_ type: T.Type) throws -> T {
        return try T(from: &self)
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    
    @_inlineable
    public mutating func encode<T : ByteEncodable>(_ values: T ... ) {
        for value in values {
            value.encode(to: &self)
        }
    }
    
    @_inlineable
    public mutating func encode<S : Sequence>(_ values: S) where S.Element : ByteEncodable {
        for value in values {
            value.encode(to: &self)
        }
    }
}

extension FixedWidthInteger {
    
    @_inlineable
    public init(from data: inout Data) throws {
        let size = Self.bitWidth >> 3
        guard data.count >= size else { throw ByteDecodeError.endOfData }
        self = data.popFirst(size).withUnsafeBytes { $0.pointee }
    }
    
    @_inlineable
    public func encode<C : RangeReplaceableCollection>(to data: inout C) where C.Element == UInt8 {
        var value = self
        withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
    }
}

extension UInt : ByteCodable {
    
}

extension UInt8 : ByteCodable {
    
}

extension UInt16 : ByteCodable {
    
}

extension UInt32 : ByteCodable {
    
}

extension UInt64 : ByteCodable {
    
}

extension Int : ByteCodable {
    
}

extension Int8 : ByteCodable {
    
}

extension Int16 : ByteCodable {
    
}

extension Int32 : ByteCodable {
    
}

extension Int64 : ByteCodable {
    
}

extension BEInteger : ByteCodable {
    
}

extension LEInteger : ByteCodable {
    
}

extension BinaryFixedPoint where BitPattern : ByteEncodable {
    
    @_inlineable
    public func encode<C : RangeReplaceableCollection>(to data: inout C) where C.Element == UInt8 {
        self.bitPattern.encode(to: &data)
    }
}

extension BinaryFixedPoint where BitPattern : ByteDecodable {
    
    @_inlineable
    public init(from data: inout Data) throws {
        self.init(bitPattern: try BitPattern(from: &data))
    }
}

