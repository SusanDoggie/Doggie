//
//  AsyncRecursiveMapSequence.swift
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

#if compiler(>=5.5.2) && canImport(_Concurrency)

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncSequence {
    
    @inlinable
    public func recursiveMap<C>(_ transform: @Sendable @escaping (Element) async -> C) -> AsyncRecursiveMapSequence<Self, C> {
        return AsyncRecursiveMapSequence(self, transform)
    }
}

@frozen
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct AsyncRecursiveMapSequence<Base: AsyncSequence, Transformed: AsyncSequence>: AsyncSequence where Base.Element == Transformed.Element {
    
    public typealias Element = Base.Element
    
    @usableFromInline
    let base: Base
    
    @usableFromInline
    let transform: @Sendable (Base.Element) async -> Transformed
    
    @inlinable
    init(_ base: Base, _ transform: @Sendable @escaping (Base.Element) async -> Transformed) {
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
        var base: Base.AsyncIterator?
        
        @usableFromInline
        var mapped: ArraySlice<Transformed> = []
        
        @usableFromInline
        var mapped_iterator: Transformed.AsyncIterator?
        
        @usableFromInline
        var transform: @Sendable (Base.Element) async -> Transformed
        
        @inlinable
        init(_ base: Base, _ transform: @Sendable @escaping (Base.Element) async -> Transformed) {
            self.base = base.makeAsyncIterator()
            self.transform = transform
        }
        
        @inlinable
        public mutating func next() async rethrows -> Base.Element? {
            
            if self.base != nil {
                
                if let element = try await self.base?.next() {
                    await mapped.append(transform(element))
                    return element
                }
                
                self.base = nil
                self.mapped_iterator = mapped.popFirst()?.makeAsyncIterator()
            }
            
            while self.mapped_iterator != nil {
                
                if let element = try await self.mapped_iterator?.next() {
                    await mapped.append(transform(element))
                    return element
                }
                
                self.mapped_iterator = mapped.popFirst()?.makeAsyncIterator()
            }
            
            return nil
        }
    }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncRecursiveMapSequence: Sendable where Base: Sendable, Base.Element: Sendable, Transformed: Sendable { }

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension AsyncRecursiveMapSequence.AsyncIterator: Sendable
where Base.AsyncIterator: Sendable, Base.Element: Sendable, Transformed: Sendable, Transformed.AsyncIterator: Sendable { }

#endif
