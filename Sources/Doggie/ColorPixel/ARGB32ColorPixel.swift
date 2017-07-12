//
//  ARGB32ColorPixel.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2017 Susan Cheng. All rights reserved.
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

public struct ARGB32ColorPixel : ColorPixelProtocol {
    
    public var a: UInt8
    public var r: UInt8
    public var g: UInt8
    public var b: UInt8
    
    @_inlineable
    public init() {
        self.a = 0
        self.r = 0
        self.g = 0
        self.b = 0
    }
    @_inlineable
    public init(red: UInt8, green: UInt8, blue: UInt8, opacity: UInt8 = 0xFF) {
        self.a = opacity
        self.r = red
        self.g = green
        self.b = blue
    }
    @_inlineable
    public init(_ hex: UInt32) {
        self.a = UInt8((hex >> 24) & 0xFF)
        self.r = UInt8((hex >> 16) & 0xFF)
        self.g = UInt8((hex >> 8) & 0xFF)
        self.b = UInt8(hex & 0xFF)
    }
    @_inlineable
    public init(color: RGBColorModel, opacity: Double) {
        self.a = UInt8((opacity * 255).clamped(to: 0...255))
        self.r = UInt8((color.red * 255).clamped(to: 0...255))
        self.g = UInt8((color.green * 255).clamped(to: 0...255))
        self.b = UInt8((color.blue * 255).clamped(to: 0...255))
    }
    
    @_inlineable
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
        }
        set {
            self.r = UInt8((newValue.red * 255).clamped(to: 0...255))
            self.g = UInt8((newValue.green * 255).clamped(to: 0...255))
            self.b = UInt8((newValue.blue * 255).clamped(to: 0...255))
        }
    }
    @_inlineable
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255))
        }
    }
    
    @_inlineable
    public var hex: UInt32 {
        let _a = UInt32(a) << 24
        let _r = UInt32(r) << 16
        let _g = UInt32(g) << 8
        let _b = UInt32(b)
        return _a | _r | _g | _b
    }
    
    @_inlineable
    public var hashValue: Int {
        return hex.hashValue
    }
    
    @_inlineable
    public var isOpaque: Bool {
        return a == 255
    }
    
    @_inlineable
    public func with(opacity: Double) -> ARGB32ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

@_inlineable
public func ==(lhs: ARGB32ColorPixel, rhs: ARGB32ColorPixel) -> Bool {
    
    return (lhs.a, lhs.r, lhs.g, lhs.b) == (rhs.a, rhs.r, rhs.g, rhs.b)
}

@_inlineable
public func !=(lhs: ARGB32ColorPixel, rhs: ARGB32ColorPixel) -> Bool {
    
    return (lhs.a, lhs.r, lhs.g, lhs.b) != (rhs.a, rhs.r, rhs.g, rhs.b)
}
