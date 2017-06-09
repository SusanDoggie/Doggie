//: Playground - noun: a place where people can play

import Cocoa
import Doggie

do {
    
    let cgColor1 = NSColor(colorSpace: NSColorSpace.adobeRGB1998, components: [0.5, 0, 0, 1], count: 4).cgColor
    
    let cgColor2 = Color(colorSpace: CalibratedRGBColorSpace.adobeRGB, red: 0.5, green: 0, blue: 0).cgColor!
    
    let xyz = CGColorSpace(name: CGColorSpace.genericXYZ)!
    
    print(cgColor1.converted(to: xyz, intent: .defaultIntent, options: nil))
    print(cgColor2.converted(to: xyz, intent: .defaultIntent, options: nil))
    
}

