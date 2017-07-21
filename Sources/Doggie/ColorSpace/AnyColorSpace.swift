//
//  AnyColorSpace.swift
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

@_versioned
protocol AnyColorSpaceBaseProtocol {
    
    var iccData: Data? { get }
    
    var localizedName: String? { get }
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get set }
    
    var numberOfComponents: Int { get }
    
    func rangeOfComponent(_ i: Int) -> ClosedRange<Double>
    
    var _cieXYZ: ColorSpace<XYZColorModel> { get }
    
    func _createColor<S : Sequence>(components: S, opacity: Double) -> AnyColorBaseProtocol where S.Element == Double
    
    func _createImage(width: Int, height: Int, resolution: Resolution) -> AnyImageBaseProtocol
    
    func _convert<Model>(_ color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol
    
    func _convert<Pixel>(_ image: Image<Pixel>, intent: RenderingIntent) -> AnyImageBaseProtocol
    
    var _linearTone: AnyColorSpaceBaseProtocol { get }
}

extension ColorSpace : AnyColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var _cieXYZ: ColorSpace<XYZColorModel> {
        return ColorSpace<XYZColorModel>.cieXYZ(from: self)
    }
    
    @_versioned
    @_inlineable
    func _createColor<S>(components: S, opacity: Double) -> AnyColorBaseProtocol where S : Sequence, S.Element == Double {
        var color = Model()
        var counter = 0
        for (i, v) in components.enumerated() {
            precondition(i < Model.numberOfComponents, "invalid count of components.")
            color.setComponent(i, v)
            counter = i
        }
        precondition(counter == Model.numberOfComponents - 1, "invalid count of components.")
        return Color(colorSpace: self, color: color, opacity: opacity)
    }
    
    @_versioned
    @_inlineable
    func _createImage(width: Int, height: Int, resolution: Resolution) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self)
    }
    
    @_versioned
    @_inlineable
    func _convert<Model>(_ color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return color.convert(to: self, intent: intent)
    }
    
    @_versioned
    @_inlineable
    func _convert<Pixel>(_ image: Image<Pixel>, intent: RenderingIntent) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(image: image, colorSpace: self, intent: intent)
    }
    
    @_versioned
    @_inlineable
    var _linearTone: AnyColorSpaceBaseProtocol {
        return self.linearTone
    }
}

@_fixed_layout
public struct AnyColorSpace {
    
    @_versioned
    var _base: AnyColorSpaceBaseProtocol
    
    @_versioned
    @_inlineable
    init(base: AnyColorSpaceBaseProtocol) {
        self._base = base
    }
    
    @_inlineable
    public var base: Any {
        return _base
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public init<Model>(_ colorSpace: ColorSpace<Model>) {
        self._base = colorSpace
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public var localizedName: String? {
        return _base.localizedName
    }
}

extension AnyColorSpace : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "\(_base)"
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public var iccData: Data? {
        return _base.iccData
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return _base.chromaticAdaptationAlgorithm
        }
        set {
            _base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @_inlineable
    public var numberOfComponents: Int {
        return _base.numberOfComponents
    }
    
    @_inlineable
    public func rangeOfComponent(_ i: Int) -> ClosedRange<Double> {
        return _base.rangeOfComponent(i)
    }
    
    @_inlineable
    public var linearTone: AnyColorSpace {
        return AnyColorSpace(base: _base._linearTone)
    }
}

extension ColorSpace where Model == XYZColorModel {
    
    @_inlineable
    public static func cieXYZ(from colorSpace: AnyColorSpace) -> ColorSpace {
        return colorSpace._base._cieXYZ
    }
}

extension ColorSpace where Model == LabColorModel {
    
    @_inlineable
    public static func cieLab(from colorSpace: AnyColorSpace) -> ColorSpace {
        return ColorSpace.cieLab(from: colorSpace._base._cieXYZ)
    }
}

extension ColorSpace where Model == LuvColorModel {
    
    @_inlineable
    public static func cieLuv(from colorSpace: AnyColorSpace) -> ColorSpace {
        return ColorSpace.cieLuv(from: colorSpace._base._cieXYZ)
    }
}

extension ColorSpace where Model == GrayColorModel {
    
    @_inlineable
    public static func calibratedGray(from colorSpace: AnyColorSpace) -> ColorSpace {
        return ColorSpace.calibratedGray(from: colorSpace._base._cieXYZ)
    }
}

