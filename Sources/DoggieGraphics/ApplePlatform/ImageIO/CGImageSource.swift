//
//  CGImageSource.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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

#if canImport(CoreGraphics) && canImport(ImageIO)

struct _CGImageSourceImageRepBase: CGImageRepBase {
    
    let source: CGImageSource
    let index: Int
    let numberOfPages: Int
    
    init(source: CGImageSource, index: Int, numberOfPages: Int) {
        self.source = source
        self.index = index
        self.numberOfPages = numberOfPages
    }
    
    init?(source: CGImageSource) {
        self.source = source
        self.index = 0
        self.numberOfPages = CGImageSourceGetCount(source)
        guard numberOfPages > 0 else { return nil }
    }
    
    var general_properties: [CFString: Any] {
        return CGImageSourceCopyProperties(source, nil) as? [CFString: Any] ?? [:]
    }
    
    var properties: [CFString: Any] {
        return CGImageSourceCopyPropertiesAtIndex(source, index, nil) as? [CFString: Any] ?? [:]
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
        
        let properties = self.properties
        
        if let resolutionX = properties[kCGImagePropertyDPIWidth] as? NSNumber, let resolutionY = properties[kCGImagePropertyDPIHeight] as? NSNumber {
            
            return Resolution(horizontal: resolutionX.doubleValue, vertical: resolutionY.doubleValue, unit: .inch)
        }
        
        if let properties = properties[kCGImagePropertyTIFFDictionary] as? [CFString: Any] {
            
            guard let resolutionUnit = (properties[kCGImagePropertyTIFFResolutionUnit] as? NSNumber)?.intValue else { return .default }
            
            let resolutionX = properties[kCGImagePropertyTIFFXResolution] as? NSNumber
            let resolutionY = properties[kCGImagePropertyTIFFYResolution] as? NSNumber
            
            switch resolutionUnit {
            case 1: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .point)
            case 2: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .inch)
            case 3: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .centimeter)
            default: return .default
            }
        }
        
        if let properties = properties[kCGImagePropertyJFIFDictionary] as? [CFString: Any] {
            
            guard let resolutionUnit = (properties[kCGImagePropertyJFIFDensityUnit] as? NSNumber)?.intValue else { return .default }
            
            let resolutionX = properties[kCGImagePropertyJFIFXDensity] as? NSNumber
            let resolutionY = properties[kCGImagePropertyJFIFYDensity] as? NSNumber
            
            switch resolutionUnit {
            case 1: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .point)
            case 2: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .inch)
            case 3: return Resolution(horizontal: resolutionX?.doubleValue ?? 0, vertical: resolutionY?.doubleValue ?? 0, unit: .centimeter)
            default: return .default
            }
        }
        
        if let properties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any] {
            
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
    
    var mediaType: MediaType? {
        return CGImageSourceGetType(source).map { MediaType(rawValue: $0 as String) }
    }
    
    func page(_ index: Int) -> CGImageRepBase {
        return _CGImageSourceImageRepBase(source: source, index: index, numberOfPages: 1)
    }
    
    var cgImage: CGImage? {
        return CGImageSourceCreateImageAtIndex(source, index, nil)
    }
    
    func auxiliaryDataInfo(_ type: String) -> [String: AnyObject]? {
        return CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, index, type as CFString) as? [String: AnyObject]
    }
    
    func copy(to destination: CGImageDestination, properties: [CFString: Any]) {
        CGImageDestinationAddImageFromSource(destination, source, index, properties as CFDictionary)
    }
    
    var isAnimated: Bool {
        return _repeats != nil
    }
    
    var _repeats: Int? {
        
        let general_properties = self.general_properties
        
        if let properties = general_properties[kCGImagePropertyGIFDictionary] as? [CFString: Any] {
            return (properties[kCGImagePropertyGIFLoopCount] as? NSNumber)?.intValue
        }
        if let properties = general_properties[kCGImagePropertyPNGDictionary] as? [CFString: Any] {
            return (properties[kCGImagePropertyAPNGLoopCount] as? NSNumber)?.intValue
        }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            
            if let properties = general_properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any] {
                return (properties[kCGImagePropertyHEICSLoopCount] as? NSNumber)?.intValue
            }
        }
        
        return nil
    }
    
    var repeats: Int {
        return _repeats ?? 0
    }
    
    var duration: Double {
        
        let general_properties = self.general_properties
        let properties = self.properties
        
        if let properties = properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
            let duration = (properties[kCGImagePropertyGIFDelayTime] as? NSNumber)?.doubleValue {
            
            return duration
        }
        if let properties = general_properties[kCGImagePropertyGIFDictionary] as? [CFString: Any],
            let duration = (properties[kCGImagePropertyGIFDelayTime] as? NSNumber)?.doubleValue {
            
            return duration
        }
        if let properties = properties[kCGImagePropertyPNGDictionary] as? [CFString: Any],
            let duration = (properties[kCGImagePropertyAPNGDelayTime] as? NSNumber)?.doubleValue {
            
            return duration
        }
        if let properties = general_properties[kCGImagePropertyPNGDictionary] as? [CFString: Any],
            let duration = (properties[kCGImagePropertyAPNGDelayTime] as? NSNumber)?.doubleValue {
            
            return duration
        }
        
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
            
            if let properties = properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any],
                let duration = (properties[kCGImagePropertyHEICSDelayTime] as? NSNumber)?.doubleValue {
                
                return duration
            }
            if let properties = general_properties[kCGImagePropertyHEICSDictionary] as? [CFString: Any],
                let duration = (properties[kCGImagePropertyHEICSDelayTime] as? NSNumber)?.doubleValue {
                
                return duration
            }
        }
        
        return 0
    }
}

struct _CGImageRepBase: CGImageRepBase {
    
    let image: CGImage
    let resolution: Resolution
    
    var width: Int {
        return image.width
    }
    
    var height: Int {
        return image.height
    }
    
    var mediaType: MediaType? {
        return nil
    }
    
    var numberOfPages: Int {
        return 1
    }
    
    var general_properties: [CFString: Any] {
        return [:]
    }
    
    var properties: [CFString: Any] {
        return [:]
    }
    
    func page(_ index: Int) -> CGImageRepBase {
        precondition(index == 0, "Index out of range.")
        return self
    }
    
    var cgImage: CGImage? {
        return image
    }
    
    func auxiliaryDataInfo(_ type: String) -> [String: AnyObject]? {
        return nil
    }
    
    func copy(to destination: CGImageDestination, properties: [CFString: Any]) {
        
        var properties = properties
        let resolution = self.resolution.convert(to: .inch)
        properties[kCGImagePropertyDPIWidth] = resolution.horizontal
        properties[kCGImagePropertyDPIHeight] = resolution.vertical
        
        CGImageDestinationAddImage(destination, image, properties as CFDictionary)
    }
    
    var isAnimated: Bool {
        return false
    }
    
    var repeats: Int {
        return 0
    }
    
    var duration: Double {
        return 0
    }
}

#endif
