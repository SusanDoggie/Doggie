//
//  CGImage.swift
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

#if canImport(CoreGraphics)

extension CGImage {
    
    public static func create(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32, command: (CGContext) -> ()) -> CGImage? {
        
        if let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) {
            
            command(context)
            
            return context.makeImage()
            
        } else {
            return nil
        }
    }
    
    public static func create(_ buffer: UnsafeRawPointer, width: Int, height: Int, bitsPerComponent: Int, bitsPerPixel: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) -> CGImage? {
        
        if let providerRef = CGDataProvider(data: Data(bytes: buffer, count: bytesPerRow * height) as CFData) {
            return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        } else {
            return nil
        }
    }
    
    public func copy(to buffer: UnsafeMutableRawPointer, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) {
        let imageWidth = self.width
        let imageHeight = self.height
        if let context = CGContext(data: buffer, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) {
            context.draw(self, in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight)))
        }
    }
}

extension CGImage {
    
    public static func create(width: Int, height: Int, command: (CGContext) -> ()) -> CGImage? {
        
        let byteOrder = 42.bigEndian == 42 ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
        let bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        return create(width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: bitmapInfo, command: command)
    }
    
    public static func create(width: Int, height: Int, space: ColorSpace<RGBColorModel>, command: (CGContext) -> ()) -> CGImage? {
        
        let byteOrder = 42.bigEndian == 42 ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
        let bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        
        guard let cgColorSpace = space.cgColorSpace else { return nil }
        
        return create(width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cgColorSpace, bitmapInfo: bitmapInfo, command: command)
    }
}

fileprivate let ImageCacheCGImageKey = "ImageCacheCGImageKey"

extension Image {
    
    public var cgImage: CGImage? {
        
        return self.cache[ImageCacheCGImageKey] {
            
            let width = self.width
            let height = self.height
            
            let bitsPerComponent: Int
            let bitmapInfo: UInt32
            
            switch self {
                
            case is Image<Gray16ColorPixel>:
                
                bitsPerComponent = 8
                
                let byteOrder = CGBitmapInfo.byteOrder16Big
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
                
            case is Image<Gray32ColorPixel>:
                
                bitsPerComponent = 16
                
                let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
                
            case is Image<ARGB32ColorPixel>:
                
                bitsPerComponent = 8
                
                let byteOrder = CGBitmapInfo.byteOrder32Big
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.first.rawValue
                
            case is Image<RGBA32ColorPixel>:
                
                bitsPerComponent = 8
                
                let byteOrder = CGBitmapInfo.byteOrder32Big
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
                
            case is Image<ARGB64ColorPixel>:
                
                bitsPerComponent = 16
                
                let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.first.rawValue
                
            case is Image<RGBA64ColorPixel>:
                
                bitsPerComponent = 16
                
                let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
                bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
                
            case is Image<FloatColorPixel<Pixel.Model>>:
                
                bitsPerComponent = 32
                
                let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
                bitmapInfo = byteOrder.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageAlphaInfo.last.rawValue
                
            default: return Image<FloatColorPixel<Pixel.Model>>(self).cgImage
            }
            
            guard let colorSpace = self.colorSpace.cgColorSpace else { return nil }
            guard let providerRef = CGDataProvider(data: self.pixels.data as CFData) else { return nil }
            
            let bytesPerPixel = MemoryLayout<Pixel>.stride
            let bitsPerPixel = bytesPerPixel << 3
            let bytesPerRow = bytesPerPixel * width
            
            return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        }
    }
}

protocol CGImageConvertibleProtocol {
    
    var cgImage: CGImage? { get }
}

extension Image : CGImageConvertibleProtocol {
    
}

extension AnyImage {
    
    public init?(cgImage: CGImage, option: MappedBufferOption = .default) {
        
        guard let colorSpace = cgImage.colorSpace.flatMap(AnyColorSpace.init) else { return nil }
        
        guard let data = cgImage.dataProvider?.data as Data? else { return nil }
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bitsPerPixel = cgImage.bitsPerPixel
        
        let byteOrder = cgImage.bitmapInfo.intersection(.byteOrderMask)
        let channel_endian: RawBitmap.Endianness
        let pixel_endian: RawBitmap.Endianness
        
        switch (bitsPerComponent, byteOrder) {
        case (16, .byteOrder16Little), (32, .byteOrder32Little): channel_endian = .little
        default: channel_endian = .big
        }
        switch (bitsPerPixel, byteOrder) {
        case (16, .byteOrder16Little), (32, .byteOrder32Little): pixel_endian = .little
        default: pixel_endian = .big
        }
        
        let alphaInfo = cgImage.alphaInfo
        let premultiplied = alphaInfo == .premultipliedLast || alphaInfo == .premultipliedFirst
        
        let floatInfo = cgImage.bitmapInfo.intersection(.floatInfoMask)
        let channelFormat: RawBitmap.Format = floatInfo == .floatComponents ? .float : .unsigned
        var channels = [RawBitmap.Channel]()
        
        switch cgImage.alphaInfo {
        case .premultipliedLast, .last:
            
            var start = 0
            for index in 0...colorSpace.numberOfComponents {
                let end = start + bitsPerComponent
                channels.append(RawBitmap.Channel(index: index, format: channelFormat, endianness: channel_endian, bitRange: start..<end))
                start = end
                guard end <= bitsPerPixel else { return nil }
            }
            
        case .premultipliedFirst, .first:
            
            channels = [RawBitmap.Channel(index: colorSpace.numberOfComponents, format: channelFormat, endianness: channel_endian, bitRange: 0..<bitsPerComponent)]
            
            var start = bitsPerComponent
            for index in 0..<colorSpace.numberOfComponents {
                let end = start + bitsPerComponent
                channels.append(RawBitmap.Channel(index: index, format: channelFormat, endianness: channel_endian, bitRange: start..<end))
                start = end
                guard end <= bitsPerPixel else { return nil }
            }
            
        case .none, .noneSkipLast:
            
            var start = 0
            for index in 0..<colorSpace.numberOfComponents {
                let end = start + bitsPerComponent
                channels.append(RawBitmap.Channel(index: index, format: channelFormat, endianness: channel_endian, bitRange: start..<end))
                start = end
                guard end <= bitsPerPixel else { return nil }
            }
            
        case .noneSkipFirst:
            
            var start = bitsPerPixel - bitsPerComponent * colorSpace.numberOfComponents
            guard start >= 0 else { return nil }
            
            for index in 0..<colorSpace.numberOfComponents {
                let end = start + bitsPerComponent
                channels.append(RawBitmap.Channel(index: index, format: channelFormat, endianness: channel_endian, bitRange: start..<end))
                start = end
                guard end <= bitsPerPixel else { return nil }
            }
            
        default: return nil
        }
        
        let bitmap = RawBitmap(bitsPerPixel: bitsPerPixel, bitsPerRow: cgImage.bytesPerRow << 3, startsRow: 0, endianness: pixel_endian, channels: channels, data: data)
        
        self.init(width: cgImage.width, height: cgImage.height, colorSpace: colorSpace, bitmaps: [bitmap], premultiplied: premultiplied, option: option)
    }
    
    public var cgImage: CGImage? {
        if let base = _base as? CGImageConvertibleProtocol {
            return base.cgImage
        }
        return nil
    }
}

#endif

