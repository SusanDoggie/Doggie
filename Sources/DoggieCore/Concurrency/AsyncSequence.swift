//
//  AsyncSequence.swift
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

#if compiler(>=5.5) && canImport(_Concurrency)

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension AsyncSequence {
    
    @inlinable
    func collect() async rethrows -> [Element] {
        return try await self.reduce(into: []) { $0.append($1) }
    }
}

@frozen
@usableFromInline
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
struct _AsyncSequenceBox<S: Sequence>: AsyncSequence {
    
    @usableFromInline
    typealias Element = S.Element
    
    @usableFromInline
    let base: S
    
    @inlinable
    init(_ base: S) {
        self.base = base
    }
    
    @inlinable
    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(base)
    }
    
    @frozen
    @usableFromInline
    struct AsyncIterator: AsyncIteratorProtocol {
        
        @usableFromInline
        var base: S.Iterator
        
        @inlinable
        init(_ base: S) {
            self.base = base.makeIterator()
        }
        
        @inlinable
        mutating func next() async -> S.Element? {
            return self.base.next()
        }
    }
}

@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
extension Sequence {
    
    @inlinable
    func map<T>(_ transform: @escaping (Element) async -> T) -> AsyncMapSequence<_AsyncSequenceBox<Self>, T> {
        return _AsyncSequenceBox(self).map(transform)
    }
    
    @inlinable
    func map<T>(_ transform: @escaping (Element) async throws -> T) -> AsyncThrowingMapSequence<_AsyncSequenceBox<Self>, T> {
        return _AsyncSequenceBox(self).map(transform)
    }
    
    @inlinable
    func filter(_ isIncluded: @escaping (Element) async -> Bool) -> AsyncFilterSequence<_AsyncSequenceBox<Self>> {
        return _AsyncSequenceBox(self).filter(isIncluded)
    }
    
    @inlinable
    func filter(_ isIncluded: @escaping (Element) async throws -> Bool) -> AsyncThrowingFilterSequence<_AsyncSequenceBox<Self>> {
        return _AsyncSequenceBox(self).filter(isIncluded)
    }
    
    @inlinable
    func flatMap<SegmentOfResult: AsyncSequence>(_ transform: @escaping (Element) async -> SegmentOfResult) -> AsyncFlatMapSequence<_AsyncSequenceBox<Self>, SegmentOfResult> {
        return _AsyncSequenceBox(self).flatMap(transform)
    }
    
    @inlinable
    func flatMap<SegmentOfResult: AsyncSequence>(_ transform: @escaping (Element) async throws -> SegmentOfResult) -> AsyncThrowingFlatMapSequence<_AsyncSequenceBox<Self>, SegmentOfResult> {
        return _AsyncSequenceBox(self).flatMap(transform)
    }
    
    @inlinable
    func compactMap<ElementOfResult>(_ transform: @escaping (Element) async -> ElementOfResult?) -> AsyncCompactMapSequence<_AsyncSequenceBox<Self>, ElementOfResult> {
        return _AsyncSequenceBox(self).compactMap(transform)
    }
    
    @inlinable
    func compactMap<ElementOfResult>(_ transform: @escaping (Element) async throws -> ElementOfResult?) -> AsyncThrowingCompactMapSequence<_AsyncSequenceBox<Self>, ElementOfResult> {
        return _AsyncSequenceBox(self).compactMap(transform)
    }
    
}

#endif
