//
//  CGImage.swift
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

#if canImport(CoreGraphics)

extension CGImage {
    
    public func fileBacked() -> CGImage? {
        
        guard let colorSpace = self.colorSpace else { return nil }
        guard let cfdata = self.dataProvider?.data else { return nil }
        
        var buffer = MappedBuffer<UInt8>(repeating: 0, count: CFDataGetLength(cfdata), fileBacked: true)
        buffer.withUnsafeMutableBufferPointer { CFDataGetBytes(cfdata, CFRange(location: 0, length: $0.count), $0.baseAddress) }
        
        guard let providerRef = CGDataProvider(data: buffer.data as CFData) else { return nil }
        
        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, provider: providerRef, decode: nil, shouldInterpolate: shouldInterpolate, intent: renderingIntent)
    }
}

extension CGImage {
    
    public static func create(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32, command: (CGContext) -> ()) -> CGImage? {
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) else { return nil }
        command(context)
        return context.makeImage()
    }
    
    public static func create(_ buffer: UnsafeRawPointer, width: Int, height: Int, bitsPerComponent: Int, bitsPerPixel: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32, shouldInterpolate: Bool = true, intent: CGColorRenderingIntent = .defaultIntent) -> CGImage? {
        guard let providerRef = CGDataProvider(data: Data(bytes: buffer, count: bytesPerRow * height) as CFData) else { return nil }
        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: shouldInterpolate, intent: intent)
    }
    
    public func copy(to buffer: UnsafeMutableRawPointer, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) {
        guard let context = CGContext(data: buffer, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) else { return }
        context.draw(self, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
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

private struct CGImageData {
    
    let width: Int
    let height: Int
    
    let bytesPerPixel: Int
    let bitsPerComponent: Int
    let bitmapInfo: UInt32
    
    let pixels: Data
    
    init<RawPixel : ColorPixelProtocol>(width: Int, height: Int, pixels: MappedBuffer<RawPixel>) {
        
        self.width = width
        self.height = height
        
        switch pixels {
            
        case is MappedBuffer<Gray16ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 8
            
            let byteOrder = CGBitmapInfo.byteOrder16Big
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<Gray32ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 16
            
            let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<ARGB32ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 8
            
            let byteOrder = CGBitmapInfo.byteOrder32Big
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.first.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<RGBA32ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 8
            
            let byteOrder = CGBitmapInfo.byteOrder32Big
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<BGRA32ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 8
            
            let byteOrder = CGBitmapInfo.byteOrder32Little
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.first.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<ARGB64ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 16
            
            let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.first.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<RGBA64ColorPixel>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 16
            
            let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder16Big : CGBitmapInfo.byteOrder16Little
            self.bitmapInfo = byteOrder.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.data
            
        case is MappedBuffer<Float32ColorPixel<RawPixel.Model>>:
            
            self.bytesPerPixel = MemoryLayout<RawPixel>.stride
            self.bitsPerComponent = 32
            
            let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
            self.bitmapInfo = byteOrder.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.data
            
        default:
            
            self.bytesPerPixel = MemoryLayout<Float32ColorPixel<RawPixel.Model>>.stride
            self.bitsPerComponent = 32
            
            let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
            self.bitmapInfo = byteOrder.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageAlphaInfo.last.rawValue
            
            self.pixels = pixels.map(Float32ColorPixel<RawPixel.Model>.init).data
        }
    }
    
    func cgImage(colorSpace: CGColorSpace) -> CGImage? {
        guard let providerRef = CGDataProvider(data: self.pixels as CFData) else { return nil }
        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bytesPerPixel << 3, bytesPerRow: bytesPerPixel * width, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
    }
}

private let ImageCacheCGImageKey = "ImageCacheCGImageKey"

extension Image {
    
    public var cgImage: CGImage? {
        
        return self.cache.load(for: ImageCacheCGImageKey) {
            guard let colorSpace = self.colorSpace.cgColorSpace else { return nil }
            let data = CGImageData(width: width, height: height, pixels: pixels)
            return data.cgImage(colorSpace: colorSpace)
        }
    }
}

extension Texture where RawPixel.Model == GrayColorModel {
    
    public var cgImage: CGImage? {
        let data = CGImageData(width: width, height: height, pixels: pixels)
        return data.cgImage(colorSpace: CGColorSpaceCreateDeviceGray())
    }
}

extension Texture where RawPixel.Model == RGBColorModel {
    
    public var cgImage: CGImage? {
        let data = CGImageData(width: width, height: height, pixels: pixels)
        return data.cgImage(colorSpace: CGColorSpaceCreateDeviceRGB())
    }
}

extension Texture where RawPixel.Model == CMYKColorModel {
    
    public var cgImage: CGImage? {
        let data = CGImageData(width: width, height: height, pixels: pixels)
        return data.cgImage(colorSpace: CGColorSpaceCreateDeviceCMYK())
    }
}

protocol CGImageConvertibleProtocol {
    
    var cgImage: CGImage? { get }
}

extension Image : CGImageConvertibleProtocol {
    
}

extension AnyImage {
    
    public init?(cgImage: CGImage, fileBacked: Bool = false) {
        
        guard let colorSpace = cgImage.colorSpace.flatMap(AnyColorSpace.init) else { return nil }
        
        guard let data = cgImage.dataProvider?.data as Data? else { return nil }
        
        let bitsPerComponent = cgImage.bitsPerComponent
        let bitsPerPixel = cgImage.bitsPerPixel
        
        let byteOrder = cgImage.bitmapInfo.intersection(.byteOrderMask)
        let channel_endian: RawBitmap.Endianness
        let pixel_endian: RawBitmap.Endianness
        
        if bitsPerComponent == bitsPerPixel {
            pixel_endian = .big
            switch (bitsPerComponent, byteOrder) {
            case (16, .byteOrder16Little), (32, .byteOrder32Little): channel_endian = .little
            default: channel_endian = .big
            }
        } else {
            switch (bitsPerComponent, byteOrder) {
            case (16, .byteOrder16Little), (32, .byteOrder32Little): channel_endian = .little
            default: channel_endian = .big
            }
            switch (bitsPerPixel, byteOrder) {
            case (16, .byteOrder16Little), (32, .byteOrder32Little): pixel_endian = .little
            default: pixel_endian = .big
            }
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
        
        let bitmap = RawBitmap(bitsPerPixel: bitsPerPixel, bytesPerRow: cgImage.bytesPerRow, endianness: pixel_endian, channels: channels, data: data)
        self.init(width: cgImage.width, height: cgImage.height, colorSpace: colorSpace, bitmaps: [bitmap], premultiplied: premultiplied, fileBacked: fileBacked)
    }
    
    public var cgImage: CGImage? {
        if let base = _base as? CGImageConvertibleProtocol {
            return base.cgImage
        }
        return nil
    }
}

#endif

