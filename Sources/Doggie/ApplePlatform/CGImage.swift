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

#if canImport(CoreGraphics) && canImport(ImageIO)

import Foundation
import CoreGraphics
import ImageIO

#if canImport(MobileCoreServices)

import MobileCoreServices

#endif

public extension CGImage {
    
    static func create(width: Int, height: Int, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32, command: (CGContext) -> ()) -> CGImage? {
        
        if let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) {
            
            command(context)
            
            return context.makeImage()
            
        } else {
            return nil
        }
    }
    
    static func create(_ buffer: UnsafeRawPointer, width: Int, height: Int, bitsPerComponent: Int, bitsPerPixel: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) -> CGImage? {
        
        if let providerRef = CGDataProvider(data: Data(bytes: buffer, count: bytesPerRow * height) as CFData) {
            return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        } else {
            return nil
        }
    }
    
    func copy(to buffer: UnsafeMutableRawPointer, bitsPerComponent: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) {
        let imageWidth = self.width
        let imageHeight = self.height
        if let context = CGContext(data: buffer, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: bitmapInfo) {
            context.draw(self, in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight)))
        }
    }
}

fileprivate final class CGPatternCallbackContainer {
    static var CGPatternCallbackList = [UInt: CGPatternCallbackContainer]()
    
    let callback: (CGContext?) -> Void
    
    let callbacks_struct: UnsafeMutablePointer<CGPatternCallbacks>
    
    init(callback: @escaping (CGContext?) -> Void) {
        self.callback = callback
        self.callbacks_struct = UnsafeMutablePointer.allocate(capacity: 1)
        
        let id = UInt(bitPattern: ObjectIdentifier(self))
        CGPatternCallbackContainer.CGPatternCallbackList[id] = self
        
        self.callbacks_struct.initialize(to: CGPatternCallbacks(version: 0, drawPattern: {
            let id = unsafeBitCast($0, to: UInt.self)
            CGPatternCallbackContainer.CGPatternCallbackList[id]?.callback($1)
        }, releaseInfo: {
            let id = unsafeBitCast($0, to: UInt.self)
            CGPatternCallbackContainer.CGPatternCallbackList[id] = nil
        }))
    }
    
    deinit {
        self.callbacks_struct.deinitialize(count: 1)
        self.callbacks_struct.deallocate()
    }
}

public func CGPatternCreate(_ bounds: CGRect, _ matrix: CGAffineTransform, _ xStep: CGFloat, _ yStep: CGFloat, _ tiling: CGPatternTiling, _ isColored: Bool, _ callback: @escaping (CGContext?) -> Void) -> CGPattern? {
    let callbackContainer = CGPatternCallbackContainer(callback: callback)
    let id = UInt(bitPattern: ObjectIdentifier(callbackContainer))
    return CGPattern(info: UnsafeMutableRawPointer(bitPattern: id), bounds: bounds, matrix: matrix, xStep: xStep, yStep: yStep, tiling: tiling, isColored: isColored, callbacks: callbackContainer.callbacks_struct)
}

public func CGContextClipToDrawing(_ context : CGContext, fillBackground: CGFloat = 0, command: (CGContext) -> Void) {
    
    let width = context.width
    let height = context.height
    
    if let maskContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) {
        maskContext.setFillColor(gray: fillBackground, alpha: 1)
        maskContext.fill(CGRect(x: 0, y: 0, width: width, height: height))
        maskContext.setFillColor(gray: 1, alpha: 1)
        let transform = context.ctm
        maskContext.concatenate(transform)
        command(maskContext)
        let alphaMask = maskContext.makeImage()
        context.concatenate(transform.inverted())
        context.clip(to: CGRect(x: 0, y: 0, width: width, height: height), mask: alphaMask!)
        context.concatenate(transform)
    }
}

extension Image {
    
    @_inlineable
    public var cgImage: CGImage? {
        
        guard let colorSpace = self.colorSpace.cgColorSpace else { return nil }
        
        let _image = Image<FloatColorPixel<Pixel.Model>>(image: self)
        guard let providerRef = CGDataProvider(data: _image.pixels.data as CFData) else { return nil }
        
        let components = Pixel.numberOfComponents
        
        let bitsPerComponent = 32
        let bytesPerPixel = 4 * components
        let bitsPerPixel = 32 * components
        
        let bytesPerRow = bytesPerPixel * width
        
        let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
        
        let bitmapInfo = byteOrder.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageAlphaInfo.last.rawValue
        
        return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
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

