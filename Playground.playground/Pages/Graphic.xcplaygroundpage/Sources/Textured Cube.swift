
import Cocoa
import Doggie

private struct UVVertex : ImageContextRenderVertex {

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

    let matrix = Matrix.rotateY(.pi / 6) * Matrix.rotateX(.pi / 6) * Matrix.translate(x: 0, y: 0, z: 100)

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

    func shader(stageIn: ImageContextRenderStageIn<UVVertex>) -> Float64ColorPixel<RGBColorModel> {

        return texture.pixel(stageIn.vertex.uv * 16)
    }

    let triangles = [t0, t1, t2, t3, t4, t5, t6, t7, t8, t9, t10, t11]

    context.renderCullingMode = .back
    context.renderDepthCompareMode = .less

    context.render(triangles, projection: PerspectiveProjectMatrix(angle: 5 * .pi / 18, nearZ: 1, farZ: 500), shader: shader)

    return context.image
}
