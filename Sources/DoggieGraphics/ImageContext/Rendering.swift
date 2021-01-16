//
//  Rendering.swift
//
//  The MIT License
//  Copyright (c) 2015 - 2021 Susan Cheng. All rights reserved.
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
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

extension ImageContext {
    
    @frozen
    @usableFromInline
    struct RenderBuffer: RasterizeBufferProtocol {
        
        @usableFromInline
        var blender: PixelBlender
        
        @usableFromInline
        var depth: UnsafeMutablePointer<Float>?
        
        @usableFromInline
        var width: Int
        
        @usableFromInline
        var height: Int
        
        @inlinable
        @inline(__always)
        init(blender: PixelBlender, depth: UnsafeMutablePointer<Float>?, width: Int, height: Int) {
            self.blender = blender
            self.depth = depth
            self.width = width
            self.height = height
        }
    }
}

extension ImageContext.RenderBuffer {
    
    @inlinable
    @inline(__always)
    static func + (lhs: Self, rhs: Int) -> Self {
        return Self(blender: lhs.blender + rhs, depth: lhs.depth.map { $0 + rhs }, width: lhs.width, height: lhs.height)
    }
    
    @inlinable
    @inline(__always)
    static func += (lhs: inout Self, rhs: Int) {
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

@frozen
public struct ImageContextRenderStageIn<Vertex: ImageContextRenderVertex> {
    
    public var vertex: Vertex
    
    public var triangle: (Vertex.Position, Vertex.Position, Vertex.Position)
    
    public var barycentric: Vector
    
    public var projection: Point
    
    public var depth: Double
    
    @inlinable
    @inline(__always)
    init(vertex: Vertex, triangle: (Vertex.Position, Vertex.Position, Vertex.Position), barycentric: Vector, projection: Point, depth: Double) {
        self.vertex = vertex
        self.triangle = triangle
        self.barycentric = barycentric
        self.projection = projection
        self.depth = depth
    }
}

extension ImageContextRenderStageIn {
    
    @inlinable
    @inline(__always)
    public var position: Vertex.Position {
        return vertex.position
    }
}

extension ImageContextRenderStageIn where Vertex.Position == Vector {
    
    @inlinable
    @inline(__always)
    public var normal: Vector {
        return cross(triangle.1 - triangle.0, triangle.2 - triangle.0)
    }
}

public protocol ImageContextRenderTriangleGenerator {
    
    associatedtype Vertex: ImageContextRenderVertex
    
    func render(projection: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void)
}

public protocol ImageContextRenderPipelineShader {
    
    associatedtype StageIn: ImageContextRenderVertex where StageIn.Position == StageOut.Position
    
    associatedtype StageOut: ImageContextRenderVertex
    
    func render(projection: (StageIn.Position) -> Point, stageIn: (StageIn, StageIn, StageIn), stageOut: (StageOut, StageOut, StageOut) -> Void)
}

@frozen
public struct ImageContextRenderPipeline<Generator: ImageContextRenderTriangleGenerator, Shader: ImageContextRenderPipelineShader>: ImageContextRenderTriangleGenerator where Generator.Vertex == Shader.StageIn {
    
    public typealias Vertex = Shader.StageOut
    
    public let generator: Generator
    public let shader: Shader
    
    @inlinable
    @inline(__always)
    init(generator: Generator, shader: Shader) {
        self.generator = generator
        self.shader = shader
    }
    
    @inlinable
    @inline(__always)
    public func render(projection: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        generator.render(projection: projection) { shader.render(projection: projection, stageIn: ($0, $1, $2), stageOut: body) }
    }
}

extension ImageContextRenderTriangleGenerator {
    
    @inlinable
    @inline(__always)
    public func bind<S>(_ shader: S) -> ImageContextRenderPipeline<Self, S> {
        return ImageContextRenderPipeline(generator: self, shader: shader)
    }
}

extension Sequence where Self: ImageContextRenderTriangleGenerator, Element: ImageContextRenderTriangleGenerator, Element.Vertex == Vertex {
    
    @inlinable
    @inline(__always)
    public func render(projection: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        self.forEach { $0.render(projection: projection, body) }
    }
}

extension Array: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ArraySlice: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ContiguousArray: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension MappedBuffer: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension UnsafeBufferPointer: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension UnsafeMutableBufferPointer: ImageContextRenderTriangleGenerator where Element: ImageContextRenderTriangleGenerator {
    
    public typealias Vertex = Element.Vertex
    
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func render<G: ImageContextRenderTriangleGenerator, P: ColorPixel>(_ triangles: G, projection: (G.Vertex.Position) -> Point, depthFun: ((G.Vertex.Position) -> Double)?, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where Pixel.Model == P.Model {
        
        let width = self.width
        let height = self.height
        let transform = self.transform
        let cullingMode = self.renderCullingMode
        let depthCompareMode = self.renderDepthCompareMode
        
        guard width != 0 && height != 0 && transform.invertible else { return }
        
        @inline(__always)
        func _render(rasterizer: RenderBuffer) {
            
            triangles.render(projection: projection) { v0, v1, v2 in
                
                let _v0 = v0.position
                let _v1 = v1.position
                let _v2 = v2.position
                
                if let depthFun = depthFun {
                    guard 0...1 ~= depthFun(_v0) || 0...1 ~= depthFun(_v1) || 0...1 ~= depthFun(_v2) else { return }
                }
                
                let p0 = projection(_v0)
                let p1 = projection(_v1)
                let p2 = projection(_v2)
                
                switch cullingMode {
                case .none: break
                case .front: guard cross(p1 - p0, p2 - p0) > 0 else { return }
                case .back: guard cross(p1 - p0, p2 - p0) < 0 else { return }
                }
                
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
                            
                            let depth = Float(_depth)
                            
                            guard 0...1 ~= _depth else { return nil }
                            guard let depth_ptr = buf.depth else { return nil }
                            
                            switch depthCompareMode {
                            case .always: break
                            case .never: return nil
                            case .equal: guard depth == depth_ptr.pointee else { return nil }
                            case .notEqual: guard depth != depth_ptr.pointee else { return nil }
                            case .less: guard depth < depth_ptr.pointee else { return nil }
                            case .lessEqual: guard depth <= depth_ptr.pointee else { return nil }
                            case .greater: guard depth > depth_ptr.pointee else { return nil }
                            case .greaterEqual: guard depth >= depth_ptr.pointee else { return nil }
                            }
                            
                            depth_ptr.pointee = depth
                            
                            if let source = shader(ImageContextRenderStageIn(vertex: b, triangle: (_v0, _v1, _v2), barycentric: barycentric, projection: position, depth: _depth)) {
                                return source
                            }
                            
                        } else if let source = shader(ImageContextRenderStageIn(vertex: b, triangle: (_v0, _v1, _v2), barycentric: barycentric, projection: position, depth: 0)) {
                            return source
                        }
                        
                        return nil
                    }
                }
            }
        }
        
        if depthFun == nil {
            
            self.withUnsafePixelBlender { blender in
                
                let rasterizer = RenderBuffer(blender: blender, depth: nil, width: width, height: height)
                
                _render(rasterizer: rasterizer)
            }
            
        } else {
            
            self.withUnsafeMutableDepthBufferPointer { _depth in
                
                guard let _depth = _depth.baseAddress else { return }
                
                self.withUnsafePixelBlender { blender in
                    
                    let rasterizer = RenderBuffer(blender: blender, depth: _depth, width: width, height: height)
                    
                    _render(rasterizer: rasterizer)
                }
            }
        }
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func render<G: ImageContextRenderTriangleGenerator, P: ColorPixel>(_ triangles: G, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Point, Pixel.Model == P.Model {
        render(triangles, projection: { $0 }, depthFun: nil, shader: shader)
    }
}

@frozen
public struct OrthographicProjectMatrix {
    
    public var nearZ: Double
    public var farZ: Double
    
    @inlinable
    @inline(__always)
    public init(nearZ: Double, farZ: Double) {
        self.nearZ = nearZ
        self.farZ = farZ
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func render<G: ImageContextRenderTriangleGenerator, P: ColorPixel>(_ triangles: G, projection: OrthographicProjectMatrix, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Vector, Pixel.Model == P.Model {
        
        let width = Double(self.width)
        let height = Double(self.height)
        
        @inline(__always)
        func _projection(_ v: Vector) -> Point {
            return Point(x: (0.5 + 0.5 * v.x) * width, y: (0.5 + 0.5 * v.y) * height)
        }
        
        render(triangles, projection: _projection, depthFun: { ($0.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: shader)
    }
}

@frozen
public struct PerspectiveProjectMatrix {
    
    public var angle: Double
    public var nearZ: Double
    public var farZ: Double
    
    @inlinable
    @inline(__always)
    public init(angle: Double, nearZ: Double, farZ: Double) {
        self.angle = angle
        self.nearZ = nearZ
        self.farZ = farZ
    }
}

@inlinable
@inline(__always)
public func *(lhs: Vector, rhs: PerspectiveProjectMatrix) -> Point {
    let cotan = 1.0 / tan(0.5 * rhs.angle)
    let dz = rhs.farZ - rhs.nearZ 
    let _z = lhs.z * (rhs.farZ + rhs.nearZ) + 2.0 * rhs.farZ * rhs.nearZ
    let _w = dz / _z
    return Point(x: lhs.x * cotan * _w, y: lhs.y * cotan * _w)
}

@frozen
@usableFromInline
struct _PerspectiveProjectTriangleGenerator<Base: ImageContextRenderTriangleGenerator>: ImageContextRenderTriangleGenerator where Base.Vertex.Position == Vector {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    @inline(__always)
    init(base: Base) {
        self.base = base
    }
    
    @inlinable
    @inline(__always)
    func render(projection: (_Vertex.Position) -> Point, _ body: (_Vertex, _Vertex, _Vertex) -> Void) {
        base.render(projection: projection) { body(_Vertex(vertex: $0), _Vertex(vertex: $1), _Vertex(vertex: $2)) }
    }
}

extension _PerspectiveProjectTriangleGenerator {
    
    @frozen
    @usableFromInline
    struct _Vertex: ImageContextRenderVertex {
        
        @usableFromInline
        var v: Base.Vertex
        
        @usableFromInline
        var w: Double
        
        @inlinable
        @inline(__always)
        init(v: Base.Vertex, w: Double) {
            self.v = v
            self.w = w
        }
        
        @inlinable
        @inline(__always)
        init(vertex: Base.Vertex) {
            self.w = 1 / vertex.position.z
            self.v = w * vertex
        }
        
        @inlinable
        @inline(__always)
        var vertex: Base.Vertex {
            return (1 / w) * v
        }
        
        @inlinable
        @inline(__always)
        var position: Base.Vertex.Position {
            return vertex.position
        }
        
        @inlinable
        @inline(__always)
        static func + (lhs: _Vertex, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs.v + rhs.v, w: lhs.w + rhs.w)
        }
        
        @inlinable
        @inline(__always)
        static func * (lhs: Double, rhs: _Vertex) -> _Vertex {
            return _Vertex(v: lhs * rhs.v, w: lhs * rhs.w)
        }
    }
}

extension ImageContextRenderStageIn {
    
    @inlinable
    @inline(__always)
    init<Base>(_ stageIn: ImageContextRenderStageIn<_PerspectiveProjectTriangleGenerator<Base>._Vertex>) where Base.Vertex == Vertex {
        self.vertex = stageIn.vertex.vertex
        self.triangle = stageIn.triangle
        self.barycentric = stageIn.barycentric
        self.projection = stageIn.projection
        self.depth = stageIn.depth
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func render<G: ImageContextRenderTriangleGenerator, P: ColorPixel>(_ triangles: G, projection: PerspectiveProjectMatrix, shader: (ImageContextRenderStageIn<G.Vertex>) -> P?) where G.Vertex.Position == Vector, Pixel.Model == P.Model {
        
        let width = Double(self.width)
        let height = Double(self.height)
        
        @inline(__always)
        func _projection(_ v: Vector) -> Point {
            let p = v * projection
            return Point(x: (0.5 + 0.5 * p.x) * width, y: (0.5 + 0.5 * p.y) * height)
        }
        
        render(_PerspectiveProjectTriangleGenerator(base: triangles), projection: _projection, depthFun: { ($0.z - projection.nearZ) / (projection.farZ - projection.nearZ) }, shader: { shader(ImageContextRenderStageIn($0)) })
    }
}

@frozen
@usableFromInline
struct _RenderTriangleSequence<Base: Sequence, Vertex: ImageContextRenderVertex>: ImageContextRenderTriangleGenerator where Base.Element == (Vertex, Vertex, Vertex) {
    
    @usableFromInline
    let base: Base
    
    @inlinable
    @inline(__always)
    init(base: Base) {
        self.base = base
    }
    
    @inlinable
    @inline(__always)
    func render(projection: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        base.forEach(body)
    }
}

extension ImageContext {
    
    @inlinable
    @inline(__always)
    public func render<S: Sequence, Vertex: ImageContextRenderVertex, P: ColorPixel>(_ triangles: S, projection: (Vertex.Position) -> Point, depthFun: ((Vertex.Position) -> Double)?, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), projection: projection, depthFun: depthFun, shader: shader)
    }
    
    @inlinable
    @inline(__always)
    public func render<S: Sequence, Vertex: ImageContextRenderVertex, P: ColorPixel>(_ triangles: S, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), shader: shader)
    }
    
    @inlinable
    @inline(__always)
    public func render<S: Sequence, Vertex: ImageContextRenderVertex, P: ColorPixel>(_ triangles: S, projection: OrthographicProjectMatrix, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), projection: projection, shader: shader)
    }
    
    @inlinable
    @inline(__always)
    public func render<S: Sequence, Vertex: ImageContextRenderVertex, P: ColorPixel>(_ triangles: S, projection: PerspectiveProjectMatrix, shader: (ImageContextRenderStageIn<Vertex>) -> P?) where S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector, Pixel.Model == P.Model {
        self.render(_RenderTriangleSequence(base: triangles), projection: projection, shader: shader)
    }
}

