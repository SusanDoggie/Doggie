//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let D50 = CIEXYZColorSpace(white: CIEXYZColorSpace.Model(luminance: 1, x: 0.34567, y: 0.35850))

CalibratedRGBColorSpace.adobeRGB.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: D50)

CalibratedRGBColorSpace.adobeRGB.normalized.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: D50)
