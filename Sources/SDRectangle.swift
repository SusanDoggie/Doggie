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

public struct SDRectangle : SDShape {
    
    public var baseTransform : SDTransform = SDTransform(SDTransform.Identity())
    
    public var rotate: Double = 0 {
        didSet {
            center = rect.center * baseTransform * SDTransform.Scale(scale) * SDTransform.Rotate(oldValue)
        }
    }
    public var scale: Double = 1 {
        didSet {
            center = rect.center * baseTransform * SDTransform.Scale(oldValue) * SDTransform.Rotate(rotate)
        }
    }
    
    public var originalBoundary : Rect {
        return rect
    }
    public var boundary : Rect {
        return Rect.bound(points)
    }
    
    public var points : [Point] {
        return frame
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
            return rect.center * transform
        }
        set {
            rect.center = newValue * transform.inverse
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
        let points = self.rect.points
        var path: SDPath = [.move(points[0]), .line(points[1]), .line(points[2]), .line(points[3]), .close]
        path.rotate = self.rotate
        path.scale = self.scale
        path.baseTransform = self.baseTransform
        return path
    }
}
