//
//  ImageContext.swift
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

public class ImageContext<ColorSpace : ColorSpaceProtocol> {
    
    var clip: Image<CalibratedGrayColorSpace, ColorPixel<GrayColorModel>>
    
    var _image: Image<ColorSpace, ColorPixel<ColorSpace.Model>>
    
    var stencil: [Int] = []
    
    public var antialias: Bool = true
    
    public var resamplingAlgorithm: ResamplingAlgorithm = .linear
    
    public var opacity: Double = 1
    public var blendMode: ColorBlendMode = .normal
    public var compositingMode: ColorCompositingMode = .sourceOver
    
    public var transform: SDTransform = SDTransform.identity
    
    var next: ImageContext<ColorSpace>?
    
    public init(width: Int, height: Int, colorSpace: ColorSpace) {
        
        _image = Image(width: width, height: height, colorSpace: colorSpace, pixel: ColorPixel<ColorSpace.Model>())
        self.clip = Image(width: width, height: height, colorSpace: CalibratedGrayColorSpace(colorSpace.cieXYZ), pixel: ColorPixel<GrayColorModel>(color: GrayColorModel(white: 1), opacity: 1))
    }
}

extension ImageContext {
    
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (UnsafeMutableBufferPointer<ColorPixel<ColorSpace.Model>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableImageBufferPointer(body)
        } else {
            return try _image.withUnsafeMutableBufferPointer(body)
        }
    }
    
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<ColorPixel<ColorSpace.Model>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeImageBufferPointer(body)
        } else {
            return try _image.withUnsafeBufferPointer(body)
        }
    }
    
    public func withUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<ColorPixel<GrayColorModel>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeClipBufferPointer(body)
        } else {
            return try clip.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    public var colorSpace: ColorSpace {
        get {
            return _image.colorSpace
        }
        set {
            _image.colorSpace = newValue
        }
    }
    
    public var width: Int {
        return _image.width
    }
    
    public var height: Int {
        return _image.height
    }
    
    public var chromaticAdaptationAlgorithm: CIEXYZColorSpace.ChromaticAdaptationAlgorithm {
        get {
            return _image.chromaticAdaptationAlgorithm
        }
        set {
            _image.chromaticAdaptationAlgorithm = newValue
        }
    }
    
    public var image: Image<ColorSpace, ColorPixel<ColorSpace.Model>> {
        return _image
    }
}

extension ImageContext {
    
    public func drawClip(body: (ImageContext<CalibratedGrayColorSpace>) throws -> Void) rethrows {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        if _image.width == 0 || _image.height == 0 {
            return
        }
        
        let _clip = ImageContext<CalibratedGrayColorSpace>(width: _image.width, height: _image.height, colorSpace: CalibratedGrayColorSpace(colorSpace.cieXYZ))
        _clip.antialias = self.antialias
        _clip.transform = self.transform
        _clip.resamplingAlgorithm = self.resamplingAlgorithm
        _clip._image.chromaticAdaptationAlgorithm = _image.chromaticAdaptationAlgorithm
        
        try body(_clip)
        
        self.clip = _clip.image
    }
}

extension ImageContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            if _image.width == 0 || _image.height == 0 {
                return
            }
            
            let layer = ImageContext(width: _image.width, height: _image.height, colorSpace: colorSpace)
            layer.antialias = self.antialias
            layer.transform = self.transform
            layer.resamplingAlgorithm = self.resamplingAlgorithm
            layer._image.chromaticAdaptationAlgorithm = _image.chromaticAdaptationAlgorithm
            
            self.next = layer
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                if _image.width == 0 || _image.height == 0 {
                    return
                }
                
                next.image.withUnsafeBufferPointer { source in
                    
                    if var _source = source.baseAddress {
                        
                        _image.withUnsafeMutableBufferPointer { destination in
                            
                            if var _destination = destination.baseAddress {
                                
                                clip.withUnsafeBufferPointer { _clip in
                                    
                                    if var _clip = _clip.baseAddress {
                                        
                                        for _ in 0..<_image.width * _image.height {
                                            
                                            let _alpha = _clip.pointee.color.white * _clip.pointee.opacity
                                            
                                            if _alpha > 0 {
                                                
                                                var __source = _source.pointee
                                                __source.opacity *= opacity * _alpha
                                                
                                                _destination.pointee.blend(source: __source, blendMode: blendMode, compositingMode: compositingMode)
                                            }
                                            
                                            _source += 1
                                            _destination += 1
                                            _clip += 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ImageContext {
    
    public func draw<C : ColorSpaceProtocol, P: ColorPixelProtocol>(image: Image<C, P>, transform: SDTransform) {
        
        if let next = self.next {
            next.draw(image: image, transform: transform)
            return
        }
        
        let transform = transform * self.transform
        
        if _image.width == 0 || _image.height == 0 || image.width == 0 || image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let source: Image<ColorSpace, ColorPixel<ColorSpace.Model>>
        
        if transform == SDTransform.identity && _image.width == image.width && _image.height == image.height {
            source = Image(image: image, colorSpace: colorSpace)
        } else if C.Model.count < ColorSpace.Model.count || (C.Model.count == ColorSpace.Model.count && _image.width * _image.height < image.width * image.height) {
            let _temp = Image(image: image, width: _image.width, height: _image.height, transform: transform, resampling: resamplingAlgorithm, antialias: antialias)
            source = Image(image: _temp, colorSpace: colorSpace)
        } else {
            let _temp = Image(image: image, colorSpace: colorSpace) as Image<ColorSpace, ColorPixel<ColorSpace.Model>>
            source = Image(image: _temp, width: _image.width, height: _image.height, transform: transform, resampling: resamplingAlgorithm, antialias: antialias)
        }
        
        source.withUnsafeBufferPointer { source in
            
            if var _source = source.baseAddress {
                
                _image.withUnsafeMutableBufferPointer { destination in
                    
                    if var _destination = destination.baseAddress {
                        
                        clip.withUnsafeBufferPointer { _clip in
                            
                            if var _clip = _clip.baseAddress {
                                
                                for _ in 0..<_image.width * _image.height {
                                    
                                    let _alpha = _clip.pointee.color.white * _clip.pointee.opacity
                                    
                                    if _alpha > 0 {
                                        
                                        var __source = _source.pointee
                                        __source.opacity *= opacity * _alpha
                                        
                                        _destination.pointee.blend(source: __source, blendMode: blendMode, compositingMode: compositingMode)
                                    }
                                    
                                    _source += 1
                                    _destination += 1
                                    _clip += 1
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ImageContext {
    
    private func draw<C : ColorSpaceProtocol>(shape: Shape, color: Color<C>, winding: (Int) -> Bool) {
        
        if let next = self.next {
            next.draw(shape: shape, color: color, winding: winding)
            return
        }
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let transform = shape.transform * self.transform
        
        if _image.width == 0 || _image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let source = ColorPixel(color.convert(to: colorSpace))
        
        let stencil_count = antialias ? _image.width * _image.height * 25 : _image.width * _image.height
        
        if stencil.count != stencil_count {
            stencil = [Int](repeating: 0, count: stencil_count)
        } else {
            stencil.withUnsafeMutableBytes { _ = _memset($0.baseAddress!, 0, $0.count) }
        }
        
        var shape = shape
        
        if antialias {
            
            shape.transform = transform * SDTransform.scale(5)
            
            shape.raster(width: _image.width * 5, height: _image.height * 5, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<image.height {
                                        
                                        var __stencil = _stencil
                                        
                                        for _ in 0..<image.width {
                                            
                                            var _p = 0
                                            
                                            var _s = __stencil
                                            
                                            for _ in 0..<5 {
                                                var __s = _s
                                                for _ in 0..<5 {
                                                    if winding(__s.pointee) {
                                                        _p += 1
                                                    }
                                                    __s += 1
                                                }
                                                _s += 5 * image.width
                                            }
                                            
                                            let _alpha = _clip.pointee.color.white * _clip.pointee.opacity * (0.04 * Double(_p))
                                            
                                            if _alpha > 0 {
                                                
                                                var _source = source
                                                _source.opacity *= opacity * _alpha
                                                
                                                _destination.pointee.blend(source: _source, blendMode: blendMode, compositingMode: compositingMode)
                                            }
                                            
                                            __stencil += 5
                                            _destination += 1
                                            _clip += 1
                                        }
                                        
                                        _stencil += 25 * image.width
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        } else {
            
            shape.transform = transform
            
            shape.raster(width: _image.width, height: _image.height, stencil: &stencil)
            
            stencil.withUnsafeBufferPointer { stencil in
                
                if var _stencil = stencil.baseAddress {
                    
                    _image.withUnsafeMutableBufferPointer { _image in
                        
                        if var _destination = _image.baseAddress {
                            
                            clip.withUnsafeBufferPointer { _clip in
                                
                                if var _clip = _clip.baseAddress {
                                    
                                    for _ in 0..<image.width * image.height {
                                        
                                        let _alpha = _clip.pointee.color.white * _clip.pointee.opacity
                                        
                                        if winding(_stencil.pointee) && _alpha > 0 {
                                            
                                            var _source = source
                                            _source.opacity *= opacity * _alpha
                                            
                                            _destination.pointee.blend(source: _source, blendMode: blendMode, compositingMode: compositingMode)
                                        }
                                        
                                        _destination += 1
                                        _stencil += 1
                                        _clip += 1
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    public func draw<C : ColorSpaceProtocol>(shape: Shape, color: Color<C>, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.draw(shape: shape, color: color) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: color) { $0 & 1 == 1 }
        }
    }
}
