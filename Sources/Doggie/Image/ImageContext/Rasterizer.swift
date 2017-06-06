//
//  Rasterizer.swift
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
protocol RasterizeBufferProtocol {
    
    var width: Int { get }
    
    var height: Int { get }
    
    static func + (lhs: Self, rhs: Int) -> Self
    
    static func += (lhs: inout Self, rhs: Int)
    
}

extension RasterizeBufferProtocol {
    
    @_versioned
    @inline(__always)
    func rasterize(_ p0: Point, _ p1: Point, _ p2: Point, operation: (Point, Self) throws -> Void) rethrows {
        
        if !Rect.bound([p0, p1, p2]).isIntersect(Rect(x: 0, y: 0, width: Double(width), height: Double(height))) {
            return
        }
        
        @inline(__always)
        func scan(_ p0: Point, _ p1: Point, _ y: Double) -> (Double, Double)? {
            let d = p1.y - p0.y
            if d.almostZero() {
                return nil
            }
            let _d = 1 / d
            let q = (p1.x - p0.x) * _d
            let r = (p0.x * p1.y - p1.x * p0.y) * _d
            return (q * y + r, q)
        }
        
        let d = cross(p1 - p0, p2 - p0)
        
        if !d.almostZero() {
            
            var q0 = p0
            var q1 = p1
            var q2 = p2
            
            sort(&q0, &q1, &q2) { $0.y < $1.y }
            
            let y0 = Int(q0.y.rounded().clamped(to: 0...Double(height - 1)))
            let y1 = Int(q1.y.rounded().clamped(to: 0...Double(height - 1)))
            let y2 = Int(q2.y.rounded().clamped(to: 0...Double(height - 1)))
            
            var buf = self
            
            if let (mid_x, _) = scan(q0, q2, q1.y) {
                
                buf += y0 * width
                
                @inline(__always)
                func _drawLoop(_ range: CountableClosedRange<Int>, _ x0: Double, _ dx0: Double, _ x1: Double, _ dx1: Double, operation: (Point, Self) throws -> Void) rethrows {
                    
                    let (min_x, min_dx, max_x, max_dx) = mid_x < q1.x ? (x0, dx0, x1, dx1) : (x1, dx1, x0, dx0)
                    
                    var _min_x = min_x
                    var _max_x = max_x
                    
                    for y in range {
                        let _y = Double(y)
                        if _min_x < _max_x && q0.y..<q2.y ~= _y {
                            let __min_x = Int(_min_x.rounded().clamped(to: 0...Double(width)))
                            let __max_x = Int(_max_x.rounded().clamped(to: 0...Double(width)))
                            var pixel = buf + __min_x
                            for x in __min_x...__max_x {
                                let _x = Double(x)
                                if _min_x..<_max_x ~= _x {
                                    try operation(Point(x: _x, y: _y), pixel)
                                }
                                pixel += 1
                            }
                        }
                        _min_x += min_dx
                        _max_x += max_dx
                        buf += width
                    }
                }
                
                if q1.y < Double(y1) {
                    
                    if let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                        
                        if y0 < y1, let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                            
                            try _drawLoop(y0...y1 - 1, x0, dx0, x1, dx1, operation: operation)
                        }
                        
                        try _drawLoop(y1...y2, x0, dx0, x2, dx2, operation: operation)
                        
                    } else if let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                        
                        try _drawLoop(y0...y1, x0, dx0, x1, dx1, operation: operation)
                    }
                } else {
                    
                    if let (x0, dx0) = scan(q0, q2, Double(y0)), let (x1, dx1) = scan(q0, q1, Double(y0)) {
                        
                        try _drawLoop(y0...y1, x0, dx0, x1, dx1, operation: operation)
                        
                        if y1 < y2, let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                            
                            try _drawLoop(y1 + 1...y2, x0 + dx0, dx0, x2 + dx2, dx2, operation: operation)
                        }
                    } else if let (x0, dx0) = scan(q0, q2, Double(y1)), let (x2, dx2) = scan(q1, q2, Double(y1)) {
                        
                        try _drawLoop(y1...y2, x0, dx0, x2, dx2, operation: operation)
                    }
                }
            }
            
        }
    }
    
}

@_versioned
@_fixed_layout
struct ImageContextRenderBuffer<Model : ColorModelProtocol> : RasterizeBufferProtocol {
    
    @_versioned
    var destination: UnsafeMutablePointer<ColorPixel<Model>>
    
    @_versioned
    var clip: UnsafePointer<Double>
    
    @_versioned
    var depth: UnsafeMutablePointer<Double>
    
    @_versioned
    var width: Int
    
    @_versioned
    var height: Int
    
    @_versioned
    @inline(__always)
    init(destination: UnsafeMutablePointer<ColorPixel<Model>>, clip: UnsafePointer<Double>, depth: UnsafeMutablePointer<Double>, width: Int, height: Int) {
        self.destination = destination
        self.clip = clip
        self.depth = depth
        self.width = width
        self.height = height
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextRenderBuffer, rhs: Int) -> ImageContextRenderBuffer {
        return ImageContextRenderBuffer(destination: lhs.destination + rhs, clip: lhs.clip + rhs, depth: lhs.depth + rhs, width: lhs.width, height: lhs.height)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextRenderBuffer, rhs: Int) {
        lhs.destination += rhs
        lhs.clip += rhs
        lhs.depth += rhs
    }
}

public protocol ImageContextRenderVertex {
    
    associatedtype Position
    
    var position: Position { get }
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func * (lhs: Double, rhs: Self) -> Self
}

public enum ImageContextRenderCullMode {
    
    case none
    case front
    case back
}

public struct PerspectiveProjectMatrix {
    
    public var angle: Double
    public var nearZ: Double
    public var farZ: Double
    
    @_inlineable
    public init(angle: Double, nearZ: Double, farZ: Double) {
        self.angle = angle
        self.nearZ = nearZ
        self.farZ = farZ
    }
}

@_inlineable
public func *(lhs: Vector, rhs: PerspectiveProjectMatrix) -> Point {
    let cotan = 1.0 / tan(0.5 * rhs.angle)
    let dz = rhs.nearZ - rhs.farZ
    let _z = lhs.z * (rhs.farZ + rhs.nearZ) + 2.0 * rhs.farZ * rhs.nearZ
    let _w = dz / _z
    return Point(x: lhs.x * cotan * _w, y: lhs.y * cotan * _w)
}

extension ImageContext {
    
    @_versioned
    @inline(__always)
    func _rasterize<S : Sequence, Vertex : ImageContextRenderVertex, Pixel : ColorPixelProtocol>(_ triangles: S, culling: ImageContextRenderCullMode, position: (Vertex) -> Point, depthFun: ((Vertex) -> Double)?, shader: (Vertex) throws -> Pixel?) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Pixel.Model == Model {
        
        @inline(__always)
        func __rasterize(rasterizer: ImageContextRenderBuffer<Model>, position: (Vertex) -> Point, depthFun: ((Vertex) -> Double)?, shader: (Vertex) throws -> Pixel?) rethrows {
            
            let transform = self._transform
            let depthCompareMode = self._renderDepthCompareMode
            
            for (v0, v1, v2) in triangles {
                
                let p0 = position(v0)
                let p1 = position(v1)
                let p2 = position(v2)
                
                let _culling: Bool
                switch culling {
                case .none: _culling = false
                case .front: _culling = cross(p1 - p0, p2 - p0) > 0
                case .back: _culling = cross(p1 - p0, p2 - p0) < 0
                }
                
                if !_culling {
                    
                    let _p0 = p0 * transform
                    let _p1 = p1 * transform
                    let _p2 = p2 * transform
                    
                    try rasterizer.rasterize(_p0, _p1, _p2) { (position, buf) in
                        
                        let _alpha = buf.clip.pointee
                        
                        if _alpha > 0, let q = Barycentric(_p0, _p1, _p2, position) {
                            
                            let b0 = q.x * v0
                            let b1 = q.y * v1
                            let b2 = q.z * v2
                            let b = b0 + b1 + b2
                            
                            if let _depth = depthFun?(b) {
                                
                                if 0...1 ~= _depth {
                                    
                                    let depthPass: Bool
                                    
                                    switch depthCompareMode {
                                    case .always: depthPass = true
                                    case .never: depthPass = false
                                    case .equal: depthPass = _depth == buf.depth.pointee
                                    case .notEqual: depthPass = _depth != buf.depth.pointee
                                    case .less: depthPass = _depth < buf.depth.pointee
                                    case .lessEqual: depthPass = _depth <= buf.depth.pointee
                                    case .greater: depthPass = _depth > buf.depth.pointee
                                    case .greaterEqual: depthPass = _depth >= buf.depth.pointee
                                    }
                                    
                                    if depthPass, var pixel = try shader(b) {
                                        
                                        pixel.opacity *= _alpha
                                        
                                        if pixel.opacity > 0 {
                                            buf.destination.pointee.blend(source: pixel, blendMode: _blendMode, compositingMode: _compositingMode)
                                            buf.depth.pointee = _depth
                                        }
                                    }
                                }
                            } else {
                                
                                if var pixel = try shader(b) {
                                    
                                    pixel.opacity *= _alpha
                                    
                                    if pixel.opacity > 0 {
                                        buf.destination.pointee.blend(source: pixel, blendMode: _blendMode, compositingMode: _compositingMode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        try _image.withUnsafeMutableBufferPointer { _image in
            
            if let _destination = _image.baseAddress {
                
                try clip.withUnsafeBufferPointer { _clip in
                    
                    if let _clip = _clip.baseAddress {
                        
                        try depth.withUnsafeMutableBufferPointer { _depth in
                            
                            if let _depth = _depth.baseAddress {
                                
                                let rasterizer = ImageContextRenderBuffer(destination: _destination, clip: _clip, depth: _depth, width: width, height: height)
                                
                                try __rasterize(rasterizer: rasterizer, position: position, depthFun: depthFun, shader: shader)
                            }
                        }
                    }
                }
            }
        }
    }
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
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, Pixel : ColorPixelProtocol>(_ triangles: S, culling: ImageContextRenderCullMode = .none, shader: (Vertex) throws -> Pixel?) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point, Pixel.Model == Model {
        
        if let next = self.next {
            try next.render(triangles, culling: culling, shader: shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        try _rasterize(triangles, culling: culling, position: { $0.position }, depthFun: nil, shader: shader)
    }
    
    @_inlineable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, Pixel : ColorPixelProtocol>(_ triangles: S, projection: PerspectiveProjectMatrix, culling: ImageContextRenderCullMode = .none, shader: (Vertex) throws -> Pixel?) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == Model {
        
        if let next = self.next {
            try next.render(triangles, projection: projection, culling: culling, shader: shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        let width = Double(self.width)
        let height = Double(self.height)
        let aspect = height / width
        
        @inline(__always)
        func _position(_ v: Vertex) -> Point {
            let p = v.position * projection
            return Point(x: (0.5 + 0.5 * p.x) * width, y: (0.5 + 0.5 * p.y) * height)
        }
        
        try _rasterize(triangles, culling: culling, position: _position, depthFun: { ($0.position.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: shader)
    }
}
