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
        ("testColorSpaceConvertionPerformance", testColorSpaceConvertionPerformance),
        ("testResamplingNonePerformance", testResamplingNonePerformance),
        ("testResamplingNonePerformanceB", testResamplingNonePerformanceB),
        ("testResamplingLinearPerformance", testResamplingLinearPerformance),
        ("testResamplingCosinePerformance", testResamplingCosinePerformance),
        ("testResamplingCubicPerformance", testResamplingCubicPerformance),
        ("testResamplingHermitePerformance", testResamplingHermitePerformance),
        ("testResamplingMitchellPerformance", testResamplingMitchellPerformance),
        ("testResamplingLanczosPerformance", testResamplingLanczosPerformance),
        ("testResamplingNoneAntialiasPerformance", testResamplingNoneAntialiasPerformance),
        ("testResamplingLinearAntialiasPerformance", testResamplingLinearAntialiasPerformance),
        ("testResamplingCosineAntialiasPerformance", testResamplingCosineAntialiasPerformance),
        ("testResamplingCubicAntialiasPerformance", testResamplingCubicAntialiasPerformance),
        ("testResamplingHermiteAntialiasPerformance", testResamplingHermiteAntialiasPerformance),
        ("testResamplingMitchellAntialiasPerformance", testResamplingMitchellAntialiasPerformance),
        ("testResamplingLanczosAntialiasPerformance", testResamplingLanczosAntialiasPerformance),
        ]
    
    var sample: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)), color: Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255)), winding: .nonZero)
        
        context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)
        
        context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)), color: Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255)), winding: .nonZero)
        
        context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)
        
        return context.image
    }()
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testColorSpaceConvertionPerformance() {
        
        
        let sampleA = self.sample
        
        let sampleB = Image(image: sampleA, width: 1000, height: 1000, resampling: .none)
        
        self.measure() {
            
            _ = Image<ARGB32ColorPixel>(image: sampleB, colorSpace: ColorSpace.adobeRGB)
        }
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
    
    func testResamplingHermitePerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 1000, height: 1000, resampling: .hermite(0.5, 0))
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
    
    func testResamplingNoneAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .none, antialias: true)
        }
    }
    
    func testResamplingLinearAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .linear, antialias: true)
        }
    }
    
    func testResamplingCosineAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .cosine, antialias: true)
        }
    }
    
    func testResamplingCubicAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .cubic, antialias: true)
        }
    }
    
    func testResamplingHermiteAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .hermite(0.5, 0), antialias: true)
        }
    }
    
    func testResamplingMitchellAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .mitchell(1/3, 1/3), antialias: true)
        }
    }
    
    func testResamplingLanczosAntialiasPerformance() {
        
        
        let sample = self.sample
        
        self.measure() {
            
            _ = Image(image: sample, width: 200, height: 200, resampling: .lanczos(3), antialias: true)
        }
    }
    
}
