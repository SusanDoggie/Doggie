//
//  SDXMLNode.swift
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

public struct SDXMLAttribute {
    
    public var attribute: String {
        didSet {
            precondition(attribute.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, "Invalid whitespaces.")
        }
    }
    public var namespace: String {
        didSet {
            precondition(namespace.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, "Invalid whitespaces.")
        }
    }
    
    public init(attribute: String, namespace: String = "") {
        precondition(attribute.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, "Invalid whitespaces.")
        precondition(namespace.rangeOfCharacter(from: .whitespacesAndNewlines) == nil, "Invalid whitespaces.")
        self.attribute = attribute
        self.namespace = namespace
    }
}

extension SDXMLAttribute : Hashable {
    
    public var hashValue: Int {
        return hash_combine(seed: 0, attribute.hashValue, namespace.hashValue)
    }
}

extension SDXMLAttribute: ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(attribute: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(attribute: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(attribute: value)
    }
}

public func ==(lhs: SDXMLAttribute, rhs: SDXMLAttribute) -> Bool {
    return lhs.attribute == rhs.attribute && lhs.namespace == rhs.namespace
}

public struct SDXMLNode {
    
    public var name: String
    public var namespace: String
    
    public var attributes: [SDXMLAttribute: String] = [:] {
        didSet {
            attributes = attributes.filter { $0.key.attribute != "" }
        }
    }
    
    private var elements: [SDXMLElement] = []
    
    public init(name: String, namespace: String = "", attributes: [SDXMLAttribute: String] = [:], elements: [SDXMLElement] = []) {
        self.name = name
        self.namespace = namespace
        self.attributes = attributes.filter { $0.key.attribute != "" }
        self.elements = elements
    }
}

extension SDXMLElement {
    
    fileprivate func _apply_global_namespace(_ namespace: String) -> SDXMLElement {
        switch self {
        case let .node(node): return .node(node._apply_global_namespace(namespace))
        default: return self
        }
    }
}

extension SDXMLNode {
    
    fileprivate func _apply_global_namespace(_ namespace: String) -> SDXMLNode {
        
        var attributes: [SDXMLAttribute: String] = [:]
        attributes.reserveCapacity(self.attributes.count)
        
        for (attribute, value) in self.attributes {
            if attribute.namespace != "" || attribute.attribute == "xmlns" || attribute.attribute.contains(":") {
                attributes[attribute] = value
            } else {
                attributes[SDXMLAttribute(attribute: attribute.attribute, namespace: namespace)] = value
            }
        }
        
        return SDXMLNode(name: self.name, namespace: self.namespace == "" ? namespace : self.namespace, attributes: attributes, elements: self.elements.map { $0._apply_global_namespace(namespace) })
    }
}

extension SDXMLNode : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<SDXMLNode>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public subscript(position : Int) -> SDXMLElement {
        get {
            return elements[position]
        }
        set {
            if let xmlns = attributes["xmlns"] {
                elements[position] = newValue._apply_global_namespace(xmlns)
            } else {
                elements[position] = newValue
            }
        }
    }
}

extension SDXMLNode {
    
    public mutating func append(_ newElement: SDXMLElement) {
        if let xmlns = attributes["xmlns"] {
            elements.append(newElement._apply_global_namespace(xmlns))
        } else {
            elements.append(newElement)
        }
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == SDXMLElement {
        if let xmlns = attributes["xmlns"] {
            elements.append(contentsOf: newElements.lazy.map { $0._apply_global_namespace(xmlns) })
        } else {
            elements.append(contentsOf: newElements)
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        elements.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == SDXMLElement {
        if let xmlns = attributes["xmlns"] {
            elements.replaceSubrange(subRange, with: newElements.lazy.map { $0._apply_global_namespace(xmlns) })
        } else {
            elements.replaceSubrange(subRange, with: newElements)
        }
    }
}
