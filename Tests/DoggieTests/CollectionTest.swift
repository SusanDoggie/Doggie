//
//  CollectionTest.swift
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

class CollectionTest: XCTestCase {
    
    func testCollectionRangeOf() {
        
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        XCTAssertEqual(array.range(of: [1, 2, 3]), 0..<3)
        XCTAssertEqual(array.range(of: [7, 8, 9]), 6..<9)
        XCTAssertEqual(array.range(of: [3, 4, 5]), 2..<5)
        XCTAssertEqual(array.range(of: [1, 4, 5]), nil)
    }
    
    func testNextPermute1() {
        
        var array = [1, 2, 3]
        
        let answer = [
            [1, 2, 3],
            [1, 3, 2],
            [2, 1, 3],
            [2, 3, 1],
            [3, 1, 2],
            [3, 2, 1],
            ]
        
        for _answer in answer {
            
            XCTAssertEqual(array, _answer)
            
            array.nextPermute()
        }
    }
    
    func testNextPermute2() {
        
        var array = [1, 2, 2, 3, 3]
        
        let answer = [
            [1, 2, 2, 3, 3],
            [1, 2, 3, 2, 3],
            [1, 2, 3, 3, 2],
            [1, 3, 2, 2, 3],
            [1, 3, 2, 3, 2],
            [1, 3, 3, 2, 2],
            [2, 1, 2, 3, 3],
            [2, 1, 3, 2, 3],
            [2, 1, 3, 3, 2],
            [2, 2, 1, 3, 3],
            [2, 2, 3, 1, 3],
            [2, 2, 3, 3, 1],
            [2, 3, 1, 2, 3],
            [2, 3, 1, 3, 2],
            [2, 3, 2, 1, 3],
            [2, 3, 2, 3, 1],
            [2, 3, 3, 1, 2],
            [2, 3, 3, 2, 1],
            [3, 1, 2, 2, 3],
            [3, 1, 2, 3, 2],
            [3, 1, 3, 2, 2],
            [3, 2, 1, 2, 3],
            [3, 2, 1, 3, 2],
            [3, 2, 2, 1, 3],
            [3, 2, 2, 3, 1],
            [3, 2, 3, 1, 2],
            [3, 2, 3, 2, 1],
            [3, 3, 1, 2, 2],
            [3, 3, 2, 1, 2],
            [3, 3, 2, 2, 1],
            ]
        
        for _answer in answer {
            
            XCTAssertEqual(array, _answer)
            
            array.nextPermute()
        }
    }
    
    func testIndexedCollection() {
        
        let a = [1, 2, 3, 4, 5, 6, 7, 8, 9][1..<6]
        
        let result = a.indexed()
        let answer = [(1, 2), (2, 3), (3, 4), (4, 5), (5, 6)]
        
        XCTAssert(result.elementsEqual(answer) { $0.0 == $1.0 && $0.1 == $1.1 })
    }
    
    func testConcatCollection() {
        
        let a = [1, 2, 3]
        let b = [4, 5, 6]
        
        let result = a.concat(b)
        let answer = a + b
        
        XCTAssert(result.elementsEqual(answer))
        XCTAssertEqual(Array(result), answer)
    }
    
    func testOptionOneCollection1() {
        
        let c = OptionOneCollection<Int>(nil)
        
        XCTAssertEqual(c.count, 0)
        
        XCTAssert(c.elementsEqual([]))
        XCTAssertEqual(Array(c), [])
    }
    
    func testOptionOneCollection2() {
        
        let c = OptionOneCollection(42)
        
        XCTAssertEqual(c.count, 1)
        
        for value in c {
            XCTAssertEqual(value, 42)
        }
        
        XCTAssert(c.elementsEqual([42]))
        XCTAssertEqual(Array(c), [42])
    }
    
    func testSequenceScan() {
        
        let result = (1..<6).scan(0, +)
        let answer = [0, 1, 3, 6, 10, 15]
        
        XCTAssertEqual(result, answer)
    }
    
    func testLazySequenceScan() {
        
        let result = (1..<6).lazy.scan(0, +)
        let answer = [0, 1, 3, 6, 10, 15]
        
        XCTAssert(result.elementsEqual(answer))
        XCTAssertEqual(Array(result), answer)
    }
    
}
