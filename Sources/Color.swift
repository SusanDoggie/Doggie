//
//  Color.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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

public protocol ColorModelProtocol {
    
}

public struct RGBColorModel : ColorModelProtocol {
    
    public var red: Double
    public var green: Double
    public var blue: Double
}

public struct CMYKColorModel : ColorModelProtocol {
    
    public var cyan: Double
    public var magenta: Double
    public var yellow: Double
    public var black: Double
}

public struct HSBColorModel : ColorModelProtocol {
    
    public var hue: Double
    public var saturation: Double
    public var brightness: Double
}

public struct HSLColorModel : ColorModelProtocol {
    
    public var hue: Double
    public var saturation: Double
    public var lightness: Double
}

public struct LabColorModel : ColorModelProtocol {
    
    /// The lightness dimension.
    public var lightness: Double
    /// The a color component.
    public var a: Double
    /// The b color component.
    public var b: Double
}

public struct XYZColorModel : ColorModelProtocol {
    
    /// The Y luminance component.
    public var x: Double
    /// The Cb chroma component.
    public var y: Double
    /// The Cr chroma component.
    public var z: Double
}

public struct GrayColorModel : ColorModelProtocol {
    
    public var white: Double
}

public protocol ColorSpaceProtocol {
    
    associatedtype Model : ColorModelProtocol
    
}

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    public var alpha: Double
}
