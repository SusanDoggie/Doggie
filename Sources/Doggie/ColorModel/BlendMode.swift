//
//  BlendMode.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2019 Susan Cheng. All rights reserved.
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

public enum ColorBlendMode {
    
    case normal /* B(cb, cs) = cs */
    
    case multiply /* B(cb, cs) = cb * cs */
    
    case screen /* B(cb, cs) = cb + cs – cb * cs */
    
    case overlay /* B(cb, cs) = cs < 0.5 ? 2 * cb * cs : 1 - 2 * (1 - cb) * (1 - cs) */
    
    case darken /* B(cb, cs) = min(cb, cs) */
    
    case lighten /* B(cb, cs) = max(cb, cs) */
    
    case colorDodge /* B(cb, cs) = cs < 1 ? min(1, cb / (1 – cs)) : 1 */
    
    case colorBurn /* B(cb, cs) = cs > 0 ? 1 – min(1, (1 – cb) / cs) : 0 */
    
    case softLight /* B(cb, cs) = cs < 0.5 ? cb – (1 – 2 * cs) * cb * (1 – cb) : cb + (2 * cs – 1) * (D(cb) – cb) where D(x) = x < 0.25 ? ((16 * x – 12) * x + 4) * x : sqrt(x) */
    
    case hardLight /* B(cb, cs) = Overlay(cs, cb) */
    
    case difference /* B(cb, cs) = abs(cb – cs) */
    
    case exclusion /* B(cb, cs) = cb + cs – 2 * cb * cs */
    
    case plusDarker /* B(cb, cs) = max(0, 1 - ((1 - cb) + (1 - cs))) */
    
    case plusLighter /* B(cb, cs) = min(1, cb + cs) */
}

extension ColorBlendMode {
    
    @inlinable
    public static var `default` : ColorBlendMode {
        return .normal
    }
}

extension ColorBlendMode {
    
    @inlinable
    @inline(__always)
    static func Multiply<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return destination * source
    }
    
    @inlinable
    @inline(__always)
    static func Screen<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return destination + source - destination * source
    }
    
    @inlinable
    @inline(__always)
    static func Overlay<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        
        if destination < 0.5 {
            return 2 * destination * source
        }
        let u = 1 - destination
        let v = 1 - source
        return 1 - 2 * u * v
    }
    
    @inlinable
    @inline(__always)
    static func Darken<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return min(destination, source)
    }
    
    @inlinable
    @inline(__always)
    static func Lighten<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return max(destination, source)
    }
    
    @inlinable
    @inline(__always)
    static func ColorDodge<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return source < 1 ? min(1, destination / (1 - source)) : 1
    }
    
    @inlinable
    @inline(__always)
    static func ColorBurn<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return source > 0 ? 1 - min(1, (1 - destination) / source) : 0
    }
    
    @inlinable
    @inline(__always)
    static func SoftLight<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        
        let db: T
        
        if destination < 0.25 {
            let s = 16 * destination - 12
            let t = s * destination + 4
            db = t * destination
        } else {
            db = sqrt(destination)
        }
        
        let u = 1 - 2 * source
        
        if source < 0.5 {
            return destination - u * destination * (1 - destination)
        }
        return destination - u * (db - destination)
    }
    
    @inlinable
    @inline(__always)
    static func HardLight<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return Overlay(source, destination)
    }
    
    @inlinable
    @inline(__always)
    static func Difference<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return abs(destination - source)
    }
    
    @inlinable
    @inline(__always)
    static func Exclusion<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return destination + source - 2 * destination * source
    }
    
    @inlinable
    @inline(__always)
    static func PlusDarker<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return max(0, 1 - ((1 - destination) + (1 - source)))
    }
    
    @inlinable
    @inline(__always)
    static func PlusLighter<T: BinaryFloatingPoint>(_ destination: T, _ source: T) -> T {
        return min(1, destination + source)
    }
}

extension ColorModelProtocol {
    
    @inlinable
    @inline(__always)
    public mutating func blend(source: Self, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, blendMode: blendMode)
    }
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, blendMode: ColorBlendMode = .default) -> Self {
        switch blendMode {
        case .normal: return source
        case .multiply: return self.combined(source, ColorBlendMode.Multiply)
        case .screen: return self.combined(source, ColorBlendMode.Screen)
        case .overlay: return self.combined(source, ColorBlendMode.Overlay)
        case .darken: return self.combined(source, ColorBlendMode.Darken)
        case .lighten: return self.combined(source, ColorBlendMode.Lighten)
        case .colorDodge: return self.combined(source, ColorBlendMode.ColorDodge)
        case .colorBurn: return self.combined(source, ColorBlendMode.ColorBurn)
        case .softLight: return self.combined(source, ColorBlendMode.SoftLight)
        case .hardLight: return self.combined(source, ColorBlendMode.HardLight)
        case .difference: return self.combined(source, ColorBlendMode.Difference)
        case .exclusion: return self.combined(source, ColorBlendMode.Exclusion)
        case .plusDarker: return self.combined(source, ColorBlendMode.PlusDarker)
        case .plusLighter: return self.combined(source, ColorBlendMode.PlusLighter)
        }
    }
}

extension FloatColorComponents {
    
    @inlinable
    @inline(__always)
    public mutating func blend(source: Self, blendMode: ColorBlendMode = .default) {
        self = self.blended(source: source, blendMode: blendMode)
    }
    
    @inlinable
    @inline(__always)
    public func blended(source: Self, blendMode: ColorBlendMode = .default) -> Self {
        switch blendMode {
        case .normal: return source
        case .multiply: return self.combined(source, ColorBlendMode.Multiply)
        case .screen: return self.combined(source, ColorBlendMode.Screen)
        case .overlay: return self.combined(source, ColorBlendMode.Overlay)
        case .darken: return self.combined(source, ColorBlendMode.Darken)
        case .lighten: return self.combined(source, ColorBlendMode.Lighten)
        case .colorDodge: return self.combined(source, ColorBlendMode.ColorDodge)
        case .colorBurn: return self.combined(source, ColorBlendMode.ColorBurn)
        case .softLight: return self.combined(source, ColorBlendMode.SoftLight)
        case .hardLight: return self.combined(source, ColorBlendMode.HardLight)
        case .difference: return self.combined(source, ColorBlendMode.Difference)
        case .exclusion: return self.combined(source, ColorBlendMode.Exclusion)
        case .plusDarker: return self.combined(source, ColorBlendMode.PlusDarker)
        case .plusLighter: return self.combined(source, ColorBlendMode.PlusLighter)
        }
    }
}

