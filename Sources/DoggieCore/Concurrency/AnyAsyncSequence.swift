//
//  AnyAsyncSequence.swift
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

@frozen
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public struct AnyAsyncSequence<Element>: AsyncSequence {
    
    public typealias AsyncIterator = AnyAsyncIterator<Element>
    
    public typealias Element = Element
    
    @usableFromInline
    let _makeAsyncIterator: () -> AnyAsyncIterator<Element>
    
    @inlinable
    public init<S: AsyncSequence>(_ base: S) where S.Element == Element {
        self._makeAsyncIterator = { AnyAsyncIterator(base.makeAsyncIterator()) }
    }
    
    @inlinable
    public func makeAsyncIterator() -> AnyAsyncIterator<Element> {
        return _makeAsyncIterator()
    }
}

@frozen
@available(macOS 12, iOS 15, watchOS 8, tvOS 15, *)
public struct AnyAsyncIterator<Element>: AsyncIteratorProtocol {
    
    public typealias Element = Element
    
    @usableFromInline
    let _next: () async throws -> Element?
    
    @inlinable
    public init<I: AsyncIteratorProtocol>(_ base: I) where I.Element == Element {
        var base = base
        self._next = { try await base.next() }
    }
    
    @inlinable
    public mutating func next() async throws -> Element? {
        return try await _next()
    }
}

#endif
