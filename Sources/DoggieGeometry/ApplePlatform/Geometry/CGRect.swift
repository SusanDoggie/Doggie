//
//  CGRect.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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

extension CGRect {
    
    @inlinable
    @inline(__always)
    public init(_ r: Rect) {
        if r.isNull {
            self = .null
        } else if r.isInfinite {
            self = .infinite
        } else {
            self.init(origin: CGPoint(r.origin), size: CGSize(r.size))
        }
    }
    
    @inlinable
    @inline(__always)
    public init(origin: Point, size: Size) {
        self.init(Rect(origin: origin, size: size))
    }
    
    @inlinable
    @inline(__always)
    public init<T: BinaryInteger>(x: T, y: T, width: T, height: T) {
        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(x: T, y: T, width: T, height: T) {
        self.init(x: CGFloat(x), y: CGFloat(y), width: CGFloat(width), height: CGFloat(height))
    }
}

extension Rect {
    
    @inlinable
    @inline(__always)
    public init(_ r: CGRect) {
        if r.isNull {
            self = .null
        } else if r.isInfinite {
            self = .infinite
        } else {
            self.init(origin: Point(r.origin), size: Size(r.size))
        }
    }
    
    @inlinable
    @inline(__always)
    public init(origin: CGPoint, size: CGSize) {
        self.init(CGRect(origin: origin, size: size))
    }
}

extension CGRect {
    
    @inlinable
    @inline(__always)
    public var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

@inlinable
@inline(__always)
public func *(lhs: CGFloat, rhs: CGRect) -> CGRect {
    if rhs.isNull || rhs.isInfinite { return .null }
    return CGRect(origin: lhs * rhs.origin, size: lhs * rhs.size)
}
@inlinable
@inline(__always)
public func *(lhs: CGRect, rhs: CGFloat) -> CGRect {
    if lhs.isNull || lhs.isInfinite { return .null }
    return CGRect(origin: lhs.origin * rhs, size: lhs.size * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: CGRect, rhs: CGFloat) -> CGRect {
    if lhs.isNull || lhs.isInfinite { return .null }
    return CGRect(origin: lhs.origin / rhs, size: lhs.size / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout CGRect, rhs: CGFloat) {
    lhs = lhs * rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout CGRect, rhs: CGFloat) {
    lhs = lhs / rhs
}
