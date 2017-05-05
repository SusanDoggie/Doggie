
import Cocoa
import Doggie

func createImage(data rawData: UnsafeRawPointer, size: CGSize) -> CGImage? {
    
    let imageWidth = Int(size.width)
    let imageHeight = Int(size.height)
    
    let bitsPerComponent: Int = 8
    let bytesPerPixel: Int = 4
    let bitsPerPixel: Int = bytesPerPixel * bitsPerComponent
    
    let bytesPerRow = bytesPerPixel * imageWidth
    
    return CGImage.create(rawData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: CGColorSpace(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.last.rawValue)
}

extension NSImage {
    
    convenience init(cgImage image: CGImage) {
        self.init(cgImage: image, size: NSZeroSize)
    }
}

let lab = CIELabColorSpace(white: Point(x: 0.34567, y: 0.35850))
let luv = CIELuvColorSpace(white: Point(x: 0.34567, y: 0.35850))

public func showLab(size: Int, x: ClosedRange<Double>, y: ClosedRange<Double>, z: Double, colorSpace: CalibratedRGBColorSpace) -> NSImage? {
    
    var buffer = [UInt32](repeating: 0, count: size * size)
    
    for j in 0..<size {
        for i in 0..<size {
            let index = j * size + i
            let x = (x.upperBound - x.lowerBound) * Double(i) / Double(size) + x.lowerBound
            let y = (y.upperBound - y.lowerBound) * Double(j) / Double(size) + y.lowerBound
            let rgb = lab.convert(LabColorModel(lightness: z, a: x, b: y), to: colorSpace)
            if 0...1 ~= rgb.red && 0...1 ~= rgb.green && 0...1 ~= rgb.blue {
                let red = UInt32(rgb.red * Double(UInt8.max))
                let green = UInt32(rgb.green * Double(UInt8.max))
                let blue = UInt32(rgb.blue * Double(UInt8.max))
                buffer[index] = red | green << 8 | blue << 16 | 0xff000000
            } else {
                buffer[index] = 0xff000000
            }
        }
    }
    
    if let image = createImage(data: &buffer, size: CGSize(width: size, height: size)) {
        
        return NSImage(cgImage: image)
    }
    
    return nil
}

public func showLuv(size: Int, x: ClosedRange<Double>, y: ClosedRange<Double>, z: Double, colorSpace: CalibratedRGBColorSpace) -> NSImage? {
    
    var buffer = [UInt32](repeating: 0, count: size * size)
    
    for j in 0..<size {
        for i in 0..<size {
            let index = j * size + i
            let x = (x.upperBound - x.lowerBound) * Double(i) / Double(size) + x.lowerBound
            let y = (y.upperBound - y.lowerBound) * Double(j) / Double(size) + y.lowerBound
            let rgb = luv.convert(LuvColorModel(lightness: z, u: x, v: y), to: colorSpace)
            if 0...1 ~= rgb.red && 0...1 ~= rgb.green && 0...1 ~= rgb.blue {
                let red = UInt32(rgb.red * Double(UInt8.max))
                let green = UInt32(rgb.green * Double(UInt8.max))
                let blue = UInt32(rgb.blue * Double(UInt8.max))
                buffer[index] = red | green << 8 | blue << 16 | 0xff000000
            } else {
                buffer[index] = 0xff000000
            }
        }
    }
    
    if let image = createImage(data: &buffer, size: CGSize(width: size, height: size)) {
        
        return NSImage(cgImage: image)
    }
    
    return nil
}
