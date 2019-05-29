
import Cocoa
import Doggie
import DoggieGP

public func doggie(blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, opacity: Double) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
    context.blendMode = blendMode
    
    context.compositingMode = compositingMode
    
    context.opacity = opacity
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
    return context.image
}

public func doggie_pdf(blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, opacity: Double) -> NSImage? {
    
    let context = PDFContext(width: 500, height: 500, colorSpace: AnyColorSpace(.sRGB))
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: AnyColor(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 4, cap: .round, join: .round, color: AnyColor.black)
    
    context.blendMode = blendMode
    
    context.compositingMode = compositingMode
    
    context.opacity = opacity
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: AnyColor(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 4, cap: .round, join: .round, color: AnyColor.black)
    
    return try? NSImage(data: context.data())
}

public func doggie_gp(blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, opacity: Double) throws -> Image<Float32ColorPixel<RGBColorModel>> {
    
    let context = GPImageContext<RGBColorModel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
    context.blendMode = blendMode
    
    context.compositingMode = compositingMode
    
    context.opacity = opacity
    
    context.draw(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
    try context.render()
    
    return context.image
}

public func coregraphic(blendMode: CGBlendMode, opacity: Double) -> CGImage? {
    
    return CGImage.create(width: 500, height: 500) { context in
        
        context.scaleBy(x: 5, y: 5)
        
        context.setLineWidth(4)
        
        context.setStrokeColor(NSColor.black.cgColor)
        context.setFillColor(NSColor(srgbRed: 247/255, green: 217/255, blue: 12/255, alpha: 1).cgColor)
        
        context.fillEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
        context.strokeEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
        
        context.setBlendMode(blendMode)
        context.setAlpha(CGFloat(opacity))
        
        context.setFillColor(NSColor(srgbRed: 234/255, green: 24/255, blue: 71/255, alpha: 1).cgColor)
        
        context.fillEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
        context.strokeEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
    }
}


