//
//  Gray16ColorPixel.swift
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
public struct Gray16ColorPixel: ColorPixel {
    
    public var w: UInt8
    public var a: UInt8
    
    @inlinable
    @inline(__always)
    public init() {
        self.w = 0
        self.a = 0
    }
    @inlinable
    @inline(__always)
    public init(white: UInt8, opacity: UInt8 = 0xFF) {
        self.w = white
        self.a = opacity
    }
    @inlinable
    @inline(__always)
    public init(color: GrayColorModel, opacity: Double = 1) {
        self.w = UInt8((color.white * 255).clamped(to: 0...255).rounded())
        self.a = UInt8((opacity * 255).clamped(to: 0...255).rounded())
    }
    
    @inlinable
    @inline(__always)
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / 255)
        }
        set {
            self.w = UInt8((newValue.white * 255).clamped(to: 0...255).rounded())
        }
    }
    @inlinable
    @inline(__always)
    public var opacity: Double {
        get {
            return Double(a) / 255
        }
        set {
            self.a = UInt8((newValue * 255).clamped(to: 0...255).rounded())
        }
    }
    
    @inlinable
    @inline(__always)
    public var isOpaque: Bool {
        return a == 255
    }
    
    @inlinable
    @inline(__always)
    public func with(opacity: Double) -> Gray16ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

extension Gray16ColorPixel {
    
    @inlinable
    @inline(__always)
    public func blended(source: Gray16ColorPixel) -> Gray16ColorPixel {
        
        let d_w = UInt32(self.w)
        let d_a = UInt32(self.a)
        let s_w = UInt32(source.w)
        let s_a = UInt32(source.a)
        
        let a = s_a + (((0xFF - s_a) * d_a) + 0x7F) / 0xFF
        
        if a == 0 {
            
            return Gray16ColorPixel()
            
        } else if d_a == 0xFF {
            
            let w = (s_a * s_w + (0xFF - s_a) * d_w + 0x7F) / 0xFF
            
            return Gray16ColorPixel(white: UInt8(w), opacity: UInt8(a))
            
        } else {
            
            let w = ((0xFF * s_a * s_w + (0xFF - s_a) * d_a * d_w) / a + 0x7F) / 0xFF
            
            return Gray16ColorPixel(white: UInt8(w), opacity: UInt8(a))
        }
    }
}
