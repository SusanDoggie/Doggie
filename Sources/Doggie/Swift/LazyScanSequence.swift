//
//  LazyScanSequence.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

extension Sequence {
    /// Returns an array containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     (1..<6).scan(0, +) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(N)
    @inlinable
    public func scan<R>(_ initial: R, _ combine: (R, Element) throws -> R) rethrows -> [R] {
        var last = initial
        var result = [initial]
        result.reserveCapacity(self.underestimatedCount + 1)
        for x in self {
            let next = try combine(last, x)
            result.append(next)
            last = next
        }
        return result
    }
}

@frozen
public struct LazyScanIterator<Base: IteratorProtocol, Element> : IteratorProtocol, Sequence {
    
    @usableFromInline
    var nextElement: Element?
    
    @usableFromInline
    var base: Base
    
    @usableFromInline
    let combine: (Element, Base.Element) -> Element
    
    @inlinable
    init(nextElement: Element?, base: Base, combine: @escaping (Element, Base.Element) -> Element) {
        self.nextElement = nextElement
        self.base = base
        self.combine = combine
    }
    
    @inlinable
    public mutating func next() -> Element? {
        return nextElement.map { result in
            nextElement = base.next().map { combine(result, $0) }
            return result
        }
    }
}

@frozen
public struct LazyScanSequence<Base: Sequence, Element> : LazySequenceProtocol {
    
    public let initial: Element
    
    public let base: Base
    
    public let combine: (Element, Base.Element) -> Element
    
    @inlinable
    public init(initial: Element, base: Base, combine: @escaping (Element, Base.Element) -> Element) {
        self.initial = initial
        self.base = base
        self.combine = combine
    }
    
    @inlinable
    public func makeIterator() -> LazyScanIterator<Base.Iterator, Element> {
        return LazyScanIterator(nextElement: initial, base: base.makeIterator(), combine: combine)
    }
    
    @inlinable
    public var underestimatedCount: Int {
        return base.underestimatedCount + 1
    }
}

extension LazySequenceProtocol {
    /// Returns a sequence containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     Array((1..<6).lazy.scan(0, +)) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(1)
    @inlinable
    public func scan<R>(_ initial: R, _ combine: @escaping (R, Elements.Element) -> R) -> LazyScanSequence<Elements, R> {
        return LazyScanSequence(initial: initial, base: self.elements, combine: combine)
    }
}
