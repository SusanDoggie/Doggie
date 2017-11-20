//
//  DGXMLDocument.swift
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

public struct DGXMLDocument : ExpressibleByArrayLiteral {
    
    private var elements: [DGXMLElement]
    
    public init() {
        self.elements = []
    }
    
    public init(arrayLiteral elements: DGXMLElement...) {
        self.elements = elements
    }
}

extension DGXMLDocument {
    
    public var root: DGXMLElement? {
        return elements.first { $0.isNode }
    }
}

extension DGXMLDocument : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRangeReplaceableRandomAccessSlice<DGXMLDocument>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public subscript(position : Int) -> DGXMLElement {
        get {
            return elements[position]
        }
        set {
            elements[position] = newValue
        }
    }
}

extension DGXMLDocument : RangeReplaceableCollection {
    
    public mutating func append(_ newElement: DGXMLElement) {
        elements.append(newElement)
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == DGXMLElement {
        elements.append(contentsOf: newElements)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == DGXMLElement {
        elements.replaceSubrange(subRange, with: newElements)
    }
}
