//
//  FourierSpeedTest.swift
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

#if canImport(Accelerate)
import Accelerate
#endif

class FourierSpeedTest: XCTestCase {
    
    func testHalfRadix2CooleyTukeySpeed() {
        
        for log2n in 15...20 {
            
            var sample = [Double](repeating: 0, count: 1 << log2n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            var result = [Complex](repeating: Complex(), count: sample.count >> 1)
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                HalfRadix2CooleyTukey(log2n, sample, 1, sample.count, &result, 1)
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
        }
    }
    
    func testRadix2CooleyTukeySpeed() {
        
        for log2n in 15...20 {
            
            var sample = [Double](repeating: 0, count: 1 << log2n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            var result = [Complex](repeating: Complex(), count: sample.count)
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                Radix2CooleyTukey(log2n, sample, 1, sample.count, &result, 1)
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
        }
    }
    
    func testRadix2CooleyTukeyComplexSpeed() {
        
        for log2n in 15...20 {
            
            var sample = [Complex](repeating: Complex(), count: 1 << log2n)
            for i in sample.indices {
                sample[i] = Complex(real: Double.random(in: 0..<1), imag: Double.random(in: 0..<1))
            }
            var result = [Complex](repeating: Complex(), count: sample.count)
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                Radix2CooleyTukey(log2n, sample, 1, sample.count, &result, 1)
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
        }
    }
    
    #if canImport(Accelerate)
    
    func testZripSpeed() {
        
        for log2n in 15...20 {
            
            let setup = vDSP_create_fftsetupD(vDSP_Length(log2n), FFTRadix(kFFTRadix2))!
            
            var sample = [Double](repeating: 0, count: 1 << log2n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                
                sample.withUnsafeMutableBufferPointer { sample in
                    
                    var input = DSPDoubleSplitComplex(realp: sample.baseAddress!, imagp: sample.baseAddress!.successor())
                    
                    vDSP_fft_zripD(setup, &input, 2, vDSP_Length(log2n), FFTDirection(kFFTDirection_Forward))
                }
                
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
            
            vDSP_destroy_fftsetupD(setup)
        }
    }
    
    func testZropSpeed() {
        
        for log2n in 15...20 {
            
            let setup = vDSP_create_fftsetupD(vDSP_Length(log2n), FFTRadix(kFFTRadix2))!
            
            var sample = [Double](repeating: 0, count: 1 << log2n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            var result = [Double](repeating: 0, count: sample.count << 1)
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                
                sample.withUnsafeMutableBufferPointer { sample in
                    
                    result.withUnsafeMutableBufferPointer { result in
                        
                        var input = DSPDoubleSplitComplex(realp: sample.baseAddress!, imagp: sample.baseAddress!.successor())
                        var output = DSPDoubleSplitComplex(realp: result.baseAddress!, imagp: result.baseAddress!.successor())
                        
                        vDSP_fft_zropD(setup, &input, 2, &output, 2, vDSP_Length(log2n), FFTDirection(kFFTDirection_Forward))
                    }
                }
                
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
            
            vDSP_destroy_fftsetupD(setup)
        }
    }
    
    func testZopSpeed() {
        
        for log2n in 15...20 {
            
            let setup = vDSP_create_fftsetupD(vDSP_Length(log2n), FFTRadix(kFFTRadix2))!
            
            var sample = [Double](repeating: 0, count: 2 << log2n)
            for i in sample.indices {
                sample[i] = Double.random(in: 0..<1)
            }
            var result = [Double](repeating: 0, count: sample.count)
            
            print("N:", 1 << log2n, terminator: "\t")
            var times: [Double] = []
            
            for _ in 0...5 {
                
                let start_t = clock()
                
                sample.withUnsafeMutableBufferPointer { sample in
                    
                    result.withUnsafeMutableBufferPointer { result in
                        
                        var input = DSPDoubleSplitComplex(realp: sample.baseAddress!, imagp: sample.baseAddress!.successor())
                        var output = DSPDoubleSplitComplex(realp: result.baseAddress!, imagp: result.baseAddress!.successor())
                        
                        vDSP_fft_zopD(setup, &input, 2, &output, 2, vDSP_Length(log2n), FFTDirection(kFFTDirection_Forward))
                    }
                }
                
                let end_t = clock()
                
                times.append(Double(end_t - start_t) / Double(CLOCKS_PER_SEC))
            }
            
            print(times.map { "\($0)" }.joined(separator: "\t"))
            
            vDSP_destroy_fftsetupD(setup)
        }
    }
    
    #endif

}
