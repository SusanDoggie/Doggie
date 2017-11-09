//
//  Rendering.swift
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
@_fixed_layout
struct ImageContextRenderBuffer<P : ColorPixelProtocol> : RasterizeBufferProtocol {
    
    @_versioned
    var blender: ImageContextPixelBlender<P>
    
    @_versioned
    var depth: UnsafeMutablePointer<Double>
    
    @_versioned
    var width: Int
    
    @_versioned
    var height: Int
    
    @_versioned
    @inline(__always)
    init(blender: ImageContextPixelBlender<P>, depth: UnsafeMutablePointer<Double>, width: Int, height: Int) {
        self.blender = blender
        self.depth = depth
        self.width = width
        self.height = height
    }
    
    @_versioned
    @inline(__always)
    static func + (lhs: ImageContextRenderBuffer, rhs: Int) -> ImageContextRenderBuffer {
        return ImageContextRenderBuffer(blender: lhs.blender + rhs, depth: lhs.depth + rhs, width: lhs.width, height: lhs.height)
    }
    
    @_versioned
    @inline(__always)
    static func += (lhs: inout ImageContextRenderBuffer, rhs: Int) {
        lhs.blender += rhs
        lhs.depth += rhs
    }
}

public protocol ImageContextRenderVertex {
    
    associatedtype Position
    
    var position: Position { get }
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func * (lhs: Double, rhs: Self) -> Self
}

extension ImageContext {
    
    @_inlineable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, position: (Vertex.Position) -> Point, depthFun: ((Vertex.Position) -> Double)?, shader: (Vertex) -> P?) where S.Element == (Vertex, Vertex, Vertex), Pixel.Model == P.Model {
        
        let transform = self.transform
        let cullingMode = self.renderCullingMode
        let depthCompareMode = self.renderDepthCompareMode
        
        if self.width == 0 || self.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        self.withUnsafePixelBlender { blender in
            
            self.withUnsafeMutableDepthBufferPointer { _depth in
                
                if let _depth = _depth.baseAddress {
                    
                    let rasterizer = ImageContextRenderBuffer(blender: blender, depth: _depth, width: width, height: height)
                    
                    for (v0, v1, v2) in triangles {
                        
                        if let depthFun = depthFun {
                            guard 0...1 ~= depthFun(v0.position) || 0...1 ~= depthFun(v1.position) || 0...1 ~= depthFun(v2.position) else { continue }
                        }
                        
                        let p0 = position(v0.position)
                        let p1 = position(v1.position)
                        let p2 = position(v2.position)
                        
                        let _culling: Bool
                        switch cullingMode {
                        case .none: _culling = false
                        case .front: _culling = cross(p1 - p0, p2 - p0) > 0
                        case .back: _culling = cross(p1 - p0, p2 - p0) < 0
                        }
                        
                        if !_culling {
                            
                            let _p0 = p0 * transform
                            let _p1 = p1 * transform
                            let _p2 = p2 * transform
                            
                            rasterizer.rasterize(_p0, _p1, _p2) { barycentric, position, buf in
                                
                                buf.blender.draw { () -> P? in
                                    
                                    let b0 = barycentric.x * v0
                                    let b1 = barycentric.y * v1
                                    let b2 = barycentric.z * v2
                                    let b = b0 + b1 + b2
                                    
                                    if let _depth = depthFun?(b.position) {
                                        
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
                                            
                                            if depthPass {
                                                buf.depth.pointee = _depth
                                                return shader(b)
                                            }
                                        }
                                    } else {
                                        return shader(b)
                                    }
                                    
                                    return nil
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
    
    @_inlineable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, shader: (Vertex) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point, Pixel.Model == P.Model {
        
        render(triangles, position: { $0 }, depthFun: nil, shader: shader)
    }
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

@_versioned
@_fixed_layout
struct _PerspectiveProjectTriangleIterator<Base : IteratorProtocol, Vertex : ImageContextRenderVertex> : Sequence, IteratorProtocol where Vertex.Position == Vector, Base.Element == (Vertex, Vertex, Vertex) {
    
    @_versioned
    var base: Base
    
    @_versioned
    @inline(__always)
    init(base: Base) {
        self.base = base
    }
    
    @_versioned
    @inline(__always)
    mutating func next() -> (_Vertex, _Vertex, _Vertex)? {
        return base.next().map { (_Vertex(vertex: $0), _Vertex(vertex: $1), _Vertex(vertex: $2)) }
    }
}

extension _PerspectiveProjectTriangleIterator {
    
    @_versioned
    @_fixed_layout
    struct _Vertex : ImageContextRenderVertex {
        
        @_versioned
        var v: Vertex
        
        @_versioned
        var w: Double
        
        @_versioned
        @_inlineable
        init(v: Vertex, w: Double) {
            self.v = v
            self.w = w
        }
        
        @_versioned
        @_inlineable
        init(vertex: Vertex) {
            self.w = 1 / vertex.position.z
            self.v = w * vertex
        }
        
        @_versioned
        @_inlineable
        var vertex: Vertex {
            return (1 / w) * v
        }
        
        @_versioned
        @_inlineable
        var position: Vertex.Position {
            return vertex.position
        }
        
        @_versioned
        @_inlineable
        static func + (lhs: _Vertex, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs.v + rhs.v, w: lhs.w + rhs.w)
        }
        
        @_versioned
        @_inlineable
        static func * (lhs: Double, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs * rhs.v, w: lhs * rhs.w)
        }
    }
}

extension ImageContext {
    
    @_inlineable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, projection: PerspectiveProjectMatrix, shader: (Vertex) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == P.Model {
        
        let width = Double(self.width)
        let height = Double(self.height)
        
        @inline(__always)
        func _position(_ v: Vector) -> Point {
            let p = v * projection
            return Point(x: (0.5 + 0.5 * p.x) * width, y: (0.5 + 0.5 * p.y) * height)
        }
        
        render(_PerspectiveProjectTriangleIterator(base: triangles.makeIterator()), position: _position, depthFun: { ($0.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: { shader($0.vertex) })
    }
}
