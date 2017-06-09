//: Playground - noun: a place where people can play

import Cocoa
import Doggie

do {
    
    let colorSpace = CalibratedRGBColorSpace.adobeRGB.cgColorSpace!
    
    let cgColor1 = NSColor(colorSpace: NSColorSpace.adobeRGB1998, components: [0.5, 0, 0, 1], count: 4).cgColor
    
    let cgColor2 = CGColor(colorSpace: colorSpace, components: [0.5, 0, 0, 1])!
    
    let xyz = CGColorSpace(name: CGColorSpace.genericXYZ)!
    
    print(cgColor1.converted(to: xyz, intent: .defaultIntent, options: nil))
    print(cgColor2.converted(to: xyz, intent: .defaultIntent, options: nil))
    
}

