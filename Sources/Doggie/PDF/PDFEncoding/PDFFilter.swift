//
//  PDFFilter.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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

fileprivate func _PDFFilterDecode(_ name: PDFDocument.Name, _ data: Data) throws -> Data {
    
    switch name.name {
    case "ASCIIHexDecode": return try PDFASCIIHexDecode(data)
    case "ASCII85Decode": return try PDFASCII85Decode(data)
    case "LZWDecode": return try PDFLZWDecode(data)
    case "FlateDecode": return try Inflate().process(data)
    case "RunLengthDecode": return try PDFRunLengthDecode(data)
    default: return data
    }
}

public func PDFFilterDecode(_ dict: PDFDocument.Dictionary, _ data: Data) throws -> Data {
    
    var data = data
    
    let predictor = dict["DecodeParms"]?["Predictor"].intValue ?? 1
    let colors = dict["DecodeParms"]?["Colors"].intValue ?? 1
    let bitsPerComponent = dict["DecodeParms"]?["BitsPerComponent"].intValue ?? 8
    let columns = dict["DecodeParms"]?["Columns"].intValue ?? 1
    
    if let filter = dict["Filter"] {
        switch filter {
        case let .name(name):
            data = try _PDFFilterDecode(name, data)
            if name == "LZWDecode" || name == "FlateDecode" {
                switch predictor {
                case 2: data = PDFPredictor(data, .TIFF2, colors, bitsPerComponent, columns)
                case 10: data = PDFPredictor(data, .PNGNone, colors, bitsPerComponent, columns)
                case 11: data = PDFPredictor(data, .PNGSub, colors, bitsPerComponent, columns)
                case 12: data = PDFPredictor(data, .PNGUp, colors, bitsPerComponent, columns)
                case 13: data = PDFPredictor(data, .PNGAverage, colors, bitsPerComponent, columns)
                case 14: data = PDFPredictor(data, .PNGPaeth, colors, bitsPerComponent, columns)
                case 15: data = PDFPredictor(data, .PNGOptimum, colors, bitsPerComponent, columns)
                default: break
                }
            }
        case let .array(array):
            loop: for filter in array {
                switch filter {
                case let .name(name):
                    data = try _PDFFilterDecode(name, data)
                    if name == "LZWDecode" || name == "FlateDecode" {
                        switch predictor {
                        case 2: data = PDFPredictor(data, .TIFF2, colors, bitsPerComponent, columns)
                        case 10: data = PDFPredictor(data, .PNGNone, colors, bitsPerComponent, columns)
                        case 11: data = PDFPredictor(data, .PNGSub, colors, bitsPerComponent, columns)
                        case 12: data = PDFPredictor(data, .PNGUp, colors, bitsPerComponent, columns)
                        case 13: data = PDFPredictor(data, .PNGAverage, colors, bitsPerComponent, columns)
                        case 14: data = PDFPredictor(data, .PNGPaeth, colors, bitsPerComponent, columns)
                        case 15: data = PDFPredictor(data, .PNGOptimum, colors, bitsPerComponent, columns)
                        default: break
                        }
                    }
                default: break loop
                }
            }
        default: break
        }
    }
    
    return data
}
