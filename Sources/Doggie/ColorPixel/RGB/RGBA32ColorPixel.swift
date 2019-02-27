//
//  RGBA32ColorPixel.swift
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
public struct RGBA32ColorPixel : ColorPixelProtocol {
    
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    public var a: UInt8
    
    @inlinable
    @inline(__always)
    public init() {
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 0
    }
    @inlinable
    @inline(__always)
    public init(red: UInt8, green: UInt8, blue: UInt8, opacity: UInt8 = 0xFF) {
        self.r = red
        self.g = green
        self.b = blue
        self.a = opacity
    }
    @inlinable
    @inline(__always)
    public init(color: RGBColorModel, opacity: Double) {
        self.r = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        self.g = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        self.b = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        self.a = UInt8((opacity * 255).clamped(to: 0...255).rounded())
    }
    
    @_transparent
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        }
        set {
            self.r = UInt8((newValue.red * 255).clamped(to: 0...255).rounded())
            self.g = UInt8((newValue.green * 255).clamped(to: 0...255).rounded())
            self.b = UInt8((newValue.blue * 255).clamped(to: 0...255).rounded())
        }
    }
    @_transparent
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255).rounded())
        }
    }
    
    @_transparent
    public var isOpaque: Bool {
        return a == 255
    }
    
    @inlinable
    @inline(__always)
    public func with(opacity: Double) -> RGBA32ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

