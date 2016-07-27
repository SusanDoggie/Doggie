//
//  LazyScanSequence.swift
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

public extension Sequence {
    /// Returns an array containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     (1..<6).scan(0, combine: +) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(N)
    func scan<R>(initial: R, combine: @noescape (R, Iterator.Element) throws -> R) rethrows -> [R] {
        var result = [initial]
        for x in self {
            result.append(try combine(result.last!, x))
        }
        return result
    }
}

public struct LazyScanIterator<Base: IteratorProtocol, Element> : IteratorProtocol, Sequence {
    
    private var nextElement: Element?
    private var base: Base
    private let combine: (Element, Base.Element) -> Element
    
    public mutating func next() -> Element? {
        return nextElement.map { result in
            nextElement = base.next().map { combine(result, $0) }
            return result
        }
    }
}

public struct LazyScanSequence<Base: Sequence, Element> : LazySequenceProtocol {
    
    private let initial: Element
    private let base: Base
    private let combine: (Element, Base.Iterator.Element) -> Element
    
    public func makeIterator() -> LazyScanIterator<Base.Iterator, Element> {
        return LazyScanIterator(nextElement: initial, base: base.makeIterator(), combine: combine)
    }
}

public extension LazySequenceProtocol {
    /// Returns a sequence containing the results of
    ///
    ///   p.reduce(initial, combine: combine)
    ///
    /// for each prefix `p` of `self`, in order from shortest to
    /// longest.  For example:
    ///
    ///     Array((1..<6).lazy.scan(0, combine: +)) // [0, 1, 3, 6, 10, 15]
    ///
    /// - complexity: O(1)
    func scan<R>(initial: R, combine: (R, Elements.Iterator.Element) -> R) -> LazyScanSequence<Elements, R> {
        return LazyScanSequence(initial: initial, base: self.elements, combine: combine)
    }
}
