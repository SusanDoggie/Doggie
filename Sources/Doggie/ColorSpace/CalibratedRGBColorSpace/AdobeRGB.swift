//
//  AdobeRGB.swift
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

extension ColorSpace where Model == RGBColorModel {
    
    public static let adobeRGB = ColorSpace(base: CalibratedGammaRGBColorSpace(CIEXYZColorSpace(white: Point(x: 0.3127, y: 0.329), luminance: 160.00, contrastRatio: 287.9), red: Point(x: 0.6400, y: 0.3300), green: Point(x: 0.2100, y: 0.7100), blue: Point(x: 0.1500, y: 0.0600), gamma: (2.19921875, 2.19921875, 2.19921875)))
}
