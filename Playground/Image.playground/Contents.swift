//: Playground - noun: a place where people can play

import Cocoa
import Doggie

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

var sample = Image(width: 100, height: 100, pixel: ARGB32ColorPixel(), colorSpace: CalibratedRGBColorSpace.sRGB.linearTone)

sample.withUnsafeMutableBytes {
    if let context = CGContext(data: $0.baseAddress!, width: 100, height: 100, bitsPerComponent: 8, bytesPerRow: 400, space: _colorspace, bitmapInfo: _bitmapInfo) {
        
        context.setStrokeColor(NSColor.black.cgColor)
        context.setFillColor(NSColor(calibratedRed: 247/255, green: 217/255, blue: 12/255, alpha: 1).cgColor)
        
        context.fillEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
        context.strokeEllipse(in: CGRect(x: 10, y: 35, width: 55, height: 55))
        
        context.setFillColor(NSColor(calibratedRed: 234/255, green: 24/255, blue: 71/255, alpha: 1).cgColor)
        
        context.fillEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
        context.strokeEllipse(in: CGRect(x: 35, y: 10, width: 55, height: 55))
        
    }
}

sample.withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 100, height: 100)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .none).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .linear).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .cosine).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .cubic).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .hermite(0.5, 0)).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .mitchell(1/3, 1/3)).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}

Image(image: sample, width: 1000, height: 1000, resampling: .lanczos(3)).withUnsafeBytes {
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: 1000, height: 1000)) {
        NSImage(cgImage: image)
    }
}
