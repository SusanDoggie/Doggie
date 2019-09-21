//
//  CGImageRep.swift
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

#if canImport(CoreGraphics) && canImport(ImageIO)

protocol CGImageRepBase {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get }
    
    var mediaType: CGImageRep.MediaType? { get }
    
    var numberOfPages: Int { get }
    
    var properties: [CFString : Any] { get }
    
    func page(_ index: Int) -> CGImageRepBase
    
    var cgImage: CGImage? { get }
}

public struct CGImageRep {
    
    private let shape: CGImageRepBase
    
    private let cache = Cache()
    
    private init(shape: CGImageRepBase) {
        self.shape = shape
    }
}

extension CGImageRep {
    
    @usableFromInline
    final class Cache {
        
        let lck = SDLock()
        
        var image: CGImage?
        var pages: [Int: CGImageRep]
        
        @usableFromInline
        init() {
            self.pages = [:]
        }
    }
}

extension CGImageRep {
    
    public init?(data: Data) {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil).map(_CGImageSourceImageRepBase.init) else { return nil }
        self.shape = source
    }
}

extension CGImageRep {
    
    public var numberOfPages: Int {
        return shape.numberOfPages
    }
    
    public func page(_ index: Int) -> CGImageRep {
        return cache.lck.synchronized {
            if cache.pages[index] == nil {
                cache.pages[index] = CGImageRep(shape: shape.page(index))
            }
            return cache.pages[index]!
        }
    }
    
    public var cgImage: CGImage? {
        return cache.lck.synchronized {
            if cache.image == nil {
                cache.image = shape.cgImage
            }
            return cache.image
        }
    }
}

extension CGImageRep {
    
    public var width: Int {
        return shape.width
    }
    
    public var height: Int {
        return shape.height
    }
    
    public var resolution: Resolution {
        return shape.resolution
    }
}

extension CGImageRep {
    
    public var properties: [CFString : Any] {
        return shape.properties
    }
}

extension CGImageRep {
    
    public enum MediaType : String, CaseIterable {
        
        case image
        
        case pict
        
        case bmp
        
        case gif
        
        case jpeg
        
        case jpeg2000
        
        case png
        
        case tiff
        
        case quickTimeImage
        
        case appleICNS
        
        case icon
    }
    
    public var mediaType: MediaType? {
        return shape.mediaType
    }
}

struct _CGImageSourceImageRepBase : CGImageRepBase {
    
    let source: CGImageSource
    let index: Int
    let numberOfPages: Int
    
    init(source: CGImageSource, index: Int, numberOfPages: Int) {
        self.source = source
        self.index = index
        self.numberOfPages = numberOfPages
    }
    
    init(source: CGImageSource) {
        self.source = source
        self.index = 0
        self.numberOfPages = CGImageSourceGetCount(source)
    }
    
    var properties: [CFString : Any] {
        return CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString : Any] ?? [:]
    }
    
    var orientation: Int {
        let orientation = properties[kCGImagePropertyOrientation] as? NSNumber
        return orientation?.intValue ?? 1
    }
    
    var _width: Int {
        let width = properties[kCGImagePropertyPixelWidth] as? NSNumber
        return width?.intValue ?? 0
    }
    
    var _height: Int {
        let height = properties[kCGImagePropertyPixelHeight] as? NSNumber
        return height?.intValue ?? 0
    }
    
    var width: Int {
        return 1...4 ~= orientation ? _width : _height
    }
    
    var height: Int {
        return 1...4 ~= orientation ? _height : _width
    }
    
    var _resolution: Resolution {
        
        if let resolutionX = properties[kCGImagePropertyDPIWidth] as? NSNumber, let resolutionY = properties[kCGImagePropertyDPIHeight] as? NSNumber {
            
            return Resolution(horizontal: resolutionX.doubleValue, vertical: resolutionY.doubleValue, unit: .inch)
            
        } else if let properties = self.properties[kCGImagePropertyTIFFDictionary] as? [CFString : Any] {
            
            if let resolutionUnit = (properties[kCGImagePropertyTIFFResolutionUnit] as? NSNumber)?.intValue {
                
                let resolutionX = properties[kCGImagePropertyTIFFXResolution] as? NSNumber
                let resolutionY = properties[kCGImagePropertyTIFFYResolution] as? NSNumber
                
                switch resolutionUnit {
                case 1: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .point)
                case 2: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .inch)
                case 3: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .centimeter)
                default: return .default
                }
            }
        } else if let properties = self.properties[kCGImagePropertyJFIFDictionary] as? [CFString : Any] {
            
            if let resolutionUnit = (properties[kCGImagePropertyJFIFDensityUnit] as? NSNumber)?.intValue {
                
                let resolutionX = properties[kCGImagePropertyJFIFXDensity] as? NSNumber
                let resolutionY = properties[kCGImagePropertyJFIFYDensity] as? NSNumber
                
                switch resolutionUnit {
                case 1: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .point)
                case 2: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .inch)
                case 3: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .centimeter)
                default: return .default
                }
            }
        } else if let properties = self.properties[kCGImagePropertyPNGDictionary] as? [CFString : Any] {
            
            let resolutionX = properties[kCGImagePropertyPNGXPixelsPerMeter] as? NSNumber
            let resolutionY = properties[kCGImagePropertyPNGYPixelsPerMeter] as? NSNumber
            
            return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .meter)
        }
        
        return .default
    }
    
    var resolution: Resolution {
        let resolution = self._resolution
        return 1...4 ~= orientation ? resolution : Resolution(horizontal: resolution.vertical, vertical: resolution.horizontal, unit: resolution.unit)
    }
    
    var mediaType: CGImageRep.MediaType? {
        switch CGImageSourceGetType(source) {
        case kUTTypeImage: return .image
        case kUTTypeJPEG: return .jpeg
        case kUTTypeJPEG2000: return .jpeg2000
        case kUTTypeTIFF: return .tiff
        case kUTTypePICT: return .pict
        case kUTTypeGIF: return .gif
        case kUTTypePNG: return .png
        case kUTTypeQuickTimeImage: return .quickTimeImage
        case kUTTypeAppleICNS: return .appleICNS
        case kUTTypeBMP: return .bmp
        case kUTTypeICO: return .icon
        default: return nil
        }
    }
    
    func page(_ index: Int) -> CGImageRepBase {
        return _CGImageSourceImageRepBase(source: source, index: index, numberOfPages: 1)
    }
    
    var cgImage: CGImage? {
        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }
}

#endif
