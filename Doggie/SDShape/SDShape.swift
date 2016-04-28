//
//  SDShape.swift
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

public protocol SDShape {
    
    var boundary : Rect { get }
    var frame : [Point] { get }
    var baseTransform : SDTransform { get set }
    var transform : SDTransform { get set }
    
    var path: SDPath { get }
    
    var center : Point { get set }
    var rotate: Double { get set }
    var xScale: Double { get set }
    var yScale: Double { get set }
}

public extension SDShape {
    
    @_transparent
    var transform : SDTransform {
        get {
            return baseTransform * SDTransform.Scale(x: xScale, y: yScale) * SDTransform.Rotate(rotate)
        }
        set {
            baseTransform = newValue * SDTransform.Rotate(rotate).inverse * SDTransform.Scale(x: xScale, y: yScale).inverse
        }
    }
    
    @_transparent
    mutating func setScale(scale: Double) {
        self.xScale = scale
        self.yScale = scale
    }
}
