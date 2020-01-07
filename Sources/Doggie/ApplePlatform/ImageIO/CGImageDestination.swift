//
//  CGImageDestination.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreGraphics) && canImport(ImageIO)

extension CGImageRep {
    
    static func withImageDestination(_ type: CFString, _ count: Int, callback: (CGImageDestination) -> Void) -> Data? {
        
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data, type, count, nil) else { return nil }
        
        callback(destination)
        
        guard CGImageDestinationFinalize(destination) else { return nil }
        
        return data as Data
    }
}

extension CGImageRep {
    
    public enum PropertyKey : Int, CaseIterable {
        
        case compression
        
        case compressionQuality
        
        case interlaced
        
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
        
        if let compressionQuality = properties[.compressionQuality] as? NSNumber {
            _properties[kCGImageDestinationLossyCompressionQuality] = compressionQuality
        }
        
        return CGImageRep.withImageDestination(storageType.rawValue as CFString, 1) { destination in
            
            self.base.copy(to: destination, properties: _properties)
            
            #if canImport(AVFoundation)
            
            #if !os(watchOS)
            
            if #available(macOS 10.13, iOS 11.0, tvOS 11.0, *), let depthData = properties[.depthData] as? AVDepthData {
                
                var type: NSString?
                let dictionary = depthData.dictionaryRepresentation(forAuxiliaryDataType: &type)
                
                if let type = type, let dictionary = dictionary {
                    CGImageDestinationAddAuxiliaryDataInfo(destination, type, dictionary as CFDictionary)
                }
            }
            
            #endif
            
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
        return self.representation(using: .tiff, properties: [.compression: compression])
    }
    
    public func pngRepresentation(interlaced: Bool = false, compression: PNGCompressionFilter = .all, resolution: Resolution = .default) -> Data? {
        return self.representation(using: .png, properties: [.interlaced: interlaced, .compression: compression])
    }
    
    public func jpegRepresentation(compressionQuality: Double, resolution: Resolution = .default) -> Data? {
        return self.representation(using: .jpeg, properties: [.compressionQuality: compressionQuality])
    }
}

extension CGImage {
    
    open func representation(using storageType: MediaType, resolution: Resolution = .default, properties: [CGImageRep.PropertyKey : Any]) -> Data? {
        let imageRep = CGImageRep(cgImage: self, resolution: resolution)
        return imageRep.representation(using: storageType, properties: properties)
    }
    
    open func tiffRepresentation(resolution: Resolution = .default, compression: CGImageRep.TIFFCompressionScheme = .none) -> Data? {
        return self.representation(using: .tiff, resolution: resolution, properties: [.compression: compression])
    }
    
    open func pngRepresentation(resolution: Resolution = .default, interlaced: Bool = false, compression: CGImageRep.PNGCompressionFilter = .all) -> Data? {
        return self.representation(using: .png, resolution: resolution, properties: [.interlaced: interlaced, .compression: compression])
    }
    
    open func jpegRepresentation(resolution: Resolution = .default, compressionQuality: Double) -> Data? {
        return self.representation(using: .jpeg, resolution: resolution, properties: [.compressionQuality: compressionQuality])
    }
}

#endif
