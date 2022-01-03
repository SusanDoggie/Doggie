//
//  PDFDocument.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
public struct PDFDocument: RandomAccessCollection {
    
    @usableFromInline
    var pages: [PDFPage]
    
    @usableFromInline
    var _trailer: PDFObject = [:]
    
    init(_ trailer: PDFObject) {
        self.pages = trailer.catalog.pages
        self._trailer = trailer
    }
}

extension PDFDocument: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(trailer)"
    }
}

extension PDFDocument {
    
    @inlinable
    public var trailer: PDFObject {
        get {
            var trailer = self._trailer
            var catalog = trailer.catalog
            catalog["Pages"] = [
                "Type": PDFObject("Pages" as PDFName),
                "Kids": PDFObject(self.pages.map { $0.object }),
                "Count": PDFObject(self.pages.count),
            ]
            trailer.catalog = catalog
            return trailer
        }
        set {
            self.pages = newValue.catalog.pages
            self._trailer = newValue
        }
    }
}

extension PDFObject {
    
    @inlinable
    static var empty_catalog: PDFObject {
        return [
            "Type": PDFObject("Catalog" as PDFName),
            "Pages": [
                "Type": PDFObject("Pages" as PDFName),
                "Kids": [],
                "Count": 0
            ]
        ]
    }
    
    @inlinable
    var catalog: PDFObject {
        get {
            let catalog = self["Root"]
            guard catalog.isDictionary, catalog["Type"].name == "Catalog" else { return PDFObject.empty_catalog }
            return catalog
        }
        set {
            var catalog = newValue
            catalog["Type"] = PDFObject("Catalog" as PDFName)
            self["Root"] = catalog
        }
    }
    
    @inlinable
    var pages: [PDFPage] {
        switch self["Type"] {
        case PDFObject("Catalog" as PDFName): return self["Pages"].pages
        case PDFObject("Pages" as PDFName): return self["Kids"].array?.flatMap { $0.pages } ?? []
        case PDFObject("Page" as PDFName): return [PDFPage(self)]
        default: return []
        }
    }
}

extension PDFDocument {
    
    @inlinable
    public var startIndex: Int {
        return pages.startIndex
    }
    
    @inlinable
    public var endIndex: Int {
        return pages.endIndex
    }
    
    @inlinable
    public subscript(position: Int) -> PDFPage {
        get {
            return pages[position]
        }
        set {
            pages[position] = newValue
        }
    }
}
