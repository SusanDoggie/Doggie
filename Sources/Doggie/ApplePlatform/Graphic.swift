//
//  Graphic.swift
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

extension CGPoint {
    
    public init(_ p: Point) {
        self.init(x: CGFloat(p.x), y: CGFloat(p.y))
    }
}

extension CGSize {
    
    public init(_ s: Size) {
        self.init(width: CGFloat(s.width), height: CGFloat(s.height))
    }
}

extension CGRect {
    
    public init(_ r: Rect) {
        self.init(origin: CGPoint(r.origin), size: CGSize(r.size))
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

extension AffineTransform {
    
    public init(_ transform: SDTransform) {
        self.init(
            m11: CGFloat(transform.a),
            m12: CGFloat(transform.d),
            m21: CGFloat(transform.b),
            m22: CGFloat(transform.e),
            tX: CGFloat(transform.c),
            tY: CGFloat(transform.f)
        )
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

#if canImport(CoreGraphics)


extension CGAffineTransform {
    
    public init(_ m: SDTransform) {
        self.init(
            a: CGFloat(m.a),
            b: CGFloat(m.d),
            c: CGFloat(m.b),
            d: CGFloat(m.e),
            tx: CGFloat(m.c),
            ty: CGFloat(m.f)
        )
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

#endif

