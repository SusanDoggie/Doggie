//
//  CIVector.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#if canImport(CoreImage)

extension CIVector {
    
    public convenience init<C: Collection>(_ values: C) where C.Element: BinaryFloatingPoint {
        self.init(values: values.map { CGFloat($0) }, count: values.count)
    }
    
    public convenience init<T: BinaryFloatingPoint>(_ values: T ...) {
        self.init(values)
    }
    
    public convenience init(_ point: Point) {
        self.init(cgPoint: CGPoint(point))
    }
    
    public convenience init(_ point: Vector) {
        self.init(point.x, point.y, point.z)
    }
    
    public convenience init(_ size: Size) {
        self.init(size.width, size.height)
    }
    
    public convenience init(_ rect: Rect) {
        self.init(cgRect: CGRect(rect))
    }
    
    public convenience init(_ transform: SDTransform) {
        self.init(cgAffineTransform: CGAffineTransform(transform))
    }
}

#endif
