//
//  CGColorSpace.swift
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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    import Foundation
    import CoreGraphics
    
    extension ColorSpace {
        
        var isSupportCGColorSpaceGamma : Bool {
            return base.isSupportCGColorSpaceGamma(linear: false)
        }
        
        public var cgColorSpace : CGColorSpace? {
            return base.cgColorSpace(linear: false)
        }
    }
    
    fileprivate protocol _LinearToneColorSpaceBase {
        
        var _base: _ColorSpaceBaseProtocol { get }
    }
    
    extension LinearToneColorSpace : _LinearToneColorSpaceBase {
        
        fileprivate var _base: _ColorSpaceBaseProtocol {
            return base
        }
    }
    
    extension _ColorSpaceBaseProtocol {
        
        fileprivate func isSupportCGColorSpaceGamma(linear: Bool) -> Bool {
            switch self {
            case let colorSpace as _LinearToneColorSpaceBase: return colorSpace._base.isSupportCGColorSpaceGamma(linear: true)
            case let colorSpace as CalibratedGrayColorSpace: return linear || colorSpace is CalibratedGammaGrayColorSpace
            case let colorSpace as CalibratedRGBColorSpace: return linear || colorSpace is CalibratedGammaRGBColorSpace
            default: break
            }
            return false
        }
        
        fileprivate func cgColorSpace(linear: Bool) -> CGColorSpace? {
            
            switch self {
            case let colorSpace as _LinearToneColorSpaceBase: return colorSpace._base.cgColorSpace(linear: true)
            case let colorSpace as CalibratedGrayColorSpace:
                
                let gamma: CGFloat
                
                if !linear, let colorSpace = colorSpace as? CalibratedGammaGrayColorSpace {
                    gamma = CGFloat(colorSpace.gamma)
                } else {
                    gamma = 1
                }
                
                let white = colorSpace.cieXYZ.normalizedWhite
                
                return CGColorSpace(calibratedGrayWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], gamma: gamma)
                
            case let colorSpace as CalibratedRGBColorSpace:
                
                let gamma: [CGFloat]
                
                if !linear, let colorSpace = colorSpace as? CalibratedGammaRGBColorSpace {
                    gamma = [CGFloat(colorSpace.gamma.0), CGFloat(colorSpace.gamma.1), CGFloat(colorSpace.gamma.2)]
                } else {
                    gamma = [1, 1, 1]
                }
                
                let white = colorSpace.white * colorSpace.cieXYZ.normalizeMatrix
                
                let white = colorSpace.cieXYZ.normalizedWhite
                
                return CGColorSpace(calibratedRGBWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], gamma: gamma,
                                    matrix: [
                                        CGFloat(matrix.a), CGFloat(matrix.e), CGFloat(matrix.i),
                                        CGFloat(matrix.b), CGFloat(matrix.f), CGFloat(matrix.j),
                                        CGFloat(matrix.c), CGFloat(matrix.g), CGFloat(matrix.k)
                    ])
                
            case let colorSpace as CIELabColorSpace:
                
                let white = colorSpace.cieXYZ.normalizedWhite
                
                return CGColorSpace(labWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], range: [-128, 128, -128, 128])
                
            default: break
            }
            return nil
        }
    }
    
    protocol CGColorSpaceConvertibleProtocol {
        
        var cgColorSpace: CGColorSpace? { get }
    }
    
    extension AnyColorSpaceBase : CGColorSpaceConvertibleProtocol {
        
        var cgColorSpace: CGColorSpace? {
            return base.cgColorSpace
        }
    }
    
    extension AnyColorSpace {
        
        public var cgColorSpace: CGColorSpace? {
            if let base = base as? CGColorSpaceConvertibleProtocol {
                return base.cgColorSpace
            }
            return nil
        }
    }
    
#endif

