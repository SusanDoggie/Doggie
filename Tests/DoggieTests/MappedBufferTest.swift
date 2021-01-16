//
//  MappedBufferTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

class MappedBufferTest: XCTestCase {
    
    func testMappedBufferAlloc() {
        
        let mapped: MappedBuffer<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        let array: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferAlloc2() {
        
        let mapped = MappedBuffer(repeating: 0, count: 64)
        let array = MappedBuffer(repeating: 0, count: 64)
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferAlloc3() {
        
        let mapped = MappedBuffer(repeating: 0, count: 64, fileBacked: true)
        let array = MappedBuffer(repeating: 0, count: 64)
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferAppend() {
        
        var mapped: MappedBuffer<Int> = []
        var array: [Int] = []
        
        mapped.append(contentsOf: 0..<9)
        array.append(contentsOf: 0..<9)
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferAppend2() {
        
        var mapped: MappedBuffer<Int> = []
        var array: [Int] = []
        
        mapped.append(contentsOf: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        array.append(contentsOf: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferAppend3() {
        
        var mapped: MappedBuffer<Int> = []
        var array: [Int] = []
        
        let shared = mapped
        let shared_array = array
        
        mapped.append(contentsOf: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        array.append(contentsOf: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9])
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
        
        XCTAssertEqual(shared_array.count, shared.count)
        XCTAssertTrue(shared_array.elementsEqual(shared))
    }
    
    func testMappedBufferReplaceSubrange() {
        
        var mapped: MappedBuffer<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        var array: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        mapped.replaceSubrange(3..<6, with: 5...9)
        array.replaceSubrange(3..<6, with: 5...9)
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferReplaceSubrange2() {
        
        var mapped: MappedBuffer<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        var array: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        mapped.replaceSubrange(3..<6, with: [5, 6, 7, 8, 9])
        array.replaceSubrange(3..<6, with: [5, 6, 7, 8, 9])
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
    }
    
    func testMappedBufferReplaceSubrange3() {
        
        var mapped: MappedBuffer<Int> = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        var array: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        
        let shared = mapped
        let shared_array = array
        
        mapped.replaceSubrange(3..<6, with: [5, 6, 7, 8, 9])
        array.replaceSubrange(3..<6, with: [5, 6, 7, 8, 9])
        
        XCTAssertEqual(array.count, mapped.count)
        XCTAssertTrue(array.elementsEqual(mapped))
        
        XCTAssertEqual(shared_array.count, shared.count)
        XCTAssertTrue(shared_array.elementsEqual(shared))
    }
    
}
