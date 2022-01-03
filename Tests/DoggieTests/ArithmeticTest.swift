//
//  ArithmeticTest.swift
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

class ArithmeticTest: XCTestCase {

    func _testTensorOperation_1<T: Tensor>(_: T.Type, _ operation: (T, T) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        var a = T()
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            a[i] = T.Scalar.random(in: -200..<200)
            b[i] = T.Scalar.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b[i]), result[i])
        }
    }
    
    func _testTensorOperation_2<T: Tensor>(_: T.Type, _ operation: (T.Scalar, T) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        let a = T.Scalar.random(in: -200..<200)
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            b[i] = T.Scalar.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a, b[i]), result[i])
        }
    }
    
    func _testTensorOperation_3<T: Tensor>(_: T.Type, _ operation: (T, T.Scalar) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        var a = T()
        let b = T.Scalar.random(in: -200..<200)
        
        for i in 0..<T.numberOfComponents {
            a[i] = T.Scalar.random(in: -200..<200)
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.numberOfComponents {
            XCTAssertEqual(check(a[i], b), result[i])
        }
    }
    
    func _testTensorOperation<T: Tensor>(_: T.Type) where T.Scalar.RawSignificand: FixedWidthInteger {
        
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
    
    func testFloat32ComponentsOperation() {
        
        _testTensorOperation(GrayColorModel.Float32Components.self)
        _testTensorOperation(XYZColorModel.Float32Components.self)
        _testTensorOperation(YxyColorModel.Float32Components.self)
        _testTensorOperation(LabColorModel.Float32Components.self)
        _testTensorOperation(LuvColorModel.Float32Components.self)
        _testTensorOperation(YCbCrColorModel.Float32Components.self)
        _testTensorOperation(CMYColorModel.Float32Components.self)
        _testTensorOperation(CMYKColorModel.Float32Components.self)
        _testTensorOperation(RGBColorModel.Float32Components.self)
        _testTensorOperation(Device2ColorModel.Float32Components.self)
        _testTensorOperation(Device3ColorModel.Float32Components.self)
        _testTensorOperation(Device4ColorModel.Float32Components.self)
        _testTensorOperation(Device5ColorModel.Float32Components.self)
        _testTensorOperation(Device6ColorModel.Float32Components.self)
        _testTensorOperation(Device7ColorModel.Float32Components.self)
        _testTensorOperation(Device8ColorModel.Float32Components.self)
        _testTensorOperation(Device9ColorModel.Float32Components.self)
        _testTensorOperation(DeviceAColorModel.Float32Components.self)
        _testTensorOperation(DeviceBColorModel.Float32Components.self)
        _testTensorOperation(DeviceCColorModel.Float32Components.self)
        _testTensorOperation(DeviceDColorModel.Float32Components.self)
        _testTensorOperation(DeviceEColorModel.Float32Components.self)
        _testTensorOperation(DeviceFColorModel.Float32Components.self)
        
    }
    
    func testFloat64ComponentsOperation() {
        
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
    
    func _testColorPixelOperation_1<T: _FloatComponentPixel>(_: T.Type, _ operation: (T, T) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        var a = T()
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            a.setComponent(i, .random(in: -200..<200))
            b.setComponent(i, .random(in: -200..<200))
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.Model.numberOfComponents {
            XCTAssertEqual(check(a._color[i], b._color[i]), result._color[i])
        }
        XCTAssertEqual(check(a._opacity, b._opacity), result._opacity)
    }
    
    func _testColorPixelOperation_2<T: _FloatComponentPixel>(_: T.Type, _ operation: (T.Scalar, T) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        let a = T.Scalar.random(in: -200..<200)
        var b = T()
        
        for i in 0..<T.numberOfComponents {
            b.setComponent(i, .random(in: -200..<200))
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.Model.numberOfComponents {
            XCTAssertEqual(check(a, b._color[i]), result._color[i])
        }
        XCTAssertEqual(check(a, b._opacity), result._opacity)
    }
    
    func _testColorPixelOperation_3<T: _FloatComponentPixel>(_: T.Type, _ operation: (T, T.Scalar) -> T, _ check: (T.Scalar, T.Scalar) -> T.Scalar) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        var a = T()
        let b = T.Scalar.random(in: -200..<200)
        
        for i in 0..<T.numberOfComponents {
            a.setComponent(i, .random(in: -200..<200))
        }
        
        let result = operation(a, b)
        
        for i in 0..<T.Model.numberOfComponents {
            XCTAssertEqual(check(a._color[i], b), result._color[i])
        }
        XCTAssertEqual(check(a._opacity, b), result._opacity)
    }
    
    func _testColorPixelOperation<T: _FloatComponentPixel>(_: T.Type) where T.Scalar.RawSignificand: FixedWidthInteger {
        
        _testColorPixelOperation_1(T.self, +, +)
        _testColorPixelOperation_1(T.self, -, -)
        _testColorPixelOperation_2(T.self, *, *)
        _testColorPixelOperation_3(T.self, *, *)
        _testColorPixelOperation_3(T.self, /, /)
        
    }
    
    func testFloat32ColorPixelOperation() {
        
        _testColorPixelOperation(Float32ColorPixel<GrayColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<XYZColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<YxyColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<LabColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<LuvColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<YCbCrColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<CMYColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<CMYKColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<RGBColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device2ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device3ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device4ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device5ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device6ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device7ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device8ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<Device9ColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceAColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceBColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceCColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceDColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceEColorModel>.self)
        _testColorPixelOperation(Float32ColorPixel<DeviceFColorModel>.self)
        
    }
    
    func testFloat64ColorPixelOperation() {
        
        _testColorPixelOperation(Float64ColorPixel<GrayColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<XYZColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<YxyColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<LabColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<LuvColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<YCbCrColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<CMYColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<CMYKColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<RGBColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device2ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device3ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device4ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device5ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device6ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device7ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device8ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<Device9ColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceAColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceBColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceCColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceDColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceEColorModel>.self)
        _testColorPixelOperation(Float64ColorPixel<DeviceFColorModel>.self)
        
    }
    
}
