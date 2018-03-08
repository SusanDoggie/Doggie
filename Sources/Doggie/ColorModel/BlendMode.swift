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
    
    @_inlineable
    public static var `default` : ColorBlendMode {
        return .normal
    }
}

@_versioned
@inline(__always)
func ColorBlendMultiply(_ destination: Double, _ source: Double) -> Double {
    return destination * source
}

@_versioned
@inline(__always)
func ColorBlendScreen(_ destination: Double, _ source: Double) -> Double {
    return destination + source - destination * source
}

@_versioned
@inline(__always)
func ColorBlendOverlay(_ destination: Double, _ source: Double) -> Double {
    
    if destination < 0.5 {
        return 2 * destination * source
    }
    let u = 1 - destination
    let v = 1 - source
    return 1 - 2 * u * v
}

@_versioned
@inline(__always)
func ColorBlendDarken(_ destination: Double, _ source: Double) -> Double {
    return min(destination, source)
}

@_versioned
@inline(__always)
func ColorBlendLighten(_ destination: Double, _ source: Double) -> Double {
    return max(destination, source)
}

@_versioned
@inline(__always)
func ColorBlendColorDodge(_ destination: Double, _ source: Double) -> Double {
    return source < 1 ? min(1, destination / (1 - source)) : 1
}

@_versioned
@inline(__always)
func ColorBlendColorBurn(_ destination: Double, _ source: Double) -> Double {
    return source > 0 ? 1 - min(1, (1 - destination) / source) : 0
}

@_versioned
@inline(__always)
func ColorBlendSoftLight(_ destination: Double, _ source: Double) -> Double {
    
    let db: Double
    
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

@_versioned
@inline(__always)
func ColorBlendHardLight(_ destination: Double, _ source: Double) -> Double {
    return ColorBlendOverlay(source, destination)
}

@_versioned
@inline(__always)
func ColorBlendDifference(_ destination: Double, _ source: Double) -> Double {
    return abs(destination - source)
}

@_versioned
@inline(__always)
func ColorBlendExclusion(_ destination: Double, _ source: Double) -> Double {
    return destination + source - 2 * destination * source
}

@_versioned
@inline(__always)
func ColorBlendPlusDarker(_ destination: Double, _ source: Double) -> Double {
    return max(0, 1 - ((1 - destination) + (1 - source)))
}

@_versioned
@inline(__always)
func ColorBlendPlusLighter(_ destination: Double, _ source: Double) -> Double {
    return min(1, destination + source)
}

@_versioned
@inline(__always)
func ColorBlendMultiply(_ destination: Float, _ source: Float) -> Float {
    return destination * source
}

@_versioned
@inline(__always)
func ColorBlendScreen(_ destination: Float, _ source: Float) -> Float {
    return destination + source - destination * source
}

@_versioned
@inline(__always)
func ColorBlendOverlay(_ destination: Float, _ source: Float) -> Float {
    
    if destination < 0.5 {
        return 2 * destination * source
    }
    let u = 1 - destination
    let v = 1 - source
    return 1 - 2 * u * v
}

@_versioned
@inline(__always)
func ColorBlendDarken(_ destination: Float, _ source: Float) -> Float {
    return min(destination, source)
}

@_versioned
@inline(__always)
func ColorBlendLighten(_ destination: Float, _ source: Float) -> Float {
    return max(destination, source)
}

@_versioned
@inline(__always)
func ColorBlendColorDodge(_ destination: Float, _ source: Float) -> Float {
    return source < 1 ? min(1, destination / (1 - source)) : 1
}

@_versioned
@inline(__always)
func ColorBlendColorBurn(_ destination: Float, _ source: Float) -> Float {
    return source > 0 ? 1 - min(1, (1 - destination) / source) : 0
}

@_versioned
@inline(__always)
func ColorBlendSoftLight(_ destination: Float, _ source: Float) -> Float {
    
    let db: Float
    
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

@_versioned
@inline(__always)
func ColorBlendHardLight(_ destination: Float, _ source: Float) -> Float {
    return ColorBlendOverlay(source, destination)
}

@_versioned
@inline(__always)
func ColorBlendDifference(_ destination: Float, _ source: Float) -> Float {
    return abs(destination - source)
}

@_versioned
@inline(__always)
func ColorBlendExclusion(_ destination: Float, _ source: Float) -> Float {
    return destination + source - 2 * destination * source
}

@_versioned
@inline(__always)
func ColorBlendPlusDarker(_ destination: Float, _ source: Float) -> Float {
    return max(0, 1 - ((1 - destination) + (1 - source)))
}

@_versioned
@inline(__always)
func ColorBlendPlusLighter(_ destination: Float, _ source: Float) -> Float {
    return min(1, destination + source)
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
        case .multiply: return self.blended(source: source, blending: ColorBlendMultiply)
        case .screen: return self.blended(source: source, blending: ColorBlendScreen)
        case .overlay: return self.blended(source: source, blending: ColorBlendOverlay)
        case .darken: return self.blended(source: source, blending: ColorBlendDarken)
        case .lighten: return self.blended(source: source, blending: ColorBlendLighten)
        case .colorDodge: return self.blended(source: source, blending: ColorBlendColorDodge)
        case .colorBurn: return self.blended(source: source, blending: ColorBlendColorBurn)
        case .softLight: return self.blended(source: source, blending: ColorBlendSoftLight)
        case .hardLight: return self.blended(source: source, blending: ColorBlendHardLight)
        case .difference: return self.blended(source: source, blending: ColorBlendDifference)
        case .exclusion: return self.blended(source: source, blending: ColorBlendExclusion)
        case .plusDarker: return self.blended(source: source, blending: ColorBlendPlusDarker)
        case .plusLighter: return self.blended(source: source, blending: ColorBlendPlusLighter)
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
        case .multiply: return self.blended(source: source, blending: ColorBlendMultiply)
        case .screen: return self.blended(source: source, blending: ColorBlendScreen)
        case .overlay: return self.blended(source: source, blending: ColorBlendOverlay)
        case .darken: return self.blended(source: source, blending: ColorBlendDarken)
        case .lighten: return self.blended(source: source, blending: ColorBlendLighten)
        case .colorDodge: return self.blended(source: source, blending: ColorBlendColorDodge)
        case .colorBurn: return self.blended(source: source, blending: ColorBlendColorBurn)
        case .softLight: return self.blended(source: source, blending: ColorBlendSoftLight)
        case .hardLight: return self.blended(source: source, blending: ColorBlendHardLight)
        case .difference: return self.blended(source: source, blending: ColorBlendDifference)
        case .exclusion: return self.blended(source: source, blending: ColorBlendExclusion)
        case .plusDarker: return self.blended(source: source, blending: ColorBlendPlusDarker)
        case .plusLighter: return self.blended(source: source, blending: ColorBlendPlusLighter)
        }
    }
}

