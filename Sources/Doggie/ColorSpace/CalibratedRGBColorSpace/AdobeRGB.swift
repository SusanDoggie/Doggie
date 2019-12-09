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

@usableFromInline
final class _adobeRGB: CalibratedRGBColorSpace {
    
    @inlinable
    init() {
        super.init(CIEXYZColorSpace(white: CIE1931.D65.rawValue, luminance: 160.00, contrastRatio: 287.9),
                   red: Point(x: 0.6400, y: 0.3300),
                   green: Point(x: 0.2100, y: 0.7100),
                   blue: Point(x: 0.1500, y: 0.0600),
                   gamma: (2.19921875, 2.19921875, 2.19921875))
    }
    
    @inlinable
    override var localizedName: String? {
        return "Adobe RGB (1998)"
    }
    
    @inlinable
    override func __equalTo(_ other: CalibratedRGBColorSpace) -> Bool {
        return type(of: other) == _adobeRGB.self
    }
    
    @inlinable
    override func hash(into hasher: inout Hasher) {
        hasher.combine("CalibratedRGBColorSpace")
        hasher.combine(".adobeRGB")
    }
}

extension ColorSpace where Model == RGBColorModel {
    
    public static let adobeRGB = ColorSpace(base: _adobeRGB())
}
