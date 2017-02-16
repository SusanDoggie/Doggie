//
//  PDFXref.swift
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

extension PDFDocument {
    
    public struct Xref {
        
        fileprivate let table: [[PDFDocument.Value?]]
        
        public init(_ table: [[PDFDocument.Value?]]) {
            self.table = table
        }
    }
}

extension PDFDocument.Xref : BidirectionalCollection {
    
    public typealias Indices = DefaultBidirectionalIndices<PDFDocument.Xref>
    
    public typealias Iterator = IndexingIterator<PDFDocument.Xref>
    
    private typealias _Collection = FlattenBidirectionalCollection<LazyMapBidirectionalCollection<IndexedRandomAccessCollection<[[PDFDocument.Value?]]>, LazyMapRandomAccessCollection<IndexedRandomAccessCollection<[PDFDocument.Value?]>, (PDFDocument.ObjectIdentifier, PDFDocument.Value?)>>>
    
    public struct Index : Comparable {
        
        fileprivate let base: _Collection.Index
    }
    
    private var _collection: _Collection {
        return table.indexed().lazy.flatMap { id, objs in objs.indexed().lazy.map { (PDFDocument.ObjectIdentifier(identifier: id, generation: $0), $1) } }.elements
    }
    
    public var startIndex: Index {
        return PDFDocument.Xref.Index(base: _collection.startIndex)
    }
    
    public var endIndex: Index {
        return PDFDocument.Xref.Index(base: _collection.endIndex)
    }
    
    public func index(after i: Index) -> Index {
        return PDFDocument.Xref.Index(base: _collection.index(after: i.base))
    }
    
    public func index(before i: Index) -> Index {
        return PDFDocument.Xref.Index(base: _collection.index(before: i.base))
    }
    
    public subscript(position: Index) -> (PDFDocument.ObjectIdentifier, PDFDocument.Value?) {
        return _collection[position.base]
    }
}

public func == (lhs: PDFDocument.Xref.Index, rhs: PDFDocument.Xref.Index) -> Bool {
    return lhs.base == rhs.base
}
public func < (lhs: PDFDocument.Xref.Index, rhs: PDFDocument.Xref.Index) -> Bool {
    return lhs.base < rhs.base
}

extension PDFDocument.Xref {
    
    public subscript(index: PDFDocument.ObjectIdentifier) -> PDFDocument.Value? {
        if table.indices ~= index.identifier {
            let objects = table[index.identifier]
            if objects.indices ~= index.generation {
                return objects[index.generation]
            }
        }
        return nil
    }
}
