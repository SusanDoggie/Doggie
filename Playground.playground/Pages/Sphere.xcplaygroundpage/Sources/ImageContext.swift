
import Cocoa
import Doggie

extension Vector : ImageContextRenderVertex {
    
    public var position: Vector {
        return self
    }
}

extension CubicBezierTriangularPatch : ImageContextRenderTriangleGenerator where Element == Vector {
    
    public typealias Vertex = Element
    
    public func render(projection: (Vertex.Position) -> Point, _ body: (Vertex, Vertex, Vertex) -> Void) {
        
        let p0 = projection(m300.position)
        let p1 = projection(m030.position)
        let p2 = projection(m003.position)
        
        let d0 = p0 - p1
        let d1 = p1 - p2
        let d2 = p2 - p0
        
        let epsilon = 5.0
        
        if abs(d0.x) < epsilon && abs(d0.y) < epsilon && abs(d1.x) < epsilon && abs(d1.y) < epsilon && abs(d2.x) < epsilon && abs(d2.y) < epsilon {
            
//            var v0 = m300
//            var v1 = m030
//            var v2 = m003
//
//            let c0 = SimplexNoise(8, 0.7, 0.025, v0.x, v0.y, v0.z) * 2 - 1
//            let c1 = SimplexNoise(8, 0.7, 0.025, v1.x, v1.y, v1.z) * 2 - 1
//            let c2 = SimplexNoise(8, 0.7, 0.025, v2.x, v2.y, v2.z) * 2 - 1
//
//            v0 += c0 * 1 * normal(1, 0)
//            v1 += c1 * 1 * normal(0, 1)
//            v2 += c2 * 1 * normal(0, 0)

            body(m300, m030, m003)
            
        } else {
            
            let (a, b) = self.halving(projection: projection)
            a.render(projection: projection, body)
            b.render(projection: projection, body)
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
    
    context.render(list.map { $0 * matrix }, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}

