//
//  GroupElementsCollection.swift
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

public struct GroupElementsCollection<Key : Equatable, Element> : RandomAccessCollection {
    
    public typealias Indices = CountableRange<Int>
    
    public let key: Key
    fileprivate var base: [Element]
    
    public var startIndex : Int {
        return base.startIndex
    }
    public var endIndex : Int {
        return base.endIndex
    }
    
    public var count: Int {
        return base.count
    }
    
    public subscript(position: Int) -> Element {
        return base[position]
    }
    
    public var elements: [Element] {
        return base
    }
    
    public var underestimatedCount: Int {
        return base.underestimatedCount
    }
}

public extension Sequence {
    
    /// Groups the elements of a sequence according to a specified key selector function.
    func group<Key : Equatable>(by: (Iterator.Element) throws -> Key) rethrows -> [GroupElementsCollection<Key, Iterator.Element>] {
        var table = ContiguousArray<GroupElementsCollection<Key, Iterator.Element>>()
        for item in self {
            let key = try by(item)
            if let idx = table.index(where: { $0.key == key }) {
                table[idx].base.append(item)
            } else {
                table.append(GroupElementsCollection(key: key, base: [item]))
            }
        }
        return Array(table)
    }
}
