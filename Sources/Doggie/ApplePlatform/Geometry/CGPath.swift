//
//  CGPath.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

private let ShapeCacheCGPathKey = "ShapeCacheCGPathKey"

private protocol BezierPathConvertible {
    
    var _currentPoint: Point { get }
    
    mutating func _move(to p1: Point)
    
    mutating func _line(to p1: Point)
    
    mutating func _quad(to p2: Point, control p1: Point)
    
    mutating func _curve(to p3: Point, control1 p1: Point, control2 p2: Point)
    
    mutating func _close()
    
    func _copy<Other: BezierPathConvertible>(to path: inout Other)
}

extension BezierPathConvertible {
    
    mutating func _quad(to p2: Point, control p1: Point) {
        let cubic = QuadBezier(self._currentPoint, p1, p2).elevated()
        self._curve(to: cubic.p3, control1: cubic.p1, control2: cubic.p2)
    }
}

extension Shape: BezierPathConvertible {
    
    fileprivate var _currentPoint: Point {
        return self.currentPoint
    }
    
    fileprivate mutating func _move(to p1: Point) {
        self.move(to: p1)
    }
    
    fileprivate mutating func _line(to p1: Point) {
        self.line(to: p1)
    }
    
    fileprivate mutating func _quad(to p2: Point, control p1: Point) {
        self.quad(to: p2, control: p1)
    }
    
    fileprivate mutating func _curve(to p3: Point, control1 p1: Point, control2 p2: Point) {
        self.curve(to: p3, control1: p1, control2: p2)
    }
    
    fileprivate mutating func _close() {
        self.close()
    }
    
    fileprivate func _copy<Other: BezierPathConvertible>(to path: inout Other) {
        
        for item in self {
            path._move(to: item.start)
            for segment in item {
                switch segment {
                case let .line(point): path._line(to: point)
                case let .quad(p1, p2): path._quad(to: p2, control: p1)
                case let .cubic(p1, p2, p3): path._curve(to: p3, control1: p1, control2: p2)
                }
            }
            if item.isClosed {
                path._close()
            }
        }
    }
}

extension CGMutablePath: BezierPathConvertible {
    
    fileprivate var _currentPoint: Point {
        return Point(currentPoint)
    }
    
    fileprivate func _move(to p1: Point) {
        self.move(to: CGPoint(p1))
    }
    
    fileprivate func _line(to p1: Point) {
        self.addLine(to: CGPoint(p1))
    }
    
    fileprivate func _quad(to p2: Point, control p1: Point) {
        self.addQuadCurve(to: CGPoint(p2), control: CGPoint(p1))
    }
    
    fileprivate func _curve(to p3: Point, control1 p1: Point, control2 p2: Point) {
        self.addCurve(to: CGPoint(p3), control1: CGPoint(p1), control2: CGPoint(p2))
    }
    
    fileprivate func _close() {
        self.closeSubpath()
    }
}

extension CGPath {
    
    fileprivate func _copy<Other: BezierPathConvertible>(to path: inout Other) {
        
        if #available(macOS 10.13, iOS 11.0, tvOS 11.0, watchOS 4.0, *) {
            
            var _path = path
            
            self.applyWithBlock { element in
                
                let points = element.pointee.points
                
                switch element.pointee.type {
                case .moveToPoint: _path._move(to: Point(points[0]))
                case .addLineToPoint: _path._line(to: Point(points[0]))
                case .addQuadCurveToPoint: _path._quad(to: Point(points[1]), control: Point(points[0]))
                case .addCurveToPoint: _path._curve(to: Point(points[2]), control1: Point(points[0]), control2: Point(points[1]))
                case .closeSubpath: _path._close()
                @unknown default: break
                }
            }
            
            path = _path
            
        } else {
            
            var _path: BezierPathConvertible = path
            
            self.apply(info: &_path) { info, element in
                
                let path = info!.assumingMemoryBound(to: BezierPathConvertible.self)
                let points = element.pointee.points
                
                switch element.pointee.type {
                case .moveToPoint: path.pointee._move(to: Point(points[0]))
                case .addLineToPoint: path.pointee._line(to: Point(points[0]))
                case .addQuadCurveToPoint: path.pointee._quad(to: Point(points[1]), control: Point(points[0]))
                case .addCurveToPoint: path.pointee._curve(to: Point(points[2]), control1: Point(points[0]), control2: Point(points[1]))
                case .closeSubpath: path.pointee._close()
                @unknown default: break
                }
            }
            
            path = _path as! Other
        }
    }
}

extension Shape {
    
    public var cgPath : CGPath {
        
        return self.identity.cache.load(for: ShapeCacheCGPathKey) {
            
            let _path: CGPath = self.cache.load(for: ShapeCacheCGPathKey) {
                var path = CGMutablePath()
                self._copy(to: &path)
                return path
            }
            
            var _transform = CGAffineTransform(self.transform)
            return _path.copy(using: &_transform) ?? _path
        }
    }
}

extension Shape {
    
    public init(_ path: CGPath) {
        self.init()
        path._copy(to: &self)
        self.cache.store(value: path.copy(), for: ShapeCacheCGPathKey)
    }
}

#endif

#if canImport(UIKit)

extension UIBezierPath {
    
    public convenience init(_ shape: Shape) {
        self.init(cgPath: shape.cgPath)
    }
}

extension Shape {
    
    public init(_ path: UIBezierPath) {
        self.init(path.cgPath)
    }
}

#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

extension NSBezierPath: BezierPathConvertible {
    
    fileprivate var _currentPoint: Point {
        return Point(currentPoint)
    }
    
    fileprivate func _move(to p1: Point) {
        self.move(to: CGPoint(p1))
    }
    
    fileprivate func _line(to p1: Point) {
        self.line(to: CGPoint(p1))
    }
    
    fileprivate func _curve(to p3: Point, control1 p1: Point, control2 p2: Point) {
        self.curve(to: CGPoint(p3), controlPoint1: CGPoint(p1), controlPoint2: CGPoint(p2))
    }
    
    fileprivate func _close() {
        self.close()
    }
    
    fileprivate func _copy<Other: BezierPathConvertible>(to path: inout Other) {
        
        var points = [CGPoint](repeating: CGPoint(), count: 3)
        for i in 0..<self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            switch type {
            case .moveTo: path._move(to: Point(points[0]))
            case .lineTo: path._line(to: Point(points[0]))
            case .curveTo: path._curve(to: Point(points[2]), control1: Point(points[0]), control2: Point(points[1]))
            case .closePath: path._close()
            @unknown default: break
            }
        }
    }
}

extension NSBezierPath {
    
    public var cgPath: CGPath {
        var path = CGMutablePath()
        self._copy(to: &path)
        return path
    }
}

extension NSBezierPath {
    
    public convenience init(cgPath: CGPath) {
        self.init()
        var path = self
        cgPath._copy(to: &path)
    }
}

extension NSBezierPath {
    
    public convenience init(_ shape: Shape) {
        self.init()
        var path = self
        shape._copy(to: &path)
        path.transform(using: AffineTransform(shape.transform))
    }
}

extension Shape {
    
    public init(_ path: NSBezierPath) {
        self.init()
        path._copy(to: &self)
    }
}

#endif

