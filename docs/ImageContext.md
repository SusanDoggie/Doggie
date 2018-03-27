# Introduction

A graphical context to draw.

# Usage

## Create a ImageContext

To create a ImageContext, you need to provide the format of color pixel of the context. You can use the predifined color pixel or custom color pixel. The custom color pixel must be plain old data structure.

```swift

let context = ImageContext<ARGB32ColorPixel>(width: 100, height: 100, colorSpace: .sRGB)

```

## 2D rendering

### Filling color with shape

```swift

let ellipse = Shape(ellipseIn: Rect(x: 10, y: 35, width: 55, height: 55))

context.draw(shape: ellipse, winding: .nonZero, color: RGBColorModel(red: 247/255, green: 217/255, blue: 12/255))

```

### Stroking with shape

```swift

context.stroke(shape: ellipse, width: 1, cap: .round, join: .round, color: RGBColorModel())

```

## 3D rendering

### Coordinate system

![3D coordinate system](images/3D_coordinate_system.png)

