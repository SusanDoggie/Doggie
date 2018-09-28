
import Cocoa
import Doggie

struct ColorVertex : ImageContextRenderVertex {
    
    var position: Vector
    
    var color: ColorPixel<RGBColorModel>
    
    static func + (lhs: ColorVertex, rhs: ColorVertex) -> ColorVertex {
        return ColorVertex(position: lhs.position + rhs.position, color: lhs.color + rhs.color)
    }
    
    static func * (lhs: Double, rhs: ColorVertex) -> ColorVertex {
        return ColorVertex(position: lhs * rhs.position, color: lhs * rhs.color)
    }
}

public func orthographicProject(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let matrix = Matrix.scale(0.4) * Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let c0 = ColorPixel(red: 0, green: 0, blue: 0, opacity: 1)
    let c1 = ColorPixel(red: 1, green: 0, blue: 0, opacity: 1)
    let c2 = ColorPixel(red: 0, green: 1, blue: 0, opacity: 1)
    let c3 = ColorPixel(red: 0, green: 0, blue: 1, opacity: 1)
    let c4 = ColorPixel(red: 1, green: 1, blue: 0, opacity: 1)
    let c5 = ColorPixel(red: 1, green: 0, blue: 1, opacity: 1)
    let c6 = ColorPixel(red: 0, green: 1, blue: 1, opacity: 1)
    let c7 = ColorPixel(red: 1, green: 1, blue: 1, opacity: 1)
    
    let v0 = ColorVertex(position: Vector(x: 1, y: 1, z: -1) * matrix, color: c0)
    let v1 = ColorVertex(position: Vector(x: -1, y: 1, z: -1) * matrix, color: c1)
    let v2 = ColorVertex(position: Vector(x: -1, y: -1, z: -1) * matrix, color: c5)
    let v3 = ColorVertex(position: Vector(x: 1, y: -1, z: -1) * matrix, color: c3)
    let v4 = ColorVertex(position: Vector(x: 1, y: 1, z: 1) * matrix, color: c2)
    let v5 = ColorVertex(position: Vector(x: -1, y: 1, z: 1) * matrix, color: c4)
    let v6 = ColorVertex(position: Vector(x: -1, y: -1, z: 1) * matrix, color: c7)
    let v7 = ColorVertex(position: Vector(x: 1, y: -1, z: 1) * matrix, color: c6)
    
    // face v0, v1, v2, v3
    let t0 = (v0, v1, v2)
    let t1 = (v0, v2, v3)
    
    // face v7, v6, v5, v4
    let t2 = (v7, v6, v5)
    let t3 = (v7, v5, v4)
    
    // face v4, v0, v3, v7
    let t4 = (v4, v0, v3)
    let t5 = (v4, v3, v7)
    
    // face v1, v5, v6, v2
    let t6 = (v1, v5, v6)
    let t7 = (v1, v6, v2)
    
    // face v0, v4, v5, v1
    let t8 = (v0, v4, v5)
    let t9 = (v0, v5, v1)
    
    // face v7, v3, v2, v6
    let t10 = (v7, v3, v2)
    let t11 = (v7, v2, v6)
    
    func shader(stageIn: ImageContextRenderStageIn<ColorVertex>) -> ColorPixel<RGBColorModel> {
        
        return stageIn.vertex.color
    }
    
    let triangles = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11]
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(triangles, projection: OrthographicProjectMatrix(nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

public func perspectiveProject(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let matrix = Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let c0 = ColorPixel(red: 0, green: 0, blue: 0, opacity: 1)
    let c1 = ColorPixel(red: 1, green: 0, blue: 0, opacity: 1)
    let c2 = ColorPixel(red: 0, green: 1, blue: 0, opacity: 1)
    let c3 = ColorPixel(red: 0, green: 0, blue: 1, opacity: 1)
    let c4 = ColorPixel(red: 1, green: 1, blue: 0, opacity: 1)
    let c5 = ColorPixel(red: 1, green: 0, blue: 1, opacity: 1)
    let c6 = ColorPixel(red: 0, green: 1, blue: 1, opacity: 1)
    let c7 = ColorPixel(red: 1, green: 1, blue: 1, opacity: 1)
    
    let v0 = ColorVertex(position: Vector(x: 25, y: 25, z: -25) * matrix, color: c0)
    let v1 = ColorVertex(position: Vector(x: -25, y: 25, z: -25) * matrix, color: c1)
    let v2 = ColorVertex(position: Vector(x: -25, y: -25, z: -25) * matrix, color: c5)
    let v3 = ColorVertex(position: Vector(x: 25, y: -25, z: -25) * matrix, color: c3)
    let v4 = ColorVertex(position: Vector(x: 25, y: 25, z: 25) * matrix, color: c2)
    let v5 = ColorVertex(position: Vector(x: -25, y: 25, z: 25) * matrix, color: c4)
    let v6 = ColorVertex(position: Vector(x: -25, y: -25, z: 25) * matrix, color: c7)
    let v7 = ColorVertex(position: Vector(x: 25, y: -25, z: 25) * matrix, color: c6)
    
    // face v0, v1, v2, v3
    let t0 = (v0, v1, v2)
    let t1 = (v0, v2, v3)
    
    // face v7, v6, v5, v4
    let t2 = (v7, v6, v5)
    let t3 = (v7, v5, v4)
    
    // face v4, v0, v3, v7
    let t4 = (v4, v0, v3)
    let t5 = (v4, v3, v7)
    
    // face v1, v5, v6, v2
    let t6 = (v1, v5, v6)
    let t7 = (v1, v6, v2)
    
    // face v0, v4, v5, v1
    let t8 = (v0, v4, v5)
    let t9 = (v0, v5, v1)
    
    // face v7, v3, v2, v6
    let t10 = (v7, v3, v2)
    let t11 = (v7, v2, v6)
    
    func shader(stageIn: ImageContextRenderStageIn<ColorVertex>) -> ColorPixel<RGBColorModel> {
        
        return stageIn.vertex.color
    }
    
    let triangles = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11]
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(triangles, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

struct UVVertex : ImageContextRenderVertex {
    
    var position: Vector
    
    var uv: Point
    
    static func + (lhs: UVVertex, rhs: UVVertex) -> UVVertex {
        return UVVertex(position: lhs.position + rhs.position, uv: lhs.uv + rhs.uv)
    }
    
    static func * (lhs: Double, rhs: UVVertex) -> UVVertex {
        return UVVertex(position: lhs * rhs.position, uv: lhs * rhs.uv)
    }
}

public func texturedCube(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    var texture_image = Image<ARGB32ColorPixel>(width: 16, height: 16, colorSpace: ColorSpace.sRGB)
    
    for y in 0..<texture_image.height {
        for x in 0..<texture_image.width {
            texture_image[x, y] = y & 1 == 0 ? Color(colorSpace: ColorSpace.sRGB, red: 0.5, green: 0.25, blue: 0) : Color(colorSpace: ColorSpace.sRGB, red: 0.75, green: 0.5, blue: 0.25)
        }
    }
    
    let texture = Texture(image: texture_image, resamplingAlgorithm: .none)
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let matrix = Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let v0 = Vector(x: 25, y: 25, z: -25) * matrix
    let v1 = Vector(x: -25, y: 25, z: -25) * matrix
    let v2 = Vector(x: -25, y: -25, z: -25) * matrix
    let v3 = Vector(x: 25, y: -25, z: -25) * matrix
    let v4 = Vector(x: 25, y: 25, z: 25) * matrix
    let v5 = Vector(x: -25, y: 25, z: 25) * matrix
    let v6 = Vector(x: -25, y: -25, z: 25) * matrix
    let v7 = Vector(x: 25, y: -25, z: 25) * matrix
    
    // face v0, v1, v2, v3
    let t0 = (UVVertex(position: v0, uv: Point(x: 0, y: 0)), UVVertex(position: v1, uv: Point(x: 1, y: 0)), UVVertex(position: v2, uv: Point(x: 1, y: 1)))
    let t1 = (UVVertex(position: v0, uv: Point(x: 0, y: 0)), UVVertex(position: v2, uv: Point(x: 1, y: 1)), UVVertex(position: v3, uv: Point(x: 0, y: 1)))
    
    // face v7, v6, v5, v4
    let t2 = (UVVertex(position: v7, uv: Point(x: 0, y: 0)), UVVertex(position: v6, uv: Point(x: 1, y: 0)), UVVertex(position: v5, uv: Point(x: 1, y: 1)))
    let t3 = (UVVertex(position: v7, uv: Point(x: 0, y: 0)), UVVertex(position: v5, uv: Point(x: 1, y: 1)), UVVertex(position: v4, uv: Point(x: 0, y: 1)))
    
    // face v4, v0, v3, v7
    let t4 = (UVVertex(position: v4, uv: Point(x: 0, y: 0)), UVVertex(position: v0, uv: Point(x: 1, y: 0)), UVVertex(position: v3, uv: Point(x: 1, y: 1)))
    let t5 = (UVVertex(position: v4, uv: Point(x: 0, y: 0)), UVVertex(position: v3, uv: Point(x: 1, y: 1)), UVVertex(position: v7, uv: Point(x: 0, y: 1)))
    
    // face v1, v5, v6, v2
    let t6 = (UVVertex(position: v1, uv: Point(x: 0, y: 0)), UVVertex(position: v5, uv: Point(x: 1, y: 0)), UVVertex(position: v6, uv: Point(x: 1, y: 1)))
    let t7 = (UVVertex(position: v1, uv: Point(x: 0, y: 0)), UVVertex(position: v6, uv: Point(x: 1, y: 1)), UVVertex(position: v2, uv: Point(x: 0, y: 1)))
    
    // face v0, v4, v5, v1
    let t8 = (UVVertex(position: v0, uv: Point(x: 0, y: 0)), UVVertex(position: v4, uv: Point(x: 1, y: 0)), UVVertex(position: v5, uv: Point(x: 1, y: 1)))
    let t9 = (UVVertex(position: v0, uv: Point(x: 0, y: 0)), UVVertex(position: v5, uv: Point(x: 1, y: 1)), UVVertex(position: v1, uv: Point(x: 0, y: 1)))
    
    // face v7, v3, v2, v6
    let t10 = (UVVertex(position: v7, uv: Point(x: 0, y: 0)), UVVertex(position: v3, uv: Point(x: 1, y: 0)), UVVertex(position: v2, uv: Point(x: 1, y: 1)))
    let t11 = (UVVertex(position: v7, uv: Point(x: 0, y: 0)), UVVertex(position: v2, uv: Point(x: 1, y: 1)), UVVertex(position: v6, uv: Point(x: 0, y: 1)))
    
    func shader(stageIn: ImageContextRenderStageIn<UVVertex>) -> ColorPixel<RGBColorModel> {
        
        return texture.pixel(stageIn.vertex.uv * 16)
    }
    
    let triangles = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11]
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(triangles, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

extension Vector : ImageContextRenderVertex {
    
    public var position: Vector {
        return self
    }
}

public struct TriangularPatchTessellator : ImageContextRenderTriangleGenerator {
    
    public let patch: CubicBezierTriangularPatch<Vector>
    
    private let q0: Point
    private let q1: Point
    private let q2: Point
    
    private init(patch: CubicBezierTriangularPatch<Vector>, _ q0: Point, _ q1: Point, _ q2: Point) {
        self.patch = patch
        self.q0 = q0
        self.q1 = q1
        self.q2 = q2
    }
    
    public init(patch: CubicBezierTriangularPatch<Vector>) {
        self.patch = patch
        self.q0 = Point(x: 1, y: 0)
        self.q1 = Point(x: 0, y: 1)
        self.q2 = Point(x: 0, y: 0)
    }
    
    public func render(projection: (Vector) -> Point, _ body: (Vector, Vector, Vector) -> Void) {
        
        let m300 = patch.eval(q0.x, q0.y)
        let m030 = patch.eval(q1.x, q1.y)
        let m003 = patch.eval(q2.x, q2.y)
        
        let p0 = projection(m300.position)
        let p1 = projection(m030.position)
        let p2 = projection(m003.position)
        
        let d0 = p0 - p1
        let d1 = p1 - p2
        let d2 = p2 - p0
        
        let epsilon = 5.0
        
        if abs(d0.x) < epsilon && abs(d0.y) < epsilon && abs(d1.x) < epsilon && abs(d1.y) < epsilon && abs(d2.x) < epsilon && abs(d2.y) < epsilon {
            
            var v0 = m300
            var v1 = m030
            var v2 = m003
            
            let c0 = SimplexNoise(8, 0.7, 0.025, v0.x, v0.y, v0.z) * 2 - 1
            let c1 = SimplexNoise(8, 0.7, 0.025, v1.x, v1.y, v1.z) * 2 - 1
            let c2 = SimplexNoise(8, 0.7, 0.025, v2.x, v2.y, v2.z) * 2 - 1
            
            v0 += c0 * 2.5 * patch.normal(q0.x, q0.y).unit
            v1 += c1 * 2.5 * patch.normal(q1.x, q1.y).unit
            v2 += c2 * 2.5 * patch.normal(q2.x, q2.y).unit
            
            body(v0, v1, v2)
            
        } else {
            
            let s0 = 0.5 * (q0 + q1)
            let s1 = 0.5 * (q1 + q2)
            let s2 = 0.5 * (q2 + q0)
            
            TriangularPatchTessellator(patch: patch, q0, s0, s2).render(projection: projection, body)
            TriangularPatchTessellator(patch: patch, s0, q1, s1).render(projection: projection, body)
            TriangularPatchTessellator(patch: patch, s2, s1, q2).render(projection: projection, body)
            TriangularPatchTessellator(patch: patch, s0, s1, s2).render(projection: projection, body)
        }
    }
}

public func tessellation(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let c = 0.5519150244935105707435627227925666423361803947243089
    
    let v0 = Vector(x: 1, y: 0, z: 0)
    let v1 = Vector(x: 1, y: c, z: 0)
    let v2 = Vector(x: c, y: 1, z: 0)
    let v3 = Vector(x: 0, y: 1, z: 0)
    let v4 = Vector(x: 0, y: 1, z: c)
    let v5 = Vector(x: 0, y: c, z: 1)
    let v6 = Vector(x: 0, y: 0, z: 1)
    let v7 = Vector(x: c, y: 0, z: 1)
    let v8 = Vector(x: 1, y: 0, z: c)
    let v9 = Vector(x: 0.9, y: 0.9, z: 0.9)
    
    let matrix = Matrix.scale(25) * Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let p0 = CubicBezierTriangularPatch(v0, v1, v2, v3, v8, v9, v4, v7, v5, v6)
    let p1 = p0 * Matrix.rotateX(degreesToRad(90))
    let p2 = p1 * Matrix.rotateX(degreesToRad(90))
    let p3 = p2 * Matrix.rotateX(degreesToRad(90))
    let p4 = p0 * Matrix.rotateY(degreesToRad(180))
    let p5 = p1 * Matrix.rotateY(degreesToRad(180))
    let p6 = p2 * Matrix.rotateY(degreesToRad(180))
    let p7 = p3 * Matrix.rotateY(degreesToRad(180))
    
    let list = [p0, p1, p2, p3, p4, p5, p6, p7]
    
    func shader(stageIn: ImageContextRenderStageIn<Vector>) -> ColorPixel<RGBColorModel> {
        
        let position = stageIn.vertex.position
        let normal = stageIn.normal.unit
        
        let obj_color = RGBColorModel(red: 0.8, green: 0.7, blue: 1)
        var result = ColorPixel(color: RGBColorModel(red: 0, green: 0, blue: 0))
        
        do {
            
            let ambient_strength = 0.3
            let light_color = RGBColorModel(red: 0.7, green: 0.9, blue: 0.4)
            
            result.red += obj_color.red * ambient_strength * light_color.red
            result.green += obj_color.green * ambient_strength * light_color.green
            result.blue += obj_color.blue * ambient_strength * light_color.blue
            
        }
        
        do {
            
            let light_position = Vector(x: -100, y: 100, z: -10)
            let light_color = RGBColorModel(red: 1.0, green: 1.0, blue: 1.0)
            
            let d = position - light_position
            let distance = d.magnitude
            
            let power = 40000 / (distance * distance)
            let cos_theta = max(0, dot(normal, d / distance))
            
            let light_strength = cos_theta * power
            
            result.red += obj_color.red * light_strength * light_color.red
            result.green += obj_color.green * light_strength * light_color.green
            result.blue += obj_color.blue * light_strength * light_color.blue
            
        }
        
        do {
            
            let light_position = Vector(x: 250, y: -200, z: 30)
            let light_color = RGBColorModel(red: 0.9, green: 0.7, blue: 0.4)
            
            let d = position - light_position
            let distance = d.magnitude
            
            let power = 60000 / (distance * distance)
            let cos_theta = max(0, dot(normal, d / distance))
            
            let light_strength = cos_theta * power
            
            result.red += obj_color.red * light_strength * light_color.red
            result.green += obj_color.green * light_strength * light_color.green
            result.blue += obj_color.blue * light_strength * light_color.blue
            
        }
        
        return result
    }
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(list.map { TriangularPatchTessellator(patch: $0 * matrix) }, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

