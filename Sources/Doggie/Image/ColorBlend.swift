//
//  ColorBlend.swift
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

import Foundation

public enum ColorBlendMode {
    
    case normal /* B(cb, cs) = cs */
    
    case multiply /* B(cb, cs) = cb * cs */
    
    case screen /* B(cb, cs) = cb + cs – (cb * cs) */
    
    case overlay /* B(cb, cs) = HardLight(cs, cb) */
    
    case darken /* B(cb, cs) = min(cb, cs) */
    
    case lighten /* B(cb, cs) = max(cb, cs) */
    
    case colorDodge /* B(cb, cs) = cs < 1 ? min(1, cb / (1 – cs)) : 1 */
    
    case colorBurn /* B(cb, cs) = cs > 0 ? 1 – min(1, (1 – cb) / cs) : 0 */
    
    case softLight /* B(cb, cs) = cs ≤ 0.5 ? cb – (1 – 2 * cs) * cb * (1 – cb) : cb + (2 * cs – 1) * (D(cb) – cb) where D(x) = x ≤ 0.25 ? ((16 * x – 12) * x + 4) * x : sqrt(x) */
    
    case hardLight /* B(cb, cs) = cs ≤ 0.5 ? Multiply(cb, 2 * cs) : Screen(cb, 2 * cs – 1) */
    
    case difference /* B(cb, cs) = abs(cb – cs) */
    
    case exclusion /* B(cb, cs) = cb + cs – 2 * cb * cs */
    
    case plusDarker /* R = MAX(0, (1 - D) + (1 - S)) */
    
    case plusLighter /* R = MIN(1, S + D) */
}

extension ColorBlendMode {
    
    @_versioned
    @inline(__always)
    func blend(_ source: Double, _ destination: Double) -> Double {
        
        @inline(__always)
        func Screen(_ source: Double, _ destination: Double) -> Double {
            
            return destination + source - (destination * source)
        }
        
        @inline(__always)
        func ColorDodge(_ source: Double, _ destination: Double) -> Double {
            
            if (source < 1) {
                return min(1, destination / (1 - source))
            }
            return 1
        }
        
        @inline(__always)
        func ColorBurn(_ source: Double, _ destination: Double) -> Double {
            
            if (source > 0) {
                return 1 - min(1, (1 - destination) / source)
            }
            return 0
        }
        
        @inline(__always)
        func SoftLight(_ source: Double, _ destination: Double) -> Double {
            
            let db: Double;
            
            if (destination <= 0.25) {
                db = ((16 * destination - 12) * destination + 4) * destination
            } else {
                db = sqrt(destination)
            }
            
            if (source <= 0.5) {
                return destination - (1 - 2 * source) * destination * (1 - destination)
            }
            return destination + (2 * source - 1) * (db - destination)
        }
        
        @inline(__always)
        func HardLight(_ source: Double, _ destination: Double) -> Double {
            
            if (source <= 0.5) {
                return 2 * source * destination
            }
            return Screen(destination, 2 * source - 1)
        }
        
        switch self {
        case .normal: return source
        case .multiply: return destination * source
        case .screen: return Screen(source, destination)
        case .overlay: return HardLight(destination, source)
        case .darken: return min(destination, source)
        case .lighten: return max(destination, source)
        case .colorDodge: return ColorDodge(source, destination)
        case .colorBurn: return ColorBurn(source, destination)
        case .softLight:  return SoftLight(source, destination)
        case .hardLight: return HardLight(source, destination)
        case .difference: return abs(destination - source)
        case .exclusion: return destination + source - 2 * destination * source
        case .plusDarker: return max(0, 1 - ((1 - destination) + (1 - source)))
        case .plusLighter: return min(1, destination + source)
        }
    }
}

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
    
    @_versioned
    @inline(__always)
    func mix(_ source: Double, _ source_alpha: Double, _ destination: Double, _ destination_alpha: Double) -> Double {
        
        switch self {
        case .clear: return 0
        case .copy: return source
        case .sourceOver: return source + destination * (1 - source_alpha)
        case .sourceIn: return source * destination_alpha
        case .sourceOut: return source * (1 - destination_alpha)
        case .sourceAtop: return source * destination_alpha + destination * (1 - source_alpha)
        case .destinationOver: return source * (1 - destination_alpha) + destination
        case .destinationIn: return destination * source_alpha
        case .destinationOut: return destination * (1 - source_alpha)
        case .destinationAtop: return source * (1 - destination_alpha) + destination * source_alpha
        case .xor: return source * (1 - destination_alpha) + destination * (1 - source_alpha)
        }
    }
}

extension ColorPixelProtocol {
    
    @_inlineable
    public mutating func blend<C : ColorPixelProtocol>(source: C, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) {
        
        let d_alpha = self.opacity
        let s_alpha = source.opacity
        
        let r_alpha = compositingMode.mix(s_alpha, s_alpha, d_alpha, d_alpha)
        
        if r_alpha > 0 {
            
            self.opacity = r_alpha
            
            for i in 0..<Model.count {
                let _source = source.color.component(i)
                let _destination = self.color.component(i)
                let blended = (1 - d_alpha) * _source + d_alpha * blendMode.blend(_source, _destination)
                self.color.setComponent(i, compositingMode.mix(s_alpha * blended, s_alpha, d_alpha * _destination, d_alpha) / r_alpha)
            }
        }
    }
    
    @_inlineable
    public func blended<C : ColorPixelProtocol>(source: C, blendMode: ColorBlendMode, compositingMode: ColorCompositingMode) -> Self {
        var result = self
        result.blend(source: source, blendMode: blendMode, compositingMode: compositingMode)
        return result
    }
}
