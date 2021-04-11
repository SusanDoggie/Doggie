//
//  PDFString.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
public struct PDFString: Hashable {
    
    @usableFromInline
    var base: Base
    
    @inlinable
    public init(_ value: String) {
        self.base = .string(value)
    }
    
    @inlinable
    public init<S: StringProtocol>(_ value: S) {
        self.init(String(value))
    }
    
    @inlinable
    public init(_ value: Data) {
        
        if let value = String(data: value, encoding: .utf8) {
            
            self.base = .string(value)
            
        } else if value.prefix(2).elementsEqual([254, 255]), let value = String(data: value, encoding: .utf16BigEndian) {
            
            self.base = .string(value)
            
        } else {
            
            self.base = .byte(value)
        }
    }
}

extension PDFString {
    
    @usableFromInline
    enum Base: Hashable {
        case string(String)
        case byte(Data)
    }
}

extension PDFString: ExpressibleByStringInterpolation {
    
    @inlinable
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
    
    @inlinable
    public init(stringInterpolation: String.StringInterpolation) {
        self.init(String(stringInterpolation: stringInterpolation))
    }
}

extension PDFString: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        switch base {
        case let .string(value): return "(\(value.escaped(asASCII: false)))"
        case let .byte(value): return "<\(value.map { String($0, radix: 16, uppercase: true) }.joined())>"
        }
    }
}

extension Data {
    
    @usableFromInline
    func pdf_string() -> String {
        
        if self.isEmpty {
            return ""
        }
        
        var bytes = self
        bytes.append(0)
        
        return bytes.withUnsafeBufferPointer { String(cString: $0.baseAddress!) }
    }
}

extension PDFString {
    
    @inlinable
    public var string: String {
        switch base {
        case let .string(value): return value
        case let .byte(value): return value.pdf_string()
        }
    }
    
    @inlinable
    public var data: Data? {
        switch base {
        case let .byte(value): return value
        default: return nil
        }
    }
}

extension PDFString {
    
    @inlinable
    public func encode(_ data: inout Data) {
        switch base {
        case let .string(value):
            if value.allSatisfy({ $0.isASCII }) {
                data.append(utf8: "(\(value.escaped(asASCII: false)))")
            } else {
                let string = value.data(using: .utf16BigEndian) ?? Data()
                data.append(utf8: "<\(string.map { String($0, radix: 16, uppercase: true) }.joined())>")
            }
        case let .byte(value): data.append(utf8: "<\(value.map { String($0, radix: 16, uppercase: true) }.joined())>")
        }
    }
}
