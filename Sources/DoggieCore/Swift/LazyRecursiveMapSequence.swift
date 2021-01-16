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
public struct LazyRecursiveMapSequence<C: Collection>: LazySequenceProtocol, IteratorProtocol {
    
    @usableFromInline
    var mapped: AnyIterator<C.Element>
    
    @usableFromInline
    var unmapped: [C.Element]?
    
    @usableFromInline
    var transform: (C.Element) -> C
    
    @inlinable
    init<S: Sequence>(_ base: S, _ transform: @escaping (C.Element) -> C) where S.Element == C.Element {
        self.mapped = AnyIterator(base.makeIterator())
        self.unmapped = base.flatMap(transform)
        self.transform = transform
    }
    
    @inlinable
    public mutating func next() -> C.Element? {
        
        if let element = self.mapped.next() {
            return element
        }
        
        if let unmapped = unmapped {
            self.mapped = AnyIterator(unmapped.makeIterator())
            self.unmapped = unmapped.flatMap(transform)
            self.unmapped = self.unmapped?.isEmpty == false ? self.unmapped : nil
        }
        
        return self.mapped.next()
    }
}

extension LazySequenceProtocol {
    
    @inlinable
    public func recursiveMap<C>(_ transform: @escaping (Element) -> C) -> LazyRecursiveMapSequence<C> where C.Element == Element {
        return LazyRecursiveMapSequence(self, transform)
    }
}
