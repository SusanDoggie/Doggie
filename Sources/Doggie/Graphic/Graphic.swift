//
//  SDGraphic.swift
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

extension CGPoint {
    
    public init(_ p: Point) {
        self.x = CGFloat(p.x)
        self.y = CGFloat(p.y)
    }
}

extension CGSize {
    
    public init(_ s: Size) {
        self.width = CGFloat(s.width)
        self.height = CGFloat(s.height)
    }
}

extension CGRect {
    
    public init(_ r: Rect) {
        self.origin = CGPoint(r.origin)
        self.size = CGSize(r.size)
    }
}

extension Point {
    
    public init(_ p: CGPoint) {
        self.x = Double(p.x)
        self.y = Double(p.y)
    }
    public init(x: CGFloat, y: CGFloat) {
        self.x = Double(x)
        self.y = Double(y)
    }
}

extension Size {
    
    public init(_ s: CGSize) {
        self.width = Double(s.width)
        self.height = Double(s.height)
    }
    public init(width: CGFloat, height: CGFloat) {
        self.width = Double(width)
        self.height = Double(height)
    }
}

extension Rect {
    
    public init(_ r: CGRect) {
        self.origin = Point(r.origin)
        self.size = Size(r.size)
    }
    public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        self.origin = Point(x: x, y: y)
        self.size = Size(width: width, height: height)
    }
}

#if os(macOS)
    
    public extension AffineTransform {
        
        init<T: SDTransformProtocol>(_ transform: T) {
            self.m11 = CGFloat(transform.a)
            self.m12 = CGFloat(transform.d)
            self.m21 = CGFloat(transform.b)
            self.m22 = CGFloat(transform.e)
            self.tX = CGFloat(transform.c)
            self.tY = CGFloat(transform.f)
        }
    }
    
    extension SDTransform {
        
        public init(_ m: AffineTransform) {
            self.a = Double(m.m11)
            self.b = Double(m.m21)
            self.c = Double(m.tX)
            self.d = Double(m.m12)
            self.e = Double(m.m22)
            self.f = Double(m.tY)
        }
    }
    
#endif

#if os(macOS)
    
    import AppKit
    
    public extension NSImage {
        
        public convenience init(cgImage image: CGImage) {
            self.init(cgImage: image, size: NSZeroSize)
        }
        
        @available(OSX 10.11, *)
        public convenience init(ciImage image: CoreImage.CIImage) {
            self.init(cgImage: CIContext(options: nil).createCGImage(image, from: image.extent)!)
        }
        
        public var cgImage: CGImage? {
            if let imageData = self.tiffRepresentation, let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
                return CGImageSourceCreateImageAtIndex(source, 0, nil)
            }
            return nil
        }
        public var ciImage: CIImage? {
            if let imageData = self.tiffRepresentation {
                return CoreImage.CIImage(data: imageData)
            }
            return nil
        }
    }
    
    public extension NSBezierPath {
        
        convenience init(_ shape: Shape) {
            self.init()
            var state = Shape.DrawableComputeState()
            for item in shape {
                item.drawPath(self, state: &state)
            }
            self.transform(using: AffineTransform(shape.transform))
        }
    }
    
    private extension Shape {
        
        struct DrawableComputeState {
            
            var start : Point = Point()
            var last : Point = Point()
        }
    }
    
    private extension Shape.Command {
        
        func drawPath(_ path: NSBezierPath, state: inout Shape.DrawableComputeState) {
            
            switch self {
            case let .move(point):
                path.move(to: NSPoint(x: point.x, y: point.y))
                state.start = point
                state.last = point
            case let .line(point):
                path.line(to: NSPoint(x: point.x, y: point.y))
                state.last = point
            case let .quad(p1, p2):
                path.curve(to: NSPoint(x: p2.x, y: p2.y),
                           controlPoint1: NSPoint(x: (p1.x - state.last.x) * 2 / 3 + state.last.x, y: (p1.y - state.last.y) * 2 / 3 + state.last.y),
                           controlPoint2: NSPoint(x: (p1.x - p2.x) * 2 / 3 + p2.x, y: (p1.y - p2.y) * 2 / 3 + p2.y))
                state.last = p2
            case let .cubic(p1, p2, p3):
                path.curve(to: NSPoint(x: p3.x, y: p3.y), controlPoint1: NSPoint(x: p1.x, y: p1.y), controlPoint2: NSPoint(x: p2.x, y: p2.y))
                state.last = p3
            case .close:
                path.close()
                state.last = state.start
            }
        }
    }
    
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
    
    import UIKit
    
    public extension UIBezierPath {
        
        convenience init(_ shape: Shape) {
            self.init(cgPath: shape.cgPath)
        }
    }
    
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    import CoreGraphics
    
    extension CGAffineTransform {
        
        public init<T: SDTransformProtocol>(_ m: T) {
            self.a = CGFloat(m.a)
            self.b = CGFloat(m.d)
            self.c = CGFloat(m.b)
            self.d = CGFloat(m.e)
            self.tx = CGFloat(m.c)
            self.ty = CGFloat(m.f)
        }
    }
    
    extension SDTransform {
        
        public init(_ m: CGAffineTransform) {
            self.a = Double(m.a)
            self.b = Double(m.c)
            self.c = Double(m.tx)
            self.d = Double(m.b)
            self.e = Double(m.d)
            self.f = Double(m.ty)
        }
    }
    
    private let ShapeCacheCGPathKey = "ShapeCacheCGPathKey"
    
    extension Shape {
        
        public var cgPath : CGPath {
            if let path = self.identity.cacheTable[ShapeCacheCGPathKey].map({ $0 as! CGPath }) {
                return path
            } else {
                let _path: CGPath
                if let path = self.cacheTable[ShapeCacheCGPathKey].map({ $0 as! CGPath }) {
                    _path = path
                } else {
                    let path = CGMutablePath()
                    self.apply { component, state in
                        switch component {
                        case let .move(point): path.move(to: CGPoint(point))
                        case let .line(point): path.addLine(to: CGPoint(point))
                        case let .quad(p1, p2): path.addQuadCurve(to: CGPoint(p2), control: CGPoint(p1))
                        case let .cubic(p1, p2, p3): path.addCurve(to: CGPoint(p3), control1: CGPoint(p1), control2: CGPoint(p2))
                        case .close: path.closeSubpath()
                        }
                    }
                    self.cacheTable[ShapeCacheCGPathKey] = path
                    _path = path
                }
                var _transform = CGAffineTransform(transform)
                let path = _path.copy(using: &_transform) ?? _path
                self.identity.cacheTable[ShapeCacheCGPathKey] = path
                return path
            }
        }
    }
    
    extension Shape {
        
        public init(_ path: CGPath) {
            self.init()
            path.apply(info: &self) { buf, element in
                let path = buf!.assumingMemoryBound(to: Shape.self)
                let points = element.pointee.points
                switch element.pointee.type {
                case .moveToPoint: path.pointee.append(.move(Point(points[0])))
                case .addLineToPoint: path.pointee.append(.line(Point(points[0])))
                case .addQuadCurveToPoint: path.pointee.append(.quad(Point(points[0]), Point(points[1])))
                case .addCurveToPoint: path.pointee.append(.cubic(Point(points[0]), Point(points[1]), Point(points[2])))
                case .closeSubpath: path.pointee.append(.close)
                }
            }
            self.cacheTable[ShapeCacheCGPathKey] = path.copy()
        }
    }
    
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    
    public extension CGImage {
        
        static func create(_ buffer: UnsafeRawPointer, width: Int, height: Int, bitsPerComponent: Int, bitsPerPixel: Int, bytesPerRow: Int, space: CGColorSpace, bitmapInfo: UInt32) -> CGImage? {
            
            if let providerRef = CGDataProvider(data: Data(bytes: buffer, count: bytesPerRow * height) as CFData) {
                return CGImage(width: width, height: height, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGBitmapInfo(rawValue: bitmapInfo), provider: providerRef, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
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
    
    private final class CGPatternCallbackContainer {
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
    
    public func CGContextClipToDrawing(_ context : CGContext, command: (CGContext) -> Void) {
        
        let width = context.width
        let height = context.height
        
        if let maskContext = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: width, space: CGColorSpaceCreateDeviceGray(), bitmapInfo: 0) {
            maskContext.setFillColor(gray: 0, alpha: 1)
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

#endif
