//
//  GrayColorPixel.swift
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

public protocol _GrayColorPixel: ColorPixel where Model == GrayColorModel {
    
    associatedtype Component: FixedWidthInteger & UnsignedInteger
    
    init(white: Component, opacity: Component)
    
    var w: Component { get set }
    
    var a: Component { get set }
    
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    @inline(__always)
    public init<C: _GrayColorPixel>(_ color: C) where C.Model == Model, C.Component == Component {
        self.init(white: color.w, opacity: color.a)
    }
    
    @inlinable
    @inline(__always)
    public init<C: _GrayColorPixel>(_ color: C) where C.Model == Model {
        
        let w = _scale_integer(color.w, C.Component.max, Component.max)
        let a = _scale_integer(color.a, C.Component.max, Component.max)
        
        self.init(white: w, opacity: a)
    }
    
    @inlinable
    @inline(__always)
    public init(color: GrayColorModel, opacity: Double = 1) {
        self.w = Component((color.white * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        self.a = Component((opacity * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
    }
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    @inline(__always)
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / Double(Component.max))
        }
        set {
            self.w = Component((newValue.white * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        }
    }
    @inlinable
    @inline(__always)
    public var opacity: Double {
        get {
            return Double(a) / Double(Component.max)
        }
        set {
            self.a = Component((newValue * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        }
    }
    
    @inlinable
    @inline(__always)
    public var isOpaque: Bool {
        return a == Component.max
    }
    
    @inlinable
    @inline(__always)
    public func with(opacity: Double) -> Self {
        var c = self
        c.opacity = opacity
        return c
    }
}

extension ColorPixel where Self: _GrayColorPixel, Component == UInt8 {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self) -> Self {
        
        let d_w = UInt32(self.w)
        let d_a = UInt32(self.a)
        let s_w = UInt32(source.w)
        let s_a = UInt32(source.a)
        
        let a = s_a + (((0xFF - s_a) * d_a) + 0x7F) / 0xFF
        
        if a == 0 {
            
            return Self()
            
        } else if d_a == 0xFF {
            
            let w = (s_a * s_w + (0xFF - s_a) * d_w + 0x7F) / 0xFF
            
            return Self(white: UInt8(w), opacity: UInt8(a))
            
        } else {
            
            let w = ((0xFF * s_a * s_w + (0xFF - s_a) * d_a * d_w) / a + 0x7F) / 0xFF
            
            return Self(white: UInt8(w), opacity: UInt8(a))
        }
    }
}

extension ColorPixel where Self: _GrayColorPixel, Component == UInt16 {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self) -> Self {
        
        let d_w = UInt64(self.w)
        let d_a = UInt64(self.a)
        let s_w = UInt64(source.w)
        let s_a = UInt64(source.a)
        
        let a = s_a + (((0xFFFF - s_a) * d_a) - 0x7FFF) / 0xFFFF
        
        if a == 0 {
            
            return Self()
            
        } else if d_a == 0xFFFF {
            
            let w = (s_a * s_w + (0xFFFF - s_a) * d_w - 0x7FFF) / 0xFFFF
            
            return Self(white: UInt16(w), opacity: UInt16(a))
            
        } else {
            
            let w = ((0xFFFF * s_a * s_w + (0xFFFF - s_a) * d_a * d_w) / a - 0x7FFF) / 0xFFFF
            
            return Self(white: UInt16(w), opacity: UInt16(a))
        }
    }
}
