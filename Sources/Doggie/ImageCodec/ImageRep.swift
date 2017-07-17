//
//  ImageRep.swift
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

import Foundation

protocol ImageRepBase {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get }
    
    var colorSpace: AnyColorSpace { get }
    
    func image() -> AnyImage
}

public struct ImageRep {
    
    private let base: ImageRepBase
    private let cache: Cache
}

extension ImageRep {
    
    private class Cache {
        var image: AnyImage?
    }
}

extension ImageRep {
    
    public var image: AnyImage {
        if cache.image == nil {
            cache.image = base.image()
        }
        return cache.image!
    }
}

extension ImageRep {
    
    public enum Error : Swift.Error {
        
        case UnknownFormat
        case InvalidFormat(String)
        case DecoderError(String)
    }
    
    public init(data: Data) throws {
        
        let decoders: [ImageRepDecoder.Type] = [
            BMPImageDecoder.self,
            PNGImageDecoder.self,
            ]
        
        for Decoder in decoders {
            if let decoder = try Decoder.init(data: Data(data)) {
                self.base = decoder
                self.cache = Cache()
                return
            }
        }
        
        throw Error.UnknownFormat
    }
}

extension ImageRep {
    
    public init<Pixel>(image: Image<Pixel>) {
        self.base = AnyImage(image)
        self.cache = Cache()
    }
    
    public init(image: AnyImage) {
        self.base = image
        self.cache = Cache()
    }
}

extension AnyImage : ImageRepBase {
    
    func image() -> AnyImage {
        return self
    }
}

extension ImageRep {
    
    public var width: Int {
        return base.width
    }
    
    public var height: Int {
        return base.height
    }
    
    public var resolution: Resolution {
        return base.resolution
    }
    
    public var colorSpace: AnyColorSpace {
        return base.colorSpace
    }
}

extension ImageRep {
    
    public enum FileType {
        case bmp
        case gif
        case jpeg
        case jpeg2000
        case png
        case tiff
    }
    
    public enum PropertyKey : Int {
        
        case compressionFactor
        case interlaced
    }
    
    public func representation(using storageType: FileType, properties: [PropertyKey : Any]) -> Data? {
        
        let Encoder: ImageRepEncoder.Type
        
        switch storageType {
        case .bmp: Encoder = BMPEncoder.self
        case .gif: Encoder = GIFEncoder.self
        case .jpeg: Encoder = JPEGEncoder.self
        case .jpeg2000: Encoder = JPEG2000Encoder.self
        case .png: Encoder = PNGEncoder.self
        case .tiff: Encoder = TIFFEncoder.self
        }
        
        return Encoder.encode(image: base.image(), properties: properties)
    }
}

extension ImageRep : CustomStringConvertible {
    
    public var description: String {
        return "ImageRep(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution), base: \(base))"
    }
}

extension AnyImage {
    
    public init(imageRep: ImageRep) {
        self = imageRep.image
    }
    
    public init(data: Data) throws {
        self = try ImageRep(data: data).image
    }
}

extension Image {
    
    public func representation(using storageType: ImageRep.FileType, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        return ImageRep(image: self).representation(using: storageType, properties: properties)
    }
}

extension AnyImage {
    
    public func representation(using storageType: ImageRep.FileType, properties: [ImageRep.PropertyKey : Any]) -> Data? {
        return ImageRep(image: self).representation(using: storageType, properties: properties)
    }
}

