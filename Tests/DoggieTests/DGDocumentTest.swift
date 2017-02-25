//
//  DGDocumentTest.swift
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

class DGDocumentTest: XCTestCase {
    
    static let allTests = [
        ("testArray", testArray),
        ("testIncrementUpdate", testIncrementUpdate),
        ]
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testArray() {
        
        let sample = "%DOG\n[@5 hello @2 ,  @5 World]\n%XREF\n0 5\n0\n%%EOF"
        
        do {
            
            let document = try DGDocument.Parse(data: Data(sample.utf8))
            
            XCTAssertEqual(document.rootId, 0)
            
            XCTAssertEqual(document.table[0]?.array?.count, 3)
            
            XCTAssertEqual(document.table[0]?.array?[0].stringValue, "hello")
            
            XCTAssertEqual(document.table[0]?.array?[1].stringValue, ", ")
            
            XCTAssertEqual(document.table[0]?.array?[2].stringValue, "World")
            
        } catch let error {
            
            XCTFail("\(error)")
        }
    }
    
    func testIncrementUpdate() {
        
        let sample = "%DOG\n[@5 Hello &1]\n@5 World\n%XREF\n0 5 19\n0\n%%EOF\n[&1]\n%XREF 41\n0 49\n0\n%%EOF"
        
        do {
            
            let document = try DGDocument.Parse(data: Data(sample.utf8))
            
            XCTAssertEqual(document.rootId, 0)
            
            XCTAssertEqual(document.table[0]?.array?.count, 1)
            
            XCTAssertEqual(document.table[0]?.array?[0].identifier, 1)
            
            XCTAssertEqual(document.table[1]?.stringValue, "World")
            
        } catch let error {
            
            XCTFail("\(error)")
        }
    }
    
}
