# Introduction

A graphical context to draw.

## 3D rendering

### Coordinate system

![3D coordinate system](images/3D_coordinate_system.png)

# protocol

## ImageContextRenderVertex

### Overview

### Associated type

```swift
associatedtype Position
```

### Properties

```swift
var position: Self.Position { get }
```

### Methods

```swift
static func +(lhs: Self, rhs: Self) -> Self
```

```swift
static func *(lhs: Double, rhs: Self) -> Self
```

# class

## ImageContext

### Overview

```swift
class ImageContext<Pixel> where Pixel : ColorPixelProtocol
```

### Initializers

### Properties

```swift
var opacity: Double { get set }
```

```swift
var antialias: Bool { get set }
```

```swift
var transform: SDTransform { get set }
```

```swift
var blendMode: ColorBlendMode { get set }
```

```swift
var compositingMode: ColorCompositingMode { get set }
```

```swift
var resamplingAlgorithm: ResamplingAlgorithm { get set }
```

```swift
var renderingIntent: RenderingIntent { get set }
```

```swift
var chromaticAdaptationAlgorithm: ChromaticAdaptationAlgorithm { get set }
```

```swift
var renderCullingMode: ImageContextRenderCullMode { get set }
```

```swift
var renderDepthCompareMode: ImageContextRenderDepthCompareMode { get set }
```

```swift
var colorSpace: ColorSpace<Pixel.Model> { get }
```

```swift
var width: Int { get }
```

```swift
var height: Int { get }
```

```swift
var resolution: Resolution { get }
```

### Methods

```swift
func beginTransparencyLayer()
```
```swift
func endTransparencyLayer()
```
```swift
func drawClip<P>(body: (ImageContext<P>) throws -> Swift.Void) rethrows where P : ColorPixelProtocol, P.Model == GrayColorModel
```
```swift
func draw(image: AnyImage, transform: SDTransform)
```
```swift
func draw<C>(image: Image<C>, transform: SDTransform) where C : ColorPixelProtocol
```
```swift
func axialShading<P>(start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> P) rethrows where P : ColorPixelProtocol, Pixel.Model == P.Model
```
```swift
func radialShading<P>(start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode, shading: (Double) throws -> P) rethrows where P : ColorPixelProtocol, Pixel.Model == P.Model
```
```swift
func drawLinearGradient<C>(stops: [GradientStop<C>], start: Point, end: Point, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorModelProtocol
```
```swift
func drawRadialGradient<C>(stops: [GradientStop<C>], start: Point, startRadius: Double, end: Point, endRadius: Double, startSpread: GradientSpreadMode, endSpread: GradientSpreadMode) where C : ColorModelProtocol
```
```swift
func draw<C>(shape: Shape, color: Color<C>, winding: Shape.WindingRule) where C : ColorModelProtocol
```
```swift
func drawGradient<C>(_ patch: CubicBezierPatch, color c0: Color<C>, _ c1: Color<C>, _ c2: Color<C>, _ c3: Color<C>) where C : ColorModelProtocol
```
```swift
func draw(shape: Shape, color: AnyColor, winding: Shape.WindingRule)
```
```swift
func render<S, Vertex, P>(_ triangles: S, position: (Vertex.Position) throws -> Point, depthFun: ((Vertex.Position) throws -> Double)?, shader: (Vertex) throws -> P?) rethrows where S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol, Pixel.Model == P.Model, S.Element == (Vertex, Vertex, Vertex)
```
```swift
func render<S, Vertex, P>(_ triangles: S, shader: (Vertex) throws -> P?) rethrows where S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol, Pixel.Model == P.Model, S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Point
```
```swift
func render<S, Vertex, P>(_ triangles: S, projection: PerspectiveProjectMatrix, shader: (Vertex) throws -> P?) rethrows where S : Sequence, Vertex : ImageContextRenderVertex, P : ColorPixelProtocol, Pixel.Model == P.Model, S.Element == (Vertex, Vertex, Vertex), Vertex.Position == Vector
```
```swift
func clearClipBuffer(with value: Double = default)
```
```swift
func clearRenderDepthBuffer(with value: Double = default)
```
