//
//  AnyColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2025 Susan Cheng. All rights reserved.
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
public struct AnyColorSpace: ColorSpaceProtocol {
    
    @usableFromInline
    var _base: any _ColorSpaceProtocol
    
    @inlinable
    init(base colorSpace: any _ColorSpaceProtocol) {
        self._base = colorSpace
    }
    
    @inlinable
    public init(_ colorSpace: AnyColorSpace) {
        self = colorSpace
    }
    
    @inlinable
    public init<Model>(_ colorSpace: ColorSpace<Model>) {
        self._base = colorSpace
    }
}

extension AnyColorSpace {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyColorSpace, rhs: AnyColorSpace) -> Bool {
        return lhs._base._equalTo(rhs._base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: AnyColorSpace) -> Bool {
        return _base._isStorageEqual(other._base)
    }
}

extension AnyColorSpace {
    
    @inlinable
    public var base: any ColorSpaceProtocol {
        return self._base
    }
    
    @inlinable
    public var model: any ColorModel.Type {
        return _base.model
    }
    
    @inlinable
    public var iccData: Data? {
        return _base.iccData
    }
    
    @inlinable
    public var localizedName: String? {
        return _base.localizedName
    }
    
    @inlinable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return _base.chromaticAdaptationAlgorithm
        }
        set {
            _base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return _base.numberOfComponents
    }
    
    @inlinable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return _base.rangeOfComponent(i)
    }
    
    @inlinable
    public var cieXYZ: ColorSpace<XYZColorModel> {
        return _base.cieXYZ
    }
    
    @inlinable
    public var linearTone: AnyColorSpace {
        return AnyColorSpace(base: _base.linearTone)
    }
    
    @inlinable
    public var referenceWhite: XYZColorModel {
        return _base.referenceWhite
    }
    
    @inlinable
    public var referenceBlack: XYZColorModel {
        return _base.referenceBlack
    }
    
    @inlinable
    public var luminance: Double {
        return _base.luminance
    }
}

extension AnyColorSpace: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(_base)"
    }
}

