//
//  ImageContext.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2018 Susan Cheng. All rights reserved.
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
import Dispatch

private struct ImageContextStyles {
    
    var opacity: Double = 1
    var antialias: Bool = true
    var transform: SDTransform = SDTransform.identity
    var blendMode: ColorBlendMode = .default
    var compositingMode: ColorCompositingMode = .default
    var resamplingAlgorithm: ResamplingAlgorithm = .default
    var renderCullingMode: ImageContextRenderCullMode = .none
    var renderDepthCompareMode: ImageContextRenderDepthCompareMode = .always
    var renderingIntent: RenderingIntent = .default
    
}

public class ImageContext<Pixel: ColorPixelProtocol> {
    
    public private(set) var image: Image<Pixel>
    
    private var clip: MappedBuffer<Double>
    private var depth: MappedBuffer<Double>
    
    private var styles: ImageContextStyles = ImageContextStyles()
    
    private var next: ImageContext?
    
    private var isDirty: Bool = false
    
    public init(image: Image<Pixel>) {
        self.image = image
        self.clip = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
        self.depth = MappedBuffer(repeating: 1, count: image.width * image.height, option: image.option)
    }
    
    public init(width: Int, height: Int, resolution: Resolution = Resolution(resolution: 1, unit: .point), colorSpace: ColorSpace<Pixel.Model>, option: MappedBufferOption = .default) {
        self.image = Image(width: width, height: height, resolution: resolution, colorSpace: colorSpace, option: option)
        self.clip = MappedBuffer(repeating: 1, count: width * height, option: option)
        self.depth = MappedBuffer(repeating: 1, count: width * height, option: option)
    }
}

extension ImageContext {
    
    private convenience init<P>(copyStates context: ImageContext<P>, colorSpace: ColorSpace<Pixel.Model>) {
        self.init(width: context.width, height: context.height, colorSpace: colorSpace, option: context.image.option)
        self.styles = context.styles
        self.styles.opacity = 1
        self.image.colorSpace.chromaticAdaptationAlgorithm = context.colorSpace.chromaticAdaptationAlgorithm
    }
}

extension ImageContext {
    
    public func withUnsafeMutableImageBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        self.isDirty = true
        
        if let next = self.next {
            return try next.withUnsafeMutableImageBufferPointer(body)
        } else {
            return try image.withUnsafeMutableBufferPointer(body)
        }
    }
    
    public func withUnsafeImageBufferPointer<R>(_ body: (UnsafeBufferPointer<Pixel>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeImageBufferPointer(body)
        } else {
            return try image.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    public func withUnsafeMutableClipBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableClipBufferPointer(body)
        } else {
            return try clip.withUnsafeMutableBufferPointer(body)
        }
    }
    
    public func withUnsafeClipBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeClipBufferPointer(body)
        } else {
            return try clip.withUnsafeBufferPointer(body)
        }
    }
    
    public func clearClipBuffer(with value: Double = 1) {
        
        withUnsafeMutableClipBufferPointer { buf in
            
            guard var clip = buf.baseAddress else { return }
            
            for _ in 0..<buf.count {
                clip.pointee = value
                clip += 1
            }
        }
    }
}

extension ImageContext {
    
    public var opacity: Double {
        get {
            return next?.opacity ?? styles.opacity
        }
        set {
            if let next = self.next {
                next.opacity = newValue
            } else {
                styles.opacity = newValue
            }
        }
    }
    
    public var antialias: Bool {
        get {
            return next?.antialias ?? styles.antialias
        }
        set {
            if let next = self.next {
                next.antialias = newValue
            } else {
                styles.antialias = newValue
            }
        }
    }
    
    public var transform: SDTransform {
        get {
            return next?.transform ?? styles.transform
        }
        set {
            if let next = self.next {
                next.transform = newValue
            } else {
                styles.transform = newValue
            }
        }
    }
    
    public var blendMode: ColorBlendMode {
        get {
            return next?.blendMode ?? styles.blendMode
        }
        set {
            if let next = self.next {
                next.blendMode = newValue
            } else {
                styles.blendMode = newValue
            }
        }
    }
    
    public var compositingMode: ColorCompositingMode {
        get {
            return next?.compositingMode ?? styles.compositingMode
        }
        set {
            if let next = self.next {
                next.compositingMode = newValue
            } else {
                styles.compositingMode = newValue
            }
        }
    }
    
    public var resamplingAlgorithm: ResamplingAlgorithm {
        get {
            return next?.resamplingAlgorithm ?? styles.resamplingAlgorithm
        }
        set {
            if let next = self.next {
                next.resamplingAlgorithm = newValue
            } else {
                styles.resamplingAlgorithm = newValue
            }
        }
    }
    
    public var renderingIntent: RenderingIntent {
        get {
            return next?.renderingIntent ?? styles.renderingIntent
        }
        set {
            if let next = self.next {
                next.renderingIntent = newValue
            } else {
                styles.renderingIntent = newValue
            }
        }
    }
    
    public var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm {
        get {
            return next?.chromaticAdaptationAlgorithm ?? image.colorSpace.chromaticAdaptationAlgorithm
        }
        set {
            if let next = self.next {
                next.chromaticAdaptationAlgorithm = newValue
            } else {
                image.colorSpace.chromaticAdaptationAlgorithm = newValue
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
    
    public func withUnsafeMutableDepthBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeMutableDepthBufferPointer(body)
        } else {
            return try depth.withUnsafeMutableBufferPointer(body)
        }
    }
    
    public func withUnsafeDepthBufferPointer<R>(_ body: (UnsafeBufferPointer<Double>) throws -> R) rethrows -> R {
        
        if let next = self.next {
            return try next.withUnsafeDepthBufferPointer(body)
        } else {
            return try depth.withUnsafeBufferPointer(body)
        }
    }
}

extension ImageContext {
    
    public var renderCullingMode: ImageContextRenderCullMode {
        get {
            return next?.renderCullingMode ?? styles.renderCullingMode
        }
        set {
            if let next = self.next {
                next.renderCullingMode = newValue
            } else {
                styles.renderCullingMode = newValue
            }
        }
    }
    
    public var renderDepthCompareMode: ImageContextRenderDepthCompareMode {
        get {
            return next?.renderDepthCompareMode ?? styles.renderDepthCompareMode
        }
        set {
            if let next = self.next {
                next.renderDepthCompareMode = newValue
            } else {
                styles.renderDepthCompareMode = newValue
            }
        }
    }
    
    public func clearRenderDepthBuffer(with value: Double = 1) {
        
        withUnsafeMutableDepthBufferPointer { buf in
            
            guard var depth = buf.baseAddress else { return }
            
            for _ in 0..<buf.count {
                depth.pointee = value
                depth += 1
            }
        }
    }
}

extension ImageContext {
    
    public var colorSpace: ColorSpace<Pixel.Model> {
        return next?.colorSpace ?? image.colorSpace
    }
    
    public var width: Int {
        return image.width
    }
    
    public var height: Int {
        return image.height
    }
    
    public var resolution: Resolution {
        return image.resolution
    }
}

extension ImageContext {
    
    public func beginTransparencyLayer() {
        
        if let next = self.next {
            next.beginTransparencyLayer()
        } else {
            
            let width = self.width
            let height = self.height
            
            if width == 0 || height == 0 {
                return
            }
            
            self.next = ImageContext(copyStates: self, colorSpace: colorSpace)
        }
    }
    
    public func endTransparencyLayer() {
        
        if let next = self.next {
            
            if next.next != nil {
                
                next.endTransparencyLayer()
                
            } else {
                
                let width = self.width
                let height = self.height
                
                self.next = nil
                
                if width == 0 || height == 0 {
                    return
                }
                
                guard next.isDirty else { return }
                
                next.image.withUnsafeBufferPointer { source in
                    
                    guard let source = source.baseAddress else { return }
                    
                    self.withUnsafePixelBlender { blender in
                        
                        let n = ProcessInfo.processInfo.activeProcessorCount
                        
                        let count = width * height
                        let _count = count / n
                        let _remain = count % n
                        
                        DispatchQueue.concurrentPerform(iterations: _remain == 0 ? n : n + 1) {
                            
                            var _blender = blender + $0 * _count
                            var _source = source + $0 * _count
                            
                            for _ in 0..<($0 != n ? _count : _remain) {
                                _blender.draw(color: _source.pointee)
                                _blender += 1
                                _source += 1
                            }
                        }
                    }
                }
            }
        }
    }
}

extension ImageContext {
    
    public func drawClip<P>(body: (ImageContext<P>) throws -> Void) rethrows where P.Model == GrayColorModel {
        try self.drawClip(colorSpace: ColorSpace.calibratedGray(from: colorSpace, gamma: 2.2), body: body)
    }
    
    public func drawClip<P>(colorSpace: ColorSpace<GrayColorModel>, body: (ImageContext<P>) throws -> Void) rethrows where P.Model == GrayColorModel {
        
        if let next = self.next {
            try next.drawClip(body: body)
            return
        }
        
        let width = self.width
        let height = self.height
        
        if width == 0 || height == 0 {
            return
        }
        
        let _clip = ImageContext<P>(copyStates: self, colorSpace: colorSpace)
        
        try body(_clip)
        
        if _clip.isDirty {
            self.clip = MappedBuffer(_clip.image.pixels.lazy.map { $0.color.white * $0.opacity }, option: image.option)
        } else {
            self.clearClipBuffer(with: 0)
        }
    }
}

