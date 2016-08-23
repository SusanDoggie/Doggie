//
//  _CollectionFix.swift
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


// https://github.com/apple/swift/blob/master/stdlib/public/core/WriteBackMutableSlice.swift
internal func _writeBackMutableSlice<C, Slice_>(
    _ self_: inout C, bounds: Range<C.Index>, slice: Slice_
    ) where
    C : MutableCollection,
    Slice_ : Collection,
    C._Element == Slice_.Iterator.Element,
    C.Index == Slice_.Index {
        
        self_._failEarlyRangeCheck(bounds, bounds: self_.startIndex..<self_.endIndex)
        
        // FIXME(performance): can we use
        // _withUnsafeMutableBufferPointerIfSupported?  Would that create inout
        // aliasing violations if the newValue points to the same buffer?
        
        var selfElementIndex = bounds.lowerBound
        let selfElementsEndIndex = bounds.upperBound
        var newElementIndex = slice.startIndex
        let newElementsEndIndex = slice.endIndex
        
        while selfElementIndex != selfElementsEndIndex &&
            newElementIndex != newElementsEndIndex {
                
                self_[selfElementIndex] = slice[newElementIndex]
                self_.formIndex(after: &selfElementIndex)
                slice.formIndex(after: &newElementIndex)
        }
        
        _precondition(
            selfElementIndex == selfElementsEndIndex,
            "Cannot replace a slice of a MutableCollection with a slice of a smaller size")
        _precondition(
            newElementIndex == newElementsEndIndex,
            "Cannot replace a slice of a MutableCollection with a slice of a larger size")
}
