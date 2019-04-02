//
//  PDFArray.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

public struct PDFArray : PDFObject, RandomAccessCollection, MutableCollection, ExpressibleByArrayLiteral {
    
    var elements: [PDFObject]
    
    public init() {
        self.elements = []
    }
    
    public init(_ elements: [PDFObject]) {
        self.elements = elements
    }
}

extension PDFArray {
    
    public init(arrayLiteral elements: PDFObject ...) {
        self.init(elements)
    }
}

extension PDFArray {
    
    public var startIndex: Int {
        return elements.startIndex
    }
    
    public var endIndex: Int {
        return elements.endIndex
    }
    
    public subscript(position: Int) -> PDFObject {
        get {
            return elements[position]
        }
        set {
            elements[position] = newValue
        }
    }
}

extension PDFArray {
    
    public func write(to data: inout Data) {
        data.append(utf8: "[\n")
        for element in elements {
            element.write(to: &data)
            data.append(utf8: "\n")
        }
        data.append(utf8: "]\n")
    }
}
