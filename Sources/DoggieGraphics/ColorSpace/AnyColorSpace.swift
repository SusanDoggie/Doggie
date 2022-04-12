//
//  AnyColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2022 Susan Cheng. All rights reserved.
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
    var base: any ColorSpaceProtocol
    
    @inlinable
    public init(_ colorSpace: any ColorSpaceProtocol) {
        if let colorSpace = colorSpace as? AnyColorSpace {
            self = colorSpace
        } else {
            self.base = colorSpace
        }
    }
}

extension AnyColorSpace {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyColorSpace, rhs: AnyColorSpace) -> Bool {
        return lhs.base._equalTo(rhs.base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: AnyColorSpace) -> Bool {
        return base._isStorageEqual(other.base)
    }
}

extension AnyColorSpace {
    
    @inlinable
    public var model: any ColorModel.Type {
        return base.model
    }
    
    @inlinable
    public var iccData: Data? {
        return base.iccData
    }
    
    @inlinable
    public var localizedName: String? {
        return base.localizedName
    }
    
    @inlinable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return base.chromaticAdaptationAlgorithm
        }
        set {
            base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @inlinable
    public var numberOfComponents: Int {
        return base.numberOfComponents
    }
    
    @inlinable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return base.rangeOfComponent(i)
    }
    
    @inlinable
    public var cieXYZ: ColorSpace<XYZColorModel> {
        return base.cieXYZ
    }
    
    @inlinable
    public var linearTone: AnyColorSpace {
        return AnyColorSpace(base.linearTone)
    }
    
    @inlinable
    public var referenceWhite: XYZColorModel {
        return base.referenceWhite
    }
    
    @inlinable
    public var referenceBlack: XYZColorModel {
        return base.referenceBlack
    }
    
    @inlinable
    public var luminance: Double {
        return base.luminance
    }
}

extension AnyColorSpace: CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(base)"
    }
}

