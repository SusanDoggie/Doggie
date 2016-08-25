//
//  SDMarkerTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

class SDMarkerTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testVariable() {
        
        let marker: SDMarker = " {{%Var1%}} {{% Var2%}} {{%Var3 %}} "
        
        XCTAssertEqual(marker.render(["Var1": 1, "Var2": 2, "Var3": 3]), " 1 2 3 ")
        
    }
    func testBoolean() {
        
        let marker: SDMarker = " {{#bool_1 #}}{{%bool_1%}}{{# bool_1#}} {{#bool_2 #}}{{%bool_2%}} {{# bool_2#}}"
        
        XCTAssertEqual(marker.render(["bool_1": true, "bool_2": false]), " true ")
        
    }
    func testLoop() {
        
        let marker: SDMarker = "{{#loop #}} {{%loop%}}{{# loop#}} "
        
        XCTAssertEqual(marker.render(["loop": 3]), " 0 1 2 ")
        
    }
    func testArray() {
        
        let marker: SDMarker = "{{#array #}} {{%var%}}{{# array#}} "
        
        XCTAssertEqual(marker.render([
            
            "array": [
                ["var": 1],
                ["var": 2],
                ["var": 3]
            ]
            
            ]), " 1 2 3 ")
        
    }
    func testObject() {
        
        let marker: SDMarker = "{{#array #}} {{%var%}}{{# array#}} "
        
        XCTAssertEqual(marker.render([
            
            "array": [
                "var": 1
            ]
            
            ]), " 1 ")
        
    }
    func testNestedSection() {
        
        let marker: SDMarker = "{{# section_1 #}}{{# section_2 #}} {{% section_1 %}}{{% section_2 %}}{{# section_2 #}}{{# section_1 #}} "
        
        XCTAssertEqual(marker.render([
            
            "section_1": [
                ["section_1": 0, "section_2": 5],
                ["section_1": 1, "section_2": 5],
                ["section_1": 2, "section_2": 5],
                ["section_1": 3, "section_2": 5],
                ["section_1": 4, "section_2": 5],
            ]
            
            ]), " 00 01 02 03 04 10 11 12 13 14 20 21 22 23 24 30 31 32 33 34 40 41 42 43 44 ")
        
    }
}
