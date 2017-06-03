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
    
    @_versioned
    var width: Int { get }
    
    @_versioned
    var height: Int { get }
    
    @_versioned
    static func + (lhs: Self, rhs: Int) -> Self
    
    @_versioned
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
struct ImageContextRasterizeBuffer<Model : ColorModelProtocol> : RasterizeBufferProtocol {
    
    @_versioned
    var destination: UnsafeMutablePointer<ColorPixel<Model>>
    
    @_versioned
    var clip: UnsafePointer<Double>
    
    @_versioned
    var width: Int
    
    @_versioned
    var height: Int
    
    @_versioned
    @inline(__always)
    init(destination: UnsafeMutablePointer<ColorPixel<Model>>, clip: UnsafePointer<Double>, width: Int, height: Int) {
        self.destination = destination
        self.clip = clip
        self.width = width
        self.height = height
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextRasterizeBuffer, rhs: Int) -> ImageContextRasterizeBuffer {
        return ImageContextRasterizeBuffer(destination: lhs.destination + rhs, clip: lhs.clip + rhs, width: lhs.width, height: lhs.height)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextRasterizeBuffer, rhs: Int) {
        lhs.destination += rhs
        lhs.clip += rhs
    }
}

public protocol ImageContextRasterizeVertex {
    
    associatedtype Position
    
    var position: Position { get }
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func * (lhs: Double, rhs: Self) -> Self
}

public enum ImageContextRasterizeCullMode {
    
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
    func _rasterize<S : Sequence, Vertex : ImageContextRasterizeVertex, Pixel : ColorPixelProtocol>(_ triangles: S, test: ((ImageContextRasterizeBuffer<Model>, Vertex) -> Bool)?, shader: (Vertex) throws -> Pixel?, position: (Vertex) -> Point, culling: (Point, Point, Point) -> Bool) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Pixel.Model == Model {
        
        @inline(__always)
        func __rasterize(rasterizer: ImageContextRasterizeBuffer<Model>, test: ((ImageContextRasterizeBuffer<Model>, Vertex) -> Bool)?, shader: (Vertex) throws -> Pixel?, position: (Vertex) -> Point, culling: (Point, Point, Point) -> Bool) rethrows {
            
            let transform = self._transform
            
            for (v0, v1, v2) in triangles {
                
                let p0 = position(v0)
                let p1 = position(v1)
                let p2 = position(v2)
                
                if culling(p0, p1, p2) {
                    
                    let _p0 = p0 * transform
                    let _p1 = p1 * transform
                    let _p2 = p2 * transform
                    
                    try rasterizer.rasterize(_p0, _p1, _p2) { (position, buf) in
                        
                        let _alpha = buf.clip.pointee
                        
                        if _alpha > 0, let q = Barycentric(_p0, _p1, _p2, position) {
                            
                            let b = q.x * v0 + q.y * v1 + q.z * v2
                            
                            if test?(buf, b) != false, var pixel = try shader(b) {
                                
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
        
        try _image.withUnsafeMutableBufferPointer { _image in
            
            if let _destination = _image.baseAddress {
                
                try clip.withUnsafeBufferPointer { _clip in
                    
                    if let _clip = _clip.baseAddress {
                        
                        let rasterizer = ImageContextRasterizeBuffer(destination: _destination, clip: _clip, width: width, height: height)
                        
                        try __rasterize(rasterizer: rasterizer, test: test, shader: shader, position: position, culling: culling)
                    }
                }
            }
        }
    }
    
    @_inlineable
    public func rasterize<S : Sequence, Vertex : ImageContextRasterizeVertex, Pixel : ColorPixelProtocol>(_ triangles: S, culling: ImageContextRasterizeCullMode = .none, shader: (Vertex) throws -> Pixel?) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point, Pixel.Model == Model {
        
        if let next = self.next {
            try next.rasterize(triangles, culling: culling, shader: shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        switch culling {
        case .none: try _rasterize(triangles, test: nil, shader: shader, position: { $0.position }, culling: { _ in true })
        case .front: try _rasterize(triangles, test: nil, shader: shader, position: { $0.position }, culling: { cross($1 - $0, $2 - $0) < 0 })
        case .back: try _rasterize(triangles, test: nil, shader: shader, position: { $0.position }, culling: { cross($1 - $0, $2 - $0) > 0 })
        }
    }
    
    @_inlineable
    public func rasterize<S : Sequence, Vertex : ImageContextRasterizeVertex, Pixel : ColorPixelProtocol>(_ triangles: S, projection: PerspectiveProjectMatrix, culling: ImageContextRasterizeCullMode = .none, shader: (Vertex) throws -> Pixel?) rethrows where S.Iterator.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == Model {
        
        if let next = self.next {
            try next.rasterize(triangles, projection: projection, culling: culling, shader: shader)
            return
        }
        
        if _image.width == 0 || _image.height == 0 || _transform.determinant.almostZero() {
            return
        }
        
        let width = Double(self.width)
        let height = Double(self.height)
        let aspect = height / width
        
        let z_range = min(projection.nearZ, projection.farZ)...max(projection.nearZ, projection.farZ)
        
        @inline(__always)
        func _test(_ buf: ImageContextRasterizeBuffer<Model>, _ v: Vertex) -> Bool {
            return z_range ~= v.position.z
        }
        
        @inline(__always)
        func _position(_ v: Vertex) -> Point {
            let p = Vector(x: v.position.x * aspect, y: -v.position.y, z: v.position.z) * projection
            return Point(x: (0.5 + 0.5 * p.x) * width, y: (0.5 + 0.5 * p.y) * height)
        }
        
        switch culling {
        case .none: try _rasterize(triangles, test: _test, shader: shader, position: _position, culling: { _ in true })
        case .front: try _rasterize(triangles, test: _test, shader: shader, position: _position, culling: { cross($1 - $0, $2 - $0) > 0 })
        case .back: try _rasterize(triangles, test: _test, shader: shader, position: _position, culling: { cross($1 - $0, $2 - $0) < 0 })
        }
    }
}
