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
        ("testResamplingNonePerformanceB", testResamplingNonePerformanceB),
        ("testResamplingLinearPerformance", testResamplingLinearPerformance),
        ("testResamplingCosinePerformance", testResamplingCosinePerformance),
        ("testResamplingCubicPerformance", testResamplingCubicPerformance),
        ("testResamplingMitchellPerformance", testResamplingMitchellPerformance),
        ("testResamplingLanczosPerformance", testResamplingLanczosPerformance),
        ]
    
    var sample: Image = {
        
        var sample = Image(width: 100, height: 100, pixel: ARGB32ColorPixel(), colorSpace: CalibratedRGBColorSpace.linearSRGB)
        
        #if os(macOS)
            if #available(OSX 10.12, *) {
                let _colorspace = CGColorSpace(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB()
                let _bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
                
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
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testResamplingNonePerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .none)
        }
    }
    
    func testResamplingNonePerformanceB() {
        
        
        let sampleA = self.sample
        
        let sampleB = Image(image: sampleA, width: 1920, height: 1080, resampling: .none)
        
        self.measure() {
            
            _ = Image(image: sampleB, width: 3840, height: 2160, resampling: .none)
        }
    }
    
    func testResamplingLinearPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .linear)
        }
    }
    
    func testResamplingCosinePerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .cosine)
        }
    }
    
    func testResamplingCubicPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .cubic)
        }
    }
    
    func testResamplingMitchellPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .mitchell(1/3, 1/3))
        }
    }
    
    func testResamplingLanczosPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .lanczos(3))
        }
    }
    
}
