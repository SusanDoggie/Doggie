//
//  ShapeRegionTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

class ShapeRegionTest: XCTestCase {
    
    func check_equal(_ shape1: Shape, _ winding1: Shape.WindingRule, _ shape2: Shape, _ winding2: Shape.WindingRule) -> Bool {
        
        var shape1 = shape1
        var shape2 = shape2
        
        let size1 = shape1.boundary.size
        let size2 = shape2.boundary.size
        
        let width = Int(max(size1.width, size2.width)) + 10
        let height = Int(max(size1.height, size2.height)) + 10
        
        shape1.center = Point(x: 0.5 * Double(width), y: 0.5 * Double(height))
        shape2.center = Point(x: 0.5 * Double(width), y: 0.5 * Double(height))
        
        let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
        
        context.draw(rect: Rect(x: 0, y: 0, width: width, height: height), color: .black)
        
        context.clipToDrawing { (context: ImageContext<Gray16ColorPixel>) in
            
            context.draw(shape: shape2, winding: winding2, color: .white)
            context.stroke(shape: shape2, width: 5, cap: .round, join: .round, color: .black)
        }
        
        context.beginTransparencyLayer()
        
        context.draw(rect: Rect(x: 0, y: 0, width: width, height: height), color: .white)
        
        context.draw(shape: shape1, winding: winding1, color: .black)
        
        context.endTransparencyLayer()
        
        return context.image.pixels.allSatisfy { $0.color == .black }
    }
    
    func testShapeRegionUnion() {
        
        let shape1 = try! Shape(code: "M81.867,25.83 C72.631,31.632,61.711,35,50,35c-11.712,0-22.631-3.368-31.867-9.17C13.033,32.545,10,40.917,10,50 c0,9.082,3.032,17.454,8.132,24.169c9.235-5.803,20.155-9.171,31.867-9.171s22.632,3.368,31.868,9.171 C86.968,67.455,90,59.083,90,50C90,40.917,86.968,32.544,81.867,25.83z")
        
        var shape2 = shape1
        shape2.translate(x: -50, y: -50)
        shape2.rotate(0.5 * .pi)
        shape2.translate(x: 50, y: 50)
        
        let region1 = ShapeRegion(shape1, winding: .nonZero)
        let region2 = ShapeRegion(shape2, winding: .nonZero)
        
        let result = region1.union(region2)
        
        let answer = try! Shape(code: "M90,50c0-9.083-3.032-17.456-8.133-24.17 c-4.388,2.756-9.158,4.955-14.21,6.512c1.558-5.052,3.756-9.822,6.513-14.21C67.455,13.033,59.082,10,50,10 c-9.082,0-17.454,3.032-24.169,8.132c2.757,4.388,4.956,9.159,6.514,14.211c-5.052-1.558-9.823-3.756-14.211-6.513 C13.033,32.545,10,40.917,10,50c0,9.082,3.032,17.454,8.132,24.169c4.388-2.757,9.16-4.956,14.212-6.514 c-1.558,5.052-3.757,9.824-6.514,14.212C32.544,86.968,40.917,90,50,90c9.083,0,17.456-3.032,24.17-8.133 c-2.757-4.388-4.956-9.159-6.513-14.211c5.052,1.558,9.822,3.756,14.21,6.513C86.968,67.455,90,59.083,90,50z")
        
        XCTAssertTrue(check_equal(Shape(result), .nonZero, answer, .nonZero))
    }
    
    func testShapeRegionIntersection() {
        
        let shape1 = try! Shape(code: "M81.867,25.83 C72.631,31.632,61.711,35,50,35c-11.712,0-22.631-3.368-31.867-9.17C13.033,32.545,10,40.917,10,50 c0,9.082,3.032,17.454,8.132,24.169c9.235-5.803,20.155-9.171,31.867-9.171s22.632,3.368,31.868,9.171 C86.968,67.455,90,59.083,90,50C90,40.917,86.968,32.544,81.867,25.83z")
        
        var shape2 = shape1
        shape2.translate(x: -50, y: -50)
        shape2.rotate(0.5 * .pi)
        shape2.translate(x: 50, y: 50)
        
        let region1 = ShapeRegion(shape1, winding: .nonZero)
        let region2 = ShapeRegion(shape2, winding: .nonZero)
        
        let result = region1.intersection(region2)
        
        let answer = try! Shape(code: "M35.001,49.999 c0,6.148-0.936,12.074-2.657,17.657c5.582-1.722,11.507-2.657,17.655-2.657c6.148,0,12.075,0.937,17.658,2.658 C65.936,62.073,65,56.147,65,50c0-6.148,0.936-12.075,2.657-17.657C62.074,34.063,56.148,35,50,35 c-6.148,0-12.073-0.936-17.656-2.657C34.065,37.925,35.001,43.851,35.001,49.999z")
        
        XCTAssertTrue(check_equal(Shape(result), .nonZero, answer, .nonZero))
    }
    
    func testShapeRegionSubtracting() {
        
        let shape1 = try! Shape(code: "M81.867,25.83 C72.631,31.632,61.711,35,50,35c-11.712,0-22.631-3.368-31.867-9.17C13.033,32.545,10,40.917,10,50 c0,9.082,3.032,17.454,8.132,24.169c9.235-5.803,20.155-9.171,31.867-9.171s22.632,3.368,31.868,9.171 C86.968,67.455,90,59.083,90,50C90,40.917,86.968,32.544,81.867,25.83z")
        
        var shape2 = shape1
        shape2.translate(x: -50, y: -50)
        shape2.rotate(0.5 * .pi)
        shape2.translate(x: 50, y: 50)
        
        let region1 = ShapeRegion(shape1, winding: .nonZero)
        let region2 = ShapeRegion(shape2, winding: .nonZero)
        
        let result = region1.subtracting(region2)
        
        let answer = try! Shape(code: "M32.344,67.655 c-5.053,1.558-9.825,3.757-14.212,6.514C13.032,67.454,10,59.082,10,50c0-9.083,3.033-17.455,8.133-24.17 c4.388,2.756,9.159,4.955,14.211,6.513c1.721,5.582,2.657,11.508,2.657,17.656C35.001,56.146,34.065,62.072,32.344,67.655z M81.867,25.83c-4.388,2.756-9.158,4.955-14.21,6.512C65.936,37.925,65,43.851,65,50c0,6.148,0.936,12.074,2.657,17.657 c5.052,1.558,9.822,3.756,14.21,6.513C86.968,67.455,90,59.083,90,50S86.968,32.544,81.867,25.83z")
        
        XCTAssertTrue(check_equal(Shape(result), .nonZero, answer, .nonZero))
    }
    
    func testShapeRegionSymmetricDifference() {
        
        let shape1 = try! Shape(code: "M81.867,25.83 C72.631,31.632,61.711,35,50,35c-11.712,0-22.631-3.368-31.867-9.17C13.033,32.545,10,40.917,10,50 c0,9.082,3.032,17.454,8.132,24.169c9.235-5.803,20.155-9.171,31.867-9.171s22.632,3.368,31.868,9.171 C86.968,67.455,90,59.083,90,50C90,40.917,86.968,32.544,81.867,25.83z")
        
        var shape2 = shape1
        shape2.translate(x: -50, y: -50)
        shape2.rotate(0.5 * .pi)
        shape2.translate(x: 50, y: 50)
        
        let region1 = ShapeRegion(shape1, winding: .nonZero)
        let region2 = ShapeRegion(shape2, winding: .nonZero)
        
        let result = region1.symmetricDifference(region2)
        
        let answer = try! Shape(code: "M35.001,49.999 c0,6.148-0.936,12.074-2.657,17.657c-5.053,1.558-9.825,3.757-14.212,6.514C13.032,67.454,10,59.082,10,50 c0-9.083,3.033-17.455,8.133-24.17c4.388,2.756,9.159,4.955,14.211,6.513C34.065,37.925,35.001,43.851,35.001,49.999z M90,50 c0-9.083-3.032-17.456-8.133-24.17c-4.388,2.756-9.158,4.955-14.21,6.512C65.936,37.925,65,43.851,65,50 c0,6.148,0.936,12.074,2.657,17.657c5.052,1.558,9.822,3.756,14.21,6.513C86.968,67.455,90,59.083,90,50z M32.344,67.655 c-1.558,5.052-3.757,9.824-6.514,14.212C32.544,86.968,40.917,90,50,90c9.083,0,17.456-3.032,24.17-8.133 c-2.757-4.388-4.956-9.159-6.513-14.211c-5.583-1.722-11.51-2.658-17.658-2.658C43.852,64.998,37.926,65.934,32.344,67.655z M67.657,32.342c1.558-5.052,3.756-9.822,6.513-14.21C67.455,13.033,59.082,10,50,10c-9.082,0-17.454,3.032-24.169,8.132 c2.757,4.388,4.956,9.159,6.514,14.211C37.927,34.064,43.852,35,50,35C56.148,35,62.074,34.063,67.657,32.342z")
        
        XCTAssertTrue(check_equal(Shape(result), .nonZero, answer, .nonZero))
    }
    
    func testShapeRegionNonZero() {
        
        let shape = try! Shape(code: "M184.529,100c0-100-236.601,36.601-150,86.601c86.599,50,86.599-223.2,0-173.2C-52.071,63.399,184.529,200,184.529,100z")
        
        let region = ShapeRegion(shape, winding: .nonZero)
        XCTAssertTrue(check_equal(Shape(region), .nonZero, shape, .nonZero))
    }
    
    func testShapeRegionEvenOdd() {
        
        let shape = try! Shape(code: "M184.529,100c0-100-236.601,36.601-150,86.601c86.599,50,86.599-223.2,0-173.2C-52.071,63.399,184.529,200,184.529,100z")
        
        let region = ShapeRegion(shape, winding: .evenOdd)
        XCTAssertTrue(check_equal(Shape(region), .nonZero, shape, .evenOdd))
    }
    
}
