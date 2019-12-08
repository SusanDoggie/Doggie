//
//  PredefinedColorSpace.swift
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
let _D50 = Point(x: 0.34567, y: 0.35850)

@usableFromInline
let _D65 = Point(x: 0.31271, y: 0.32902)

extension ColorSpace where Model == XYZColorModel {
    
    @inlinable
    public static var genericXYZ_D50: ColorSpace {
        return .cieXYZ(white: _D50)
    }
    
    @inlinable
    public static var genericXYZ: ColorSpace {
        return .cieXYZ(white: _D65)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericXYZ
    }
}

extension ColorSpace where Model == YxyColorModel {
    
    @inlinable
    public static var genericYxy_D50: ColorSpace {
        return .cieYxy(white: _D50)
    }
    
    @inlinable
    public static var genericYxy: ColorSpace {
        return .cieYxy(white: _D65)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericYxy
    }
    
}

extension ColorSpace where Model == LabColorModel {
    
    @inlinable
    public static var genericLab_D50: ColorSpace {
        return .cieLab(white: _D50)
    }
    
    @inlinable
    public static var genericLab: ColorSpace {
        return .cieLab(white: _D65)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericLab
    }
}

extension ColorSpace where Model == LuvColorModel {
    
    @inlinable
    public static var genericLuv_D50: ColorSpace {
        return .cieLuv(white: _D50)
    }
    
    @inlinable
    public static var genericLuv: ColorSpace {
        return .cieLuv(white: _D65)
    }
    
    @inlinable
    public static var `default`: ColorSpace {
        return .genericLuv
    }
}

extension ColorSpace where Model == GrayColorModel {
    
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
    public static var genericXYZ_D50: AnyColorSpace {
        return AnyColorSpace(.genericXYZ_D50)
    }
    
    @inlinable
    public static var genericXYZ: AnyColorSpace {
        return AnyColorSpace(.genericXYZ)
    }
    
    @inlinable
    public static var genericYxy_D50: AnyColorSpace {
        return AnyColorSpace(.genericYxy_D50)
    }
    
    @inlinable
    public static var genericYxy: AnyColorSpace {
        return AnyColorSpace(.genericYxy)
    }
    
    @inlinable
    public static var genericLab_D50: AnyColorSpace {
        return AnyColorSpace(.genericLab_D50)
    }
    
    @inlinable
    public static var genericLab: AnyColorSpace {
        return AnyColorSpace(.genericLab)
    }
    
    @inlinable
    public static var genericLuv_D50: AnyColorSpace {
        return AnyColorSpace(.genericLuv_D50)
    }
    
    @inlinable
    public static var genericLuv: AnyColorSpace {
        return AnyColorSpace(.genericLuv)
    }
    
    @inlinable
    public static var genericGamma22Gray: AnyColorSpace {
        return AnyColorSpace(.genericGamma22Gray)
    }
    
    @inlinable
    public static var sRGB: AnyColorSpace {
        return AnyColorSpace(.sRGB)
    }
    
    @inlinable
    public static var adobeRGB: AnyColorSpace {
        return AnyColorSpace(.adobeRGB)
    }
    
    @inlinable
    public static var displayP3: AnyColorSpace {
        return AnyColorSpace(.displayP3)
    }
}
