//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let size = 500

let range: Double = 128

if let image = showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: ColorSpace.sRGB).cgImage {
    NSImage(cgImage: image)
}

if let image = showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: ColorSpace.adobeRGB).cgImage {
    NSImage(cgImage: image)
}

if let image = showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: ColorSpace.displayP3).cgImage {
    NSImage(cgImage: image)
}
