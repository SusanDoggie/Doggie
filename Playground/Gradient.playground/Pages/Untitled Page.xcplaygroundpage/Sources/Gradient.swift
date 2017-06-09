
import Cocoa
import Doggie

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext(width: width, height: height, colorSpace: CalibratedRGBColorSpace.sRGB)
    
    context.transform = SDTransform.scale(x: Double(width) / 300, y: Double(height) / 300)
    
    let stop1 = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
    let stop2 = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    context.drawLinearGradient(stops: [stop1, stop2], start: Point(x: 50, y: 50), end: Point(x: 250, y: 250), startSpread: .pad, endSpread: .pad)
    
    return Image(image: context.image)
}

