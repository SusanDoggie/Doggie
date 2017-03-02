//
//  RangeSet.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public struct RangeSet<Bound : Comparable> {
    
    fileprivate let ranges: [Range<Bound>]
    
    public init() {
        self.ranges = []
    }
    public init(_ ranges: Range<Bound> ... ) {
        self.init(ranges)
    }
    public init<S : Sequence>(_ s: S) where S.Iterator.Element == Range<Bound> {
        self = s.reduce(RangeSet()) { $0.union($1) }
    }
    
    fileprivate init(ranges: [Range<Bound>]) {
        self.ranges = ranges
    }
}

extension RangeSet : RandomAccessCollection {
    
    public var startIndex: Int {
        return ranges.startIndex
    }
    public var endIndex: Int {
        return ranges.endIndex
    }
    
    public subscript(position: Int) -> Range<Bound> {
        return ranges[position]
    }
    
    public func index(before i: Int) -> Int {
        return ranges.index(before: i)
    }
    public func index(after i: Int) -> Int {
        return ranges.index(after: i)
    }
}

extension RangeSet {
    
    public func contains(_ x: Bound) -> Bool {
        return ranges.contains { $0.contains(x) }
    }
}

extension RangeSet {
    
    public func union(_ range: Range<Bound>) -> RangeSet {
        var collect: [Range<Bound>] = []
        var overlap = range
        for r in ranges {
            if overlap.overlaps(r) || overlap.lowerBound == r.upperBound || overlap.upperBound == r.lowerBound {
                overlap = Range(uncheckedBounds: (Swift.min(overlap.lowerBound, r.lowerBound), Swift.max(overlap.upperBound, r.upperBound)))
            } else {
                collect.append(r)
            }
        }
        collect.append(overlap)
        return RangeSet(ranges: collect.sorted { $0.lowerBound < $1.lowerBound })
    }
    
    public func subtracting(_ range: Range<Bound>) -> RangeSet {
        var collect: [Range<Bound>] = []
        for r in ranges {
            if range.overlaps(r) {
                if r.upperBound <= range.upperBound && r.lowerBound < range.lowerBound {
                    collect.append(Range(uncheckedBounds: (r.lowerBound, Swift.min(range.lowerBound, r.upperBound))))
                } else if r.lowerBound >= range.lowerBound && r.upperBound > range.upperBound {
                    collect.append(Range(uncheckedBounds: (Swift.max(range.upperBound, r.lowerBound), r.upperBound)))
                } else if r.lowerBound < range.lowerBound && r.upperBound > range.upperBound {
                    collect.append(Range(uncheckedBounds: (r.lowerBound, range.lowerBound)))
                    collect.append(Range(uncheckedBounds: (range.upperBound, r.upperBound)))
                }
            } else {
                collect.append(r)
            }
        }
        return RangeSet(ranges: collect.sorted { $0.lowerBound < $1.lowerBound })
    }
    
    public func intersection(_ range: Range<Bound>) -> RangeSet {
        var collect: [Range<Bound>] = []
        for r in ranges where range.overlaps(r) {
            collect.append(r.clamped(to: range))
        }
        return RangeSet(ranges: collect.sorted { $0.lowerBound < $1.lowerBound })
    }
}

extension RangeSet {
    
    public func union(_ ranges: RangeSet) -> RangeSet {
        return ranges.ranges.reduce(self) { $0.union($1) }
    }
    public func subtracting(_ ranges: RangeSet) -> RangeSet {
        return ranges.ranges.reduce(self) { $0.subtracting($1) }
    }
    public func intersection(_ ranges: RangeSet) -> RangeSet {
        return ranges.ranges.reduce(self) { $0.intersection($1) }
    }
}
