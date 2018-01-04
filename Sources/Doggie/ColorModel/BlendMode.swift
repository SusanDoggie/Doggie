//
//  BlendMode.swift
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
    
    @_inlineable
    public static var `default` : ColorBlendMode {
        return .normal
    }
}

extension ColorBlendMode {
    
    @_versioned
    @inline(__always)
    static func Multiply<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return destination * source
    }
    
    @_versioned
    @inline(__always)
    static func Screen<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return destination + source - (destination * source)
    }
    
    @_versioned
    @inline(__always)
    static func Overlay<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return HardLight(destination, source)
    }
    
    @_versioned
    @inline(__always)
    static func Darken<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return min(destination, source)
    }
    
    @_versioned
    @inline(__always)
    static func Lighten<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return max(destination, source)
    }
    
    @_versioned
    @inline(__always)
    static func ColorDodge<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        if source < 1 {
            return min(1, destination / (1 - source))
        }
        return 1
    }
    
    @_versioned
    @inline(__always)
    static func ColorBurn<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        if source > 0 {
            return 1 - min(1, (1 - destination) / source)
        }
        return 0
    }
    
    @_versioned
    @inline(__always)
    static func SoftLight<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        let db: T
        
        if destination <= 0.25 {
            let s = 16 * destination - 12
            let t = s * destination + 4
            db = t * destination
        } else {
            db = sqrt(destination)
        }
        
        let u = 1 - 2 * source
        
        if source <= 0.5 {
            return destination - u * destination * (1 - destination)
        }
        return destination - u * (db - destination)
    }
    
    @_versioned
    @inline(__always)
    static func HardLight<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        if source <= 0.5 {
            return 2 * source * destination
        }
        return Screen(destination, 2 * source - 1)
    }
    
    @_versioned
    @inline(__always)
    static func Difference<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return abs(destination - source)
    }
    
    @_versioned
    @inline(__always)
    static func Exclusion<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return destination + source - 2 * destination * source
    }
    
    @_versioned
    @inline(__always)
    static func PlusDarker<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return max(0, 1 - ((1 - destination) + (1 - source)))
    }
    
    @_versioned
    @inline(__always)
    static func PlusLighter<T: BinaryFloatingPoint>(_ source: T, _ destination: T) -> T {
        
        return min(1, destination + source)
    }
}

extension ColorModelProtocol {
    
    @_transparent
    public mutating func blend(source: Self, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, blendMode: blendMode)
    }
    
    @_transparent
    public func blended(source: Self, blendMode: ColorBlendMode) -> Self {
        switch blendMode {
        case .normal: return source
        case .multiply: return self.blended(source: source, blending: ColorBlendMode.Multiply)
        case .screen: return self.blended(source: source, blending: ColorBlendMode.Screen)
        case .overlay: return self.blended(source: source, blending: ColorBlendMode.Overlay)
        case .darken: return self.blended(source: source, blending: ColorBlendMode.Darken)
        case .lighten: return self.blended(source: source, blending: ColorBlendMode.Lighten)
        case .colorDodge: return self.blended(source: source, blending: ColorBlendMode.ColorDodge)
        case .colorBurn: return self.blended(source: source, blending: ColorBlendMode.ColorBurn)
        case .softLight: return self.blended(source: source, blending: ColorBlendMode.SoftLight)
        case .hardLight: return self.blended(source: source, blending: ColorBlendMode.HardLight)
        case .difference: return self.blended(source: source, blending: ColorBlendMode.Difference)
        case .exclusion: return self.blended(source: source, blending: ColorBlendMode.Exclusion)
        case .plusDarker: return self.blended(source: source, blending: ColorBlendMode.PlusDarker)
        case .plusLighter: return self.blended(source: source, blending: ColorBlendMode.PlusLighter)
        }
    }
}

extension FloatColorComponents {
    
    @_transparent
    public mutating func blend(source: Self, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, blendMode: blendMode)
    }
    
    @_transparent
    public func blended(source: Self, blendMode: ColorBlendMode) -> Self {
        switch blendMode {
        case .normal: return source
        case .multiply: return self.blended(source: source, blending: ColorBlendMode.Multiply)
        case .screen: return self.blended(source: source, blending: ColorBlendMode.Screen)
        case .overlay: return self.blended(source: source, blending: ColorBlendMode.Overlay)
        case .darken: return self.blended(source: source, blending: ColorBlendMode.Darken)
        case .lighten: return self.blended(source: source, blending: ColorBlendMode.Lighten)
        case .colorDodge: return self.blended(source: source, blending: ColorBlendMode.ColorDodge)
        case .colorBurn: return self.blended(source: source, blending: ColorBlendMode.ColorBurn)
        case .softLight: return self.blended(source: source, blending: ColorBlendMode.SoftLight)
        case .hardLight: return self.blended(source: source, blending: ColorBlendMode.HardLight)
        case .difference: return self.blended(source: source, blending: ColorBlendMode.Difference)
        case .exclusion: return self.blended(source: source, blending: ColorBlendMode.Exclusion)
        case .plusDarker: return self.blended(source: source, blending: ColorBlendMode.PlusDarker)
        case .plusLighter: return self.blended(source: source, blending: ColorBlendMode.PlusLighter)
        }
    }
}

