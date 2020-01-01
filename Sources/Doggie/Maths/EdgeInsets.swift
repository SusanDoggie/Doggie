//
//  EdgeInsets.swift
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

@frozen
public struct EdgeInsets: Hashable {
    
    public var top: Double
    
    public var left: Double
    
    public var right: Double
    
    public var bottom: Double
    
    @inlinable
    @inline(__always)
    public init(top: Double = 0, left: Double = 0, right: Double = 0, bottom: Double = 0) {
        self.top = top
        self.left = left
        self.right = right
        self.bottom = bottom
    }
}

extension Rect {
    
    @inlinable
    @inline(__always)
    public func inset(by insets: EdgeInsets) -> Rect {
        let rect = self.standardized
        return Rect(x: rect.x + insets.left,
                    y: rect.y + insets.top,
                    width: rect.width - insets.left - insets.right,
                    height: rect.height - insets.top - insets.bottom)
    }
}
