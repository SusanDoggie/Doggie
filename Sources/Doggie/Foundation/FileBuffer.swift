//
//  FileBuffer.swift
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

import Foundation

public struct FileBuffer : RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral, Hashable {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    @_versioned
    var buffer: MappedBuffer<UInt8>
    
    @_inlineable
    public init() {
        self.buffer = MappedBuffer(capacity: 0, option: .fileBacked)
    }
    
    @_inlineable
    public init(capacity: Int) {
        self.buffer = MappedBuffer(capacity: capacity, option: .fileBacked)
    }
    
    @_inlineable
    public init(repeating repeatedValue: UInt8, count: Int) {
        self.buffer = MappedBuffer(repeating: repeatedValue, count: count, option: .fileBacked)
    }
    
    @_inlineable
    public init(arrayLiteral elements: UInt8 ...) {
        self.buffer = MappedBuffer(elements, option: .fileBacked)
    }
    
    @_inlineable
    public init(_ other: FileBuffer) {
        self = other
    }
    
    @_inlineable
    public init<S : Sequence>(_ elements: S) where S.Element == UInt8 {
        if let elements = elements as? FileBuffer {
            self = elements
        } else {
            self.buffer = MappedBuffer(elements, option: .fileBacked)
        }
    }
}

extension FileBuffer {
    
    @_inlineable
    public var hashValue: Int {
        return withUnsafeBufferPointer { bytes in
            let max_count = Swift.min(10, bytes.count / MemoryLayout<Int>.stride)
            return bytes.baseAddress!.withMemoryRebound(to: Int.self, capacity: max_count) { address in UnsafeBufferPointer(start: address, count: max_count).reduce(bytes.count) { _hash_combine($0, $1) } }
        }
    }
}

extension FileBuffer {
    
    @_inlineable
    public var capacity: Int {
        return buffer.capacity
    }
}

extension FileBuffer {
    
    @_inlineable
    public var startIndex: Int {
        return buffer.startIndex
    }
    
    @_inlineable
    public var endIndex: Int {
        return buffer.endIndex
    }
    
    @_inlineable
    public subscript(position: Int) -> UInt8 {
        get {
            return buffer[position]
        }
        set {
            buffer[position] = newValue
        }
    }
}

extension FileBuffer : RangeReplaceableCollection {
    
    @_inlineable
    public mutating func append(_ newElement: UInt8) {
        buffer.append(newElement)
    }
    
    @_inlineable
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == UInt8 {
        buffer.append(contentsOf: newElements)
    }
    
    @_inlineable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        buffer.reserveCapacity(minimumCapacity)
    }
    
    @_inlineable
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == UInt8 {
        buffer.replaceSubrange(subRange, with: newElements)
    }
}

extension FileBuffer {
    
    @_inlineable
    public var underestimatedCount: Int {
        return buffer.underestimatedCount
    }
    
    @_inlineable
    public func _copyContents(initializing buffer: UnsafeMutableBufferPointer<Element>) -> (IndexingIterator<FileBuffer>, UnsafeMutableBufferPointer<Element>.Index) {
        let written = buffer._copyContents(initializing: buffer).1
        return (Iterator(_elements: self, _position: written), written)
    }
    
    @_inlineable
    public func _copyToContiguousArray() -> ContiguousArray<UInt8> {
        return buffer._copyToContiguousArray()
    }
}

extension FileBuffer {
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<UInt8>) throws -> R) rethrows -> R {
        return try buffer.withUnsafeBufferPointer(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<UInt8>) throws -> R) rethrows -> R {
        return try buffer.withUnsafeMutableBufferPointer(body)
    }
    
    @_inlineable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeBytes(body)
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        return try buffer.withUnsafeMutableBytes(body)
    }
}

extension FileBuffer {
    
    @_inlineable
    public var data: Data {
        return buffer.data
    }
}

@_inlineable
public func ==(lhs: FileBuffer, rhs: FileBuffer) -> Bool {
    return lhs.withUnsafeBytes { lhs in rhs.withUnsafeBytes { rhs in lhs.count == rhs.count && (lhs.baseAddress == rhs.baseAddress || memcmp(lhs.baseAddress, rhs.baseAddress, lhs.count) == 0) } }
}
