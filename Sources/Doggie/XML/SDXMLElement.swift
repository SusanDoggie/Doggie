//
//  SDXMLElement.swift
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

public enum SDXMLElement {
    
    case node(SDXMLNode)
    case characters(String)
    case comment(String)
    case CDATA(String)
    
    public init(name: String, namespace: String = "", attributes: [SDXMLAttribute: String] = [:], elements: [SDXMLElement] = []) {
        self = .node(SDXMLNode(name: name, namespace: namespace, attributes: attributes, elements: elements))
    }
    
    public init(_ value: SDXMLNode) {
        self = .node(value)
    }
    
    public init(CDATA value: String) {
        self = .CDATA(value)
    }
    
    public init(comment value: String) {
        self = .comment(value)
    }
    
    public init(characters value: String) {
        self = .characters(value)
    }
}

extension SDXMLElement {
    
    public var isNode: Bool {
        switch self {
        case .node: return true
        default: return false
        }
    }
    
    public var isCharacters: Bool {
        switch self {
        case .characters: return true
        default: return false
        }
    }
    
    public var isComment: Bool {
        switch self {
        case .comment: return true
        default: return false
        }
    }
    
    public var isCDATA: Bool {
        switch self {
        case .CDATA: return true
        default: return false
        }
    }
}

extension SDXMLElement {
    
    public var name: String? {
        switch self {
        case let .node(node): return node.name
        default: return nil
        }
    }
    
    public var namespace: String? {
        switch self {
        case let .node(node): return node.namespace
        default: return nil
        }
    }
    
    public var value: String? {
        switch self {
        case let .characters(value): return value
        case let .comment(value): return value
        case let .CDATA(value): return value
        default: return nil
        }
    }
}

extension SDXMLElement {
    
    public mutating func setAttribute(for attribute: String, namespace: String = "", value: String?) {
        switch self {
        case var .node(node):
            node.attributes[SDXMLAttribute(attribute: attribute, namespace: namespace)] = value
            self = .node(node)
        default: break
        }
    }
    
    public func attributes() -> [SDXMLAttribute: String] {
        switch self {
        case let .node(node): return node.attributes
        default: return [:]
        }
    }
    
    public func attributes(for attribute: String) -> [SDXMLAttribute: String] {
        switch self {
        case let .node(node): return node.attributes.filter { $0.key.attribute == attribute }
        default: return [:]
        }
    }
    
    public func attributes(for attribute: String, namespace: String) -> String? {
        switch self {
        case let .node(node): return node.attributes[SDXMLAttribute(attribute: attribute, namespace: namespace)]
        default: return nil
        }
    }
}

extension SDXMLElement : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<SDXMLElement>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        switch self {
        case let .node(node): return node.startIndex
        default: return 0
        }
    }
    
    public var endIndex: Int {
        switch self {
        case let .node(node): return node.endIndex
        default: return 0
        }
    }
    
    public subscript(position : Int) -> SDXMLElement {
        get {
            switch self {
            case let .node(node): return node[position]
            default: fatalError()
            }
        }
        set {
            switch self {
            case var .node(node):
                node[position] = newValue
                self = .node(node)
            default: fatalError()
            }
        }
    }
}

extension SDXMLElement {
    
    public mutating func append(_ newElement: SDXMLElement) {
        switch self {
        case var .node(node):
            node.append(newElement)
            self = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == SDXMLElement {
        switch self {
        case var .node(node):
            node.append(contentsOf: newElements)
            self = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        switch self {
        case var .node(node):
            node.reserveCapacity(minimumCapacity)
            self = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        switch self {
        case var .node(node):
            node.removeAll(keepingCapacity: keepingCapacity)
            self = .node(node)
        default: fatalError()
        }
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == SDXMLElement {
        switch self {
        case var .node(node):
            node.replaceSubrange(subRange, with: newElements)
            self = .node(node)
        default: fatalError()
        }
    }
}
