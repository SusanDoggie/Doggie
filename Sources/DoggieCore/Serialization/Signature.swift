//
//  Signature.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

public protocol SignatureProtocol: RawRepresentable, Hashable, ExpressibleByIntegerLiteral, ExpressibleByStringLiteral, CustomStringConvertible, ByteCodable {
    
    associatedtype Bytes: FixedWidthInteger
    
    var rawValue: Bytes { get set }
    
    init(rawValue: Bytes)
}

extension SignatureProtocol {
    
    @inlinable
    @inline(__always)
    public init<S: SignatureProtocol>(_ signature: S) where S.Bytes == Bytes {
        self.init(rawValue: signature.rawValue)
    }
}

extension SignatureProtocol {
    
    @inlinable
    @inline(__always)
    public init(integerLiteral value: Bytes.IntegerLiteralType) {
        self.init(rawValue: Bytes(integerLiteral: value))
    }
    
    @inlinable
    @inline(__always)
    public init(stringLiteral value: StaticString) {
        assert(value.utf8CodeUnitCount == Bytes.bitWidth >> 3)
        self.init(rawValue: value.withUTF8Buffer { $0.withUnsafeTypePunnedBufferPointer(to: Bytes.self) { Bytes(bigEndian: $0.baseAddress!.pointee) } })
    }
    
    @inlinable
    @inline(__always)
    public var description: String {
        return String(self)
    }
}

extension String {
    
    @inlinable
    @inline(__always)
    public init<S: SignatureProtocol>(_ signature: S) {
        self = withUnsafeBytes(of: signature.rawValue.bigEndian) { String(bytes: $0, encoding: .ascii) ?? "" }
    }
}

extension SignatureProtocol where Bytes: ByteOutputStreamable {
    
    @inlinable
    @inline(__always)
    public func write<Target: ByteOutputStream>(to stream: inout Target) {
        stream.encode(rawValue)
    }
}

extension SignatureProtocol where Bytes: ByteDecodable {
    
    @inlinable
    @inline(__always)
    public init(from data: inout Data) throws {
        self.init(rawValue: try Bytes(from: &data))
    }
}

@frozen
public struct Signature<Bytes: FixedWidthInteger & ByteCodable>: SignatureProtocol {
    
    public var rawValue: Bytes
    
    @inlinable
    @inline(__always)
    public init(rawValue: Bytes) {
        self.rawValue = rawValue
    }
}

extension Signature: ByteDecodable where Bytes: ByteDecodable {
    
}

