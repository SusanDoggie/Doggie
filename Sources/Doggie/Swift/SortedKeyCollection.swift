//
//  SortedKeyCollection.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public protocol SortedKeyCollection : KeyValueCollection, RandomAccessCollection where Key: Comparable {
    
}

extension SortedKeyCollection {
    
    @inlinable
    public func index(forKey key: Key) -> Index? {
        
        var lowerBound = startIndex
        var upperBound = endIndex
        var count = distance(from: lowerBound, to: upperBound)
        
        while count != 0 {
            
            guard let mid = index(lowerBound, offsetBy: count >> 1, limitedBy: upperBound) else { return nil }
            let current = self[mid].key
            
            if key == current {
                return mid
            }
            
            if key < current {
                upperBound = mid
            } else {
                lowerBound = index(after: mid)
            }
            
            count = distance(from: lowerBound, to: upperBound)
        }
        
        return nil
    }
}
