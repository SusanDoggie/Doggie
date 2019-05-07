//
//  AnyColorSpace.swift
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

@usableFromInline
protocol AnyColorSpaceBaseProtocol: PolymorphicHashable {
    
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
    
    func _create_color<S : Sequence>(components: S, opacity: Double) -> AnyColorBaseProtocol where S.Element == Double
    
    func _create_image(width: Int, height: Int, resolution: Resolution, fileBacked: Bool) -> AnyImageBaseProtocol
    
    func _create_image<P>(image: Image<P>, intent: RenderingIntent) -> AnyImageBaseProtocol
    
    func _create_image(image: AnyImage, intent: RenderingIntent) -> AnyImageBaseProtocol
    
    func _create_image(width: Int, height: Int, resolution: Resolution, bitmaps: [RawBitmap], premultiplied: Bool, fileBacked: Bool) -> AnyImageBaseProtocol
    
    func _convert<Model>(color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol
    
    func _isStorageEqual(_ other: AnyColorSpaceBaseProtocol) -> Bool
}

extension ColorSpace : AnyColorSpaceBaseProtocol {
    
    @inlinable
    var _linearTone: AnyColorSpaceBaseProtocol {
        return self
    }
    
    @inlinable
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
    
    @inlinable
    func _create_image(width: Int, height: Int, resolution: Resolution, fileBacked: Bool) -> AnyImageBaseProtocol {
        return Image<Float64ColorPixel<Model>>(width: width, height: height, resolution: resolution, colorSpace: self, fileBacked: fileBacked)
    }
    
    @inlinable
    func _create_image<P>(image: Image<P>, intent: RenderingIntent) -> AnyImageBaseProtocol {
        return Image<Float64ColorPixel<Model>>(image: image, colorSpace: self, intent: intent)
    }
    
    @inlinable
    func _create_image(image: AnyImage, intent: RenderingIntent) -> AnyImageBaseProtocol {
        return Image<Float64ColorPixel<Model>>(image: image, colorSpace: self, intent: intent)
    }
    
    @inlinable
    func _convert<Model>(color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return color.convert(to: self, intent: intent)
    }
    
    @inlinable
    func _isStorageEqual(_ other: AnyColorSpaceBaseProtocol) -> Bool {
        guard let other = other as? ColorSpace else { return false }
        return self.isStorageEqual(other)
    }
}

@_fixed_layout
public struct AnyColorSpace : ColorSpaceProtocol, Hashable {

    @usableFromInline
    var _base: AnyColorSpaceBaseProtocol
    
    @inlinable
    init(base: AnyColorSpaceBaseProtocol) {
        self._base = base
    }
    
    @inlinable
    public var base: Any {
        return _base
    }
}

extension AnyColorSpace {
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        _base.hash(into: &hasher)
    }
    
    @inlinable
    public static func ==(lhs: AnyColorSpace, rhs: AnyColorSpace) -> Bool {
        return lhs._base.isEqual(rhs._base)
    }
    
    @inlinable
    public func isStorageEqual(_ other: AnyColorSpace) -> Bool {
        return _base._isStorageEqual(other._base)
    }
}

extension AnyColorSpace {
    
    @inlinable
    public init<Model>(_ colorSpace: ColorSpace<Model>) {
        self._base = colorSpace
    }
    
    @inlinable
    public init(_ colorSpace: AnyColorSpace) {
        self = colorSpace
    }
}

extension AnyColorSpace {
    
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
        return AnyColorSpace(base: _base._linearTone)
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

extension AnyColorSpace : CustomStringConvertible {
    
    @inlinable
    public var description: String {
        return "\(_base)"
    }
}

