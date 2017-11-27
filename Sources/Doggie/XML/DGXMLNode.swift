//
//  DGXMLNode.swift
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

import Foundation

public struct DGXMLNode {
    
    public var name: String
    public var namespace: String?
    
    public var attributes: [String: String] = [:] {
        didSet {
            attributes = attributes.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" && $1.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        }
    }
    
    private var elements: [DGXMLElement] = []
    
    public init(name: String, namespace: String? = nil, attributes: [String: String] = [:], elements: [DGXMLElement] = []) {
        self.name = name
        self.namespace = namespace
        self.attributes = attributes.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines) != "" && $1.trimmingCharacters(in: .whitespacesAndNewlines) != "" }
        self.elements = elements
    }
}

extension DGXMLNode : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<DGXMLNode>
    
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

extension DGXMLNode {
    
    public mutating func append(_ newElement: DGXMLElement) {
        elements.append(newElement)
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == DGXMLElement {
        elements.append(contentsOf: newElements)
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        elements.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == DGXMLElement {
        elements.replaceSubrange(subRange, with: newElements)
    }
}
