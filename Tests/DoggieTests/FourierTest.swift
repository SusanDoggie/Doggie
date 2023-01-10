//
//  FourierTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

class FourierTest: XCTestCase {
    
    let accuracy = 0.00000001
    
    func testRadix2CooleyTukeyA() {
        
        for i in 0...10 {
            let n = 1 << i
            
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Complex]()
            DiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            Radix2CooleyTukey(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testRadix2CooleyTukeyComplexA() {
        
        for i in 0...10 {
            let n = 1 << i
            
            var sample = [Complex](repeating: Complex(0), count: n)
            for i in sample.indices {
                sample[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            DiscreteFourier(sample, &answer)
            
            let result = Radix2CooleyTukey(sample)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testInverseRadix2CooleyTukeyA() {
        
        for i in 0...10 {
            let n = 1 << i
            
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Complex]()
            InverseDiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            InverseRadix2CooleyTukey(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testInverseRadix2CooleyTukeyComplexA() {
        
        for i in 0...10 {
            let n = 1 << i
            
            var sample = [Complex](repeating: Complex(0), count: n)
            for i in sample.indices {
                sample[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            InverseDiscreteFourier(sample, &answer)
            
            let result = InverseRadix2CooleyTukey(sample)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testRadix2CooleyTukeyB() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Complex]()
            DiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            Fourier(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testRadix2CooleyTukeyComplexB() {
        
        for n in 2...11 {
            var sample = [Complex](repeating: Complex(0), count: n)
            for i in sample.indices {
                sample[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            DiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            Fourier(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testInverseRadix2CooleyTukeyB() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Complex]()
            InverseDiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            InverseFourier(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testInverseRadix2CooleyTukeyComplexB() {
        
        for n in 2...11 {
            var sample = [Complex](repeating: Complex(0), count: n)
            for i in sample.indices {
                sample[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            InverseDiscreteFourier(sample, &answer)
            
            var result = [Complex]()
            InverseFourier(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testConvolve() {
        
        for n in 2...11 {
            var a = [Double](repeating: 0, count: n)
            var b = [Double](repeating: 0, count: n)
            for i in 0..<a.count {
                a[i] = Double.random(in: 0..<1)
            }
            for i in 0..<a.count {
                b[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            DirectConvolve(a, b, &answer)
            
            var result = [Double]()
            Convolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testConvolveComplex() {
        
        for n in 2...11 {
            var a = [Complex](repeating: Complex(0), count: n)
            var b = [Complex](repeating: Complex(0), count: n)
            for i in 0..<a.count {
                a[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            for i in 0..<a.count {
                b[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            DirectConvolve(a, b, &answer)
            
            var result = [Complex]()
            Convolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testCircularConvolve() {
        
        for n in 2...11 {
            var a = [Double](repeating: 0, count: n)
            var b = [Double](repeating: 0, count: n)
            for i in 0..<a.count {
                a[i] = Double.random(in: 0..<1)
            }
            for i in 0..<a.count {
                b[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            DirectConvolve(a, b, &answer)
            let part = answer[a.count..<answer.count]
            answer = [Double](answer[0..<a.count])
            for i in 0..<part.count {
                answer[i] += part[i + part.startIndex]
            }
            
            var result = [Double]()
            CircularConvolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testCircularConvolveComplex() {
        
        for n in 2...11 {
            var a = [Complex](repeating: Complex(0), count: n)
            var b = [Complex](repeating: Complex(0), count: n)
            for i in 0..<a.count {
                a[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            for i in 0..<a.count {
                b[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            DirectConvolve(a, b, &answer)
            let part = answer[a.count..<answer.count]
            answer = [Complex](answer[0..<a.count])
            for i in 0..<part.count {
                answer[i] += part[i + part.startIndex]
            }
            
            var result = [Complex]()
            CircularConvolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    func testNegacyclicConvolve() {
        
        for n in 2...11 {
            var a = [Double](repeating: 0, count: n)
            var b = [Double](repeating: 0, count: n)
            for i in 0..<a.count {
                a[i] = Double.random(in: 0..<1)
            }
            for i in 0..<a.count {
                b[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            DirectConvolve(a, b, &answer)
            let part = answer[a.count..<answer.count]
            answer = [Double](answer[0..<a.count])
            for i in 0..<part.count {
                answer[i] -= part[i + part.startIndex]
            }
            
            var result = [Double]()
            NegacyclicConvolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testNegacyclicConvolveComplex() {
        
        for n in 2...11 {
            var a = [Complex](repeating: Complex(0), count: n)
            var b = [Complex](repeating: Complex(0), count: n)
            for i in 0..<a.count {
                a[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            for i in 0..<a.count {
                b[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            
            var answer = [Complex]()
            DirectConvolve(a, b, &answer)
            let part = answer[a.count..<answer.count]
            answer = [Complex](answer[0..<a.count])
            for i in 0..<part.count {
                answer[i] -= part[i + part.startIndex]
            }
            
            var result = [Complex]()
            NegacyclicConvolve(a, b, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i].real, result[i].real, accuracy: accuracy)
                XCTAssertEqual(answer[i].imag, result[i].imag, accuracy: accuracy)
            }
        }
    }
    
    func testDCTII() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DCTII(sample, result: &answer)
            
            var result = [Double]()
            DCTII(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testDCTIII() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DCTIII(sample, result: &answer)
            
            var result = [Double]()
            DCTIII(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testDCTIV() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DCTIV(sample, result: &answer)
            
            var result = [Double]()
            DCTIV(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testDSTII() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DSTII(sample, result: &answer)
            
            var result = [Double]()
            DSTII(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testDSTIII() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DSTIII(sample, result: &answer)
            
            var result = [Double]()
            DSTIII(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    func testDSTIV() {
        
        for n in 2...11 {
            var sample = [Double](repeating: 0, count: n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            var answer = [Double]()
            _DSTIV(sample, result: &answer)
            
            var result = [Double]()
            DSTIV(sample, &result)
            
            for i in 0..<answer.count {
                XCTAssertEqual(answer[i], result[i], accuracy: accuracy)
            }
        }
    }
    
    func testFourierBPerformance() {
        
        let sample = [Double](repeating: 0, count: 32700)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformance() {
        
        let sample = [Double](repeating: 0, count: 32768)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            
            Fourier(sample, &result)
        }
    }
    func testFourierBPerformanceX2() {
        
        let sample = [Double](repeating: 0, count: 65500)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformanceX2() {
        
        let sample = [Double](repeating: 0, count: 65536)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            
            Fourier(sample, &result)
        }
    }
    func testFourierCPerformanceX3() {
        
        let sample = [Double](repeating: 0, count: 131072)
        var result = [Complex]()
        Fourier(sample, &result)
        self.measure() {
            
            Fourier(sample, &result)
        }
    }
    func testCircularConvolvePerformance() {
        
        let sample = [Double](repeating: 0, count: 44100)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            
            CircularConvolve(sample, sample, &result)
        }
    }
    func testCircularConvolvePerformanceX2() {
        
        let sample = [Double](repeating: 0, count: 96000)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            
            CircularConvolve(sample, sample, &result)
        }
    }
    func testCircularConvolvePerformanceX3() {
        
        let sample = [Double](repeating: 0, count: 192000)
        var result = [Double]()
        CircularConvolve(sample, sample, &result)
        self.measure() {
            
            CircularConvolve(sample, sample, &result)
        }
    }
}

func _DCTII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * cos(angle * Double(k) * (Double(i) + 0.5))
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
    result[0] *= sqrt(0.5)
}
func _DCTIII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            if i == 0 {
                result[k] += buffer[i] * cos(angle * Double(i) * (Double(k) + 0.5)) * sqrt(0.5)
            } else {
                result[k] += buffer[i] * cos(angle * Double(i) * (Double(k) + 0.5))
            }
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
}
func _DCTIV(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * cos(angle * (Double(i) + 0.5) * (Double(k) + 0.5))
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
}
func _DSTII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * sin(angle * (Double(i) + 0.5) * Double(k + 1))
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
    result[buffer.count - 1] *= sqrt(0.5)
}
func _DSTIII(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            if i == buffer.count - 1 {
                result[k] += buffer[i] * sin(angle * Double(i + 1) * (Double(k) + 0.5)) * sqrt(0.5)
            } else {
                result[k] += buffer[i] * sin(angle * Double(i + 1) * (Double(k) + 0.5))
            }
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
}
func _DSTIV(_ buffer: [Double], result: inout [Double]) {
    result = [Double](repeating: 0, count: buffer.count)
    let angle = .pi / Double(buffer.count)
    let _sqrt_length = sqrt(Double(buffer.count))
    for k in buffer.indices {
        for i in buffer.indices {
            result[k] += buffer[i] * sin(angle * (Double(i) + 0.5) * (Double(k) + 0.5))
        }
        result[k] *= sqrt(2) / _sqrt_length
    }
}
