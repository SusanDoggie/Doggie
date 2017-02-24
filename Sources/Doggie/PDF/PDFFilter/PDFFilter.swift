//
//  PDFFilter.swift
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

import Foundation

public struct PDFFilterError: Error {
    
    public var message: String
}

private func _PDFFilterDecode(_ name: PDFDocument.Name, _ data: Data) throws -> Data {
    
    switch name.name {
    case "ASCIIHexDecode": return try PDFASCIIHexDecode(data)
    case "ASCII85Decode": return try PDFASCII85Decode(data)
    case "FlateDecode": return try data.gunzipped()
    default: return data
    }
}

public func PDFFilterDecode(_ dict: PDFDocument.Dictionary, _ data: Data) throws -> Data {
    
    var data = data
    
    if let filter = dict["Filter"] {
        switch filter {
        case let .name(name): data = try _PDFFilterDecode(name, data)
        case let .array(array):
            loop: for filter in array {
                switch filter {
                case let .name(name): data = try _PDFFilterDecode(name, data)
                default: break loop
                }
            }
        default: break
        }
    }
    
    return data
}
