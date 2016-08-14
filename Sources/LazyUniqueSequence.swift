//
//  LazyUniqueSequence.swift
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

public struct LazyUniqueIterator<Base : IteratorProtocol> : IteratorProtocol, Sequence {
    
    fileprivate var pass: ContiguousArray<Base.Element>
    fileprivate var base: Base
    fileprivate let isEquivalent: (Base.Element, Base.Element) -> Bool
    
    public mutating func next() -> Base.Element? {
        while let val = base.next() {
            if !pass.contains(where: { isEquivalent($0, val) }) {
                pass.append(val)
                return val
            }
        }
        return nil
    }
}

public struct LazyUniqueSequence<Base : Sequence> : LazySequenceProtocol {
    
    fileprivate let base: Base
    fileprivate let isEquivalent: (Base.Iterator.Element, Base.Iterator.Element) -> Bool
    
    public func makeIterator() -> LazyUniqueIterator<Base.Iterator> {
        var pass = ContiguousArray<Base.Iterator.Element>()
        pass.reserveCapacity(base.underestimatedCount)
        return LazyUniqueIterator(pass: pass, base: base.makeIterator(), isEquivalent: isEquivalent)
    }
}

public extension Sequence where Iterator.Element : Equatable {
    
    func unique() -> [Iterator.Element] {
        return self.unique(where: ==)
    }
}

public extension Sequence {
    
    func unique(where isEquivalent: (Iterator.Element, Iterator.Element) throws -> Bool) rethrows -> [Iterator.Element] {
        var result = ContiguousArray<Iterator.Element>()
        result.reserveCapacity(self.underestimatedCount)
        for item in self where try !result.contains(where: { try isEquivalent($0, item) }) {
            result.append(item)
        }
        return Array(result)
    }
}

public extension LazySequenceProtocol where Elements.Iterator.Element : Equatable {
    
    func unique() -> LazyUniqueSequence<Elements> {
        return LazyUniqueSequence(base: elements, isEquivalent: ==)
    }
}

public extension LazySequenceProtocol {
    
    func unique(where isEquivalent: @escaping (Elements.Iterator.Element, Elements.Iterator.Element) -> Bool) -> LazyUniqueSequence<Elements> {
        return LazyUniqueSequence(base: elements, isEquivalent: isEquivalent)
    }
}
