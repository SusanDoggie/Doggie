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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

public protocol _GrayColorPixelConvertible {
    
    func _convert<Pixel: _GrayColorPixel>(_: Pixel.Type) -> Pixel
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    public init<C: ColorPixel>(_ color: C) where Model == C.Model {
        if let color = color as? _GrayColorPixelConvertible {
            self = color._convert(Self.self)
        } else {
            self.init(color: color.color, opacity: color.opacity)
        }
    }
    
    @inlinable
    public func _convert<Pixel: _GrayColorPixel>(_: Pixel.Type) -> Pixel {
        return Pixel(color: self)
    }
}

public protocol _GrayColorPixel: ColorPixel, _GrayColorPixelConvertible where Model == GrayColorModel {
    
    associatedtype Component: FixedWidthInteger & UnsignedInteger
    
    init(white: Component, opacity: Component)
    
    var w: Component { get set }
    
    var a: Component { get set }
    
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    public init() {
        self.init(white: 0, opacity: 0)
    }
    
    @inlinable
    public init<C: _GrayColorPixel>(_ color: C) where C.Component == Component {
        self.init(white: color.w, opacity: color.a)
    }
    
    @inlinable
    init<C: _GrayColorPixel>(color: C) {
        
        let w = _mul_div(color.w, Component.max, C.Component.max)
        let a = _mul_div(color.a, Component.max, C.Component.max)
        
        self.init(white: w, opacity: a)
    }
    
    @inlinable
    public init<C: _GrayColorPixel>(_ color: C) {
        self.init(color: color)
    }
    
    @inlinable
    public init(color: GrayColorModel, opacity: Double = 1) {
        
        let w = Component((color.white * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        let a = Component((opacity * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        
        self.init(white: w, opacity: a)
    }
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    public static var bitsPerComponent: Int {
        return MemoryLayout<Component>.stride << 3
    }
    
    @inlinable
    public var bitsPerComponent: Int {
        return Self.bitsPerComponent
    }
}

extension ColorPixel where Self: _GrayColorPixel {
    
    @inlinable
    var _max: Double {
        return Double(Component.max)
    }
    
    @inlinable
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return Double(w) / _max
        case 1: return Double(a) / _max
        default: fatalError("Index out of range.")
        }
    }
    
    @inlinable
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: self.w = Component((value * _max).clamped(to: 0..._max).rounded())
        case 1: self.a = Component((value * _max).clamped(to: 0..._max).rounded())
        default: fatalError("Index out of range.")
        }
    }
    
    @inlinable
    public var color: GrayColorModel {
        get {
            return GrayColorModel(white: Double(w) / _max)
        }
        set {
            self.w = Component((newValue.white * _max).clamped(to: 0..._max).rounded())
        }
    }
    @inlinable
    public var opacity: Double {
        get {
            return Double(a) / _max
        }
        set {
            self.a = Component((newValue * _max).clamped(to: 0..._max).rounded())
        }
    }
    
    @inlinable
    public func premultiplied() -> Self {
        return Self(white: _mul_div(w, a, Component.max), opacity: a)
    }
    
    @inlinable
    public func unpremultiplied() -> Self {
        guard a != 0 else { return self }
        return Self(white: _mul_div(w, Component.max, a), opacity: a)
    }
    
    @inlinable
    public var isOpaque: Bool {
        return a == Component.max
    }
}

extension ColorPixel where Self: _GrayColorPixel, Component == UInt8 {
    
    @inlinable
    public func blended(source: Self) -> Self {
        
        switch (self.a, source.a) {
        case (0, 0): return Self()
        case (0, _), (_, 0xFF): return source
        case (_, 0): return self
        default: break
        }
        
        let d_w = UInt32(self.w)
        let d_a = UInt32(self.a)
        let s_w = UInt32(source.w)
        let s_a = UInt32(source.a)
        
        if d_a == 0xFF {
            
            let w = (s_a * s_w + (0xFF - s_a) * d_w + 0x7F) / 0xFF
            
            return Self(white: UInt8(w), opacity: 0xFF)
            
        } else {
            
            let a = s_a + ((0xFF - s_a) * d_a + 0x7F) / 0xFF
            let w = ((0xFF * s_a * s_w + (0xFF - s_a) * d_a * d_w) / a + 0x7F) / 0xFF
            
            return Self(white: UInt8(w), opacity: UInt8(a))
        }
    }
}

extension ColorPixel where Self: _GrayColorPixel, Component == UInt16 {
    
    @inlinable
    public func blended(source: Self) -> Self {
        
        switch (self.a, source.a) {
        case (0, 0): return Self()
        case (0, _), (_, 0xFFFF): return source
        case (_, 0): return self
        default: break
        }
        
        let d_w = UInt64(self.w)
        let d_a = UInt64(self.a)
        let s_w = UInt64(source.w)
        let s_a = UInt64(source.a)
        
        if d_a == 0xFFFF {
            
            let w = (s_a * s_w + (0xFFFF - s_a) * d_w + 0x7FFF) / 0xFFFF
            
            return Self(white: UInt16(w), opacity: 0xFFFF)
            
        } else {
            
            let a = s_a + ((0xFFFF - s_a) * d_a + 0x7FFF) / 0xFFFF
            let w = ((0xFFFF * s_a * s_w + (0xFFFF - s_a) * d_a * d_w) / a + 0x7FFF) / 0xFFFF
            
            return Self(white: UInt16(w), opacity: UInt16(a))
        }
    }
}
