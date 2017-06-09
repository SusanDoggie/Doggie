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
    
    fileprivate protocol _CGColorSpaceConvertible {
        
        var cgColorSpace : CGColorSpace? { get }
    }
    
    extension _ColorSpaceBase : _CGColorSpaceConvertible {
        
        fileprivate var cgColorSpace : CGColorSpace? {
            return self.base.cgColorSpace
        }
    }
    
    extension ColorSpaceProtocol {
        
        public var cgColorSpace : CGColorSpace? {
            
            switch self {
            case let colorSpace as ColorSpace<Model>:
                
                if let colorSpace = colorSpace.base as? _CGColorSpaceConvertible {
                    return colorSpace.cgColorSpace
                }
                
            case let colorSpace as CalibratedGrayColorSpace:
                
                let gamma: CGFloat
                
                if let colorSpace = colorSpace as? CalibratedGammaGrayColorSpace {
                    gamma = CGFloat(colorSpace.gamma)
                } else {
                    gamma = 1
                }
                
                let white = colorSpace.normalized.white
                
                return CGColorSpace(calibratedGrayWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], gamma: gamma)
                
            case let colorSpace as CalibratedRGBColorSpace:
                
                let gamma: [CGFloat]
                
                if let colorSpace = colorSpace as? CalibratedGammaRGBColorSpace {
                    gamma = [CGFloat(colorSpace.gamma.0), CGFloat(colorSpace.gamma.1), CGFloat(colorSpace.gamma.2)]
                } else {
                    gamma = [1, 1, 1]
                }
                
                let white = colorSpace.normalized.white
                
                let matrix = colorSpace.transferMatrix * colorSpace.cieXYZ.normalizeMatrix
                
                return CGColorSpace(calibratedRGBWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], gamma: gamma,
                                    matrix: [
                                        CGFloat(matrix.a), CGFloat(matrix.e), CGFloat(matrix.i),
                                        CGFloat(matrix.b), CGFloat(matrix.f), CGFloat(matrix.j),
                                        CGFloat(matrix.c), CGFloat(matrix.g), CGFloat(matrix.k)
                    ])
                
            case let colorSpace as CIELabColorSpace:
                
                let white = colorSpace.normalized.white
                
                return CGColorSpace(labWhitePoint: [CGFloat(white.x), CGFloat(white.y), CGFloat(white.z)], blackPoint: [0, 0, 0], range: [-128, 128, -128, 128])
                
            default: break
            }
            return nil
        }
    }
    
#endif

