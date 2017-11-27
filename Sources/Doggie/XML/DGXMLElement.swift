//
//  DGXMLElement.swift
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

public struct DGXMLElement {
    
    public var kind: Kind
    
    public init(name: String, namespace: String? = nil, attributes: [String: String] = [:], elements: [DGXMLElement] = []) {
        self.kind = .node(DGXMLNode(name: name, namespace: namespace, attributes: attributes, elements: elements))
    }
    
    public init(_ value: DGXMLNode) {
        self.kind = .node(value)
    }
    
    public init(CDATA value: String) {
        self.kind = .CDATA(value)
    }
    
    public init(comment value: String) {
        self.kind = .comment(value)
    }
    
    public init(characters value: String) {
        self.kind = .characters(value)
    }
}

extension DGXMLElement {
    
    public enum Kind {
        
        case node(DGXMLNode)
        case characters(String)
        case comment(String)
        case CDATA(String)
    }
}

extension DGXMLElement {
    
    public var isNode: Bool {
        switch kind {
        case .node: return true
        default: return false
        }
    }
    
    public var isCharacters: Bool {
        switch kind {
        case .characters: return true
        default: return false
        }
    }
    
    public var isComment: Bool {
        switch kind {
        case .comment: return true
        default: return false
        }
    }
    
    public var isCDATA: Bool {
        switch kind {
        case .CDATA: return true
        default: return false
        }
    }
}

extension DGXMLElement {
    
    public var name: String? {
        switch kind {
        case let .node(node): return node.name
        default: return nil
        }
    }
    
    public var namespace: String? {
        switch kind {
        case let .node(node): return node.namespace
        default: return nil
        }
    }
    
    public var value: String? {
        switch kind {
        case let .characters(value): return value
        case let .comment(value): return value
        case let .CDATA(value): return value
        default: return nil
        }
    }
    
    public var attributes: [String: String] {
        get {
            switch kind {
            case let .node(node): return node.attributes
            default: return [:]
            }
        }
        set {
            switch kind {
            case var .node(node):
                node.attributes = newValue
                self.kind = .node(node)
            default: break
            }
        }
    }
}

extension DGXMLElement : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<DGXMLElement>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        switch kind {
        case let .node(node): return node.startIndex
        default: return 0
        }
    }
    
    public var endIndex: Int {
        switch kind {
        case let .node(node): return node.endIndex
        default: return 0
        }
    }
    
    public subscript(position : Int) -> DGXMLElement {
        get {
            switch kind {
            case let .node(node): return node[position]
            default: fatalError()
            }
        }
        set {
            switch kind {
            case var .node(node):
                node[position] = newValue
                self.kind = .node(node)
            default: fatalError()
            }
        }
    }
}

extension DGXMLElement {
    
    public mutating func append(_ newElement: DGXMLElement) {
        switch kind {
        case var .node(node):
            node.append(newElement)
            self.kind = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == DGXMLElement {
        switch kind {
        case var .node(node):
            node.append(contentsOf: newElements)
            self.kind = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        switch kind {
        case var .node(node):
            node.reserveCapacity(minimumCapacity)
            self.kind = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        switch kind {
        case var .node(node):
            node.removeAll(keepingCapacity: keepingCapacity)
            self.kind = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == DGXMLElement {
        switch kind {
        case var .node(node):
            node.replaceSubrange(subRange, with: newElements)
            self.kind = .node(node)
        default: fatalError()
        }
    }
}
