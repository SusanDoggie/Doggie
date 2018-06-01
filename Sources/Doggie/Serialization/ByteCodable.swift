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

public protocol ByteEncodable: ByteInputStream {
    
}

extension RangeReplaceableCollection where Element == UInt8 {
    
    @_inlineable
    public mutating func encode<T: ByteEncodable>(_ value: T) {
        value.write(to: &self)
    }
}

extension ByteOutputStream {
    
    @_inlineable
    public func encode<T: ByteEncodable>(_ value: T) {
        value.write(to: self)
    }
    
    @_inlineable
    public func encode<T: ByteEncodable>(_ first: T, _ second: T, _ remains: T...) {
        first.write(to: self)
        second.write(to: self)
        for value in remains {
            value.write(to: self)
        }
    }
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

extension Data {
    
    @_inlineable
    public mutating func decode<T : ByteDecodable>(_ type: T.Type) throws -> T {
        return try T(from: &self)
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
    public func write(to stream: ByteOutputStream) {
        var value = self
        withUnsafeBytes(of: &value) { stream.write($0) }
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
