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

#if canImport(CoreGraphics) && canImport(ImageIO)

public struct CGImageAnimationFrame {
    
    public var image: CGImage
    public var delay: Double
    
    public init(image: CGImage, delay: Double) {
        self.image = image
        self.delay = delay
    }
}

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension AVDepthData {
    
    public convenience init<T>(texture: StencilTexture<T>, metadata: CGImageMetadata? = nil) throws {
        
        var description: [AnyHashable: Any] = [:]
        
        description[kCGImagePropertyPixelFormat] = kCVPixelFormatType_DepthFloat32
        description[kCGImagePropertyWidth] = texture.width
        description[kCGImagePropertyHeight] = texture.height
        description[kCGImagePropertyBytesPerRow] = 4 * texture.width
        
        let pixels = texture.pixels as? MappedBuffer<Float> ?? texture.pixels.map(Float.init)
        
        var dictionary: [AnyHashable: Any] = [
            kCGImageAuxiliaryDataInfoData: pixels.data as CFData,
            kCGImageAuxiliaryDataInfoDataDescription: description
        ]
        
        if let metadata = metadata {
            dictionary[kCGImageAuxiliaryDataInfoMetadata] = metadata
        }
        
        try self.init(fromDictionaryRepresentation: dictionary)
    }
}

@available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
extension AVPortraitEffectsMatte {
    
    public convenience init<T>(texture: StencilTexture<T>) throws {
        
        var description: [AnyHashable: Any] = [:]
        
        description[kCGImagePropertyPixelFormat] = kCVPixelFormatType_OneComponent8
        description[kCGImagePropertyWidth] = texture.width
        description[kCGImagePropertyHeight] = texture.height
        description[kCGImagePropertyBytesPerRow] = texture.width
        
        let pixels = texture.pixels.map { UInt8(($0 * 255).clamped(to: 0...255).rounded()) }
        
        let dictionary: [AnyHashable: Any] = [
            kCGImageAuxiliaryDataInfoData: pixels.data as CFData,
            kCGImageAuxiliaryDataInfoDataDescription: description
        ]
        
        try self.init(fromDictionaryRepresentation: dictionary)
    }
}

extension CGImage {
    
    private static func withImageDestination(_ type: CFString, _ count: Int, callback: (CGImageDestination) -> Void) -> Data? {
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data, type, count, nil) else { return nil }
        
        callback(destination)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
}

extension CGImage {
    
    public struct MediaType : RawRepresentable, Hashable, ExpressibleByStringLiteral {
        
        public var rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: String) {
            self.rawValue = value
        }
        
        public static let bmp        = MediaType(rawValue: kUTTypeBMP as String)
        public static let gif        = MediaType(rawValue: kUTTypeGIF as String)
        public static let jpeg       = MediaType(rawValue: kUTTypeJPEG as String)
        public static let jpeg2000   = MediaType(rawValue: kUTTypeJPEG2000 as String)
        public static let png        = MediaType(rawValue: kUTTypePNG as String)
        public static let tiff       = MediaType(rawValue: kUTTypeTIFF as String)
        
        #if canImport(AVFoundation)
        
        @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
        public static let heif       = MediaType(rawValue: AVFileType.heif.rawValue)
        
        @available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *)
        public static let heic       = MediaType(rawValue: AVFileType.heic.rawValue)
        
        #endif
        
    }
    
    public enum PropertyKey : Int, CaseIterable {
        
        case compression
        
        case compressionQuality
        
        case interlaced
        
        case resolution
        
        case depthData
        
        case matteData
        
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
        
        var _properties: [CFString: Any] = [:]
        
        switch storageType {
        case .png:
            
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
            
            var _tiff_properties: [CFString: Any] = [:]
            
            if let compression = properties[.compression] as? TIFFCompressionScheme {
                switch compression {
                case .none: break
                case .lzw: _tiff_properties[kCGImagePropertyTIFFCompression] = 5
                case .packBits: _tiff_properties[kCGImagePropertyTIFFCompression] = 32773
                }
            }
            
            _properties[kCGImagePropertyTIFFDictionary] = _tiff_properties
            
        default: break
        }
        
        if let resolution = properties[.resolution] as? Resolution {
            let _resolution = resolution.convert(to: .inch)
            _properties[kCGImagePropertyDPIWidth] = _resolution.horizontal
            _properties[kCGImagePropertyDPIHeight] = _resolution.vertical
        }
        
        if let compressionQuality = properties[.compressionQuality] as? NSNumber {
            _properties[kCGImageDestinationLossyCompressionQuality] = compressionQuality
        }
        
        return CGImage.withImageDestination(storageType.rawValue as CFString, 1) { destination in
            
            CGImageDestinationAddImage(destination, self, _properties as CFDictionary)
            
            #if canImport(AVFoundation)
            
            if #available(macOS 10.13, iOS 11.0, tvOS 11.0, *), let depthData = properties[.depthData] as? AVDepthData {
                
                var type: NSString?
                let dictionary = depthData.dictionaryRepresentation(forAuxiliaryDataType: &type)
                
                if let type = type, let dictionary = dictionary {
                    CGImageDestinationAddAuxiliaryDataInfo(destination, type, dictionary as CFDictionary)
                }
            }
            
            if #available(macOS 10.14, iOS 12.0, tvOS 12.0, watchOS 5.0, *), let matteData = properties[.matteData] as? AVPortraitEffectsMatte {
                
                var type: NSString?
                let dictionary = matteData.dictionaryRepresentation(forAuxiliaryDataType: &type)
                
                if let type = type, let dictionary = dictionary {
                    CGImageDestinationAddAuxiliaryDataInfo(destination, type, dictionary as CFDictionary)
                }
            }
            
            #endif
            
        }
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
        
        return CGImage.withImageDestination(kUTTypeGIF, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    public static func animatedPNGRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImage.withImageDestination(kUTTypePNG, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyPNGDictionary: [kCGImagePropertyAPNGDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    #if canImport(AVFoundation)
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 4.0, *)
    public static func animatedHEICRepresentation(loop: Int, frames: [CGImageAnimationFrame]) -> Data? {
        
        return CGImage.withImageDestination(AVFileType.heic as CFString, frames.count) { destination in
            
            CGImageDestinationSetProperties(destination, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSLoopCount: loop]] as CFDictionary)
            
            for frame in frames {
                CGImageDestinationAddImage(destination, frame.image, [kCGImagePropertyHEICSDictionary: [kCGImagePropertyHEICSDelayTime: frame.delay]] as CFDictionary)
            }
        }
    }
    
    #endif
    
}

extension CGImage {
    
    public static func animatedGIFRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedGIFRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    public static func animatedPNGRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedPNGRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    #if canImport(AVFoundation)
    
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 4.0, *)
    public static func animatedHEICRepresentation(loop: Int, delay: Double, frames: [CGImage]) -> Data? {
        return self.animatedHEICRepresentation(loop: loop, frames: frames.map { CGImageAnimationFrame(image: $0, delay: delay) })
    }
    
    #endif
    
}

#endif
