//
//  CGSize.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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

extension CGSize {
    
    @inlinable
    @inline(__always)
    public init(_ s: Size) {
        self.init(width: CGFloat(s.width), height: CGFloat(s.height))
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryInteger>(width: T, height: T) {
        self.init(width: CGFloat(width), height: CGFloat(height))
    }
    @inlinable
    @inline(__always)
    public init<T: BinaryFloatingPoint>(width: T, height: T) {
        self.init(width: CGFloat(width), height: CGFloat(height))
    }
}

extension Size {
    
    @inlinable
    @inline(__always)
    public init(_ s: CGSize) {
        self.init(width: s.width, height: s.height)
    }
}

@inlinable
@inline(__always)
public prefix func +(val: CGSize) -> CGSize {
    return val
}
@inlinable
@inline(__always)
public prefix func -(val: CGSize) -> CGSize {
    return CGSize(width: -val.width, height: -val.height)
}
@inlinable
@inline(__always)
public func +(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
}
@inlinable
@inline(__always)
public func -(lhs: CGSize, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
}

@inlinable
@inline(__always)
public func *(lhs: CGFloat, rhs: CGSize) -> CGSize {
    return CGSize(width: lhs * rhs.width, height: lhs * rhs.height)
}
@inlinable
@inline(__always)
public func *(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

@inlinable
@inline(__always)
public func /(lhs: CGSize, rhs: CGFloat) -> CGSize {
    return CGSize(width: lhs.width / rhs, height: lhs.height / rhs)
}

@inlinable
@inline(__always)
public func *= (lhs: inout CGSize, rhs: CGFloat) {
    lhs.width *= rhs
    lhs.height *= rhs
}
@inlinable
@inline(__always)
public func /= (lhs: inout CGSize, rhs: CGFloat) {
    lhs.width /= rhs
    lhs.height /= rhs
}
@inlinable
@inline(__always)
public func += (lhs: inout CGSize, rhs: CGSize) {
    lhs.width += rhs.width
    lhs.height += rhs.height
}
@inlinable
@inline(__always)
public func -= (lhs: inout CGSize, rhs: CGSize) {
    lhs.width -= rhs.width
    lhs.height -= rhs.height
}
