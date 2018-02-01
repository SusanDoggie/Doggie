//
//  CGColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
    
    fileprivate let ColorSpaceCacheCGColorSpaceKey = "ColorSpaceCacheCGColorSpaceKey"
    
    extension ColorSpace {
        
        public var cgColorSpace : CGColorSpace? {
            
            return self.cache[ColorSpaceCacheCGColorSpaceKey] {
                
                if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                    
                    return iccData.map { CGColorSpace(iccData: $0 as CFData) }
                    
                } else {
                    
                    if Model.numberOfComponents != 1 && Model.numberOfComponents != 3 && Model.numberOfComponents != 4 {
                        return nil
                    }
                    
                    if let iccData = iccData.flatMap({ CGDataProvider(data: $0 as CFData) }) {
                        
                        var range: [CGFloat] = []
                        
                        for i in 0..<Model.numberOfComponents {
                            let _range = Model.rangeOfComponent(i)
                            range.append(CGFloat(_range.lowerBound))
                            range.append(CGFloat(_range.upperBound))
                        }
                        
                        return CGColorSpace(iccBasedNComponents: Model.numberOfComponents, range: range, profile: iccData, alternate: nil)
                        
                    } else {
                        return nil
                    }
                }
            }
        }
    }
    
    extension AnyColorSpace {
        
        public init?(cgColorSpace: CGColorSpace) {
            
            if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
                
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
    
    extension AnyColorSpace {
        
        @available(OSX 10.11, iOS 9.0, *)
        public static var availableColorSpaces: [AnyColorSpace] {
            
            var availableColorSpaces: [AnyColorSpace] = []
            
            for url in FileManager.default.fileUrls(FileManager.default.urls(for: .libraryDirectory, in: .allDomainsMask).map { URL(fileURLWithPath: "ColorSync/Profiles/", relativeTo: $0) }) {
                
                if let data = try? Data(contentsOf: url, options: .alwaysMapped), let colorSpace = try? AnyColorSpace(iccData: data) {
                    availableColorSpaces.append(colorSpace)
                }
            }
            
            return availableColorSpaces
        }
        
    }
    
#endif

