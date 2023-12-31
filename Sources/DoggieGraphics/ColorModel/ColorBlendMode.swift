//
//  ColorBlendMode.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2024 Susan Cheng. All rights reserved.
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
public struct ColorBlendMode: Hashable {
    
    @usableFromInline
    var rawValue: ColorBlendKernel.Type
    
    @inlinable
    init(rawValue: ColorBlendKernel.Type) {
        self.rawValue = rawValue
    }
}

extension ColorBlendMode {
    
    @inlinable
    public var identifier: ObjectIdentifier {
        return ObjectIdentifier(rawValue)
    }
    
    @inlinable
    public static func == (lhs: ColorBlendMode, rhs: ColorBlendMode) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension ColorBlendMode {
    
    @inlinable
    @inline(__always)
    public static var `default`: ColorBlendMode {
        return .normal
    }
}

extension ColorBlendMode {
    
    /// B(cb, cs) = cs
    public static let normal = ColorBlendMode(rawValue: NormalBlendKernel.self)
    
    /// B(cb, cs) = cb * cs
    public static let multiply = ColorBlendMode(rawValue: MultiplyBlendKernel.self)
    
    /// B(cb, cs) = cb + cs - cb * cs
    public static let screen = ColorBlendMode(rawValue: ScreenBlendKernel.self)
    
    /// B(cb, cs) = cb < 0.5 ? 2 * cb * cs : 1 - 2 * (1 - cb) * (1 - cs)
    public static let overlay = ColorBlendMode(rawValue: OverlayBlendKernel.self)
    
    /// B(cb, cs) = min(cb, cs)
    public static let darken = ColorBlendMode(rawValue: DarkenBlendKernel.self)
    
    /// B(cb, cs) = max(cb, cs)
    public static let lighten = ColorBlendMode(rawValue: LightenBlendKernel.self)
    
    /// B(cb, cs) = cs < 1 ? min(1, cb / (1 - cs)) : 1
    public static let colorDodge = ColorBlendMode(rawValue: ColorDodgeBlendKernel.self)
    
    /// B(cb, cs) = cs > 0 ? 1 - min(1, (1 - cb) / cs) : 0
    public static let colorBurn = ColorBlendMode(rawValue: ColorBurnBlendKernel.self)
    
    /// B(cb, cs) = cs < 0.5 ? cb - (1 - 2 * cs) * cb * (1 - cb) : cb + (2 * cs - 1) * (D(cb) - cb)
    /// where D(x) = x < 0.25 ? ((16 * x - 12) * x + 4) * x : sqrt(x)
    public static let softLight = ColorBlendMode(rawValue: SoftLightBlendKernel.self)
    
    /// B(cb, cs) = Overlay(cs, cb)
    public static let hardLight = ColorBlendMode(rawValue: HardLightBlendKernel.self)
    
    /// B(cb, cs) = abs(cb - cs)
    public static let difference = ColorBlendMode(rawValue: DifferenceBlendKernel.self)
    
    /// B(cb, cs) = cb + cs - 2 * cb * cs
    public static let exclusion = ColorBlendMode(rawValue: ExclusionBlendKernel.self)
    
    /// B(cb, cs) = max(0, 1 - ((1 - cb) + (1 - cs)))
    public static let plusDarker = ColorBlendMode(rawValue: PlusDarkerBlendKernel.self)
    
    /// B(cb, cs) = min(1, cb + cs)
    public static let plusLighter = ColorBlendMode(rawValue: PlusLighterBlendKernel.self)
}
