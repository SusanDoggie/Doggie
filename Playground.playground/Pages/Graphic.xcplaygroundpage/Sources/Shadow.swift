
import Cocoa
import Doggie
import DoggieGP

public func shadow(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.shadowBlur = 10
    context.shadowOffset = Size(width: 10, height: 10)
    
    context.beginTransparencyLayer()
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.endTransparencyLayer()
    
    return context.image
}

public func shadow_pdf(width: Int, height: Int) -> NSImage? {
    
    let context = PDFContext(width: Double(width), height: Double(height), colorSpace: AnyColorSpace(.sRGB))
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: AnyColor(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: AnyColor.black)
    
    context.shadowBlur = 10
    context.shadowOffset = Size(width: 10, height: 10)
    
    context.beginTransparencyLayer()
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: AnyColor(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: AnyColor.black)
    
    context.endTransparencyLayer()
    
    return try? NSImage(data: context.data())
}

public func shadow_gp(width: Int, height: Int) throws -> Image<Float32ColorPixel<RGBColorModel>> {
    
    let context = DGImageContext<RGBColorModel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.shadowBlur = 10
    context.shadowOffset = Size(width: 10, height: 10)
    
    context.beginTransparencyLayer()
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 1, cap: .round, join: .round, color: RGBColorModel())
    
    context.endTransparencyLayer()
    
    try context.render()
    
    return context.image
}
