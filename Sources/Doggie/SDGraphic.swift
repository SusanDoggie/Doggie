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
    
    public extension NSBezierPath {
        
        convenience init(_ shape: SDPath) {
            self.init()
            var state = SDPath.DrawableComputeState()
            for item in shape {
                item.drawPath(self, state: &state)
            }
            self.transform(using: AffineTransform(shape.transform))
        }
    }
    
    private extension SDPath {
        
        struct DrawableComputeState {
            
            var start : Point = Point()
            var last : Point = Point()
        }
    }
    
    private extension SDPath.Command {
        
        func drawPath(_ path: NSBezierPath, state: inout SDPath.DrawableComputeState) {
            
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
        
        convenience init(_ shape: SDPath) {
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
    
    extension SDRectangle {
        
        public var cgPath : CGPath {
            var _transform = CGAffineTransform(transform)
            return CoreGraphics.CGPath(rect: CGRect(Rect(x: x, y: y, width: width, height: height)), transform: &_transform)
        }
    }
    
    extension SDEllipse {
        
        public var cgPath : CGPath {
            var _transform = CGAffineTransform(transform)
            return CoreGraphics.CGPath(ellipseIn: CGRect(Rect(x: x - rx, y: y - ry, width: 2 * rx, height: 2 * ry)), transform: &_transform)
        }
    }
    
    private let SDPathCacheCGPathKey = "SDPathCacheCGPathKey"
    
    extension SDPath {
        
        public var cgPath : CGPath {
            if let path = self.getCache(name: SDPathCacheCGPathKey, type: .transformed).map({ $0 as! CGPath }) {
                return path
            } else {
                let _path: CGPath
                if let path = self.getCache(name: SDPathCacheCGPathKey, type: .regular).map({ $0 as! CGPath }) {
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
                    self.setCache(name: SDPathCacheCGPathKey, value: path, type: .regular)
                    _path = path
                }
                var _transform = CGAffineTransform(transform)
                let path = _path.copy(using: &_transform) ?? _path
                self.setCache(name: SDPathCacheCGPathKey, value: path, type: .transformed)
                return path
            }
        }
    }
    
    extension SDPath {
        
        public init(_ path: CGPath) {
            self.init()
            path.apply(info: &self) { buf, element in
                let path = buf!.assumingMemoryBound(to: SDPath.self)
                let points = element.pointee.points
                switch element.pointee.type {
                case .moveToPoint: path.pointee.append(.move(Point(points[0])))
                case .addLineToPoint: path.pointee.append(.line(Point(points[0])))
                case .addQuadCurveToPoint: path.pointee.append(.quad(Point(points[0]), Point(points[1])))
                case .addCurveToPoint: path.pointee.append(.cubic(Point(points[0]), Point(points[1]), Point(points[2])))
                case .closeSubpath: path.pointee.append(.close)
                }
            }
            self.setCache(name: SDPathCacheCGPathKey, value: path.copy()!, type: .regular)
        }
    }
    
#endif
