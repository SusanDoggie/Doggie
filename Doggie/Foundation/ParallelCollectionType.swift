//
//  ParallelCollectionType.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

extension CollectionType where Index : RandomAccessIndexType {
    
    public var parallel: ParallelCollection<Self> {
        return ParallelCollection(self)
    }
}

public protocol ParallelCollectionType : CollectionType {
    
    typealias Index : RandomAccessIndexType
}

extension ParallelCollectionType {
    /// Identical to `self`.
    public var parallel: Self {
        return self
    }
}

extension ParallelCollectionType {
    
    /// Call `body` on each element in `self` in parallel
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    public func forEach(body: (Generator.Element) -> ()) {
        let queue = dispatch_queue_create("com.SusanDoggie.CollectionType.Parallel", DISPATCH_QUEUE_CONCURRENT)
        self.forEach(queue, body: body)
    }
    
    /// Call `body` on each element in `self` in parallel with specific queue
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    public func forEach(queue: dispatch_queue_t, body: (Generator.Element) -> ()) {
        let _startIndex = self.startIndex
        dispatch_apply(numericCast(self.count), queue) {
            body(self[_startIndex.advancedBy(numericCast($0))])
        }
    }
}

extension ParallelCollectionType {
    
    public var array : [Generator.Element] {
        let count: Int = numericCast(self.count)
        let buffer = UnsafeMutablePointer<Generator.Element>.alloc(count)
        let queue = dispatch_queue_create("com.SusanDoggie.CollectionType.Parallel", DISPATCH_QUEUE_CONCURRENT)
        let _startIndex = self.startIndex
        dispatch_apply(numericCast(self.count), queue) {
            (buffer + $0).initialize(self[_startIndex.advancedBy(numericCast($0))])
        }
        let result = Array(UnsafeMutableBufferPointer(start: buffer, count: count))
        buffer.destroy(count)
        buffer.dealloc(count)
        return result
    }
}

public struct ParallelCollection<Base: CollectionType where Base.Index : RandomAccessIndexType> : ParallelCollectionType {
    
    private let base: Base
    
    public typealias Generator = ParallelCollectionGenerator<Base.Generator>
    
    public typealias Index = Base.Index
    
    public init(_ base: Base) {
        self.base = base
    }
    
    public var startIndex : Index {
        return base.startIndex
    }
    public var endIndex : Index {
        return base.endIndex
    }
    
    public var count : Index.Distance {
        return self.base.count
    }
    
    public subscript(position: Index) -> Base.Generator.Element {
        return base[position]
    }
    
    public func generate() -> Generator {
        return ParallelCollectionGenerator(base: base.generate())
    }
}

public struct ParallelCollectionGenerator<Base: GeneratorType> : GeneratorType, SequenceType {
    
    private var base: Base
    
    public mutating func next() -> Base.Element? {
        return base.next()
    }
}

public struct ParallelMapCollection<Base: CollectionType, Element where Base.Index : RandomAccessIndexType> : ParallelCollectionType {
    
    private let base: Base
    private let transform: (Base.Generator.Element) -> Element
    
    public typealias Generator = ParallelMapCollectionGenerator<Base.Generator, Element>
    
    public typealias Index = Base.Index
    
    public init(_ base: Base, transform: (Base.Generator.Element) -> Element) {
        self.base = base
        self.transform = transform
    }
    
    public var startIndex : Index {
        return base.startIndex
    }
    public var endIndex : Index {
        return base.endIndex
    }
    
    public var count : Index.Distance {
        return self.base.count
    }
    
    public subscript(position: Index) -> Element {
        return transform(base[position])
    }
    
    public func generate() -> Generator {
        return ParallelMapCollectionGenerator(base: base.generate(), transform: transform)
    }
}

public struct ParallelMapCollectionGenerator<Base: GeneratorType, Element> : GeneratorType, SequenceType {
    
    private var base: Base
    private let transform: (Base.Element) -> Element
    
    public mutating func next() -> Element? {
        return base.next().map(transform)
    }
}

extension ParallelCollectionType {
    
    public func map<T>(transform: (Generator.Element) -> T) -> ParallelMapCollection<Self, T> {
        return ParallelMapCollection(self, transform: transform)
    }
}