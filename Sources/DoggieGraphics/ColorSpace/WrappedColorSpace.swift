//
//  WrappedColorSpace.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2020 Susan Cheng. All rights reserved.
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

extension ColorSpace {
    
    @inlinable
    public static func wrapped<Base>(base: ColorSpace<Base>, convertFromBase: @escaping (Base) -> Model, convertToBase: @escaping (Model) -> Base) -> ColorSpace {
        return ColorSpace(base: WrappedColorSpace(base, convertFromBase, convertToBase))
    }
}

@frozen
@usableFromInline
struct WrappedColorSpace<Model: ColorModel, Base: ColorModel>: ColorSpaceBaseProtocol {
    
    @usableFromInline
    let token = UUID()
    
    @usableFromInline
    let base: _ColorSpaceBaseProtocol
    
    @usableFromInline
    let convertFromBase: (Base) -> Model
    
    @usableFromInline
    let convertToBase: (Model) -> Base
    
    @inlinable
    init(_ base: ColorSpace<Base>, _ convertFromBase: @escaping (Base) -> Model, _ convertToBase: @escaping (Model) -> Base) {
        self.base = base.base
        self.convertFromBase = convertFromBase
        self.convertToBase = convertToBase
    }
}

extension WrappedColorSpace {
    
    @usableFromInline
    var cieXYZ: CIEXYZColorSpace {
        return base.cieXYZ
    }
}

extension WrappedColorSpace {
    
    @inlinable
    var localizedName: String? {
        return "WrappedColorSpace(base: \(base)))"
    }
}

extension WrappedColorSpace {
    
    @inlinable
    func hash(into hasher: inout Hasher) {
        hasher.combine("WrappedColorSpace")
        hasher.combine(token)
        base.hash(into: &hasher)
    }
    
    @inlinable
    static func ==(lhs: WrappedColorSpace, rhs: WrappedColorSpace) -> Bool {
        return lhs.token == rhs.token && lhs.base.isEqual(rhs.base)
    }
    
    @inlinable
    func isStorageEqual(_ other: _ColorSpaceBaseProtocol) -> Bool {
        guard let other = other as? WrappedColorSpace else { return false }
        return self.token == other.token && self.base.isStorageEqual(other.base)
    }
}

extension WrappedColorSpace {
    
    @inlinable
    var linearTone: WrappedColorSpace {
        return self
    }
}

extension WrappedColorSpace {
    
    @inlinable
    func convertToLinear(_ color: Model) -> Model {
        return color
    }
    
    @inlinable
    func convertFromLinear(_ color: Model) -> Model {
        return color
    }
    
    @inlinable
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel {
        return base._convertToXYZ(convertToBase(color))
    }
    
    @inlinable
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model {
        return convertFromBase(base._convertFromXYZ(color))
    }
}

