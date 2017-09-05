
# Introduction


# struct

## Font

### Overview

### Initializers

```swift
init(font: Font, size: Double)
```

### Properties

```swift
var pointSize: Double { get set }
```
```swift
var numberOfGlyphs: Int { get }
```
```swift
var coveredCharacterSet: CharacterSet { get }
```
```swift
var ascender: Double { get }
```
```swift
var descender: Double { get }
```
```swift
var lineGap: Double { get }
```
```swift
var verticalAscender: Double? { get }
```
```swift
var verticalDescender: Double? { get }
```
```swift
var verticalLineGap: Double? { get }
```
```swift
var unitsPerEm: Double { get }
```
```swift
var boundingRectForFont: Rect { get }
```
```swift
var italicAngle: Double { get }
```
```swift
var weight: Int? { get }
```
```swift
var stretch: Int? { get }
```
```swift
var isFixedPitch: Bool { get }
```
```swift
var isItalic: Bool { get }
```
```swift
var isBold: Bool { get }
```
```swift
var isExpanded: Bool { get }
```
```swift
var isCondensed: Bool { get }
```
```swift
var underlinePosition: Double { get }
```
```swift
var underlineThickness: Double { get }
```
```swift
var fontName: String { get }
```
```swift
var displayName: String? { get }
```
```swift
var uniqueName: String? { get }
```
```swift
var familyName: String? { get }
```
```swift
var faceName: String? { get }
```
```swift
var familyClass: Font.FamilyClass? { get }
```
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

### Properties

```swift
var familyNames: Set<String> { get }
```

### Methods

```swift
func filter(_ isIncluded: (Font) throws -> Bool) rethrows -> FontCollection
```

### Conforms To

- SetAlgebra
- Hashable
- Collection
- ExpressibleByArrayLiteral
