//
//  CGColorSpace.swift
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

#if canImport(CoreGraphics)

private let ColorSpaceCacheCGColorSpaceKey = "ColorSpaceCacheCGColorSpaceKey"

extension ColorSpace {
    
    private var _cgColorSpace: CGColorSpace? {
        
        switch AnyColorSpace(self) {
        case AnyColorSpace.sRGB: return CGColorSpace(name: CGColorSpace.sRGB)
        case AnyColorSpace.genericGamma22Gray: return CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)
        case AnyColorSpace.displayP3: return CGColorSpace(name: CGColorSpace.displayP3)
        case AnyColorSpace.genericGamma22Gray.linearTone: return CGColorSpace(name: CGColorSpace.linearGray)
        case AnyColorSpace.sRGB.linearTone: return CGColorSpace(name: CGColorSpace.linearSRGB)
        default: break
        }
        
        switch AnyColorSpace(self) {
        case AnyColorSpace.genericXYZ: return CGColorSpace(name: CGColorSpace.genericXYZ)
        default: break
        }
        
        if self is ColorSpace<LabColorModel> {
            let white = self.referenceWhite
            let black = self.referenceBlack
            return CGColorSpace(
                labWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)],
                blackPoint: [CGFloat(black.x), CGFloat(black.y), CGFloat(black.z)],
                range: [-128, 128, -128, 128]
            )
        }
        
        return nil
    }
    
    public var cgColorSpace: CGColorSpace? {
        
        if let colorSpace = self._cgColorSpace {
            return colorSpace
        }
        
        return self.cache.load(for: ColorSpaceCacheCGColorSpaceKey) {
            return self.iccData.flatMap { CGColorSpace(iccData: $0 as CFData) }
        }
    }
}

extension AnyColorSpace {
    
    private static func _init(cgColorSpace: CGColorSpace) -> AnyColorSpace? {
        
        switch cgColorSpace.name {
        case CGColorSpace.genericGrayGamma2_2: return AnyColorSpace.genericGamma22Gray
        case CGColorSpace.sRGB: return AnyColorSpace.sRGB
        case CGColorSpace.displayP3: return AnyColorSpace.displayP3
        case CGColorSpace.linearGray: return AnyColorSpace.genericGamma22Gray.linearTone
        case CGColorSpace.linearSRGB: return AnyColorSpace.sRGB.linearTone
        default: break
        }
        
        switch cgColorSpace.name {
        case CGColorSpace.genericXYZ: return AnyColorSpace.genericXYZ
        default: break
        }
        
        return nil
    }
    
    public init?(cgColorSpace: CGColorSpace) {
        
        if let colorSpace = AnyColorSpace._init(cgColorSpace: cgColorSpace) {
            self = colorSpace
            return
        }
        
        guard let iccData = cgColorSpace.copyICCData() as Data? else { return nil }
        
        try? self.init(iccData: iccData)
    }
}

protocol CGColorSpaceConvertibleProtocol {
    
    var cgColorSpace: CGColorSpace? { get }
}

extension ColorSpace: CGColorSpaceConvertibleProtocol {
    
}

extension AnyColorSpace {
    
    public var cgColorSpace: CGColorSpace? {
        if let base = self.base as? CGColorSpaceConvertibleProtocol {
            return base.cgColorSpace
        }
        return nil
    }
}

#endif
