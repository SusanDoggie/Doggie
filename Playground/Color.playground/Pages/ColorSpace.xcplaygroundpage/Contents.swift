//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let D50 = ColorSpace.cieXYZ(white: XYZColorModel(luminance: 1, x: 0.34567, y: 0.35850))

ColorSpace.adobeRGB.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: D50)

ColorSpace.adobeRGB.normalized.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: D50)

ColorSpace.adobeRGB.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: ColorSpace.adobeRGB.linearTone)

ColorSpace.adobeRGB.linearTone.convert(RGBColorModel(red: 0.217755528144395, green: 0, blue: 0), to: ColorSpace.adobeRGB)
