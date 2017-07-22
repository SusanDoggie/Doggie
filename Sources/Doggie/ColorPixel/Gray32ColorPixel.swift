//
//  Gray32ColorPixel.swift
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

public struct Gray32ColorPixel : ColorPixelProtocol {
    
    public var a: UInt16
    public var w: UInt16
    
    @_inlineable
    public init() {
        self.a = 0
        self.w = 0
    }
    @_inlineable
    public init(white: UInt16, opacity: UInt16 = 0xFFFF) {
        self.a = opacity
        self.w = white
    }
    @_inlineable
    public init(_ hex: UInt32) {
        self.a = UInt16((hex >> 16) & 0xFFFF)
        self.w = UInt16(hex & 0xFFFF)
    }
    @_inlineable
    public init(color: GrayColorModel, opacity: Double) {
        self.a = UInt16((opacity * 65535).clamped(to: 0...65535).rounded())
        self.w = UInt16((color.white * 65535).clamped(to: 0...65535).rounded())
    }
    
    @_inlineable
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / 65535)
        }
        set {
            self.w = UInt16((newValue.white * 65535).clamped(to: 0...65535).rounded())
        }
    }
    @_inlineable
    public var opacity: Double {
        get {
            return Double(a) / 65535
        }
        set {
            self.a = UInt16((newValue * 65535).rounded().clamped(to: 0...65535))
        }
    }
    
    @_inlineable
    public var hex: UInt32 {
        let _a = UInt32(a) << 16
        let _w = UInt32(w)
        return _a | _w
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
    public func with(opacity: Double) -> Gray32ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

@_inlineable
public func ==(lhs: Gray32ColorPixel, rhs: Gray32ColorPixel) -> Bool {
    
    return (lhs.a, lhs.w) == (rhs.a, rhs.w)
}

@_inlineable
public func !=(lhs: Gray32ColorPixel, rhs: Gray32ColorPixel) -> Bool {
    
    return (lhs.a, lhs.w) != (rhs.a, rhs.w)
}
