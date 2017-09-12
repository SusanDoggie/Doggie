# Introduction

A structure represents a color space.

# Usage

## Define a RGB ColorSpace

To define a RGB color space, it's have to provide the XYZ coordinates of white, red, green and blue.

```swift

let rgb = ColorSpace.calibratedRGB(white: Point(x: 0.3127, y: 0.3290),
                                   red: Point(x: 0.6400, y: 0.3300),
                                   green: Point(x: 0.3000, y: 0.6000),
                                   blue: Point(x: 0.1500, y: 0.0600))

```

You can also specify the gamma values for each primary colors.

```swift

let rgb = ColorSpace.calibratedRGB(white: Point(x: 0.3127, y: 0.3290),
                                   red: Point(x: 0.6400, y: 0.3300),
                                   green: Point(x: 0.3000, y: 0.6000),
                                   blue: Point(x: 0.1500, y: 0.0600),
                                   gamma: (2.19921875, 2.19921875, 2.19921875))

```

## Define a Grayscale ColorSpace

Define a grayscale color space is same way as RGB color space.

```swift

let gray = ColorSpace.calibratedGray(white: Point(x: 0.3127, y: 0.3290), gamma: 2.19921875)

```


## Predefined ColorSpace

Here are also some of predefined color spaces.

```swift

let adobeRGB = ColorSpace.adobeRGB
let sRGB = ColorSpace.sRGB
let displayP3 = ColorSpace.displayP3

```

