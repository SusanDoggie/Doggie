//
//  RGBA64ColorPixel.swift
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

public struct RGBA64ColorPixel : ColorPixelProtocol {
    
    public var r: UInt16
    public var g: UInt16
    public var b: UInt16
    public var a: UInt16
    
    @_transparent
    public init() {
        self.r = 0
        self.g = 0
        self.b = 0
        self.a = 0
    }
    @_transparent
    public init(red: UInt16, green: UInt16, blue: UInt16, opacity: UInt16 = 0xFFFF) {
        self.r = red
        self.g = green
        self.b = blue
        self.a = opacity
    }
    @_transparent
    public init(color: RGBColorModel, opacity: Double) {
        self.r = UInt16((color.red * 65535).clamped(to: 0...65535).rounded())
        self.g = UInt16((color.green * 65535).clamped(to: 0...65535).rounded())
        self.b = UInt16((color.blue * 65535).clamped(to: 0...65535).rounded())
        self.a = UInt16((opacity * 65535).clamped(to: 0...65535).rounded())
    }
    
    @_transparent
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / 65535, green: Double(g) / 65535, blue: Double(b) / 65535)
        }
        set {
            self.r = UInt16((newValue.red * 65535).clamped(to: 0...65535).rounded())
            self.g = UInt16((newValue.green * 65535).clamped(to: 0...65535).rounded())
            self.b = UInt16((newValue.blue * 65535).clamped(to: 0...65535).rounded())
        }
    }
    @_transparent
    public var opacity: Double {
        get {
            return Double(a) / 65535
        }
        set {
            self.a = UInt16((newValue * 65535).clamped(to: 0...65535).rounded())
        }
    }
    
    @_transparent
    public var isOpaque: Bool {
        return a == 65535
    }
    
    @_transparent
    public func with(opacity: Double) -> RGBA64ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

