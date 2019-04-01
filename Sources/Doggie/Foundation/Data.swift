//
//  Data.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

extension Data {
    
    @inlinable
    @inline(__always)
    public func fileBacked() -> Data {
        return self.withUnsafeBufferPointer { MappedBuffer(bytes: UnsafeRawBufferPointer($0), fileBacked: true).data }
    }
}

extension Data {
    
    @inlinable
    public func withUnsafeBufferPointer<T, R>(as type: T.Type, _ body: (UnsafeBufferPointer<T>) throws -> R) rethrows -> R {
        return try self.withUnsafeBytes { try body($0.bindMemory(to: T.self)) }
    }
    
    @inlinable
    public mutating func withUnsafeMutableBufferPointer<T, R>(as type: T.Type, _ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        
        return try self.withUnsafeMutableBytes { (bytes: UnsafeMutableRawBufferPointer) in
            
            var buf = bytes.bindMemory(to: T.self)
            let copy = buf
            
            defer { precondition(buf.baseAddress == copy.baseAddress) }
            defer { precondition(buf.count == copy.count) }
            
            return try body(&buf)
        }
    }
}

extension Data {
    
    @inlinable
    @inline(__always)
    public func load<T>(fromByteOffset offset: Int = 0, as type: T.Type) -> T {
        precondition(offset >= 0, "Data.load with negative offset")
        precondition(offset + MemoryLayout<T>.stride <= self.count, "Data.load out of bounds")
        return self.withUnsafeBytes { ($0.baseAddress! + offset).bindMemory(to: T.self, capacity: 1).pointee }
    }
    
    @inlinable
    @inline(__always)
    public mutating func storeBytes<T>(of value: T, toByteOffset offset: Int = 0) {
        precondition(offset >= 0, "Data.storeBytes with negative offset")
        precondition(offset + MemoryLayout<T>.stride <= self.count, "Data.storeBytes out of bounds")
        self.withUnsafeMutableBytes { ($0.baseAddress! + offset).bindMemory(to: T.self, capacity: 1).pointee = value }
    }
}

extension Data {
    
    @inlinable
    @inline(__always)
    public mutating func append(utf8 str: String) {
        let count = str.utf8.count
        str.utf8CString.withUnsafeBufferPointer { self.append(UnsafeBufferPointer(rebasing: $0.prefix(count))) }
    }
}

extension RangeReplaceableCollection where Element == UInt8 {
    
    @inlinable
    @inline(__always)
    public mutating func append(utf8 str: String) {
        let count = str.utf8.count
        str.utf8CString.withUnsafeBufferPointer { self.append(contentsOf: UnsafeRawBufferPointer(UnsafeBufferPointer(rebasing: $0.prefix(count)))) }
    }
}

extension String {
    
    @inlinable
    @inline(__always)
    public var _utf8_data: Data {
        let count = self.utf8.count
        return self.utf8CString.withUnsafeBufferPointer { Data(buffer: UnsafeBufferPointer(rebasing: $0.prefix(count))) }
    }
}

extension Data {
    
    public func write(to url: URL, withIntermediateDirectories createIntermediates: Bool, options: Data.WritingOptions = []) throws {
        
        let manager = FileManager.default
        
        let directory = url.deletingLastPathComponent()
        
        if !manager.fileExists(atPath: directory.path) {
            try manager.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
        }
        
        try self.write(to: url, options: options)
    }
}

