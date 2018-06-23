//
//  Rendering.swift
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

@_fixed_layout
@usableFromInline
struct ImageContextRenderBuffer<P : ColorPixelProtocol> : RasterizeBufferProtocol {
    
    @usableFromInline
    var blender: ImageContextPixelBlender<P>
    
    @usableFromInline
    var depth: UnsafeMutablePointer<Double>?
    
    @usableFromInline
    var width: Int
    
    @usableFromInline
    var height: Int
    
    @inlinable
    init(blender: ImageContextPixelBlender<P>, depth: UnsafeMutablePointer<Double>?, width: Int, height: Int) {
        self.blender = blender
        self.depth = depth
        self.width = width
        self.height = height
    }
    
    @inlinable
    static func + (lhs: ImageContextRenderBuffer, rhs: Int) -> ImageContextRenderBuffer {
        return ImageContextRenderBuffer(blender: lhs.blender + rhs, depth: lhs.depth.map { $0 + rhs }, width: lhs.width, height: lhs.height)
    }
    
    @inlinable
    static func += (lhs: inout ImageContextRenderBuffer, rhs: Int) {
        lhs.blender += rhs
        lhs.depth = lhs.depth.map { $0 + rhs }
    }
}

public protocol ImageContextRenderVertex {
    
    associatedtype Position
    
    var position: Position { get }
    
    static func + (lhs: Self, rhs: Self) -> Self
    
    static func * (lhs: Double, rhs: Self) -> Self
}

extension ScalarMultiplicative where Self : ImageContextRenderVertex {
    
    @_transparent
    public static prefix func + (x: Self) -> Self {
        return x
    }
    @_transparent
    public static prefix func - (x: Self) -> Self {
        return -1 * x
    }
    @_transparent
    public static func - (lhs: Self, rhs: Self) -> Self {
        return lhs + (-rhs)
    }
    @_transparent
    public static func * (lhs: Self, rhs: Scalar) -> Self {
        return rhs * lhs
    }
    @_transparent
    public static func / (lhs: Self, rhs: Scalar) -> Self {
        return lhs * (1 / rhs)
    }
    @_transparent
    public static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
    @_transparent
    public static func -= (lhs: inout Self, rhs: Self) {
        lhs = lhs - rhs
    }
    @_transparent
    public static func *= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs * rhs
    }
    @_transparent
    public static func /= (lhs: inout Self, rhs: Scalar) {
        lhs = lhs / rhs
    }
}

public struct ImageContextRenderStageIn<Vertex : ImageContextRenderVertex> {
    
    public var vertex: Vertex
    
    public var triangle: (Vertex.Position, Vertex.Position, Vertex.Position)
    
    public var barycentric: Vector
    
    public var position: Point
    
    public var facing: Double
    
    public var depth: Double
    
    @inlinable
    init(vertex: Vertex, triangle: (Vertex.Position, Vertex.Position, Vertex.Position), barycentric: Vector, position: Point, facing: Double, depth: Double) {
        self.vertex = vertex
        self.triangle = triangle
        self.barycentric = barycentric
        self.position = position
        self.facing = facing
        self.depth = depth
    }
}

extension ImageContextRenderStageIn where Vertex.Position == Vector {
    
    @inlinable
    public var normal: Vector {
        return cross(triangle.1 - triangle.0, triangle.2 - triangle.0)
    }
}

public protocol ImageContextRenderTriangleGenerator {
    
    associatedtype Vertex : ImageContextRenderVertex
    
    func render(position: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void)
}

public protocol ImageContextRenderPipelineShader {
    
    associatedtype StageIn : ImageContextRenderVertex
    
    associatedtype StageOut : ImageContextRenderVertex where StageOut.Position == StageIn.Position
    
    func render(position: (StageIn.Position) -> Point, stageIn: (StageIn, StageIn, StageIn)) -> (StageOut, StageOut, StageOut)
}

public struct ImageContextRenderPipeline<Intput: ImageContextRenderTriangleGenerator, Shader: ImageContextRenderPipelineShader> : ImageContextRenderTriangleGenerator where Intput.Vertex == Shader.StageIn {
    
    public typealias Vertex = Shader.StageOut
    
    public let input: Intput
    public let shader: Shader
    
    @inlinable
    init(input: Intput, shader: Shader) {
        self.input = input
        self.shader = shader
    }
    
    @inlinable
    public func render(position: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        input.render(position: position) {
            let stageOut = shader.render(position: position, stageIn: ($0, $1, $2))
            body(stageOut.0, stageOut.1, stageOut.2)
        }
    }
}

extension ImageContextRenderTriangleGenerator {
    
    @inlinable
    public func bind<S>(_ shader: S) -> ImageContextRenderPipeline<Self, S> {
        return ImageContextRenderPipeline(input: self, shader: shader)
    }
}

extension Sequence where Self : ImageContextRenderTriangleGenerator, Element : ImageContextRenderTriangleGenerator, Element.Vertex == Self.Vertex {
    
    @inlinable
    public func render(position: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        self.forEach { $0.render(position: position, body) }
    }
}

extension Array : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ArraySlice : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ContiguousArray : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension MappedBuffer : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension UnsafeBufferPointer : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension UnsafeMutableBufferPointer : ImageContextRenderTriangleGenerator where Element : ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ImageContext {
    
    @inlinable
    public func render<G : ImageContextRenderTriangleGenerator, P : ColorPixelProtocol>(_ triangles: G, position: (G.Vertex.Position) -> Point, depthFun: ((G.Vertex.Position) -> Double)?, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where Pixel.Model == P.Model {
        
        let transform = self.transform
        let cullingMode = self.renderCullingMode
        let depthCompareMode = self.renderDepthCompareMode
        
        if self.width == 0 || self.height == 0 || transform.determinant.almostZero() {
            return
        }
        
        @inline(__always)
        func _render(rasterizer: ImageContextRenderBuffer<Pixel>, position: (G.Vertex.Position) -> Point, depthFun: ((G.Vertex.Position) -> Double)?, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) {
            
            triangles.render(position: position) { v0, v1, v2 in
                
                let _v0 = v0.position
                let _v1 = v1.position
                let _v2 = v2.position
                
                if let depthFun = depthFun {
                    guard 0...1 ~= depthFun(_v0) || 0...1 ~= depthFun(_v1) || 0...1 ~= depthFun(_v2) else { return }
                }
                
                let p0 = position(_v0)
                let p1 = position(_v1)
                let p2 = position(_v2)
                
                let facing = cross(p1 - p0, p2 - p0)
                
                switch cullingMode {
                case .none: break
                case .front: guard facing < 0 else { return }
                case .back: guard facing > 0 else { return }
                }
                
                let _p0 = p0 * transform
                let _p1 = p1 * transform
                let _p2 = p2 * transform
                
                rasterizer.rasterize(_p0, _p1, _p2) { barycentric, position, buf in
                    
                    let b0 = barycentric.x * v0
                    let b1 = barycentric.y * v1
                    let b2 = barycentric.z * v2
                    let b = b0 + b1 + b2
                    
                    if let _depth = depthFun?(b.position) {
                        
                        guard 0...1 ~= _depth else { return }
                        guard let depth_ptr = buf.depth else { return }
                        
                        switch depthCompareMode {
                        case .always: break
                        case .never: return
                        case .equal: guard _depth == depth_ptr.pointee else { return }
                        case .notEqual: guard _depth != depth_ptr.pointee else { return }
                        case .less: guard _depth < depth_ptr.pointee else { return }
                        case .lessEqual: guard _depth <= depth_ptr.pointee else { return }
                        case .greater: guard _depth > depth_ptr.pointee else { return }
                        case .greaterEqual: guard _depth >= depth_ptr.pointee else { return }
                        }
                        
                        depth_ptr.pointee = _depth
                        if let source = shader(ImageContextRenderStageIn(vertex: b, triangle: (_v0, _v1, _v2), barycentric: barycentric, position: position, facing: facing, depth: _depth)) {
                            buf.blender.draw(color: source)
                        }
                        
                    } else if let source = shader(ImageContextRenderStageIn(vertex: b, triangle: (_v0, _v1, _v2), barycentric: barycentric, position: position, facing: facing, depth: 0)) {
                        buf.blender.draw(color: source)
                    }
                }
            }
        }
        
        self.withUnsafePixelBlender { blender in
            
            if let depthFun = depthFun {
                
                self.withUnsafeMutableDepthBufferPointer { _depth in
                    
                    guard let _depth = _depth.baseAddress else { return }
                    
                    let rasterizer = ImageContextRenderBuffer(blender: blender, depth: _depth, width: width, height: height)
                    
                    _render(rasterizer: rasterizer, position: position, depthFun: depthFun, shader: shader)
                }
            } else {
                
                let rasterizer = ImageContextRenderBuffer(blender: blender, depth: nil, width: width, height: height)
                
                _render(rasterizer: rasterizer, position: position, depthFun: nil, shader: shader)
            }
        }
    }
}

extension ImageContext {
    
    @inlinable
    public func render<G : ImageContextRenderTriangleGenerator, P : ColorPixelProtocol>(_ triangles: G, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Point, Pixel.Model == P.Model {
        render(triangles, position: { $0 }, depthFun: nil, shader: shader)
    }
}

public struct OrthographicProjectMatrix {
    
    public var nearZ: Double
    public var farZ: Double
    
    @inlinable
    public init(nearZ: Double, farZ: Double) {
        self.nearZ = nearZ
        self.farZ = farZ
    }
}

extension ImageContext {
    
    @inlinable
    public func render<G : ImageContextRenderTriangleGenerator, P : ColorPixelProtocol>(_ triangles: G, projection: OrthographicProjectMatrix, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Vector, Pixel.Model == P.Model {
        
        let width = Double(self.width)
        let height = Double(self.height)
        
        render(triangles, position: { Point(x: (0.5 + 0.5 * $0.x) * width, y: (0.5 + 0.5 * $0.y) * height) }, depthFun: { ($0.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: { shader($0) })
    }
}

public struct PerspectiveProjectMatrix {
    
    public var angle: Double
    public var nearZ: Double
    public var farZ: Double
    
    @inlinable
    public init(angle: Double, nearZ: Double, farZ: Double) {
        self.angle = angle
        self.nearZ = nearZ
        self.farZ = farZ
    }
}

@inlinable
public func *(lhs: Vector, rhs: PerspectiveProjectMatrix) -> Point {
    let cotan = 1.0 / tan(0.5 * rhs.angle)
    let dz = rhs.farZ - rhs.nearZ 
    let _z = lhs.z * (rhs.farZ + rhs.nearZ) + 2.0 * rhs.farZ * rhs.nearZ
    let _w = dz / _z
    return Point(x: lhs.x * cotan * _w, y: lhs.y * cotan * _w)
}

@_fixed_layout
@usableFromInline
struct _PerspectiveProjectTriangleGenerator<Base : ImageContextRenderTriangleGenerator> : ImageContextRenderTriangleGenerator where Base.Vertex.Position == Vector {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    init(base: Base) {
        self.base = base
    }
    
    @inlinable
    func render(position: (_Vertex.Position) -> Point, _ body: (_Vertex, _Vertex, _Vertex) -> Void) {
        base.render(position: position) { body(_Vertex(vertex: $0), _Vertex(vertex: $1), _Vertex(vertex: $2)) }
    }
}

extension _PerspectiveProjectTriangleGenerator {
    
    @usableFromInline
    @_fixed_layout
    struct _Vertex : ImageContextRenderVertex {
        
        @usableFromInline
        var v: Base.Vertex
        
        @usableFromInline
        var w: Double
        
        @inlinable
        init(v: Base.Vertex, w: Double) {
            self.v = v
            self.w = w
        }
        
        @inlinable
        init(vertex: Base.Vertex) {
            self.w = 1 / vertex.position.z
            self.v = w * vertex
        }
        
        @inlinable
        var vertex: Base.Vertex {
            return (1 / w) * v
        }
        
        @inlinable
        var position: Base.Vertex.Position {
            return vertex.position
        }
        
        @inlinable
        static func + (lhs: _Vertex, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs.v + rhs.v, w: lhs.w + rhs.w)
        }
        
        @inlinable
        static func * (lhs: Double, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs * rhs.v, w: lhs * rhs.w)
        }
    }
}

extension ImageContextRenderStageIn {
    
    @inlinable
    init<Base>(_ stageIn: ImageContextRenderStageIn<_PerspectiveProjectTriangleGenerator<Base>._Vertex>) where Base.Vertex == Vertex {
        self.vertex = stageIn.vertex.vertex
        self.triangle = stageIn.triangle
        self.barycentric = stageIn.barycentric
        self.position = stageIn.position
        self.facing = stageIn.facing
        self.depth = stageIn.depth
    }
}

extension ImageContext {
    
    @inlinable
    public func render<G : ImageContextRenderTriangleGenerator, P : ColorPixelProtocol>(_ triangles: G, projection: PerspectiveProjectMatrix, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Vector, Pixel.Model == P.Model {
        
        let width = Double(self.width)
        let height = Double(self.height)
        
        @inline(__always)
        func _position(_ v: Vector) -> Point {
            let p = v * projection
            return Point(x: (0.5 + 0.5 * p.x) * width, y: (0.5 + 0.5 * p.y) * height)
        }
        
        render(_PerspectiveProjectTriangleGenerator(base: triangles), position: _position, depthFun: { ($0.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: { shader(ImageContextRenderStageIn($0)) })
    }
}

@_fixed_layout
@usableFromInline
struct _RenderTriangleSequence<Base: Sequence, Vertex: ImageContextRenderVertex> : ImageContextRenderTriangleGenerator where Base.Element == (Vertex, Vertex, Vertex) {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    init(base: Base) {
        self.base = base
    }
    
    @inlinable
    func render(position: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        base.forEach(body)
    }
}

extension ImageContext {
    
    @inlinable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, position: (Vertex.Position) -> Point, depthFun: ((Vertex.Position) -> Double)?, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), position: position, depthFun: depthFun, shader: shader)
    }
    
    @inlinable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), shader: shader)
    }
    
    @inlinable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, projection: OrthographicProjectMatrix, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), projection: projection, shader: shader)
    }
    
    @inlinable
    public func render<S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol>(_ triangles: S, projection: PerspectiveProjectMatrix, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), projection: projection, shader: shader)
    }
}

