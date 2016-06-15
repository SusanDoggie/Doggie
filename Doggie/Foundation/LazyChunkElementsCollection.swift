//
//  LazyChunkElementsCollection.swift
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

public struct LazyChunkElementsIterator<Base : IteratorProtocol> : IteratorProtocol, Sequence {
    
    private var base: Base
    
    public mutating func next() -> Base.Element? {
        return base.next()
    }
}

public struct LazyChunkElementsSequence<Key : Equatable, Base : Sequence> : LazySequenceProtocol {
    
    public let key: Key
    private let base: Base
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsCollection<Key : Equatable, Base : Collection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsBidirectionalCollection<Key : Equatable, Base : BidirectionalCollection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        return base.index(before: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public struct LazyChunkElementsRandomAccessCollection<Key : Equatable, Base : RandomAccessCollection> : LazyCollectionProtocol {
    
    public typealias Iterator = LazyChunkElementsIterator<Base.Iterator>
    
    public let key: Key
    private let base: Base
    
    public var startIndex : Base.Index {
        return base.startIndex
    }
    public var endIndex : Base.Index {
        return base.endIndex
    }
    
    public func index(after i: Base.Index) -> Base.Index {
        return base.index(after: i)
    }
    
    public func index(before i: Base.Index) -> Base.Index {
        return base.index(before: i)
    }
    
    public subscript(index: Base.Index) -> Base.Iterator.Element {
        return base[index]
    }
    
    public var count : Base.IndexDistance {
        return base.count
    }
    
    public func makeIterator() -> LazyChunkElementsIterator<Base.Iterator> {
        return LazyChunkElementsIterator(base: base.makeIterator())
    }
    
    public var elements: Base {
        return base
    }
}

public extension Collection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsSequence<Key, SubSequence>] {
        
        var table: [LazyChunkElementsSequence<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsSequence(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}

public extension Collection where SubSequence : Collection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}
public extension Collection where SubSequence : BidirectionalCollection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsBidirectionalCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsBidirectionalCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsBidirectionalCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}
public extension Collection where SubSequence : RandomAccessCollection {
    
    func chunk<Key : Equatable>(by: @noescape (Iterator.Element) throws -> Key) rethrows -> [LazyChunkElementsRandomAccessCollection<Key, SubSequence>] {
        
        var table: [LazyChunkElementsRandomAccessCollection<Key, SubSequence>] = []
        var key: Key?
        var start = startIndex
        var scanner = startIndex
        while scanner != endIndex {
            let _key = try by(self[scanner])
            if key == nil {
                key = _key
            } else if key != _key {
                table.append(LazyChunkElementsRandomAccessCollection(key: key!, base: self[start..<scanner]))
                key = _key
                start = scanner
            }
            scanner = self.index(after: scanner)
        }
        return table
    }
}
