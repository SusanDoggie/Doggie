//
//  CGAnimatedImage.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

public struct CGAnimatedImage {
    
    public var frames: [CGAnimatedImageFrame]
    
    public var repeats: Int
    
    public init(frames: [CGAnimatedImageFrame], repeats: Int) {
        self.frames = frames
        self.repeats = repeats
    }
}

public struct CGAnimatedImageFrame {
    
    public var image: CGImage
    
    public var duration: Double
    
    public init(image: CGImage, duration: Double) {
        self.image = image
        self.duration = duration
    }
}

extension CGAnimatedImage {
    
    public func representation(using storageType: MediaType, properties: [CGImageRep.PropertyKey: Any]) -> Data? {
        
        var _properties: [CFString: Any] = [:]
        var _typed_properties: [CFString: Any] = [:]
        
        let kCGImagePropertyMediaDictionary: CFString
        let kCGImagePropertyLoopCount: CFString
        let kCGImagePropertyDelayTime: CFString
        
        switch storageType {
            
        case .gif:
            
            kCGImagePropertyMediaDictionary = kCGImagePropertyGIFDictionary
            kCGImagePropertyLoopCount = kCGImagePropertyGIFLoopCount
            kCGImagePropertyDelayTime = kCGImagePropertyGIFDelayTime
            
        case .png:
            
            kCGImagePropertyMediaDictionary = kCGImagePropertyPNGDictionary
            kCGImagePropertyLoopCount = kCGImagePropertyAPNGLoopCount
            kCGImagePropertyDelayTime = kCGImagePropertyAPNGDelayTime
            
            if properties[.interlaced] as? Bool == true {
                _typed_properties[kCGImagePropertyPNGInterlaceType] = 1
            }
            
            var filter = IMAGEIO_PNG_FILTER_NONE
            filter |= IMAGEIO_PNG_FILTER_SUB
            filter |= IMAGEIO_PNG_FILTER_UP
            filter |= IMAGEIO_PNG_FILTER_AVG
            filter |= IMAGEIO_PNG_FILTER_PAETH
            
            _typed_properties[kCGImagePropertyPNGCompressionFilter] = filter
            
        case .heic:
            
            #if canImport(AVFoundation)
            
            guard #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) else { return nil }
            
            kCGImagePropertyMediaDictionary = kCGImagePropertyHEICSDictionary
            kCGImagePropertyLoopCount = kCGImagePropertyHEICSLoopCount
            kCGImagePropertyDelayTime = kCGImagePropertyHEICSDelayTime
            
            #else
            
            return nil
            
            #endif
            
        case .webp:
            
            var _properties: [ImageRep.PropertyKey: Any] = [:]
            _properties[.compressionQuality] = _properties[.compressionQuality]
            
            return WEBPAnimatedEncoder.encode(image: self, properties: _properties)
            
        default: return nil
        }
        
        if let compressionQuality = properties[.compressionQuality] as? NSNumber {
            _properties[kCGImageDestinationLossyCompressionQuality] = compressionQuality
        }
        
        return CGImageRep.withImageDestination(storageType.rawValue as CFString, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyMediaDictionary: [kCGImagePropertyLoopCount: repeats]] as CFDictionary)
            
            for frame in frames {
                
                var _typed_properties = _typed_properties
                _typed_properties[kCGImagePropertyDelayTime] = frame.duration
                
                var _properties = _properties
                _properties[kCGImagePropertyMediaDictionary] = _typed_properties
                
                CGImageDestinationAddImage(destination, frame.image, _properties as CFDictionary)
            }
        }
        
    }
}

extension CGAnimatedImage {
    
    public init?(_ image: AnimatedImage) {
        
        self.frames = []
        self.repeats = image.repeats
        
        for frame in image.frames {
            guard let frame = CGAnimatedImageFrame(frame) else { return nil }
            self.frames.append(frame)
        }
    }
}

extension CGAnimatedImageFrame {
    
    public init?(_ frame: AnimatedImageFrame) {
        guard let image = frame.image.cgImage else { return nil }
        self.image = image
        self.duration = frame.duration
    }
}

extension AnimatedImage {
    
    public init?(_ image: CGAnimatedImage) {
        
        self.frames = []
        self.repeats = image.repeats
        
        for frame in image.frames {
            guard let frame = AnimatedImageFrame(frame) else { return nil }
            self.frames.append(frame)
        }
    }
}

extension AnimatedImageFrame {
    
    public init?(_ frame: CGAnimatedImageFrame) {
        guard let image = AnyImage(cgImage: frame.image) else { return nil }
        self.image = image
        self.duration = frame.duration
    }
}

#endif
