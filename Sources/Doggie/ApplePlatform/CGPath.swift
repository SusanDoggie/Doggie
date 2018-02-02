//
//  CGPath.swift
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
    
    fileprivate let ShapeCacheCGPathKey = "ShapeCacheCGPathKey"
    
    extension Shape {
        
        public var cgPath : CGPath {
            
            return self.identity.cache[ShapeCacheCGPathKey] {
                
                let _path: CGPath = self.cache[ShapeCacheCGPathKey] {
                    
                    let path = CGMutablePath()
                    for item in self {
                        path.move(to: CGPoint(item.start))
                        for segment in item {
                            switch segment {
                            case let .line(point): path.addLine(to: CGPoint(point))
                            case let .quad(p1, p2): path.addQuadCurve(to: CGPoint(p2), control: CGPoint(p1))
                            case let .cubic(p1, p2, p3): path.addCurve(to: CGPoint(p3), control1: CGPoint(p1), control2: CGPoint(p2))
                            }
                        }
                        if item.isClosed {
                            path.closeSubpath()
                        }
                    }
                    return path
                }
                
                var _transform = CGAffineTransform(transform)
                return _path.copy(using: &_transform) ?? _path
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
                case .moveToPoint: path.pointee.append(Component(start: Point(points[0]), closed: false, segments: []))
                case .addLineToPoint:
                    if path.pointee.count == 0 || path.pointee.last?.isClosed == true {
                        path.pointee.append(Component(start: path.pointee.last?.start ?? Point(), closed: false, segments: []))
                    }
                    path.pointee[path.pointee.count - 1].append(.line(Point(points[0])))
                case .addQuadCurveToPoint:
                    if path.pointee.count == 0 || path.pointee.last?.isClosed == true {
                        path.pointee.append(Component(start: path.pointee.last?.start ?? Point(), closed: false, segments: []))
                    }
                    path.pointee[path.pointee.count - 1].append(.quad(Point(points[0]), Point(points[1])))
                case .addCurveToPoint:
                    if path.pointee.count == 0 || path.pointee.last?.isClosed == true {
                        path.pointee.append(Component(start: path.pointee.last?.start ?? Point(), closed: false, segments: []))
                    }
                    path.pointee[path.pointee.count - 1].append(.cubic(Point(points[0]), Point(points[1]), Point(points[2])))
                case .closeSubpath:
                    if path.pointee.count == 0 || path.pointee.last?.isClosed == true {
                        path.pointee.append(Component(start: path.pointee.last?.start ?? Point(), closed: false, segments: []))
                    }
                    path.pointee[path.pointee.count - 1].isClosed = true
                }
            }
            self.cache[ShapeCacheCGPathKey] = path.copy()
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

#if os(macOS)
    
    import AppKit
    
    public extension NSBezierPath {
        
        convenience init(_ shape: Shape) {
            self.init()
            for item in shape {
                var last: Point = item.start
                self.move(to: NSPoint(item.start))
                for segment in item {
                    switch segment {
                    case let .line(point):
                        self.line(to: NSPoint(x: point.x, y: point.y))
                        last = point
                    case let .quad(p1, p2):
                        self.curve(to: NSPoint(x: p2.x, y: p2.y),
                                   controlPoint1: NSPoint(x: (p1.x - last.x) * 2 / 3 + last.x, y: (p1.y - last.y) * 2 / 3 + last.y),
                                   controlPoint2: NSPoint(x: (p1.x - p2.x) * 2 / 3 + p2.x, y: (p1.y - p2.y) * 2 / 3 + p2.y))
                        last = p2
                    case let .cubic(p1, p2, p3):
                        self.curve(to: NSPoint(x: p3.x, y: p3.y), controlPoint1: NSPoint(x: p1.x, y: p1.y), controlPoint2: NSPoint(x: p2.x, y: p2.y))
                        last = p3
                    }
                }
                if item.isClosed {
                    self.close()
                }
            }
            self.transform(using: AffineTransform(shape.transform))
        }
    }
    
    extension Shape {
        
        public init(_ path: NSBezierPath) {
            self.init()
            var points = [NSPoint](repeating: NSPoint(x: 0, y: 0), count: 3)
            for idx in 0..<path.elementCount {
                switch path.element(at: idx, associatedPoints: &points) {
                case .moveToBezierPathElement: self.append(Component(start: Point(points[0]), closed: false, segments: []))
                case .lineToBezierPathElement:
                    if self.count == 0 || self.last?.isClosed == true {
                        self.append(Component(start: self.last?.start ?? Point(), closed: false, segments: []))
                    }
                    self[self.count - 1].append(.quad(Point(points[0]), Point(points[1])))
                case .curveToBezierPathElement:
                    if self.count == 0 || self.last?.isClosed == true {
                        self.append(Component(start: self.last?.start ?? Point(), closed: false, segments: []))
                    }
                    self[self.count - 1].append(.cubic(Point(points[0]), Point(points[1]), Point(points[2])))
                case .closePathBezierPathElement:
                    if self.count == 0 || self.last?.isClosed == true {
                        self.append(Component(start: self.last?.start ?? Point(), closed: false, segments: []))
                    }
                    self[self.count - 1].isClosed = true
                }
            }
        }
    }
    
#endif

