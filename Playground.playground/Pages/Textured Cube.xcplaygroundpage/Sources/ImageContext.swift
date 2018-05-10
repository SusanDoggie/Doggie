
import Cocoa
import Doggie

struct Vertex : ImageContextRenderVertex {
    
    var position: Vector
    
    var uv: Point
    
    static func + (lhs: Vertex, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs.position + rhs.position, uv: lhs.uv + rhs.uv)
    }
    
    static func * (lhs: Double, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs * rhs.position, uv: lhs * rhs.uv)
    }
}

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    var texture = Image<ARGB32ColorPixel>(width: 16, height: 16, colorSpace: ColorSpace.sRGB)
    
    for y in 0..<texture.height {
        for x in 0..<texture.width {
            texture[x, y] = y & 1 == 0 ? Color(colorSpace: ColorSpace.sRGB, red: 0.5, green: 0.25, blue: 0) : Color(colorSpace: ColorSpace.sRGB, red: 0.75, green: 0.5, blue: 0.25)
        }
    }
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    let matrix = Matrix.rotateY(degreesToRad(30)) * Matrix.rotateX(degreesToRad(-30)) * Matrix.translate(x: 0, y: 0, z: 100)
    
    let v0 = Vector(x: 25, y: 25, z: -25) * matrix
    let v1 = Vector(x: -25, y: 25, z: -25) * matrix
    let v2 = Vector(x: -25, y: -25, z: -25) * matrix
    let v3 = Vector(x: 25, y: -25, z: -25) * matrix
    let v4 = Vector(x: 25, y: 25, z: 25) * matrix
    let v5 = Vector(x: -25, y: 25, z: 25) * matrix
    let v6 = Vector(x: -25, y: -25, z: 25) * matrix
    let v7 = Vector(x: 25, y: -25, z: 25) * matrix
    
    // face v0, v1, v2, v3
    let t0 = (Vertex(position: v0, uv: Point(x: 0, y: 0)), Vertex(position: v1, uv: Point(x: 1, y: 0)), Vertex(position: v2, uv: Point(x: 1, y: 1)))
    let t1 = (Vertex(position: v0, uv: Point(x: 0, y: 0)), Vertex(position: v2, uv: Point(x: 1, y: 1)), Vertex(position: v3, uv: Point(x: 0, y: 1)))
    
    // face v7, v6, v5, v4
    let t2 = (Vertex(position: v7, uv: Point(x: 0, y: 0)), Vertex(position: v6, uv: Point(x: 1, y: 0)), Vertex(position: v5, uv: Point(x: 1, y: 1)))
    let t3 = (Vertex(position: v7, uv: Point(x: 0, y: 0)), Vertex(position: v5, uv: Point(x: 1, y: 1)), Vertex(position: v4, uv: Point(x: 0, y: 1)))
    
    // face v4, v0, v3, v7
    let t4 = (Vertex(position: v4, uv: Point(x: 0, y: 0)), Vertex(position: v0, uv: Point(x: 1, y: 0)), Vertex(position: v3, uv: Point(x: 1, y: 1)))
    let t5 = (Vertex(position: v4, uv: Point(x: 0, y: 0)), Vertex(position: v3, uv: Point(x: 1, y: 1)), Vertex(position: v7, uv: Point(x: 0, y: 1)))
    
    // face v1, v5, v6, v2
    let t6 = (Vertex(position: v1, uv: Point(x: 0, y: 0)), Vertex(position: v5, uv: Point(x: 1, y: 0)), Vertex(position: v6, uv: Point(x: 1, y: 1)))
    let t7 = (Vertex(position: v1, uv: Point(x: 0, y: 0)), Vertex(position: v6, uv: Point(x: 1, y: 1)), Vertex(position: v2, uv: Point(x: 0, y: 1)))
    
    // face v0, v4, v5, v1
    let t8 = (Vertex(position: v0, uv: Point(x: 0, y: 0)), Vertex(position: v4, uv: Point(x: 1, y: 0)), Vertex(position: v5, uv: Point(x: 1, y: 1)))
    let t9 = (Vertex(position: v0, uv: Point(x: 0, y: 0)), Vertex(position: v5, uv: Point(x: 1, y: 1)), Vertex(position: v1, uv: Point(x: 0, y: 1)))
    
    // face v7, v3, v2, v6
    let t10 = (Vertex(position: v7, uv: Point(x: 0, y: 0)), Vertex(position: v3, uv: Point(x: 1, y: 0)), Vertex(position: v2, uv: Point(x: 1, y: 1)))
    let t11 = (Vertex(position: v7, uv: Point(x: 0, y: 0)), Vertex(position: v2, uv: Point(x: 1, y: 1)), Vertex(position: v6, uv: Point(x: 0, y: 1)))
    
    func shader(stageIn: ImageContextRenderStageIn<Vertex>) -> ColorPixel<RGBColorModel> {
        
        let uv = stageIn.vertex.uv
        
        let u = min(max(Int(uv.x * 16), 0), 15)
        let v = min(max(Int(uv.y * 16), 0), 15)
        
        return ColorPixel(texture[u, v])
    }
    
    let triangles = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11]
    
    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less
    
    context.render(triangles, projection: PerspectiveProjectMatrix(angle: degreesToRad(50), nearZ: 1, farZ: 500), shader: shader)
    
    return context.image
}


