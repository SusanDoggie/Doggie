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

@_versioned
protocol AnyColorSpaceBaseProtocol {
    
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get set }
    
    func createColor<S : Sequence>(components: S) -> AnyColorBaseProtocol where S.Element == Double
    
    func createImage(width: Int, height: Int) -> AnyImageBaseProtocol
    
    func convert<Model>(_ color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol
    
    func convert<Pixel>(_ image: Image<Pixel>, intent: RenderingIntent) -> AnyImageBaseProtocol
    
    var normalized: AnyColorSpaceBaseProtocol { get }
    
    var linearTone: AnyColorSpaceBaseProtocol { get }
    
    var white: XYZColorModel { get }
    
    var black: XYZColorModel { get }
}

@_versioned
@_fixed_layout
struct AnyColorSpaceBase<Model : ColorModelProtocol> : AnyColorSpaceBaseProtocol {
    
    @_versioned
    var base : ColorSpace<Model>
    
    @_versioned
    @_inlineable
    init(base: ColorSpace<Model>) {
        self.base = base
    }
    
    @_versioned
    @_inlineable
    var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return base.chromaticAdaptationAlgorithm
        }
        set {
            base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @_versioned
    @_inlineable
    func createColor<S : Sequence>(components: S) -> AnyColorBaseProtocol where S.Element == Double {
        
        var opacity = 0.0
        var color = Model()
        for (i, v) in components.enumerated() {
            switch i {
            case 0..<Model.count: color.setComponent(i, v)
            case Model.count: opacity = v
            default: fatalError()
            }
        }
        return AnyColorBase(base: Color<Model>(colorSpace: base, color: color, opacity: opacity))
    }
    
    @_versioned
    @_inlineable
    func createImage(width: Int, height: Int) -> AnyImageBaseProtocol {
        return AnyImageBase(base: Image<ColorPixel<Model>>(width: width, height: height, colorSpace: base))
    }
    
    @_versioned
    @_inlineable
    func convert<Model>(_ color: Color<Model>, intent: RenderingIntent) -> AnyColorBaseProtocol {
        return AnyColorBase(base: color.convert(to: base, intent: intent))
    }
    
    @_versioned
    @_inlineable
    func convert<Pixel>(_ image: Image<Pixel>, intent: RenderingIntent) -> AnyImageBaseProtocol {
        return AnyImageBase(base: Image<ColorPixel<Model>>(image: image, colorSpace: base, intent: intent))
    }
    
    @_versioned
    @_inlineable
    var normalized: AnyColorSpaceBaseProtocol {
        return AnyColorSpaceBase(base: base.normalized)
    }
    
    @_versioned
    @_inlineable
    var linearTone: AnyColorSpaceBaseProtocol {
        return AnyColorSpaceBase(base: base.linearTone)
    }
    
    @_versioned
    @_inlineable
    var white: XYZColorModel {
        return base.white
    }
    
    @_versioned
    @_inlineable
    var black: XYZColorModel {
        return base.black
    }
}

@_fixed_layout
public struct AnyColorSpace {
    
    @_versioned
    var base: AnyColorSpaceBaseProtocol
    
    @_versioned
    @_inlineable
    init(base: AnyColorSpaceBaseProtocol) {
        self.base = base
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public init<Model>(_ colorSpace: ColorSpace<Model>) {
        self.base = AnyColorSpaceBase(base: colorSpace)
    }
}

extension AnyColorSpace {
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return base.chromaticAdaptationAlgorithm
        }
        set {
            base.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    @_inlineable
    public var normalized: AnyColorSpace {
        return AnyColorSpace(base: base.normalized)
    }
    
    @_inlineable
    public var linearTone: AnyColorSpace {
        return AnyColorSpace(base: base.linearTone)
    }
    
    @_inlineable
    public var white: XYZColorModel {
        return base.white
    }
    
    @_inlineable
    public var black: XYZColorModel {
        return base.black
    }
}

