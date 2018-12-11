//
//  ImageCodecTest.swift
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

import Doggie
import XCTest

class ImageCodecTest: XCTestCase {
    
    var sample1: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 100, height: 100), color: .white)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    var sample2: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    func testPng1() {
        
        guard let data = sample1.pngRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testPng2() {
        
        guard let data = sample2.pngRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testBmp1() {
        
        guard let data = sample1.representation(using: .bmp, properties: [:]) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testBmp2() {
        
        guard let data = sample2.representation(using: .bmp, properties: [:]) else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff1() {
        
        guard let data = sample1.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff2() {
        
        guard let data = sample2.tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
    func testTiff3() {
        
        guard let data = Image<FloatColorPixel<LabColorModel>>(image: sample1, colorSpace: .default).tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample1.pixels, result.pixels)
    }
    
    func testTiff4() {
        
        guard let data = Image<FloatColorPixel<LabColorModel>>(image: sample2, colorSpace: .default).tiffRepresentation else {
            XCTFail()
            return
        }
        
        guard let result = try? Image<ARGB32ColorPixel>(image: AnyImage(data: data), colorSpace: .sRGB) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(sample2.pixels, result.pixels)
    }
    
}
