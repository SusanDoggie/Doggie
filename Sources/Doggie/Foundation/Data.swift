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

extension Data : ExpressibleByArrayLiteral {
    
    @inlinable
    @inline(__always)
    public init(arrayLiteral elements: UInt8 ...) {
        self.init(elements)
    }
}

extension Data {
    
    @inlinable
    @inline(__always)
    public func fileBacked() -> Data {
        return self.withUnsafeBufferPointer { MappedBuffer(bytes: UnsafeRawBufferPointer($0), fileBacked: true).data }
    }
}

extension Data {
    
    @inlinable
    @inline(__always)
    public func load<T>(fromByteOffset offset: Int = 0, as type: T.Type) -> T {
        precondition(offset >= 0, "Data.load with negative offset")
        precondition(offset + MemoryLayout<T>.stride <= self.count, "Data.load out of bounds")
        return self.withUnsafeBytes { UnsafeRawBufferPointer(rebasing: $0.dropFirst(offset)).baseAddress!.assumingMemoryBound(to: type).pointee }
    }
    
    @inlinable
    @inline(__always)
    public mutating func storeBytes<T>(of value: T, toByteOffset offset: Int = 0) {
        precondition(offset >= 0, "Data.storeBytes with negative offset")
        precondition(offset + MemoryLayout<T>.stride <= self.count, "Data.storeBytes out of bounds")
        return self.withUnsafeMutableBytes { UnsafeMutableRawBufferPointer(rebasing: $0.dropFirst(offset)).baseAddress!.assumingMemoryBound(to: T.self).pointee = value }
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

