//
//  ImageIO.swift
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

#if canImport(CoreGraphics) && canImport(ImageIO) && canImport(AVFoundation)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
let kUTTypeHEIC = AVFileType.heic as CFString

public struct CGImageAnimationFrame {
    
    public var image: CGImage
    public var delay: Double
    
    public init(image: CGImage, delay: Double) {
        self.image = image
        self.delay = delay
    }
}

extension CGImage {
    
    private static func withImageDestination(_ type: CFString, _ count: Int, callback: (CGImageDestination) -> Void) -> Data? {
        
        let data = NSMutableData()
        
        guard let imageDestination = CGImageDestinationCreateWithData(data, type, count, nil) else { return nil }
        
        callback(imageDestination)
        
        guard CGImageDestinationFinalize(imageDestination) else { return nil }
        
        return data as Data
    }
}

extension CGImage {
    
    public enum MediaType : String, CaseIterable {
        
        case bmp
        
        case gif
        
        case jpeg
        
        case jpeg2000
        
        case png
        
        case tiff
        
        case heic
    }
    
    public enum PropertyKey : Int, CaseIterable {
        
        case compression
        
        case compressionQuality
        
        case interlaced
        
        case resolution
    }
    
    public struct PNGCompressionFilter: OptionSet {
        
        public var rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        public static let none      = PNGCompressionFilter(rawValue: IMAGEIO_PNG_FILTER_NONE)
        public static let sub       = PNGCompressionFilter(rawValue: IMAGEIO_PNG_FILTER_SUB)
        public static let up        = PNGCompressionFilter(rawValue: IMAGEIO_PNG_FILTER_UP)
        public static let average   = PNGCompressionFilter(rawValue: IMAGEIO_PNG_FILTER_AVG)
        public static let paeth     = PNGCompressionFilter(rawValue: IMAGEIO_PNG_FILTER_PAETH)
        
        public static let all: PNGCompressionFilter = [.none, .sub, .up, .average, .paeth]
    }
    
    public enum TIFFCompressionScheme : CaseIterable {
        
        case none
        
        case lzw
        
        case packBits
    }
    
    public func representation(using storageType: MediaType, properties: [PropertyKey : Any]) -> Data? {
        
        let type: CFString
        var _properties: [CFString: Any] = [:]
        
        switch storageType {
        case .bmp: type = kUTTypeBMP
        case .gif: type = kUTTypeGIF
        case .jpeg: type = kUTTypeJPEG
        case .jpeg2000: type = kUTTypeJPEG2000
        case .png:
            
            type = kUTTypePNG
            
            var _png_properties: [CFString: Any] = [:]
            
            if properties[.interlaced] as? Bool == true {
                _png_properties[kCGImagePropertyPNGInterlaceType] = 1
            }
            
            if #available(macOS 10.11, iOS 9.0, tvOS 9.0, watchOS 2.0, *), let compression = properties[.compression] as? PNGCompressionFilter {
                if compression.isEmpty {
                    _png_properties[kCGImagePropertyPNGCompressionFilter] = IMAGEIO_PNG_NO_FILTERS
                } else {
                    _png_properties[kCGImagePropertyPNGCompressionFilter] = compression.rawValue
                }
            }
            
            _properties[kCGImagePropertyPNGDictionary] = _png_properties
            
        case .tiff:
            
            type = kUTTypeTIFF
            
            var _tiff_properties: [CFString: Any] = [:]
            
            if let compression = properties[.compression] as? TIFFCompressionScheme {
                switch compression {
                case .none: break
                case .lzw: _tiff_properties[kCGImagePropertyTIFFCompression] = 5
                case .packBits: _tiff_properties[kCGImagePropertyTIFFCompression] = 32773
                }
            }
            
            _properties[kCGImagePropertyTIFFDictionary] = _tiff_properties
            
        case .heic:
            
            guard #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) else { return nil }
            
            type = kUTTypeHEIC
        }
        
        if let resolution = properties[.resolution] as? Resolution {
            let _resolution = resolution.convert(to: .inch)
            _properties[kCGImagePropertyDPIWidth] = _resolution.horizontal
            _properties[kCGImagePropertyDPIHeight] = _resolution.vertical
        }
        
        if let compressionQuality = properties[.compressionQuality] as? NSNumber {
            _properties[kCGImageDestinationLossyCompressionQuality] = compressionQuality
        }
        
        return CGImage.withImageDestination(type, 1) { CGImageDestinationAddImage($0, self, _properties as CFDictionary) }
    }
    
    public func tiffRepresentation(compression: TIFFCompressionScheme = .none, resolution: Resolution = .default) -> Data? {
        return self.representation(using: .tiff, properties: [.compression: compression, .resolution: resolution])
    }
    
    public func pngRepresentation(interlaced: Bool = false, compression: PNGCompressionFilter = .all, resolution: Resolution = .default) -> Data? {
        return self.representation(using: .png, properties: [.interlaced: interlaced, .compression: compression, .resolution: resolution])
    }
    
    public func jpegRepresentation(compressionQuality: Double, resolution: Resolution = .default) -> Data? {
        return self.representation(using: .jpeg, properties: [.compressionQuality: compressionQuality, .resolution: resolution])
    }
}

extension CGImage {
    
    public static func animatedGIFRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImage.withImageDestination(kUTTypeGIF, frames.count) { imageDestination in
            
            CGImageDestinationSetProperties(imageDestination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(imageDestination, frame.image, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    public static func animatedPNGRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImage.withImageDestination(kUTTypePNG, frames.count) { imageDestination in
            
            CGImageDestinationSetProperties(imageDestination, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(imageDestination, frame.image, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 4.0, *)
    public static func animatedHEICRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImage.withImageDestination(kUTTypeHEIC, frames.count) { imageDestination in
            
            CGImageDestinationSetProperties(imageDestination, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(imageDestination, frame.image, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
}

extension CGImage {
    
    public static func animatedGIFRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedGIFRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    public static func animatedPNGRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedPNGRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 4.0, *)
    public static func animatedHEICRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedHEICRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
}

#endif
