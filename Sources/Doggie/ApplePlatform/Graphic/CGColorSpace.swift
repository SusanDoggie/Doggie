//
//  CGColorSpace.swift
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

#if canImport(CoreGraphics)

private let ColorSpaceCacheCGColorSpaceKey = "ColorSpaceCacheCGColorSpaceKey"

extension ColorSpace {
    
    public var cgColorSpace : CGColorSpace? {
        
        let _D50 = Point(x: 0.34567, y: 0.35850)
        
        switch self {
        case AnyColorSpace(ColorSpace<XYZColorModel>.cieXYZ(white: _D50)): return CGColorSpace(name: CGColorSpace.genericXYZ)
        case AnyColorSpace(ColorSpace<LabColorModel>.cieLab(white: _D50)): return CGColorSpace(name: CGColorSpace.genericLab)
        case AnyColorSpace(ColorSpace<GrayColorModel>.genericGamma22Gray): return CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)
        case AnyColorSpace(ColorSpace<GrayColorModel>.genericGamma22Gray.linearTone): return CGColorSpace(name: CGColorSpace.linearGray)
        case AnyColorSpace(ColorSpace<RGBColorModel>.sRGB): return CGColorSpace(name: CGColorSpace.sRGB)
        case AnyColorSpace(ColorSpace<RGBColorModel>.sRGB.linearTone): return CGColorSpace(name: CGColorSpace.linearSRGB)
        case AnyColorSpace(ColorSpace<RGBColorModel>.displayP3): return CGColorSpace(name: CGColorSpace.displayP3)
        default:
            
            return self.cache.load(for: ColorSpaceCacheCGColorSpaceKey) {
                
                if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                    
                    return self.iccData.map { CGColorSpace(iccData: $0 as CFData) }
                    
                } else {
                    
                    return self.iccData.flatMap { CGColorSpace(iccProfileData: $0 as CFData) }
                }
            }
        }
    }
}

extension AnyColorSpace {
    
    public init?(cgColorSpace: CGColorSpace) {
        
        let _D50 = Point(x: 0.34567, y: 0.35850)
        
        switch cgColorSpace.name {
        case CGColorSpace.genericXYZ: self.init(ColorSpace<XYZColorModel>.cieXYZ(white: _D50))
        case CGColorSpace.genericLab: self.init(ColorSpace<LabColorModel>.cieLab(white: _D50))
        case CGColorSpace.genericGrayGamma2_2: self.init(ColorSpace<GrayColorModel>.genericGamma22Gray)
        case CGColorSpace.linearGray: self.init(ColorSpace<GrayColorModel>.genericGamma22Gray.linearTone)
        case CGColorSpace.sRGB: self.init(ColorSpace<RGBColorModel>.sRGB)
        case CGColorSpace.linearSRGB: self.init(ColorSpace<RGBColorModel>.sRGB.linearTone)
        case CGColorSpace.displayP3: self.init(ColorSpace<RGBColorModel>.displayP3)
        default:
            
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                
                guard let iccData = cgColorSpace.copyICCData() as Data? else { return nil }
                
                try? self.init(iccData: iccData)
                
            } else {
                
                guard let iccData = cgColorSpace.iccData as Data? else { return nil }
                
                try? self.init(iccData: iccData)
            }
        }
    }
}

protocol CGColorSpaceConvertibleProtocol {
    
    var cgColorSpace: CGColorSpace? { get }
}

extension ColorSpace : CGColorSpaceConvertibleProtocol {
    
}

extension AnyColorSpace {
    
    public var cgColorSpace: CGColorSpace? {
        if let base = _base as? CGColorSpaceConvertibleProtocol {
            return base.cgColorSpace
        }
        return nil
    }
}

#endif
