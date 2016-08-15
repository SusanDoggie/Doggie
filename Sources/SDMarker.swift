//
//  SDMarker.swift
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

public struct SDMarker {
    
    fileprivate indirect enum Element {
        case string(String)
        case variable(String)
        case scope(String, [Element])
    }
    
    public enum Value {
        case string(String)
        case bool(Bool)
        case integer(IntMax)
        case float(Double)
        case array([[String: Value]])
    }
}

extension SDMarker.Value {
    
    public init(_ val: Bool) {
        self = .bool(val)
    }
    public init<S : SignedInteger>(_ val: S) {
        self = .integer(val.toIntMax())
    }
    public init(_ val: Float) {
        self = .float(Double(val))
    }
    public init(_ val: Double) {
        self = .float(val)
    }
    public init(_ val: String) {
        self = .string(val)
    }
    public init<S : Sequence>(_ val: S) where S.Iterator.Element == [String: SDMarker.Value] {
        self = .array(Array(val))
    }
}

extension SDMarker.Value: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(value)
    }
}

extension SDMarker.Value: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension SDMarker.Value: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: FloatLiteralType) {
        self.init(value)
    }
}

extension SDMarker.Value: ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(value)
    }
}

extension SDMarker.Value: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: [String: SDMarker.Value] ...) {
        self.init(elements)
    }
}

extension SDMarker.Value : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .string(string): return string
        case let .bool(bool): return "\(bool)"
        case let .integer(integer): return "\(integer)"
        case let .float(float): return "\(float)"
        case let .array(array): return "\(array)"
        }
    }
}

extension SDMarker.Element {
    
    func render(stack: [String: SDMarker.Value]) -> String {
        switch self {
        case let .string(str): return str
        case let .variable(name): return stack[name]?.description ?? ""
        case let .scope(name, elements):
            switch stack[name] ?? false {
            case let .bool(bool):
                if bool {
                    var stack = stack
                    stack[name] = true
                    return elements.lazy.map { $0.render(stack: stack) }.joined()
                }
            case let .integer(count):
                if count > 0 {
                    for idx in 0..<count {
                        var stack = stack
                        stack[name] = .integer(idx)
                        return elements.lazy.map { $0.render(stack: stack) }.joined()
                    }
                }
            case let .array(array):
                var result = ""
                for item in array {
                    var stack = stack
                    for (key, value) in item {
                        stack[key] = value
                    }
                    result += elements.lazy.map { $0.render(stack: stack) }.joined()
                }
                return result
            default: break
            }
            return ""
        }
    }
}
