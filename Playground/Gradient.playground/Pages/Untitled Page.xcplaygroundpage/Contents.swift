//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let t = Date()

let image = sampleImage1(width: 500, height: 500)

t.timeIntervalSinceNow

image.withUnsafeBufferPointer {
    
    if let image = createImage(data: $0.baseAddress!, size: CGSize(width: image.width, height: image.height), colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.first.rawValue) {
        NSImage(cgImage: image, size: NSZeroSize)
    }
}
