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

import Foundation

public struct SDMarker {
    
    fileprivate indirect enum Element {
        case string(String)
        case variable(String)
        case scope(String, Bool, [Element])
    }
    
    public enum Value {
        case object([String: Value])
        case array([Value])
        case template(SDMarker)
        case integer(IntMax)
        case boolean(Bool)
        case any(Any)
    }
    
    fileprivate let elements: [Element]
}

extension SDMarker {
    
    public init(template: String) {
        let characterSet = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-_1234567890.:".characters)
        self.elements = SDMarker.parseScope(ArraySlice(template.characters), characterSet)
    }
    
    private static let token_start = Array("{{".characters)
    private static let scope_token_start = Array("{{#".characters)
    private static let scope_token_end = Array("#}}".characters)
    private static let variable_token_end = Array("%}}".characters)
    
    private static func parseScope(_ chars: ArraySlice<Character>, _ characterSet: Set<Character>) -> [Element] {
        var result: [Element] = []
        var chars = chars
        outer: while let index = chars.range(of: token_start)?.lowerBound {
            let head = chars.prefix(upTo: index + 2)
            let tail = chars.suffix(from: index + 2)
            if let token = parseToken(tail, characterSet) {
                switch token {
                case let .variable(name, end):
                    result.append(.string(String(head.dropLast(2))))
                    result.append(.variable(name))
                    chars = tail.suffix(from: end)
                    continue
                case let .scope(name, flag, end):
                    var _tail = tail.dropFirst()
                    while let index2 = _tail.range(of: scope_token_start)?.lowerBound {
                        if let token = parseToken(_tail.suffix(from: index2 + 2), characterSet), case .scope(name, true, let end2) = token {
                            result.append(.string(String(head.dropLast(2))))
                            result.append(.scope(name, flag, parseScope(tail.suffix(from: end).prefix(upTo: index2), characterSet)))
                            chars = _tail.suffix(from: end2)
                            continue outer
                        }
                        _tail = _tail.suffix(from: index2 + 3)
                    }
                }
            }
            result.append(.string(String(head)))
            chars = tail
        }
        result.append(.string(String(chars)))
        return result
    }
    
    private enum TokenType {
        case variable(String, Int)
        case scope(String, Bool, Int)
    }
    
    private static func parseToken(_ chars: ArraySlice<Character>, _ characterSet: Set<Character>) -> TokenType? {
        if let token = chars.first {
            switch token {
            case "%":
                if let end_token_index = chars.range(of: variable_token_end)?.lowerBound, chars.startIndex + 1 != end_token_index {
                    let variable_name = String(chars.prefix(upTo: end_token_index).dropFirst()).trimmingCharacters(in: .whitespaces)
                    if variable_name.characters.all({ characterSet.contains($0) }) {
                        return .variable(variable_name, end_token_index + 3)
                    }
                }
            case "#":
                if let end_token_index = chars.range(of: scope_token_end)?.lowerBound, chars.startIndex + 1 != end_token_index {
                    var flag = true
                    var scope_name = String(chars.prefix(upTo: end_token_index).dropFirst()).trimmingCharacters(in: .whitespaces)
                    if scope_name.characters.first == "!" {
                        scope_name.remove(at: scope_name.startIndex)
                        scope_name = scope_name.trimmingCharacters(in: .whitespaces)
                        flag = false
                    }
                    if scope_name.characters.all({ characterSet.contains($0) }) {
                        return .scope(scope_name, flag, end_token_index + 3)
                    }
                }
            default: break
            }
        }
        return nil
    }
}

extension SDMarker: ExpressibleByStringLiteral {
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(template: value)
    }
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(template: value)
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(template: value)
    }
}

extension SDMarker {
    
    public func render(_ values: [String: SDMarker.Value]) -> String {
        return self.elements.map { $0.render(stack: values) }.joined()
    }
}

extension SDMarker.Element : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .string(str): return str
        case let .variable(name): return "{{%\(name)%}}"
        case let .scope(name, flag, elements): return "{{#\(flag ? "" : "!")\(name)#}}\(elements.lazy.map { $0.description }.joined()){{#\(name)#}}"
        }
    }
}

extension SDMarker : CustomStringConvertible {
    
    public var description: String {
        return elements.lazy.map { $0.description }.joined()
    }
}

extension SDMarker.Value {
    
    public init(_ val: Bool) {
        self = .boolean(val)
    }
    public init<S : SignedInteger>(_ val: S) {
        self = .integer(val.toIntMax())
    }
    public init(_ val: Float) {
        self = .any(val)
    }
    public init(_ val: Double) {
        self = .any(val)
    }
    public init(_ val: String) {
        self = .any(val)
    }
    public init(_ val: [String: SDMarker.Value]) {
        self = .object(val)
    }
    public init<S : Sequence>(_ val: S) where S.Iterator.Element == SDMarker.Value {
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
    
    public init(arrayLiteral elements: SDMarker.Value ...) {
        self.init(elements)
    }
}

extension SDMarker.Value: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (String, SDMarker.Value) ...) {
        var dictionary: [String: SDMarker.Value] = [:]
        for (key, value) in elements {
            dictionary[key] = value
        }
        self.init(dictionary)
    }
}

extension SDMarker.Value : CustomStringConvertible {
    
    public var description: String {
        switch self {
        case let .object(object): return "\(object)"
        case let .array(array): return "\(array)"
        case let .template(template): return template.description
        case let .integer(integer): return "\(integer)"
        case let .boolean(bool): return "\(bool)"
        case let .any(other): return "\(other)"
        }
    }
}

extension SDMarker.Element {
    
    fileprivate func render(stack: [String: SDMarker.Value]) -> String {
        switch self {
        case let .string(str): return str
        case let .variable(name):
            if let variable = stack[name] {
                switch variable {
                case let .template(template): return template.render(stack)
                default: return variable.description
                }
            }
        case let .scope(name, flag, elements):
            switch stack[name] ?? false {
            case let .object(object):
                if flag {
                    var stack = stack
                    stack[name] = .object(object)
                    for (key, value) in object {
                        stack[key] = value
                    }
                    return elements.lazy.map { $0.render(stack: stack) }.joined()
                }
            case let .array(array):
                if flag {
                    return array.lazy.map {
                        var stack = stack
                        stack[name] = $0
                        if case let .object(object) = $0 {
                            for (key, value) in object {
                                stack[key] = value
                            }
                        }
                        return elements.lazy.map { $0.render(stack: stack) }.joined()
                        }.joined()
                } else if array.count == 0 {
                    return elements.lazy.map { $0.render(stack: stack) }.joined()
                }
            case let .integer(count):
                if flag {
                    if count > 0 {
                        return (0..<count).lazy.map {
                            var stack = stack
                            stack[name] = .integer($0)
                            return elements.lazy.map { $0.render(stack: stack) }.joined()
                            }.joined()
                    }
                } else if count == 0 {
                    return elements.lazy.map { $0.render(stack: stack) }.joined()
                }
            case let .boolean(bool):
                if flag {
                    if bool {
                        return elements.lazy.map { $0.render(stack: stack) }.joined()
                    }
                } else if !bool {
                    return elements.lazy.map { $0.render(stack: stack) }.joined()
                }
            default: break
            }
        }
        return ""
    }
}
