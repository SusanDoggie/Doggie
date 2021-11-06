//
//  LazyRecursiveMapSequence.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

extension Sequence {
    
    @inlinable
    public func recursiveMap<C: Collection>(_ transform: (Element) throws -> C) rethrows -> [Element] where C.Element == Element {
        var result: [Element] = Array(self)
        var unmapped = try result.flatMap(transform)
        repeat {
            result.append(contentsOf: unmapped)
            unmapped = try unmapped.flatMap(transform)
        } while !unmapped.isEmpty
        return result
    }
}

@frozen
public struct LazyRecursiveMapSequence<Base: Sequence, Transformed: Collection>: LazySequenceProtocol, IteratorProtocol where Base.Element == Transformed.Element {
    
    @usableFromInline
    var mapped: EitherIterator
    
    @usableFromInline
    var unmapped: [Base.Element]?
    
    @usableFromInline
    var transform: (Base.Element) -> Transformed
    
    @inlinable
    init(_ base: Base, _ transform: @escaping (Base.Element) -> Transformed) {
        self.mapped = EitherIterator(base: base.makeIterator())
        self.unmapped = base.flatMap(transform)
        self.transform = transform
    }
    
    @inlinable
    public mutating func next() -> Base.Element? {
        
        if let element = self.mapped.next() {
            return element
        }
        
        if let unmapped = unmapped {
            self.mapped = EitherIterator(transformed: unmapped.makeIterator())
            self.unmapped = unmapped.flatMap(transform)
            self.unmapped = self.unmapped?.isEmpty == false ? self.unmapped : nil
        }
        
        return self.mapped.next()
    }
}

extension LazyRecursiveMapSequence {
    
    @frozen
    @usableFromInline
    struct EitherIterator: IteratorProtocol {
        
        @usableFromInline
        var base: Base.Iterator?
        
        @usableFromInline
        var transformed: Array<Base.Element>.Iterator?
        
        @usableFromInline
        init(base: Base.Iterator? = nil, transformed: Array<Base.Element>.Iterator? = nil) {
            self.base = base
            self.transformed = transformed
        }
        
        @inlinable
        mutating func next() -> Base.Element? {
            return base?.next() ?? transformed?.next()
        }
    }
}

extension LazySequenceProtocol {
    
    @inlinable
    public func recursiveMap<C>(_ transform: @escaping (Element) -> C) -> LazyRecursiveMapSequence<Elements, C> {
        return LazyRecursiveMapSequence(self.elements, transform)
    }
}
