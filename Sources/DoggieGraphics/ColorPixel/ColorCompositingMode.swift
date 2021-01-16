//
//  ColorCompositingMode.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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

public enum ColorCompositingMode: CaseIterable {
    
    /// R = 0
    case clear
    
    /// R = S
    case copy
    
    /// R = S + D * (1 - Sa)
    case sourceOver
    
    /// R = S * Da
    case sourceIn
    
    /// R = S * (1 - Da)
    case sourceOut
    
    /// R = S * Da + D * (1 - Sa)
    case sourceAtop
    
    /// R = S * (1 - Da) + D
    case destinationOver
    
    /// R = D * Sa
    case destinationIn
    
    /// R = D * (1 - Sa)
    case destinationOut
    
    /// R = S * (1 - Da) + D * Sa
    case destinationAtop
    
    /// R = S * (1 - Da) + D * (1 - Sa)
    case xor
    
}

extension ColorCompositingMode {
    
    @inlinable
    @inline(__always)
    public static var `default`: ColorCompositingMode {
        return .sourceOver
    }
}

extension ColorCompositingMode {
    
    @inlinable
    @inline(__always)
    func mix<T: ScalarMultiplicative>(_ source: T, _ source_alpha: T.Scalar, _ destination: T, _ destination_alpha: T.Scalar) -> T {
        
        switch self {
        case .clear: return .zero
        case .copy: return source
        case .sourceOver: return source + destination * (1 - source_alpha)
        case .sourceIn: return source * destination_alpha
        case .sourceOut: return source * (1 - destination_alpha)
        case .sourceAtop: return source * destination_alpha + destination * (1 - source_alpha)
        case .destinationOver: return source * (1 - destination_alpha) + destination
        case .destinationIn: return destination * source_alpha
        case .destinationOut: return destination * (1 - source_alpha)
        case .destinationAtop: return source * (1 - destination_alpha) + destination * source_alpha
        case .xor:
            let _s = source * (1 - destination_alpha)
            let _d = destination * (1 - source_alpha)
            return _s + _d
        }
    }
}

extension ColorPixel {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self {
        
        switch (compositingMode, blendMode) {
        case (.clear, _): return Self()
        case (.copy, .normal): return source
        case (.copy, _):
            
            let d_alpha = self.opacity
            let s_alpha = source.opacity
            
            switch (d_alpha, s_alpha) {
            case (0, 0): return Self()
            case (0, _): return source
            case (1, _):
                
                let _source = source.color
                let _destination = self.color
                let blended = _destination.blended(source: _source, blendMode: blendMode)
                
                return Self(color: blended, opacity: s_alpha)
                
            default:
                
                let _source = source.color
                let _destination = self.color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                
                return Self(color: blended, opacity: s_alpha)
            }
            
        case (_, .normal):
            
            let d_alpha = self.opacity
            let s_alpha = source.opacity
            
            switch (d_alpha, s_alpha) {
            case (0, 0): return Self()
            case (0, _), (_, 1): return source
            case (_, 0): return self
            case (1, _):
                
                let _source = source.color
                let _destination = self.color
                return Self(color: compositingMode.mix(s_alpha * _source, s_alpha, _destination, 1), opacity: 1)
                
            default:
                
                let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
                
                let _source = source.color
                let _destination = self.color
                return Self(color: compositingMode.mix(s_alpha / r_alpha * _source, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            }
            
        default:
            
            let d_alpha = self.opacity
            let s_alpha = source.opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source.color
                let _destination = self.color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                return Self(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return Self()
            }
        }
    }
}

extension ColorPixel where Self: _FloatComponentPixel, ColorComponents: DoggieGraphics.ColorComponents {
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, compositingMode: ColorCompositingMode, blendMode: ColorBlendMode) -> Self {
        
        switch (compositingMode, blendMode) {
        case (.clear, _): return Self()
        case (.copy, .normal): return source
        case (.copy, _):
            
            let d_alpha = self._opacity
            let s_alpha = source._opacity
            
            switch (d_alpha, s_alpha) {
            case (0, 0): return Self()
            case (0, _): return source
            case (1, _):
                
                let _source = source._color
                let _destination = self._color
                let blended = _destination.blended(source: _source, blendMode: blendMode)
                
                return Self(color: blended, opacity: s_alpha)
                
            default:
                
                let _source = source._color
                let _destination = self._color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                
                return Self(color: blended, opacity: s_alpha)
            }
            
        case (_, .normal):
            
            let d_alpha = self._opacity
            let s_alpha = source._opacity
            
            switch (d_alpha, s_alpha) {
            case (0, 0): return Self()
            case (0, _), (_, 1): return source
            case (_, 0): return self
            case (1, _):
                
                let _source = source._color
                let _destination = self._color
                return Self(color: compositingMode.mix(s_alpha * _source, s_alpha, _destination, 1), opacity: 1)
                
            default:
                
                let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
                
                let _source = source._color
                let _destination = self._color
                return Self(color: compositingMode.mix(s_alpha / r_alpha * _source, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            }
            
        default:
            
            let d_alpha = self._opacity
            let s_alpha = source._opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source._color
                let _destination = self._color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                return Self(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return Self()
            }
        }
    }
}
