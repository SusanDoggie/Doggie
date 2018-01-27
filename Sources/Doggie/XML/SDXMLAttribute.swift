//
//  SDXMLAttribute.swift
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
