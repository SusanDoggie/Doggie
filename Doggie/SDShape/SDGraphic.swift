//
//  SDGraphic.swift
//
//  The MIT License
//  Copyright (c) 2015 Susan Cheng. All rights reserved.
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
        return CGPathCreateWithRect(CGRect(boundary), &_transform)
    }
}

extension SDEllipse {
    
    public var CGPath : CoreGraphics.CGPath {
        var _transform = CGAffineTransform(transform)
        return CGPathCreateWithEllipseInRect(CGRect(boundary), &_transform)
    }
}

extension SDPath {
    
    public var CGPath : CoreGraphics.CGPath {
        let path = CGPathCreateMutable()
        self.apply { component, state in
            switch component {
            case let move as SDPath.Move:
                
                CGPathMoveToPoint(path, nil, CGFloat(move.x), CGFloat(move.y))
                
            case let line as SDPath.Line:
                
                CGPathAddLineToPoint(path, nil, CGFloat(line.x), CGFloat(line.y))
                
            case let quad as SDPath.QuadBezier:
                
                CGPathAddQuadCurveToPoint(path, nil, CGFloat(state.firstControl!.x), CGFloat(state.firstControl!.y), CGFloat(quad.p2.x), CGFloat(quad.p2.y))
                
            case let cubic as SDPath.CubicBezier:
                
                CGPathAddCurveToPoint(path, nil, CGFloat(state.firstControl!.x), CGFloat(state.firstControl!.y), CGFloat(cubic.p2.x), CGFloat(cubic.p2.y), CGFloat(cubic.p3.x), CGFloat(cubic.p3.y))
                
            case let arc as SDPath.Arc:
                
                let (center, radius) = arc.details(state.last)
                
                let _transform = SDTransform.Rotate(arc.rotate) * SDTransform.Scale(x: radius.x, y: radius.y)
                let _transformInverse = _transform.inverse
                
                let _center = _transformInverse * center
                let _start = _transformInverse * (state.last - center)
                let _end = _transformInverse * (arc.point - center)
                
                var _arctransform = CGAffineTransform(_transform)
                CGPathAddArc(path, &_arctransform, CGFloat(_center.x), CGFloat(_center.y), 1.0, CGFloat(atan2(_start.y, _start.x)), CGFloat(atan2(_end.y, _end.x)), !arc.sweep)
                
            case _ as SDPath.ClosePath:
                
                CGPathCloseSubpath(path)
                
            default: break
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
            case .MoveToPoint: path.memory.append(SDPath.Move(Point(points[0])))
            case .AddLineToPoint: path.memory.append(SDPath.Line(Point(points[0])))
            case .AddQuadCurveToPoint: path.memory.append(SDPath.QuadBezier(Point(points[0]), Point(points[1])))
            case .AddCurveToPoint: path.memory.append(SDPath.CubicBezier(Point(points[0]), Point(points[1]), Point(points[2])))
            case .CloseSubpath: path.memory.append(SDPath.ClosePath())
            }
            
        }
    }
}
