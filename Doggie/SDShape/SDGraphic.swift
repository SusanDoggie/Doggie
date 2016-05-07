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
import CoreGraphics

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

extension CGAffineTransform {
    
    public init<T: SDTransformType>(_ m: T) {
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
        return CGPathCreateWithRect(CGRect(Rect(x: x, y: y, width: width, height: height)), &_transform)
    }
}

extension SDEllipse {
    
    public var CGPath : CoreGraphics.CGPath {
        var _transform = CGAffineTransform(transform)
        return CGPathCreateWithEllipseInRect(CGRect(Rect(x: x - rx, y: y - ry, width: 2 * rx, height: 2 * ry)), &_transform)
    }
}

extension SDPath {
    
    public var CGPath : CoreGraphics.CGPath {
        let path = CGPathCreateMutable()
        self._apply { component, state in
            switch component {
            case let .move(point): CGPathMoveToPoint(path, nil, CGFloat(point.x), CGFloat(point.y))
            case let .line(point): CGPathAddLineToPoint(path, nil, CGFloat(point.x), CGFloat(point.y))
            case let .quad(p1, p2): CGPathAddQuadCurveToPoint(path, nil, CGFloat(p1.x), CGFloat(p1.y), CGFloat(p2.x), CGFloat(p2.y))
            case let .cubic(p1, p2, p3): CGPathAddCurveToPoint(path, nil, CGFloat(p1.x), CGFloat(p1.y), CGFloat(p2.x), CGFloat(p2.y), CGFloat(p3.x), CGFloat(p3.y))
            case .close: CGPathCloseSubpath(path)
            }
        }
        var _transform = CGAffineTransform(transform)
        return CGPathCreateCopyByTransformingPath(path, &_transform) ?? path
    }
}

extension SDPath {
    
    public init(_ path: CoreGraphics.CGPath) {
        self.init()
        CGPathApply(path, &self) { buf, element in
            let path = UnsafeMutablePointer<SDPath>(buf)
            let points = element.memory.points
            switch element.memory.type {
            case .MoveToPoint: path.memory.appendCommand(SDPath.Move(Point(points[0])))
            case .AddLineToPoint: path.memory.appendCommand(SDPath.Line(Point(points[0])))
            case .AddQuadCurveToPoint: path.memory.appendCommand(SDPath.QuadBezier(Point(points[0]), Point(points[1])))
            case .AddCurveToPoint: path.memory.appendCommand(SDPath.CubicBezier(Point(points[0]), Point(points[1]), Point(points[2])))
            case .CloseSubpath: path.memory.appendCommand(SDPath.ClosePath())
            }
        }
    }
}
