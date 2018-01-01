//
//  ARGB64ColorPixel.swift
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

public struct ARGB64ColorPixel : ColorPixelProtocol {
    
    public typealias Scalar = Double
    
    public var a: UInt16
    public var r: UInt16
    public var g: UInt16
    public var b: UInt16
    
    @_inlineable
    public init() {
        self.a = 0
        self.r = 0
        self.g = 0
        self.b = 0
    }
    @_inlineable
    public init(red: UInt16, green: UInt16, blue: UInt16, opacity: UInt16 = 0xFFFF) {
        self.a = opacity
        self.r = red
        self.g = green
        self.b = blue
    }
    @_inlineable
    public init(_ hex: UInt64) {
        self.a = UInt16((hex >> 48) & 0xFFFF)
        self.r = UInt16((hex >> 32) & 0xFFFF)
        self.g = UInt16((hex >> 16) & 0xFFFF)
        self.b = UInt16(hex & 0xFFFF)
    }
    @_inlineable
    public init(color: RGBColorModel, opacity: Double) {
        self.a = UInt16((opacity * 65535).clamped(to: 0...65535).rounded())
        self.r = UInt16((color.red * 65535).clamped(to: 0...65535).rounded())
        self.g = UInt16((color.green * 65535).clamped(to: 0...65535).rounded())
        self.b = UInt16((color.blue * 65535).clamped(to: 0...65535).rounded())
    }
    
    @_inlineable
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
    @_inlineable
    public var opacity: Double {
        get {
            return Double(a) / 65535
        }
        set {
            self.a = UInt16((newValue * 65535).clamped(to: 0...65535).rounded())
        }
    }
    
    @_inlineable
    public var hex: UInt64 {
        let _a = UInt64(a) << 48
        let _r = UInt64(r) << 32
        let _g = UInt64(g) << 16
        let _b = UInt64(b)
        return _a | _r | _g | _b
    }
    
    @_inlineable
    public var hashValue: Int {
        return hex.hashValue
    }
    
    @_inlineable
    public var isOpaque: Bool {
        return a == 65535
    }
    
    @_inlineable
    public func with(opacity: Double) -> ARGB64ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

@_inlineable
public func ==(lhs: ARGB64ColorPixel, rhs: ARGB64ColorPixel) -> Bool {
    
    return (lhs.a, lhs.r, lhs.g, lhs.b) == (rhs.a, rhs.r, rhs.g, rhs.b)
}

@_inlineable
public func !=(lhs: ARGB64ColorPixel, rhs: ARGB64ColorPixel) -> Bool {
    
    return (lhs.a, lhs.r, lhs.g, lhs.b) != (rhs.a, rhs.r, rhs.g, rhs.b)
}
