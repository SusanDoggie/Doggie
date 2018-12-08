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
    
    var sample: Image<ARGB32ColorPixel> = {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)
        
        context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
        
        context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
        
        context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
        
        return context.image
    }()
    
    let shape = try! Shape(code: "M184.529,100c0-100-236.601,36.601-150,86.601c86.599,50,86.599-223.2,0-173.2C-52.071,63.399,184.529,200,184.529,100z")
    
    let mask = try! Shape(code: "M100.844,122.045c1.51-14.455,1.509-29.617-0.001-44.09c17.241-7.306,33.295-11.16,46.526-11.16c28.647,0,34.66,18.057,34.66,33.205c0,11.428-3.231,20.032-9.604,25.573c-5.826,5.064-14.252,7.632-25.048,7.632c-0.002,0-0.005,0-0.007,0C134.13,133.204,118.076,129.349,100.844,122.045z M57.276,96.89c11.771-8.541,24.9-16.122,38.18-22.044C91.51,43.038,78.813,9.759,54.625,9.759c-5.832,0-12.172,1.954-18.846,5.807c-11.233,6.485-17.211,14.737-17.766,24.525C17.084,56.461,31.729,77.609,57.276,96.89z M35.779,184.436c6.673,3.853,13.014,5.807,18.846,5.807c24.184,0,36.883-33.279,40.832-65.088c-13.283-5.925-26.413-13.506-38.181-22.045c-25.547,19.281-40.192,40.43-39.263,56.801C18.568,169.699,24.546,177.95,35.779,184.436z M61.514,100c10.717,7.645,22.534,14.467,34.517,19.929c1.261-13.099,1.261-26.743-0.001-39.857C84.05,85.531,72.234,92.354,61.514,100z")
    
    func testDrawing() {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .black)
        
        context.setClip(shape: mask, winding: .nonZero)
        
        context.beginTransparencyLayer()
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .white)
        context.draw(shape: shape, winding: .nonZero, color: .black)
        
        context.endTransparencyLayer()
        
        XCTAssertTrue(context.image.pixels.allSatisfy { $0.color == .black })
    }
    
    func testShapeRegionNonZero() {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .black)
        
        context.setClip(shape: mask, winding: .nonZero)
        
        context.beginTransparencyLayer()
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .white)
        
        let region = ShapeRegion(shape, winding: .nonZero)
        context.draw(shape: region.shape, winding: .nonZero, color: .black)
        
        context.endTransparencyLayer()
        
        XCTAssertTrue(context.image.pixels.allSatisfy { $0.color == .black })
    }
    
    func testShapeRegionEvenOdd() {
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .black)
        
        context.setClip(shape: mask, winding: .nonZero)
        
        context.beginTransparencyLayer()
        
        context.draw(rect: Rect(x: 0, y: 0, width: 500, height: 500), color: .white)
        
        let region = ShapeRegion(shape, winding: .nonZero)
        context.draw(shape: region.shape, winding: .evenOdd, color: .black)
        
        context.endTransparencyLayer()
        
        XCTAssertTrue(context.image.pixels.allSatisfy { $0.color == .black })
    }
    
    func testClipPerformance() {
        
        self.measure() {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
            
            context.setClip(shape: Shape(ellipseIn: Rect(x: 20, y: 20, width: 460, height: 460)), winding: .nonZero)
            
            context.scale(5)
            
            let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
            let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
            
            context.drawLinearGradient(stops: [stop1, stop2], start: Point(x: 50, y: 50), end: Point(x: 250, y: 250), startSpread: .pad, endSpread: .pad)
            
        }
    }
    
    func testLinearGradientPerformance() {
        
        self.measure() {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
            
            context.scale(5)
            
            let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
            let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
            
            context.drawLinearGradient(stops: [stop1, stop2], start: Point(x: 50, y: 50), end: Point(x: 250, y: 250), startSpread: .pad, endSpread: .pad)
            
        }
    }
    
    func testRadialGradientPerformance() {
        
        self.measure() {
            
            let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
            
            context.scale(5)
            
            let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
            let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
            
            context.drawRadialGradient(stops: [stop1, stop2], start: Point(x: 100, y: 150), startRadius: 0, end: Point(x: 150, y: 150), endRadius: 100, startSpread: .pad, endSpread: .pad)
            
        }
    }
    
    func testColorSpaceConversionPerformance() {
        
        let sampleA = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sampleA.colorSpace)
        
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
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .none
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLinearPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .linear
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCosinePerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .cosine
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCubicPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .cubic
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingHermitePerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .hermite(0.5, 0)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingMitchellPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .mitchell(1/3, 1/3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLanczosPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = false
        context.resamplingAlgorithm = .lanczos(3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingNoneAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .none
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLinearAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .linear
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCosineAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .cosine
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingCubicAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .cubic
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingHermiteAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .hermite(0.5, 0)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingMitchellAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .mitchell(1/3, 1/3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
    func testResamplingLanczosAntialiasPerformance() {
        
        let sample = self.sample
        
        let context = ImageContext<ARGB32ColorPixel>(width: 50, height: 50, colorSpace: sample.colorSpace)
        
        context.shouldAntialias = true
        context.resamplingAlgorithm = .lanczos(3)
        
        self.measure() {
            
            context.draw(image: sample, transform: SDTransform.scale(x: Double(context.width) / Double(sample.width), y: Double(context.height) / Double(sample.height)))
        }
    }
    
}
