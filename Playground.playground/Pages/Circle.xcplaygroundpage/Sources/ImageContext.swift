
import Cocoa
import Doggie

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    return context.image
}

