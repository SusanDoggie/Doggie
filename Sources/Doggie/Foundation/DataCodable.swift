//
//  DataCodable.swift
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

public protocol DataEncodable {
    
    func encode(to: inout Data)
}

public protocol DataDecodable {
    
    init(from: inout Data) throws
}

public typealias DataCodable = DataEncodable & DataDecodable

public enum DataDecodeError : Error {
    
    case endOfData
}

extension Data {
    
    @_inlineable
    public mutating func encode<T : DataEncodable>(_ value: T) {
        value.encode(to: &self)
    }
    
    @_inlineable
    public mutating func decode<T : DataDecodable>(_ type: T.Type) throws -> T {
        return try T(from: &self)
    }
}

extension FixedWidthInteger {
    
    @_inlineable
    public func encode(to data: inout Data) {
        var value = self
        withUnsafeBytes(of: &value) { data.append(contentsOf: $0) }
    }
    
    @_inlineable
    public init(from data: inout Data) throws {
        let size = Self.bitWidth >> 3
        guard data.count >= size else { throw DataDecodeError.endOfData }
        self = data.suffix(size).withUnsafeBytes { $0.pointee }
        data.removeFirst(size)
    }
}

extension UInt : DataCodable {
    
}

extension UInt8 : DataCodable {
    
}

extension UInt16 : DataCodable {
    
}

extension UInt32 : DataCodable {
    
}

extension UInt64 : DataCodable {
    
}

extension Int : DataCodable {
    
}

extension Int8 : DataCodable {
    
}

extension Int16 : DataCodable {
    
}

extension Int32 : DataCodable {
    
}

extension Int64 : DataCodable {
    
}

extension BEInteger : DataCodable {
    
}

extension LEInteger : DataCodable {
    
}

extension BinaryFixedPoint where BitPattern : DataEncodable {
    
    public func encode(to data: inout Data) {
        self.bitPattern.encode(to: &data)
    }
}

extension BinaryFixedPoint where BitPattern : DataDecodable {
    
    public init(from data: inout Data) throws {
        self.init(bitPattern: try BitPattern(from: &data))
    }
}
