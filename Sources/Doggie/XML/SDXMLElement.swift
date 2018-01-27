//
//  SDXMLElement.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

public struct SDXMLElement {
    
    enum Kind {
        case node
        case characters
        case comment
        case CDATA
    }
    
    let kind: Kind
    
    let _name: String
    let _namespace: String
    
    var _attributes: [SDXMLAttribute: String] {
        didSet {
            _attributes = _attributes.filter { $0.key.attribute != "" }
        }
    }
    
    var _elements: [SDXMLElement]
    
    let _string: String
    
    var _parent: [Any] = []
    
    public init(name: String, namespace: String = "", attributes: [SDXMLAttribute: String] = [:], elements: [SDXMLElement] = []) {
        self.kind = .node
        self._name = name
        self._namespace = namespace
        self._attributes = attributes.filter { $0.key.attribute != "" }
        self._elements = elements.map { $0._detach() }
        self._string = ""
    }
    
    public init(CDATA value: String) {
        self.kind = .CDATA
        self._name = ""
        self._namespace = ""
        self._attributes = [:]
        self._elements = []
        self._string = value
    }
    
    public init(comment value: String) {
        self.kind = .comment
        self._name = ""
        self._namespace = ""
        self._attributes = [:]
        self._elements = []
        self._string = value
    }
    
    public init(characters value: String) {
        self.kind = .characters
        self._name = ""
        self._namespace = ""
        self._attributes = [:]
        self._elements = []
        self._string = value
    }
}

extension SDXMLElement: ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(characters: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(characters: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(characters: value)
    }
}

extension SDXMLElement {
    
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

extension SDXMLElement {
    
    public var name: String? {
        switch kind {
        case .node: return _name
        default: return nil
        }
    }
    
    public var namespace: String? {
        switch kind {
        case .node: return _namespace
        default: return nil
        }
    }
    
    public var value: String? {
        switch kind {
        case .characters: return _string
        case .comment: return _string
        case .CDATA: return _string
        default: return nil
        }
    }
}

extension SDXMLElement {
    
    public var rootDocument: SDXMLDocument? {
        return _parent.first as? SDXMLDocument ?? parent?.rootDocument
    }
    
    public var root: SDXMLElement? {
        return rootDocument?.root
    }
    
    public var parent: SDXMLElement? {
        return _parent.first as? SDXMLElement
    }
}

extension SDXMLElement {
    
    public mutating func setAttribute(for attribute: String, namespace: String = "", value: String?) {
        switch kind {
        case .node:
            _attributes[SDXMLAttribute(attribute: attribute, namespace: namespace)] = value
        default: break
        }
    }
    
    public func attributes() -> [SDXMLAttribute: String] {
        switch kind {
        case .node: return _attributes
        default: return [:]
        }
    }
    
    public func attributes(for attribute: String) -> [SDXMLAttribute: String] {
        switch kind {
        case .node: return _attributes.filter { $0.key.attribute == attribute }
        default: return [:]
        }
    }
    
    public func attributes(for attribute: String, namespace: String) -> String? {
        switch kind {
        case .node: return _attributes[SDXMLAttribute(attribute: attribute, namespace: namespace)]
        default: return nil
        }
    }
}

extension SDXMLElement {
    
    private func _apply_global_namespace(_ namespace: String) -> SDXMLElement {
        
        switch kind {
        case .node:
            
            var attributes: [SDXMLAttribute: String] = [:]
            attributes.reserveCapacity(self._attributes.count)
            
            for (attribute, value) in self._attributes {
                if attribute.namespace != "" || attribute.attribute == "xmlns" || attribute.attribute.contains(":") {
                    attributes[attribute] = value
                } else {
                    attributes[SDXMLAttribute(attribute: attribute.attribute, namespace: namespace)] = value
                }
            }
            
            return SDXMLElement(name: self._name, namespace: self._namespace == "" ? namespace : self._namespace, attributes: _attributes, elements: self._elements.map { $0._apply_global_namespace(namespace) })
            
        default: return self
        }
    }
    
    func _detach() -> SDXMLElement {
        var copy = self
        copy._parent = []
        return copy
    }
}

extension SDXMLElement : RandomAccessCollection, MutableCollection {
    
    public typealias SubSequence = MutableRandomAccessSlice<SDXMLElement>
    
    public typealias Indices = CountableRange<Int>
    
    public typealias Index = Int
    
    public var startIndex: Int {
        return _elements.startIndex
    }
    
    public var endIndex: Int {
        return _elements.endIndex
    }
    
    public subscript(position : Int) -> SDXMLElement {
        get {
            var element = _elements[position]
            element._parent = [self]
            return element
        }
        set {
            if let xmlns = _attributes["xmlns"] {
                _elements[position] = newValue._apply_global_namespace(xmlns)._detach()
            } else {
                _elements[position] = newValue._detach()
            }
        }
    }
}

extension SDXMLElement {
    
    public mutating func append(_ newElement: SDXMLElement) {
        if let xmlns = _attributes["xmlns"] {
            _elements.append(newElement._apply_global_namespace(xmlns)._detach())
        } else {
            _elements.append(newElement._detach())
        }
    }
    
    public mutating func append<S : Sequence>(contentsOf newElements: S) where S.Element == SDXMLElement {
        if let xmlns = _attributes["xmlns"] {
            _elements.append(contentsOf: newElements.lazy.map { $0._apply_global_namespace(xmlns)._detach() })
        } else {
            _elements.append(contentsOf: newElements.lazy.map { $0._detach() })
        }
    }
    
    public mutating func reserveCapacity(_ minimumCapacity: Int) {
        _elements.reserveCapacity(minimumCapacity)
    }
    
    public mutating func removeAll(keepingCapacity: Bool = false) {
        _elements.removeAll(keepingCapacity: keepingCapacity)
    }
    
    public mutating func replaceSubrange<C : Collection>(_ subRange: Range<Int>, with newElements: C) where C.Element == SDXMLElement {
        if let xmlns = _attributes["xmlns"] {
            _elements.replaceSubrange(subRange, with: newElements.lazy.map { $0._apply_global_namespace(xmlns)._detach() })
        } else {
            _elements.replaceSubrange(subRange, with: newElements.lazy.map { $0._detach() })
        }
    }
}
