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
        
        public var cgColorSpace : CGColorSpace? {
            
            if #available(OSX 10.12, iOS 10.0, *) {
                
                return iccData.map { CGColorSpace(iccData: $0 as CFData) }
                
            } else {
                
                if Model.numberOfComponents != 1 && Model.numberOfComponents != 3 && Model.numberOfComponents != 4 {
                    return nil
                }
                
                if let iccData = iccData.flatMap({ CGDataProvider(data: $0 as CFData) }) {
                    
                    var range: [CGFloat] = []
                    
                    for i in 0..<Model.numberOfComponents {
                        switch Model.self {
                        case is LabColorModel.Type, is LuvColorModel.Type:
                            if i == 0 {
                                range.append(0)
                                range.append(100)
                            } else {
                                range.append(-128)
                                range.append(128)
                            }
                        default:
                            range.append(0)
                            range.append(1)
                        }
                    }
                    
                    return CGColorSpace(iccBasedNComponents: Model.numberOfComponents, range: range, profile: iccData, alternate: nil)
                    
                } else {
                    return nil
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
            if let base = base as? CGColorSpaceConvertibleProtocol {
                return base.cgColorSpace
            }
            return nil
        }
    }
    
#endif

