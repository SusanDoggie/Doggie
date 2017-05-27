
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

public func sampleImage(width: Int, height: Int) -> Image<ARGB32ColorPixel> {
    
    let context = ImageContext(width: width, height: height, colorSpace: CalibratedRGBColorSpace.sRGB)
    
    let from = GradientStop(offset: 0, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)))
    let to = GradientStop(offset: 1, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    context.drawLinearGradient(stops: [from, to], start: Point(x: 3 * (width >> 3), y: 3 * (height >> 3)), end: Point(x: 4 * (width >> 3), y: 4 * (height >> 3)), startSpread: .reflect, endSpread: .reflect)
    
    return Image(image: context.image)
}

extension Image : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        
        return .text("Image{ width: \(width), height: \(height) }")
    }
}
