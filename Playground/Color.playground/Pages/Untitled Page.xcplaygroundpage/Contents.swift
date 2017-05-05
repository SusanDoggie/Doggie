//: Playground - noun: a place where people can play

import Cocoa
import Doggie

public func createImage(data rawData: UnsafeRawPointer, size: CGSize) -> CGImage? {
    
    let imageWidth = Int(size.width)
    let imageHeight = Int(size.height)
    
    let bitsPerComponent: Int = 8
    let bytesPerPixel: Int = 4
    let bitsPerPixel: Int = bytesPerPixel * bitsPerComponent
    
    let bytesPerRow = bytesPerPixel * imageWidth
    
    return CGImage.create(rawData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: CGColorSpace(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.last.rawValue)
}

extension NSImage {
    
    public convenience init(cgImage image: CGImage) {
        self.init(cgImage: image, size: NSZeroSize)
    }
}

let lab = CIELabColorSpace(white: Point(x: 0.34567, y: 0.35850))
let luv = CIELuvColorSpace(white: Point(x: 0.34567, y: 0.35850))

let srgb = CalibratedRGBColorSpace.sRGB

let size = 128

var buffer = [UInt32](repeating: 0, count: size * size)

for j in 0..<size {
    for i in 0..<size {
        let index = j * size + i
        let x = 256 * Double(i) / Double(size) - 128
        let y = 256 * Double(j) / Double(size) - 128
        let rgb = lab.convert(LabColorModel(lightness: 50, a: x, b: y), to: srgb)
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
    
    NSImage(cgImage: image)
}

for j in 0..<size {
    for i in 0..<size {
        let index = j * size + i
        let x = 256 * Double(i) / Double(size) - 128
        let y = 256 * Double(j) / Double(size) - 128
        let rgb = luv.convert(LuvColorModel(lightness: 50, u: x, v: y), to: srgb)
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
    
    NSImage(cgImage: image)
}
