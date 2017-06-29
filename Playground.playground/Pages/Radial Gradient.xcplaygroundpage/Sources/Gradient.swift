
import Cocoa
import Doggie

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext<ARGB32ColorPixel>(width: width, height: height, colorSpace: ColorSpace.sRGB)
    
    context.transform = SDTransform.scale(x: Double(width) / 300, y: Double(height) / 300)
    
    let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
    let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    context.drawRadialGradient(stops: [stop1, stop2], start: Point(x: 100, y: 150), startRadius: 0, end: Point(x: 150, y: 150), endRadius: 100, startSpread: .pad, endSpread: .pad)
    
    return context.image
}

