//
//  LazyRecursiveMapSequence.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
    public func recursiveMap<S: Sequence>(_ transform: (Element) throws -> S) rethrows -> [Element] where S.Element == Element {
        var result: [Element] = Array(self)
        var mapped = try result.flatMap(transform)
        repeat {
            result.append(contentsOf: mapped)
            mapped = try mapped.flatMap(transform)
        } while !mapped.isEmpty
        return result
    }
}

@frozen
public struct LazyRecursiveMapSequence<Base: Sequence, Transformed: Sequence>: LazySequenceProtocol where Base.Element == Transformed.Element {
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: (Base.Element) -> Transformed
    
    @inlinable
    init(_ base: Base, _ transform: @escaping (Base.Element) -> Transformed) {
        self.base = base
        self.transform = transform
    }
    
    @inlinable
    public func makeIterator() -> Iterator {
        return Iterator(base, transform)
    }
}

extension LazyRecursiveMapSequence {
    
    @frozen
    public struct Iterator: IteratorProtocol {
        
        @usableFromInline
        var base: Base.Iterator?
        
        @usableFromInline
        var mapped: ArraySlice<Transformed> = []
        
        @usableFromInline
        var mapped_iterator: Transformed.Iterator?
        
        @usableFromInline
        var transform: (Base.Element) -> Transformed
        
        @inlinable
        init(_ base: Base, _ transform: @escaping (Base.Element) -> Transformed) {
            self.base = base.makeIterator()
            self.transform = transform
        }
        
        @inlinable
        public mutating func next() -> Base.Element? {
            
            if self.base != nil {
                
                if let element = self.base?.next() {
                    mapped.append(transform(element))
                    return element
                }
                
                self.base = nil
                self.mapped_iterator = mapped.popFirst()?.makeIterator()
            }
            
            while self.mapped_iterator != nil {
                
                if let element = self.mapped_iterator?.next() {
                    mapped.append(transform(element))
                    return element
                }
                
                self.mapped_iterator = mapped.popFirst()?.makeIterator()
            }
            
            return nil
        }
    }
}

extension LazySequenceProtocol {
    
    @inlinable
    public func recursiveMap<S>(_ transform: @escaping (Element) -> S) -> LazyRecursiveMapSequence<Elements, S> {
        return LazyRecursiveMapSequence(self.elements, transform)
    }
}
