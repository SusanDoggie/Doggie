//
//  CountableSet.swift
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

public struct CountableSet<Element : Comparable> where Element : Strideable, Element.Stride : SignedInteger {
    
    fileprivate var ranges: [CountableClosedRange<Element>]
    
    public init() {
        self.ranges = []
    }
    
    public init(_ elements: Range<Element>) {
        self.ranges = [CountableClosedRange(elements)]
    }
    public init(_ elements: ClosedRange<Element>) {
        self.ranges = [CountableClosedRange(elements)]
    }
    public init(_ elements: CountableRange<Element>) {
        self.ranges = [CountableClosedRange(elements)]
    }
    public init(_ elements: CountableClosedRange<Element>) {
        self.ranges = [elements]
    }
    public init<S : Sequence>(_ elements: S) where S.Iterator.Element == Element {
        self.ranges = []
        self.insert(elements)
    }
}

extension CountableSet : ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element ... ) {
        self.init(elements)
    }
}

public struct CountableSetIterator<Element : Comparable> : IteratorProtocol, Sequence where Element : Strideable, Element.Stride : SignedInteger {
    
    fileprivate var base: FlattenIterator<IndexingIterator<Array<CountableClosedRange<Element>>>>
    
    public mutating func next() -> Element? {
        return base.next()
    }
}

public struct CountableSetIndex<Element : Comparable> : Comparable where Element : Strideable, Element.Stride : SignedInteger {
    
    fileprivate let base: FlattenBidirectionalCollectionIndex<[CountableClosedRange<Element>]>
}

public func == <Element>(lhs: CountableSetIndex<Element>, rhs: CountableSetIndex<Element>) -> Bool {
    return lhs.base == rhs.base
}
public func < <Element>(lhs: CountableSetIndex<Element>, rhs: CountableSetIndex<Element>) -> Bool {
    return lhs.base < rhs.base
}

extension CountableSet : BidirectionalCollection {
    
    public var startIndex : CountableSetIndex<Element> {
        return CountableSetIndex(base: ranges.joined().startIndex)
    }
    public var endIndex : CountableSetIndex<Element> {
        return CountableSetIndex(base: ranges.joined().endIndex)
    }
    
    public func index(after i: CountableSetIndex<Element>) -> CountableSetIndex<Element> {
        return CountableSetIndex(base: ranges.joined().index(after: i.base))
    }
    
    public func index(before i: CountableSetIndex<Element>) -> CountableSetIndex<Element> {
        return CountableSetIndex(base: ranges.joined().index(before: i.base))
    }
    
    public subscript(position: CountableSetIndex<Element>) -> Element {
        return ranges.joined()[position.base]
    }
    
    public func makeIterator() -> CountableSetIterator<Element> {
        return CountableSetIterator(base: ranges.joined().makeIterator())
    }
}

extension CountableSet: CustomStringConvertible {
    
    public var description: String {
        var result = "["
        var first = true
        for item in self {
            if first {
                first = false
            } else {
                result += ", "
            }
            result += "\(item)"
        }
        result += "]"
        return result
    }
}
private extension CountableSet {
    
    func search(_ target: Element, _ indices: CountableRange<Int>) -> (Bool, Int) {
        switch ranges.count {
        case 0: return (false, indices.lowerBound)
        default:
            let mid = (indices.lowerBound + indices.upperBound) >> 1
            if indices.upperBound == mid {
                return (false, indices.upperBound)
            } else if ranges[mid].contains(target) {
                return (true, mid)
            } else if target < ranges[mid].lowerBound {
                if indices.lowerBound == mid {
                    return (false, indices.lowerBound)
                } else if target > ranges[mid - 1].upperBound {
                    return (false, mid)
                } else {
                    return search(target, indices.lowerBound..<mid)
                }
            } else {
                if indices.upperBound == mid + 1 {
                    return (false, indices.upperBound)
                } else if target < ranges[mid + 1].lowerBound {
                    return (false, mid)
                } else {
                    return search(target, mid + 1..<indices.upperBound)
                }
            }
        }
    }
    
    func search(_ target: Element) -> (Bool, Int) {
        return search(target, ranges.indices)
    }
}

public extension CountableSet {
    
    func contains(_ member: Element) -> Bool {
        return search(member).0
    }
    
    mutating func insert(_ newMember: Element) {
        let (flag, index) = search(newMember)
        if !flag {
            let join_left = index > 0 && ranges[index - 1].upperBound == newMember - 1
            let join_right = index < ranges.count && ranges[index].lowerBound == newMember + 1
            if join_left && join_right {
                ranges.replaceSubrange(index - 1...index, with: CollectionOfOne(ranges[index - 1].lowerBound...ranges[index].upperBound))
            } else if join_left {
                ranges[index - 1] = ranges[index - 1].lowerBound...newMember
            } else if join_right {
                ranges[index] = newMember...ranges[index].upperBound
            } else {
                ranges.insert(newMember...newMember, at: index)
            }
        }
    }
    
    mutating func remove(_ member: Element) {
        let (flag, index) = search(member)
        if flag {
            if ranges[index].count == 1 {
                ranges.remove(at: index)
            } else if ranges[index].lowerBound == member {
                ranges[index] = ranges[index].lowerBound + 1...ranges[index].upperBound
            } else if ranges[index].upperBound == member {
                ranges[index] = ranges[index].lowerBound...ranges[index].upperBound - 1
            } else {
                let left = ranges[index].lowerBound...member - 1
                let right = member + 1...ranges[index].upperBound
                ranges.replaceSubrange(index...index, with: [left, right])
            }
        }
    }
    
    mutating func insert(_ newMembers: CountableClosedRange<Element>) {
        if newMembers.count == 0 {
            return
        }
        let (flag1, index1) = search(newMembers.lowerBound)
        let (flag2, index2) = search(newMembers.upperBound)
        let join_left = index1 > 0 && ranges[index1 - 1].upperBound == newMembers.lowerBound - 1
        let join_right = index2 < ranges.count && ranges[index2].lowerBound == newMembers.upperBound + 1
        if join_left && join_right {
            ranges.replaceSubrange(index1 - 1...index2, with: CollectionOfOne(ranges[index1 - 1].lowerBound...ranges[index2].upperBound))
        } else if join_left {
            if flag2 {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(ranges[index1].lowerBound...ranges[index2].upperBound))
            } else {
                ranges.replaceSubrange(index1 - 1..<index2, with: CollectionOfOne(ranges[index1 - 1].lowerBound...newMembers.upperBound))
            }
        } else if join_right {
            if flag1 {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(ranges[index1].lowerBound...ranges[index2].upperBound))
            } else {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(newMembers.lowerBound...ranges[index2].upperBound))
            }
        } else {
            ranges.replaceSubrange(index1..<index2, with: CollectionOfOne(newMembers))
        }
    }
    
    mutating func remove(_ members: CountableClosedRange<Element>) {
        if members.count == 0 {
            return
        }
        let (flag1, index1) = search(members.lowerBound)
        let (flag2, index2) = search(members.upperBound)
        let t1 = ranges[index1].lowerBound == members.lowerBound
        let t2 = ranges[index2].upperBound == members.upperBound
        if flag1 && flag2 {
            if t1 && t2 {
                ranges.removeSubrange(index1...index2)
            } else if t1 {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(members.upperBound + 1...ranges[index2].upperBound))
            } else if t2 {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(ranges[index1].lowerBound...members.lowerBound - 1))
            } else {
                let left = ranges[index1].lowerBound...members.lowerBound - 1
                let right = members.upperBound + 1...ranges[index2].upperBound
                ranges.replaceSubrange(index1...index2, with: [left, right])
            }
        } else if flag1 {
            if t1 {
                ranges.removeSubrange(index1...index2)
            } else {
                ranges.replaceSubrange(index1..<index2, with: CollectionOfOne(ranges[index1].lowerBound...members.lowerBound - 1))
            }
        } else if flag2 {
            if t2 {
                ranges.removeSubrange(index1...index2)
            } else {
                ranges.replaceSubrange(index1...index2, with: CollectionOfOne(members.upperBound + 1...ranges[index2].upperBound))
            }
        } else {
            ranges.replaceSubrange(index1..<index2, with: CollectionOfOne(members))
        }
    }
}

public extension CountableSet {
    
    mutating func insert(_ other: CountableSet) {
        for range in other.ranges {
            self.insert(range)
        }
    }
    mutating func remove(_ other: CountableSet) {
        for range in other.ranges {
            self.remove(range)
        }
    }
}

public extension CountableSet {
    
    mutating func insert(_ newMembers: Range<Element>) {
        self.insert(CountableClosedRange(newMembers))
    }
    mutating func remove(_ members: Range<Element>) {
        self.remove(CountableClosedRange(members))
    }
    mutating func insert(_ newMembers: ClosedRange<Element>) {
        self.insert(CountableClosedRange(newMembers))
    }
    mutating func remove(_ members: ClosedRange<Element>) {
        self.remove(CountableClosedRange(members))
    }
    mutating func insert(_ newMembers: CountableRange<Element>) {
        self.insert(CountableClosedRange(newMembers))
    }
    mutating func remove(_ members: CountableRange<Element>) {
        self.remove(CountableClosedRange(members))
    }
    mutating func insert<S : Sequence>(_ newMembers: S) where S.Iterator.Element == Element {
        for element in newMembers {
            self.insert(element)
        }
    }
    mutating func remove<S : Sequence>(_ members: S) where S.Iterator.Element == Element {
        for element in members {
            self.remove(element)
        }
    }
}
