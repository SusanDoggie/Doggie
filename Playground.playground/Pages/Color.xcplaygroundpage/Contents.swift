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
    
    print("")
    
}

do {
    
    let list = NSColorSpace.availableColorSpaces(with: .RGB).map { ($0.localizedName, $0.cgColorSpace, $0.iccProfileData.flatMap { try? AnyColorSpace(iccData: $0) }) }
    let _list = list.filter { $0.0 != nil && $0.1 != nil && $0.2 != nil }.map { ($0.0!, $0.1!, $0.2!) }
    
    for (name, cgColorSpace, colorSpace) in _list {
        
        print(name)
        
        let c0 = CGColor(colorSpace: cgColorSpace, components: [0.5, 0.3, 0.7, 1])!.converted(to: D50.cgColorSpace!, intent: .relativeColorimetric, options: nil)!
        let c1 = AnyColor(colorSpace: colorSpace, components: [0.5, 0.3, 0.7], opacity: 1).convert(to: D50, intent: .relativeColorimetric)
        
        let c2 = c0.converted(to: cgColorSpace, intent: .relativeColorimetric, options: nil)!
        let c3 = c1.convert(to: colorSpace, intent: .relativeColorimetric)
        
        let c4 = CGColor(colorSpace: cgColorSpace, components: [0.5, 0.3, 0.7, 1])!.converted(to: D50.cgColorSpace!, intent: .absoluteColorimetric, options: nil)!
        let c5 = AnyColor(colorSpace: colorSpace, components: [0.5, 0.3, 0.7], opacity: 1).convert(to: D50, intent: .absoluteColorimetric)
        
        let c6 = c0.converted(to: cgColorSpace, intent: .relativeColorimetric, options: nil)!
        let c7 = c1.convert(to: colorSpace, intent: .relativeColorimetric)
        
        print("CoreGraphic:", c0.components!)
        print("Doggie:     ", (0..<3).map { c1.component($0) })
        
        print("CoreGraphic:", c2.components!)
        print("Doggie:     ", (0..<3).map { c3.component($0) })
        
        print("CoreGraphic:", c4.components!)
        print("Doggie:     ", (0..<3).map { c5.component($0) })
        
        print("CoreGraphic:", c6.components!)
        print("Doggie:     ", (0..<3).map { c7.component($0) })
        
        print("")
        
    }
}

do {
    
    let list = NSColorSpace.availableColorSpaces(with: .CMYK).map { ($0.localizedName, $0.cgColorSpace, $0.iccProfileData.flatMap { try? AnyColorSpace(iccData: $0) }) }
    let _list = list.filter { $0.0 != nil && $0.1 != nil && $0.2 != nil }.map { ($0.0!, $0.1!, $0.2!) }
    
    for (name, cgColorSpace, colorSpace) in _list {
        
        print(name)
        
        let c0 = CGColor(colorSpace: cgColorSpace, components: [0.5, 0.3, 0.7, 0.4, 1])!.converted(to: D50.cgColorSpace!, intent: .relativeColorimetric, options: nil)!
        let c1 = AnyColor(colorSpace: colorSpace, components: [0.5, 0.3, 0.7, 0.4], opacity: 1).convert(to: D50, intent: .relativeColorimetric)
        
        let c2 = c0.converted(to: cgColorSpace, intent: .relativeColorimetric, options: nil)!
        let c3 = c1.convert(to: colorSpace, intent: .relativeColorimetric)
        
        let c4 = CGColor(colorSpace: cgColorSpace, components: [0.5, 0.3, 0.7, 0.4, 1])!.converted(to: D50.cgColorSpace!, intent: .absoluteColorimetric, options: nil)!
        let c5 = AnyColor(colorSpace: colorSpace, components: [0.5, 0.3, 0.7, 0.4], opacity: 1).convert(to: D50, intent: .absoluteColorimetric)
        
        let c6 = c0.converted(to: cgColorSpace, intent: .relativeColorimetric, options: nil)!
        let c7 = c1.convert(to: colorSpace, intent: .relativeColorimetric)
        
        print("CoreGraphic:", c0.components!)
        print("Doggie:     ", (0..<3).map { c1.component($0) })
        
        print("CoreGraphic:", c2.components!)
        print("Doggie:     ", (0..<4).map { c3.component($0) })
        
        print("CoreGraphic:", c4.components!)
        print("Doggie:     ", (0..<3).map { c5.component($0) })
        
        print("CoreGraphic:", c6.components!)
        print("Doggie:     ", (0..<4).map { c7.component($0) })
        
        print("")
        
    }
}

