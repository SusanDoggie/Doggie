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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    import Foundation
    import CoreGraphics
    import ImageIO
    
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
    
    import MobileCoreServices
    
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
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
            self.callbacks_struct.deinitialize()
            self.callbacks_struct.deallocate(capacity: 1)
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
            
            if let colorSpace = self.colorSpace.cgColorSpace {
                
                return Image<FloatColorPixel<Pixel.Model>>(image: self).withUnsafeBufferPointer {
                    
                    let components = Pixel.numberOfComponents
                    
                    let bitsPerComponent = 32
                    let bytesPerPixel = 4 * components
                    let bitsPerPixel = 32 * components
                    
                    let bytesPerRow = bytesPerPixel * width
                    
                    let byteOrder = bitsPerComponent.bigEndian == bitsPerComponent ? CGBitmapInfo.byteOrder32Big : CGBitmapInfo.byteOrder32Little
                    
                    let bitmapInfo = byteOrder.rawValue | CGBitmapInfo.floatComponents.rawValue | CGImageAlphaInfo.last.rawValue
                    
                    return CGImage.create($0.baseAddress!, width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
                }
            }
            
            return nil
        }
    }
    
    protocol CGImageConvertibleProtocol {
        
        var cgImage: CGImage? { get }
    }
    
    extension Image : CGImageConvertibleProtocol {
        
    }
    
    extension AnyImage {
        
        public init?(cgImage: CGImage, option: MappedBufferOption = .default) {
            
            let data = NSMutableData()
            
            guard let destination = CGImageDestinationCreateWithData(data, kUTTypeTIFF, 1, nil) else { return nil }
            
            CGImageDestinationAddImage(destination, cgImage, nil)
            
            guard CGImageDestinationFinalize(destination) else { return nil }
            
            try? self.init(data: data as Data, option: option)
        }
        
        public var cgImage: CGImage? {
            if let base = _base as? CGImageConvertibleProtocol {
                return base.cgImage
            }
            return nil
        }
    }
    
#endif

