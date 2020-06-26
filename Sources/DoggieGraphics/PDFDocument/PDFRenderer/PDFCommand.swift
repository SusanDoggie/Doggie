//
//  PDFCommand.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

enum PDFCommand: Hashable {
    
    case command(String)
    
    case name(PDFName)
    
    case string(PDFString)
    
    case number(PDFNumber)
    
    case array([PDFCommand])
    
    case dictionary([PDFName: PDFCommand])
    
}

extension PDFCommand {
    
    init(_ value: PDFNumber) {
        self = .number(value)
    }
    
    init<T: FixedWidthInteger & SignedInteger>(_ value: T) {
        self = .number(PDFNumber(value))
    }
    
    init<T: FixedWidthInteger & UnsignedInteger>(_ value: T) {
        self = .number(PDFNumber(value))
    }
    
    init<T: BinaryFloatingPoint>(_ value: T) {
        self = .number(PDFNumber(value))
    }
    
    init(_ value: Decimal) {
        self = .number(PDFNumber(value))
    }
    
    init<S: Sequence>(_ elements: S) where S.Element == PDFCommand {
        self = .array(Array(elements))
    }
    
}

extension PDFCommand: ExpressibleByArrayLiteral {
    
    init(arrayLiteral elements: PDFCommand ...) {
        self.init(elements)
    }
}

extension PDFCommand: CustomStringConvertible {
    
    var description: String {
        switch self {
        case let .command(value): return "\(value.escaped(asASCII: false))"
        case let .name(value): return "\(value)"
        case let .string(value): return "\(value)"
        case let .number(value): return "\(value)"
        case let .array(value): return "\(value)"
        case let .dictionary(value): return "\(value)"
        }
    }
}

extension PDFCommand {
    
    var command: String? {
        switch self {
        case let .command(value): return value
        default: return nil
        }
    }
    
    var name: PDFName? {
        switch self {
        case let .name(value): return value
        default: return nil
        }
    }
    
    var string: PDFString? {
        switch self {
        case let .string(value): return value
        default: return nil
        }
    }
    
    var number: PDFNumber? {
        switch self {
        case let .number(value): return value
        default: return nil
        }
    }
    
    var intValue: Int? {
        switch self {
        case let .number(value): return value.int64Value.flatMap { Int(exactly: $0) }
        default: return nil
        }
    }
    
    var doubleValue: Double? {
        switch self {
        case let .number(value): return value.doubleValue
        default: return nil
        }
    }
    
    var array: [PDFCommand]? {
        switch self {
        case let .array(value): return value
        default: return nil
        }
    }
    
    var dictionary: [PDFName: PDFCommand]? {
        switch self {
        case let .dictionary(value): return value
        default: return nil
        }
    }
}

extension PDFCommand {
    
    func encode(_ data: inout Data) {
        switch self {
        case let .command(value): data.append(utf8: value)
        case let .name(value): value.encode(&data)
        case let .string(value): value.encode(&data)
        case let .number(value): value.encode(&data)
            
        case let .array(array):
            
            data.append(utf8: "[\n")
            for object in array {
                object.encode(&data)
                data.append(utf8: "\n")
            }
            data.append(utf8: "]")
            
        case let .dictionary(dictionary):
            
            data.append(utf8: "<<\n")
            for (name, object) in dictionary {
                name.encode(&data)
                data.append(utf8: " ")
                object.encode(&data)
                data.append(utf8: "\n")
            }
            data.append(utf8: ">>")
        }
    }
}

extension Collection where Element == PDFCommand {
    
    func encode(_ data: inout Data) {
        
        guard let first = self.first else { return }
        first.encode(&data)
        
        for command in self.dropFirst() {
            data.append(utf8: "\n")
            command.encode(&data)
        }
    }
}
