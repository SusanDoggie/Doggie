//
//  PDFContextTest.swift
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

import Doggie
import XCTest

class PDFContextTest: XCTestCase {
    
    func testDrawing() throws {
        
        let image: Image<ARGB32ColorPixel> = {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
            
            context.draw(rect: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel.red)
            
            return context.image
        }()
        
        let pdf_data: Data = try {
            
            let context = PDFContext(width: 100, height: 100, colorSpace: .sRGB)
            
            context.draw(rect: Rect(x: 10, y: 35, width: 55, height: 55), color: AnyColor.red)
            
            return try context.data()
        }()
        
        let pdf_image: Image<ARGB32ColorPixel> = try {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
            
            let doc = try PDFDocument(data: pdf_data)
            
            context.draw(doc[0])
            
            return context.image
        }()
        
        XCTAssertEqual(image.pixels, pdf_image.pixels)
    }
    
    func testClipping() throws {
        
        let image: Image<ARGB32ColorPixel> = {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
            
            context.clip(rect: Rect(x: 10, y: 35, width: 55, height: 55))
            
            context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: RGBColorModel.red)
            
            return context.image
        }()
        
        let pdf_data: Data = try {
            
            let context = PDFContext(width: 100, height: 100, colorSpace: .sRGB)
            
            context.clip(rect: Rect(x: 10, y: 35, width: 55, height: 55))
            
            context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: AnyColor.red)
            
            return try context.data()
        }()
        
        let pdf_image: Image<ARGB32ColorPixel> = try {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
            
            let doc = try PDFDocument(data: pdf_data)
            
            context.draw(doc[0])
            
            return context.image
        }()
        
        XCTAssertEqual(image.pixels, pdf_image.pixels)
    }
}
