
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
    
    context.transform = SDTransform.scale(x: Double(width) / 300, y: Double(height) / 300)
    
    let patch = CubicBezierPatch(coonsPatch: Point(x: 50, y: 50), Point(x: 100, y: 0), Point(x: 200, y: 100), Point(x: 250, y: 50),
                                 Point(x: 100, y: 100), Point(x: 300, y: 100),
                                 Point(x: 0, y: 200), Point(x: 200, y: 200),
                                 Point(x: 50, y: 250), Point(x: 100, y: 200), Point(x: 200, y: 300), Point(x: 250, y: 250))
    
    context.drawGradient(patch, color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)),
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 1, blue: 0)),
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)),
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 1, blue: 1)))
    
    return Image(image: context.image)
}

extension Image : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        
        return .text("Image{ width: \(width), height: \(height) }")
    }
}
