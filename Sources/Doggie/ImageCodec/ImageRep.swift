//
//  ImageRep.swift
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

import Foundation

protocol ImageRepBase {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get }
    
    var colorSpace: AnyColorSpace { get }
    
    var numberOfPages: Int { get }
    
    func page(_ index: Int) -> ImageRepBase
    
    func image(option: MappedBufferOption) -> AnyImage
}

extension ImageRepBase {
    
    var numberOfPages: Int {
        return 1
    }
    
    func page(_ index: Int) -> ImageRepBase {
        guard index == 0 else { fatalError("Index out of range.") }
        return self
    }
}

public struct ImageRep {
    
    fileprivate let base: ImageRepBase
    
    private init(base: ImageRepBase) {
        self.base = base
    }
}

extension ImageRep {
    
    public enum Error : Swift.Error {
        
        case UnknownFormat
        case InvalidFormat(String)
        case Unsupported(String)
        case DecoderError(String)
    }
    
    public init(data: Data) throws {
        
        let decoders: [ImageRepDecoder.Type] = [
            BMPDecoder.self,
            TIFFDecoder.self,
            PNGDecoder.self,
            //JPEGDecoder.self,
            ]
        
        for Decoder in decoders {
            if let decoder = try Decoder.init(data: data) {
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

extension AnyImage : ImageRepBase {
    
    func image(option: MappedBufferOption) -> AnyImage {
        return AnyImage(image: self, option: option)
    }
}

extension ImageRep {
    
    public var numberOfPages: Int {
        return base.numberOfPages
    }
    
    public func page(_ index: Int) -> ImageRep {
        return ImageRep(base: base.page(index))
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
        
        let image = base as? AnyImage ?? base.image(option: .fileBacked)
        guard image.width > 0 && image.height > 0 else { return nil }
        
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

extension AnyImage {
    
    public init(imageRep: ImageRep, option: MappedBufferOption = .default) {
        self = imageRep.base.image(option: option)
    }
    
    public init(data: Data, option: MappedBufferOption = .default) throws {
        self = try ImageRep(data: data).base.image(option: option)
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

