# Doggie - Foundation Library for Swift

[![Build Status](https://travis-ci.org/SusanDoggie/Doggie.svg?branch=master)](https://travis-ci.org/SusanDoggie/Doggie)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20iOS%20%7C%20Linux-lightgrey.svg?style=flat)
[![GitHub release](https://img.shields.io/github/release/SusanDoggie/Doggie.svg?style=flat&maxAge=2592000)](https://github.com/SusanDoggie/Doggie/releases)
[![Swift](https://img.shields.io/badge/swift-4-orange.svg?style=flat)](https://swift.org)
[![MIT](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

Doggie is a foundational library for Apple's swift. It includes mathematics, accelerate, signal processing and graphic functions.

## Features

- complex number
- accelerate and signal processing
- [polynomial](Documents/Polynomial.md)
- [color and color space](Documents/Color.md)
- [shape and boolean operation](Documents/Shape.md)
```swift
let shape = try Shape(code: "M100 0c0-100-236.60 36.60-150 86.60S36.60-136.60-50-86.60 100 100 100 0z")

let region = ShapeRegion(shape, winding: .nonZero)
let ellipse = ShapeRegion.Ellipse(shape.boundary)

region.union(ellipse)

region.intersection(ellipse)

region.subtracting(ellipse)
ellipse.subtracting(region)

region.symmetricDifference(ellipse)
```
- [font](Documents/Font.md)
```swift
let collection = try FontCollection(data: fontFileData)

if let font = collection.first?.with(size: 64) {

    let string = "Doggie\u{0301}".precomposedStringWithCompatibilityMapping

    let glyphs = string.unicodeScalars.map { font.glyph(with: $0) }
    let advances = glyphs.map { font.advanceWidth(forGlyph: $0) }.scan(0, +)

    var shape = Shape()

    for (advance, glyph) in zip(advances, glyphs) {
        var outline = font.shape(forGlyph: glyph)
        outline.center.x += advance
        shape.append(contentsOf: outline.identity)
    }

    print(shape.encode())
}
```
- [image](Documents/Image.md) and [graphics](Documents/ImageContext.md)
```swift

let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: ColorSpace.sRGB)

let black = Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel())
let yellow = Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))
let red = Color(colorSpace: ColorSpace.sRGB, color: RGBColorModel(red: 234/255, green: 24/255, blue: 71/255))

let ellipse1 = Shape.Ellipse(Rect(x: 10, y: 35, width: 55, height: 55))
let ellipse2 = Shape.Ellipse(Rect(x: 35, y: 10, width: 55, height: 55))

context.draw(shape: ellipse1, color: yellow, winding: .nonZero)
context.draw(shape: ellipse1.strokePath(width: 1, cap: .round, join: .round), color: black, winding: .nonZero)
context.draw(shape: ellipse2, color: red, winding: .nonZero)
context.draw(shape: ellipse2.strokePath(width: 1, cap: .round, join: .round), color: black, winding: .nonZero)
        
let image: Image<ARGB32ColorPixel> = context.image
```

## Status

### ColorSpace
- [x] ICC
- [x] CIEXYZ
- [x] CIELab
- [x] CIELuv
- [x] Calibrated Gray
- [x] Calibrated RGB

### ColorSpace Rendering Intent
- [ ] perceptual
- [ ] saturation
- [x] absolute colorimetric
- [x] relative colorimetric

### ImageRep
- [x] bmp
- [ ] gif
- [ ] jpeg
- [ ] jpeg2000
- [x] png
- [x] tiff

### Font
- [x] TrueType
- [ ] OpenType
- [ ] WOFF
- [ ] WOFF2

## Supporting

<a href='https://pledgie.com/campaigns/34662'><img alt='Click here to lend your support to: Doggie - Swift Foundation Library and make a donation at pledgie.com !' src='https://pledgie.com/campaigns/34662.png?skin_name=chrome' border='0' ></a>

## License

Doggie is licensed under the [MIT license](LICENSE).
