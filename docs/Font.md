
# Introduction


# struct

## FontCollection

### Overview

### Initializers

```swift
init()
```

```swift
init<S>(_ components: S) where S : Sequence, S.Element == Font
```

```swift
init(data: Data) throws
```
> Create a FontCollection with a font file.

### Properties

```swift
var familyNames: Set<String> { get }
```
> Return all the family names in this collection.

### Methods

```swift
func filter(_ isIncluded: (Font) throws -> Bool) rethrows -> FontCollection
```

### Conforms To

- SetAlgebra
- Hashable
- Collection
- ExpressibleByArrayLiteral

## Font

### Overview

### Initializers

```swift
init(font: Font, size: Double)
```
> Create new font with specific point size.

### Properties

```swift
var pointSize: Double { get set }
```
> Point size of this font.

```swift
var numberOfGlyphs: Int { get }
```
> Return number of glyphs with this font. This value may not represent the count of unicode characters covered by font.

```swift
var coveredCharacterSet: CharacterSet { get }
```
> The unicode characters covered by font. The result is approximate.

```swift
var ascender: Double { get }
```
> Ascender of this font.

```swift
var descender: Double { get }
```
> Descender of this font.

```swift
var lineGap: Double { get }
```
> Line-gap of this font.

```swift
var verticalAscender: Double? { get }
```
> Vertical ascender of this font.

```swift
var verticalDescender: Double? { get }
```
> Vertical descender of this font.

```swift
var verticalLineGap: Double? { get }
```
> Vertical line-gap of this font.

```swift
var unitsPerEm: Double { get }
```
> Units-per-Em of this font.

```swift
var boundingRectForFont: Rect { get }
```
> Bounding of all characters with this font.

```swift
var italicAngle: Double { get }
```
> Italic angle of this font.

```swift
var weight: Int? { get }
```
> Weight of this font.

```swift
var stretch: Int? { get }
```
> Stretch of this font.

```swift
var isFixedPitch: Bool { get }
```
> Return true if font is monospace.

```swift
var isItalic: Bool { get }
```
> Return true if font is italic style.

```swift
var isBold: Bool { get }
```
> Return true if font is bold style.

```swift
var isExpanded: Bool { get }
```
> Return true if font is expanded style.

```swift
var isCondensed: Bool { get }
```
> Return true if font is condensed style.

```swift
var underlinePosition: Double { get }
```
```swift
var underlineThickness: Double { get }
```
```swift
var fontName: String { get }
```
> PostScript name of this font.

```swift
var displayName: String? { get }
```
> Name of this font.

```swift
var uniqueName: String? { get }
```
> Unique name of this font.

```swift
var familyName: String? { get }
```
> Family name of this font.

```swift
var faceName: String? { get }
```
> Face name of this font.

```swift
var familyClass: Font.FamilyClass? { get }
```
> Family class of this font.

```swift
var designer: String? { get }
```
```swift
var version: String? { get }
```
```swift
var trademark: String? { get }
```
```swift
var manufacturer: String? { get }
```
```swift
var license: String? { get }
```
```swift
var copyright: String? { get }
```

### Methods

```swift
func with(size pointSize: Double) -> Font
```
> Return new font with specific point size.

```swift
func boundary(forGlyph glyph: Int) -> Rect
```
```swift
func shape(forGlyph glyph: Int) -> Shape
```
```swift
func glyph(with unicode: UnicodeScalar) -> Int
```
```swift
func advanceWidth(forGlyph glyph: Int) -> Double
```
```swift
func advanceHeight(forGlyph glyph: Int) -> Double
```
