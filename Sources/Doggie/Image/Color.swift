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

public struct Color<Model : ColorModelProtocol> {
    
    public var colorSpace: ColorSpace<Model>
    
    public var color: Model
    
    public var opacity: Double
    
    @_inlineable
    public init<C : ColorSpaceProtocol, P : ColorPixelProtocol>(colorSpace: C, color: P) where C.Model == Model, C.Model == P.Model {
        self.colorSpace = ColorSpace(colorSpace)
        self.color = color.color
        self.opacity = color.opacity
    }
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(colorSpace: C, color: Model, opacity: Double = 1) where C.Model == Model {
        self.colorSpace = ColorSpace(colorSpace)
        self.color = color
        self.opacity = opacity
    }
}

extension Color where Model == GrayColorModel {
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(colorSpace: C, white: Double, opacity: Double = 1) where C.Model == Model {
        self.init(colorSpace: colorSpace, color: GrayColorModel(white: white), opacity: opacity)
    }
}

extension Color where Model == RGBColorModel {
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(colorSpace: C, red: Double, green: Double, blue: Double, opacity: Double = 1) where C.Model == Model {
        self.init(colorSpace: colorSpace, color: RGBColorModel(red: red, green: green, blue: blue), opacity: opacity)
    }
}

extension Color where Model == CMYKColorModel {
    
    @_inlineable
    public init<C : ColorSpaceProtocol>(colorSpace: C, cyan: Double, magenta: Double, yellow: Double, black: Double, opacity: Double = 1) where C.Model == Model {
        self.init(colorSpace: colorSpace, color: CMYKColorModel(cyan: cyan, magenta: magenta, yellow: yellow, black: black), opacity: opacity)
    }
}

extension Color {
    
    @_inlineable
    public func convert<C : ColorSpaceProtocol>(to colorSpace: C) -> Color<C.Model> {
        return Color<C.Model>(colorSpace: colorSpace, color: self.colorSpace.convert(color, to: colorSpace), opacity: opacity)
    }
}

extension Color {
    
    @_inlineable
    public func blended<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> Color {
        let source = source.convert(to: colorSpace)
        let color = ColorPixel(color: self.color, opacity: self.opacity).blended(source: ColorPixel(color: source.color, opacity: source.opacity), blendMode: blendMode, compositingMode: compositingMode)
        return Color(colorSpace: colorSpace, color: color.color, opacity: color.opacity)
    }
    
    @_inlineable
    public mutating func blend<C>(source: Color<C>, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        self = self.blended(source: source, blendMode: blendMode, compositingMode: compositingMode)
    }
}
