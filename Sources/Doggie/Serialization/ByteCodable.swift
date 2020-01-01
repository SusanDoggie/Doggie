//
//  ByteCodable.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public protocol ByteOutputStream {
    
    mutating func write(_ bytes: UnsafeRawBufferPointer)
}

public protocol ByteOutputStreamable {
    
    func write<Target: ByteOutputStream>(to stream: inout Target)
}

public protocol ByteDecodable {
    
    init(from: inout Data) throws
}

public typealias ByteCodable = ByteOutputStreamable & ByteDecodable

extension ByteOutputStream {
    
    @inlinable
    public mutating func write<Buffer: DataProtocol>(_ buffer: Buffer) {
        buffer.regions.forEach { $0.withUnsafeBytes { self.write($0) } }
    }
}

@frozen
@usableFromInline
struct _ByteOutputStream: ByteOutputStream {
    
    @usableFromInline
    let sink: (UnsafeRawBufferPointer) -> Void
    
    @inlinable
    init(sink: @escaping (UnsafeRawBufferPointer) -> Void) {
        self.sink = sink
    }
    
    @inlinable
    func write(_ bytes: UnsafeRawBufferPointer) {
        sink(bytes)
    }
}

extension ByteOutputStreamable {
    
    @inlinable
    public func enumerateBytes(_ body: (UnsafeRawBufferPointer) -> Void) {
        withoutActuallyEscaping(body) {
            var stream = _ByteOutputStream(sink: $0)
            self.write(to: &stream)
        }
    }
    
    @inlinable
    public func write<C : RangeReplaceableCollection>(to data: inout C) where C.Element == UInt8 {
        self.enumerateBytes { data.append(contentsOf: $0) }
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    
    @inlinable
    public mutating func encode<T: ByteOutputStreamable>(_ value: T) {
        value.write(to: &self)
    }
}

extension ByteOutputStream {
    
    @inlinable
    public mutating func encode<T: ByteOutputStreamable>(_ value: T) {
        value.write(to: &self)
    }
}

extension ByteDecodable {
    
    @inlinable
    public init(_ data: Data) throws {
        var data = data
        try self.init(from: &data)
    }
}

public enum ByteDecodeError : Error, CaseIterable {
    
    case endOfData
}

extension Data {
    
    @inlinable
    public mutating func decode<T : ByteDecodable>(_ type: T.Type) throws -> T {
        return try T(from: &self)
    }
}

extension FixedWidthInteger where Self : ByteDecodable {
    
    @inlinable
    public init(from data: inout Data) throws {
        let size = Self.bitWidth >> 3
        guard data.count >= size else { throw ByteDecodeError.endOfData }
        self = data.popFirst(size).load(as: Self.self)
    }
}

extension FixedWidthInteger where Self : ByteOutputStreamable {
    
    @inlinable
    public func write<Target: ByteOutputStream>(to stream: inout Target) {
        withUnsafeBytes(of: self) { stream.write($0) }
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
