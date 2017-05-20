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

public class ImageContext<Model : ColorModelProtocol> {
    
    fileprivate var clip: Image<ColorPixel<GrayColorModel>>
    
    fileprivate var _image: Image<ColorPixel<Model>>
    
    fileprivate var stencil: [Int] = []
    
    fileprivate var _antialias: Bool = true
    
    fileprivate var _resamplingAlgorithm: ResamplingAlgorithm = .default
    
    fileprivate var _opacity: Double = 1
    fileprivate var _blendMode: ColorBlendMode = .default
    fileprivate var _compositingMode: ColorCompositingMode = .default
    
    fileprivate var _transform: SDTransform = SDTransform.identity
    
    fileprivate var next: ImageContext<Model>?
    
    public init<P : ColorPixelProtocol>(image: Image<P>) where P.Model == Model {
        
        self._image = Image(image: image)
        self.clip = Image(width: image.width, height: image.height, colorSpace: CalibratedGrayColorSpace(image.colorSpace.cieXYZ), pixel: ColorPixel<GrayColorModel>(color: GrayColorModel(white: 1), opacity: 1))
    }
    
    public init<C : ColorSpaceProtocol>(width: Int, height: Int, colorSpace: C) where C.Model == Model {
        
        self._image = Image(width: width, height: height, colorSpace: colorSpace, pixel: ColorPixel<Model>())
        self.clip = Image(width: width, height: height, colorSpace: CalibratedGrayColorSpace(colorSpace.cieXYZ), pixel: ColorPixel<GrayColorModel>(color: GrayColorModel(white: 1), opacity: 1))
    }
}

extension ImageContext {
    
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<ColorPixel<Model>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableImageBufferPointer(body)
        } else {
            return try _image.withUnsafeMutableBufferPointer(body)
        }
    }
    
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<ColorPixel<Model>>) throws -> R) rethrows -> R {
        
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
    
    public var antialias: Bool {
        get {
            return next?.antialias ?? _antialias
        }
        set {
            if let next = self.next {
                next.antialias = newValue
            } else {
                _antialias = newValue
            }
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return next?.resamplingAlgorithm ?? _resamplingAlgorithm
        }
        set {
            if let next = self.next {
                next.resamplingAlgorithm = newValue
            } else {
                _resamplingAlgorithm = newValue
            }
        }
    }
    
    public var opacity: Double {
        get {
            return next?.opacity ?? _opacity
        }
        set {
            if let next = self.next {
                next.opacity = newValue
            } else {
                _opacity = newValue
            }
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return next?.blendMode ?? _blendMode
        }
        set {
            if let next = self.next {
                next.blendMode = newValue
            } else {
                _blendMode = newValue
            }
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return next?.compositingMode ?? _compositingMode
        }
        set {
            if let next = self.next {
                next.compositingMode = newValue
            } else {
                _compositingMode = newValue
            }
        }
    }
    
    public var transform: SDTransform {
        get {
            return next?.transform ?? _transform
        }
        set {
            if let next = self.next {
                next.transform = newValue
            } else {
                _transform = newValue
            }
        }
    }
    
    public var colorSpace: ColorSpace<Model> {
        return _image.colorSpace
    }
    
    public var width: Int {
        return _image.width
    }
    
    public var height: Int {
        return _image.height
    }
    
    public var image: Image<ColorPixel<Model>> {
        return _image
    }
}

extension ImageContext {
    
    public func drawClip(body: (ImageContext<GrayColorModel>) throws -> Void) rethrows {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        if _image.width == 0 || _image.height == 0 {
            return
        }
        
        let _clip = ImageContext<GrayColorModel>(width: _image.width, height: _image.height, colorSpace: CalibratedGrayColorSpace(colorSpace.cieXYZ))
        _clip._antialias = self._antialias
        _clip._transform = self._transform
        _clip._resamplingAlgorithm = self._resamplingAlgorithm
        
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
            layer._antialias = self._antialias
            layer._transform = self._transform
            layer._resamplingAlgorithm = self._resamplingAlgorithm
            
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
                                                __source.opacity *= _opacity * _alpha
                                                
                                                _destination.pointee.blend(source: __source, blendMode: _blendMode, compositingMode: _compositingMode)
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
    
    public func draw<C>(image: Image<C>, transform: SDTransform) {
        
        if let next = self.next {
            next.draw(image: image, transform: transform)
            return
        }
        
        let transform = transform * self._transform
        
        if _image.width == 0 || _image.height == 0 || image.width == 0 || image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let source: Image<ColorPixel<Model>>
        
        if transform == SDTransform.identity && _image.width == image.width && _image.height == image.height {
            source = Image(image: image, colorSpace: colorSpace)
        } else if C.Model.count < Model.count || (C.Model.count == Model.count && _image.width * _image.height < image.width * image.height) {
            let _temp = Image(image: image, width: _image.width, height: _image.height, transform: transform, resampling: _resamplingAlgorithm, antialias: _antialias)
            source = Image(image: _temp, colorSpace: colorSpace)
        } else {
            let _temp = Image(image: image, colorSpace: colorSpace) as Image<ColorPixel<Model>>
            source = Image(image: _temp, width: _image.width, height: _image.height, transform: transform, resampling: _resamplingAlgorithm, antialias: _antialias)
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
                                        __source.opacity *= _opacity * _alpha
                                        
                                        _destination.pointee.blend(source: __source, blendMode: _blendMode, compositingMode: _compositingMode)
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
    
    private func draw<C>(shape: Shape, color: Color<C>, winding: (Int) -> Bool) {
        
        if let next = self.next {
            next.draw(shape: shape, color: color, winding: winding)
            return
        }
        
        if shape.reduce(0, { $0 + $1.count }) == 0 {
            return
        }
        
        let transform = shape.transform * self._transform
        
        if _image.width == 0 || _image.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        let source = ColorPixel(color.convert(to: colorSpace))
        
        let stencil_count = _antialias ? _image.width * _image.height * 25 : _image.width * _image.height
        
        if stencil.count != stencil_count {
            stencil = [Int](repeating: 0, count: stencil_count)
        } else {
            stencil.withUnsafeMutableBytes { _ = _memset($0.baseAddress!, 0, $0.count) }
        }
        
        var shape = shape
        
        if _antialias {
            
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
                                                _source.opacity *= _opacity * _alpha
                                                
                                                _destination.pointee.blend(source: _source, blendMode: _blendMode, compositingMode: _compositingMode)
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
                                            _source.opacity *= _opacity * _alpha
                                            
                                            _destination.pointee.blend(source: _source, blendMode: _blendMode, compositingMode: _compositingMode)
                                        }
                                        
                                        _stencil += 1
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
    
    public func draw<C>(shape: Shape, color: Color<C>, winding: Shape.WindingRule) {
        
        switch winding {
        case .nonZero: self.draw(shape: shape, color: color) { $0 != 0 }
        case .evenOdd: self.draw(shape: shape, color: color) { $0 & 1 == 1 }
        }
    }
}
