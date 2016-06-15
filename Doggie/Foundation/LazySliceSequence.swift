//
//  LazySliceSequence.swift
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

public extension RandomAccessCollection {
    
    func slice(by maxLength: IndexDistance) -> [SubSequence] {
        return Array(self.lazy.slice(by: maxLength))
    }
}

public struct LazySliceSequence<Base : RandomAccessCollection> : IteratorProtocol, LazySequenceProtocol {
    
    private let base: Base
    private let maxLength: Base.IndexDistance
    private var currentIndex: Base.Index
    
    public mutating func next() -> Base.SubSequence? {
        
        if currentIndex != base.endIndex {
            let nextIndex = base.index(currentIndex, offsetBy: maxLength, limitedBy: base.endIndex) ?? base.endIndex
            let result = base[currentIndex..<nextIndex]
            currentIndex = nextIndex
            return result
        }
        return nil
    }
}

public extension LazyCollectionProtocol where Elements : RandomAccessCollection {
    
    func slice(by maxLength: Elements.IndexDistance) -> LazySliceSequence<Elements> {
        return LazySliceSequence(base: elements, maxLength: maxLength, currentIndex: elements.startIndex)
    }
}
