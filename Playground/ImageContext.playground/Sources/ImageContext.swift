
import Cocoa
import Doggie

public func createImage(data rawData: UnsafeRawPointer, size: CGSize, colorSpace: CGColorSpace, bitmapInfo: UInt32) -> CGImage? {
    
    let imageWidth = Int(size.width)
    let imageHeight = Int(size.height)
    
    let bitsPerComponent: Int = 8
    let bytesPerPixel: Int = 4
    let bitsPerPixel: Int = bytesPerPixel * bitsPerComponent
    
    let bytesPerRow = bytesPerPixel * imageWidth
    
    return CGImage.create(rawData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
}

public func sampleImage(width: Int, height: Int) -> Image<CalibratedRGBColorSpace, ARGB32ColorPixel> {
    
    let context = ImageContext(width: width, height: height, colorSpace: CalibratedRGBColorSpace.sRGB)
    
    context.transform = SDTransform.scale(5)
    
    context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255)), winding: .nonZero)
    
    context.draw(shape: Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)
    
    context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255)), winding: .nonZero)
    
    context.draw(shape: Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55)).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: CalibratedRGBColorSpace.sRGB, color: RGBColorModel()), winding: .nonZero)
    
    return Image(image: context.image, colorSpace: CalibratedRGBColorSpace.sRGB)
}
