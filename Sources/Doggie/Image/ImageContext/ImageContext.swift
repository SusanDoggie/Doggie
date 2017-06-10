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

@_fixed_layout
public class ImageContext<Model : ColorModelProtocol> {
    
    @_versioned
    var _image: Image<ColorPixel<Model>>
    
    @_versioned
    var clip: [Double]
    
    @_versioned
    var stencil: [Int16] = []
    
    @_versioned
    var depth: [Double]
    
    @_versioned
    var _renderDepthCompareMode: ImageContextRenderDepthCompareMode = .always
    
    @_versioned
    var _antialias: Bool = true
    
    @_versioned
    var _resamplingAlgorithm: ResamplingAlgorithm = .default
    
    @_versioned
    var _opacity: Double = 1
    
    @_versioned
    var _blendMode: ColorBlendMode = .default
    
    @_versioned
    var _compositingMode: ColorCompositingMode = .default
    
    @_versioned
    var _transform: SDTransform = SDTransform.identity
    
    @_versioned
    var next: ImageContext<Model>?
    
    @_inlineable
    public init<P>(image: Image<P>) where P.Model == Model {
        
        self._image = Image(image: image)
        self.clip = [Double](repeating: 1, count: image.width * image.height)
        self.depth = [Double](repeating: 1, count: image.width * image.height)
    }
    
    @_inlineable
    public init(width: Int, height: Int, colorSpace: ColorSpace<Model>) {
        
        self._image = Image(width: width, height: height, colorSpace: colorSpace)
        self.clip = [Double](repeating: 1, count: width * height)
        self.depth = [Double](repeating: 1, count: width * height)
    }
}

extension ImageContext {
    
    @_inlineable
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<ColorPixel<Model>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableImageBufferPointer(body)
        } else {
            return try _image.withUnsafeMutableBufferPointer(body)
        }
    }
    
    @_inlineable
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<ColorPixel<Model>>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeImageBufferPointer(body)
        } else {
            return try _image.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
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
    
    @_inlineable
    public var colorSpace: ColorSpace<Model> {
        return _image.colorSpace
    }
    
    @_inlineable
    public var width: Int {
        return _image.width
    }
    
    @_inlineable
    public var height: Int {
        return _image.height
    }
    
    @_inlineable
    public var image: Image<ColorPixel<Model>> {
        return _image
    }
}
