//
//  RGBColorPixel.swift
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

public protocol _RGBColorPixelConvertible {
    
    func _convert<Pixel: _RGBColorPixel>(_: Pixel.Type) -> Pixel
}

extension ColorPixel where Self: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    public init<C: ColorPixel>(_ color: C) where Model == C.Model {
        if let color = color as? _RGBColorPixelConvertible {
            self = color._convert(Self.self)
        } else {
            self.init(color: color.color, opacity: color.opacity)
        }
    }
    
    @inlinable
    @inline(__always)
    public func _convert<Pixel: _RGBColorPixel>(_: Pixel.Type) -> Pixel {
        return Pixel(color: self)
    }
}

public protocol _RGBColorPixel: ColorPixel, _RGBColorPixelConvertible where Model == RGBColorModel {
    
    associatedtype Component: FixedWidthInteger & UnsignedInteger
    
    init(red: Component, green: Component, blue: Component, opacity: Component)
    
    var r: Component { get set }
    
    var g: Component { get set }
    
    var b: Component { get set }
    
    var a: Component { get set }
    
}

extension ColorPixel where Self: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    public init<C: _RGBColorPixel>(_ color: C) where C.Component == Component {
        self.init(red: color.r, green: color.g, blue: color.b, opacity: color.a)
    }
    
    @inlinable
    @inline(__always)
    init<C: _RGBColorPixel>(color: C) {
        
        let r = _mul_div(color.r, Component.max, C.Component.max)
        let g = _mul_div(color.g, Component.max, C.Component.max)
        let b = _mul_div(color.b, Component.max, C.Component.max)
        let a = _mul_div(color.a, Component.max, C.Component.max)
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
    
    @inlinable
    @inline(__always)
    public init<C: _RGBColorPixel>(_ color: C) {
        self.init(color: color)
    }
    
    @inlinable
    @inline(__always)
    public init(color: RGBColorModel, opacity: Double = 1) {
        
        let r = Component((color.red * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        let g = Component((color.green * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        let b = Component((color.blue * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        let a = Component((opacity * Double(Component.max)).clamped(to: 0...Double(Component.max)).rounded())
        
        self.init(red: r, green: g, blue: b, opacity: a)
    }
}

extension ColorPixel where Self: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    public static var bitsPerComponent: Int {
        return MemoryLayout<Component>.stride << 3
    }
    
    @inlinable
    @inline(__always)
    public var bitsPerComponent: Int {
        return Self.bitsPerComponent
    }
}

extension ColorPixel where Self: _RGBColorPixel {
    
    @inlinable
    @inline(__always)
    var _max: Double {
        return Double(Component.max)
    }
    
    @inlinable
    @inline(__always)
    public func component(_ index: Int) -> Double {
        switch index {
        case 0: return Double(r) / _max
        case 1: return Double(g) / _max
        case 2: return Double(b) / _max
        case 3: return Double(a) / _max
        default: fatalError("Index out of range.")
        }
    }
    
    @inlinable
    @inline(__always)
    public mutating func setComponent(_ index: Int, _ value: Double) {
        switch index {
        case 0: self.r = Component((value * _max).clamped(to: 0..._max).rounded())
        case 1: self.g = Component((value * _max).clamped(to: 0..._max).rounded())
        case 2: self.b = Component((value * _max).clamped(to: 0..._max).rounded())
        case 3: self.a = Component((value * _max).clamped(to: 0..._max).rounded())
        default: fatalError("Index out of range.")
        }
    }
    
    @inlinable
    @inline(__always)
    public var color: RGBColorModel {
        get {
            return RGBColorModel(red: Double(r) / _max, green: Double(g) / _max, blue: Double(b) / _max)
        }
        set {
            self.r = Component((newValue.red * _max).clamped(to: 0..._max).rounded())
            self.g = Component((newValue.green * _max).clamped(to: 0..._max).rounded())
            self.b = Component((newValue.blue * _max).clamped(to: 0..._max).rounded())
        }
    }
    @inlinable
    @inline(__always)
    public var opacity: Double {
        get {
            return Double(a) / _max
        }
        set {
            self.a = Component((newValue * _max).clamped(to: 0..._max).rounded())
        }
    }
    
    @inlinable
    @inline(__always)
    public func premultiplied() -> Self {
        
        guard a != 0 else { return self }
        
        let _r = _mul_div(r, a, Component.max)
        let _g = _mul_div(g, a, Component.max)
        let _b = _mul_div(b, a, Component.max)
        
        return Self(red: _r, green: _g, blue: _b, opacity: a)
    }
    
    @inlinable
    @inline(__always)
    public func unpremultiplied() -> Self {
        
        guard a != 0 else { return self }
        
        let _r = _mul_div(r, Component.max, a)
        let _g = _mul_div(g, Component.max, a)
        let _b = _mul_div(b, Component.max, a)
        
        return Self(red: _r, green: _g, blue: _b, opacity: a)
    }
    
    @inlinable
    @inline(__always)
    public var isOpaque: Bool {
        return a == Component.max
    }
}

extension ColorPixel where Self: _RGBColorPixel, Component == UInt8 {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self) -> Self {
        
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
            
            return Self()
            
        } else if d_a == 0xFF {
            
            let r = (s_a * s_r + (0xFF - s_a) * d_r + 0x7F) / 0xFF
            let g = (s_a * s_g + (0xFF - s_a) * d_g + 0x7F) / 0xFF
            let b = (s_a * s_b + (0xFF - s_a) * d_b + 0x7F) / 0xFF
            
            return Self(red: UInt8(r), green: UInt8(g), blue: UInt8(b), opacity: UInt8(a))
            
        } else {
            
            let r = ((0xFF * s_a * s_r + (0xFF - s_a) * d_a * d_r) / a + 0x7F) / 0xFF
            let g = ((0xFF * s_a * s_g + (0xFF - s_a) * d_a * d_g) / a + 0x7F) / 0xFF
            let b = ((0xFF * s_a * s_b + (0xFF - s_a) * d_a * d_b) / a + 0x7F) / 0xFF
            
            return Self(red: UInt8(r), green: UInt8(g), blue: UInt8(b), opacity: UInt8(a))
        }
    }
}

extension ColorPixel where Self: _RGBColorPixel, Component == UInt16 {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self) -> Self {
        
        let d_r = UInt64(self.r)
        let d_g = UInt64(self.g)
        let d_b = UInt64(self.b)
        let d_a = UInt64(self.a)
        let s_r = UInt64(source.r)
        let s_g = UInt64(source.g)
        let s_b = UInt64(source.b)
        let s_a = UInt64(source.a)
        
        let a = s_a + (((0xFFFF - s_a) * d_a) + 0x7FFF) / 0xFFFF
        
        if a == 0 {
            
            return Self()
            
        } else if d_a == 0xFFFF {
            
            let r = (s_a * s_r + (0xFFFF - s_a) * d_r + 0x7FFF) / 0xFFFF
            let g = (s_a * s_g + (0xFFFF - s_a) * d_g + 0x7FFF) / 0xFFFF
            let b = (s_a * s_b + (0xFFFF - s_a) * d_b + 0x7FFF) / 0xFFFF
            
            return Self(red: UInt16(r), green: UInt16(g), blue: UInt16(b), opacity: UInt16(a))
            
        } else {
            
            let r = ((0xFFFF * s_a * s_r + (0xFFFF - s_a) * d_a * d_r) / a + 0x7FFF) / 0xFFFF
            let g = ((0xFFFF * s_a * s_g + (0xFFFF - s_a) * d_a * d_g) / a + 0x7FFF) / 0xFFFF
            let b = ((0xFFFF * s_a * s_b + (0xFFFF - s_a) * d_a * d_b) / a + 0x7FFF) / 0xFFFF
            
            return Self(red: UInt16(r), green: UInt16(g), blue: UInt16(b), opacity: UInt16(a))
        }
    }
}
