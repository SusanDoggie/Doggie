//
//  CompressionTest.swift
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

class CompressionTest: XCTestCase {
    
    static let allTests = [
        ("testZlib", testZlib),
        ("testGzip", testGzip),
        ("testDeflatePerformance", testDeflatePerformance),
        ("testInflatePerformance", testInflatePerformance),
        ]
    
    let sample = ColorSpace.adobeRGB.iccData!
    
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        
        super.tearDown()
    }
    
    func testZlib() {
        
        do {
            
            let deflate = try Deflate(windowBits: 15)
            let inflate = try Inflate()
            
            let sample = self.sample
            
            let result = try inflate.process(deflate.process(self.sample))
            
            XCTAssertEqual(result, sample)
            
        } catch let error {
            
            XCTFail("\(error)")
            
        }
        
    }
    
    func testGzip() {
        
        do {
            
            let deflate = try Deflate(windowBits: 15 + 16)
            let inflate = try Inflate()
            
            let sample = self.sample
            
            let result = try inflate.process(deflate.process(self.sample))
            
            XCTAssertEqual(result, sample)
            
        } catch let error {
            
            XCTFail("\(error)")
            
        }
        
    }
    
    func testDeflatePerformance() {
        
        let sample = self.sample
        
        self.measure() {
            
            do {
                
                let deflate = try Deflate(windowBits: 15)
                
                XCTAssert(try deflate.process(sample).count > 0)
                
            } catch let error {
                
                XCTFail("\(error)")
                
            }
        }
    }
    
    func testInflatePerformance() {
        
        do {
            
            let deflate = try Deflate(windowBits: 15)
            
            let sample = try deflate.process(self.sample)
            
            self.measure() {
                
                do {
                    
                    let inflate = try Inflate()
                    
                    XCTAssert(try inflate.process(sample).count > 0)
                    
                } catch let error {
                    
                    XCTFail("\(error)")
                    
                }
                
            }
            
        } catch let error {
            
            XCTFail("\(error)")
            
        }
        
    }
    
}
