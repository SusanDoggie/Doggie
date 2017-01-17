//
//  ColorPixel.swift
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

public protocol ColorPixelProtocol {
    
    associatedtype Model : ColorModelProtocol
    
    init(color: Model, alpha: Double)
    
    var color: Model { get set }
    
    var alpha: Double { get set }
}

public struct ARGB32ColorPixel : ColorPixelProtocol {
    
    public var a: UInt8
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    public init(color: RGBColorModel, alpha: Double) {
        self.a = UInt8(alpha * 255)
        self.r = UInt8(color.red * 255)
        self.g = UInt8(color.green * 255)
        self.b = UInt8(color.blue * 255)
    }
    
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        }
        set {
            self.r = UInt8(newValue.red * 255)
            self.g = UInt8(newValue.green * 255)
            self.b = UInt8(newValue.blue * 255)
        }
    }
    public var alpha: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8(newValue * 255)
        }
    }
}
