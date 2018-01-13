//
//  Mappedbase.swift
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

public enum MappedBufferOption {
    
    case inMemory
    case fileBacked
}

extension MappedBufferOption {
    
    @_inlineable
    public static var `default` : MappedBufferOption {
        return .inMemory
    }
}

public struct MappedBuffer<Element> : RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    public typealias SubSequence = MutableRangeReplaceableRandomAccessSlice<MappedBuffer>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    @_versioned
    var base: Base
    
    @_inlineable
    public init() {
        self.base = Base(capacity: 0, option: .default)
    }
    
    @_inlineable
    public init(option: MappedBufferOption) {
        self.base = Base(capacity: 0, option: option)
    }
    
    @_inlineable
    public init(capacity: Int, option: MappedBufferOption = .default) {
        self.base = Base(capacity: capacity, option: option)
    }
    
    @_inlineable
    public init(repeating repeatedValue: Element, count: Int, option: MappedBufferOption = .default) {
        self.base = Base(capacity: count, option: option)
        self.base.count = count
        self.base.address.initialize(to: repeatedValue, count: count)
    }
    
    @_inlineable
    public init(arrayLiteral elements: Element ...) {
        self.base = Base(capacity: elements.count, option: .default)
        self.base.count = elements.count
        self.base.address.initialize(from: elements, count: elements.count)
    }
    
    @_inlineable
    public init(_ other: MappedBuffer<Element>) {
        self = other
    }
    
    @_inlineable
    public init(_ other: MappedBuffer<Element>, option: MappedBufferOption) {
        if other.option == option {
            self = other
        } else {
            let _other = other.base
            self.base = Base(capacity: _other.capacity, option: option)
            self.base.count = _other.count
            self.base.address.initialize(from: _other.address, count: _other.count)
        }
    }
    
    @_inlineable
    public init<S : Sequence>(_ elements: S, option: MappedBufferOption = .default) where S.Element == Element {
        self.base = Base(capacity: elements.underestimatedCount, option: option)
        self.append(contentsOf: elements)
    }
}

extension MappedBuffer {
    
    @_inlineable
    public var option: MappedBufferOption {
        return base.fd == -1 ? .inMemory : .fileBacked
    }
    
    @_inlineable
    public var capacity: Int {
        return base.capacity
    }
}

extension MappedBuffer : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return self.withUnsafeBufferPointer { "[\($0.lazy.map { "\($0)" }.joined(separator: ", "))]" }
    }
}

extension MappedBuffer {
    
    @_versioned
    @_inlineable
    mutating func make_unique_if_need() {
        
        if _fastPath(isKnownUniquelyReferenced(&base)) {
            return
        }
        
        let new_base = Base(capacity: base.capacity, option: self.option)
        
        new_base.count = base.count
        new_base.address.initialize(from: base.address, count: base.count)
        
        self.base = new_base
    }
    
    @_inlineable
    public var startIndex: Int {
        return 0
    }
    
    @_inlineable
    public var endIndex: Int {
        return base.count
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
    
    @_inlineable
    public mutating func append(_ newElement: Element) {
        
        let old_count = base.count
        let new_count = old_count + 1
        
        if _fastPath(isKnownUniquelyReferenced(&base)) {
            if base.capacity < new_count {
                base.extend_capacity(capacity: new_count)
            }
        } else {
            let new_base = Base(capacity: Swift.max(base.capacity, new_count), option: self.option)
            new_base.address.initialize(from: base.address, count: old_count)
            
            self.base = new_base
        }
        
        let append = base.address + old_count
        append.initialize(to: newElement)
        
        base.count = new_count
    }
    
    @_inlineable
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == Element {
        
        let old_count = base.count
        let new_count = old_count + newElements.underestimatedCount
        
        if _fastPath(isKnownUniquelyReferenced(&base)) {
            if base.capacity < new_count {
                base.extend_capacity(capacity: new_count)
            }
        } else {
            let new_base = Base(capacity: Swift.max(base.capacity, new_count), option: self.option)
            new_base.address.initialize(from: base.address, count: old_count)
            
            self.base = new_base
        }
        
        var iterator = UnsafeMutableBufferPointer(start: base.address + old_count, count: new_count - old_count).initialize(from: newElements).0
        base.count = new_count
        
        while let item = iterator.next() {
            self.append(item)
        }
    }
    
    @_inlineable
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        
        guard base.capacity < minimumCapacity else { return }
        
        if _fastPath(isKnownUniquelyReferenced(&base)) {
            
            base.extend_capacity(capacity: minimumCapacity)
            
        } else {
            
            let new_base = Base(capacity: minimumCapacity, option: self.option)
            
            new_base.count = base.count
            new_base.address.initialize(from: base.address, count: base.count)
            
            self.base = new_base
        }
    }
    
    @_inlineable
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == Element {
        
        precondition(0 <= subRange.lowerBound, "Index out of range.")
        precondition(subRange.upperBound <= base.count, "Index out of range.")
        
        let newElements_count = Int(newElements.count)
        let new_count = base.count - subRange.count + newElements_count
        
        if _fastPath(isKnownUniquelyReferenced(&base)) {
            
            if base.capacity < new_count {
                base.extend_capacity(capacity: new_count)
            }
            
            let destroy = base.address + subRange.lowerBound
            destroy.deinitialize(count: subRange.count)
            
            if subRange.upperBound != base.count {
                
                let move_count = base.count - subRange.upperBound
                
                let move_from = base.address + subRange.upperBound
                let move_to = base.address + subRange.lowerBound + newElements_count
                
                move_to.moveInitialize(from: move_from, count: move_count)
            }
            
            var address = base.address + subRange.lowerBound
            
            for item in newElements {
                address.initialize(to: item)
                address += 1
            }
            
            base.count = new_count
            
        } else {
            
            let new_base = Base(capacity: Swift.max(base.capacity, new_count), option: self.option)
            
            new_base.count = new_count
            
            var address = new_base.address
            
            if subRange.lowerBound != 0 {
                address.initialize(from: base.address, count: subRange.lowerBound)
                address += subRange.lowerBound
            }
            
            for item in newElements {
                address.initialize(to: item)
                address += 1
            }
            
            if subRange.upperBound != base.count {
                address.initialize(from: base.address + subRange.upperBound, count: base.count - subRange.upperBound)
            }
            
            self.base = new_base
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
    
    @_inlineable
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        
        return try body(UnsafeBufferPointer(start: base.address, count: base.count))
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        
        self.make_unique_if_need()
        
        var buf = UnsafeMutableBufferPointer(start: base.address, count: base.count)
        
        defer { precondition(buf.baseAddress == base.address) }
        defer { precondition(buf.count == base.count) }
        
        return try body(&buf)
    }
    
    @_inlineable
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        
        return try body(UnsafeRawBufferPointer(start: base.address, count: base.count * MemoryLayout<Element>.stride))
    }
    
    @_inlineable
    public mutating func withUnsafeMutableBytes<R>(_ body: (UnsafeMutableRawBufferPointer) throws -> R) rethrows -> R {
        
        self.make_unique_if_need()
        
        return try body(UnsafeMutableRawBufferPointer(start: base.address, count: base.count * MemoryLayout<Element>.stride))
    }
}

extension MappedBuffer {
    
    @_versioned
    @_fixed_layout
    class Base {
        
        @_versioned
        let fd: Int32
        
        let path: String
        
        @_versioned
        var address: UnsafeMutablePointer<Element>
        
        var mapped_size: Int
        
        @_versioned
        var count: Int = 0
        
        @_versioned
        var capacity: Int {
            return self.mapped_size / MemoryLayout<Element>.stride
        }
        
        @_versioned
        init(capacity: Int, option: MappedBufferOption) {
            
            self.mapped_size = (Swift.max(capacity, 1) * MemoryLayout<Element>.stride).align(Int(getpagesize()))
            let capacity = mapped_size / MemoryLayout<Element>.stride
            
            switch option {
            case .inMemory:
                
                self.fd = -1
                self.path = ""
                
                let _address = mmap(nil, mapped_size, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, fd, 0)
                guard _address != UnsafeMutableRawPointer(bitPattern: -1) else { fatalError(String(cString: strerror(errno))) }
                
                self.address = _address!.bindMemory(to: Element.self, capacity: capacity)
                
            case .fileBacked:
                
                var fd: Int32 = 0
                var path = ""
                
                while true {
                    let path_url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("com.SusanDoggie.MappedBuffer.\(UUID().uuidString)")
                    path = path_url.withUnsafeFileSystemRepresentation { String(cString: $0!) }
                    fd = open(path, O_RDWR | O_CREAT | O_EXCL, S_IRUSR | S_IWUSR)
                    guard fd == -1 && errno == EEXIST else { break }
                }
                
                self.fd = fd
                self.path = path
                
                guard fd != -1 else { fatalError("\(String(cString: strerror(errno))): \(path)") }
                guard flock(fd, LOCK_EX) != -1 else { fatalError(String(cString: strerror(errno))) }
                guard ftruncate(fd, off_t(mapped_size)) != -1 else { fatalError(String(cString: strerror(errno))) }
                
                let _address = mmap(nil, mapped_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
                guard _address != UnsafeMutableRawPointer(bitPattern: -1) else { fatalError(String(cString: strerror(errno))) }
                
                self.address = _address!.bindMemory(to: Element.self, capacity: capacity)
            }
        }
        
        deinit {
            
            if count != 0 {
                address.deinitialize(count: count)
            }
            
            munmap(address, mapped_size)
            
            if fd != -1 {
                ftruncate(fd, 0)
                flock(fd, LOCK_UN)
                close(fd)
                Foundation.remove(path)
            }
        }
        
        @_versioned
        func extend_capacity(capacity: Int) {
            
            guard self.capacity < capacity else { return }
            
            let new_mapped_size = (Swift.max(capacity, 1) * MemoryLayout<Element>.stride).align(Int(getpagesize()))
            let new_capacity = new_mapped_size / MemoryLayout<Element>.stride
            
            if fd == -1 {
                
                let _extended_size = new_mapped_size - mapped_size
                
                let _extended = mmap(UnsafeMutableRawPointer(address) + mapped_size, _extended_size, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE | MAP_FIXED, fd, 0)
                
                if _extended != UnsafeMutableRawPointer(bitPattern: -1) {
                    self.mapped_size = new_mapped_size
                    return
                }
                
                let _address = mmap(nil, new_mapped_size, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE, fd, 0)
                guard _address != UnsafeMutableRawPointer(bitPattern: -1) else { fatalError(String(cString: strerror(errno))) }
                
                let new_buffer = _address!.bindMemory(to: Element.self, capacity: new_capacity)
                
                new_buffer.moveInitialize(from: address, count: count)
                
                munmap(address, mapped_size)
                
                self.mapped_size = new_mapped_size
                self.address = new_buffer
                
            } else {
                
                munmap(address, mapped_size)
                
                self.mapped_size = new_mapped_size
                
                guard ftruncate(self.fd, off_t(new_mapped_size)) != -1 else { fatalError(String(cString: strerror(errno))) }
                
                let _address = mmap(nil, new_mapped_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)
                guard _address != UnsafeMutableRawPointer(bitPattern: -1) else { fatalError(String(cString: strerror(errno))) }
                
                self.address = _address!.bindMemory(to: Element.self, capacity: new_capacity)
            }
        }
    }
}
