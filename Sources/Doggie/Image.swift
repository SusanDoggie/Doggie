//
//  Image.swift
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

private protocol ImageBaseProtocol {
    
    var width: Int { get }
    var height: Int { get }
    
    subscript(x: Int, y: Int) -> ColorProtocol { get set }
}

private struct ImageBase<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol> : ImageBaseProtocol where ColorPixel.Model == ColorSpace.Model {
    
    var width: Int
    var height: Int
    var buffer: [ColorPixel]
    
    var colorSpace: ColorSpace
    var algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm
    
    subscript(x: Int, y: Int) -> ColorProtocol {
        get {
            let pixel = buffer[width * y + x]
            return Color(colorSpace: colorSpace, color: pixel.color, alpha: pixel.alpha)
        }
        set {
            let color = newValue.convert(to: colorSpace, algorithm: algorithm)
            buffer[width * y + x] = ColorPixel(color: color.color, alpha: color.alpha)
        }
    }
}

public struct Image {
    
    private var base: ImageBaseProtocol
    
    public init<ColorPixel: ColorPixelProtocol, ColorSpace : ColorSpaceProtocol>(width: Int, height: Int, pixel: ColorPixel, colorSpace: ColorSpace, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) where ColorPixel.Model == ColorSpace.Model {
        self.base = ImageBase(width: width, height: height, buffer: [ColorPixel](repeating: pixel, count: width * height), colorSpace: colorSpace, algorithm: algorithm)
    }
    
    public var width: Int {
        return base.width
    }
    
    public var height: Int {
        return base.height
    }
    
    public subscript(x: Int, y: Int) -> ColorProtocol {
        get {
            return base[x, y]
        }
        set {
            base[x, y] = newValue
        }
    }
}
