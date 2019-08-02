//
//  ShapePreview.swift
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

extension Shape {
    
    public var preview: Image<RGBA32ColorPixel> {
        
        let bound = self.boundary.inset(dx: -0.5, dy: -0.5)
        
        let context = ImageContext<RGBA32ColorPixel>(width: Int(ceil(bound.width)), height: Int(ceil(bound.height)), colorSpace: .sRGB)
        
        context.translate(x: -bound.x, y: -bound.y)
        
        context.draw(shape: self, winding: .nonZero, color: RGBColorModel(red: 0.0, green: 0.5, blue: 1.0), opacity: 0.4)
        context.stroke(shape: self, width: 1, cap: .round, join: .round, color: RGBColorModel(red: 0.0, green: 0.5, blue: 1.0))
        
        return context.image
    }
}

extension Shape.Component {
    
    public var preview: Image<RGBA32ColorPixel> {
        return Shape([self]).preview
    }
}

extension ShapeRegion {
    
    public var preview: Image<RGBA32ColorPixel> {
        return shape.preview
    }
}

extension ShapeRegion.Solid {
    
    public var preview: Image<RGBA32ColorPixel> {
        return shape.preview
    }
}
