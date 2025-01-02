//
//  GeometryTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

class GeometryTest: XCTestCase {
    
    func testRectNull() {
        
        let rect = Rect.null
        
        XCTAssertEqual(rect, .null)
        XCTAssertNotEqual(rect, .infinite)
        
        XCTAssertEqual(rect.standardized, .null)
        
        XCTAssertEqual(Rect(x: .infinity, y: .infinity, width: 0, height: 0), .null)
        XCTAssertEqual(Rect(x: .infinity, y: .infinity, width: 10, height: 10), .null)
        XCTAssertEqual(Rect(x: .infinity, y: .infinity, width: -10, height: -10), .null)
        XCTAssertEqual(Rect(x: .infinity, y: 0, width: 0, height: 0), .null)
        XCTAssertEqual(Rect(x: 0, y: .infinity, width: 0, height: 0), .null)
        XCTAssertNotEqual(Rect(x: 0, y: 0, width: 0, height: 0), .null)
        
        XCTAssertFalse(rect.contains(Point(x: 0, y: 10.1)))
        XCTAssertFalse(rect.contains(Rect(x: 0, y: 3.4, width: -10, height: 20.2)))
        
    }
    
    func testRectInfinite() {
        
        let rect = Rect.infinite
        
        XCTAssertNotEqual(rect, .null)
        XCTAssertEqual(rect, .infinite)
        
        XCTAssertEqual(rect.standardized, .infinite)
        
        XCTAssertEqual(rect.minX, -.infinity)
        XCTAssertEqual(rect.minY, -.infinity)
        
        XCTAssertEqual(rect.maxX, .infinity)
        XCTAssertEqual(rect.maxY, .infinity)
        
        XCTAssertEqual(rect.width, .infinity)
        XCTAssertEqual(rect.height, .infinity)
        
        XCTAssertTrue(rect.contains(Point(x: 0, y: 10.1)))
        XCTAssertTrue(rect.contains(Rect(x: 0, y: 3.4, width: -10, height: 20.2)))
        
    }
    
    func testRectNullUnion() {
        
        let r1 = Rect.null
        let r2 = Rect(x: 0, y: -1, width: 60, height: 90)
        
        XCTAssertEqual(r1.union(r2), r2)
        XCTAssertEqual(r2.union(r1), r2)
        
        XCTAssertEqual(r1.union(.infinite), .infinite)
        XCTAssertEqual(Rect.infinite.union(r1), .infinite)
    }
    
    func testRectInfiniteUnion() {
        
        let r1 = Rect.infinite
        let r2 = Rect(x: 0, y: -1, width: 60, height: 90)
        
        XCTAssertEqual(r1.union(r2), .infinite)
        XCTAssertEqual(r2.union(r1), .infinite)
        
    }
    
    func testRectNullIntersect() {
        
        let r1 = Rect.null
        let r2 = Rect(x: 0, y: -1, width: 60, height: 90)
        
        XCTAssertFalse(r1.isIntersect(r2))
        XCTAssertFalse(r2.isIntersect(r1))
        
        XCTAssertEqual(r1.intersect(r2), .null)
        XCTAssertEqual(r2.intersect(r1), .null)
        
        XCTAssertFalse(r1.isIntersect(.null))
        XCTAssertEqual(r1.intersect(.null), .null)
        XCTAssertFalse(r1.isIntersect(.infinite))
        
        XCTAssertEqual(r1.intersect(.infinite), .null)
        XCTAssertEqual(Rect.infinite.intersect(r1), .null)
        
    }
    
    func testRectInfiniteIntersect() {
        
        let r1 = Rect.infinite
        let r2 = Rect(x: 0, y: -1, width: 60, height: 90)
        
        XCTAssertTrue(r1.isIntersect(r1))
        XCTAssertEqual(r1.intersect(r1), r1)
        
        XCTAssertTrue(r1.isIntersect(r2))
        XCTAssertTrue(r2.isIntersect(r1))
        
        XCTAssertEqual(r1.intersect(r2), r2)
        XCTAssertEqual(r2.intersect(r1), r2)
        
        XCTAssertTrue(r1.isIntersect(.infinite))
        
    }
    
}
