//
//  CompositingMode.swift
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

public enum ColorCompositingMode {
    
    case clear /* R = 0 */
    
    case copy /* R = S */
    
    case sourceOver /* R = S + D * (1 - Sa) */
    
    case sourceIn /* R = S * Da */
    
    case sourceOut /* R = S * (1 - Da) */
    
    case sourceAtop /* R = S * Da + D * (1 - Sa) */
    
    case destinationOver /* R = S * (1 - Da) + D */
    
    case destinationIn /* R = D * Sa */
    
    case destinationOut /* R = D * (1 - Sa) */
    
    case destinationAtop /* R = S * (1 - Da) + D * Sa */
    
    case xor /* R = S * (1 - Da) + D * (1 - Sa) */
    
}

extension ColorCompositingMode {
    
    @inlinable
    public static var `default` : ColorCompositingMode {
        return .sourceOver
    }
}

extension ColorCompositingMode {
    
    @inlinable
    @inline(__always)
    func mix<T : ScalarMultiplicative>(_ source: T, _ source_alpha: T.Scalar, _ destination: T, _ destination_alpha: T.Scalar) -> T {
        
        switch self {
        case .clear: return T()
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

extension ColorPixelProtocol {
    
    @inlinable
    @inline(__always)
    public func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blending: (Double, Double) -> Double) -> Self where C.Model == Model {
        
        switch compositingMode {
        case .clear: return Self()
        default:
            
            let d_alpha = self.opacity
            let s_alpha = source.opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source.color
                let _destination = self.color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.combined(_source, blending)
                return Self(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return Self()
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) -> Self where C.Model == Model {
        
        switch (compositingMode, blendMode) {
        case (.clear, _): return Self()
        case (.copy, .normal): return Self(source)
        default:
            
            let d_alpha = self.opacity
            let s_alpha = source.opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source.color
                let _destination = self.color
                let blended = blendMode == .normal ? _source : (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                return Self(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return Self()
            }
        }
    }
}

extension FloatColorPixel {
    
    @inlinable
    @inline(__always)
    public func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blending: (Double, Double) -> Double) -> FloatColorPixel where C.Model == Model {
        return blended(source: source, compositingMode: compositingMode, blending: { Float(blending(Double($0), Double($1))) })
    }
    
    @inlinable
    @inline(__always)
    public mutating func blend<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blending: (Float, Float) -> Float) where C.Model == Model {
        self = self.blended(source: source, compositingMode: compositingMode, blending: blending)
    }
    
    @inlinable
    @inline(__always)
    public func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode, blending: (Float, Float) -> Float) -> FloatColorPixel where C.Model == Model {
        
        switch compositingMode {
        case .clear: return FloatColorPixel()
        default:
            
            let source = FloatColorPixel(source)
            
            let d_alpha = self._opacity
            let s_alpha = source._opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source._color
                let _destination = self._color
                let blended = (1 - d_alpha) * _source + d_alpha * _destination.combined(_source, blending)
                return FloatColorPixel(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return FloatColorPixel()
            }
        }
    }
    
    @inlinable
    @inline(__always)
    public func blended<C : ColorPixelProtocol>(source: C, compositingMode: ColorCompositingMode = .default, blendMode: ColorBlendMode = .default) -> FloatColorPixel where C.Model == Model {
        
        switch (compositingMode, blendMode) {
        case (.clear, _): return FloatColorPixel()
        case (.copy, .normal): return FloatColorPixel(source)
        default:
            
            let source = FloatColorPixel(source)
            
            let d_alpha = self._opacity
            let s_alpha = source._opacity
            
            let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
            
            if r_alpha > 0 {
                let _source = source._color
                let _destination = self._color
                let blended = blendMode == .normal ? _source : (1 - d_alpha) * _source + d_alpha * _destination.blended(source: _source, blendMode: blendMode)
                return FloatColorPixel(color: compositingMode.mix(s_alpha / r_alpha * blended, s_alpha, d_alpha / r_alpha * _destination, d_alpha), opacity: r_alpha)
            } else {
                return FloatColorPixel()
            }
        }
    }
}

