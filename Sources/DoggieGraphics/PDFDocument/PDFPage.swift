//
//  PDFPage.swift
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
public struct PDFPage {
    
    @usableFromInline
    var object: PDFObject {
        didSet {
            object["Type"] = PDFObject("Page" as PDFName)
        }
    }
    
    @inlinable
    init(_ object: PDFObject = [:]) {
        self.object = object
        self.object["Type"] = PDFObject("Page" as PDFName)
    }
}

extension PDFPage {
    
    private func search(_ key: PDFName) -> PDFObject {
        
        var object = self.object
        var value: PDFObject
        
        repeat {
            value = object[key]
            object = object["Parent"]
        } while value == nil && object != nil
        
        return value
    }
    
    public var mediaBox: Rect? {
        get {
            return self.search("MediaBox").rect
        }
        set {
            self.object["MediaBox"] = newValue.map(PDFObject.init) ?? nil
        }
    }
    
    public var cropBox: Rect? {
        get {
            return self.search("CropBox").rect ?? mediaBox
        }
        set {
            self.object["CropBox"] = newValue.map(PDFObject.init) ?? nil
        }
    }
    
    public var bleedBox: Rect? {
        get {
            return self.search("BleedBox").rect ?? cropBox
        }
        set {
            self.object["BleedBox"] = newValue.map(PDFObject.init) ?? nil
        }
    }
    
    public var trimBox: Rect? {
        get {
            return self.search("TrimBox").rect ?? cropBox
        }
        set {
            self.object["TrimBox"] = newValue.map(PDFObject.init) ?? nil
        }
    }
    
    public var artBox: Rect? {
        get {
            return self.search("ArtBox").rect ?? cropBox
        }
        set {
            self.object["ArtBox"] = newValue.map(PDFObject.init) ?? nil
        }
    }
}

extension PDFPage {
    
    public var resources: PDFObject {
        get {
            
            var object = self.object
            var value: PDFObject = [:]
            
            repeat {
                value = value.merging(object["Resources"]) { _, rhs in rhs }
                object = object["Parent"]
            } while value == nil && object != nil
            
            return value._apply_xref(self.object.xref)
        }
        set {
            self.object["Resources"] = newValue
        }
    }
    
    public var contents: PDFStream? {
        return self.object["Contents"].stream
    }
}

extension PDFPage {
    
    public var colorSpaces: Set<PDFColorSpace> {
        let colorSpaces = resources["ColorSpace"].dictionary?.values.compactMap { PDFColorSpace($0) } ?? []
        return Set(colorSpaces)
    }
}
