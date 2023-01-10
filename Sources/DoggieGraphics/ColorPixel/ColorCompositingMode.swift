//
//  ColorCompositingMode.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2023 Susan Cheng. All rights reserved.
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

@frozen
public struct ColorCompositingMode: Hashable {
    
    @usableFromInline
    var rawValue: ColorCompositingKernel.Type
    
    @inlinable
    init(rawValue: ColorCompositingKernel.Type) {
        self.rawValue = rawValue
    }
}

extension ColorCompositingMode {
    
    @inlinable
    public var identifier: ObjectIdentifier {
        return ObjectIdentifier(rawValue)
    }
    
    @inlinable
    public static func == (lhs: ColorCompositingMode, rhs: ColorCompositingMode) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension ColorCompositingMode {
    
    @inlinable
    @inline(__always)
    public static var `default`: ColorCompositingMode {
        return .sourceOver
    }
}

extension ColorCompositingMode {
    
    /// R = 0
    public static let clear = ColorCompositingMode(rawValue: ClearCompositingKernel.self)
    
    /// R = S
    public static let copy = ColorCompositingMode(rawValue: CopyCompositingKernel.self)
    
    /// R = S + D * (1 - Sa)
    public static let sourceOver = ColorCompositingMode(rawValue: SourceOverCompositingKernel.self)
    
    /// R = S * Da
    public static let sourceIn = ColorCompositingMode(rawValue: SourceInCompositingKernel.self)
    
    /// R = S * (1 - Da)
    public static let sourceOut = ColorCompositingMode(rawValue: SourceOutCompositingKernel.self)
    
    /// R = S * Da + D * (1 - Sa)
    public static let sourceAtop = ColorCompositingMode(rawValue: SourceAtopCompositingKernel.self)
    
    /// R = S * (1 - Da) + D
    public static let destinationOver = ColorCompositingMode(rawValue: DestinationOverCompositingKernel.self)
    
    /// R = D * Sa
    public static let destinationIn = ColorCompositingMode(rawValue: DestinationInCompositingKernel.self)
    
    /// R = D * (1 - Sa)
    public static let destinationOut = ColorCompositingMode(rawValue: DestinationOutCompositingKernel.self)
    
    /// R = S * (1 - Da) + D * Sa
    public static let destinationAtop = ColorCompositingMode(rawValue: DestinationAtopCompositingKernel.self)
    
    /// R = S * (1 - Da) + D * (1 - Sa)
    public static let xor = ColorCompositingMode(rawValue: XorCompositingKernel.self)
}

extension ColorPixel {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self {
        
        let d_alpha = self.opacity
        let s_alpha = source.opacity
        
        let r_alpha = compositingMode.rawValue.mix(s_alpha, s_alpha, d_alpha, d_alpha)
        
        if r_alpha > 0 {
            let _destination = self.color
            let _source = blendMode.rawValue.combine(source.color, _destination, d_alpha)
            return Self(color: compositingMode.rawValue.mix(s_alpha / r_alpha * _source, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
        } else {
            return Self()
        }
    }
}

extension ColorPixel where Self: _FloatComponentPixel, ColorComponents: DoggieGraphics.ColorComponents {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self {
        
        let d_alpha = self._opacity
        let s_alpha = source._opacity
        
        let r_alpha = compositingMode.rawValue.mix(s_alpha, s_alpha, d_alpha, d_alpha)
        
        if r_alpha > 0 {
            let _destination = self._color
            let _source = blendMode.rawValue.combine(source._color, _destination, d_alpha)
            return Self(color: compositingMode.rawValue.mix(s_alpha / r_alpha * _source, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
        } else {
            return Self()
        }
    }
}
