//: Playground - noun: a place where people can play

import Cocoa
import Doggie

let D50 = ColorSpace.cieXYZ(white: Point(x: 0.34567, y: 0.35850))

ColorSpace.adobeRGB.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: D50)

ColorSpace.adobeRGB.convert(RGBColorModel(red: 0.5, green: 0, blue: 0), to: ColorSpace.adobeRGB.linearTone)

ColorSpace.adobeRGB.linearTone.convert(RGBColorModel(red: 0.217755528144395, green: 0, blue: 0), to: ColorSpace.adobeRGB)

do {
    
    let cgColor1 = NSColor(colorSpace: NSColorSpace.adobeRGB1998, components: [0.5, 0, 0, 1], count: 4).cgColor
    
    let cgColor2 = Color(colorSpace: ColorSpace.adobeRGB, red: 0.5, green: 0, blue: 0).cgColor!
    
    let cgColor3 = Color(colorSpace: ColorSpace.adobeRGB.linearTone, red: 0.217755528144395, green: 0, blue: 0).cgColor!
    
    let xyz = CGColorSpace(name: CGColorSpace.genericXYZ)!
    
    print(cgColor1.converted(to: xyz, intent: .defaultIntent, options: nil))
    print(cgColor2.converted(to: xyz, intent: .defaultIntent, options: nil))
    print(cgColor3.converted(to: xyz, intent: .defaultIntent, options: nil))
    
}

