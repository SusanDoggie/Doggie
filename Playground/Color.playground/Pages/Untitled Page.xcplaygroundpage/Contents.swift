//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let srgb = CalibratedRGBColorSpace.sRGB

let size = 500

let range: Double = 128

showLab(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: srgb)

showLuv(size: size, x: -range...range, y: -range...range, z: 50, colorSpace: srgb)
