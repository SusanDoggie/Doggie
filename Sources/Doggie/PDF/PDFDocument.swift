//
//  PDFDocument.swift
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

public struct PDFDocument {
    
    fileprivate let rootId: PDFDocument.ObjectIdentifier
    fileprivate let list: [PDFDocument.ObjectIdentifier: PDFDocument.Value]
    
    public let version: (major: Int, minor: Int)
    
    public init(version: (major: Int, minor: Int), root: PDFDocument.ObjectIdentifier, _ list: [PDFDocument.ObjectIdentifier: PDFDocument.Value]) {
        self.version = version
        self.rootId = root
        self.list = list
    }
}

extension PDFDocument {
    
    public struct View {
        
        fileprivate var list: [PDFDocument.ObjectIdentifier: PDFDocument.Value]
        
        public var value: PDFDocument.Value
    }
    
    public var root: PDFDocument.View? {
        return list[rootId].flatMap { $0.isIndirect ? nil : View(list: list, value: $0) }
    }
}

extension PDFDocument.View {
    
    public var count: Int {
        return self.value.count
    }
    
    public subscript(index: Int) -> PDFDocument.View {
        let value = self.value[index]
        switch value {
        case let .indirect(identifier): return list[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(list: list, value: $0) } ?? PDFDocument.View(list: list, value: nil)
        default: return PDFDocument.View(list: list, value: value)
        }
    }
    
    public var keys: LazyMapCollection<Dictionary<PDFDocument.Name, PDFDocument.Value>, PDFDocument.Name> {
        return self.value.keys
    }
    
    public subscript(key: PDFDocument.Name) -> PDFDocument.View {
        let value = self.value[key]
        switch value {
        case let .indirect(identifier): return list[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(list: list, value: $0) } ?? PDFDocument.View(list: list, value: nil)
        default: return PDFDocument.View(list: list, value: value)
        }
    }
}
