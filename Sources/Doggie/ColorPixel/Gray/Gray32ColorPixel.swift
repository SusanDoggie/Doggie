//
//  Gray32ColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

@_fixed_layout
public struct Gray32ColorPixel : ColorPixelProtocol {
    
    public var w: UInt16
    public var a: UInt16
    
    @inlinable
    @inline(__always)
    public init() {
        self.w = 0
        self.a = 0
    }
    @inlinable
    @inline(__always)
    public init(white: UInt16, opacity: UInt16 = 0xFFFF) {
        self.w = white
        self.a = opacity
    }
    
    @inlinable
    @inline(__always)
    public init(color: GrayColorModel, opacity: Double) {
        self.w = UInt16((color.white * 65535).clamped(to: 0...65535).rounded())
        self.a = UInt16((opacity * 65535).clamped(to: 0...65535).rounded())
    }
    
    @_transparent
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / 65535)
        }
        set {
            self.w = UInt16((newValue.white * 65535).clamped(to: 0...65535).rounded())
        }
    }
    @_transparent
    public var opacity: Double {
        get {
            return Double(a) / 65535
        }
        set {
            self.a = UInt16((newValue * 65535).rounded().clamped(to: 0...65535))
        }
    }
    
    @_transparent
    public var isOpaque: Bool {
        return a == 65535
    }
    
    @inlinable
    @inline(__always)
    public func with(opacity: Double) -> Gray32ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

