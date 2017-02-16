//
//  PDFView.swift
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

extension PDFDocument {
    
    public struct View {
        
        fileprivate let xref: PDFDocument.Xref
        
        public let identifier: PDFDocument.ObjectIdentifier?
        public let value: PDFDocument.Value
    }
    
    public var info: PDFDocument.View? {
        if case let .some(.indirect(identifier)) = trailer["Info"] {
            return xref[identifier].flatMap { $0.isIndirect ? nil : View(xref: xref, identifier: identifier, value: $0) }
        }
        return nil
    }
    public var root: PDFDocument.View? {
        if case let .some(.indirect(identifier)) = trailer["Root"] {
            return xref[identifier].flatMap { $0.isIndirect ? nil : View(xref: xref, identifier: identifier, value: $0) }
        }
        return nil
    }
}

extension PDFDocument.View {
    
    public var count: Int {
        return self.value.count
    }
    
    public subscript(index: Int) -> PDFDocument.View {
        let value = self.value[index]
        switch value {
        case let .indirect(identifier): return xref[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(xref: xref, identifier: identifier, value: $0) } ?? PDFDocument.View(xref: xref, identifier: identifier, value: nil)
        default: return PDFDocument.View(xref: xref, identifier: nil, value: value)
        }
    }
    
    public var keys: LazyMapCollection<PDFDocument.Dictionary, PDFDocument.Name> {
        return self.value.keys
    }
    
    public subscript(key: PDFDocument.Name) -> PDFDocument.View {
        let value = self.value[key]
        switch value {
        case let .indirect(identifier): return xref[identifier].flatMap { $0.isIndirect ? nil : PDFDocument.View(xref: xref, identifier: identifier, value: $0) } ?? PDFDocument.View(xref: xref, identifier: identifier, value: nil)
        default: return PDFDocument.View(xref: xref, identifier: nil, value: value)
        }
    }
}
