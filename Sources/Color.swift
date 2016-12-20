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

public protocol ColorModel {
    
}

public struct RGBColorModel {
    
    var red: Double
    var green: Double
    var blue: Double
}

public struct CMYKColorModel {
    
    var cyan: Double
    var magenta: Double
    var yellow: Double
    var black: Double
}

public struct HSBColorModel {
    
    var hue: Double
    var saturation: Double
    var brightness: Double
}

public struct HSLColorModel {
    
    var hue: Double
    var saturation: Double
    var lightness: Double
}

public struct CIELABColorModel {
    
    /// The lightness dimension.
    var lightness: Double
    /// The a color component.
    var a: Double
    /// The b color component.
    var b: Double
}

public struct CIEXYZColorModel {
    
    /// The Y luminance component.
    var x: Double
    /// The Cb chroma component.
    var y: Double
    /// The Cr chroma component.
    var z: Double
}

public struct GrayColorModel {
    
    var white: Double
}

public struct ColorSpace {
    
}

public struct Color<ColorModel> {
    
    var colorSpace: ColorSpace
    
    var color: ColorModel
    var alpha: Double
}
