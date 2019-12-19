
import Cocoa
import Doggie

public func circle(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.scale(x: Double(width) / 100, y: Double(height) / 100)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    return context.image
}

public func circle_pdf(width: Int, height: Int) -> NSImage? {
    
    let context = PDFContext(width: Double(width), height: Double(height), colorSpace: AnyColorSpace(.sRGB))
    
    context.scale(x: Double(width) / 100, y: Double(height) / 100)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: AnyColor(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: AnyColor.black)
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: AnyColor(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: AnyColor.black)
    
    return try? NSImage(data: context.data())
}

public func circle_gpu(width: Int, height: In) -> CIImage {
    
    let context = GPContext(width: width, height: width)
    
    context.scale(x: Double(width) / 100, y: Double(height) / 100)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: CGColor(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 4, cap: .round, join: .round, color: CGColor.black)
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: CGColor(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 4, cap: .round, join: .round, color: CGColor.black)
    
    return context.image
}
