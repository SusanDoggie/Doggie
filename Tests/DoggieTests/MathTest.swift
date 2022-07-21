//
//  MathTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

class MathTest: XCTestCase {

    func testFactorial() {
        
        XCTAssertEqual(factorial(0) as UInt, 1)
        XCTAssertEqual(factorial(1) as UInt, 1)
        XCTAssertEqual(factorial(2) as UInt, 2)
        XCTAssertEqual(factorial(3) as UInt, 6)
        XCTAssertEqual(factorial(4) as UInt, 24)
        XCTAssertEqual(factorial(5) as UInt, 120)
        XCTAssertEqual(factorial(6) as UInt, 720)
        XCTAssertEqual(factorial(7) as UInt, 5040)
        XCTAssertEqual(factorial(8) as UInt, 40320)
        
    }
    
    func testPermutation() {
        
        XCTAssertEqual(permutation(1, 0) as UInt, 1)
        XCTAssertEqual(permutation(1, 1) as UInt, 1)
        
        XCTAssertEqual(permutation(2, 0) as UInt, 2)
        XCTAssertEqual(permutation(2, 1) as UInt, 2)
        XCTAssertEqual(permutation(2, 2) as UInt, 1)
        
        XCTAssertEqual(permutation(3, 0) as UInt, 6)
        XCTAssertEqual(permutation(3, 1) as UInt, 6)
        XCTAssertEqual(permutation(3, 2) as UInt, 3)
        XCTAssertEqual(permutation(3, 3) as UInt, 1)
        
        XCTAssertEqual(permutation(4, 0) as UInt, 24)
        XCTAssertEqual(permutation(4, 1) as UInt, 24)
        XCTAssertEqual(permutation(4, 2) as UInt, 12)
        XCTAssertEqual(permutation(4, 3) as UInt, 4)
        XCTAssertEqual(permutation(4, 4) as UInt, 1)
        
        XCTAssertEqual(permutation(5, 0) as UInt, 120)
        XCTAssertEqual(permutation(5, 1) as UInt, 120)
        XCTAssertEqual(permutation(5, 2) as UInt, 60)
        XCTAssertEqual(permutation(5, 3) as UInt, 20)
        XCTAssertEqual(permutation(5, 4) as UInt, 5)
        XCTAssertEqual(permutation(5, 5) as UInt, 1)
    }
    
    func testCombination() {
        
        XCTAssertEqual(combination(1, 0) as UInt, 1)
        XCTAssertEqual(combination(1, 1) as UInt, 1)
        
        XCTAssertEqual(combination(2, 0) as UInt, 1)
        XCTAssertEqual(combination(2, 1) as UInt, 2)
        XCTAssertEqual(combination(2, 2) as UInt, 1)
        
        XCTAssertEqual(combination(3, 0) as UInt, 1)
        XCTAssertEqual(combination(3, 1) as UInt, 3)
        XCTAssertEqual(combination(3, 2) as UInt, 3)
        XCTAssertEqual(combination(3, 3) as UInt, 1)
        
        XCTAssertEqual(combination(4, 0) as UInt, 1)
        XCTAssertEqual(combination(4, 1) as UInt, 4)
        XCTAssertEqual(combination(4, 2) as UInt, 6)
        XCTAssertEqual(combination(4, 3) as UInt, 4)
        XCTAssertEqual(combination(4, 4) as UInt, 1)
        
        XCTAssertEqual(combination(5, 0) as UInt, 1)
        XCTAssertEqual(combination(5, 1) as UInt, 5)
        XCTAssertEqual(combination(5, 2) as UInt, 10)
        XCTAssertEqual(combination(5, 3) as UInt, 10)
        XCTAssertEqual(combination(5, 4) as UInt, 5)
        XCTAssertEqual(combination(5, 5) as UInt, 1)
        
    }
    
    func testFactorialList() {
        
        XCTAssertEqual(Array(FactorialList(8 as UInt)), [1, 1, 2, 6, 24, 120, 720, 5040, 40320])
        
    }
    
    func testPermutationList() {
        
        XCTAssertEqual(Array(PermutationList(1 as UInt)), [1, 1])
        XCTAssertEqual(Array(PermutationList(2 as UInt)), [1, 2, 2])
        XCTAssertEqual(Array(PermutationList(3 as UInt)), [1, 3, 6, 6])
        XCTAssertEqual(Array(PermutationList(4 as UInt)), [1, 4, 12, 24, 24])
        XCTAssertEqual(Array(PermutationList(5 as UInt)), [1, 5, 20, 60, 120, 120])
        
    }
    
    func testCombinationList() {
        
        XCTAssertEqual(Array(CombinationList(1 as UInt)), [1, 1])
        XCTAssertEqual(Array(CombinationList(2 as UInt)), [1, 2, 1])
        XCTAssertEqual(Array(CombinationList(3 as UInt)), [1, 3, 3, 1])
        XCTAssertEqual(Array(CombinationList(4 as UInt)), [1, 4, 6, 4, 1])
        XCTAssertEqual(Array(CombinationList(5 as UInt)), [1, 5, 10, 10, 5, 1])
        
    }
    
}
