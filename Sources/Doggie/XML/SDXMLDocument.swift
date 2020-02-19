//
//  SDXMLDocument.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public struct SDXMLDocument: ExpressibleByArrayLiteral {
    
    private var elements: [SDXMLElement]
    
    public init() {
        self.elements = []
    }
    
    public init(arrayLiteral elements: SDXMLElement...) {
        self.elements = elements.map { $0._detach() }
    }
}

extension SDXMLDocument {
    
    public var root: SDXMLElement? {
        guard let index = elements.firstIndex(where: { $0.isNode }) else { return nil }
        var element = elements[index]
        element._tree = SDXMLElement._Tree(root: self, parent: nil, level: 1, index: index)
        return element
    }
}

extension SDXMLDocument: RandomAccessCollection, MutableCollection {
    
    public typealias Indices = Range<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public subscript(position: Int) -> SDXMLElement {
        get {
            var element = elements[position]
            element._tree = SDXMLElement._Tree(root: self, parent: nil, level: 1, index: position)
            return element
        }
        set {
            elements[position] = newValue._detach()
        }
    }
}

extension SDXMLDocument: RangeReplaceableCollection {
    
    public mutating func append(_ newElement: SDXMLElement) {
        elements.append(newElement._detach())
    }
    
    public mutating func append<S: Sequence>(contentsOf newElements: S) where S.Element == SDXMLElement {
        elements.append(contentsOf: newElements.lazy.map { $0._detach() })
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func replaceSubrange<C: Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == SDXMLElement {
        elements.replaceSubrange(subRange, with: newElements.lazy.map { $0._detach() })
    }
}
