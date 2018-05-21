
import Cocoa
import Doggie

struct Vertex : ImageContextRenderVertex {
    
    var position: Vector
    
    static func + (lhs: Vertex, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs.position + rhs.position)
    }
    
    static func * (lhs: Double, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs * rhs.position)
    }
}

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
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

