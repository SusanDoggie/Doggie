//
//  PDFName.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct PDFName: Hashable {
    
    @usableFromInline
    var value: Data
    
    @inlinable
    public init(_ value: String) {
        self.value = value._utf8_data
    }
    
    @inlinable
    public init<S: StringProtocol>(_ value: S) {
        self.init(String(value))
    }
}

extension PDFName: ExpressibleByStringLiteral {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

extension PDFName: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "/\(string.escaped(asASCII: false))"
    }
}

extension PDFName {
    
    @inlinable
    public var string: String {
        return value.pdf_string()
    }
}

extension PDFName {
    
    @inlinable
    public func encode(_ data: inout Data) {
        data.append(utf8: "/\(string.escaped(asASCII: false))")
    }
}
