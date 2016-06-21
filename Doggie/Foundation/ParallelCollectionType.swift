//
//  ParallelCollection.swift
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

extension RandomAccessCollection {
    
    public var parallel: ParallelCollection<Self> {
        return ParallelCollection(self)
    }
}

public protocol ParallelCollectionProtocol : RandomAccessCollection {
    
}

extension ParallelCollectionProtocol {
    /// Identical to `self`.
    public var parallel: Self {
        return self
    }
}

extension ParallelCollectionProtocol {
    
    /// Call `body` on each element in `self` in parallel
    ///
    /// - Note: You cannot use the `break` or `continue` statement to exit the
    ///   current call of the `body` closure or skip subsequent calls.
    /// - Note: Using the `return` statement in the `body` closure will only
    ///   exit from the current call to `body`, not any outer scope, and won't
    ///   skip subsequent calls.
    public func forEach(body: (Iterator.Element) -> ()) {
        DispatchQueue.concurrentPerform(iterations: numericCast(self.count)) {
            body(self[self.index(startIndex, offsetBy: numericCast($0))])
        }
    }
}

extension ParallelCollectionProtocol {
    
    public var array : [Iterator.Element] {
        let count: Int = numericCast(self.count)
        let buffer = UnsafeMutablePointer<Iterator.Element>(allocatingCapacity: count)
        DispatchQueue.concurrentPerform(iterations: numericCast(self.count)) {
            (buffer + $0).initialize(with: self[self.index(startIndex, offsetBy: numericCast($0))])
        }
        let result = Array(UnsafeMutableBufferPointer(start: buffer, count: count))
        buffer.deinitialize(count: count)
        buffer.deallocateCapacity(count)
        return result
    }
}

public struct ParallelCollection<Base: RandomAccessCollection> : ParallelCollectionProtocol {
    
    private let base: Base
    
    public typealias Iterator = ParallelCollectionIterator<Base.Iterator>
    
    public typealias Index = Base.Index
    public typealias IndexDistance = Base.IndexDistance
    
    public init(_ base: Base) {
        self.base = base
    }
    
    public var startIndex : Index {
        return base.startIndex
    }
    public var endIndex : Index {
        return base.endIndex
    }
    
    public var count : Base.IndexDistance {
        return self.base.count
    }
    
    public func index(after i: Index) -> Index {
        return self.base.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return self.base.index(before: i)
    }
    
    public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
        return self.base.index(i, offsetBy: n)
    }
    
    public func distance(from start: Index, to end: Index) -> IndexDistance {
        return self.base.distance(from: start, to: end)
    }
    
    public subscript(position: Index) -> Base.Iterator.Element {
        return base[position]
    }
    
    public func makeIterator() -> Iterator {
        return ParallelCollectionIterator(base: base.makeIterator())
    }
}

public struct ParallelCollectionIterator<Base: IteratorProtocol> : IteratorProtocol, Sequence {
    
    private var base: Base
    
    public mutating func next() -> Base.Element? {
        return base.next()
    }
}

public struct ParallelMapCollection<Base: RandomAccessCollection, Element> : ParallelCollectionProtocol {
    
    private let base: Base
    private let transform: (Base.Iterator.Element) -> Element
    
    public typealias Iterator = ParallelMapCollectionIterator<Base.Iterator, Element>
    
    public typealias Index = Base.Index
    public typealias IndexDistance = Base.IndexDistance
    
    public init(_ base: Base, transform: (Base.Iterator.Element) -> Element) {
        self.base = base
        self.transform = transform
    }
    
    public var startIndex : Index {
        return base.startIndex
    }
    public var endIndex : Index {
        return base.endIndex
    }
    
    public var count : Base.IndexDistance {
        return self.base.count
    }
    
    public func index(after i: Index) -> Index {
        return self.base.index(after: i)
    }
    
    public func index(before i: Index) -> Index {
        return self.base.index(before: i)
    }
    
    public func index(_ i: Index, offsetBy n: IndexDistance) -> Index {
        return self.base.index(i, offsetBy: n)
    }
    
    public func distance(from start: Index, to end: Index) -> IndexDistance {
        return self.base.distance(from: start, to: end)
    }
    
    public subscript(position: Index) -> Element {
        return transform(base[position])
    }
    
    public func makeIterator() -> Iterator {
        return ParallelMapCollectionIterator(base: base.makeIterator(), transform: transform)
    }
}

public struct ParallelMapCollectionIterator<Base: IteratorProtocol, Element> : IteratorProtocol, Sequence {
    
    private var base: Base
    private let transform: (Base.Element) -> Element
    
    public mutating func next() -> Element? {
        return base.next().map(transform)
    }
}

extension ParallelCollectionProtocol {
    
    public func map<T>(transform: (Iterator.Element) -> T) -> ParallelMapCollection<Self, T> {
        return ParallelMapCollection(self, transform: transform)
    }
}
