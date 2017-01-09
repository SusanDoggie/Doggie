//
//  FourierTest.swift
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

class FourierTest: XCTestCase {
    
    let accuracy = 0.00000001
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testRadix2CooleyTukeyA() {
        
        var sample = [Double](repeating: 0, count: 4)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Radix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyB() {
        
        var sample = [Double](repeating: 0, count: 8)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Radix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyC() {
        
        var sample = [Double](repeating: 0, count: 16)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Radix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyD() {
        
        var sample = [Double](repeating: 0, count: 32)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Radix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyE() {
        
        var sample = [Double](repeating: 0, count: 512)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Radix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplexA() {
        
        var sample = [Complex](repeating: Complex(0), count: 4)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        let result = Radix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplexB() {
        
        var sample = [Complex](repeating: Complex(0), count: 8)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        let result = Radix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplexC() {
        
        var sample = [Complex](repeating: Complex(0), count: 16)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        let result = Radix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplexD() {
        
        var sample = [Complex](repeating: Complex(0), count: 32)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        let result = Radix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplexE() {
        
        var sample = [Complex](repeating: Complex(0), count: 512)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        let result = Radix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyA() {
        
        var sample = [Double](repeating: 0, count: 4)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseRadix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyB() {
        
        var sample = [Double](repeating: 0, count: 8)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseRadix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyC() {
        
        var sample = [Double](repeating: 0, count: 16)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseRadix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyD() {
        
        var sample = [Double](repeating: 0, count: 32)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseRadix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyE() {
        
        var sample = [Double](repeating: 0, count: 512)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseRadix2CooleyTukey(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplexA() {
        
        var sample = [Complex](repeating: Complex(0), count: 4)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        let result = InverseRadix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplexB() {
        
        var sample = [Complex](repeating: Complex(0), count: 8)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        let result = InverseRadix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplexC() {
        
        var sample = [Complex](repeating: Complex(0), count: 16)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        let result = InverseRadix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplexD() {
        
        var sample = [Complex](repeating: Complex(0), count: 32)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        let result = InverseRadix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplexE() {
        
        var sample = [Complex](repeating: Complex(0), count: 512)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        let result = InverseRadix2CooleyTukey(sample)
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testFourier() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testFourierComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 10)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukey() {
        
        var sample = [Double](repeating: 0, count: 8)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testRadix2CooleyTukeyComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 8)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testBluestein() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testBluesteinComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 10)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testBluesteinO() {
        
        var sample = [Double](repeating: 0, count: 9)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testBluesteinOComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 9)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        Fourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    
    func testInverseFourier() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseFourierComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 10)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseRadix2CooleyTukeyComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 8)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseBluestein() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseBluesteinComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 10)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseBluesteinO() {
        
        var sample = [Double](repeating: 0, count: 9)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testInverseBluesteinOComplex() {
        
        var sample = [Complex](repeating: Complex(0), count: 9)
        for i in sample.indices {
            sample[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        InverseDiscreteFourier(sample, &answer)
        
        var result = [Complex]()
        InverseFourier(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    
    func testConvolveA() {
        
        var a = [Double](repeating: 0, count: 2)
        var b = [Double](repeating: 0, count: 2)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveB() {
        
        var a = [Double](repeating: 0, count: 3)
        var b = [Double](repeating: 0, count: 3)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveC() {
        
        var a = [Double](repeating: 0, count: 4)
        var b = [Double](repeating: 0, count: 4)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveD() {
        
        var a = [Double](repeating: 0, count: 5)
        var b = [Double](repeating: 0, count: 5)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveE() {
        
        var a = [Double](repeating: 0, count: 6)
        var b = [Double](repeating: 0, count: 6)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveF() {
        
        var a = [Double](repeating: 0, count: 7)
        var b = [Double](repeating: 0, count: 7)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveG() {
        
        var a = [Double](repeating: 0, count: 8)
        var b = [Double](repeating: 0, count: 8)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveH() {
        
        var a = [Double](repeating: 0, count: 9)
        var b = [Double](repeating: 0, count: 9)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveI() {
        
        var a = [Double](repeating: 0, count: 10)
        var b = [Double](repeating: 0, count: 10)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveJ() {
        
        var a = [Double](repeating: 0, count: 11)
        var b = [Double](repeating: 0, count: 11)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Double]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testConvolveComplex() {
        
        var a = [Complex](repeating: Complex(0), count: 10)
        var b = [Complex](repeating: Complex(0), count: 10)
        for i in 0..<a.count {
            a[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        for i in 0..<a.count {
            b[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteConvolve(a, b, &answer)
        
        var result = [Complex]()
        Convolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testCircularConvolve() {
        
        var a = [Double](repeating: 0, count: 10)
        var b = [Double](repeating: 0, count: 10)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        let part = answer[a.count..<answer.count]
        answer = [Double](answer[0..<a.count])
        for i in 0..<part.count {
            answer[i] += part[i + part.startIndex]
        }
        
        var result = [Double]()
        CircularConvolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testCircularConvolveComplex() {
        
        var a = [Complex](repeating: Complex(0), count: 10)
        var b = [Complex](repeating: Complex(0), count: 10)
        for i in 0..<a.count {
            a[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        for i in 0..<a.count {
            b[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteConvolve(a, b, &answer)
        let part = answer[a.count..<answer.count]
        answer = [Complex](answer[0..<a.count])
        for i in 0..<part.count {
            answer[i] += part[i + part.startIndex]
        }
        
        var result = [Complex]()
        CircularConvolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    func testNegacyclicConvolve() {
        
        var a = [Double](repeating: 0, count: 10)
        var b = [Double](repeating: 0, count: 10)
        for i in 0..<a.count {
            a[i] = (0.0..<1.0).random()
        }
        for i in 0..<a.count {
            b[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        DiscreteConvolve(a, b, &answer)
        let part = answer[a.count..<answer.count]
        answer = [Double](answer[0..<a.count])
        for i in 0..<part.count {
            answer[i] -= part[i + part.startIndex]
        }
        
        var result = [Double]()
        NegacyclicConvolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testNegacyclicConvolveComplex() {
        
        var a = [Complex](repeating: Complex(0), count: 10)
        var b = [Complex](repeating: Complex(0), count: 10)
        for i in 0..<a.count {
            a[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        for i in 0..<a.count {
            b[i] = Complex(real: (0.0..<1.0).random(), imag: (0.0..<1.0).random())
        }
        
        var answer = [Complex]()
        DiscreteConvolve(a, b, &answer)
        let part = answer[a.count..<answer.count]
        answer = [Complex](answer[0..<a.count])
        for i in 0..<part.count {
            answer[i] -= part[i + part.startIndex]
        }
        
        var result = [Complex]()
        NegacyclicConvolve(a, b, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i].real, result[i].real, accuracy: accuracy)
            XCTAssertEqualWithAccuracy(answer[i].imag, result[i].imag, accuracy: accuracy)
        }
    }
    
    func testDCTII() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DCTII(sample, result: &answer)
        
        var result = [Double]()
        DCTII(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testDCTIII() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DCTIII(sample, result: &answer)
        
        var result = [Double]()
        DCTIII(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testDCTIV() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DCTIV(sample, result: &answer)
        
        var result = [Double]()
        DCTIV(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testDSTII() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DSTII(sample, result: &answer)
        
        var result = [Double]()
        DSTII(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testDSTIII() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DSTIII(sample, result: &answer)
        
        var result = [Double]()
        DSTIII(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    func testDSTIV() {
        
        var sample = [Double](repeating: 0, count: 10)
        for i in sample.indices {
            sample[i] = (0.0..<1.0).random()
        }
        
        var answer = [Double]()
        _DSTIV(sample, result: &answer)
        
        var result = [Double]()
        DSTIV(sample, &result)
        
        for i in 0..<answer.count {
            XCTAssertEqualWithAccuracy(answer[i], result[i], accuracy: accuracy)
        }
    }
    
    func testFourierBPerformance() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 32700)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformance() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 32768)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            Fourier(sample, &result)
        }
    }
    func testFourierBPerformanceX2() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 65500)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformanceX2() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 65536)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformanceX3() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 131072)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            Fourier(sample, &result)
        }
    }
    func testCircularConvolvePerformance() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 44100)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            CircularConvolve(sample, sample, &result)
        }
    }
    func testCircularConvolvePerformanceX2() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 96000)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            CircularConvolve(sample, sample, &result)
        }
    }
    func testCircularConvolvePerformanceX3() {
        // This is an example of a performance test case.
        let sample = [Double](repeating: 0, count: 192000)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            // Put the code you want to measure the time of here.
            CircularConvolve(sample, sample, &result)
        }
    }
}

func _DCTII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * cos(angle * Double(k) * (Double(i) + 0.5))
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
    result[0] *= M_SQRT1_2
}
func _DCTIII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            if i == 0 {
                result[k] += buffer[i] * cos(angle * Double(i) * (Double(k) + 0.5)) * M_SQRT1_2
            } else {
                result[k] += buffer[i] * cos(angle * Double(i) * (Double(k) + 0.5))
            }
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
}
func _DCTIV(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * cos(angle * (Double(i) + 0.5) * (Double(k) + 0.5))
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
}
func _DSTII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * sin(angle * (Double(i) + 0.5) * Double(k + 1))
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
    result[buffer.count - 1] *= M_SQRT1_2
}
func _DSTIII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            if i == buffer.count - 1 {
                result[k] += buffer[i] * sin(angle * Double(i + 1) * (Double(k) + 0.5)) * M_SQRT1_2
            } else {
                result[k] += buffer[i] * sin(angle * Double(i + 1) * (Double(k) + 0.5))
            }
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
}
func _DSTIV(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = M_PI / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * sin(angle * (Double(i) + 0.5) * (Double(k) + 0.5))
        }
        result[k] *= M_SQRT2 / _sqrt_length
    }
}
