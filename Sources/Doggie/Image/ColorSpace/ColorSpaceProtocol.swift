//
//  ColorSpaceProtocol.swift
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

public enum ChromaticAdaptationAlgorithm {
    case xyzScaling
    case vonKries
    case bradford
    case other(Matrix)
}

extension ChromaticAdaptationAlgorithm {
    
    @_inlineable
    public static var `default` : ChromaticAdaptationAlgorithm {
        return .bradford
    }
}

public protocol ColorSpaceProtocol {
    
    associatedtype Model : ColorModelProtocol
    
    var cieXYZ: CIEXYZColorSpace { get }
    
    var white: XYZColorModel { get }
    
    var black: XYZColorModel { get }
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get }
    
    func convertToLinear(_ color: Model) -> Model
    
    func convertFromLinear(_ color: Model) -> Model
    
    func convertLinearToXYZ(_ color: Model) -> XYZColorModel
    
    func convertLinearFromXYZ(_ color: XYZColorModel) -> Model
    
    func convertToXYZ(_ color: Model) -> XYZColorModel
    
    func convertFromXYZ(_ color: XYZColorModel) -> Model
    
    func convert<C : ColorSpaceProtocol>(_ color: Model, to other: C) -> C.Model
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public var white: XYZColorModel {
        return cieXYZ.white
    }
    
    @_inlineable
    public var black: XYZColorModel {
        return cieXYZ.black
    }
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public func convertToXYZ(_ color: Model) -> XYZColorModel {
        return self.convertLinearToXYZ(self.convertToLinear(color))
    }
    
    @_inlineable
    public func convertFromXYZ(_ color: XYZColorModel) -> Model {
        return self.convertFromLinear(self.convertLinearFromXYZ(color))
    }
}

extension ColorSpaceProtocol {
    
    @_inlineable
    public func convert<C : ColorSpaceProtocol>(_ color: Model, to other: C) -> C.Model {
        return other.convertFromXYZ(self.convertToXYZ(color) * self.cieXYZ.transferMatrix(to: other.cieXYZ, chromaticAdaptationAlgorithm: chromaticAdaptationAlgorithm))
    }
}

extension ColorSpaceProtocol {
    
    @_versioned
    @_inlineable
    func exteneded(_ x: Double, _ gamma: (Double) -> Double) -> Double {
        return x.sign == .plus ? gamma(x) : -gamma(-x)
    }
}
