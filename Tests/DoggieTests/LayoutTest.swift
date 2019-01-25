//
//  LayoutTest.swift
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

class LayoutTest: XCTestCase {
    
    func _testLayout<T: Tensor>(_: T.Type) -> Bool where T.Scalar : BinaryFloatingPoint {
        
        guard MemoryLayout<T>.size == MemoryLayout<T.Scalar>.stride * T.numberOfComponents else { return false }
        guard MemoryLayout<T>.stride == MemoryLayout<T.Scalar>.stride * T.numberOfComponents else { return false }
        
        var x = T()
        
        for i in 0..<T.numberOfComponents {
            x[i] = T.Scalar(i + 1)
            guard x[i] == T.Scalar(i + 1) else { return false }
        }
        
        return withUnsafeBytes(of: x) {
            
            guard let ptr = $0.baseAddress?.assumingMemoryBound(to: T.Scalar.self) else { return false }
            
            for i in 0..<T.numberOfComponents {
                guard ptr[i] == T.Scalar(i + 1) else { return false }
            }
            
            return true
        }
    }
    
    func testComplexLayout() {
        
        XCTAssertEqual(MemoryLayout<Complex>.size, MemoryLayout<Double>.stride * 2)
        XCTAssertEqual(MemoryLayout<Complex>.stride, MemoryLayout<Double>.stride * 2)
        
        var c = Complex()
        
        c.real = 1.0
        c.imag = 2.0
        
        withUnsafeBytes(of: c) {
            
            guard let ptr = $0.baseAddress?.assumingMemoryBound(to: Double.self) else { XCTFail(); return }
            
            XCTAssertEqual(ptr[0], 1.0)
            XCTAssertEqual(ptr[1], 2.0)
        }
    }
    
    func testPointLayout() {
        
        XCTAssertTrue(_testLayout(Point.self))
        
    }
    
    func testVectorLayout() {
        
        XCTAssertTrue(_testLayout(Vector.self))
        
    }
    
    func testColorModelLayout() {
        
        XCTAssertTrue(_testLayout(GrayColorModel.self))
        XCTAssertTrue(_testLayout(XYZColorModel.self))
        XCTAssertTrue(_testLayout(YxyColorModel.self))
        XCTAssertTrue(_testLayout(LabColorModel.self))
        XCTAssertTrue(_testLayout(LuvColorModel.self))
        XCTAssertTrue(_testLayout(YCbCrColorModel.self))
        XCTAssertTrue(_testLayout(CMYColorModel.self))
        XCTAssertTrue(_testLayout(CMYKColorModel.self))
        XCTAssertTrue(_testLayout(RGBColorModel.self))
        XCTAssertTrue(_testLayout(Device2ColorModel.self))
        XCTAssertTrue(_testLayout(Device3ColorModel.self))
        XCTAssertTrue(_testLayout(Device4ColorModel.self))
        XCTAssertTrue(_testLayout(Device5ColorModel.self))
        XCTAssertTrue(_testLayout(Device6ColorModel.self))
        XCTAssertTrue(_testLayout(Device7ColorModel.self))
        XCTAssertTrue(_testLayout(Device8ColorModel.self))
        XCTAssertTrue(_testLayout(Device9ColorModel.self))
        XCTAssertTrue(_testLayout(DeviceAColorModel.self))
        XCTAssertTrue(_testLayout(DeviceBColorModel.self))
        XCTAssertTrue(_testLayout(DeviceCColorModel.self))
        XCTAssertTrue(_testLayout(DeviceDColorModel.self))
        XCTAssertTrue(_testLayout(DeviceEColorModel.self))
        XCTAssertTrue(_testLayout(DeviceFColorModel.self))
        
    }
    
    func testColorComponentsLayout() {
        
        XCTAssertTrue(_testLayout(GrayColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(XYZColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(YxyColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(LabColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(LuvColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(YCbCrColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(CMYColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(CMYKColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(RGBColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device2ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device3ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device4ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device5ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device6ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device7ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device8ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(Device9ColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceAColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceBColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceCColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceDColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceEColorModel.Float32Components.self))
        XCTAssertTrue(_testLayout(DeviceFColorModel.Float32Components.self))
        
    }
    
    func _testLayout<T: _FloatComponentPixel>(_: T.Type) -> Bool {
        
        guard MemoryLayout<T>.size == MemoryLayout<T.Scalar>.stride * T.numberOfComponents else { return false }
        guard MemoryLayout<T>.stride == MemoryLayout<T.Scalar>.stride * T.numberOfComponents else { return false }
        
        var c = T.Model()
        
        for i in 0..<T.Model.numberOfComponents {
            c[i] = Double(i + 1)
        }
        
        let x = T(color: c, opacity: Double(T.numberOfComponents))
        
        return withUnsafeBytes(of: x) {
            
            guard let ptr = $0.baseAddress?.assumingMemoryBound(to: T.Scalar.self) else { return false }
            
            for i in 0..<T.numberOfComponents {
                guard ptr[i] == T.Scalar(i + 1) else { return false }
            }
            
            return true
        }
    }
    
    func testFloat32ColorPixelLayout() {
        
        XCTAssertTrue(_testLayout(Float32ColorPixel<GrayColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<XYZColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<YxyColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<LabColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<LuvColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<YCbCrColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<CMYColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<CMYKColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<RGBColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device2ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device3ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device4ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device5ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device6ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device7ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device8ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<Device9ColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceAColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceBColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceCColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceDColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceEColorModel>.self))
        XCTAssertTrue(_testLayout(Float32ColorPixel<DeviceFColorModel>.self))
        
    }
    
    func testFloat64ColorPixelLayout() {
        
        XCTAssertTrue(_testLayout(Float64ColorPixel<GrayColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<XYZColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<YxyColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<LabColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<LuvColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<YCbCrColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<CMYColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<CMYKColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<RGBColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device2ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device3ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device4ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device5ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device6ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device7ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device8ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<Device9ColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceAColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceBColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceCColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceDColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceEColorModel>.self))
        XCTAssertTrue(_testLayout(Float64ColorPixel<DeviceFColorModel>.self))
        
    }
    
}
