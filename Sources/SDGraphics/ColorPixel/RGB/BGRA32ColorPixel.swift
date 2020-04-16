//
//  BGRA32ColorPixel.swift
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
public struct BGRA32ColorPixel: ColorPixel {
    
    public var b: UInt8
    public var g: UInt8
    public var r: UInt8
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
    public init(color: RGBColorModel, opacity: Double = 1) {
        self.r = UInt8((color.red * 255).clamped(to: 0...255).rounded())
        self.g = UInt8((color.green * 255).clamped(to: 0...255).rounded())
        self.b = UInt8((color.blue * 255).clamped(to: 0...255).rounded())
        self.a = UInt8((opacity * 255).clamped(to: 0...255).rounded())
    }
    
    @inlinable
    @inline(__always)
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
    public func with(opacity: Double) -> BGRA32ColorPixel {
        var c = self
        c.opacity = opacity
        return c
    }
}

extension BGRA32ColorPixel {
    
    @inlinable
    @inline(__always)
    public func blended(source: BGRA32ColorPixel) -> BGRA32ColorPixel {
        
        let d_r = UInt32(self.r)
        let d_g = UInt32(self.g)
        let d_b = UInt32(self.b)
        let d_a = UInt32(self.a)
        let s_r = UInt32(source.r)
        let s_g = UInt32(source.g)
        let s_b = UInt32(source.b)
        let s_a = UInt32(source.a)
        
        let a = s_a + (((0xFF - s_a) * d_a) + 0x7F) / 0xFF
        
        if a == 0 {
            
            return BGRA32ColorPixel()
            
        } else if d_a == 0xFF {
            
            let r = (s_a * s_r + (0xFF - s_a) * d_r + 0x7F) / 0xFF
            let g = (s_a * s_g + (0xFF - s_a) * d_g + 0x7F) / 0xFF
            let b = (s_a * s_b + (0xFF - s_a) * d_b + 0x7F) / 0xFF
            
            return BGRA32ColorPixel(red: UInt8(r), green: UInt8(g), blue: UInt8(b), opacity: UInt8(a))
            
        } else {
            
            let r = ((0xFF * s_a * s_r + (0xFF - s_a) * d_a * d_r) / a + 0x7F) / 0xFF
            let g = ((0xFF * s_a * s_g + (0xFF - s_a) * d_a * d_g) / a + 0x7F) / 0xFF
            let b = ((0xFF * s_a * s_b + (0xFF - s_a) * d_a * d_b) / a + 0x7F) / 0xFF
            
            return BGRA32ColorPixel(red: UInt8(r), green: UInt8(g), blue: UInt8(b), opacity: UInt8(a))
        }
    }
}
