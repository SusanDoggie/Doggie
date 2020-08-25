//
//  Pattern.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

@frozen
public struct Pattern {
    
    public var bound: Rect
    
    public var xStep: Double
    public var yStep: Double
    
    public var transform: SDTransform = .identity
    public var opacity: Double = 1
    
    public var callback: (DrawableContext) -> Void
    
    @inlinable
    @inline(__always)
    public init(bound: Rect, xStep: Double, yStep: Double, callback: @escaping (DrawableContext) -> Void) {
        self.bound = bound
        self.xStep = xStep
        self.yStep = yStep
        self.callback = callback
    }
}

extension Pattern {
    
    public var center: Point {
        get {
            return bound.center * transform
        }
        set {
            let offset = newValue - center
            transform *= SDTransform.translate(x: offset.x, y: offset.y)
        }
    }
}
