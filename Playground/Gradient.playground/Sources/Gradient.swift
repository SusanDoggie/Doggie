
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
    
    //context.drawLinearGradient(stops: [from, to], start: Point(x: 3 * (width >> 3), y: 3 * (height >> 3)), end: Point(x: 4 * (width >> 3), y: 4 * (height >> 3)), startSpread: .reflect, endSpread: .reflect)
    
    context.drawRadialGradient(stops: [from, to], start: Point(x: 3 * (height >> 3), y: 3 * (height >> 3)), startRadius: Double(width >> 2), end: Point(x: 4 * (width >> 3), y: 4 * (height >> 3)), endRadius: Double(width >> 4), startSpread: .pad, endSpread: .pad)
    
    return Image(image: context.image)
}

public func coregraphic(width: Int, height: Int) -> NSImage {
    
    return NSImage.create(size: CGSize(width: width, height: height)) { context in
        
        context.drawRadialGradient(CGGradient(colorSpace: NSColorSpace.sRGB.cgColorSpace!, colorComponents: [1, 0, 0, 1, 0, 0, 1, 1], locations: [0, 1], count: 2)!, startCenter: CGPoint(Point(x: 3 * (height >> 3), y: 3 * (height >> 3))), startRadius: CGFloat(width >> 2), endCenter: CGPoint(Point(x: 4 * (width >> 3), y: 4 * (height >> 3))), endRadius: CGFloat(width >> 4), options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        
    }
}

extension Image : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        
        return .text("Image{ width: \(width), height: \(height) }")
    }
}
