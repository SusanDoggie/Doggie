//
//  ImageRep.swift
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

@usableFromInline
protocol ImageRepBase {
    
    var width: Int { get }
    
    var height: Int { get }
    
    var resolution: Resolution { get }
    
    var colorSpace: AnyColorSpace { get }
    
    var numberOfPages: Int { get }
    
    func page(_ index: Int) -> ImageRepBase
    
    func image(fileBacked: Bool) -> AnyImage
    
    var isAnimated: Bool { get }
    
    var repeats: Int { get }
    
    var duration: Double { get }
}

extension ImageRepBase {
    
    @usableFromInline
    var numberOfPages: Int {
        return 1
    }
    
    @usableFromInline
    func page(_ index: Int) -> ImageRepBase {
        precondition(index == 0, "Index out of range.")
        return self
    }
}

extension ImageRepBase {
    
    @usableFromInline
    var isAnimated: Bool {
        return false
    }
    
    @usableFromInline
    var repeats: Int {
        return 0
    }
    
    @usableFromInline
    var duration: Double {
        return isAnimated && numberOfPages > 1 ? (0..<numberOfPages).reduce(0) { $0 + self.page($1).duration } : 0
    }
}

@frozen
public struct ImageRep {
    
    public let originalData: Data?
    
    private let base: ImageRepBase
    
    private let cache = Cache()
    
    private init(base: ImageRepBase) {
        self.originalData = nil
        self.base = base
    }
}

extension ImageRep {
    
    @usableFromInline
    final class Cache {
        
        let lck = SDLock()
        
        var image: AnyImage?
        var pages: [Int: ImageRep]
        
        @usableFromInline
        init() {
            self.image = nil
            self.pages = [:]
        }
    }
    
    public func clearCaches() {
        cache.lck.synchronized {
            cache.image = nil
            cache.pages = [:]
        }
    }
}

extension ImageRep {
    
    private static let decoders: [ImageRepDecoder.Type] = [
        BMPDecoder.self,
        TIFFDecoder.self,
        PNGDecoder.self,
        JPEGDecoder.self,
        WEBPDecoder.self,
    ]
    
    public static var supportedMediaTypes: [MediaType] {
        
        var types: [MediaType] = []
        
        for decoder in decoders {
            for type in decoder.supportedMediaTypes where !types.contains(type) {
                types.append(type)
            }
        }
        
        return types
    }
}

extension ImageRep {
    
    public enum Error: Swift.Error {
        
        case UnknownFormat
        case InvalidFormat(String)
        case Unsupported(String)
        case DecoderError(String)
    }
    
    public init(data: Data) throws {
        
        self.originalData = data
        
        for Decoder in ImageRep.decoders {
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
        self.init(base: AnyImage(image))
    }
    
    public init(image: AnyImage) {
        self.init(base: image)
    }
}

extension AnyImage: ImageRepBase {
    
    @usableFromInline
    func image(fileBacked: Bool) -> AnyImage {
        var copy = self
        copy.fileBacked = fileBacked
        return copy
    }
}

extension ImageRep {
    
    public var numberOfPages: Int {
        return base.numberOfPages
    }
    
    public func page(_ index: Int) -> ImageRep {
        return cache.lck.synchronized {
            if cache.pages[index] == nil {
                cache.pages[index] = ImageRep(base: base.page(index))
            }
            return cache.pages[index]!
        }
    }
    
    fileprivate func image(fileBacked: Bool) -> AnyImage {
        return cache.lck.synchronized {
            if cache.image == nil {
                cache.image = base.image(fileBacked: true)
            }
            return cache.image!.image(fileBacked: fileBacked)
        }
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
    
    public var isAnimated: Bool {
        return base.isAnimated
    }
    
    public var repeats: Int {
        return base.repeats
    }
    
    public var duration: Double {
        return base.duration
    }
}

extension ImageRep {
    
    public var mediaType: MediaType? {
        guard let decoder = base as? ImageRepDecoder else { return nil }
        return decoder.mediaType
    }
}

extension ImageRep {
    
    public enum PropertyKey: CaseIterable {
        
        case compression
        
        case compressionQuality
        
        case deflateLevel
        
        case interlaced
    }
    
    public enum TIFFCompressionScheme: CaseIterable {
        
        case none
        
        case deflate
    }
    
    public func representation(using storageType: MediaType, properties: [PropertyKey: Any]) -> Data? {
        
        let image = base as? AnyImage ?? self.image(fileBacked: true)
        guard image.width > 0 && image.height > 0 else { return nil }
        
        let Encoder: ImageRepEncoder.Type
        
        switch storageType {
        case .bmp: Encoder = BMPEncoder.self
        case .gif: Encoder = GIFEncoder.self
        case .jpeg: Encoder = JPEGEncoder.self
        case .png: Encoder = PNGEncoder.self
        case .tiff: Encoder = TIFFEncoder.self
        case .webp: Encoder = WEBPEncoder.self
        default: return nil
        }
        
        return Encoder.encode(image: image, properties: properties)
    }
}

extension ImageRep: CustomStringConvertible {
    
    public var description: String {
        return "ImageRep(width: \(width), height: \(height), colorSpace: \(colorSpace), resolution: \(resolution), base: \(base))"
    }
}

extension AnyImage {
    
    public init(imageRep: ImageRep, fileBacked: Bool = false) {
        self = imageRep.image(fileBacked: fileBacked)
    }
    
    public init(data: Data, fileBacked: Bool = false) throws {
        self = try ImageRep(data: data).image(fileBacked: fileBacked)
    }
}

extension Image {
    
    public func representation(using storageType: MediaType, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        return ImageRep(image: self).representation(using: storageType, properties: properties)
    }
}

extension AnyImage {
    
    public func representation(using storageType: MediaType, properties: [ImageRep.PropertyKey: Any]) -> Data? {
        return ImageRep(image: self).representation(using: storageType, properties: properties)
    }
}

extension ImageRep {
    
    public func tiffRepresentation(compression: TIFFCompressionScheme = .none) -> Data? {
        return self.representation(using: .tiff, properties: [.compression: compression])
    }
    
    public func pngRepresentation(interlaced: Bool = false) -> Data? {
        return self.representation(using: .png, properties: [.interlaced: interlaced])
    }
    
    public func jpegRepresentation(compressionQuality: Double) -> Data? {
        return self.representation(using: .jpeg, properties: [.compressionQuality: compressionQuality])
    }
}

extension Image {
    
    public func tiffRepresentation(compression: ImageRep.TIFFCompressionScheme = .none) -> Data? {
        return self.representation(using: .tiff, properties: [.compression: compression])
    }
    
    public func pngRepresentation(interlaced: Bool = false) -> Data? {
        return self.representation(using: .png, properties: [.interlaced: interlaced])
    }
    
    public func jpegRepresentation(compressionQuality: Double) -> Data? {
        return self.representation(using: .jpeg, properties: [.compressionQuality: compressionQuality])
    }
}

extension AnyImage {
    
    public func tiffRepresentation(compression: ImageRep.TIFFCompressionScheme = .none) -> Data? {
        return self.representation(using: .tiff, properties: [.compression: compression])
    }
    
    public func pngRepresentation(interlaced: Bool = false) -> Data? {
        return self.representation(using: .png, properties: [.interlaced: interlaced])
    }
    
    public func jpegRepresentation(compressionQuality: Double) -> Data? {
        return self.representation(using: .jpeg, properties: [.compressionQuality: compressionQuality])
    }
}

