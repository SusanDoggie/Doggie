//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let size = 500

let range: Double = 128

showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: CalibratedRGBColorSpace.sRGB)

showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: CalibratedRGBColorSpace.adobeRGB)

showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: CalibratedRGBColorSpace.displayP3)
