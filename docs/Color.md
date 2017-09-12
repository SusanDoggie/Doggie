# Introduction

A type to define a color with a color space to specify how to interpret it.

# Usage

## Define a color

To define a color, you need to provide the color space and the color component values of the color.

```swift

let red = Color(colorSpace: .sRGB, color: RGBColorModel(red: 1, green: 0, blue: 0), opacity: 1)

```
