//
//  ImageTest.swift
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

class ImageTest: XCTestCase {
    
    static let allTests = [
        ("testColorSpaceConversionPerformance", testColorSpaceConversionPerformance),
        ("testResamplingNonePerformance", testResamplingNonePerformance),
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
        
        context.draw(shape: Shape(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(shape: Shape(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55)), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(shape: Shape(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(shape: Shape(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55)), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testColorSpaceConversionPerformance() {
        
        let sampleA = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sampleA.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .none
        
        context.draw(image: sampleA, transform: SDTransform.scale(x: Double(context.width) / Double(sampleA.width), y: Double(context.height) / Double(sampleA.height)))
        
        let sampleB = context.image
        
        self.measure() {
            
            _ = Image<ARGB32ColorPixel>(image: sampleB, colorSpace: ColorSpace.adobeRGB)
        }
    }
    
    func testResamplingNonePerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .none
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLinearPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .linear
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCosinePerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .cosine
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCubicPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .cubic
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingHermitePerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .hermite(0.5, 0)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingMitchellPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .mitchell(1/3, 1/3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLanczosPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .lanczos(3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingNoneAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .none
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLinearAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .linear
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCosineAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .cosine
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCubicAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .cubic
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingHermiteAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .hermite(0.5, 0)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingMitchellAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .mitchell(1/3, 1/3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLanczosAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 20, height: 20, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .lanczos(3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
}
