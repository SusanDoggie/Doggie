//
//  AVPortraitEffectsMatte.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

#if canImport(CoreGraphics) && canImport(ImageIO) && canImport(AVFoundation)

@available(macOS 10.14, macCatalyst 14.0, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
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

extension CGImageRep {
    
    @available(macOS 10.14, macCatalyst 14.0, iOS 12.0, tvOS 12.0, watchOS 5.0, *)
    public var portraitEffectsMatte: AVPortraitEffectsMatte? {
        guard let info = self.auxiliaryDataInfo(kCGImageAuxiliaryDataTypePortraitEffectsMatte as String) else { return nil }
        return try? AVPortraitEffectsMatte(fromDictionaryRepresentation: info)
    }
}

#endif
