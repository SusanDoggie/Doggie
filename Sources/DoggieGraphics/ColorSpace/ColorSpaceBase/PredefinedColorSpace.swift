//
//  PredefinedColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension ColorSpace where Model == XYZColorModel {
    
    @inlinable
    public static var genericXYZ: ColorSpace {
        return .cieXYZ(illuminant: CIE1931.D50)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericXYZ
    }
}

extension ColorSpace where Model == YxyColorModel {
    
    @inlinable
    public static var genericYxy: ColorSpace {
        return .cieYxy(illuminant: CIE1931.D50)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericYxy
    }
    
}

extension ColorSpace where Model == LabColorModel {
    
    @inlinable
    public static var genericLab: ColorSpace {
        return .cieLab(illuminant: CIE1931.D50)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericLab
    }
}

extension ColorSpace where Model == LuvColorModel {
    
    @inlinable
    public static var genericLuv: ColorSpace {
        return .cieLuv(illuminant: CIE1931.D50)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericLuv
    }
}

extension ColorSpace where Model == GrayColorModel {
    
    @inlinable
    public static var genericGamma22Gray: ColorSpace {
        return .calibratedGray(illuminant: CIE1931.D65, gamma: 2.2)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericGamma22Gray
    }
}

extension ColorSpace where Model == RGBColorModel {
    
    @inlinable
    public static var `default`: ColorSpace {
        return .sRGB
    }
}

extension AnyColorSpace {
    
    @inlinable
    public static var genericXYZ: AnyColorSpace {
        return AnyColorSpace(ColorSpace.genericXYZ)
    }
    
    @inlinable
    public static var genericYxy: AnyColorSpace {
        return AnyColorSpace(ColorSpace.genericYxy)
    }
    
    @inlinable
    public static var genericLab: AnyColorSpace {
        return AnyColorSpace(ColorSpace.genericLab)
    }
    
    @inlinable
    public static var genericLuv: AnyColorSpace {
        return AnyColorSpace(ColorSpace.genericLuv)
    }
    
    @inlinable
    public static var genericGamma22Gray: AnyColorSpace {
        return AnyColorSpace(ColorSpace.genericGamma22Gray)
    }
    
    @inlinable
    public static var sRGB: AnyColorSpace {
        return AnyColorSpace(ColorSpace.sRGB)
    }
    
    @inlinable
    public static var adobeRGB: AnyColorSpace {
        return AnyColorSpace(ColorSpace.adobeRGB)
    }
    
    @inlinable
    public static var displayP3: AnyColorSpace {
        return AnyColorSpace(ColorSpace.displayP3)
    }
}

extension AnyColorSpace {
    
    @inlinable
    public static func cieXYZ(white: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieXYZ(white: white))
    }
    @inlinable
    public static func cieYxy(white: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieYxy(white: white))
    }
    @inlinable
    public static func cieLab(white: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLab(white: white))
    }
    @inlinable
    public static func cieLuv(white: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLuv(white: white))
    }
    @inlinable
    public static func cieXYZ(white: XYZColorModel, black: XYZColorModel) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieXYZ(white: white, black: black))
    }
    @inlinable
    public static func cieYxy(white: XYZColorModel, black: XYZColorModel) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieYxy(white: white, black: black))
    }
    @inlinable
    public static func cieLab(white: XYZColorModel, black: XYZColorModel) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLab(white: white, black: black))
    }
    @inlinable
    public static func cieLuv(white: XYZColorModel, black: XYZColorModel) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLuv(white: white, black: black))
    }
    @inlinable
    public static func cieXYZ(white: Point, luminance: Double, contrastRatio: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieXYZ(white: white, luminance: luminance, contrastRatio: contrastRatio))
    }
    @inlinable
    public static func cieYxy(white: Point, luminance: Double, contrastRatio: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieYxy(white: white, luminance: luminance, contrastRatio: contrastRatio))
    }
    @inlinable
    public static func cieLab(white: Point, luminance: Double, contrastRatio: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLab(white: white, luminance: luminance, contrastRatio: contrastRatio))
    }
    @inlinable
    public static func cieLuv(white: Point, luminance: Double, contrastRatio: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLuv(white: white, luminance: luminance, contrastRatio: contrastRatio))
    }
    
    @inlinable
    public static func calibratedGray(white: Point, gamma: Double = 1) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedGray(white: white, gamma: gamma))
    }
    @inlinable
    public static func calibratedGray(white: XYZColorModel, black: XYZColorModel, gamma: Double = 1) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedGray(white: white, black: black, gamma: gamma))
    }
    @inlinable
    public static func calibratedGray(white: Point, luminance: Double, contrastRatio: Double, gamma: Double = 1) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedGray(white: white, luminance: luminance, contrastRatio: contrastRatio, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point, gamma: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, red: red, green: green, blue: blue, gamma: gamma))
    }
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, black: black, red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, black: black, red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: XYZColorModel, black: XYZColorModel, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, black: black, red: red, green: green, blue: blue, gamma: gamma))
    }
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, luminance: luminance, contrastRatio: contrastRatio, red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point, gamma: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, luminance: luminance, contrastRatio: contrastRatio, red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB(white: Point, luminance: Double, contrastRatio: Double, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(white: white, luminance: luminance, contrastRatio: contrastRatio, red: red, green: green, blue: blue, gamma: gamma))
    }
}

extension ColorSpace where Model == XYZColorModel {
    
    @inlinable
    public static func cieXYZ<I: Illuminant>(illuminant: I) -> ColorSpace {
        return .cieXYZ(white: illuminant.rawValue)
    }
}

extension ColorSpace where Model == YxyColorModel {
    
    @inlinable
    public static func cieYxy<I: Illuminant>(illuminant: I) -> ColorSpace {
        return .cieYxy(white: illuminant.rawValue)
    }
}

extension ColorSpace where Model == LabColorModel {
    
    @inlinable
    public static func cieLab<I: Illuminant>(illuminant: I) -> ColorSpace {
        return .cieLab(white: illuminant.rawValue)
    }
}

extension ColorSpace where Model == LuvColorModel {
    
    @inlinable
    public static func cieLuv<I: Illuminant>(illuminant: I) -> ColorSpace {
        return .cieLuv(white: illuminant.rawValue)
    }
}

extension ColorSpace where Model == GrayColorModel {
    
    @inlinable
    public static func calibratedGray<I: Illuminant>(illuminant: I, gamma: Double = 1) -> ColorSpace {
        return .calibratedGray(white: illuminant.rawValue, gamma: gamma)
    }
}

extension ColorSpace where Model == RGBColorModel {
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point) -> ColorSpace {
        return .calibratedRGB(white: illuminant.rawValue, red: red, green: green, blue: blue)
    }
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point, gamma: Double) -> ColorSpace {
        return .calibratedRGB(white: illuminant.rawValue, red: red, green: green, blue: blue, gamma: (gamma, gamma, gamma))
    }
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> ColorSpace {
        return .calibratedRGB(white: illuminant.rawValue, red: red, green: green, blue: blue, gamma: gamma)
    }
}

extension AnyColorSpace {
    
    @inlinable
    public static func cieXYZ<I: Illuminant>(illuminant: I) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieXYZ(illuminant: illuminant))
    }
    @inlinable
    public static func cieYxy<I: Illuminant>(illuminant: I) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieYxy(illuminant: illuminant))
    }
    @inlinable
    public static func cieLab<I: Illuminant>(illuminant: I) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLab(illuminant: illuminant))
    }
    @inlinable
    public static func cieLuv<I: Illuminant>(illuminant: I) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.cieLuv(illuminant: illuminant))
    }
    
    @inlinable
    public static func calibratedGray<I: Illuminant>(illuminant: I, gamma: Double = 1) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedGray(illuminant: illuminant, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(illuminant: illuminant, red: red, green: green, blue: blue))
    }
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point, gamma: Double) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(illuminant: illuminant, red: red, green: green, blue: blue, gamma: gamma))
    }
    
    @inlinable
    public static func calibratedRGB<I: Illuminant>(illuminant: I, red: Point, green: Point, blue: Point, gamma: (Double, Double, Double)) -> AnyColorSpace {
        return AnyColorSpace(ColorSpace.calibratedRGB(illuminant: illuminant, red: red, green: green, blue: blue, gamma: gamma))
    }
}
