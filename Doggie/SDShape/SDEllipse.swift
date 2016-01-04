//
//  SDEllipse.swift
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

public struct SDEllipse : SDShape {
    
    public var transform : SDTransform
    
    public var x: Double
    public var y: Double
    
    public var rx: Double
    public var ry: Double
    
    public var position: Point {
        get {
            return Point(x: x, y: y)
        }
        set {
            self.x = newValue.x
            self.y = newValue.y
        }
    }
    public var radius: Radius {
        get {
            return Radius(x: rx, y: ry)
        }
        set {
            self.rx = newValue.x
            self.ry = newValue.y
        }
    }
    
    public var boundary : Rect {
        return Rect(x: x - rx, y: y - ry, width: 2 * rx, height: 2 * ry)
    }
    
    public var frame : Rect {
        return EllipseBound(position, radius, transform)
    }
    
    public init(center: Point, radius: Double) {
        transform = SDTransform(SDTransform.Identity())
        self.x = center.x
        self.y = center.y
        self.rx = radius
        self.ry = radius
    }
    
    public init(x: Double, y: Double, radius: Double) {
        transform = SDTransform(SDTransform.Identity())
        self.x = x
        self.y = y
        self.rx = radius
        self.ry = radius
    }
    
    public init(center: Point, radius: Radius) {
        transform = SDTransform(SDTransform.Identity())
        self.x = center.x
        self.y = center.y
        self.rx = radius.x
        self.ry = radius.y
    }
    
    public init(x: Double, y: Double, rx: Double, ry: Double) {
        transform = SDTransform(SDTransform.Identity())
        self.x = x
        self.y = y
        self.rx = rx
        self.ry = ry
    }
    
    public init(inRect: Rect) {
        transform = SDTransform(SDTransform.Identity())
        let center = inRect.center
        self.x = center.x
        self.y = center.y
        self.rx = inRect.width * 0.5
        self.ry = inRect.height * 0.5
    }
    
    public var center : Point {
        get {
            return transform * position
        }
        set {
            position = transform.inverse * newValue
        }
    }
    
    public var width : Double {
        get {
            return 2 * rx
        }
        set {
            rx = newValue * 0.5
        }
    }
    
    public var height : Double {
        get {
            return 2 * ry
        }
        set {
            ry = newValue * 0.5
        }
    }
}
