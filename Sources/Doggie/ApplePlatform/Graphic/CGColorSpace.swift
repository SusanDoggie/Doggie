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
        
        if #available(macOS 10.5, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            switch AnyColorSpace(self) {
            case AnyColorSpace.sRGB: return CGColorSpace(name: CGColorSpace.sRGB)
            default: break
            }
        }
        
        if #available(macOS 10.6, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            switch AnyColorSpace(self) {
            case AnyColorSpace.genericGamma22Gray: return CGColorSpace(name: CGColorSpace.genericGrayGamma2_2)
            default: break
            }
        }
        
        if #available(macOS 10.11.2, iOS 9.3, tvOS 9.3, watchOS 2.3, *) {
            switch AnyColorSpace(self) {
            case AnyColorSpace.displayP3: return CGColorSpace(name: CGColorSpace.displayP3)
            default: break
            }
        }
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            switch AnyColorSpace(self) {
            case AnyColorSpace.genericGamma22Gray.linearTone: return CGColorSpace(name: CGColorSpace.linearGray)
            case AnyColorSpace.sRGB.linearTone: return CGColorSpace(name: CGColorSpace.linearSRGB)
            default: break
            }
        }
        
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            switch AnyColorSpace(self) {
            case AnyColorSpace.genericXYZ_D50: return CGColorSpace(name: CGColorSpace.genericXYZ)
            case AnyColorSpace.genericLab_D50: return CGColorSpace(name: CGColorSpace.genericLab)
            default: break
            }
        }
        
        return self.cache.load(for: ColorSpaceCacheCGColorSpaceKey) {
            
            if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                
                return self.iccData.map { CGColorSpace(iccData: $0 as CFData) }
                
            } else {
                
                return self.iccData.flatMap { CGColorSpace(iccProfileData: $0 as CFData) }
            }
        }
    }
}

extension AnyColorSpace {
    
    public init?(cgColorSpace: CGColorSpace) {
        
        if #available(macOS 10.5, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            switch cgColorSpace.name {
            case CGColorSpace.sRGB:
                
                self = AnyColorSpace.sRGB
                return
                
            default: break
            }
        }
        
        if #available(macOS 10.6, iOS 9.0, tvOS 9.0, watchOS 2.0, *) {
            switch cgColorSpace.name {
            case CGColorSpace.genericGrayGamma2_2:
                
                self = AnyColorSpace.genericGamma22Gray
                return
                
            default: break
            }
        }
        
        if #available(macOS 10.11.2, iOS 9.3, tvOS 9.3, watchOS 2.3, *) {
            switch cgColorSpace.name {
            case CGColorSpace.displayP3:
                
                self = AnyColorSpace.displayP3
                return
                
            default: break
            }
        }
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            switch cgColorSpace.name {
            case CGColorSpace.linearGray:
                
                self = AnyColorSpace.genericGamma22Gray.linearTone
                return
                
            case CGColorSpace.linearSRGB:
                
                self = AnyColorSpace.sRGB.linearTone
                return
                
            default: break
            }
        }
        
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            switch cgColorSpace.name {
            case CGColorSpace.genericXYZ:
                
                self = AnyColorSpace.genericXYZ_D50
                return
                
            case CGColorSpace.genericLab:
                
                self = AnyColorSpace.genericLab_D50
                return
                
            default: break
            }
        }
        
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            
            guard let iccData = cgColorSpace.copyICCData() as Data? else { return nil }
            
            try? self.init(iccData: iccData)
            
        } else {
            
            guard let iccData = cgColorSpace.iccData as Data? else { return nil }
            
            try? self.init(iccData: iccData)
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
