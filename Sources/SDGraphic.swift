//
//  SDGraphic.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2016 Susan Cheng. All rights reserved.
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
        
        public var CGPath : CoreGraphics.CGPath {
            var _transform = CGAffineTransform(transform)
            return CoreGraphics.CGPath(rect: CGRect(Rect(x: x, y: y, width: width, height: height)), transform: &_transform)
        }
    }
    
    extension SDEllipse {
        
        public var CGPath : CoreGraphics.CGPath {
            var _transform = CGAffineTransform(transform)
            return CoreGraphics.CGPath(ellipseIn: CGRect(Rect(x: x - rx, y: y - ry, width: 2 * rx, height: 2 * ry)), transform: &_transform)
        }
    }
    
    private let SDPathCacheCGPathKey = "SDPathCacheCGPathKey"
    
    extension SDPath {
        
        public var CGPath : CoreGraphics.CGPath {
            if let path = self.getCache(name: SDPathCacheCGPathKey, type: .transformed).map({ $0 as! CoreGraphics.CGPath }) {
                return path
            } else {
                let _path: CoreGraphics.CGPath
                if let path = self.getCache(name: SDPathCacheCGPathKey, type: .regular).map({ $0 as! CoreGraphics.CGPath }) {
                    _path = path
                } else {
                    let path = CGMutablePath()
                    self._apply { component, state in
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
        
        public init(_ path: CoreGraphics.CGPath) {
            self.init()
            path.apply(info: &self) { buf, element in
                let path = buf!.assumingMemoryBound(to: SDPath.self)
                let points = element.pointee.points
                switch element.pointee.type {
                case .moveToPoint: path.pointee.appendCommand(SDPath.Move(Point(points[0])))
                case .addLineToPoint: path.pointee.appendCommand(SDPath.Line(Point(points[0])))
                case .addQuadCurveToPoint: path.pointee.appendCommand(SDPath.QuadBezier(Point(points[0]), Point(points[1])))
                case .addCurveToPoint: path.pointee.appendCommand(SDPath.CubicBezier(Point(points[0]), Point(points[1]), Point(points[2])))
                case .closeSubpath: path.pointee.appendCommand(SDPath.ClosePath())
                }
            }
            self.setCache(name: SDPathCacheCGPathKey, value: path.copy()!, type: .regular)
        }
    }
    
#endif
