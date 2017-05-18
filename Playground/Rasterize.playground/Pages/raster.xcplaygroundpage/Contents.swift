//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let size = 1000

var shape = try Shape(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")

shape.scale *= Double(size) / max(shape.boundary.width, shape.boundary.height)

shape.center = Point(x: 0.5 * Double(size), y: 0.5 * Double(size))

let t = Date()

let sample = drawImage(shape: shape, width: size, height: size)

t.timeIntervalSinceNow

let _colorspace = CGColorSpace(name: CGColorSpace.linearSRGB) ?? CGColorSpaceCreateDeviceRGB()
let _bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue

public func createImage(data rawData: UnsafeRawPointer, size: CGSize) -> CGImage? {
    
    let imageWidth = Int(size.width)
    let imageHeight = Int(size.height)
    
    let bitsPerComponent: Int = 8
    let bytesPerPixel: Int = 4
    let bitsPerPixel: Int = bytesPerPixel * bitsPerComponent
    
    let bytesPerRow = bytesPerPixel * imageWidth
    
    return CGImage.create(rawData, width: imageWidth, height: imageHeight, bitsPerComponent: bitsPerComponent, bitsPerPixel: bitsPerPixel, bytesPerRow: bytesPerRow, space: _colorspace, bitmapInfo: _bitmapInfo)
}

extension NSImage {
    
    public convenience init(cgImage image: CGImage) {
        self.init(cgImage: image, size: NSZeroSize)
    }
}

sample.withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: sample.width, height: sample.height)) {
        NSImage(cgImage: image)
    }
}
