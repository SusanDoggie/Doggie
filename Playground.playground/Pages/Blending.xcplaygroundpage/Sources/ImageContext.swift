
import Cocoa
import Doggie

public func doggie(blendMode: ColorBlendMode, compositingMode: ColorCompositingMode, opacity: Double) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: 500, height: 500, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(shape: Shape(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
    
    context.stroke(shape: Shape(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55)), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
    context.blendMode = blendMode
    
    context.compositingMode = compositingMode
    
    context.opacity = opacity
    
    context.draw(shape: Shape(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55)), winding: .nonZero, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))
    
    context.stroke(shape: Shape(ellipseIn: Rect(x: 35, y: 10, width: 55, height: 55)), width: 4, cap: .round, join: .round, color: RGBColorModel())
    
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


