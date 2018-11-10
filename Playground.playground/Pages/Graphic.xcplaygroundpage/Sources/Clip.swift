
import Cocoa
import Doggie
import DoggieGP

public func clip(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.setClip(shape: Shape(ellipseIn: Rect(x: 20, y: 20, width: width - 40, height: height - 40)), winding: .nonZero)
    
    context.transform = SDTransform.scale(x: Double(width) / 300, y: Double(height) / 300)
    
    let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
    let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    context.drawLinearGradient(stops: [stop1, stop2], start: Point(x: 50, y: 50), end: Point(x: 250, y: 250), startSpread: .pad, endSpread: .pad)
    
    return context.image
}


public func clip_gp(width: Int, height: Int) throws -> Image<FloatColorPixel<RGBColorModel>> {
    
    let context = DGImageContext<RGBColorModel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.setClip(shape: Shape(ellipseIn: Rect(x: 20, y: 20, width: width - 40, height: height - 40)), winding: .nonZero)
    
    context.transform = SDTransform.scale(x: Double(width) / 300, y: Double(height) / 300)
    
    let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
    let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    context.drawLinearGradient(stops: [stop1, stop2], start: Point(x: 50, y: 50), end: Point(x: 250, y: 250), startSpread: .pad, endSpread: .pad)
    
    try context.render()
    
    return context.image
}

