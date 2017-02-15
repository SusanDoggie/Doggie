//
//  ImageTest.swift
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
import Doggie
import XCTest

class ImageTest: XCTestCase {
    
    static let allTests = [
        ("testResamplingNonePerformance", testResamplingNonePerformance),
        ("testResamplingLinearPerformance", testResamplingLinearPerformance),
        ("testResamplingCosinePerformance", testResamplingCosinePerformance),
        ("testResamplingCubicPerformance", testResamplingCubicPerformance),
        ("testResamplingMitchellPerformance", testResamplingMitchellPerformance),
        ("testResamplingLanczosPerformance", testResamplingLanczosPerformance),
        ]
    
    var sample: Image = {
        
        let srgb = CalibratedRGBColorSpace(white: XYZColorModel(luminance: 1, x: 0.3127, y: 0.3290), black: XYZColorModel(luminance: 0, x: 0.3127, y: 0.3290), red: XYZColorModel(luminance: 0.2126, x: 0.6400, y: 0.3300), green: XYZColorModel(luminance: 0.7152, x: 0.3000, y: 0.6000), blue: XYZColorModel(luminance: 0.0722, x: 0.1500, y: 0.0600))
        
        var sample = Image(width: 100, height: 100, pixel: ARGB32ColorPixel(), colorSpace: srgb)
        
        #if os(macOS)
            if #available(OSX 10.12, *) {
                let _colorspace = CGColorSpace(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB()
                let _bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
                
                func createImage(data rawData: UnsafeRawPointer, size: CGSize) -> CGImage? {
                    
                    let imageWidth = Int(size.width)
                    let imageHeight = Int(size.height)
                    
                    let bitsPerComponent: Int = 8
                    let bytesPerPixel: Int = 4
                    let bitsPerPixel: Int = bytesPerPixel * bitsPerComponent
                    
                    let bytesPerRow = bytesPerPixel * imageWidth
                    
                    return CGImage.create(rawData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: _colorspace, bitmapInfo: _bitmapInfo)
                }
                
                sample.withUnsafeMutableBytes {
                    if let context = CGContext(data: $0.baseAddress!, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 400, space: _colorspace, bitmapInfo: _bitmapInfo) {
                        
                        context.setStrokeColor(NSColor.black.cgColor)
                        context.setFillColor(NSColor(calibratedRed: 247/255, green: 217/255, blue: 12/255, alpha: 1).cgColor)
                        
                        context.fillEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
                        context.strokeEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
                        
                        context.setFillColor(NSColor(calibratedRed: 234/255, green: 24/255, blue: 71/255, alpha: 1).cgColor)
                        
                        context.fillEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
                        context.strokeEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
                        
                    }
                }
                
            }
        #endif
        
        return sample
    }()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testResamplingNonePerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .none)
        }
    }
    
    func testResamplingLinearPerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .linear)
        }
    }
    
    func testResamplingCosinePerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .cosine)
        }
    }
    
    func testResamplingCubicPerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .cubic)
        }
    }
    
    func testResamplingMitchellPerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .mitchell(1/3, 1/3))
        }
    }
    
    func testResamplingLanczosPerformance() {
        // This is an example of a performance test case.
        
        let sample = self.sample
        let transform = SDTransform.Scale(x: 10, y: 10)
        
        self.measure() {
            // Put the code you want to measure the time of here.
            _ = Image(image: sample, width: 1000, height: 1000, transform: transform, resampling: .lanczos(3))
        }
    }
    
}
