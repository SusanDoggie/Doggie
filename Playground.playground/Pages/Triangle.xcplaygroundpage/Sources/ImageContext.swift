
import Cocoa
import Doggie

struct Vertex : ImageContextRenderVertex {
    
    var position: Point
    
    var color: ColorPixel<RGBColorModel>
    
    static func + (lhs: Vertex, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs.position + rhs.position, color: lhs.color + rhs.color)
    }
    
    static func * (lhs: Double, rhs: Vertex) -> Vertex {
        return Vertex(position: lhs * rhs.position, color: lhs * rhs.color)
    }
}

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
    
    func shader(vertex: Vertex) -> ColorPixel<RGBColorModel> {
        
        return vertex.color
    }
    
    let triangle = (Vertex(position: Point(x: 50, y: 50), color: ColorPixel(red: 1, green: 0, blue: 0, opacity: 1)),
                    Vertex(position: Point(x: 450, y: 50), color: ColorPixel(red: 0, green: 1, blue: 0, opacity: 1)),
                    Vertex(position: Point(x: 450, y: 450), color: ColorPixel(red: 0, green: 0, blue: 1, opacity: 1)))
    
    context.render(CollectionOfOne(triangle), shader: shader)
    
    return context.image
}

