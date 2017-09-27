//
//  MappedBuffer.swift
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

public struct MappedBuffer<Element> : RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    public typealias SubSequence = MutableRangeReplaceableRandomAccessSlice<MappedBuffer>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    private var buffer: MappedBufferTempFile<Element>
    
    public init() {
        self.buffer = MappedBufferTempFile<Element>(capacity: 0)
    }
    
    public init(repeating repeatedValue: Element, count: Int) {
        self.buffer = MappedBufferTempFile<Element>(capacity: count)
        self.buffer.count = count
        self.buffer.address.initialize(to: repeatedValue, count: count)
    }
    
    public init(arrayLiteral elements: Element ...) {
        self.buffer = MappedBufferTempFile<Element>(capacity: elements.count)
        self.buffer.count = count
        
        var address = self.buffer.address
        for item in elements {
            address.initialize(to: item)
            address += 1
        }
    }
}

extension MappedBuffer {
    
    public var capacity: Int {
        return buffer.capacity
    }
}

extension MappedBuffer : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return self.withUnsafeBufferPointer { "[\($0.lazy.map { "\($0)" }.joined(separator: ", "))]" }
    }
}

extension MappedBuffer {
    
    private mutating func make_unique_if_need() {
        
        if isKnownUniquelyReferenced(&buffer) {
            return
        }
        
        let new_buffer = MappedBufferTempFile<Element>(capacity: buffer.capacity)
        
        new_buffer.count = buffer.count
        new_buffer.address.initialize(from: buffer.address, count: buffer.count)
        
        self.buffer = new_buffer
    }
    
    @_inlineable
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return buffer.count
    }
    
    @_inlineable
    public subscript(position: Int) -> Element {
        get {
            precondition(self.indices ~= position, "Index out of range.")
            return self.withUnsafeBufferPointer { $0[position] }
        }
        set {
            precondition(self.indices ~= position, "Index out of range.")
            self.withUnsafeMutableBufferPointer { $0[position] = newValue }
        }
    }
}

extension MappedBuffer : RangeReplaceableCollection {
    
    public mutating func append(_ x: Element) {
        
        let new_count = buffer.count + 1
        
        if isKnownUniquelyReferenced(&buffer) {
            
            if buffer.capacity < new_count {
                buffer.extend_capacity(capacity: new_count)
            }
            
            let append = buffer.address + buffer.count
            append.initialize(to: x)
            
            buffer.count = new_count
            
        } else {
            
            let new_buffer = MappedBufferTempFile<Element>(capacity: new_count)
            
            new_buffer.count = new_count
            new_buffer.address.initialize(from: buffer.address, count: buffer.count)
            
            let append = new_buffer.address + buffer.count
            append.initialize(to: x)
            
            self.buffer = new_buffer
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        
        guard buffer.capacity < minimumCapacity else { return }
        
        if isKnownUniquelyReferenced(&buffer) {
            
            buffer.extend_capacity(capacity: minimumCapacity)
            
        } else {
            
            let new_buffer = MappedBufferTempFile<Element>(capacity: minimumCapacity)
            
            new_buffer.count = buffer.count
            new_buffer.address.initialize(from: buffer.address, count: buffer.count)
            
            self.buffer = new_buffer
        }
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Element {
        
        precondition(0 <= subRange.lowerBound, "Index out of range.")
        precondition(subRange.upperBound <= buffer.count, "Index out of range.")
        
        let newElements_count = Int(newElements.count)
        let new_count = buffer.count - subRange.count + newElements_count
        
        if isKnownUniquelyReferenced(&buffer) {
            
            if buffer.capacity < new_count {
                buffer.extend_capacity(capacity: new_count)
            }
            
            let destroy = buffer.address + subRange.lowerBound
            destroy.deinitialize(count: subRange.count)
            
            if subRange.upperBound != buffer.count {
                
                let move_count = buffer.count - subRange.upperBound
                
                let move_from = buffer.address + subRange.upperBound
                let move_to = buffer.address + subRange.lowerBound + newElements_count
                
                move_to.moveInitialize(from: move_from, count: move_count)
            }
            
            var address = buffer.address + subRange.lowerBound
            
            for item in newElements {
                address.initialize(to: item)
                address += 1
            }
            
            buffer.count = new_count
            
        } else {
            
            let new_buffer = MappedBufferTempFile<Element>(capacity: Swift.max(buffer.capacity, new_count))
            
            new_buffer.count = new_count
            
            var address = new_buffer.address
            
            if subRange.lowerBound != 0 {
                address.initialize(from: buffer.address, count: subRange.lowerBound)
                address += subRange.lowerBound
            }
            
            for item in newElements {
                address.initialize(to: item)
                address += 1
            }
            
            if subRange.upperBound != buffer.count {
                address.initialize(from: buffer.address + subRange.upperBound, count: buffer.count - subRange.upperBound)
            }
            
            self.buffer = new_buffer
        }
    }
}

extension MappedBuffer {
    
    @_inlineable
    public var underestimatedCount: Int {
        return self.count
    }
    
    @_inlineable
    public func _copyToContiguousArray() -> ContiguousArray<Element> {
        
        var result = ContiguousArray<Element>()
        result.reserveCapacity(self.count)
        
        self.withUnsafeBufferPointer { result.append(contentsOf: $0) }
        
        return result
    }
}

extension MappedBuffer {
    
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        
        return try body(UnsafeBufferPointer(start: buffer.address, count: buffer.count))
    }
    
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        
        self.make_unique_if_need()
        
        var buf = UnsafeMutableBufferPointer(start: buffer.address, count: buffer.count)
        
        defer { precondition(buf.baseAddress == buffer.address) }
        defer { precondition(buf.count == buffer.count) }
        
        return try body(&buf)
    }
    
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try body(UnsafeRawBufferPointer(start: buffer.address, count: buffer.count * MemoryLayout<Element>.stride))
    }
    
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        self.make_unique_if_need()
        
        return try body(UnsafeMutableRawBufferPointer(start: buffer.address, count: buffer.count * MemoryLayout<Element>.stride))
    }
}

private class MappedBufferTempFile<Element> {
    
    let fd: Int32
    private(set) var raw_address: UnsafeMutableRawPointer
    private(set) var address: UnsafeMutablePointer<Element>
    private(set) var mapped_size: Int
    private(set) var capacity: Int
    var count: Int = 0
    
    init(capacity: Int) {
        
        self.mapped_size = (max(capacity, 1) * MemoryLayout<Element>.stride).align(Int(getpagesize()))
        self.capacity = mapped_size / MemoryLayout<Element>.stride
        
        let path = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.SusanDoggie.MappedBuffer.\(UUID().uuidString).XXXXXX")
        var path_buffer = path.withUnsafeFileSystemRepresentation { Array(UnsafeBufferPointer(start: $0, count: $0 == nil ? 0 : Int(PATH_MAX))) }
        
        self.fd = mkstemp(&path_buffer)
        
        guard self.fd != -1 else { fatalError("\(String(cString: strerror(errno))): \(path)") }
        guard ftruncate(self.fd, off_t(mapped_size)) != -1 else { fatalError("\(String(cString: strerror(errno)))") }
        
        self.raw_address = mmap(nil, mapped_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
        self.address = raw_address.bindMemory(to: Element.self, capacity: capacity)
    }
    
    deinit {
        if count != 0 {
            address.deinitialize(count: count)
        }
        munmap(raw_address, mapped_size)
        ftruncate(fd, 0)
        close(fd)
    }
    
    func extend_capacity(capacity: Int) {
        
        precondition(self.capacity <= capacity)
        
        munmap(raw_address, mapped_size)
        
        self.mapped_size = (max(capacity, 1) * MemoryLayout<Element>.stride).align(Int(getpagesize()))
        self.capacity = mapped_size / MemoryLayout<Element>.stride
        
        guard ftruncate(self.fd, off_t(mapped_size)) != -1 else { fatalError("\(String(cString: strerror(errno)))") }
        
        self.raw_address = mmap(nil, mapped_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
        self.address = raw_address.bindMemory(to: Element.self, capacity: capacity)
    }
}

