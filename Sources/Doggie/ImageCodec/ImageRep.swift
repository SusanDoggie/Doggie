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
    
    func image() throws -> AnyImage
}

public struct ImageRep {
    
    let base: ImageRepBase
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
            if let decoder = Decoder.init(data: Data(data)) {
                self.base = decoder
                return
            }
        }
        
        throw Error.UnknownFormat
    }
}

extension ImageRep {
    
    public init<Pixel>(image: Image<Pixel>) {
        self.base = AnyImage(image)
    }
    
    public init(image: AnyImage) {
        self.base = image
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
    }
    
    public func representation(using storageType: FileType, properties: [PropertyKey : Any]) -> Data? {
        
        guard let image = try? base.image() else { return nil }
        
        let Encoder: ImageRepEncoder.Type
        
        switch storageType {
        case .bmp: Encoder = BMPEncoder.self
        case .gif: Encoder = GIFEncoder.self
        case .jpeg: Encoder = JPEGEncoder.self
        case .jpeg2000: Encoder = JPEG2000Encoder.self
        case .png: Encoder = PNGEncoder.self
        case .tiff: Encoder = TIFFEncoder.self
        }
        
        return Encoder.encode(image: image, properties: properties)
    }
}

extension ImageRep : CustomStringConvertible {
    
    public var description: String {
        return "ImageRep(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution), base: \(base))"
    }
}

protocol ImageRepDecoder : ImageRepBase {
    
    init?(data: Data)
}

protocol ImageRepEncoder {
    
    static func encode(image: AnyImage, properties: [ImageRep.PropertyKey : Any]) -> Data?
}

extension AnyImage : ImageRepBase {
    
    func image() throws -> AnyImage {
        return self
    }
}

extension AnyImage {
    
    public init(imageRep: ImageRep) throws {
        self = try imageRep.base.image()
    }
    
    public init(data: Data) throws {
        try self.init(imageRep: try ImageRep(data: data))
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

