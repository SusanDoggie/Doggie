//
//  Gray16ColorPixel.swift
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

public struct Gray16ColorPixel : ColorPixelProtocol {
    
    public typealias Scalar = Double
    
    public var a: UInt8
    public var w: UInt8
    
    @_inlineable
    public init() {
        self.a = 0
        self.w = 0
    }
    @_inlineable
    public init(white: UInt8, opacity: UInt8 = 0xFF) {
        self.a = opacity
        self.w = white
    }
    @_inlineable
    public init(_ hex: UInt16) {
        self.a = UInt8((hex >> 8) & 0xFF)
        self.w = UInt8(hex & 0xFF)
    }
    @_inlineable
    public init(color: GrayColorModel, opacity: Double) {
        self.a = UInt8((opacity * 255).clamped(to: 0...255).rounded())
        self.w = UInt8((color.white * 255).clamped(to: 0...255).rounded())
    }
    
    @_inlineable
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / 255)
        }
        set {
            self.w = UInt8((newValue.white * 255).clamped(to: 0...255).rounded())
        }
    }
    @_inlineable
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255).rounded())
        }
    }
    
    @_inlineable
    public var hex: UInt16 {
        let _a = UInt16(a) << 8
        let _w = UInt16(w)
        return _a | _w
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
    public func with(opacity: Double) -> Gray16ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

@_inlineable
public func ==(lhs: Gray16ColorPixel, rhs: Gray16ColorPixel) -> Bool {
    
    return (lhs.a, lhs.w) == (rhs.a, rhs.w)
}

@_inlineable
public func !=(lhs: Gray16ColorPixel, rhs: Gray16ColorPixel) -> Bool {
    
    return (lhs.a, lhs.w) != (rhs.a, rhs.w)
}

