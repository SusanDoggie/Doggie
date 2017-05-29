
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
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 1, green: 0, blue: 0)),
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)),
                         Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 1)))
    
    let n = 8
    
    for _v in 0...n {
        let v = Double(_v) / Double(n)
        for _u in 0...n {
            let u = Double(_u) / Double(n)
            
            let q1 = Bezier(patch.m00, patch.m01, patch.m02, patch.m03)
            let q2 = Bezier(patch.m10, patch.m11, patch.m12, patch.m13)
            let q3 = Bezier(patch.m20, patch.m21, patch.m22, patch.m23)
            let q4 = Bezier(patch.m30, patch.m31, patch.m32, patch.m33)
            
            context.draw(shape: Shape([Shape.Component(start: q1.eval(u), segments: [.cubic(q2.eval(u), q3.eval(u), q4.eval(u))])]).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 0), opacity: 0.01), winding: .nonZero)
            
            let q5 = Bezier(patch.m00, patch.m10, patch.m20, patch.m30)
            let q6 = Bezier(patch.m01, patch.m11, patch.m21, patch.m31)
            let q7 = Bezier(patch.m02, patch.m12, patch.m22, patch.m32)
            let q8 = Bezier(patch.m03, patch.m13, patch.m23, patch.m33)
            
            context.draw(shape: Shape([Shape.Component(start: q5.eval(v), segments: [.cubic(q6.eval(v), q7.eval(v), q8.eval(v))])]).strokePath(width: 1, cap: .round, join: .round), color: Color(colorSpace: context.colorSpace, color: RGBColorModel(red: 0, green: 0, blue: 0), opacity: 0.01), winding: .nonZero)
        }
    }
    
    return Image(image: context.image)
}

extension Image : CustomPlaygroundQuickLookable {
    
    public var customPlaygroundQuickLook: PlaygroundQuickLook {
        
        return .text("Image{ width: \(width), height: \(height) }")
    }
}
