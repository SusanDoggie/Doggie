//
//  AsyncRecursiveMapSequence.swift
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

#if compiler(>=5.5.2) && canImport(_Concurrency)

@frozen
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct AsyncRecursiveMapSequence<Base: AsyncSequence, Transformed: AsyncSequence>: AsyncSequence where Base.Element == Transformed.Element {
    
    public typealias Element = Base.Element
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: (Base.Element) async -> Transformed
    
    @inlinable
    init(_ base: Base, _ transform: @escaping (Base.Element) async -> Transformed) {
        self.base = base
        self.transform = transform
    }
    
    @inlinable
    public func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(base, transform)
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncRecursiveMapSequence {
    
    @frozen
    public struct AsyncIterator: AsyncIteratorProtocol {
        
        @usableFromInline
        let base: Base
        
        @usableFromInline
        var result: Array<Base.Element>.Iterator?
        
        @usableFromInline
        var mapped: [Base.Element]?
        
        @usableFromInline
        var transform: (Base.Element) async -> Transformed
        
        @inlinable
        init(_ base: Base, _ transform: @escaping (Base.Element) async -> Transformed) {
            self.base = base
            self.transform = transform
        }
        
        @inlinable
        public mutating func next() async rethrows -> Base.Element? {
            
            if self.result == nil {
                let base = try await self.base.collect()
                self.result = base.makeIterator()
                self.mapped = try await base.flatMap(transform).collect()
            }
            
            if let element = self.result!.next() {
                return element
            }
            
            if let mapped = mapped {
                self.result = mapped.makeIterator()
                self.mapped = try await mapped.flatMap(transform).collect()
                self.mapped = self.mapped?.isEmpty == false ? self.mapped : nil
            }
            
            return self.result!.next()
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncSequence {
    
    @inlinable
    public func recursiveMap<C>(_ transform: @escaping (Element) async -> C) -> AsyncRecursiveMapSequence<Self, C> {
        return AsyncRecursiveMapSequence(self, transform)
    }
}

#endif
