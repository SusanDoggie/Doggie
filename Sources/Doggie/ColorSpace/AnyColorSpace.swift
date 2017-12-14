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
    
    var cieXYZ: ColorSpace<XYZColorModel> { get }
    
    var _linearTone: AnyColorSpaceBaseProtocol { get }
    
    var referenceWhite: XYZColorModel { get }
    
    var referenceBlack: XYZColorModel { get }
    
    var luminance: Double { get }
    
    var hashValue: Int { get }
    
    func isEqualTo(_ other: AnyColorSpaceBaseProtocol) -> Bool
    
    func _create_color<S : Sequence>(components: S, opacity: Double) -> AnyColorBaseProtocol where S.Element == Double
    
    func _create_image(width: Int, height: Int, resolution: Resolution, option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _create_image<P>(image: Image<P>, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _create_image(image: AnyImage, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, option: MappedBufferOption) -> AnyImageBaseProtocol
    
    func _convert<Model>(color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol
}

extension AnyColorSpaceBaseProtocol where Self : Equatable {
    
    @_versioned
    @_inlineable
    func isEqualTo(_ other: AnyColorSpaceBaseProtocol) -> Bool {
        guard let other = other as? Self else { return false }
        return self == other
    }
}

extension ColorSpace : AnyColorSpaceBaseProtocol {
    
    @_versioned
    @_inlineable
    var _linearTone: AnyColorSpaceBaseProtocol {
        return self
    }
    
    @_versioned
    @_inlineable
    func _create_color<S>(components: S, opacity: Double) -> AnyColorBaseProtocol where S : Sequence, S.Element == Double {
        var color = Model()
        var counter = 0
        for (i, v) in components.enumerated() {
            precondition(i < Model.numberOfComponents, "invalid count of components.")
            color[i] = v
            counter = i
        }
        precondition(counter == Model.numberOfComponents - 1, "invalid count of components.")
        return Color(colorSpace: self, color: color, opacity: opacity)
    }
    
    @_versioned
    @_inlineable
    func _create_image(width: Int, height: Int, resolution: Resolution, option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, option: option)
    }
    
    @_versioned
    @_inlineable
    func _create_image<P>(image: Image<P>, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(image: image, colorSpace: self, intent: intent, option: option)
    }
    
    @_versioned
    @_inlineable
    func _create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, bitmaps: bitmaps, premultiplied: premultiplied, option: option)
    }
    
    @_versioned
    @_inlineable
    func _create_image(image: AnyImage, intent: RenderingIntent, option: MappedBufferOption) -> AnyImageBaseProtocol {
        return Image<ColorPixel<Model>>(image: image, colorSpace: self, intent: intent, option: option)
    }
    
    @_versioned
    @_inlineable
    func _convert<Model>(color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return color.convert(to: self, intent: intent)
    }
}

@_fixed_layout
public struct AnyColorSpace : ColorSpaceProtocol, Hashable {

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
    public var hashValue: Int {
        return _base.hashValue
    }
    
    @_inlineable
    public static func ==(lhs: AnyColorSpace, rhs: AnyColorSpace) -> Bool {
        return lhs._base.isEqualTo(rhs._base)
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public init<Model>(_ colorSpace: ColorSpace<Model>) {
        self._base = colorSpace
    }
    
    @_inlineable
    public init(_ colorSpace: AnyColorSpace) {
        self = colorSpace
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public var iccData: Data? {
        return _base.iccData
    }
    
    @_inlineable
    public var localizedName: String? {
        return _base.localizedName
    }
    
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
    public var cieXYZ: ColorSpace<XYZColorModel> {
        return _base.cieXYZ
    }
    
    @_inlineable
    public var linearTone: AnyColorSpace {
        return AnyColorSpace(base: _base._linearTone)
    }
    
    @_inlineable
    public var referenceWhite: XYZColorModel {
        return _base.referenceWhite
    }
    
    @_inlineable
    public var referenceBlack: XYZColorModel {
        return _base.referenceBlack
    }
    
    @_inlineable
    public var luminance: Double {
        return _base.luminance
    }
}

extension AnyColorSpace : CustomStringConvertible {
    
    @_inlineable
    public var description: String {
        return "\(_base)"
    }
}

