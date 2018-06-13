
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

struct Vertex : ImageContextRenderVertex {
    
    var position: Vector
    
    static func + (lhs: Vertex, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs.position + rhs.position)
    }
    
    static func * (lhs: Double, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs * rhs.position)
    }
}

public func tessellation(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let matrix = Matrix.scale(25) * Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let t = 0.5 + 0.5 * sqrt(5.0)
    
    let v0 = Vector(x: -1, y: t, z: 0).unit
    let v1 = Vector(x: 1, y: t, z: 0).unit
    let v2 = Vector(x: -1, y: -t, z: 0).unit
    let v3 = Vector(x: 1, y: -t, z: 0).unit
    
    let v4 = Vector(x: 0, y: -1, z: t).unit
    let v5 = Vector(x: 0, y: 1, z: t).unit
    let v6 = Vector(x: 0, y: -1, z: -t).unit
    let v7 = Vector(x: 0, y: 1, z: -t).unit
    
    let v8 = Vector(x: t, y: 0, z: -1).unit
    let v9 = Vector(x: t, y: 0, z: 1).unit
    let v10 = Vector(x: -t, y: 0, z: -1).unit
    let v11 = Vector(x: -t, y: 0, z: 1).unit
    
    let f0 = (v0, v11, v5)
    let f1 = (v0, v5, v1)
    let f2 = (v0, v1, v7)
    let f3 = (v0, v7, v10)
    let f4 = (v0, v10, v11)
    
    let f5 = (v1, v5, v9)
    let f6 = (v5, v11, v4)
    let f7 = (v11, v10, v2)
    let f8 = (v10, v7, v6)
    let f9 = (v7, v1, v8)
    
    let f10 = (v3, v9, v4)
    let f11 = (v3, v4, v2)
    let f12 = (v3, v2, v6)
    let f13 = (v3, v6, v8)
    let f14 = (v3, v8, v9)
    
    let f15 = (v4, v9, v5)
    let f16 = (v2, v4, v11)
    let f17 = (v6, v2, v10)
    let f18 = (v8, v6, v7)
    let f19 = (v9, v8, v1)
    
    func tessellation(_ face: (Vector, Vector, Vector)) -> [(Vector, Vector, Vector)] {
        
        let (v0, v1, v2) = face
        
        let v3 = (v0 + v1).unit
        let v4 = (v1 + v2).unit
        let v5 = (v2 + v0).unit
        
        return [(v0, v3, v5), (v3, v1, v4), (v5, v4, v2), (v3, v4, v5)]
    }
    
    func geometry_shader(_ face: (Vector, Vector, Vector)) -> (Vector, Vector, Vector) {
        
        var (v0, v1, v2) = face
        
        let m0 = v0 * matrix
        let m1 = v1 * matrix
        let m2 = v2 * matrix
        
        let c0 = SimplexNoise(8, 0.7, 0.025, m0.x, m0.y, m0.z) * 2 - 1
        let c1 = SimplexNoise(8, 0.7, 0.025, m1.x, m1.y, m1.z) * 2 - 1
        let c2 = SimplexNoise(8, 0.7, 0.025, m2.x, m2.y, m2.z) * 2 - 1
        
        v0.magnitude += c0 * 0.1
        v1.magnitude += c1 * 0.1
        v2.magnitude += c2 * 0.1
        
        return (v0, v1, v2)
    }
    
    func shader(stageIn: ImageContextRenderStageIn<Vertex>) -> ColorPixel<RGBColorModel> {
        
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
    
    var triangles = [f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15, f16, f17, f18, f19]
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.flatMap(tessellation)
    triangles = triangles.map(geometry_shader)
    
    let _triangles = triangles.map { (Vertex(position: $0 * matrix), Vertex(position: $1 * matrix), Vertex(position: $2 * matrix)) }
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(_triangles, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

