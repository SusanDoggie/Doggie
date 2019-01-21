//
//  ArithmeticTest.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

class ArithmeticTest: XCTestCase {

    func _testTensorOperation_1<T: Tensor>(_: T.Type, _ operation: (T, T) -> T, _ check: (Double, Double) -> Double) where T.Scalar == Double {
        
        var a = T()
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            a[i] = Double.random(in: -200..<200)
            b[i] = Double.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b[i]), result[i])
        }
    }
    
    func _testTensorOperation_2<T: Tensor>(_: T.Type, _ operation: (Double, T) -> T, _ check: (Double, Double) -> Double) where T.Scalar == Double {
        
        let a = Double.random(in: -200..<200)
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            b[i] = Double.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a, b[i]), result[i])
        }
    }
    
    func _testTensorOperation_3<T: Tensor>(_: T.Type, _ operation: (T, Double) -> T, _ check: (Double, Double) -> Double) where T.Scalar == Double {
        
        var a = T()
        let b = Double.random(in: -200..<200)
        
        for i in 0..<T.numberOfComponents {
            a[i] = Double.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b), result[i])
        }
    }
    
    func _testTensorOperation<T: Tensor>(_: T.Type) where T.Scalar == Double {
        
        _testTensorOperation_1(T.self, +, +)
        _testTensorOperation_1(T.self, -, -)
        _testTensorOperation_2(T.self, *, *)
        _testTensorOperation_3(T.self, *, *)
        _testTensorOperation_3(T.self, /, /)
        
    }
    
    func testTensorOperation() {
        
        _testTensorOperation(Point.self)
        _testTensorOperation(Vector.self)
        
    }
    
    func testColorOperation() {
        
        _testTensorOperation(GrayColorModel.self)
        _testTensorOperation(XYZColorModel.self)
        _testTensorOperation(YxyColorModel.self)
        _testTensorOperation(LabColorModel.self)
        _testTensorOperation(LuvColorModel.self)
        _testTensorOperation(YCbCrColorModel.self)
        _testTensorOperation(CMYColorModel.self)
        _testTensorOperation(CMYKColorModel.self)
        _testTensorOperation(RGBColorModel.self)
        _testTensorOperation(Device2ColorModel.self)
        _testTensorOperation(Device3ColorModel.self)
        _testTensorOperation(Device4ColorModel.self)
        _testTensorOperation(Device5ColorModel.self)
        _testTensorOperation(Device6ColorModel.self)
        _testTensorOperation(Device7ColorModel.self)
        _testTensorOperation(Device8ColorModel.self)
        _testTensorOperation(Device9ColorModel.self)
        _testTensorOperation(DeviceAColorModel.self)
        _testTensorOperation(DeviceBColorModel.self)
        _testTensorOperation(DeviceCColorModel.self)
        _testTensorOperation(DeviceDColorModel.self)
        _testTensorOperation(DeviceEColorModel.self)
        _testTensorOperation(DeviceFColorModel.self)
        
    }
    
    func _testFloatComponentsOperation_1<T: Tensor>(_: T.Type, _ operation: (T, T) -> T, _ check: (Float, Float) -> Float) where T.Scalar == Float {
        
        var a = T()
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            a[i] = Float.random(in: -200..<200)
            b[i] = Float.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b[i]), result[i])
        }
    }
    
    func _testFloatComponentsOperation_2<T: Tensor>(_: T.Type, _ operation: (Float, T) -> T, _ check: (Float, Float) -> Float) where T.Scalar == Float {
        
        let a = Float.random(in: -200..<200)
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            b[i] = Float.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a, b[i]), result[i])
        }
    }
    
    func _testFloatComponentsOperation_3<T: Tensor>(_: T.Type, _ operation: (T, Float) -> T, _ check: (Float, Float) -> Float) where T.Scalar == Float {
        
        var a = T()
        let b = Float.random(in: -200..<200)
        
        for i in 0..<T.numberOfComponents {
            a[i] = Float.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b), result[i])
        }
    }
    
    func _testFloatComponentsOperation<T: ColorModelProtocol>(_: T.Type) {
        
        _testFloatComponentsOperation_1(T.Float32Components.self, +, +)
        _testFloatComponentsOperation_1(T.Float32Components.self, -, -)
        _testFloatComponentsOperation_2(T.Float32Components.self, *, *)
        _testFloatComponentsOperation_3(T.Float32Components.self, *, *)
        _testFloatComponentsOperation_3(T.Float32Components.self, /, /)
        
    }
    
    func testFloatComponentsOperation() {
        
        _testFloatComponentsOperation(GrayColorModel.self)
        _testFloatComponentsOperation(XYZColorModel.self)
        _testFloatComponentsOperation(YxyColorModel.self)
        _testFloatComponentsOperation(LabColorModel.self)
        _testFloatComponentsOperation(LuvColorModel.self)
        _testFloatComponentsOperation(YCbCrColorModel.self)
        _testFloatComponentsOperation(CMYColorModel.self)
        _testFloatComponentsOperation(CMYKColorModel.self)
        _testFloatComponentsOperation(RGBColorModel.self)
        _testFloatComponentsOperation(Device2ColorModel.self)
        _testFloatComponentsOperation(Device3ColorModel.self)
        _testFloatComponentsOperation(Device4ColorModel.self)
        _testFloatComponentsOperation(Device5ColorModel.self)
        _testFloatComponentsOperation(Device6ColorModel.self)
        _testFloatComponentsOperation(Device7ColorModel.self)
        _testFloatComponentsOperation(Device8ColorModel.self)
        _testFloatComponentsOperation(Device9ColorModel.self)
        _testFloatComponentsOperation(DeviceAColorModel.self)
        _testFloatComponentsOperation(DeviceBColorModel.self)
        _testFloatComponentsOperation(DeviceCColorModel.self)
        _testFloatComponentsOperation(DeviceDColorModel.self)
        _testFloatComponentsOperation(DeviceEColorModel.self)
        _testFloatComponentsOperation(DeviceFColorModel.self)
        
    }
}
