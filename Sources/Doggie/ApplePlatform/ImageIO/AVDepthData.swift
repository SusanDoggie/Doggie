//
//  AVDepthData.swift
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

#if canImport(CoreGraphics) && canImport(ImageIO) && canImport(AVFoundation) && !os(watchOS)

@available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
extension AVDepthData {
    
    open convenience init<T>(texture: StencilTexture<T>, metadata: CGImageMetadata? = nil) throws {
        
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

extension CGImageRep {
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open var disparityData: AVDepthData? {
        guard let info = self.auxiliaryDataInfo(kCGImageAuxiliaryDataTypeDisparity as String) else { return nil }
        return try? AVDepthData(fromDictionaryRepresentation: info)
    }
    
    @available(macOS 10.13, iOS 11.0, tvOS 11.0, *)
    open var depthData: AVDepthData? {
        guard let info = self.auxiliaryDataInfo(kCGImageAuxiliaryDataTypeDepth as String) else { return nil }
        return try? AVDepthData(fromDictionaryRepresentation: info)
    }
}

#endif
