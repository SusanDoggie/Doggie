//
//  PolynomialTest.swift
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

class PolynomialTest: XCTestCase {
    
    func testPolynomialMulPerformance() {
        
        var a: Polynomial = []
        var b: Polynomial = []
        
        for _ in 0..<100 {
            a.append(Double((-10..<10).randomElement()!))
            b.append(Double((-10..<10).randomElement()!))
        }
        
        self.measure() {
            _ = a * b
        }
    }
    
    func testPolynomialDivPerformance() {
        
        var a: Polynomial = []
        var b: Polynomial = []
        
        for _ in 0..<100 {
            a.append(Double((-10..<10).randomElement()!))
            b.append(Double((-10..<10).randomElement()!))
        }
        
        for _ in 0..<2 {
            a.append(Double((-10..<10).randomElement()!))
        }
        
        self.measure() {
            _ = a / b
        }
    }
    
    func testPolynomialModPerformance() {
        
        var a: Polynomial = []
        var b: Polynomial = []
        
        for _ in 0..<100 {
            a.append(Double((-10..<10).randomElement()!))
            b.append(Double((-10..<10).randomElement()!))
        }
        
        for _ in 0..<2 {
            a.append(Double((-10..<10).randomElement()!))
        }
        
        self.measure() {
            _ = a % b
        }
    }
    
    func testPolynomialPowPerformance() {
        
        var a: Polynomial = []
        
        for _ in 0..<100 {
            a.append(Double((-10..<10).randomElement()!))
        }
        
        self.measure() {
            _ = pow(a, 5)
        }
    }
    
}
