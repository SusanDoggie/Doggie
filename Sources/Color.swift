//
//  Color.swift
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

public struct Color<ColorSpace : ColorSpaceProtocol> {
    
    public var colorSpace: ColorSpace
    
    public var color: ColorSpace.Model
    public var alpha: Double
    
    public init(colorSpace: ColorSpace, color: ColorSpace.Model, alpha: Double = 1) {
        self.colorSpace = colorSpace
        self.color = color
        self.alpha = alpha
    }
}

extension Color {
    
    public func convert<C : ColorSpaceProtocol>(to colorSpace: C, algorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm = .bradford) -> Color<C> {
        return Color<C>(colorSpace: colorSpace, color: self.colorSpace.convert(color, to: colorSpace, algorithm: algorithm), alpha: alpha)
    }
}

public protocol ColorBlendProtocol : ColorModelProtocol {
    
    func blend(operation: (Double) -> Double) -> Self
    func blend(source: Self, operation: (Double, Double) -> Double) -> Self
}

extension ColorBlendProtocol where Self : ColorVectorConvertible {
    
    public func blend(operation: (Double) -> Double) -> Self {
        let v = self.vector
        return Self(Vector(x: operation(v.x), y: operation(v.y), z: operation(v.z)))
    }
    public func blend(source: Self, operation: (Double, Double) -> Double) -> Self {
        let d = self.vector
        let s = source.vector
        return Self(Vector(x: operation(d.x, s.x), y: operation(d.y, s.y), z: operation(d.z, s.z)))
    }
}

extension CMYKColorModel : ColorBlendProtocol {
    
    public func blend(operation: (Double) -> Double) -> CMYKColorModel {
        return CMYKColorModel(cyan: operation(cyan), magenta: operation(magenta), yellow: operation(yellow), black: operation(black))
    }
    public func blend(source: CMYKColorModel, operation: (Double, Double) -> Double) -> CMYKColorModel {
        return CMYKColorModel(cyan: operation(cyan, source.cyan), magenta: operation(magenta, source.magenta), yellow: operation(yellow, source.yellow), black: operation(black, source.black))
    }
}

extension GrayColorModel : ColorBlendProtocol {
    
    public func blend(operation: (Double) -> Double) -> GrayColorModel {
        return GrayColorModel(white: operation(white))
    }
    public func blend(source: GrayColorModel, operation: (Double, Double) -> Double) -> GrayColorModel {
        return GrayColorModel(white: operation(white, source.white))
    }
}
