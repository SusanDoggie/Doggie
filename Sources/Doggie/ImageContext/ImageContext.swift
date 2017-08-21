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
public class ImageContext<Pixel: ColorPixelProtocol> {
    
    @_versioned
    var _image: Image<Pixel>
    
    @_versioned
    var clip: [Double]
    
    @_versioned
    var depth: [Double]
    
    @_versioned
    var _opacity: Double = 1
    
    @_versioned
    var _antialias: Bool = true
    
    @_versioned
    var _transform: SDTransform = SDTransform.identity
    
    @_versioned
    var _blendMode: ColorBlendMode = .default
    
    @_versioned
    var _compositingMode: ColorCompositingMode = .default
    
    @_versioned
    var _resamplingAlgorithm: ResamplingAlgorithm = .default
    
    @_versioned
    var _renderCullingMode: ImageContextRenderCullMode = .none
    
    @_versioned
    var _renderDepthCompareMode: ImageContextRenderDepthCompareMode = .always
    
    @_versioned
    var _renderingIntent: RenderingIntent = .default
    
    @_versioned
    var next: ImageContext?
    
    @_inlineable
    public init(image: Image<Pixel>) {
        self._image = image
        self.clip = [Double](repeating: 1, count: image.width * image.height)
        self.depth = [Double](repeating: 1, count: image.width * image.height)
    }
    
    @_inlineable
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>) {
        self._image = Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace)
        self.clip = [Double](repeating: 1, count: width * height)
        self.depth = [Double](repeating: 1, count: width * height)
    }
}

extension ImageContext {
    
    @_versioned
    @_inlineable
    convenience init<P>(copyStates context: ImageContext<P>, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: context.width, height: context.height, colorSpace: colorSpace)
        self._antialias = context.antialias
        self._transform = context.transform
        self._blendMode = context.blendMode
        self._compositingMode = context.compositingMode
        self._resamplingAlgorithm = context.resamplingAlgorithm
        self._renderCullingMode = context.renderCullingMode
        self._renderDepthCompareMode = context.renderDepthCompareMode
        self._renderingIntent = context.renderingIntent
        self._image.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension ImageContext {
    
    @_inlineable
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableImageBufferPointer(body)
        } else {
            return try _image.withUnsafeMutableBufferPointer(body)
        }
    }
    
    @_inlineable
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeImageBufferPointer(body)
        } else {
            return try _image.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func withUnsafeMutableClipBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableClipBufferPointer(body)
        } else {
            return try clip.withUnsafeMutableBufferPointer(body)
        }
    }
    
    @_inlineable
    public func withUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeClipBufferPointer(body)
        } else {
            return try clip.withUnsafeBufferPointer(body)
        }
    }
    
    @_inlineable
    public func clearClipBuffer(with value: Double = 1) {
        
        withUnsafeMutableClipBufferPointer { buf in
            
            if var clip = buf.baseAddress {
                
                for _ in 0..<buf.count {
                    clip.pointee = value
                    clip += 1
                }
            }
        }
    }
}

extension ImageContext {
    
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
    public var renderingIntent: RenderingIntent {
        get {
            return next?.renderingIntent ?? _renderingIntent
        }
        set {
            if let next = self.next {
                next.renderingIntent = newValue
            } else {
                _renderingIntent = newValue
            }
        }
    }
    
    @_inlineable
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return next?.chromaticAdaptationAlgorithm ?? _image.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            if let next = self.next {
                next.chromaticAdaptationAlgorithm = newValue
            } else {
                _image.colorSpace.chromaticAdaptationAlgorithm = newValue
            }
        }
    }
}

public enum ImageContextRenderCullMode {
    
    case none
    case front
    case back
}

public enum ImageContextRenderDepthCompareMode {
    
    case always
    case never
    case equal
    case notEqual
    case less
    case lessEqual
    case greater
    case greaterEqual
}

extension ImageContext {
    
    @_inlineable
    public func withUnsafeMutableDepthBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableDepthBufferPointer(body)
        } else {
            return try depth.withUnsafeMutableBufferPointer(body)
        }
    }
    
    @_inlineable
    public func withUnsafeDepthBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeDepthBufferPointer(body)
        } else {
            return try depth.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public var renderCullingMode: ImageContextRenderCullMode {
        get {
            return next?.renderCullingMode ?? _renderCullingMode
        }
        set {
            if let next = self.next {
                next.renderCullingMode = newValue
            } else {
                _renderCullingMode = newValue
            }
        }
    }
    
    @_inlineable
    public var renderDepthCompareMode: ImageContextRenderDepthCompareMode {
        get {
            return next?.renderDepthCompareMode ?? _renderDepthCompareMode
        }
        set {
            if let next = self.next {
                next.renderDepthCompareMode = newValue
            } else {
                _renderDepthCompareMode = newValue
            }
        }
    }
    
    @_inlineable
    public func clearRenderDepthBuffer(with value: Double = 1) {
        
        withUnsafeMutableDepthBufferPointer { buf in
            
            if var depth = buf.baseAddress {
                
                for _ in 0..<buf.count {
                    depth.pointee = value
                    depth += 1
                }
            }
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public var colorSpace: ColorSpace<Pixel.Model> {
        return next?.colorSpace ?? _image.colorSpace
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
    public var resolution: Resolution {
        return _image.resolution
    }
    
    @_inlineable
    public var image: Image<Pixel> {
        return _image
    }
}
