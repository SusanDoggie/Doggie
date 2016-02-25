//
//  SDRectangle.swift
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

public struct SDRectangle : SDShape {
    
    private var _transform : SDTransform = SDTransform(SDTransform.Identity())
    public var rotate: Double = 0
    public var xScale: Double = 1
    public var yScale: Double = 1
    
    public var transform : SDTransform {
        get {
            return SDTransform.Rotate(rotate) * SDTransform.Scale(x: xScale, y: yScale) * _transform
        }
        set {
            _transform = SDTransform.Scale(x: xScale, y: yScale).inverse * SDTransform.Rotate(rotate).inverse * newValue
        }
    }
    
    public var boundary : Rect {
        return rect
    }
    
    public var points : [Point] {
        return rect.points.map { self.transform * $0 }
    }
    
    public var frame : Rect {
        return Rect.bound(points)
    }
    
    private var rect : Rect
    
    public init(x: Double, y: Double, width: Double, height: Double) {
        rect = Rect(x: x, y: y, width: width, height: height)
    }
    
    public init(_ rect : Rect) {
        self.rect = rect
    }
    
    public var center : Point {
        get {
            return transform * rect.center
        }
        set {
            rect.center = transform.inverse * newValue
        }
    }
    
    public var x : Double {
        get {
            return rect.x
        }
        set {
            rect.x = newValue
        }
    }
    
    public var y : Double {
        get {
            return rect.y
        }
        set {
            rect.y = newValue
        }
    }
    
    public var width : Double {
        get {
            return rect.width
        }
        set {
            rect.width = newValue
        }
    }
    
    public var height : Double {
        get {
            return rect.height
        }
        set {
            rect.height = newValue
        }
    }
    
    public var path: SDPath {
        let points = self.points
        var path: SDPath = [SDPath.Move(points[0]), SDPath.Line(points[1]), SDPath.Line(points[2]), SDPath.Line(points[3]), SDPath.ClosePath()]
        path.rotate = self.rotate
        path.xScale = self.xScale
        path.yScale = self.yScale
        path.transform = self.transform
        return path
    }
    
}
